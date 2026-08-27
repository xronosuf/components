# Ximera components development container

This directory defines an isolated Podman development environment for the new Ximera component architecture. It is intended to coexist safely with the legacy Xronos stack on the same host without upgrading or replacing the host's Node, TeX, or other runtime dependencies.

## Goals

- keep the new toolchain isolated from the legacy Xronos server;
- make the development/build environment reproducible for other developers;
- test `tex4npm` and the compatibility corpus under Linux/Podman;
- mount source repositories into the container rather than baking changing source code into the image;
- provide a path toward later static-server, Modulus, and Sage service integration without requiring those services now.

## Current image contents

The image is based on `node:22-trixie` and includes:

- Node.js 22 and npm;
- git;
- make, Perl, and Python 3;
- **official upstream TeX Live 2026** installed under `/usr/local/texlive/2026`;
- the LaTeX, tex4ht, graphics, PSTricks, science, and font collections needed by the compatibility corpus;
- `pdflatex`, `latex`, `tex4ht`, `t4ht`, and `dvisvgm` from that TeX Live 2026 tree.

### TeX Live date is a hard requirement

For Ximera/Xronos work, TeX is not merely a generic compiler dependency. Accessibility behavior introduced after October 31, 2025 is required, and some of that behavior is coupled to the TeX/tex4ht/MathJax pipeline. Therefore the development environment must use a TeX distribution dated **after 2025-10-31**. The current pinned requirement is TeX Live **2026**.

Do not replace the upstream TeX Live installation with the Debian-provided TeX packages merely because the base image contains them. Debian stable snapshots can lag the TeX Live release cycle substantially. The toolchain verifier intentionally fails unless the active TeX reports TeX Live 2026, making accidental regressions visible immediately.

Using current TeX Live is also relevant to the component compatibility work: `@ximera/answer` post-processing expects tex4ht's MathJax-oriented output structure, including `.mathjax-inline` / `.mathjax-block` wrappers. Testing against an obsolete tex4ht can therefore create failures that are artifacts of the build environment rather than defects in the component runtime.

Sage is intentionally not installed yet. The first compatibility build should tell us which non-Sage pages work before we expand the image.

## Recommended host layout

On the test host, keep the new architecture in a directory separate from the legacy server checkout, for example:

```text
$HOME/xronos-new-architecture/
├── components/
└── testFiles/
```

The expected branches are:

- `xronosuf/components`: `development-container`
- `xronosuf/testFiles`: `tex4npm-testing`

## Initial setup on the host

```bash
mkdir -p "$HOME/xronos-new-architecture"
cd "$HOME/xronos-new-architecture"

git clone https://github.com/xronosuf/components.git
git clone https://github.com/xronosuf/testFiles.git

cd components
git switch development-container

cd ../testFiles
git switch tex4npm-testing
```

Do not modify the existing legacy Xronos checkout or its containers for this setup.

## Build the development image

From the components checkout:

```bash
cd "$HOME/xronos-new-architecture/components"
bash dev-environment/build.sh
```

The default image name is:

```text
ximera-components-dev:latest
```

To override it:

```bash
IMAGE_NAME=my-ximera-dev:local bash dev-environment/build.sh
```

The TeX Live 2026 installation is performed while building the image, so an image rebuild requires network access to CTAN/TUG mirrors and is substantially heavier than a source-only rebuild. Source changes still do not require rebuilding the image unless the toolchain itself changes.

## Start an interactive development container

The run helper bind-mounts both repositories and starts in `/workspace/testFiles`:

```bash
cd "$HOME/xronos-new-architecture/components"
bash dev-environment/run.sh
```

Default mounts:

```text
host components checkout -> /workspace/components
host testFiles checkout  -> /workspace/testFiles
```

The container is run with:

- `--rm`, so the container itself is disposable;
- `--user 0`, because the UF test host's rootless Podman storage cannot execute image binaries as the image's non-root `node` UID;
- rootless Podman, so container UID 0 maps to the invoking unprivileged host account and does **not** grant host-root privileges;
- `--security-opt=no-new-privileges`;
- `--cap-drop=ALL`;
- `--entrypoint /bin/bash`, so RHEL Podman/runc does not depend on resolving the relative `docker-entrypoint.sh` inherited from the official Node image;
- SELinux relabeling (`:Z`) on the two bind mounts.

The `--userns=keep-id` mode is intentionally not used on this host: diagnostics showed the same executable-permission failure under that mapping. If this environment is used on a different host, the user mapping can be revisited there.

No network ports are exposed in the initial environment, and no existing Xronos container/network is joined.

If the host checkout lives somewhere else, override `TESTFILES_DIR` or `COMPONENTS_DIR`:

```bash
TESTFILES_DIR=/path/to/testFiles bash dev-environment/run.sh
```

## Verify the toolchain

Inside the container:

```bash
bash /workspace/components/dev-environment/verify-toolchain.sh
```

This checks that the expected Node, npm, Git, TeX, tex4ht/t4ht, and dvisvgm commands are present. It also verifies that the active TeX distribution is TeX Live 2026 and reports the active TEXMF root so build-environment drift is visible in diagnostics.

## First compatibility build

Inside the container, from `/workspace/testFiles`:

```bash
npm install
npm run build
```

The compatibility branch is configured to write generated static output to:

```text
/workspace/testFiles/dist/
```

The first build is exploratory. Failures should be recorded rather than worked around immediately: they are evidence about package publication, TeX dependencies, unsupported author constructs, or `tex4npm`/component behavior.

In particular, the current corpus contains Sage/runtime-Sage pages. Sage is intentionally absent from this first image, so those tests may expose expected unsupported/failure behavior until the Sage architecture is implemented.

## Testing local component changes

Installing a local package directory directly with npm creates a symlink. For `@ximera/core`, that makes Node/esbuild resolve the package's dependencies relative to `/workspace/components/core`, outside the compatibility corpus's `node_modules` tree. This differs from the resolution behavior of a published npm package.

To test development changes to core while preserving normal published-package semantics, use the packed overlay helper inside the container:

```bash
bash /workspace/components/dev-environment/install-local-core.sh
npm run build
```

The helper runs `npm pack` on the local core source and installs the resulting tarball into `testFiles` with `--no-save --package-lock=false`. This copies the package into `testFiles/node_modules` instead of linking it, so dependencies such as `@modulus-learning/agent` resolve in the same way they do in the published package. Other `@ximera/*` packages remain on their published versions unless explicitly overlaid later.

## Local static serving later

The initial milestone is compilation only. Once useful HTML exists in `dist/`, add a small HTTP-serving step rather than opening pages through `file://`. That server can initially bind only to localhost on the test host. A UF-facing reverse-proxy route should be added only after the generated pages and browser runtime are understood.

## Development model

The image contains tools, not source snapshots. The repositories remain normal Git working trees on the host and are mounted into the disposable container. This means source changes do not require rebuilding the image unless the required development toolchain itself changes.

When the environment stabilizes, this branch can be folded back into the main development branch and potentially generalized for upstream Ximera use.
