#!/bin/sh
: '
/* jslint utility2:true */
'

shBrowserScreenshot() {(set -e
# this function will run headless-chrome to screenshot url $1 with
# window-size $2
    node -e '
// init debugInline
if (!globalThis.debugInline) {
    let consoleError;
    consoleError = console.error;
    globalThis.debugInline = function (...argList) {
    /*
     * this function will both print <argList> to stderr and
     * return <argList>[0]
     */
        consoleError("\n\ndebugInline");
        consoleError(...argList);
        consoleError("\n");
        return argList[0];
    };
}
(function () {
    "use strict";
    let file;
    let timeStart;
    let url;
    if (process.platform !== "linux") {
        return;
    }
    timeStart = Date.now();
    url = process.argv[1];
    if (!(
        /^\w+?:/
    ).test(url)) {
        url = require("path").resolve(url);
    }
    file = require("url").parse(url).pathname;
    // remove prefix $PWD from file
    if (String(file + "/").indexOf(process.cwd() + "/") === 0) {
        file = file.replace(process.cwd(), "");
    }
    file = ".build/screenshot.browser." + encodeURIComponent(file).replace((
        /%/g
    ), "_").toLowerCase();
    process.on("exit", function (exitCode) {
        if (typeof exitCode === "object" && exitCode) {
            console.error(exitCode);
            exitCode = 1;
        }
        console.error(
            "shBrowserScreenshot" +
            "\n  - url - " + url +
            "\n  - wrote - " + file + ".html" +
            "\n  - wrote - " + file + ".png" +
            "\n  - timeElapsed - " + (Date.now() - timeStart) + " ms" +
            "\n  - EXIT_CODE=" + exitCode
        );
    });
    [
        ".html", ".png"
    ].forEach(function (extname) {
        let argList;
        let child;
        argList = Array.from([
            "--headless",
            "--ignore-certificate-errors",
            "--incognito",
            "--timeout=30000",
            "--user-data-dir=/dev/null",
            "--window-size=" + (process.argv[2] || "800x600"),
            (
                extname === ".html"
                ? "--dump-dom"
                : ""
            ),
            (
                extname === ".png"
                ? "--screenshot"
                : ""
            ),
            (
                extname === ".png"
                ? "-screenshot=" + file + ".png"
                : ""
            ),
            (
                (process.getuid && process.getuid() === 0)
                ? "--no-sandbox"
                : ""
            ),
            url
        ]).filter(function (elem) {
            return elem;
        });
        // debug argList
        // console.error(argList);
        child = require("child_process").spawn((
            process.platform === "darwin"
            ? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
            : process.platform === "win32"
            ? "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe"
            : "/usr/bin/google-chrome-stable"
        ), argList, {
            stdio: [
                "ignore", "pipe", 2
            ]
        });
        child.stdout.pipe(
            extname === ".html"
            ? require("fs").createWriteStream(file + ".html")
            : process.stdout
        );
    });
}());
' "$@" # "'
)}

shCiArtifactUpload() {(set -e
# this function will upload build-artifacts to branch-gh-pages
    node -e '
process.exit(
    `${process.version.split(".")[0]}.${process.arch}.${process.platform}` !==
    process.env.CI_NODE_VERSION_ARCH_PLATFORM
);
' || return 0
    local BRANCH
    # init $BRANCH
    BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    # init .git/config
    git config --local user.email "github-actions@users.noreply.github.com"
    git config --local user.name "github-actions"
    # update README.md with $GITHUB_REPOSITORY
    sed -i \
        -e "s|\bjslint-org/jslint\b|$GITHUB_REPOSITORY|g" \
        -e "s|\bjslint-org\.github\.io/jslint\b|$(
            printf "$GITHUB_REPOSITORY" | sed -e "s|/|.github.io/|"
        )|g" \
        README.md
    # add dir .build
    git add -f .build
    git commit -am "add dir .build"
    # checkout branch-gh-pages
    git checkout -b gh-pages
    git fetch origin gh-pages
    git reset --hard origin/gh-pages
    # update dir branch.$BRANCH
    rm -rf "branch.$BRANCH"
    mkdir "branch.$BRANCH"
    (set -e
        cd "branch.$BRANCH"
        git init -b branch1
        git pull --depth=1 .. "$BRANCH"
        rm -rf .git
        git add -f .
    )
    # update root-dir with branch-master
    if [ "$BRANCH" = master ]
    then
        git rm -rf .build
        git checkout master .
    fi
    git status
    git commit -am "update dir branch.$BRANCH" || true
    # if branch-gh-pages has more than 100 commits,
    # then backup and squash commits
    if [ "$(git rev-list --count gh-pages)" -gt 100 ]
    then
        # backup
        shGitCmdWithGithubToken push origin -f gh-pages:gh-pages.backup
        # squash commits
        git checkout --orphan squash1
        git commit --quiet -am squash || true
        # reset branch-gh-pages to squashed-commit
        git push . -f squash1:gh-pages
        git checkout gh-pages
        # force-push squashed-commit
        shGitCmdWithGithubToken push origin -f gh-pages
    fi
    # list files
    shGitLsTree
    # push branch-gh-pages
    shGitCmdWithGithubToken push origin gh-pages
    # validate http-links
    (set -e
        cd "branch.$BRANCH"
        sleep 15
        shDirHttplinkValidate
    )
)}

shCiBase() {(set -e
# this function will run github-ci
    # jslint all files
    shJslintCli .
    # run test with coverage-report
    shRunWithCoverage node test.js
    # screenshot live-web-demo
    shBrowserScreenshot index.html
)}

shDirHttplinkValidate() {(set -e
# this function will validate http-links embedded in .html and .md files
    node -e '
(function () {
    "use strict";
    let dict = {};
    require("fs").readdirSync(".").forEach(async function (file) {
        if (!(
            /.\.html$|.\.md$/m
        ).test(file)) {
            return;
        }
        let data = await require("fs").promises.readFile(file, "utf8");
        data.replace((
            /\bhttps?:\/\/.*?(?:[")\]]|$)/gm
        ), function (match0) {
            match0 = match0.slice(0, -1).replace((
                /[\u0022\u0027]/g
            ), "").replace((
                /\/branch\.\w+?\//g
            ), "/branch.alpha/").replace((
                /\bjslint-org\/jslint\b/g
            ), process.env.GITHUB_REPOSITORY || "jslint-org/jslint").replace((
                /\bjslint-org\.github\.io\/jslint\b/g
            ), String(
                process.env.GITHUB_REPOSITORY || "jslint-org/jslint"
            ).replace("/", ".github.io/"));
            if (match0.indexOf("http://") === 0) {
                throw new Error(
                    "shDirHttplinkValidate - insecure link " + match0
                );
            }
            // ignore duplicate-link
            if (dict.hasOwnProperty(match0)) {
                return "";
            }
            dict[match0] = true;
            let req = require("https").request(require("url").parse(
                match0
            ), function (res) {
                console.error(
                    "shDirHttplinkValidate " + res.statusCode + " " + match0
                );
                if (!(res.statusCode < 400)) {
                    throw new Error(
                        "shDirHttplinkValidate - " + file +
                        " - unreachable link " + match0
                    );
                }
                req.abort();
                res.destroy();
            });
            req.setTimeout(30000);
            req.end();
            return "";
        });
        data.replace((
            /(?:\bhref=|\bsrc=|\burl\().(.*?)(?:[")\]]|$)/gm
        ), function (ignore, match1) {
            if (!(
                /^https?|^mailto:|^[#\/]/m
            ).test(match1)) {
                require("fs").stat(match1, function (ignore, exists) {
                    console.error(
                        "shDirHttplinkValidate " + Boolean(exists) + " " +
                        match1
                    );
                    if (!exists) {
                        throw new Error(
                            "shDirHttplinkValidate - " + file +
                            " - unreachable link " + match1
                        );
                    }
                });
            }
            return "";
        });
    });
}());
' # "'
)}

shGitCmdWithGithubToken() {(set -e
# this function will run git $CMD with $GITHUB_TOKEN
    local CMD
    local EXIT_CODE
    local REMOTE
    local URL
    printf "shGitCmdWithGithubToken $*\n"
    CMD="$1"
    shift
    REMOTE="$1"
    shift
    URL="$(
        git config "remote.$REMOTE.url" |
            sed -e "s|https://|https://x-access-token:$GITHUB_TOKEN@|"
    )"
    EXIT_CODE=0
    # hide $GITHUB_TOKEN in case of err
    git "$CMD" "$URL" "$@" 2>/dev/null || EXIT_CODE="$?"
    printf "EXIT_CODE=$EXIT_CODE\n"
    return "$EXIT_CODE"
)}

shGitLsTree() {(set -e
# this function will "git ls-tree" all files committed in HEAD
# example use:
# shGitLsTree | sort -rk3 # sort by date
# shGitLsTree | sort -rk4 # sort by size
    node -e '
(function () {
    "use strict";
    let result;
    // get file, mode, size
    result = require("child_process").spawnSync("git", [
        "ls-tree", "-lr", "HEAD"
    ], {
        encoding: "utf8",
        stdio: [
            "ignore", "pipe", 2
        ]
    }).stdout;
    result = Array.from(result.matchAll(
        /^(\S+?)\u0020+?\S+?\u0020+?\S+?\u0020+?(\S+?)\t(\S+?)$/gm
    )).map(function ([
        ignore, mode, size, file
    ]) {
        return {
            file,
            mode: mode.slice(-3),
            size: Number(size)
        };
    });
    result = result.sort(function (aa, bb) {
        return aa.file > bb.file || -1;
    });
    result = result.slice(0, 1000);
    result.unshift({
        file: ".",
        mode: "755",
        size: 0
    });
    // get date
    result.forEach(function (elem) {
        result[0].size += elem.size;
        require("child_process").spawn("git", [
            "log", "--max-count=1", "--format=%at", elem.file
        ], {
            stdio: [
                "ignore", "pipe", 2
            ]
        }).stdout.on("data", function (chunk) {
            elem.date = new Date(
                Number(chunk) * 1000
            ).toISOString().slice(0, 19) + "Z";
        });
    });
    process.on("exit", function () {
        let iiPad;
        let sizePad;
        iiPad = String(result.length).length + 1;
        sizePad = String(Math.ceil(result[0].size / 1024)).length;
        process.stdout.write(result.map(function (elem, ii) {
            return (
                String(ii + ".").padStart(iiPad, " ") +
                "  " + elem.mode +
                "  " + elem.date +
                "  " + String(
                    Math.ceil(elem.size / 1024)
                ).padStart(sizePad, " ") + " KB" +
                "  " + elem.file +
                "\n"
            );
        }).join(""));
    });
}());
' # "'
)}

shJslintCli() {(set -e
# this function will run jslint from nodejs
    node -e '
import jslint from "./jslint.js";
import {promises, readFileSync, readdirSync} from "fs";
// init debugInline
if (!globalThis.debugInline) {
    let consoleError;
    consoleError = console.error;
    globalThis.debugInline = function (...argList) {
    /*
     * this function will both print <argList> to stderr and
     * return <argList>[0]
     */
        consoleError("\n\ndebugInline");
        consoleError(...argList);
        consoleError("\n");
        return argList[0];
    };
}
let exitCode;
function stringLineCount(data) {
/*
 * this function will count number of newlines in <data>
 */
    let cnt;
    let ii;
    // https://jsperf.com/regexp-counting-2/8
    cnt = 0;
    ii = 0;
    while (true) {
        ii = data.indexOf("\n", ii) + 1;
        if (ii === 0) {
            break;
        }
        cnt += 1;
    }
    return cnt;
}
async function jslint2({
    code,
    errList = [],
    file,
    lineOffset = 0
}) {
    switch ((
        /\.\w+?$|$/m
    ).exec(file)[0]) {
    case ".css":
        /*
        errList = CSSLint.verify( // jslint ignore:line
            code
        ).messages.map(function (err) {
            err.message = (
                err.type + " - " + err.rule.id + " - " + err.message
                + "\n    " + err.rule.desc
            );
            return err;
        });
        errList = [];
        // ignore comment
        code = code.replace((
            /^\u0020*?\/\*[\S\s]*?\*\/\u0020*?$/gm
        ), function (match0) {
            // preserve lineno
            return match0.replace((
                /.+/g
            ), "");
        });
        code.replace((
            /\S\u0020{2}|\u0020,|^\S.*?,.|[;{}]./gm
        ), function (match0, ii) {
            switch (match0.slice(-2)) {
            case "  ":
                err = {
                    message: "unexpected multi-whitespace"
                };
                break;
            case " ,":
                err = {
                    message: "unexpected whitespace before comma"
                };
                break;
            default:
                err = {
                    message: "unexpected multiline-statement"
                };
            }
            errList.push(Object.assign(err, {
                col: 1,
                evidence: match0,
                line: stringLineCount(code.slice(0, ii))
            }));
            return "";
        });
        // validate line-sorted - css-selector
        previous = "";
        code = code.replace((
            /^.|[#.>]|[,}]$|\u0020\{$|\b\w/gm
        ), function (match0) {
            switch (match0) {
            case " ":
                return match0;
            case " {":
                return "\u0001" + match0;
            case "#":
                return "\u0002" + match0;
            case ",":
                return "\u0000" + match0;
            case ".":
                return "\u0001" + match0;
            case ">":
                return "\u0003" + match0;
            case "}":
                return match0;
            default:
                return "\u0000" + match0;
            }
        });
        code.replace((
            /\n{2,}|^\u0000@|^\}\n\}|\}|^(?:\S.*?\n)+/gm
        ), function (match0, ii) {
            switch (match0.slice(0, 2)) {
            case "\n\n":
            case "\u0000@":
            case "}\n":
                previous = "";
                return "";
            case "}":
                return "";
            }
            match0 = match0.trim();
            err = (
                !(previous < match0)
                ? {
                    message: "lines not sorted\n" + previous + "\n" + match0
                }
                : match0.split("\n").sort().join("\n") !== match0
                ? {
                    message: "lines not sorted\n" + match0
                }
                : undefined
            );
            if (err) {
                errList.push(Object.assign(err, {
                    col: 1,
                    evidence: match0,
                    line: stringLineCount(code.slice(0, ii)),
                    message: err.message.replace((
                        /[\u0000-\u0007]/g
                    ), "")
                }));
            }
            previous = match0;
            return "";
        });
        */
        break;
    case ".html":
        // recurse
        code.replace((
            /^<style>\n([\S\s]*?\n)<\/style>$/gm
        ), function (ignore, match1, ii) {
            jslint2({
                code: match1,
                file: file + ".<style>.css",
                lineOffset: stringLineCount(code.slice(0, ii)) + 1
            });
            return "";
        });
        // recurse
        code.replace((
            /^<script\b[^>]*?>\n([\S\s]*?\n)<\/script>$/gm
        ), function (ignore, match1, ii) {
            jslint2({
                code: match1,
                file: file + ".<script>.js",
                lineOffset: stringLineCount(code.slice(0, ii)) + 1
            });
            return "";
        });
        return;
    case ".md":
        // recurse
        code.replace((
            /^```javascript\n([\S\s]*?\n)```$/gm
        ), function (ignore, match1, ii) {
            jslint2({
                code: match1.replace((
                    /\u0027"\u0027"\u0027/g
                ), "\u0027"),
                file: file + ".<```javascript>.js",
                lineOffset: stringLineCount(code.slice(0, ii)) + 1
            });
            return "";
        });
        return;
    case ".sh":
        // recurse
        code.replace((
            /\bnode\u0020-e\u0020\u0027\n([\S\s]*?\n)\u0027/gm
        ), function (ignore, match1, ii) {
            jslint2({
                code: match1.replace((
                    /\u0027"\u0027"\u0027/g
                ), "\u0027"),
                file: file + ".<node -e>.js",
                lineOffset: stringLineCount(code.slice(0, ii)) + 1
            });
            return "";
        });
        return;
    default:
        errList = jslint("\n".repeat(lineOffset) + code, {
            bitwise: true,
            browser: true,
            debug: true,
            fudge: true,
            node: true,
            this: true
        }, [
            "global", "globalThis"
        ]).warnings;
    }
    errList = errList.filter(function ({
        message
    }) {
        return message;
    // print only first 10 err
    }).slice(0, 10).map(function ({
        col,
        column,
        evidence,
        line,
        message,
        source_line,
        stack
    }, ii) {
        // mode csslint
        if (col !== undefined) {
            column = col;
            source_line = evidence;
        // mode jslint
        } else {
            column += 1;
            line += 1;
        }
        return (
            String(ii + 1).padStart(3, " ") +
            " \u001b[31m" + message + "\u001b[39m" +
            " \u001b[90m\/\/ line " + line + ", column " + column +
            "\u001b[39m\n" +
            ("    " + String(source_line).trim()).slice(0, 72) +
            ((ii === 0 && stack) || "")
        );
    });
    if (errList.length > 0) {
        exitCode = 1;
        // print err to stderr
        console.error(
            "\u001b[1mjslint " + file + "\u001b[22m\n" + errList.join("\n")
        );
    }
}
(async function () {
    let file;
    file = process.argv[1];
    if (file === ".") {
        await Promise.all(readdirSync(".").map(async function (file) {
            let code;
            let timeStart;
            timeStart = Date.now();
            switch ((
                /\.\w+?$|$/m
            ).exec(file)[0]) {
            // case ".css":
            case ".html":
            case ".js":
            // case ".json":
            case ".md":
            // case ".sh":
                break;
            default:
                return;
            }
            try {
                code = await promises.readFile(file, "utf8");
            } catch (ignore) {
                return;
            }
            if (!(
                !(
                    /\b(?:assets\.app\.js|lock|min|raw|rollup)\b/
                ).test(file) &&
                code &&
                /*
                (
                    /^\/\*jslint\b/m
                ).test(code.slice(0, 65536)) &&
                */
                code.length < 1048576
            )) {
                return;
            }
            jslint2({
                code,
                file
            });
            console.error(
                "jslint - " + (Date.now() - timeStart) + "ms - " + file
            );
        }));
    } else {
        jslint2({
            code: readFileSync(file, "utf8"),
            file
        });
    }
    process.exit(exitCode);
}());
' --input-type=module "$@" # "'
)}

shRunWithCoverage() {(set -e
# this function will run nodejs command $@ with v8-coverage and
# create coverage-report .build/coverage/index.html
    export DIR_COVERAGE=.build/coverage/
    rm -rf "$DIR_COVERAGE"
    (export NODE_V8_COVERAGE="$DIR_COVERAGE" && "$@" || true)
    node -e '
// init debugInline
if (!globalThis.debugInline) {
    let consoleError;
    consoleError = console.error;
    globalThis.debugInline = function (...argList) {
    /*
     * this function will both print <argList> to stderr and
     * return <argList>[0]
     */
        consoleError("\n\ndebugInline");
        consoleError(...argList);
        consoleError("\n");
        return argList[0];
    };
}
(async function () {
    "use strict";
    let DIR_COVERAGE = process.env.DIR_COVERAGE;
    let cwd;
    let data;
    let fileDict;
    async function htmlRender({
        fileList,
        lineList,
        pathname
    }) {
        let html;
        let padLines;
        let padPathname;
        let txt;
        let txtBorder;
        function stringHtmlSafe(str) {
        /*
         * this function will make <str> html-safe
         * https://stackoverflow.com/questions/7381974/which-characters-need-to-be-escaped-on-html
         */
            return str.replace((
                /&/gu
            ), "&amp;").replace((
                /"/gu
            ), "&quot;").replace((
                /\u0027/gu
            ), "&apos;").replace((
                /</gu
            ), "&lt;").replace((
                />/gu
            ), "&gt;").replace((
                /&amp;(amp;|apos;|gt;|lt;|quot;)/igu
            ), "&$1");
        }
        html = "";
        html += `<!DOCTYPE html>
<html lang="en">
<head>
<title>coverage-report</title>
<style>
/* csslint ignore:start */
* {
box-sizing: border-box;
    font-family: consolas, menlo, monospace;
}
/* csslint ignore:end */
body {
    margin: 0;
}
.coverage pre {
    margin: 5px 0;
}
.coverage table {
    border-collapse: collapse;
}
.coverage td,
.coverage th {
    border: 1px solid #777;
    margin: 0;
    padding: 5px;
}
.coverage td span {
    display: inline-block;
    width: 100%;
}
.coverage .content {
    padding: 0 5px;
}
.coverage .content a {
    text-decoration: none;
}
.coverage .count {
    margin: 0 5px;
    padding: 0 5px;
}
.coverage .footer,
.coverage .header {
    padding: 20px;
}
.coverage .percentbar {
    height: 12px;
    margin: 2px 0;
    min-width: 200px;
    position: relative;
    width: 100%;
}
.coverage .percentbar div {
    height: 100%;
    position: absolute;
}
.coverage .title {
    font-size: large;
    font-weight: bold;
    margin-bottom: 10px;
}

.coverage td,
.coverage th {
    background: #fff;
}
.coverage .count {
    background: #9d9;
    color: #777;
}
.coverage .coverageHigh{
    background: #9d9;
}
.coverage .coverageLow{
    background: #ebb;
}
.coverage .coverageMedium{
    background: #fd7;
}
.coverage .header {
    background: #ddd;
}
.coverage .lineno {
    background: #ddd;
}
.coverage .percentbar {
    background: #999;
}
.coverage .percentbar div {
    background: #666;
}
.coverage .uncovered {
    background: #dbb;
}

.coverage pre:hover span,
.coverage tr:hover td {
    background: #bbe;
}
</style>
</head>
<body class="coverage">
<div class="header">
<div class="title">coverage-report</div>
<table>
<thead>
<tr>
<th>files covered</th>
<th>lines</th>
</tr>
</thead>
<tbody>`;
        if (!lineList) {
            padLines = String("100.00 %").length;
            padPathname = 32;
            fileList.unshift({
                linesCovered: 0,
                linesTotal: 0,
                pathname: "./"
            });
            fileList.slice(1).forEach(function ({
                linesCovered,
                linesTotal,
                pathname
            }) {
                fileList[0].linesCovered += linesCovered;
                fileList[0].linesTotal += linesTotal;
                padPathname = Math.max(padPathname, pathname.length + 2);
                padLines = Math.max(
                    padLines,
                    String(linesCovered + " / " + linesTotal).length
                );
            });
        }
        txtBorder = (
            "+" + "-".repeat(padPathname + 2) + "+" +
            "-".repeat(padLines + 2) + "+\n"
        );
        txt = "";
        txt += "coverage-report\n";
        txt += txtBorder;
        txt += (
            "| " + String("files covered").padEnd(padPathname, " ") + " | " +
            String("lines").padStart(padLines, " ") + " |\n"
        );
        txt += txtBorder;
        fileList.forEach(function ({
            linesCovered,
            linesTotal,
            pathname
        }, ii) {
            let coverageLevel;
            let coveragePct;
            coveragePct = Math.floor(10000 * linesCovered / linesTotal | 0);
            coverageLevel = (
                coveragePct >= 8000
                ? "coverageHigh"
                : coveragePct >= 5000
                ? "coverageMedium"
                : "coverageLow"
            );
            coveragePct = String(coveragePct).replace((
                /..$/m
            ), ".$&");
            if (!lineList && ii === 0) {
                let fill = (
                    // red
                    "#" + Math.round(
                        (100 - Number(coveragePct)) * 2.21
                    ).toString(16).padStart(2, "0")
                    // green
                    + Math.round(
                        Number(coveragePct) * 2.21
                    ).toString(16).padStart(2, "0") +
                    // blue
                    "00"
                );
                let str1 = "coverage";
                let str2 = coveragePct + " %";
                let xx1 = 6 * str1.length + 20;
                let xx2 = 6 * str2.length + 20;
                // fs - write coverage-badge.svg
                require("fs").promises.writeFile((
                    DIR_COVERAGE + "/coverage-badge.svg"
                ), String(`
<svg height="20" width="${xx1 + xx2}" xmlns="http://www.w3.org/2000/svg">
<rect fill="#555" height="20" width="${xx1 + xx2}"/>
<rect fill="${fill}" height="20" width="${xx2}" x="${xx1}"/>
<g
    fill="#fff"
    font-family="dejavu sans,verdana,geneva,sans-serif"
    font-size="11"
    font-weight="bold"
    text-anchor="middle"
>
<text x="${0.5 * xx1}" y="14">${str1}</text>
<text x="${xx1 + 0.5 * xx2}" y="14">${str2}</text>
</g>
</svg>
                `).trim() + "\n");
                pathname = "";
            }
            txt += (
                "| " +
                String("./" + pathname).padEnd(padPathname, " ") + " | " +
                String(coveragePct + " %").padStart(padLines, " ") + " |\n"
            );
            txt += (
                "| " + "*".repeat(
                    Math.round(0.01 * coveragePct * padPathname)
                ).padEnd(padPathname, "_") + " | " +
                String(
                    linesCovered + " / " + linesTotal
                ).padStart(padLines, " ") + " |\n"
            );
            txt += txtBorder;
            pathname = stringHtmlSafe(pathname);
            html += `<tr>
<td class="${coverageLevel}">
            ${(
                lineList
                ? (
                    "<a href=\"index.html\">./ </a>" +
                    pathname + "<br>"
                )
                : (
                    "<a href=\"" + (pathname || "index") + ".html\">./ " +
                    pathname + "</a><br>"
                )
            )}
<div class="percentbar">
    <div style="width: ${coveragePct}%;"></div>
</div>
</td>
<td style="text-align: right;">
    ${coveragePct} %<br>
    ${linesCovered} / ${linesTotal}
</td>
</tr>`;
        });
        if (lineList) {
            html += `</tbody>
</table>
</div>
<div class="content">
`;
            lineList.forEach(function ({
                count,
                holeList,
                line,
                startOffset
            }, ii) {
                let chunk;
                let inHole;
                let lineId;
                let lineHtml;
                lineHtml = "";
                lineId = "line_" + (ii + 1);
                switch (count) {
                case -1:
                case 0:
                    if (holeList.length === 0) {
                        lineHtml += "</span>";
                        lineHtml += "<span class=\"uncovered\">";
                        lineHtml += stringHtmlSafe(line);
                        break;
                    }
                    line = line.split("").map(function (chr) {
                        return {
                            chr,
                            isHole: undefined
                        };
                    });
                    holeList.forEach(function ([
                        aa, bb
                    ]) {
                        aa = Math.max(aa - startOffset, 0);
                        bb = Math.min(bb - startOffset, line.length);
                        while (aa < bb) {
                            line[aa].isHole = true;
                            aa += 1;
                        }
                    });
                    chunk = "";
                    line.forEach(function ({
                        chr,
                        isHole
                    }) {
                        if (inHole !== isHole) {
                            lineHtml += stringHtmlSafe(chunk);
                            lineHtml += (
                                isHole
                                ? "</span><span class=\"uncovered\">"
                                : "</span><span>"
                            );
                            chunk = "";
                            inHole = isHole;
                        }
                        chunk += chr;
                    });
                    lineHtml += stringHtmlSafe(chunk);
                    break;
                default:
                    lineHtml += stringHtmlSafe(line);
                }
                html += String(`
<pre>
<span class="lineno">
<a href="#${lineId}" id="${lineId}">${String(ii + 1).padStart(5, " ")}.</a>
</span>
<span class="count
                ${(
                    count <= 0
                    ? "uncovered"
                    : ""
                )}"
>
${String(count).padStart(7, " ")}
</span>
<span>${lineHtml}</span>
</pre>
                `).replace((
                    /\n/g
                ), "").trim() + "\n";
            });
        }
        html += `
</div>
<div class="coverageFooter">
</div>
</body>
</html>`;
        html += "\n";
        await require("fs").promises.mkdir(require("path").dirname(pathname), {
            recursive: true
        });
        // fs - write *.html
        require("fs").promises.writeFile(pathname + ".html", html);
        if (lineList) {
            return;
        }
        // fs - write coverage.txt
        console.error("\n" + txt);
        require("fs").promises.writeFile((
            DIR_COVERAGE + "/coverage-report.txt"
        ), txt);
    }
    data = await require("fs").promises.readdir(DIR_COVERAGE);
    await Promise.all(data.map(async function (file) {
        if ((
            /^coverage-.*?\.json$/
        ).test(file)) {
            data = await require("fs").promises.readFile((
                DIR_COVERAGE + file
            ), "utf8");
            // fs - rename to coverage-v8.json
            require("fs").promises.rename(
                DIR_COVERAGE + file,
                DIR_COVERAGE + "coverage-v8.json"
            );
        }
    }));
    fileDict = {};
    cwd = process.cwd().replace((
        /\\/g
    ), "/") + "/";
    await Promise.all(JSON.parse(data).result.map(async function ({
        functions,
        url
    }) {
        let lineList;
        let linesCovered;
        let linesTotal;
        let pathname;
        let src;
        if (url.indexOf("file:///") !== 0) {
            return;
        }
        pathname = url.replace((
            process.platform === "win32"
            ? "file:///"
            : "file://"
        ), "").replace((
            /\\\\/g
        ), "/");
        if (
            pathname.indexOf(cwd) !== 0 ||
            pathname.indexOf(cwd + "[") === 0 ||
            (
                process.env.npm_config_mode_coverage !== "all" &&
                pathname.indexOf("/node_modules/") >= 0
            )
        ) {
            return;
        }
        pathname = pathname.replace(cwd, "");
        src = await require("fs").promises.readFile(pathname, "utf8");
        lineList = [{}];
        src.replace((
            /^.*$/gm
        ), function (line, startOffset) {
            lineList[lineList.length - 1].endOffset = startOffset - 1;
            lineList.push({
                count: -1,
                endOffset: 0,
                holeList: [],
                line,
                startOffset
            });
            return "";
        });
        lineList.shift();
        lineList[lineList.length - 1].endOffset = src.length;
        functions.reverse().forEach(function ({
            ranges
        }) {
            ranges.reverse().forEach(function ({
                count,
                endOffset,
                startOffset
            }, ii, list) {
                lineList.forEach(function (elem) {
                    if (!(
                        (
                            elem.startOffset <= startOffset &&
                            startOffset <= elem.endOffset
                        ) || (
                            elem.startOffset <= endOffset &&
                            endOffset <= elem.endOffset
                        ) || (
                            startOffset <= elem.startOffset &&
                            elem.endOffset <= endOffset
                        )
                    )) {
                        return;
                    }
                    // handle root-range
                    if (ii + 1 === list.length) {
                        if (elem.count === -1) {
                            elem.count = count;
                        }
                        return;
                    }
                    // handle non-root-range
                    if (elem.count !== 0) {
                        elem.count = Math.max(count, elem.count);
                    }
                    if (count === 0) {
                        elem.count = 0;
                        elem.holeList.push([
                            startOffset, endOffset
                        ]);
                    }
                });
            });
        });
        linesTotal = lineList.length;
        linesCovered = lineList.filter(function ({
            count
        }) {
            return count > 0;
        }).length;
        await require("fs").promises.mkdir((
            require("path").dirname(DIR_COVERAGE + pathname)
        ), {
            recursive: true
        });
        await htmlRender({
            fileList: [
                {
                    linesCovered,
                    linesTotal,
                    pathname
                }
            ],
            lineList,
            pathname: DIR_COVERAGE + pathname
        });
        fileDict[pathname] = {
            lineList,
            linesCovered,
            linesTotal,
            pathname,
            src
        };
    }));
    await htmlRender({
        fileList: Object.keys(fileDict).sort().map(function (pathname) {
            return fileDict[pathname];
        }),
        pathname: DIR_COVERAGE + "index"
    });
}());
' # "'
)}

shRunWithScreenshotTxt() {(set -e
# this function will run cmd $@ and screenshot text-output
# https://www.cnx-software.com/2011/09/22/how-to-convert-a-command-line-result-into-an-image-in-linux/
    local EXIT_CODE
    EXIT_CODE=0
    export SCREENSHOT_SVG=.build/screenshot.svg
    rm -f "$SCREENSHOT_SVG"
    printf "0\n" > "$SCREENSHOT_SVG.exit_code"
    shCiPrint "shRunWithScreenshotTxt - (shRun $* 2>&1)"
    (
        (shRun "$@" 2>&1) || printf "$?\n" > "$SCREENSHOT_SVG.exit_code"
    ) | tee /tmp/shRunWithScreenshotTxt.txt
    EXIT_CODE="$(cat "$SCREENSHOT_SVG.exit_code")"
    shCiPrint "shRunWithScreenshotTxt - EXIT_CODE=$EXIT_CODE"
    # run shRunWithScreenshotTxtAfter
    if (type shRunWithScreenshotTxtAfter > /dev/null 2>&1)
    then
        eval shRunWithScreenshotTxtAfter
        unset shRunWithScreenshotTxtAfter
    fi
    # format text-output
    node -e '
(function () {
    "use strict";
    let result;
    let yy;
    yy = 10;
    result = require("fs").readFileSync(
        require("os").tmpdir() + "/shRunWithScreenshotTxt.txt",
        "utf8"
    );
    // remove ansi escape-code
    result = result.replace((
        /\u001b.*?m/g
    ), "");
    // format unicode
    result = result.replace((
        /\\u[0-9a-f]{4}/g
    ), function (match0) {
        return String.fromCharCode("0x" + match0.slice(-4));
    }).trimEnd();
    // 96 column wordwrap
    result = result.replace((
        /^.*?$/gm
    ), function (line) {
        return line.replace((
            /.{0,96}/g
        ), function (line, ii) {
            if (ii && !line) {
                return "";
            }
            yy += 16;
            return "<tspan x=\"10\" y=\"" + yy + "\">" + line.replace((
                /&/g
            ), "&amp;").replace((
                /</g
            ), "&lt;").replace((
                />/g
            ), "&gt;") + "</tspan>";
        }).replace((
            /(<\/tspan><tspan)/g
        ), "\\$1").slice();
    }) + "\n";
    result = (
        "<svg height=\"" + (yy + 20) +
        "px\" width=\"720px\" xmlns=\"http://www.w3.org/2000/svg\">\n" +
        "<rect height=\"" + (yy + 20) +
        "px\" fill=\"#555\" width=\"720px\"></rect>\n" +
        "<text fill=\"#7f7\" font-family=\"Consolas, Menlo, monospace\" " +
        "font-size=\"12\" xml:space=\"preserve\">\n" +
        result + "</text>\n</svg>\n"
    );
    try {
        require("fs").mkdirSync(require("path").dirname(process.argv[1]), {
            recursive: true
        });
    } catch (ignore) {}
    require("fs").writeFileSync(process.argv[1], result);
}());
' "$SCREENSHOT_SVG" # "'
    shCiPrint "shRunWithScreenshotTxt - wrote - $SCREENSHOT_SVG"
    return "$EXIT_CODE"
)}

# run $@
"$@"
