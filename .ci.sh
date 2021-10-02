shArtifactUploadCustom() {(set -e
# this function will custom-upload build-artifacts to branch-gh-pages
    # screenshot asset_image_logo
    shImageLogoCreate &
    # screenshot install
    shBrowserScreenshot \
        "https://$UPSTREAM_OWNER.github.io/\
$UPSTREAM_REPO/branch-beta/index.html"
    # screenshot curl
    node --input-type=module -e '
import moduleFs from "fs";
import moduleChildProcess from "child_process";
(async function () {
    let screenshotCurl;
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
    // parallel-task - screenshot example-shell-commands in README.md
    Array.from(String(
        await moduleFs.promises.readFile("README.md", "utf8")
    ).matchAll(
        /\n```shell\u0020<!--\u0020shRunWithScreenshotTxt\u0020(.*?)\u0020-->\n([\S\s]*?\n)```\n/g
    )).forEach(async function ([
        ignore, file, script
    ]) {
        await moduleFs.promises.writeFile(file + ".sh", (
            "printf \u0027"
            + script.trim().replace((
                /[%\\]/gm
            ), "$&$&").replace((
                /\u0027/g
            ), "\u0027\"\u0027\"\u0027").replace((
                /^/gm
            ), "> ")
            + "\n\n\n\u0027\n"
            + script.replace(
                "curl -L https://www.jslint.com/jslint.mjs > jslint.mjs",
                screenshotCurl
            )
        ));
        moduleChildProcess.spawn(
            "sh",
            [
                "jslint_ci.sh",
                "shRunWithScreenshotTxt",
                file,
                "sh",
                file + ".sh"
            ],
            {
                stdio: [
                    "ignore", 1, 2
                ]
            }
        );
    });
}());
' "$@" # '
    # screenshot asset_image_logo_512.png
    shBrowserScreenshot .jslint_report.html \
        --window-size=512x512 \
        -screenshot=.build/screenshot_install_cli_report.png
    # seo - inline css-assets and invalidate cached-assets
    node --input-type=module -e '
import moduleFs from "fs";
(async function () {
    let cacheKey = Math.random().toString(36).slice(-4);
    let fileDict = {};
    await Promise.all([
        "asset_codemirror_rollup.css",
        "index.html",
        "jslint.mjs"
    ].map(async function (file) {
        try {
            fileDict[file] = await moduleFs.promises.readFile(file, "utf8");
        } catch (ignore) {
            process.exit();
        }
    }));

// inline css-assets

    fileDict["index.html"] = fileDict["index.html"].replace((
        "\n<link rel=\"stylesheet\" href=\"asset_codemirror_rollup.css\">\n"
    ), function () {
        return (
            "\n<style>\n"
            + fileDict["asset_codemirror_rollup.css"].trim()
            + "\n</style>\n"
        );
    });
    fileDict["index.html"] = fileDict["index.html"].replace((
        "\n<style class=\"JSLINT_REPORT_STYLE\"></style>\n"
    ), function () {
        return fileDict["jslint.mjs"].match(
            /\n<style\sclass="JSLINT_REPORT_STYLE">\n[\S\s]*?\n<\/style>\n/
        )[0];
    });

// invalidate cached-assets

    fileDict["index.html"] = fileDict["index.html"].replace((
        /\b(?:href|src)=".+?\.(?:css|js|mjs)\b/g
    ), function (match0) {
        return `${match0}?cc=${cacheKey}`;
    });

// write file

    await Promise.all(Object.entries(fileDict).map(function ([
        file, data
    ]) {
        moduleFs.promises.writeFile(file, data);
    }));
}());
' "$@" # '
    git add -f jslint.cjs jslint.js || true
)}

(set -e
    # coverage-hack - test jslint's invalid-file handling-behavior
    mkdir -p .test-dir.js
)
