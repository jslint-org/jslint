shCiArtifactUploadCustom() {(set -e
# this function will run custom-code to upload build-artifacts
    # .github_cache - restore
    if [ "$GITHUB_ACTION" ] && [ -d .github_cache ]
    then
        cp -a .github_cache/* . || true # js-hack - */
    fi
    # add jslint.js
    cp jslint.mjs jslint.js
    git add -f jslint.js
    # seo - inline css-assets and invalidate cached-assets
    node --input-type=module --eval '
import moduleFs from "fs";
(async function () {
    let cacheKey = Math.random().toString(36).slice(-4);
    let fileDict = {};
    await Promise.all([
        "index.html"
    ].map(async function (file) {
        try {
            fileDict[file] = await moduleFs.promises.readFile(file, "utf8");
        } catch (ignore) {
            process.exit();
        }
    }));
    // invalidate cached-assets
    fileDict["index.html"] = fileDict["index.html"].replace((
        /\b(?:href|src)=".+?\.(?:css|js|mjs)\b/g
    ), function (match0) {
        return `${match0}?cc=${cacheKey}`;
    });
    // write file
    Object.entries(fileDict).map(function ([
        file, data
    ]) {
        moduleFs.promises.writeFile(file, data);
    });
}());
' "$@" # '
    # screenshot quickstart
    node --input-type=module --eval '
import moduleFs from "fs";
import moduleChildProcess from "child_process";
(async function () {
    let fileDict = {};
    let screenshotCurl;
    await Promise.all([
        "README.md"
    ].map(async function (file) {
        fileDict[file] = await moduleFs.promises.readFile(file, "utf8");
    }));
    screenshotCurl = await moduleFs.promises.stat("jslint.mjs");
    screenshotCurl = String(`
echo "\
% Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                     Dload  Upload   Total   Spent    Left  Speed
100  250k  100  250k    0     0   250k      0  0:00:01 --:--:--  0:00:01  250k\
"
    `).trim().replace((
        /250/g
    ), Math.floor(screenshotCurl.size / 1024));
    // parallel-task - run-and-screenshot example-shell-commands in README.md
    await Promise.all(Array.from(
        fileDict["README.md"].matchAll(
            /\n```shell <!-- shRunWithScreenshotTxt (.*?) -->\n([\S\s]*?\n)```\n/g
        )
    ).map(async function ([
        ignore, file, script0
    ]) {
        let script = script0;
        // modify script - jslint install
        script = script.replace(
            "curl -L https://www.jslint.com/jslint.mjs > jslint.mjs",
            screenshotCurl
        );
        // modify script - cd node-sqlite3
        script = script.replace((
            /\n\ncd node-sqlite3-\w*?\n/g
        ), (
            " 2>/dev/null || true\n"
            + "$&\n"
            + "git checkout 61194ec2aee4b56e8e17f757021434122772f145\n"
        ));
        // printf script
        script = (
            "(set -e\n"
            + "printf \u0027"
            + script0.trim().replace((
                /[%\\]/gm
            ), "$&$&").replace((
                /\u0027/g
            ), "\u0027\"\u0027\"\u0027").replace((
                /^/gm
            ), "> ")
            + "\n\n\n\u0027\n"
            + script
            + ")\n"
        );
        await moduleFs.promises.writeFile(file + ".sh", script);
        await new Promise(function (resolve) {
            moduleChildProcess.spawn(
                "sh",
                [
                    "jslint_ci.sh", "shRunWithScreenshotTxt", file,
                    "sh", file + ".sh"
                ],
                {
                    env: Object.assign({
                        // limit stdout to xxx lines
                        SH_RUN_WITH_SCREENSHOT_TXT_MAX_LINES: 64
                    }, process.env),
                    stdio: [
                        "ignore", 1, 2
                    ]
                }
            ).on("exit", resolve);
        });
    }));
}());
' "$@" # '
    # background http-file-server to serve webpages for screenshot
    # PORT=8080 npm_config_timeout_exit=5000 shHttpFileServer &
    # screenshot html
    node --input-type=module --eval '
import moduleChildProcess from "child_process";
(async function () {
    let {
        GITHUB_BRANCH0,
        GITHUB_GITHUB_IO
    } = process.env;
    await Promise.all([
        (
            `https://${GITHUB_GITHUB_IO}/branch-${GITHUB_BRANCH0}`
            + `/jslint_wrapper_codemirror.html`
        ),
        (
            `https://${GITHUB_GITHUB_IO}/branch-${GITHUB_BRANCH0}`
            + `/index.html`
        ),
        ".artifact/apidoc.html",
        ".artifact/coverage_sqlite3_js/index.html",
        ".artifact/coverage_sqlite3_js/lib/sqlite3.js.html",
        ".artifact/coverage_sqlite3_sh/index.html",
        ".artifact/coverage_sqlite3_sh/lib/sqlite3.js.html",
        ".artifact/jslint_report_hello.html"
    ].map(async function (url) {
        await new Promise(function (resolve) {
            moduleChildProcess.spawn(
                "sh",
                [
                    "jslint_ci.sh", "shBrowserScreenshot", url
                ],
                {
                    stdio: [
                        "ignore", 1, 2
                    ]
                }
            ).on("exit", resolve);
        });
    }));
}());
' "$@" # '
    # remove bloated json-coverage-files
    rm .artifact/coverage/*.json # js-hack - */
    rm .artifact/coverage_sqlite3_*/*.json # js-hack - */
    # jslint_wrapper_vscode - build
    shCiVscePackageJslintWrapperVscode
    # .github_cache - save
    if [ "$GITHUB_ACTION" ] && [ ! -d .github_cache ]
    then
        mkdir -p .github_cache
        cp -a node-sqlite3-* .github_cache
    fi
)}

shCiBaseCustom() {(set -e
# this function will run custom-code for base-ci
    # update files
    if [ "$(git branch --show-current)" = alpha ]
    then
        node --input-type=module --eval '
import jslint from "./jslint.mjs";
import moduleFs from "fs";
(async function () {
    let fileDict = {};
    let fileModified;
    let versionBeta;
    let versionMaster;
    await Promise.all([
        ".ci.sh",
        "CHANGELOG.md",
        "README.md",
        "index.html",
        "jslint.mjs",
        "jslint_ci.sh",
        "jslint_wrapper_codemirror.html"
    ].map(async function (file) {
        fileDict[file] = await moduleFs.promises.readFile(file, "utf8");
    }));
    Array.from(fileDict["CHANGELOG.md"].matchAll(
        /\n\n# v(\d\d\d\d\.\d\d?\.\d\d?(-.*?)?)\n/g
    )).slice(0, 2).forEach(function ([
        ignore, version, isBeta
    ]) {
        versionBeta = versionBeta || version;
        versionMaster = versionMaster || (!isBeta && version);
    });
    await Promise.all([
        {
            file: ".ci.sh",
            // update version
            src: fileDict[".ci.sh"].replace((
                /    "version": "\d\d\d\d\.\d\d?\.\d\d?(?:-.*?)?"/
            ), `    "version": "${versionBeta.split("-")[0]}"`)
        }, {
            file: "README.md",
            src: fileDict["README.md"].replace((
                /\n```html <!-- jslint_wrapper_codemirror.html -->\n[\S\s]*?\n```\n/
            ), (
                "\n```html <!-- jslint_wrapper_codemirror.html -->\n"
                + fileDict["jslint_wrapper_codemirror.html"]
                + "```\n"
            ))
        }, {
            file: "index.html",
            src: fileDict["index.html"].replace((
                /\n<style class="JSLINT_REPORT_STYLE">\n[\S\s]*?\n<\/style>\n/
            ), function () {
                return fileDict["jslint.mjs"].match(
                    /\n<style class="JSLINT_REPORT_STYLE">\n[\S\s]*?\n<\/style>\n/
                )[0];
            })
        }, {
            file: "jslint.mjs",
            // update version
            src: fileDict["jslint.mjs"].replace((
                /^let jslint_edition = ".*?";$/m
            ), `let jslint_edition = "v${versionBeta}";`)
        }, {
            file: "jslint_ci.sh",
            // update coverage-code
            src: fileDict["jslint_ci.sh"].replace((
                /(\nshRunWithCoverage[\S\s]*?\nlet moduleUrl;\n)[\S\s]*?\nv8CoverageReportCreate\(/m
            ), function (ignore, match1) {
                return (
                    match1
                    + [
                        jslint.assertOrThrow,
                        jslint.fsWriteFileWithParents,
                        jslint.globExclude,
                        jslint.htmlEscape,
                        jslint.moduleFsInit,
                        jslint.v8CoverageListMerge,
                        jslint.v8CoverageReportCreate
                    // reduce size of string/argument passed to nodejs
                    // by removing comments
                    ].join("\n").replace((
                        /\n\/\/.*/g
                    ), "").replace((
                        /\n\n\n/g
                    // CL-61b11012 reduce size of string/argument passed
                    // to nodejs by using 2-space-indent
                    ), "\n").replace((
                        /    /g
                    ), "  ")
                    + "\nv8CoverageReportCreate("
                );
            })
        }
    ].map(async function ({
        file,
        src
    }) {
        let src0 = fileDict[file];
        if (src !== src0) {
            console.error(`update file ${file}`);
            fileModified = file;
            await moduleFs.promises.writeFile(file, src);
        }
    }));
    if (fileModified) {
        throw new Error("modified file " + fileModified);
    }
}());
' "$@" # '
    fi
    # run test with coverage-report
    npm run test
)}

shCiNpmPublishCustom() {(set -e
# this function will run custom-code to npm-publish package
    npm publish --access public
)}

shCiVscePackageJslintWrapperVscode() {(set -e
# this function will vsce-package jslint_wrapper_vscode
    mkdir -p .artifact/jslint_wrapper_vscode/.vscode
    (set -e
    cd .artifact/jslint_wrapper_vscode
    ln -f ../../.npmignore .vscodeignore
    ln -f ../../LICENSE
    ln -f ../../asset_image_logo_512.png
    ln -f ../../jslint.mjs
    ln -f ../../jslint_wrapper_vscode.js
    node --input-type=module --eval '
import moduleFs from "fs";
(async function () {
    let fileDict = {};
    await Promise.all([
        "README.md"
    ].map(async function (file) {
        fileDict[file] = await moduleFs.promises.readFile(
            `../../${file}`,
            "utf8"
        );
    }));
    await Promise.all([
        {
            file: ".vscode/launch.json",
            src: JSON.stringify({
                "configurations": [
                    {
                        "args": [
                            "--extensionDevelopmentPath=${workspaceFolder}"
                        ],
                        "name": "Run Extension",
                        "request": "launch",
                        "type": "extensionHost"
                    }
                ],
                "version": "0.2.0"
            }, undefined, 4)
        }, {
            file: "README.md",
            src: (
                /\n# quickstart jslint in vscode\n[\S\s]*?\n\n\n/i
            ).exec(fileDict["README.md"])[0]
        }, {
            file: "package.json",
            src: JSON.stringify({
                "activationEvents": [
                    "onCommand:jslint.clear",
                    "onCommand:jslint.disableRegion",
                    "onCommand:jslint.ignoreLine",
                    "onCommand:jslint.lint"
                ],
                "bugs": {
                    "url": "https://github.com/jslint-org/jslint/issues"
                },
                "categories": [
                    "Linters"
                ],
                "contributes": {
                    "commands": [
                        {
                            "category": "jslint",
                            "command": "jslint.clear",
                            "title": "JSLint - Clear Warnings"
                        },
                        {
                            "category": "jslint",
                            "command": "jslint.disableRegion",
                            "title": "JSLint - Do Not Lint Selected Region"
                        },
                        {
                            "category": "jslint",
                            "command": "jslint.ignoreLine",
                            "title": "JSLint - Ignore Current Line"
                        },
                        {
                            "category": "jslint",
                            "command": "jslint.lint",
                            "title": "JSLint - Lint File"
                        }
                    ],
                    "keybindings": [
                        {
                            "command": "jslint.clear",
                            "key": "ctrl+shift+j c",
                            "mac": "cmd+shift+j c",
                            "when": "editorTextFocus"
                        },
                        {
                            "command": "jslint.lint",
                            "key": "ctrl+shift+j l",
                            "mac": "cmd+shift+j l",
                            "when": "editorTextFocus"
                        }
                    ],
                    "menus": {
                        "editor/context": [
                            {
                                "command": "jslint.lint",
                                "group": "7_modification@1",
                                "when": "resourceLangId == javascript"
                            },
                            {
                                "command": "jslint.clear",
                                "group": "7_modification@2",
                                "when": "resourceLangId == javascript"
                            },
                            {
                                "command": "jslint.disableRegion",
                                "group": "7_modification@3",
                                "when": "resourceLangId == javascript"
                            },
                            {
                                "command": "jslint.ignoreLine",
                                "group": "7_modification@4",
                                "when": "resourceLangId == javascript"
                            }
                        ]
                    }
                },
                "description": "Integrates JSLint into VS Code.",
                "displayName": "vscode-jslint",
                "engines": {
                    "vscode": "^1.66.0"
                },
                "icon": "asset_image_logo_512.png",
                "keywords": [
                    "javascript",
                    "jslint",
                    "linter"
                ],
                "license": "UNLICENSE",
                "main": "./jslint_wrapper_vscode.js",
                "name": "vscode-jslint",
                "publisher": "jslint",
                "repository": {
                    "type": "git",
                    "url": "https://github.com/jslint-org/jslint.git"
                },
                "version": "2023.1.29"
            }, undefined, 4)
        }
    ].map(async function ({
        file,
        src
    }) {
        await moduleFs.promises.writeFile(file, src.trim() + "\n");
    }));
}());
' "$@" # '
    npx vsce package
    rm -rf node_modules
    )
)}
