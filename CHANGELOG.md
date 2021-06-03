# Changelog

## Todo
- app - deploy jslint as chrome-extension.
- jslint - add `for...of` syntax support.
- jslint - add html and css linting back into jslint.
- jslint - add new warning if case-statements are not sorted.
- jslint - add new warning if const/let/var statements are not declared at top of function-scope.
- jslint - add new warning if const/let/var statements are not sorted.
- jslint - migrate code away from recursive-loops to for/while loops.
- node - after node-v12 is deprecated, change `require("fs").promises` to `require("fs/promises")`.
- node - after node-v14 is deprecated, remove shell-code `export "NODE_OPTIONS=--unhandled-rejections=strict"`.
- tests - update function warn_at() with assertion-check matching column with artifact.
- website - replace current-editor with CodeMirror-editor and change programming-font-family from `Programma` to `Consolas, Menlo, monospace`.

## v2021.6.3
- breaking-change - hardcode `const fudge = 1`
- breaking-change - remove little-used-feature allowing jslint to accept array-of-strings as source b/c internal lines-object has been changed from array-of-strings to array-of-objects.
- doc - add svg changelog.
- doc - add svg package-listing.
- doc - document cli-feature to jslint entire directory.
- jslint - add eslint-like ignore-directives `/*jslint-disable*/`, `/*jslint-enable*/`, `//jslint-quiet`.
- jslint - add new warning `Directive /*jslint-disable*/ was not closed with /*jslint-enable*/.`.
- jslint - add new warning `Directive /*jslint-enable*/ was not opened with /*jslint-disable*/.`.
- jslint - remove obsolete ie-era warning about duplicate names for caught-errors.
- website - move options-ui to top of page after editor-ui

## v2021.5.30
- bugfix - fix issue #282 - fail to warn trailing semicolon in `export default Object.freeze({})`.
- ci - 100% code-coverage!
- ci - auto-update changelog in README.md from CHANGELOG.md.
- ci - auto-update version numbers in README.md and jslint.js from CHANGELOG.md.
- deadcode - replace with assertion-check in function choice() - `if (char === "|") { warn... }`.
- deadcode - replace with assertion-check in function do_function() - `if (mega_mode) { warn... }`.
- deadcode - replace with assertion-check in function no_space() - `const at = (free ? ...)`.
- deadcode - replace with assertion-check in function no_space() - `if (open) {...}`.
- deadcode - replace with assertion-check in function parse_directive() - `} else if (value === "false") {...}`.
- deadcode - replace with assertion-check in function supplant() - `return ( replacement !== undefined ?...)`.
- jslint - cleanup regexp code using switch-case-statements.
- jslint - inline function `activate` into function `action_var`.
- jslint - inline-document each deadcode-removal/assertion-check.
- jslint - inline-document each warning with cause that can reproduce it - part 2.
- tests - inline remaining causal-regressions from test.js into jslint.js
- tests - validate inline-multi-causes are sorted.
- website - replace links `branch.xxx` with `branch-xxx`.

## v2021.5.27
- ci - fix expectedWarningCode not being validated.
- ci - in windows, disable git-autocrlf.
- deadcode - replace with assertion-check in function are_similar() - "if (a === b) { return true }".
- deadcode - replace with assertion-check in function are_similar() superseded by id-check - "if (Array.isArray(b)) { return false; }".
- deadcode - replace with assertion-check in function are_similar() superseded by is_weird() check - "if (a.arity === "function" && a.arity ===...c".
- jslint - add directive `test_internal_error`.
- jslint - add directive `unordered` to tolerate unordered properties and params.
- jslint - inline-document each warning with cause that can reproduce it - part 1.
- style - refactor code moving infix-operators from post-position to pre-position in multiline statements.
- website - add hotkey ctrl-enter to run jslint.

## v2021.5.26
- ci - fix ci silently failing in node-v12 and node-v14.
- cli - add env var JSLINT_CLI to force-trigger cli in jslint.js (used for code-coverage of cli).
- jslint - add "globalThis" to default globals.
- jslint - add new rules unordered_param_a, unordered_property_a, that warn if parameters and properties are listed in nonascii-order.
- jslint - fix bug where (global) functionage missing properties finally and try.
- jslint - fix bug failing to parse unicode "\\u{12345}".
- jslint - fix bug falsely warning against conditional-chaining-operator "?.".
- jslint - remove deadcode for preaction-binary-".".
- jslint - remove deadcode warning bad_option_a.
- website - add fork-me ribbon.
- website - load index.html with example code.
- website - merge file report.js into browser.js.

## v2021.5.23
- doc - add section Changelog.
- doc - update README.md with installation instructions.
- cli - merge shell-function shJslintCli into jslint.js.
- jslint - update default globals with support for "import".
- jslint - sort warnings with higher priority for early_stop.
- jslint - add async/await support.
- ci - make branch-beta the default branch.
- ci - validate non-http/file links in *.md files.
- ci - add shell-functions shCiBranchPromote.

## v2021.5.21
- this ci-release does not change any core-functionality of file jslint.js.
- doc - add file CHANGELOG.md.
- ci - begin addng regression tests and improve code-coverage.
- ci - allow pull-requests to run restricted-ci (cannot upload artifacts).
- gh-pages - fix missing assets and insecure http-links.
- gh-pages - merge file jslint.css into index.html.
- gh-pages - add files image-jslint-xxx.png.
- gh-pages - cleanup asset naming-convention.
- fix missing fonts in function.html and help.html.
- add files .gitconfig, Daley-Bold.woff2, Programma-Bold.woff2, icon-folder-open-solid.svg, icon-window-maximize-regular.svg.
- ci - fix http-links after moving to jslint-org.
- doc - migrate file README to README.md with embedded ci links and screenshots.
- ci - add macos and windows to ci-matrix.
- ci - ci now fails if jslint-check fails for any of the files in branches.
- ci - add github-workflows to generate code-coverage for jslint.js.

## v2020.11.6
- last jslint version before jslint-org migration.

## v2018.4.25
- last jslint version written in commonjs.

## v2017.11.6
- last jslint version written in es5.

## v2013.3.13
- last jslint version that can lint .html and .css files.
