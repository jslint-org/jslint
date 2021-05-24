# Changelog

## Todo
- app - deploy jslint as chrome-extension.
- doc - add svg package-listing.
- ci - continue addng regression tests and improve code-coverage.
- none

## Branch beta
- jslint - add new rules unordered_param_a, unordered_property_a, that warn if parameters and properties are listed in nonascii-order.
- jslint - add "globalThis" to default globals.
- none

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
- vestigial
