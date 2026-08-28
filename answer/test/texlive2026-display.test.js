import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { load } from 'cheerio';
import { extractAnswerBlanks } from '../postprocess.js';

describe('TeX Live 2026 display math compatibility', () => {
  it('extracts answers from span.mathjax-block emitted by current tex4ht', () => {
    const $ = load(
      '<span class="mathjax-block">\\[ x = \\answer[id=displayAnswer]{5} \\]</span>'
    );

    extractAnswerBlanks($);

    assert.equal($('.answer.respondable').length, 1);
    assert.equal($('.answer.respondable').attr('data-correct-text'), '5');
    assert.equal($('div.ximera-math-with-answers').length, 1);
    assert.equal($('div.ximera-math-with-answers > span.mathjax-block').length, 1);
    assert.ok($('span.mathjax-block').html().includes('\\cssId{ximera-placeholder-1}'));
    assert.ok(!$('span.mathjax-block').html().includes('\\answer'));
  });
});
