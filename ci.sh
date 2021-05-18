#!/bin/sh

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

shGithubCi() {(set -e
# this function will run github-ci
    # jslint all files
    shJslintCli .
    # create coverage-report
    shV8CoverageReport shJslintCli jslint.js
)}

shGithubUploadArtifact() {(set -e
# this function will upload build-artifacts to branch-gh-pages
    local BRANCH
    # init $BRANCH
    BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    # init .git/config
    git config --local user.email "github-actions@users.noreply.github.com"
    git config --local user.name "github-actions"
    # commit coverage-report
    git add -f .coverage/
    git commit -am "add coverage-report"
    # add coverage-report to branch-gh-pages
    git checkout -b gh-pages
    git fetch origin gh-pages
    git reset origin/gh-pages --hard
    rm -rf "branch.$BRANCH"
    mkdir "branch.$BRANCH"
    cp -a .git "branch.$BRANCH"
    (cd "branch.$BRANCH" && git reset "$BRANCH" --hard)
    rm -rf "branch.$BRANCH/.git"
    git add -f "branch.$BRANCH"
    git commit -am "update dir branch.$BRANCH" || true
    # if branch-gh-pages has more than 100 commits,
    # then backup and squash all commits
    if [ "$(git rev-list gh-pages --count)" -gt 100 ]
    then
        # backup
        shGitCmdWithGithubToken push origin -f gh-pages:gh-pages.backup
        # squash all commits
        git add -f .
        git checkout --orphan squash1
        git checkout gh-pages .
        git add -f .
        git commit --quiet -am squash || true
        # reset branch-gh-pages to squashed-commit
        git push . -f squash1:gh-pages
        git checkout gh-pages
        # force push squashed-commit
        shGitCmdWithGithubToken push origin -f gh-pages
    fi
    # push branch-gh-pages
    shGitCmdWithGithubToken push origin gh-pages
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
// hack-jslint - cli
let errMsg;
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
    err,
    errList = [],
    file,
    lineOffset = 0,
    previous
}) {
    switch ((
        /\.\w+?$|$/m
    ).exec(file)[0]) {
    case ".css":
        errList = CSSLint.verify( // jslint ignore:line
            code
        ).messages.map(function (err) {
            err.message = (
                err.type + " - " + err.rule.id + " - " + err.message
                + "\n    " + err.rule.desc
            );
            return err;
        });
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
            /^<script>\n([\S\s]*?\n)<\/script>$/gm
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
                    /'"'"'"'"'"'"'"'"'/g
                ), "'"'"'"),
                file: file + ".<```javascript>.js",
                lineOffset: stringLineCount(code.slice(0, ii)) + 1
            });
            return "";
        });
        return;
    case ".sh":
        // recurse
        code.replace((
            /\bnode\u0020-e\u0020'"'"'\n([\S\s]*?\n)'"'"'/gm
        ), function (ignore, match1, ii) {
            jslint2({
                code: match1.replace((
                    /'"'"'"'"'"'"'"'"'/g
                ), "'"'"'"),
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
    errMsg = errList.filter(function ({
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
    }).join("\n");
    if (errMsg) {
        // print err to stderr
        console.error("\u001b[1mjslint " + file + "\u001b[22m\n" + errMsg);
    }
}
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
        case ".css":
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
            code.length < 1048576 &&
            (
                /^\/\*\u0020jslint\u0020utility2:true\u0020\*\/$/m
            ).test(code.slice(0, 65536))
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
process.exit(Boolean(errMsg) | 0);
' --input-type=module "$@" # '
)}

shV8CoverageReport() {(set -e
# this function will create coverage-report .coverage/index.html from
# nodejs command "$@"
    rm -rf .coverage/
    (export NODE_V8_COVERAGE=.coverage/ && "$@" || true)
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
                /'"'"'/gu
            ), "&apos;").replace((
                /</gu
            ), "&lt;").replace((
                />/gu
            ), "&gt;").replace((
                /&amp;(amp;|apos;|gt;|lt;|quot;)/igu
            ), "&$1");
        }
        html = "";
        html += `<!doctype html>
<html lang="en">
<head>
<title>coverage-report</title>
<style>
/* jslint utility2:true */
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
        if (!lineList) {
            console.error("\n" + txt);
            await require("fs").promises.writeFile((
                ".coverage/coverage.txt"
            ), txt);
        }
        await require("fs").promises.writeFile(pathname + ".html", html);
    }
    data = await require("fs").promises.readdir(".coverage/");
    await Promise.all(data.map(async function (file) {
        if ((
            /^coverage-.*?\.json$/
        ).test(file)) {
            data = await require("fs").promises.readFile((
                ".coverage/" + file
            ), "utf8");
            require("fs").promises.rename(
                ".coverage/" + file,
                ".coverage/coverage_v8.json"
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
                    /*
                    debugInline(
                        count,
                        [elem.startOffset, startOffset],
                        [elem.endOffset, endOffset],
                        elem.line
                    );
                    */
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
            require("path").dirname(".coverage/" + pathname)
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
            pathname: ".coverage/" + pathname
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
        pathname: ".coverage/index"
    });
}());
' # '
)}

# run "$@"
"$@"
