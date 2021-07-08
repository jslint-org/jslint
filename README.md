[<img align="left" height="100" src="asset-image-jslint-512.svg"/>](https://github.com/jslint-org/jslint)


# JSLint, The JavaScript Code Quality Tool

&nbsp;

Douglas Crockford <douglas@crockford.com>


# Status
| Branch | [master<br>(v2021.6.30)](https://github.com/jslint-org/jslint/tree/master) | [beta<br>(Web Demo)](https://github.com/jslint-org/jslint/tree/beta) | [alpha<br>(Development)](https://github.com/jslint-org/jslint/tree/alpha) |
|--:|:--:|:--:|:--:|
| CI | [![ci](https://github.com/jslint-org/jslint/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/jslint-org/jslint/actions?query=branch%3Amaster) | [![ci](https://github.com/jslint-org/jslint/actions/workflows/ci.yml/badge.svg?branch=beta)](https://github.com/jslint-org/jslint/actions?query=branch%3Abeta) | [![ci](https://github.com/jslint-org/jslint/actions/workflows/ci.yml/badge.svg?branch=alpha)](https://github.com/jslint-org/jslint/actions?query=branch%3Aalpha) |
| Coverage | [![coverage](https://jslint-org.github.io/jslint/branch-master/.build/coverage/coverage-badge.svg)](https://jslint-org.github.io/jslint/branch-master/.build/coverage/index.html) | [![coverage](https://jslint-org.github.io/jslint/branch-beta/.build/coverage/coverage-badge.svg)](https://jslint-org.github.io/jslint/branch-beta/.build/coverage/index.html) | [![coverage](https://jslint-org.github.io/jslint/branch-alpha/.build/coverage/coverage-badge.svg)](https://jslint-org.github.io/jslint/branch-alpha/.build/coverage/index.html) |
| Demo | [<img src="asset-image-jslint-512.svg" height="32">](https://jslint-org.github.io/jslint/branch-master/index.html) | [<img src="asset-image-jslint-512.svg" height="32">](https://jslint-org.github.io/jslint/branch-beta/index.html) | [<img src="asset-image-jslint-512.svg" height="32">](https://jslint-org.github.io/jslint/branch-alpha/index.html) |
| Artifacts | [<img src="asset-image-folder-open-solid.svg" height="30">](https://github.com/jslint-org/jslint/tree/gh-pages/branch-master/.build) | [<img src="asset-image-folder-open-solid.svg" height="30">](https://github.com/jslint-org/jslint/tree/gh-pages/branch-beta/.build) | [<img src="asset-image-folder-open-solid.svg" height="30">](https://github.com/jslint-org/jslint/tree/gh-pages/branch-alpha/.build) |


# Web Demo
- https://www.jslint.com

[![screenshot](https://jslint-org.github.io/jslint/branch-beta/.build/screenshot-browser-_2fjslint_2fbranch-beta_2findex.html.png)](https://jslint-org.github.io/jslint/index.html)


# Install
### 1. To install, just download https://www.jslint.com/jslint.mjs:
```shell
#!/bin/sh

curl -L https://www.jslint.com/jslint.mjs > jslint.mjs
```

### 2. To run `jslint.mjs` from command-line:
```shell <!-- shRunWithScreenshotTxt .build/screenshot-install-cli-file.svg -->
#!/bin/sh

printf "console.log('hello world');\n" > hello.js

node jslint.mjs hello.js
```
- shell output

![screenshot.svg](https://jslint-org.github.io/jslint/branch-beta/.build/screenshot-install-cli-file.svg)

### 3. To import `jslint.mjs` as es-module:
```shell <!-- shRunWithScreenshotTxt .build/screenshot-install-import.svg -->
#!/bin/sh

node --input-type=module -e '

/*jslint devel*/
import jslint from "./jslint.mjs";
let globals = ["caches", "indexedDb"];
let options = {browser: true};
let result;
let source = "console.log(\u0027hello world\u0027);\n";
result = jslint(source, options, globals);
result.warnings.forEach(function ({
    formatted_message
}) {
    console.error(formatted_message);
});

'
```
- shell output

![screenshot.svg](https://jslint-org.github.io/jslint/branch-beta/.build/screenshot-install-import.svg)

### 4. To jslint entire directory:
```shell <!-- shRunWithScreenshotTxt .build/screenshot-install-cli-dir.svg -->
#!/bin/sh

node jslint.mjs .
```
- shell output

![screenshot.svg](https://jslint-org.github.io/jslint/branch-beta/.build/screenshot-install-cli-dir.svg)

<!-- coverage-hack
```javascript
"use strict";
```
-->


# Description
- [jslint.mjs](jslint.mjs) contains the jslint function. It parses and analyzes a source file, returning an object with information about the file. It can also take an object that sets options.

- [index.html](index.html) runs the jslint.mjs function in a web page. The page also depends on `browser.mjs`.

- [browser.mjs](browser.mjs) runs the web user interface and generates the results reports in HTML.

- [help.html](help.html) describes JSLint's usage. Please [read it](https://jslint-org.github.io/jslint/help.html).

- [function.html](function.html) describes the jslint function and the results it produces.

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


# Files
![screenshot-files.svg](https://jslint-org.github.io/jslint/branch-beta/.build/screenshot-files.svg)


# Changelog
- [Full CHANGELOG.md](CHANGELOG.md)

![screenshot-changelog.svg](https://jslint-org.github.io/jslint/branch-beta/.build/screenshot-changelog.svg)
