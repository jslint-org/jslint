# [<img align="left" height="80" src="asset_image_logo_512.svg"/>](https://github.com/jslint-org/jslint) JSLint, The JavaScript Code Quality and Coverage Tool
Douglas Crockford <douglas@crockford.com>


# Status
| Branch | [master<br>(v2023.1.29)](https://github.com/jslint-org/jslint/tree/master) | [beta<br>(Web Demo)](https://github.com/jslint-org/jslint/tree/beta) | [alpha<br>(Development)](https://github.com/jslint-org/jslint/tree/alpha) |
|--:|:--:|:--:|:--:|
| CI | [![ci](https://github.com/jslint-org/jslint/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/jslint-org/jslint/actions?query=branch%3Amaster) | [![ci](https://github.com/jslint-org/jslint/actions/workflows/ci.yml/badge.svg?branch=beta)](https://github.com/jslint-org/jslint/actions?query=branch%3Abeta) | [![ci](https://github.com/jslint-org/jslint/actions/workflows/ci.yml/badge.svg?branch=alpha)](https://github.com/jslint-org/jslint/actions?query=branch%3Aalpha) |
| Coverage | [![coverage](https://jslint-org.github.io/jslint/branch-master/.artifact/coverage/coverage_badge.svg)](https://jslint-org.github.io/jslint/branch-master/.artifact/coverage/index.html) | [![coverage](https://jslint-org.github.io/jslint/branch-beta/.artifact/coverage/coverage_badge.svg)](https://jslint-org.github.io/jslint/branch-beta/.artifact/coverage/index.html) | [![coverage](https://jslint-org.github.io/jslint/branch-alpha/.artifact/coverage/coverage_badge.svg)](https://jslint-org.github.io/jslint/branch-alpha/.artifact/coverage/index.html) |
| Demo | [<img src="asset_image_logo_512.svg" height="32">](https://jslint-org.github.io/jslint/branch-master/index.html) | [<img src="asset_image_logo_512.svg" height="32">](https://jslint-org.github.io/jslint/branch-beta/index.html) | [<img src="asset_image_logo_512.svg" height="32">](https://jslint-org.github.io/jslint/branch-alpha/index.html) |
| Artifacts | [<img src="asset_image_folder_open_solid.svg" height="30">](https://github.com/jslint-org/jslint/tree/gh-pages/branch-master/.artifact) | [<img src="asset_image_folder_open_solid.svg" height="30">](https://github.com/jslint-org/jslint/tree/gh-pages/branch-beta/.artifact) | [<img src="asset_image_folder_open_solid.svg" height="30">](https://github.com/jslint-org/jslint/tree/gh-pages/branch-alpha/.artifact) |


<br><br>
# Table of Contents

1. [Web Demo](#web-demo)

2. [Web Demo Archived](#web-demo-archived)

3. [Quickstart Install](#quickstart-install)
    - [To install, just download and save https://www.jslint.com/jslint.mjs to file:](#to-install-just-download-and-save-httpswwwjslintcomjslintmjs-to-file)
    - [To run `jslint.mjs` in shell:](#to-run-jslintmjs-in-shell)
    - [To import `jslint.mjs` in ES Module environment:](#to-import-jslintmjs-in-es-module-environment)
    - [To import `jslint.mjs` in CommonJS environment:](#to-import-jslintmjs-in-commonjs-environment)
    - [To JSLint entire directory in shell:](#to-jslint-entire-directory-in-shell)

4. [Quickstart JSLint Report](#quickstart-jslint-report)
    - [To create a JSLint report in shell:](#to-create-a-jslint-report-in-shell)
    - [To create a JSLint report in javascript:](#to-create-a-jslint-report-in-javascript)

5. [Quickstart V8 Coverage Report](#quickstart-v8-coverage-report)
    - [To create V8 coverage report from Node.js / Npm program in shell:](#to-create-v8-coverage-report-from-nodejs--npm-program-in-shell)
    - [To create V8 coverage report from Node.js / Npm program in javascript:](#to-create-v8-coverage-report-from-nodejs--npm-program-in-javascript)

6. [Quickstart JSLint in CodeMirror](#quickstart-jslint-in-codemirror)

7. [Quickstart JSLint in Vim](#quickstart-jslint-in-vim)

8. [Quickstart JSLint in VSCode](#quickstart-jslint-in-vscode)

9. [Documentation](#documentation)
    - [API Doc](#api-doc)
    - [Directive `/*jslint*/`](#directive-jslint)
        - [`/*jslint beta*/`](#jslint-beta)
        - [`/*jslint bitwise*/`](#jslint-bitwise)
        - [`/*jslint browser*/`](#jslint-browser)
        - [`/*jslint convert*/`](#jslint-convert)
        - [`/*jslint couch*/`](#jslint-couch)
        - [`/*jslint devel*/`](#jslint-devel)
        - [`/*jslint eval*/`](#jslint-eval)
        - [`/*jslint fart*/`](#jslint-fart)
        - [`/*jslint for*/`](#jslint-for)
        - [`/*jslint getset*/`](#jslint-getset)
        - [`/*jslint indent2*/`](#jslint-indent2)
        - [`/*jslint long*/`](#jslint-long)
        - [`/*jslint node*/`](#jslint-node)
        - [`/*jslint nomen*/`](#jslint-nomen)
        - [`/*jslint single*/`](#jslint-single)
        - [`/*jslint subscript*/`](#jslint-subscript)
        - [`/*jslint this*/`](#jslint-this)
        - [`/*jslint trace*/`](#jslint-trace)
        - [`/*jslint unordered*/`](#jslint-unordered)
        - [`/*jslint white*/`](#jslint-white)
    - [Directive `/*global*/`](#directive-global)
    - [Directive `/*property*/`](#directive-property)
    - [Directive `/*jslint-disable*/.../*jslint-enable*/`](#directive-jslint-disablejslint-enable)
    - [Directive `//jslint-ignore-line`](#directive-jslint-ignore-line)

10. [Package Listing](#package-listing)

11. [Changelog](#changelog)

12. [License](#license)


<br><br>
# Web Demo
- https://www.jslint.com

[![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_browser__2fjslint_2fbranch-beta_2findex.html.png)](https://jslint-org.github.io/jslint/index.html)


<br><br>
# Web Demo Archived
- [Web Demo 2020](https://www.jslint.com/branch-v2020.11.6/index.html)
- [Web Demo 2014 (ES5 only)](https://www.jslint.com/branch-v2014.7.8/jslint.html)
- [Web Demo 2013 (ES5, CSS, HTML)](https://www.jslint.com/branch-v2013.3.13/jslint.html)


<br><br>
# Quickstart Install


<br><br>
### To install, just download and save https://www.jslint.com/jslint.mjs to file:
```shell <!-- shRunWithScreenshotTxt .artifact/screenshot_sh_install_download.svg -->
#!/bin/sh

curl -L https://www.jslint.com/jslint.mjs > jslint.mjs
```
- shell output

![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_sh_install_download.svg)


<br><br>
### To run `jslint.mjs` in shell:
```shell <!-- shRunWithScreenshotTxt .artifact/screenshot_sh_jslint_file.svg -->
#!/bin/sh

printf "console.log('hello world');\n" > hello.js

node jslint.mjs hello.js
```
- shell output

![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_sh_jslint_file.svg)


<br><br>
### To import `jslint.mjs` in ES Module environment:
```shell <!-- shRunWithScreenshotTxt .artifact/screenshot_js_import_esm.svg -->
#!/bin/sh

node --input-type=module --eval '

/*jslint devel*/

// Import JSLint in ES Module environment.

import jslint from "./jslint.mjs";

let globals = ["caches", "indexedDb"];
let options = {browser: true};
let result;
let source = "console.log(\u0027hello world\u0027);\n";

// JSLint <source> and print <formatted_message>.

result = jslint.jslint(source, options, globals);
result.warnings.forEach(function ({
    formatted_message
}) {
    console.error(formatted_message);
});

'
```
- shell output

![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_js_import_esm.svg)


<br><br>
### To import `jslint.mjs` in CommonJS environment:
```shell <!-- shRunWithScreenshotTxt .artifact/screenshot_js_import_cjs.svg -->
#!/bin/sh

node --eval '

/*jslint devel*/
(async function () {
    let globals = ["caches", "indexedDb"];
    let jslint;
    let options = {browser: true};
    let result;
    let source = "console.log(\u0027hello world\u0027);\n";

// Import JSLint in CommonJS environment.

    jslint = await import("./jslint.mjs");
    jslint = jslint.default;

// JSLint <source> and print <formatted_message>.

    result = jslint.jslint(source, options, globals);
    result.warnings.forEach(function ({
        formatted_message
    }) {
        console.error(formatted_message);
    });
}());

'
```
- shell output

![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_js_import_cjs.svg)


<br><br>
### To JSLint entire directory in shell:
```shell <!-- shRunWithScreenshotTxt .artifact/screenshot_sh_jslint_dir.svg -->
#!/bin/sh

# JSLint directory '.'

node jslint.mjs .
```
- shell output

![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_sh_jslint_dir.svg)


<br><br>
# Quickstart JSLint Report


<br><br>
### To create a JSLint report in shell:
```shell <!-- shRunWithScreenshotTxt .artifact/screenshot_sh_jslint_report_file.svg -->
#!/bin/sh

printf "function foo() {console.log('hello world');}\n" > hello.js

# Create JSLint report from file 'hello.js' in shell.

node jslint.mjs \
    jslint_report=.artifact/jslint_report_hello.html \
    hello.js
```
- shell output

![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_sh_jslint_report_file.svg)

- screenshot file [.artifact/jslint_report_hello.html](https://jslint-org.github.io/jslint/branch-beta/.artifact/jslint_report_hello.html)

[![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_browser__2f.artifact_2fjslint_report_hello.html.png)](https://jslint-org.github.io/jslint/branch-beta/.artifact/jslint_report_hello.html)


<br><br>
### To create a JSLint report in javascript:
```shell <!-- shRunWithScreenshotTxt .artifact/screenshot_js_jslint_report_file.svg -->
#!/bin/sh

node --input-type=module --eval '

/*jslint devel*/
import jslint from "./jslint.mjs";
import fs from "fs";
(async function () {
    let result;
    let source = "function foo() {console.log(\u0027hello world\u0027);}\n";

// Create JSLint report from <source> in javascript.

    result = jslint.jslint(source);
    result = jslint.jslint_report(result);
    result = `<body class="JSLINT_ JSLINT_REPORT_">\n${result}</body>\n`;

    await fs.promises.mkdir(".artifact/", {recursive: true});
    await fs.promises.writeFile(".artifact/jslint_report_hello.html", result);
    console.error("wrote file .artifact/jslint_report_hello.html");
}());

'
```
- shell output

![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_js_jslint_report_file.svg)

- screenshot file [.artifact/jslint_report_hello.html](https://jslint-org.github.io/jslint/branch-beta/.artifact/jslint_report_hello.html)

[![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_browser__2f.artifact_2fjslint_report_hello.html.png)](https://jslint-org.github.io/jslint/branch-beta/.artifact/jslint_report_hello.html)


<br><br>
# Quickstart V8 Coverage Report


<br><br>
### To create V8 coverage report from Node.js / Npm program in shell:
```shell <!-- shRunWithScreenshotTxt .artifact/screenshot_sh_coverage_report_spawn.svg -->
#!/bin/sh

git clone https://github.com/tryghost/node-sqlite3 node-sqlite3-sh \
    --branch=v5.0.11 \
    --depth=1 \
    --single-branch

cd node-sqlite3-sh
npm install

# Create V8 coverage report from program `npm run test` in shell.

node ../jslint.mjs \
    v8_coverage_report=../.artifact/coverage_sqlite3_sh/ \
        --exclude=tes?/ \
        --exclude=tes[!0-9A-Z_a-z-]/ \
        --exclude=tes[0-9A-Z_a-z-]/ \
        --exclude=tes[^0-9A-Z_a-z-]/ \
        --exclude=test/**/*.js \
        --exclude=test/suppor*/*elper.js \
        --exclude=test/suppor?/?elper.js \
        --exclude=test/support/helper.js \
        --include=**/*.cjs \
        --include=**/*.js \
        --include=**/*.mjs \
        --include=li*/*.js \
        --include=li?/*.js \
        --include=lib/ \
        --include=lib/**/*.js \
        --include=lib/*.js \
        --include=lib/sqlite3.js \
    npm run test
```
- shell output

![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_sh_coverage_report_spawn.svg)

- screenshot file [.artifact/coverage_sqlite3_sh/index.html](https://jslint-org.github.io/jslint/branch-beta/.artifact/coverage_sqlite3_sh/index.html)

[![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_browser__2f.artifact_2fcoverage_sqlite3_sh_2findex.html.png)](https://jslint-org.github.io/jslint/branch-beta/.artifact/coverage_sqlite3_sh/index.html)

- screenshot file [.artifact/coverage_sqlite3_sh/lib/sqlite3.js.html](https://jslint-org.github.io/jslint/branch-beta/.artifact/coverage_sqlite3_sh/lib/sqlite3.js.html)

[![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_browser__2f.artifact_2fcoverage_sqlite3_sh_2flib_2fsqlite3.js.html.png)](https://jslint-org.github.io/jslint/branch-beta/.artifact/coverage_sqlite3_sh/lib/sqlite3.js.html)


<br><br>
### To create V8 coverage report from Node.js / Npm program in javascript:
```shell <!-- shRunWithScreenshotTxt .artifact/screenshot_js_coverage_report_spawn.svg -->
#!/bin/sh

git clone https://github.com/tryghost/node-sqlite3 node-sqlite3-js \
    --branch=v5.0.11 \
    --depth=1 \
    --single-branch

cd node-sqlite3-js
npm install

node --input-type=module --eval '

/*jslint node*/
import jslint from "../jslint.mjs";
(async function () {

// Create V8 coverage report from program `npm run test` in javascript.

    await jslint.v8CoverageReportCreate({
        coverageDir: "../.artifact/coverage_sqlite3_js/",
        processArgv: [
            "--exclude=tes?/",
            "--exclude=tes[!0-9A-Z_a-z-]/",
            "--exclude=tes[0-9A-Z_a-z-]/",
            "--exclude=tes[^0-9A-Z_a-z-]/",
            "--exclude=test/**/*.js",
            "--exclude=test/suppor*/*elper.js",
            "--exclude=test/suppor?/?elper.js",
            "--exclude=test/support/helper.js",
            "--include=**/*.cjs",
            "--include=**/*.js",
            "--include=**/*.mjs",
            "--include=li*/*.js",
            "--include=li?/*.js",
            "--include=lib/",
            "--include=lib/**/*.js",
            "--include=lib/*.js",
            "--include=lib/sqlite3.js",
            "npm", "run", "test"
        ]
    });
}());

'
```
- shell output

![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_js_coverage_report_spawn.svg)

- screenshot file [.artifact/coverage_sqlite3_js/index.html](https://jslint-org.github.io/jslint/branch-beta/.artifact/coverage_sqlite3_js/index.html)

[![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_browser__2f.artifact_2fcoverage_sqlite3_js_2findex.html.png)](https://jslint-org.github.io/jslint/branch-beta/.artifact/coverage_sqlite3_js/index.html)

- screenshot file [.artifact/coverage_sqlite3_js/lib/sqlite3.js.html](https://jslint-org.github.io/jslint/branch-beta/.artifact/coverage_sqlite3_js/lib/sqlite3.js.html)

[![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_browser__2f.artifact_2fcoverage_sqlite3_js_2flib_2fsqlite3.js.html.png)](https://jslint-org.github.io/jslint/branch-beta/.artifact/coverage_sqlite3_js/lib/sqlite3.js.html)


<br><br>
# Quickstart JSLint in CodeMirror
1. Download and save [`jslint.mjs`](https://www.jslint.com/jslint.mjs), [`jslint_wrapper_codemirror.js`](https://www.jslint.com/jslint_wrapper_codemirror.js) to file.

2. Edit, save, and serve example html-file below:
```html <!-- jslint_wrapper_codemirror.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>CodeMirror: JSLint Demo</title>

<!-- Assets from codemirror. -->

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.10/codemirror.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.10/addon/lint/lint.css">
    <script defer src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.10/codemirror.js"></script>
    <script defer src="https://codemirror.net/mode/javascript/javascript.js"></script>
    <script defer src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.65.10/addon/lint/lint.js"></script>

<!-- Assets from jslint. -->

    <script type="module" src="./jslint.mjs?window_jslint=1"></script>
    <script defer src="./jslint_wrapper_codemirror.js"></script>
<style>
body {
    background: #bbb;
    color: #333;
    font-family: sans-serif;
    margin: 20px;
}
.JSLINT_.JSLINT_REPORT_ {
    margin-top: 20px;
}
#editor1 {
    height: 300px;
    width: 100%;
}
</style>
</head>


<body>
    <h1>CodeMirror: JSLint Demo</h1>
    <h3>
This demo will auto-lint the code below, and auto-generate a report as you type.
    </h3>

<!-- Container for codemirror-editor. -->

    <textarea id="editor1">console.log('hello world');</textarea>

<!-- Container for jslint-report. -->

    <div class="JSLINT_ JSLINT_REPORT_"></div>


<script type=module>
window.addEventListener("load", function () {
    let editor = window.CodeMirror.fromTextArea(document.getElementById(
        "editor1"
    ), {
        gutters: [
            "CodeMirror-lint-markers"
        ],
        indentUnit: 4,
        lineNumbers: true,
        lint: {
            lintOnChange: true, // Enable auto-lint.
            options: {
                // browser: true,
                // node: true
                globals: [
                    // "caches",
                    // "indexedDb"
                ]
            }
        },
        mode: "javascript"
    });

// Initialize event-handling before linter is run.

    editor.on("lintJslintBefore", function (/* options */) {
        // options.browser = true;
        // options.node = true;
        // options.globals = [
        //     "caches",
        //     "indexedDb"
        // ];
        return;
    });

// Initialize event-handling after linter is run.

    editor.on("lintJslintAfter", function (options) {

// Generate jslint-report from options.result.

        document.querySelector(
            ".JSLINT_REPORT_"
        ).innerHTML = window.jslint.jslint_report(options.result);
    });

// Manually trigger linter.

    editor.performLint();
});
</script>
</body>
</html>
```
3. Live example at https://www.jslint.com/jslint_wrapper_codemirror.html

[![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_browser__2fjslint_2fbranch-beta_2fjslint_wrapper_codemirror.html.png)](https://jslint-org.github.io/jslint/jslint_wrapper_codemirror.html)


<br><br>
# Quickstart JSLint in Vim
1. Download and save [`jslint.mjs`](https://www.jslint.com/jslint.mjs), [`jslint_wrapper_vim.vim`](https://www.jslint.com/jslint_wrapper_vim.vim) to directory `~/.vim/`
2. Add vim-command `:source ~/.vim/jslint_wrapper_vim.vim` to file `~/.vimrc`
3. Vim can now jslint files (via nodejs):
    - with vim-command `:SaveAndJslint`
    - with vim-key-combo `<Ctrl-S> <Ctrl-J>`
- screenshot

[![screenshot](asset_image_jslint_wrapper_vim.png)](https://www.jslint.com/jslint_wrapper_vim.vim)


<br><br>
# Quickstart JSLint in VSCode
1. In VSCode, search and install extension [`vscode-jslint`](https://marketplace.visualstudio.com/items?itemName=jslint.vscode-jslint)
2. In VSCode, while editing a javascript file:
    - right-click context-menu and select `[JSLint - Lint File]`
    - or use key-binding `[Ctrl + Shift + J], [L]`
    - or use key-binding `[ Cmd + Shift + J], [L]` for Mac
- screenshot

[![screenshot](https://jslint-org.github.io/jslint/asset_image_jslint_wrapper_vscode.png)](https://marketplace.visualstudio.com/items?itemName=jslint.vscode-jslint)


<br><br>
# Documentation


- [jslint.mjs](jslint.mjs) contains the jslint function. It parses and analyzes a source file, returning an object with information about the file. It can also take an object that sets options.

- [index.html](index.html) runs the jslint.mjs function in a web page.

JSLint can be run anywhere that JavaScript (or Java) can run.

The place to express yourself in programming is in the quality of your ideas and
the efficiency of their execution. The role of style in programming is the same
as in literature: It makes for better reading. A great writer doesn't express
herself by putting the spaces before her commas instead of after, or by putting
extra spaces inside her parentheses. A great writer will slavishly conform to
some rules of style, and that in no way constrains her power to express herself
creatively. See for example William Strunk's The Elements of Style
[https://www.crockford.com/style.html].

This applies to programming as well. Conforming to a consistent style improves
readability, and frees you to express yourself in ways that matter. JSLint here
plays the part of a stern but benevolent editor, helping you to get the style
right so that you can focus your creative energy where it is most needed.


<br><br>
### API Doc
- https://www.jslint.com/apidoc.html

[![screenshot](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_browser__2f.artifact_2fapidoc.html.png)](https://www.jslint.com/apidoc.html)


<br><br>
### Directive `/*jslint*/`

<br>

##### `/*jslint beta*/`

```js
/*jslint beta*/
// Enable experimental warnings.
// Warn if global variables are redefined.
// Warn if const / let statements are not declared at top of function or
//    script, similar to var statements.
// Warn if const / let / var statements are not declared in ascii-order.
// Warn if named-functions are not declared in ascii-order.
// Warn if cases in switch-statements are not in ascii-order.
```

<br>

##### `/*jslint bitwise*/`

```js
/*jslint bitwise*/
// Allow bitwise operator.

let foo = 0 | 1;
```

<br>

##### `/*jslint browser*/`

```js
/*jslint browser*/
// Assume browser environment.

localStorage.getItem("foo");
```

<br>

##### `/*jslint convert*/`

```js
/*jslint convert*/
// Allow conversion operator.

let foo = new Date() + "";
let bar = !!0;
```

<br>

##### `/*jslint couch*/`

```js
/*jslint couch*/
// Assume CouchDb environment.

registerType("text-json", "text/json");
```

<br>

##### `/*jslint devel*/`

```js
/*jslint devel*/
// Allow console.log() and friends.

console.log("hello");
```

<br>

##### `/*jslint eval*/`

```js
/*jslint eval*/
// Allow eval().

eval("1");
```

<br>

##### `/*jslint fart*/`

```js
/*jslint fart*/
// Allow complex fat-arrow.

let foo = async ({bar, baz}) => {
    return await bar(baz);
};
```

<br>

##### `/*jslint for*/`

```js
/*jslint for*/
// Allow for-loop.

function foo() {
    let ii;
    for (ii = 0; ii < 10; ii += 1) {
        foo();
    }
}
```

<br>

##### `/*jslint getset*/`

```js
/*jslint getset, this, devel*/
// Allow get() and set().

let foo = {
    bar: 0,
    get getBar() {
        return this.bar;
    },
    set setBar(value) {
        this.bar = value;
    }
};
console.log(foo.getBar); // 0
foo.setBar = 1;
console.log(foo.getBar); // 1
```

<br>

##### `/*jslint indent2*/`

```js
/*jslint indent2*/
// Use 2-space indent.

function foo() {
  return;
}
```

<br>

##### `/*jslint long*/`

```js
/*jslint long*/
// Allow long lines.

let foo = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
```

<br>

##### `/*jslint node*/`

```js
/*jslint node*/
// Assume Node.js environment.

require("fs");
```

<br>

##### `/*jslint nomen*/`

```js
/*jslint nomen*/
// Allow weird property name.

let foo = {};
foo._bar = 1;
```

<br>

##### `/*jslint single*/`

```js
/*jslint single*/
// Allow single-quote strings.

let foo = '';
```

<br>

##### `/*jslint subscript*/`

```js
/*jslint subscript*/
// Allow identifiers in subscript-notation.

let foo = {};
foo["bar"] = 1;
```

<br>

##### `/*jslint this*/`

```js
/*jslint this*/
// Allow 'this'.

function foo() {
    return this;
}
```

<br>

##### `/*jslint trace*/`

```js
/*jslint trace*/
// Include jslint stack-trace in warnings.

console.log('hello world');
/*
1. Undeclared 'console'.
console.log('hello world');
Error
    at warn_at (...)
    at warn (...)
    at lookup (...)
    at pre_v (...)
    at jslint.mjs
2. Use double quotes, not single quotes.
console.log(...);
Error
    at warn_at (...)
    at lex_string (...)
    at lex_token (...)
    at jslint_phase2_lex (...)
    at Function.jslint (...)
    at jslint.mjs
*/
```

<br>

##### `/*jslint unordered*/`

```js
/*jslint unordered*/
// Allow unordered cases, params, properties, and variables.

let foo = {bb: 1, aa: 0};

function bar({
    bb = 1,
    aa = 0
}) {
    return aa + bb;
}
```

<br>

##### `/*jslint white*/`

```js
/*jslint white*/
// Allow messy whitespace.

let foo = 1; let bar = 2;
```


<br><br>
### Directive `/*global*/`

```js
/*global foo, bar*/
// Declare global variables foo, bar.

foo();
bar();
```


<br><br>
### Directive `/*property*/`

```js
/*property foo, bar*/
// Restrict property-access to only .foo, .bar.

let aa = {bar: 1, foo: 2};
```


<br><br>
### Directive `/*jslint-disable*/.../*jslint-enable*/`

```js
/*jslint-disable*/

JSLint will ignore and treat this region as blank-lines.
Syntax error.

/*jslint-enable*/
```


<br><br>
### Directive `//jslint-ignore-line`

```js
// JSLint will ignore non-fatal warnings at given line.

eval("1"); //jslint-ignore-line
```


<br><br>
# Package Listing
![screenshot_package_listing.svg](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_package_listing.svg)


<br><br>
# Changelog
- [Full CHANGELOG.md](CHANGELOG.md)

![screenshot_changelog.svg](https://jslint-org.github.io/jslint/branch-beta/.artifact/screenshot_changelog.svg)


<br><br>
# License
- JSLint is under [Unlicense License](LICENSE).
- CodeMirror editor is under [MIT License](https://github.com/codemirror/codemirror5/blob/d0e3b2e727c41aa4fd89fbad0adfb3815339174c/LICENSE).
- Function `v8CoverageListMerge` is derived from [MIT Licensed v8-coverage](https://github.com/demurgos/v8-coverage/blob/73446087dc38f61b09832c9867122a23f8577099/ts/LICENSE.md).

<!--
Coverage-hack
node --eval '
0
'
-->
