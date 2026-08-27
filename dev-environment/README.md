# Ximera components development container

This directory defines an isolated Podman development environment for the new Ximera component architecture. It is intended to coexist safely with the legacy Xronos stack on the same host without upgrading or replacing the host's Node, TeX, or other runtime dependencies.

## Goals

- keep the new toolchain isolated from the legacy Xronos server;
- make the development/build environment reproducible for other developers;
- test `tex4npm` and the compatibility corpus under Linux/Podman;
- mount source repositories into the container rather than baking changing source code into the image;
- provide a path toward later static-server, Modulus, and Sage service integration without requiring those services now.

## Current image contents

The initial image is based on `node:22-bookworm` and includes:

- Node.js 22 and npm;
- git;
- make and Python 3;
- TeX Live packages needed for ordinary Ximera/tex4ht compilation;
- `pdflatex`, `latex`, `tex4ht`, `t4ht`, and `dvisvgm`.

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

This checks that the expected Node, npm, Git, TeX, tex4ht/t4ht, and dvisvgm commands are present.

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

## Local static serving later

The initial milestone is compilation only. Once useful HTML exists in `dist/`, add a small HTTP-serving step rather than opening pages through `file://`. That server can initially bind only to localhost on the test host. A UF-facing reverse-proxy route should be added only after the generated pages and browser runtime are understood.

## Development model

The image contains tools, not source snapshots. The repositories remain normal Git working trees on the host and are mounted into the disposable container. This means source changes do not require rebuilding the image unless the required development toolchain itself changes.

When the environment stabilizes, this branch can be folded back into the main development branch and potentially generalized for upstream Ximera use.
