# JSLint, The JavaScript Code Quality Tool

Douglas Crockford
douglas@crockford.com

## v2021.5.21

## Status
| Branch | [master](https://github.com/jslint-org/jslint/tree/master) | [beta](https://github.com/jslint-org/jslint/tree/beta) | [alpha](https://github.com/jslint-org/jslint/tree/alpha)|
|--:|:--:|:--:|:--:|
| CI | [![ci](https://github.com/jslint-org/jslint/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/jslint-org/jslint/actions?query=branch%3Amaster) | [![ci](https://github.com/jslint-org/jslint/actions/workflows/ci.yml/badge.svg?branch=beta)](https://github.com/jslint-org/jslint/actions?query=branch%3Abeta) | [![ci](https://github.com/jslint-org/jslint/actions/workflows/ci.yml/badge.svg?branch=alpha)](https://github.com/jslint-org/jslint/actions?query=branch%3Aalpha)|
| Coverage | [![coverage](https://jslint-org.github.io/jslint/branch.master/.build/coverage/coverage-badge.svg)](https://jslint-org.github.io/jslint/branch.master/.build/coverage/index.html) | [![coverage](https://jslint-org.github.io/jslint/branch.beta/.build/coverage/coverage-badge.svg)](https://jslint-org.github.io/jslint/branch.beta/.build/coverage/index.html) | [![coverage](https://jslint-org.github.io/jslint/branch.alpha/.build/coverage/coverage-badge.svg)](https://jslint-org.github.io/jslint/branch.alpha/.build/coverage/index.html)|
| Demo | [<img src="image-window-maximize-regular.svg" height="30">](https://jslint-org.github.io/jslint/branch.master/index.html) | [<img src="image-window-maximize-regular.svg" height="30">](https://jslint-org.github.io/jslint/branch.beta/index.html) | [<img src="image-window-maximize-regular.svg" height="30">](https://jslint-org.github.io/jslint/branch.alpha/index.html)|
| Artifacts | [<img src="image-folder-open-solid.svg" height="30">](https://github.com/jslint-org/jslint/tree/gh-pages/branch.master/.build) | [<img src="image-folder-open-solid.svg" height="30">](https://github.com/jslint-org/jslint/tree/gh-pages/branch.beta/.build) | [<img src="image-folder-open-solid.svg" height="30">](https://github.com/jslint-org/jslint/tree/gh-pages/branch.alpha/.build)|

## Live Web Demo
- [https://jslint-org.github.io/jslint/index.html](https://jslint-org.github.io/jslint/index.html)

[![screenshot](https://jslint-org.github.io/jslint/branch.master/.build/screenshot.browser._2findex.html.png)](https://jslint-org.github.io/jslint/index.html)

## Description
`jslint.js` contains the jslint function. It parses and analyzes a source file,
returning an object with information about the file. It can also take an object
that sets options.

`index.html` runs the jslint.js function in a web page. The page also depends
`browser.js` and `report.js` and `jslint.css`.

`jslint.css` provides styling for `index.html`.

`browser.js` runs the web user interface.

`report.js` generates the results reports in HTML.

`help.html` describes JSLint's usage. Please read it.

`function.html` describes the jslint function and the results it produces.

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
