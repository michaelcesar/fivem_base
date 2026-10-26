'use strict';
// Live RP: pulls one `local function NAME(...) ... end` block out of a real resource file by
// counting block-opening/closing keywords, rather than keeping a hand-copied duplicate of the
// function here. A duplicate silently drifts the moment someone edits the real function and
// forgets the test; this fails loudly instead - if the function is renamed, removed, or the
// extraction breaks, the test throws immediately rather than quietly testing stale logic.
const fs = require('fs');

// Live RP: `do` is deliberately excluded - as the tail of `for ... do` / `while ... do` it isn't
// its own block (both are closed by a single `end`), and none of the functions this extracts use
// a standalone `do ... end` scoping block (the one case where `do` really would open one). A
// real parser wouldn't need this caveat; this keyword counter does.
function extractFunction(filePath, functionName) {
    const source = fs.readFileSync(filePath, 'utf8');
    const anchor = new RegExp(`local function ${functionName}\\s*\\(`);
    const match = anchor.exec(source);
    if (!match) {
        throw new Error(`extractFunction: "local function ${functionName}(" not found in ${filePath}`);
    }

    const start = match.index;
    let depth = 0;
    const combined = /\b(function|if|for|while|end)\b/g;
    combined.lastIndex = start;

    let endIndex = -1;
    let tok;
    while ((tok = combined.exec(source))) {
        if (tok[1] === 'end') {
            depth -= 1;
            if (depth === 0) {
                endIndex = tok.index + tok[0].length;
                break;
            }
        } else {
            depth += 1;
        }
    }

    if (endIndex === -1) {
        throw new Error(`extractFunction: unbalanced blocks looking for the end of ${functionName} in ${filePath}`);
    }

    return source.slice(start, endIndex);
}

module.exports = { extractFunction };
