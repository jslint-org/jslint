# Changelog

# Todo
- doc - document supported/unsupported es6+ features
- coverage - add macros `/*coverage-disable*/` and `/*coverage-enable*/`.
- jslint - add html and css linting back into jslint.
- jslint - add new warning requiring paren around plus-separated concatenations.
- jslint - require regexp to use open-form.
- jslint - try to improve parser to be able to parse jquery.js without stopping.
- jslint - unify analysis of variable-assignment/function-parameters into one function

# v2023.1.29
- ci - in windows-ci-env, alias node=node.exe instead of using winpty for pipes
- ci - bugfix - fix ci-shell-function shGithubFileUpload unable to upload new asset
- ci - auto-create asset_image_logo_512.png from asset_image_logo_512.html
- bugfix - fix shell-function shGithubCheckoutRemote not able to checkout trusted-files in non-alpha branches
- jslint-ci - revamp auto-updating and add shell-function shGithubCheckoutRemote
- test - print time-finished after test-run
- jslint - hide warning about unordered case-statements behind beta-flag
- ci - bugfix - update shell-function shCiBase() to handle undefined fileMain
- ci - auto-update version-number in main mjs-module
- ci - update shell-function shDirHttplinkValidate() to ignore insecure-links http://127.0.0.1, http://localhost

# v2022.11.20
- ci - update ci from node-v16 to node-v18
- cli - remove deprecated cli-option `--mode-vim-plugin`
- node - after node-v14 is deprecated, remove shell-code `export "NODE_OPTIONS=--unhandled-rejections=strict"`.
- editor - update codemirror-editor to v5.65.10
- remove obsolete help.html

# v2022.9.20
- directive - add new directive `fart` to allow complex fat-arrow

# v2022.7.20
- bugfix - warnings that should be ignored sometimes suppress legitimate warnings
- doc - document jslint directives
- vscode - add extra contextmenu commands "JSLint - Do Not Lint Selected Region", "JSLint - Ignore Current Line"

# v2022.6.21
- directive - add new directive `subscript` for linting of scripts targeting Google Closure Compiler
- bugfix - fix expression after "await" mis-identified as statement
- warning - relax warning about missing `catch` in `try...finally` statement
- jslint - allow aliases `evil, nomen` for jslint-directives `eval, name`, respectively for backwards-compat
- bugfix - fix broken codemirror example
- bugfix - fix jslint not-recognizing option-chaining when comparing operands of binary operator
- allow array-literals to directly call [...].flat() and [...].flatMap()

# v2022.5.20
- coverage-report - disable default-coverage of directory `node_modules`, but allow override with cli-option `--include-node-modules=1`
- coverage-report - add function globExclude() to revamp coverage-report to exclude files using glob-pattern-matching
- add codemirror-example-file jslint_wrapper_codemirror.html
- update codemirror-editor to v5.65.3
- wrapper - add jslint-addon for codemirror
- allow jslint.mjs to auto-export itself to globalThis when given search-param `?window_jslint=1`
- wrapper - add jslint-extension for vscode
- bugfix - fix jslint falsely believing megastring literals `0` and `1` are similar
- bugfix - fix function jstestOnExit() from exiting prematurely and suppressing additional error-messages

# v2022.3.30
- website - use localStorage to persist jslint-options selected in ui
- website - add optional debug-mode to use sessionStorage to persist jslint-globals and jslint-source from ui
- jslint - add numeric-separator support
- jslint - move regexp-literals to module-level so they are explicitly cached, to improve performance
- ci - add check for package.json.fileCount

# v2022.2.20
- test - migrate all tests to use jstestDescribe(), jstestIt()
- fs - rename jslint-wrapper-files to jslint_wrapper_xxx.xxx
- bugfix - fix issue #382 - make fart-related warnings more readable
- bugfix - fix issue #382 - fix warnings against destructured fart
- bugfix - fix issue #379 - warn against naked-statement in fart.
- update commonjs-wrapper jslint.cjs to load jslint in strict-mode.

# v2021.12.20
- npm - add file jslint.cjs so package @jslint-org/jslint can be published as dual-module
- jslint - relax warning "function_in_loop"
- update function assertJsonEqual to JSON.stringify 3rd param if its an object

# v2021.11.20
- jslint - add top-level-await support
- ci - deprecate/remove jslint.cjs from ci
- coverage - add cli-options `--exclude=aa,bb`, `--exclude-node-modules=false`, `--include=aa,bb`
- coverage - dedupe coverage-logic now applied when only one script passed
- npm - add file .npmignore
- website - add clickable-links to editor-code in report-warnings and report-functions

# v2021.10.20
- ci - add release-trigger to publish to `@jslint-org/jslint`
- bugfix - fix coverage-report having incorrect http-link to index.html
- bugfix - fix false warning `uninitialized 'bb'` in code `/*jslint node*/\nlet {aa:bb} = {}; bb();`
- bugfix - fix issue #358 - switch-statement crashes jslint
- ci - cache coverage-example node-sqlite3 to speed up ci
- ci - rename dir .build/ to .artifact/
- ci - update shell-function shRunWithCoverage() to reduce size of string/argument passed to nodejs by using 2-space-indent
- cli - add cli-command jslint_plugin_vim
- cli - add cli-command v8_coverage_report
- cli - change cli-option `--mode-report` to cli-command `jslint_report=<filename>`
- coverage - relax requirement for coverageDir to be in cwd
- deprecated - cli - add cli-option `--mode-report`
- doc - add api-documentation
- fs - merge file asset_codemirror_rollup.css into index.html
- fs - merge file browser.mjs into index.html
- fs - merge file function.html into help.html
- fs - remove little-used font asset_font_programma_bold.woff2
- fs - rename files with dashes to files with underscore
- jslint - disable linting of embedded javascript in markdown-files
- jslint - relax regexp-warning against using 'space'
- npm - add file package.json and command `npm test`
- style - change naming-convention for non-jslint-core code from underscore to camelCase
- test - add mocha-like test-functions jstestDescribe, jstestIt

# v2021.9.20
- jslint - add bigint support.
- vim - add vim-plugin and file jslint.vim.
- doc - auto-generate toc for README.md
- jslint - rename little-used directive `debug` to `trace` to avoid confusion with non-related directive `devel`.

# v2021.8.20
- warning - disable un-ergonomic warnings restricting directive-global (missing_browser and unexpected_directive_a).
- fs - rename file ci.sh to jslint_ci.sh.
- license - add codemirror license to rollup-assets.
- website - display number of warnings, properties, functions in report.
- website - fix uiLoader getting hidden behind highlighted text.

# v2021.7.24
- bugfix - fix jslint not warning about function-redefinition when function is defined inside a call.
- bugfix - fix website crashing when linting pure json-object.
- ci - fix race-condition when inlining css.
- doc - update README.md with links to archived web-demos.
- jslint - add new beta-warning against redefining global-variables.
- jslint - add new beta-warning if functions are unordered.
- jslint - add new warning disallowing string-literal as property-name, e.g. {`aa`:0}.
- jslint - comment out shebang in jslint.mjs so older ios devices can use website.
- jslint - deprecate directive `/*jslint eval*/` - use `//jslint-quiet` instead.
- jslint-revamp - rearrange functions in jslint.mjs to comply with ordered-functions beta-warning.
- jslint-revamp - revamp cause-based testing with more robust instrumentation.
- tests - test artifact and column-position in warnings are correct.

# v2021.6.30
- breaking-change - rename files *.js to *.mjs for better integration with nodejs.
- ci - auto-screenshot example-shell-commands in README.md.
- ci - include explicit commonjs (jslint.cjs) and es-module (jslint.mjs) variants of jslint.
- jslint - disable out-of-scope warning for functions.
- jslint - reintroduce directive `/*jslint indent2*/` - allow 2-space indent.
- license - change license to public-domain/unlicense.
- website - create codemirror-plugin to highlight jslint-warnings in editor.

# v2021.6.22
- bugfix - fix global_list being ignored by jslint.
- bugfix - fix no-warning when exception in catch-block is unused.
- ci - migrate ci-scripts from cjs to esm.
- cli - add env-variable \$JSLINT_BETA.
- jslint - add new directive `/*jslint beta*/` - enable features currently in beta.
- jslint - add new directive `/*jslint variable*/` - allow unordered variable-declarations that are not at top of function-scope.
- jslint - add new warning if const/let/var statements are not declared at top of function-scope.
- jslint - add new warning if const/let/var statements are unordered.
- website - invalidate url-cache with each deployment.
- website - replace .png logo with .svg logo.
- website - replace current-editor with CodeMirror-editor and change programming-font-family from `Programma` to `consolas, menlo, monospace`.

# v2021.6.12
- bugfix - fix await expression/statement inside catch-statement not registered by functionage.await.
- bugfix - fix cli appending slash "/" to normalized filename.
- bugfix - fix issue #316, #317 - jslint complains about dynamic-import.
- bugfix - fix misleading warning describing alphabetical-order instead of ascii-order.
- bugfix - fix off-by-one-column bug in missing-semicolon-warning.
- bugfix - fix try-catch-block complaining about "Unexpected await" inside async-function.
- directive - re-introduce `/*jslint name*/` to ignore "Bad property name" warning.
- doc - add install-screenshots.
- jslint - add new warning if case-statements are not sorted.
- jslint - add warning for unexpected ? in example `aa=/.{0}?/`.
- jslint - add warning for unexpected-expr in example `async function aa(){await 0;}`.
- jslint-refactor-1 - make "stateful" variables scoped outside of jslint() "stateless" by moving them into jslint().
- jslint-refactor-2 - inline constants anticondition, bitwiseop, escapeable, and opener directly into code.
- jslint-refactor-3 - inline regexp-functions quantifier(), ranges(), klass(), choice(), directly into code.
- jslint-refactor-4 - document jslint process and each recursion-loop converted to while-loop.
    - remove unnecessary variables nr.
    - rename artifact-related variables a, b to let artifact_now, artifact_nxt.
    - rename functions make() to token_create().
    - reorganize/rename "global" variables by topical-prefixes:
        artifact_xxx, export_xxx, from_xxx, import_xxx, line_xxx, mode_xxx, token_xxx
- jslint-refactor-5 - split jslint-core-logic into 5-phases.
    - move phase-sub-functions out of function-jslint().
    - move global-vars into state-object, that can be passed between functions.
    - migrate recursive-loops to while-loops in sub-function phase2_lex().
    - move remaining global-vars into sub-functions or hardcode.
    - update functions artifact(), stop(), warn() with fallback-code `the_token = the_token || state.token_nxt;`.
- website - add ui-loader-animation.

# v2021.6.3
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

# v2021.5.30
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

# v2021.5.27
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

# v2021.5.26
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

# v2021.5.23
- doc - add section Changelog.
- doc - update README.md with installation instructions.
- cli - merge shell-function shJslintCli into jslint.js.
- jslint - update default globals with support for "import".
- jslint - sort warnings with higher priority for early_stop.
- jslint - add async/await support.
- ci - make branch-beta the default branch.
- ci - validate non-http/file links in *.md files.
- ci - add shell-functions shCiBranchPromote.

# v2021.5.21
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

# v2020.11.6
- last jslint version before jslint-org migration.

# v2018.4.25
- last jslint version written in commonjs.

# v2017.11.6
- last jslint version written in es5.

# v2014.7.8
- last jslint version before 2 year hiatus.

# v2013.3.13
- last jslint version that can lint .html and .css files.
