#!/bin/sh

## The Unlicense
##
## This is free and unencumbered software released into the public domain.
##
## Anyone is free to copy, modify, publish, use, compile, sell, or
## distribute this software, either in source code form or as a compiled
## binary, for any purpose, commercial or non-commercial, and by any
## means.
##
## In jurisdictions that recognize copyright laws, the author or authors
## of this software dedicate any and all copyright interest in the
## software to the public domain. We make this dedication for the benefit
## of the public at large and to the detriment of our heirs and
## successors. We intend this dedication to be an overt act of
## relinquishment in perpetuity of all present and future rights to this
## software under copyright law.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
## EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
## MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
## IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
## OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
## ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
## OTHER DEALINGS IN THE SOFTWARE.
##
## For more information, please refer to <https://unlicense.org/>


# POSIX reference
# http://pubs.opengroup.org/onlinepubs/9699919799/utilities/test.html
# http://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html

# sh one-liner
# git add .; npm run test2; git checkout .
# git branch -d -r origin/aa
# git config --global diff.algorithm histogram
# git fetch --prune
# git fetch origin alpha beta master && git fetch upstream alpha beta master
# git fetch origin alpha beta master --tags
# git fetch upstream "refs/tags/*:refs/tags/*"
# git ls-files --stage | sort
# git ls-remote --heads origin
# git update-index --chmod=+x aa.js
# head CHANGELOG.md -n50
# ln -f jslint.mjs ~/jslint.mjs
# openssl rand -base64 32 # random key
# sh jslint_ci.sh shRunWithScreenshotTxt .artifact/screenshot_changelog.svg head -n50 CHANGELOG.md
# vim rgx-lowercase \L\1\e

# charset - ascii
# \u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007
# \b\t\n\u000b\f\r\u000e\u000f
# \u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017
# \u0018\u0019\u001a\u001b\u001c\u001d\u001e\u001f
#  !\"#$%&'()*+,-./0123456789:;<=>?
# @ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_
# `abcdefghijklmnopqrstuvwxyz{|}~\u007f

shBashrcDebianInit() {
# this function will init debian:stable /etc/skel/.bashrc
# https://sources.debian.org/src/bash/4.4-5/debian/skel.bashrc/
    # ~/.bashrc: executed by bash(1) for non-login shells.
    # see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
    # for examples

    # If not running interactively, don't do anything
    case $- in
        *i*) ;;
          *) return;;
    esac

    # don't put duplicate lines or lines starting with space in the history.
    # See bash(1) for more options
    HISTCONTROL=ignoreboth

    # append to the history file, don't overwrite it
    shopt -s histappend

    # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
    HISTSIZE=1000
    HISTFILESIZE=2000

    # check the window size after each command and, if necessary,
    # update the values of LINES and COLUMNS.
    shopt -s checkwinsize

    # If set, the pattern "**" used in a pathname expansion context will
    # match all files and zero or more directories and subdirectories.
    #shopt -s globstar

    # make less more friendly for non-text input files, see lesspipe(1)
    [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

    # set variable identifying the chroot you work in (used in the prompt below)
    if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
        debian_chroot=$(cat /etc/debian_chroot)
    fi

    # set a fancy prompt (non-color, unless we know we "want" color)
    case "$TERM" in
        xterm-color|*-256color) color_prompt=yes;;
    esac

    # uncomment for a colored prompt, if the terminal has the capability; turned
    # off by default to not distract the user: the focus in a terminal window
    # should be on the output of commands, not on the prompt
    #force_color_prompt=yes

    if [ -n "$force_color_prompt" ]; then
        if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
        else
        color_prompt=
        fi
    fi

    if [ "$color_prompt" = yes ]; then
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    else
        PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    fi
    unset color_prompt force_color_prompt

    # If this is an xterm set the title to user@host:dir
    case "$TERM" in
    xterm*|rxvt*)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
    esac

    # enable color support of ls and also add handy aliases
    if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        alias ls='ls --color=auto'
        #alias dir='dir --color=auto'
        #alias vdir='vdir --color=auto'

        alias grep='grep --color=auto'
        #alias fgrep='fgrep --color=auto'
        #alias egrep='egrep --color=auto'
    fi

    # colored GCC warnings and errors
    #export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

    # some more ls aliases
    alias ll='ls -alF'
    #alias la='ls -A'
    #alias l='ls -CF'

    # Alias definitions.
    # You may want to put all your additions into a separate file like
    # ~/.bash_aliases, instead of adding them here directly.
    # See /usr/share/doc/bash-doc/examples in the bash-doc package.

    if [ -f ~/.bash_aliases ]; then
        . ~/.bash_aliases
    fi

    # enable programmable completion features (you don't need to enable
    # this, if it's already enabled in /etc/bash.bashrc and /etc/profile
    # sources /etc/bash.bashrc).
    if ! shopt -oq posix; then
        if [ -f /usr/share/bash-completion/bash_completion ]; then
            . /usr/share/bash-completion/bash_completion
        elif [ -f /etc/bash_completion ]; then
            . /etc/bash_completion
        fi
    fi
}

shBashrcWindowsInit() {
# this function will init windows-environment
    case "$(uname)" in
    CYGWIN*)
        ;;
    MINGW*)
        ;;
    MSYS*)
        ;;
    *)
        return
        ;;
    esac
    # alias curl.exe
    # if (! alias curl &>/dev/null) && [ -f c:/windows/system32/curl.exe ]
    # then
    #     alias curl=c:/windows/system32/curl.exe
    # fi
    # alias node.exe
    if (! alias node &>/dev/null)
    then
        alias node=node.exe
    fi
}

shBrowserScreenshot() {(set -e
# this function will run headless-chrome to screenshot url $1 with
# window-size $2
    node --input-type=module --eval '
import moduleChildProcess from "child_process";
import modulePath from "path";
import moduleUrl from "url";
// init debugInline
(function () {
    let consoleError = console.error;
    globalThis.debugInline = globalThis.debugInline || function (...argList) {

// this function will both print <argList> to stderr and return <argList>[0]

        consoleError("\n\ndebugInline");
        consoleError(...argList);
        consoleError("\n");
        return argList[0];
    };
}());
(async function () {
    let child;
    let exitCode;
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
        url = modulePath.resolve(url);
    }
    file = moduleUrl.parse(url).pathname;
    // remove prefix $PWD from file
    if (String(file + "/").startsWith(process.cwd() + "/")) {
        file = file.replace(process.cwd(), "");
    }
    file = ".artifact/screenshot_browser_" + encodeURIComponent(file).replace((
        /%/g
    ), "_").toLowerCase() + ".png";
    child = moduleChildProcess.spawn(
        (
            process.platform === "darwin"
            ? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
            : process.platform === "win32"
            ? "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe"
            : "/usr/bin/google-chrome-stable"
        ),
        [
            "--headless",
            "--ignore-certificate-errors",
            "--incognito",
            "--screenshot",
            "--timeout=30000",
            "--user-data-dir=/dev/null",
            "--window-size=800x600",
            "-screenshot=" + file,
            (
                (process.getuid && process.getuid() === 0)
                ? "--no-sandbox"
                : ""
            ),
            url
        ].concat(process.argv.filter(function (elem) {
            return elem.startsWith("-");
        })).filter(function (elem) {
            return elem;
        }),
        {stdio: ["ignore", 1, 2]}
    );
    exitCode = await new Promise(function (resolve) {
        child.on("exit", resolve);
    });
    console.error(
        "shBrowserScreenshot"
        + "\n  - url - " + url
        + "\n  - wrote - " + file
        + "\n  - timeElapsed - " + (Date.now() - timeStart) + " ms"
        + "\n  - EXIT_CODE=" + exitCode
    );
}());
' "$@" # '
)}

shCiArtifactUpload() {(set -e
# this function will upload build-artifacts to branch-gh-pages
# shCiArtifactUploadCustom() {(set -e
# # this function will run custom-code to upload build-artifacts
#     return
# )}
    local FILE
    if ! (shCiMatrixIsmainName \
        && [ -f package.json ] \
        && grep -q '^    "shCiArtifactUpload": 1,$' package.json)
    then
        return
    fi
    mkdir -p .artifact
    # init .git/config
    git config --local user.email "github-actions@users.noreply.github.com"
    git config --local user.name "github-actions"
    # init $GITHUB_BRANCH0
    export GITHUB_BRANCH0="$(git rev-parse --abbrev-ref HEAD)"
    git pull --unshallow origin "$GITHUB_BRANCH0"
    # init $UPSTREAM_XXX
    export UPSTREAM_REPOSITORY="$(node -p '(
    /^https:\/\/github\.com\/([^\/]*?\/[^.]*?)\.git$/
).exec(require("./package.json").repository.url)[1]
')" # '
    export UPSTREAM_GITHUB_IO="$(
        printf "$UPSTREAM_REPOSITORY" | sed -e "s|/|.github.io/|"
    )"
    # init $GITHUB_XXX
    export GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-$UPSTREAM_REPOSITORY}"
    export GITHUB_GITHUB_IO="$(
        printf "$GITHUB_REPOSITORY" | sed -e "s|/|.github.io/|"
    )"
    # screenshot changelog and files
    node --input-type=module --eval '
import moduleChildProcess from "child_process";
(function () {
    [
        // parallel-task - screenshot changelog
        [
            "jslint_ci.sh",
            "shRunWithScreenshotTxt",
            ".artifact/screenshot_changelog.svg",
            "head",
            "-n50",
            "CHANGELOG.md"
        ],
        // parallel-task - screenshot files
        [
            "jslint_ci.sh",
            "shRunWithScreenshotTxt",
            ".artifact/screenshot_package_listing.svg",
            "shGitLsTree"
        ],
        // parallel-task - screenshot logo
        [
            "jslint_ci.sh",
            "shImageLogoCreate"
        ]
    ].forEach(function (argList) {
        moduleChildProcess.spawn(
            "sh",
            argList,
            {stdio: ["ignore", 1, 2]}
        ).on("exit", function (exitCode) {
            if (exitCode) {
                process.exit(exitCode);
            }
        });
    });
}());
' "$@" # '
    if (command -v shCiArtifactUploadCustom >/dev/null)
    then
        shCiArtifactUploadCustom
    fi
    # 1px-border around browser-screenshot
    if (ls .artifact/screenshot_browser_*.png 2>/dev/null \
            && mogrify -version 2>&1 | grep -i imagemagick)
    then
        mogrify -shave 1x1 -bordercolor black -border 1 \
            .artifact/screenshot_browser_*.png
    fi
    # add dir .artifact
    git add -f .artifact
    git rm --cached -r .artifact/tmp 2>/dev/null || true
    git commit -am "add dir .artifact"
    # checkout branch-gh-pages
    git fetch origin gh-pages
    git checkout -b gh-pages origin/gh-pages
    # update dir branch-$GITHUB_BRANCH0
    rm -rf "branch-$GITHUB_BRANCH0"
    git clone . "branch-$GITHUB_BRANCH0" --branch="$GITHUB_BRANCH0"
    rm -rf "branch-$GITHUB_BRANCH0/.git"
    # add dir branch-$GITHUB_BRANCH0
    git add -f "branch-$GITHUB_BRANCH0"
    # update root-dir with branch-beta
    if [ "$GITHUB_BRANCH0" = beta ]
    then
        rm -rf .artifact
        git checkout beta .
        # update apidoc.html
        for FILE in apidoc.html
        do
            if [ -f ".artifact/$FILE" ]
            then
                cp -a ".artifact/$FILE" .
                git add -f "$FILE"
            fi
        done
    fi
    # update README.md with branch-$GITHUB_BRANCH0 and $GITHUB_REPOSITORY
    sed -i \
        -e "s|/branch-[a-z]*/|/branch-$GITHUB_BRANCH0/|g" \
        -e "s|\\b$UPSTREAM_GITHUB_IO\\b|$GITHUB_GITHUB_IO|g" \
        -e "s|\\b$UPSTREAM_REPOSITORY\\b|$GITHUB_REPOSITORY|g" \
        -e "s|_2fbranch-[a-z]*_2f|_2fbranch-${GITHUB_BRANCH0}_2f|g" \
        "branch-$GITHUB_BRANCH0/README.md"
    git status
    # git push
    shGitCommitPushOrSquash "" 50
    # list files
    shGitLsTree
    # validate http-links
    (
    cd "branch-$GITHUB_BRANCH0"
    sleep 15
    shDirHttplinkValidate
    )
)}

shCiBase() {(set -e
# this function will run base-ci
# shCiBaseCustom() {(set -e
# # this function will run custom-code for base-ci
#     return
# )}
# shCiLintCustom2() {(set -e
# # this function will run custom-code to lint files
# )}
    export GITHUB_BRANCH0="$(git rev-parse --abbrev-ref HEAD)"
    # validate package.json.fileCount
    node --input-type=module --eval '
import moduleFs from "fs";
globalThis.assert(
    JSON.parse(
        moduleFs.readFileSync("package.json") //jslint-ignore-line
    ).fileCount === Number(process.argv[1]),
    `package.json.fileCount !== ${process.argv[1]}`
);
' "$(git ls-tree -r HEAD | wc -l)" # '
    # update version in README.md, jslint.mjs, package.json from CHANGELOG.md
    if [ "$(git branch --show-current)" = alpha ]
    then
        node --input-type=module --eval '
import moduleFs from "fs";
(async function () {
    let fileDict = {};
    let fileMain;
    let fileModified;
    let packageJson;
    let versionBeta;
    let versionMaster;
    await Promise.all([
        "CHANGELOG.md",
        "README.md",
        "package.json"
    ].map(async function (file) {
        fileDict[file] = await moduleFs.promises.readFile(file, "utf8");
        if (file === "package.json") {
            packageJson = JSON.parse(fileDict[file]);
            fileMain = packageJson.module || packageJson.main || "package.json";
            fileDict[fileMain] = (
                await moduleFs.promises.readFile(fileMain, "utf8")
            );
        }
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
            file: "README.md",
            src: fileDict["README.md"].replace((
                /\bv\d\d\d\d\.\d\d?\.\d\d?\b/m
            ), `v${versionMaster}`)
        }, {
            file: "package.json",
            src: fileDict["package.json"].replace((
                /    "version": "\d\d\d\d\.\d\d?\.\d\d?(?:-.*?)?"/
            ), `    "version": "${versionBeta}"`)
        }, {
            file: fileMain,
            // update version
            src: fileDict[fileMain].replace((
                /^let version = ".*?";$/m
            ), `let version = "v${versionBeta}";`)
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
    # update table-of-contents in README.md
    node --input-type=module --eval '
import moduleFs from "fs";
(async function () {
    let data = await moduleFs.promises.readFile("README.md", "utf8");
    data = data.replace((
        /\n# Table of Contents$[\S\s]*?\n\n\n/m
    ), function () {
        let ii = -1;
        let toc = "\n# Table of Contents\n";
        data.replace((
            /((?:\n{3,}|\n+?(?:<br>)+?\n+?)(?:#|###|#####)) (\S.*)/g
        ), function (match0, level, title) {
            if (title === "Table of Contents") {
                ii += 1;
                return "";
            }
            if (ii < 0) {
                return "";
            }
            switch (level) {
            case "\n\n<br>\n\n#####":
                toc += "        - [" + title + "](#";
                break;
            case "\n\n\n<br><br>\n#":
                ii += 1;
                toc += "\n" + ii + ". [" + title + "](#";
                break;
            case "\n\n\n<br><br>\n###":
                toc += "    - [" + title + "](#";
                break;
            default:
                throw new Error(JSON.stringify(match0));
            }
            toc += title.toLowerCase().replace((
                /[^ \-0-9A-Z_a-z]/g
            ), "").replace((
                / /g
            ), "-") + ")\n";
            return "";
        });
        toc += "\n\n";
        return toc;
    });
    await moduleFs.promises.writeFile("README.md", data);
}());
' "$@" # '
    JSLINT_BETA=1 node jslint.mjs .
    if (command -v shCiLintCustom >/dev/null)
    then
        shCiLintCustom
    fi
    if (command -v shCiLintCustom2 >/dev/null)
    then
        shCiLintCustom2
    fi
    if (command -v shCiBaseCustom >/dev/null)
    then
        shCiBaseCustom
    fi
    if (command -v shCiBaseCustom2 >/dev/null)
    then
        shCiBaseCustom2
    fi
    git diff
)}

shCiMatrixIsmainName() {(set -e
# this function will return 0 if current ci-job is main job
    CI_MATRIX_NAME="$(printf "$CI_MATRIX_NAME" | xargs)"
    [ "$CI_MATRIX_NAME" ] && [ "$CI_MATRIX_NAME" = "$CI_MATRIX_NAME_MAIN" ]
)}

shCiMatrixIsmainNodeversion() {(set -e
# this function will return 0 if current ci-job is main job
    [ "$CI_MATRIX_NODE_VERSION" ] \
        && [ "$CI_MATRIX_NODE_VERSION" = "$CI_MATRIX_NODE_VERSION_MAIN" ]
)}

shCiNpmPublish() {(set -e
# this function will npm-publish package
# shCiNpmPublishCustom() {(set -e
# # this function will run custom-code to npm-publish package
#     # npm publish --access public
# )}
    if ! ([ -f package.json ] \
        && grep -q '^    "shCiNpmPublish": 1,$' package.json)
    then
        return
    fi
    # init package.json for npm-publish
    npm install
    # update package-name
    if [ "$NPM_REGISTRY" = github ]
    then
        sed -i \
            "s|^    \"name\":.*|    \"name\": \"@$GITHUB_REPOSITORY\",|" \
            package.json
    fi
    if (command -v shCiNpmPublishCustom >/dev/null)
    then
        shCiNpmPublishCustom
    fi
)}

shCiPre() {(set -e
# this function will run pre-ci
# shCiPreCustom() {(set -e
# # this function will run custom-code for pre-ci
#     return
# )}
    if [ -f ./myci2.sh ]
    then
        . ./myci2.sh :
        shMyciInit
    fi
    if (command -v shCiPreCustom >/dev/null)
    then
        shCiPreCustom
    fi
    if (command -v shCiPreCustom2 >/dev/null)
    then
        shCiPreCustom2
    fi
)}

shCurlExe() {(set -e
# this function will print to stdout "curl.exe", if it exists, else "curl"
    if [ -f c:/windows/system32/curl.exe ]
    then
        printf c:/windows/system32/curl.exe
        return
    fi
    printf curl
)}

shDirHttplinkValidate() {(set -e
# this function will validate http-links embedded in .html and .md files
    # init $GITHUB_BRANCH0
    export GITHUB_BRANCH0="${GITHUB_BRANCH0:-alpha}"
    # init $UPSTREAM_XXX
    export UPSTREAM_REPOSITORY="$(node -p '(
    /^https:\/\/github\.com\/([^\/]*?\/[^.]*?)\.git$/
).exec(require("./package.json").repository.url)[1]
')" # '
    export UPSTREAM_GITHUB_IO="$(
        printf "$UPSTREAM_REPOSITORY" | sed -e "s|/|.github.io/|"
    )"
    # init $GITHUB_XXX
    export GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-$UPSTREAM_REPOSITORY}"
    export GITHUB_GITHUB_IO="$(
        printf "$GITHUB_REPOSITORY" | sed -e "s|/|.github.io/|"
    )"
    node --input-type=module --eval '
import moduleAssert from "assert";
import moduleFs from "fs";
import moduleHttps from "https";
import moduleUrl from "url";
(async function () {
    let {
        GITHUB_BRANCH0,
        GITHUB_GITHUB_IO,
        GITHUB_REPOSITORY,
        UPSTREAM_GITHUB_IO,
        UPSTREAM_REPOSITORY
    } = process.env;
    let dict = {};
    Array.from(
        await moduleFs.promises.readdir(".")
    ).forEach(async function (file) {
        let data;
        if (file === "CHANGELOG.md" || !(
            /.\.html$|.\.md$/m
        ).test(file)) {
            return;
        }
        data = await moduleFs.promises.readFile(file, "utf8");
        // ignore link-rel-preconnect
        data = data.replace((
            /<link\b.*?\brel="preconnect".*?>/g
        ), "");
        data.replace((
            /\bhttps?:\/\/.*?(?:[\s")\]]|\W?$)/gm
        ), function (url) {
            let req;
            url = url.slice(0, -1).replace((
                /[\u0022\u0027]/g
            ), "").replace((
                /\/branch-[a-z]*?\//g
            ), `/branch-${GITHUB_BRANCH0}/`).replace(new RegExp(
                `\\b${UPSTREAM_REPOSITORY}\\b`,
                "g"
            ), GITHUB_REPOSITORY).replace(new RegExp(
                `\\b${UPSTREAM_GITHUB_IO}\\b`,
                "g"
            ), GITHUB_GITHUB_IO);
            if ((
                /^http:\/\/(?:127\.0\.0\.1|localhost|www\.w3\.org\/2000\/svg)(?:[\/:]|$)/m
            ).test(url)) {
                return "";
            }
            moduleAssert.ok(
                !url.startsWith("http://"),
                `shDirHttplinkValidate - ${file} - insecure link - ${url}`
            );
            // ignore duplicate-link
            if (dict.hasOwnProperty(url)) {
                return "";
            }
            dict[url] = true;
            req = moduleHttps.request(moduleUrl.parse(
                url
            ), function (res) {
                console.error(
                    "shDirHttplinkValidate " + res.statusCode + " " + url
                );
                moduleAssert.ok(
                    res.statusCode < 400,
                    `shDirHttplinkValidate - ${file} - unreachable url ${url}`
                );
                req.abort();
                res.destroy();
            });
            req.setTimeout(30000);
            req.end();
            return "";
        });
        data.replace((
            /(\bhref=|\bsrc=|\burl\(|\[[^]*?\]\()("?.*?)(?:[")\]]|$)/gm
        ), function (ignore, linkType, url) {
            if (!linkType.startsWith("[")) {
                url = url.slice(1);
            }
            if ((
                /^$|^\\|^data:/m
            ).test(url)) {
                return "";
            }
            // ignore duplicate-link
            if (dict.hasOwnProperty(url)) {
                return "";
            }
            dict[url] = true;
            if (!(
                /^https?|^mailto:|^[#\/]/m
            ).test(url)) {
                moduleFs.stat(url.split("?")[0], function (ignore, exists) {
                    console.error(
                        "shDirHttplinkValidate " + Boolean(exists) + " " + url
                    );
                    moduleAssert.ok(
                        exists,
                        (
                            `shDirHttplinkValidate - ${file}`
                            + `- unreachable file ${url}`
                        )
                    );
                });
            }
            return "";
        });
    });
}());
' "$@" # '
)}

shDuList() {(set -e
# this function will du $1 and sort its subdir by size
    du -md1 "$1" | sort -nr
)}

shGitCmdWithGithubToken() {(set -e
# this function will run git $CMD with $MY_GITHUB_TOKEN
    printf "shGitCmdWithGithubToken $*\n"
    if [ -f .git/config ]
    then
        # security - scrub token from url
        sed -i.bak "s|://.*@|://|g" .git/config
        rm -f .git/config.bak
    fi
    local CMD="$1"
    case "$CMD" in
    clone)
        ;;
    ls-remote)
        ;;
    *)
        if [ ! "$MY_GITHUB_TOKEN" ]
        then
            git "$@"
            return
        fi
        ;;
    esac
    shift
    URL="$1"
    shift
    if (printf "$URL" | grep -qv "^https://")
    then
        URL="$(git config "remote.$URL.url")"
    fi
    if [ "$MY_GITHUB_TOKEN" ]
    then
        URL="$(
            printf "$URL" \
            | sed -e "s|https://|https://x-access-token:$MY_GITHUB_TOKEN@|"
        )"
    fi
    EXIT_CODE=0
    # hide $MY_GITHUB_TOKEN in case of err
    git "$CMD" "$URL" "$@" 2>/dev/null || EXIT_CODE="$?"
    printf "shGitCmdWithGithubToken - EXIT_CODE=$EXIT_CODE\n" 1>&2
    return "$EXIT_CODE"
)}

shGitCommitPushOrSquash() {(set -e
# this function will, if $COMMIT_COUNT > $COMMIT_LIMIT,
# then backup, squash, force-push,
# else normal-push
    BRANCH="$(git branch --show-current)"
    COMMIT_MESSAGE="${1:-$(git diff HEAD --stat)}"
    COMMIT_LIMIT="$2"
    MODE_NOBACKUP="$3"
    MODE_FORCE="$4"
    git commit -am "$COMMIT_MESSAGE" || true
    COMMIT_COUNT="$(git rev-list --count HEAD)"
    if (! [ "$COMMIT_COUNT" -gt "$COMMIT_LIMIT" ] &>/dev/null)
    then
        if [ "$MODE_FORCE" = force ]
        then
            shGitCmdWithGithubToken push origin "$BRANCH" -f
        else
            shGitCmdWithGithubToken push origin "$BRANCH"
        fi
        return
    fi
    # backup
    if [ "$MODE_NOBACKUP" != nobackup ]
    then
        shGitCmdWithGithubToken push origin \
            "$BRANCH:$BRANCH.backup_wday$(date -u +%w)" -f
    fi
    # squash commits
    COMMIT_MESSAGE="[squashed $COMMIT_COUNT commits] $COMMIT_MESSAGE"
    git branch -D __tmp1 &>/dev/null || true
    git checkout --orphan __tmp1
    git commit --quiet -am "$COMMIT_MESSAGE" || true
    # reset branch to squashed-commit
    git push . "__tmp1:$BRANCH" -f
    git checkout "$BRANCH"
    # force-push squashed-commit
    shGitCmdWithGithubToken push origin "$BRANCH" -f
)}

shGitGc() {(set -e
# this function will gc unreachable .git objects
# http://stackoverflow.com/questions/3797907/how-to-remove-unused-objects-from-a-git-repository
    git \
        -c gc.reflogExpire=0 \
        -c gc.reflogExpireUnreachable=0 \
        -c gc.rerereresolved=0 \
        -c gc.rerereunresolved=0 \
        -c gc.pruneExpire=now \
        gc
)}

shGitInitBase() {(set -e
# this function will git init && create basic git-template from jslint-org/base
    local BRANCH
    git init
    git config core.autocrlf input
    git remote remove base 2>/dev/null || true
    git remote add base https://github.com/jslint-org/base
    git fetch base base
    for BRANCH in base alpha
    do
        git branch -D "$BRANCH" 2>/dev/null || true
        git checkout -b "$BRANCH" base/base
    done
    sed -i.bak "s|owner/repo|${1:-owner/repo}|" .gitconfig
    rm -f .gitconfig.bak
    cp .gitconfig .git/config
    git commit -am "update owner/repo to $1" || true
)}

shGitLsTree() {(set -e
# this function will "git ls-tree" all files committed in HEAD
# example use:
# shGitLsTree | sort -rk3 # sort by date
# shGitLsTree | sort -rk4 # sort by size
    node --input-type=module --eval '
import moduleChildProcess from "child_process";
(async function () {
    let result;
    // get file, mode, size
    result = await new Promise(function (resolve) {
        result = "";
        moduleChildProcess.spawn(
            "git",
            ["ls-tree", "-lr", "HEAD"],
            {stdio: ["ignore", "overlapped", 2]}
        ).on("exit", function () {
            resolve(result);
        }).stdout.on("data", function (chunk) {
            result += chunk;
        }).setEncoding("utf8");
    });
    result = Array.from(result.matchAll(
        /^(\S+?) +?\S+? +?\S+? +?(\S+?)\t(\S+?)$/gm
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
        moduleChildProcess.spawn(
            "git",
            ["log", "--max-count=1", "--format=%at", elem.file],
            {stdio: ["ignore", "overlapped", 2]}
        ).stdout.on("data", function (chunk) {
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
                String(ii + ".").padStart(iiPad, " ")
                + "  " + elem.mode
                + "  " + elem.date
                + "  " + String(
                    Math.ceil(elem.size / 1024)
                ).padStart(sizePad, " ") + " KB"
                + "  " + elem.file
                + "\n"
            );
        }).join(""));
    });
}());
' "$@" # '
)}

shGitSquashPop() {(set -e
# this function will squash HEAD to given $COMMIT
# http://stackoverflow.com/questions/5189560
# /how-can-i-squash-my-last-x-commits-together-using-git
    COMMIT="$1"
    MESSAGE="$2"
    # reset git to previous $COMMIT
    git reset "$COMMIT"
    git add .
    # commit HEAD immediately after previous $COMMIT
    git commit -am "$MESSAGE" || true
)}

shGithubCheckoutRemote() {(set -e
# this function will run like actions/checkout, except checkout remote-branch
    # GITHUB_REF_NAME="owner/repo/branch"
    GITHUB_REF_NAME="$1"
    if (printf "$GITHUB_REF_NAME" | grep -q ".*/.*/.*")
    then
        # branch - */*/*
        git fetch origin alpha
        # assert latest ci
        if (git rev-parse "$GITHUB_REF_NAME" &>/dev/null) \
            && [ "$(git rev-parse "$GITHUB_REF_NAME")" \
            != "$(git rev-parse origin/alpha)" ]
        then
            git push -f origin "origin/alpha:$GITHUB_REF_NAME"
            shGithubWorkflowDispatch "$GITHUB_REPOSITORY" "$GITHUB_REF_NAME"
            return 1
        fi
    else
        # branch - alpha, beta, master
        GITHUB_REF_NAME="$GITHUB_REPOSITORY/$GITHUB_REF_NAME"
    fi
    GITHUB_REPOSITORY="$(printf "$GITHUB_REF_NAME" | cut -d'/' -f1,2)"
    GITHUB_REF_NAME="$(printf "$GITHUB_REF_NAME" | cut -d'/' -f3)"
    # replace current git-checkout with $GITHUB_REF_NAME
    rm -rf * ..?* .[!.]*
    shGitCmdWithGithubToken clone \
        "https://github.com/$GITHUB_REPOSITORY" __tmp1 \
        --branch="$GITHUB_REF_NAME" --depth=1 --single-branch
    mv __tmp1/.git .
    cp __tmp1/.gitconfig .git/config
    rm -rf __tmp1
    git reset "origin/$GITHUB_REF_NAME" --hard
    # fetch jslint_ci.sh from trusted source
    git branch -D __tmp1 &>/dev/null || true
    shGitCmdWithGithubToken fetch origin alpha:__tmp1 --depth=1
    for FILE in .ci.sh .ci2.sh jslint_ci.sh myci2.sh
    do
        if [ -f "$FILE" ]
        then
            git checkout __tmp1 "$FILE"
        fi
    done
)}

shGithubFileDownload() {(set -e
# this function will download file $1 from github repo/branch
# https://docs.github.com/en/rest/reference/repos#create-or-update-file-contents
# example use:
# shGithubFileDownload octocat/hello-world/master/hello.txt
    shGithubFileDownloadUpload download "$1" "$2"
)}

shGithubFileDownloadUpload() {(set -e
# this function will upload file $2 to github repo/branch $1
# https://docs.github.com/en/rest/reference/repos#create-or-update-file-contents
# example use:
# shGithubFileUpload octocat/hello-world/master/hello.txt hello.txt
    shGithubTokenExport
    node --input-type=module --eval '
import moduleAssert from "assert";
import moduleFs from "fs";
import moduleHttps from "https";
import modulePath from "path";
(async function () {
    let branch;
    let [mode, path, content] = process.argv.slice(1);
    let repo;
    let responseBuf;
    let url;
    function httpRequest({
        method,
        payload
    }) {
        return new Promise(function (resolve) {
            moduleHttps.request(`${url}?ref=${branch}`, {
                headers: {
                    accept: (
                        mode === "download"
                        ? "application/vnd.github.v3.raw"
                        : "application/vnd.github.v3+json"
                    ),
                    authorization: `Bearer ${process.env.MY_GITHUB_TOKEN}`,
                    "user-agent": "undefined"
                },
                method
            }, function (res) {
                responseBuf = [];
                res.on("data", function (chunk) {
                    responseBuf.push(chunk);
                });
                res.on("end", function () {
                    responseBuf = Buffer.concat(responseBuf);
                    moduleAssert.ok(
                        (
                            res.statusCode < 400
                            || (res.statusCode === 404 && mode === "upload")
                        ),
                        (
                            `shGithubFileUpload - ${res.statusCode}`
                            + ` - failed to download/upload file ${url} - `
                            + responseBuf.slice(0, 1024).toString()
                        )
                    );
                    resolve();
                });
            }).end(payload);
        });
    }
    console.error(
        mode === "download"
        ? `shGithubFileDownload - ${process.argv[1]}`
        : `shGithubFileUpload - ${process.argv[1]}`
    );
    path = path.split("/");
    repo = path.slice(0, 2).join("/");
    branch = path[2];
    path = path.slice(3).join("/");
    url = `https://api.github.com/repos/${repo}/contents/${path}`;
    await httpRequest({});
    if (mode === "download") {
        await moduleFs.promises.writeFile(
            content || modulePath.basename(url),
            responseBuf
        );
        return;
    }
    content = await moduleFs.promises.readFile(content);
    await httpRequest({
        method: "PUT",
        payload: JSON.stringify({
            branch,
            content: content.toString("base64"),
            "message": `upload file ${path}`,
            sha: JSON.parse(responseBuf).sha
        })
    });
    console.error(
        mode === "download"
        ? `shGithubFileDownload - done`
        : `shGithubFileUpload - done`
    );
}());
' "$@" # '
)}

shGithubFileUpload() {(set -e
# this function will upload file $2 to github repo/branch $1
# https://docs.github.com/en/rest/reference/repos#create-or-update-file-contents
# example use:
# shGithubFileUpload octocat/hello-world/master/hello.txt hello.txt
    shGithubFileDownloadUpload upload "$1" "$2"
)}

shGithubTokenExport() {
# this function will export $MY_GITHUB_TOKEN from file
    if [ ! "$MY_GITHUB_TOKEN" ]
    then
        export MY_GITHUB_TOKEN="$(cat ~/.mysecret2/.my_github_token)"
    fi
}

shGithubWorkflowDispatch() {(set -e
# this function will trigger github-workflow on given $REPO and $BRANCH
# example use:
# shGithubWorkflowDispatch octocat/hello-world master
    shGithubTokenExport
    REPO="$1"
    shift
    BRANCH="$1"
    shift
    EXIT_CODE=0
    "$(shCurlExe)" \
"https://api.github.com/repos/$REPO/actions/workflows/ci.yml/dispatches" \
        -H "accept: application/vnd.github.v3+json" \
        -H "authorization: Bearer $MY_GITHUB_TOKEN" \
        -X POST \
        -d '{"ref":"'"$BRANCH"'"}' \
        -s \
        "$@" || EXIT_CODE="$?"
    printf "shGithubWorkflowDispatch - EXIT_CODE=$EXIT_CODE\n" 1>&2
    return "$EXIT_CODE"
)}

shGrep() {(set -e
# this function will recursively grep . for $REGEXP
    REGEXP="$1"
    shift
    FILE_FILTER="\
/\\.|~$|/(obj|release)/|(\\b|_)(\\.\\d|\
archive|artifact|\
bower_component|build|\
coverage|\
doc|\
external|\
fixture|\
git_module|\
jquery|\
log|\
min|misc|mock|\
node_module|\
old|\
raw|\rollup|\
swp|\
tmp|\
vendor)s{0,1}(\\b|_)\
"
    find . -type f |
        grep -v -E "$FILE_FILTER" |
        tr "\n" "\000" |
        xargs -0 grep -HIin -E "$REGEXP" "$@" |
        tee /tmp/shGrep.txt || true
)}

shGrepReplace() {(set -e
# this function will inline grep-and-replace /tmp/shGrep.txt
    node --input-type=module --eval '
import moduleFs from "fs";
import moduleOs from "os";
import modulePath from "path";
(async function () {
    "use strict";
    let data;
    let dict = {};
    data = await moduleFs.promises.readFile((
        moduleOs.tmpdir() + "/shGrep.txt"
    ), "utf8");
    data = data.replace((
        /^(.+?):(\d+?):(.*?)$/gm
    ), function (ignore, file, lineno, str) {
        dict[file] = dict[file] || moduleFs.readFileSync( //jslint-ignore-line
            modulePath.resolve(file),
            "utf8"
        ).split("\n");
        dict[file][lineno - 1] = str;
        return "";
    });
    Object.entries(dict).forEach(function ([
        file, data
    ]) {
        moduleFs.promises.writeFile(file, data.join("\n"));
    });
}());
' "$@" # '
)}

shHttpFileServer() {(set -e
# this function will run simple node http-file-server on port $PORT
    if [ ! "$npm_config_mode_auto_restart" ]
    then
        local EXIT_CODE
        EXIT_CODE=0
        export npm_config_mode_auto_restart=1
        while true
        do
            printf "\n"
            git diff --color 2>/dev/null | cat || true
            printf "\nshHttpFileServer - (re)starting $*\n"
            (shHttpFileServer "$@") || EXIT_CODE="$?"
            printf "process exited with code $EXIT_CODE\n"
            # if $EXIT_CODE != 77, then exit process
            # http://en.wikipedia.org/wiki/Unix_signal
            if [ "$EXIT_CODE" != 77 ]
            then
                break
            fi
            # else restart process after 1 second
            sleep 1
        done
        return
    fi
    node --input-type=module --eval '
import moduleChildProcess from "child_process";
import moduleFs from "fs";
import moduleHttp from "http";
import modulePath from "path";
import moduleRepl from "repl";
import moduleUrl from "url";
// init debugInline
(function () {
    let consoleError = console.error;
    globalThis.debugInline = globalThis.debugInline || function (...argList) {

// this function will both print <argList> to stderr and return <argList>[0]

        consoleError("\n\ndebugInline");
        consoleError(...argList);
        consoleError("\n");
        return argList[0];
    };
}());
(async function httpFileServer() {

// this function will start http-file-server

    let contentTypeDict = {
        ".bmp": "image/bmp",
        ".cjs": "application/javascript; charset=utf-8",
        ".css": "text/css; charset=utf-8",
        ".gif": "image/gif",
        ".htm": "text/html; charset=utf-8",
        ".html": "text/html; charset=utf-8",
        ".jpe": "image/jpeg",
        ".jpeg": "image/jpeg",
        ".jpg": "image/jpeg",
        ".js": "application/javascript; charset=utf-8",
        ".json": "application/json; charset=utf-8",
        ".md": "text/markdown; charset=utf-8",
        ".mjs": "application/javascript; charset=utf-8",
        ".pdf": "application/pdf",
        ".png": "image/png",
        ".svg": "image/svg+xml; charset=utf-8",
        ".txt": "text/plain; charset=utf-8",
        ".wasm": "application/wasm",
        ".woff": "font/woff",
        ".woff2": "font/woff2",
        ".xml": "application/xml; charset=utf-8",
        "/": "text/html; charset=utf-8"
    };
    // exit after given timeout
    if (process.env.npm_config_timeout_exit) {
        setTimeout(
            process.exit,
            process.env.npm_config_timeout_exit
        );
    }
    if (process.argv[1]) {
        await import("file://" + modulePath.resolve(process.argv[1]));
    }
    process.env.PORT = process.env.PORT || "8080";
    console.error("http-file-server listening on port " + process.env.PORT);
    moduleHttp.createServer(function (req, res) {
        let file;
        let pathname;
        let timeStart;
        // init timeStart
        timeStart = Date.now();
        // init pathname
        pathname = moduleUrl.parse(req.url).pathname;
        // debug - serverLog
        res.on("close", function () {
            if (pathname === "/favicon.ico") {
                return;
            }
            console.error(
                "serverLog - "
                + new Date(timeStart).toISOString() + " - "
                + (Date.now() - timeStart) + "ms - "
                + (res.statusCode || 0) + " " + req.method + " " + pathname
            );
        });
        // debug - echo request
        if (pathname === "/echo") {
            res.write(JSON.stringify(req.headers, undefined, 4) + "\n");
            req.pipe(res);
            return;
        }
        // replace trailing "/" with "/index.html"
        file = pathname.slice(1).replace((
            /\/$/
        ), "/index.html");
        // resolve file
        file = modulePath.resolve(file);
        // security - disable parent-directory lookup
        if (!file.startsWith(process.cwd() + modulePath.sep)) {
            res.statusCode = 404;
            res.end();
            return;
        }
        moduleFs.readFile(file, function (err, data) {
            let contentType;
            if (err) {
                res.statusCode = 404;
                res.end();
                return;
            }
            contentType = contentTypeDict[(
                /^\/$|\.[^.]*?$|$/m
            ).exec(file)[0]];
            if (contentType) {
                res.setHeader("content-type", contentType);
            }
            res.end(data);
        });
    }).listen(process.env.PORT);
}());
(function jslintDir() {

// this function will jslint current-directory

    moduleFs.stat((
        process.env.HOME + "/jslint.mjs"
    ), function (ignore, exists) {
        if (exists) {
            moduleChildProcess.spawn(
                "node",
                [process.env.HOME + "/jslint.mjs", "."],
                {stdio: ["ignore", 1, 2]}
            );
        }
    });
}());
(function replStart() {

// this function will start repl-debugger

    let that;
    // start repl
    that = moduleRepl.start({
        useGlobal: true
    });
    // init history
    that.setupHistory(modulePath.resolve(
        process.env.HOME + "/.node_repl_history"
    ), function () {
        return;
    });
    // save eval-function
    that.evalDefault = that.eval;
    // hook custom-eval-function
    that.eval = function (script, context, file, onError) {
        script.replace((
            /^(\S+) (.*?)\n/
        ), function (ignore, match1, match2) {
            switch (match1) {
            // syntax-sugar - run shell-cmd
            case "$":
                switch (match2.split(" ").slice(0, 2).join(" ")) {
                // syntax-sugar - run git diff
                case "git diff":
                    match2 += " --color";
                    break;
                // syntax-sugar - run git log
                case "git log":
                    match2 += " -n 10";
                    break;
                // syntax-sugar - run ll
                case "ll":
                    match2 = "ls -Fal";
                    break;
                }
                match2 = match2.replace((
                    /^git /
                ), "git --no-pager ");
                // run shell-cmd
                console.error("$ " + match2);
                moduleChildProcess.spawn(
                    "sh",
                    ["-c", match2],
                    {stdio: ["ignore", 1, 2]}
                ).on("exit", function (exitCode) {
                    // print exitCode
                    console.error("$ EXIT_CODE=" + exitCode);
                    that.evalDefault("\n", context, file, onError);
                });
                script = "\n";
                break;
            // syntax-sugar - map text with charCodeAt
            case "charCode":
                console.error(
                    match2.split("").map(function (chr) {
                        return (
                            "\\u"
                            + chr.charCodeAt(0).toString(16).padStart(4, 0)
                        );
                    }).join("")
                );
                script = "\n";
                break;
            // syntax-sugar - sort chr
            case "charSort":
                console.error(JSON.stringify(match2.split("").sort().join("")));
                script = "\n";
                break;
            // syntax-sugar - list obj-keys, sorted by item-type
            // console.error(Object.keys(global).map(function(key){return(typeof global[key]===\u0027object\u0027&&global[key]&&global[key]===global[key]?\u0027global\u0027:typeof global[key])+\u0027 \u0027+key;}).sort().join(\u0027\n\u0027)) //jslint-ignore-line
            case "keys":
                script = (
                    "console.error(Object.keys(" + match2
                    + ").map(function(key){return("
                    + "typeof " + match2 + "[key]===\u0027object\u0027&&"
                    + match2 + "[key]&&"
                    + match2 + "[key]===global[key]"
                    + "?\u0027global\u0027"
                    + ":typeof " + match2 + "[key]"
                    + ")+\u0027 \u0027+key;"
                    + "}).sort().join(\u0027\\n\u0027))\n"
                );
                break;
            // syntax-sugar - print String(val)
            case "print":
                script = "console.error(String(" + match2 + "))\n";
                break;
            }
        });
        // eval script
        that.evalDefault(script, context, file, onError);
    };
}());
(function watchDir() {

// this function will watch current-directory for changes

    moduleFs.readdir(".", function (ignore, fileList) {
        fileList.forEach(function (file) {
            if (file[0] === ".") {
                return;
            }
            moduleFs.stat(file, function (ignore, stats) {
                if (!(stats && stats.isFile())) {
                    return;
                }
                moduleFs.watchFile(file, {
                    interval: 1000,
                    persistent: false
                }, function () {
                    console.error("watchFile - modified - " + file);
                    setTimeout(process.exit.bind(undefined, 77), 1000);
                });
            });
        });
    });
}());
' "$@" # '
)}

shImageLogoCreate() {(set -e
# this function will create .png logo
    if [ ! -f asset_image_logo_512.html ]
    then
        return
    fi
    # screenshot asset_image_logo_512.png
    shBrowserScreenshot asset_image_logo_512.html \
        --window-size=512x512 \
        -screenshot=.artifact/asset_image_logo_512.png
    # create various smaller thumbnails
    local SIZE
    for SIZE in 32 64 128 256
    do
        convert -resize "${SIZE}x${SIZE}" .artifact/asset_image_logo_512.png \
            ".artifact/asset_image_logo_$SIZE.png"
        printf \
"shImageLogoCreate - wrote - .artifact/asset_image_logo_$SIZE.png\n" 1>&2
    done
    # convert to svg @ https://convertio.co/png-svg/
)}

shImageToDataUri() {(set -e
# this function will convert image $1 to data-uri string
    node --input-type=module --eval '
import moduleFs from "fs";
import moduleHttps from "https";
(async function () {
    let file;
    let result;
    file = process.argv[1];
    if ((
        /^https:\/\//
    ).test(file)) {
        result = await new Promise(function (resolve) {
            moduleHttps.get(file, function (res) {
                let chunkList;
                chunkList = [];
                res.on("data", function (chunk) {
                    chunkList.push(chunk);
                }).on("end", function () {
                    resolve(Buffer.concat(chunkList));
                });
            });
        });
    } else {
        result = await moduleFs.promises.readFile(file);
    }
    result = String(
        "data:image/" + file.match(
            /\.[^.]*?$|$/m
        )[0].slice(1) + ";base64," + result.toString("base64")
    ).replace((
        /.{72}/g
    ), "$&\\\n");
    console.log(result);
}());
' "$@" # '
)}

shJsonNormalize() {(set -e
# this function will
# 1. read json-data from file $1
# 2. normalize json-data
# 3. write normalized json-data back to file $1
    node --input-type=module --eval '
import moduleFs from "fs";
function noop(val) {

// This function will do nothing except return <val>.

    return val;
}
function objectDeepCopyWithKeysSorted(obj) {

// This function will recursively deep-copy <obj> with keys sorted.

    let sorted;
    if (typeof obj !== "object" || !obj) {
        return obj;
    }

// Recursively deep-copy list with child-keys sorted.

    if (Array.isArray(obj)) {
        return obj.map(objectDeepCopyWithKeysSorted);
    }

// Recursively deep-copy obj with keys sorted.

    sorted = {};
    Object.keys(obj).sort().forEach(function (key) {
        sorted[key] = objectDeepCopyWithKeysSorted(obj[key]);
    });
    return sorted;
}
(async function () {
    console.error("shJsonNormalize - " + process.argv[1]);
    await moduleFs.promises.writeFile(
        process.argv[1],
        JSON.stringify(
            objectDeepCopyWithKeysSorted(
                JSON.parse(
                    noop(
                        await moduleFs.promises.readFile(
                            process.argv[1],
                            "utf8"
                        )
                    ).replace((
                        /^\ufeff/
                    ), "")
                )
            ),
            undefined,
            Number(process.argv[2]) || 4
        ) + "\n"
    );
}());
' "$@" # '
)}

shNpmPublishV0() {(set -e
# this function will npm-publish name $1 with bare package.json
    local DIR
    DIR=/tmp/shNpmPublishV0
    rm -rf "$DIR" && mkdir -p "$DIR" && cd "$DIR"
    printf "{\"name\":\"$1\",\"version\":\"0.0.1\"}\n" > package.json
    shift
    npm publish "$@"
)}

shPidListWait() {
# this will wait for all process-pid in $PID_LIST to exit
    local EXIT_CODE=0
    local PID_LIST="$2"
    local TASK="$1"
    for PID in $PID_LIST
    do
        printf "$TASK - pid=$PID ...\n"
        wait "$PID" || EXIT_CODE="$?"
        printf "$TASK - pid=$PID EXIT_CODE=$EXIT_CODE\n"
    done
    printf "$TASK - pid=done EXIT_CODE=$EXIT_CODE\n\n\n\n"
    return "$EXIT_CODE"
}

shRmDsStore() {(set -e
# this function will recursively rm .DS_Store from current-dir
# http://stackoverflow.com/questions/2016844/bash-recursively-remove-files
    local NAME
    for NAME in "._*" ".DS_Store" "desktop.ini" "npm-debug.log" "*~"
    do
        find . -iname "$NAME" -print0 | xargs -0 rm -f || true
    done
)}

shRollupFetch() {(set -e
# this function will fetch raw-lib from $1
    node --input-type=module --eval '
import moduleChildProcess from "child_process";
import moduleFs from "fs";
import moduleHttps from "https";
import modulePath from "path";
// init debugInline
(function () {
    let consoleError = console.error;
    globalThis.debugInline = globalThis.debugInline || function (...argList) {

// this function will both print <argList> to stderr and return <argList>[0]

        consoleError("\n\ndebugInline");
        consoleError(...argList);
        consoleError("\n");
        return argList[0];
    };
}());
function objectDeepCopyWithKeysSorted(obj) {

// This function will recursively deep-copy <obj> with keys sorted.

    let sorted;
    if (typeof obj !== "object" || !obj) {
        return obj;
    }

// Recursively deep-copy list with child-keys sorted.

    if (Array.isArray(obj)) {
        return obj.map(objectDeepCopyWithKeysSorted);
    }

// Recursively deep-copy obj with keys sorted.

    sorted = {};
    Object.keys(obj).sort().forEach(function (key) {
        sorted[key] = objectDeepCopyWithKeysSorted(obj[key]);
    });
    return sorted;
}
function replaceListReplace(replaceList, data) {
    // replaceList - normalize regexp
    replaceList.forEach(function (elem) {
        ["aa", "substr"].forEach(function (key) {
            elem[key] = (
                elem[key]
                ? new RegExp(elem[key]).source
                : ""
            );
        });
    });
    // replaceList - sort
    replaceList.sort(function (aa, bb) {
        return (
            (aa.substr !== bb.substr)
            ? 0.5 - Boolean(aa.substr < bb.substr)
            : (aa.aa !== bb.aa)
            ? 0.5 - Boolean(aa.aa < bb.aa)
            : 0.5 - Boolean(aa.bb < bb.bb)
        );
    });
    // replaceList - replace
    replaceList.forEach(function ({
        aa,
        bb,
        flags,
        substr
    }) {
        let data0 = data;
        data = data.replace(new RegExp(
            substr || "[\\S\\s]*"
        ), function (match0) {
            return match0.replace(
                new RegExp(aa, flags),
                bb.replace((
                    /\*\\\\\//g
                ), "*/").replace((
                    /\/\\\\\*/g
                ), "/*")
            );
        });
        if (data0 === data) {
            throw new Error(
                "shRollupFetch - cannot find-and-replace snippet "
                + JSON.stringify(aa)
            );
        }
    });
    return data;
}
(async function () {
    let fetchCount = 0;
    let fetchList;
    let matchObj;
    let repoDict;
    function pipeToBuffer(res, dict, key) {

// This function will concat data from <res> to <dict>[<key>].

        let data;
        data = [];
        res.on("data", function (chunk) {
            data.push(chunk);
        }).on("end", function () {
            dict[key] = Buffer.concat(data);
        });
    }
    // init matchObj
    matchObj = (
        /^\/\*jslint-disable\*\/\n\/\*\nshRollupFetch\n(\{\n[\S\s]*?\n\})([\S\s]*?)\n\*\/\n/m
    ).exec(await moduleFs.promises.readFile(process.argv[1], "utf8"));
    // JSON.parse match1 with comment
    matchObj[1] = Object.assign({
        fetchList: [],
        replaceList: []
    }, JSON.parse(matchObj[1]));
    fetchList = JSON.parse(JSON.stringify(matchObj[1].fetchList));
    // init repoDict, fetchList
    repoDict = {};
    fetchList.forEach(async function (elem) {
        if (!elem.url) {
            return;
        }
        elem.prefix = elem.url.split("/").slice(0, 7).join("/");
        // fetch dateCommitted
        if (!repoDict.hasOwnProperty(elem.prefix)) {
            repoDict[elem.prefix] = true;
            moduleHttps.request(elem.prefix.replace(
                "/blob/",
                "/commits/"
            ), function (res) {
                pipeToBuffer(res, elem, "dateCommitted");
            }).end();
        }
        // fetch file
        if (elem.node) {
            pipeToBuffer(moduleChildProcess.spawn(
                "node",
                ["-e", elem.node],
                {stdio: ["ignore", "overlapped", 2]}
            ).stdout, elem, "data");
            return;
        }
        if (elem.sh) {
            pipeToBuffer(moduleChildProcess.spawn(
                "sh",
                ["-c", elem.sh],
                {stdio: ["ignore", "overlapped", 2]}
            ).stdout, elem, "data");
            return;
        }
        fetchCount += 1;
        await new Promise(function (resolve) {
            setTimeout(resolve, fetchCount * 50);
        });
        moduleHttps.get(elem.url2 || elem.url.replace(
            "https://github.com/",
            "https://raw.githubusercontent.com/"
        ).replace("/blob/", "/"), function (res) {
            fetchCount -= 1;
            console.error(`shRollupFetch - ${fetchCount} remaining fetches`);
            // http-redirect
            if (res.statusCode === 302) {
                moduleHttps.get(res.headers.location, function (res) {
                    pipeToBuffer(res, elem, "data");
                });
                return;
            }
            pipeToBuffer(res, elem, "data");
        });
    });
    // parse fetched data
    process.on("exit", function () {
        let header;
        let result;
        let result0;
        result = "";
        fetchList.forEach(function ({
            comment,
            data,
            dataUriType,
            dateCommitted,
            footer = "",
            header = "",
            prefix,
            replaceList = [],
            url
        }, ii, list) {
            if (!url) {
                return;
            }
            list[ii].exports = (
                (
                    "exports_" + modulePath.dirname(url).replace(
                        "https://github.com/",
                        ""
                    ).replace((
                        /\/blob\/[^\/]*/
                    ), "/").replace((
                        /\W/g
                    ), "_").replace((
                        /(_)_+|_+$/g
                    ), "$1")
                )
                + "_"
                + (
                    modulePath.basename(
                        url
                    ).replace((
                        /\.js$/
                    ), "").replace((
                        /\W/g
                    ), "_")
                )
            );
            if (dataUriType) {
                return;
            }
            if (dateCommitted) {
                result += (
                    "\n\n\n/*\n"
                    + "repo " + prefix.replace("/blob/", "/tree/") + "\n"
                    + "committed " + (
                        /\b\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\dZ\b|$/
                    ).exec(dateCommitted.toString())[0] + "\n"
                    + "*/"
                );
            }
            data = data.toString();
            // comment /*...*/
            if (comment) {
                data = "/*\n" + data.trim().replace((
                    /\/\*/g
                ), "/\\*").replace((
                    /\*\//g
                ), "*\\/") + "\n*/";
            }
            data = replaceListReplace(replaceList, data);
            // init header and footer
            result += (
                "\n\n\n/*\nfile " + url + "\n*/\n"
                + header
                + data.trim()
                + footer
            );
        });
        result = (
            "\n" + result.trim()
            + "\n\n\n/*\nfile none\n*/\n/*jslint-enable*/\n"
        );
        // comment #!
        result = result.replace((
            /^#!/gm
        ), "// $&");
        // normalize newline
        result = result.replace((
            /\r\n|\r/g
        ), "\n");
        // remove trailing-whitespace
        result = result.replace((
            /[\t ]+$/gm
        ), "");
        // remove leading-newline before ket
        result = result.replace((
            /\n+?(\n *?\})/g
        ), "$1");
        // eslint - no-multiple-empty-lines
        // https://github.com/eslint/eslint/blob/v7.2.0/docs/rules/no-multiple-empty-lines.md //jslint-ignore-line
        result = result.replace((
            /\n{4,}/g
        ), "\n\n\n");
        // replace from replaceList
        result = replaceListReplace(matchObj[1].replaceList, result);
        // init header
        header = (
            matchObj.input.slice(0, matchObj.index)
            + "/*jslint-disable*/\n/*\nshRollupFetch\n"
            + JSON.stringify(
                objectDeepCopyWithKeysSorted(matchObj[1]),
                undefined,
                4
            ) + "\n"
            + matchObj[2].split("\n\n").filter(function (elem) {
                return elem.trim();
            }).map(function (elem) {
                return elem.trim().replace((
                    /\*\//g
                ), "*\\\\/").replace((
                    /\/\*/g
                ), "/\\\\*") + "\n";
            }).sort().join("\n") + "*/\n\n"
        );
        // replace from header-diff
        header.replace((
            /((?:^-.*?\n)+?)((?:^\+.*?\n)+)/gm
        ), function (ignore, aa, bb) {
            aa = "\n" + aa.replace((
                /^-/gm
            ), "").replace((
                /\*\\\\\//g
            ), "*/").replace((
                /\/\\\\\*/g
            ), "/*");
            bb = "\n" + bb.replace((
                /^\+/gm
            ), "").replace((
                /\*\\\\\//g
            ), "*/").replace((
                /\/\\\\\*/g
            ), "/*");
            result0 = result;
            // disable $-escape in replacement-string
            result = result.replace(aa, function () {
                return bb;
            });
            if (result0 === result) {
                throw new Error(
                    "shRollupFetch - cannot find-and-replace snippet "
                    + JSON.stringify(aa)
                );
            }
            return "";
        });
        // inline dataUri
        fetchList.forEach(function ({
            data,
            dataUriType,
            exports
        }) {
            if (!dataUriType) {
                return;
            }
            data = (
                "data:" + dataUriType + ";base64,"
                + data.toString("base64")
            );
            result0 = result;
            result = result.replace(
                new RegExp("^" + exports + "$", "gm"),
                // disable $-escape in replacement-string
                function () {
                    return data;
                }
            );
            if (result0 === result) {
                throw new Error(
                    "shRollupFetch - cannot find-and-replace snippet "
                    + JSON.stringify(exports)
                );
            }
        });
        // init footer
        result = header + result;
        matchObj.input.replace((
            /\n\/\*\nfile none\n\*\/\n\/\*jslint-enable\*\/\n([\S\s]+)/
        ), function (ignore, match1) {
            result += "\n\n" + match1.trim() + "\n";
        });
        // write to file
        moduleFs.writeFileSync(process.argv[1], result); //jslint-ignore-line
    });
}());
' "$@" # '
    git diff
)}

shRunWithCoverage() {(set -e
# this function will run nodejs command $@ with v8-coverage
# and create coverage-report .artifact/coverage/index.html
    node --input-type=module --eval '
/*jslint indent2*/
let moduleChildProcess;
let moduleFs;
let moduleFsInitResolveList;
let modulePath;
let moduleUrl;
function assertOrThrow(condition, message) {
  if (!condition) {
    throw (
      (!message || typeof message === "string")
      ? new Error(String(message).slice(0, 2048))
      : message
    );
  }
}
async function fsWriteFileWithParents(pathname, data) {
  await moduleFsInit();
  try {
    await moduleFs.promises.writeFile(pathname, data);
  } catch (ignore) {
    await moduleFs.promises.mkdir(modulePath.dirname(pathname), {
      recursive: true
    });
    await moduleFs.promises.writeFile(pathname, data);
  }
  console.error("wrote file " + pathname);
}
function globExclude({
  excludeList = [],
  includeList = [],
  pathnameList = []
}) {
  function globAssertNotWeird(list, name) {
    [
      [
        "\n", (
          /^.*?([\u0000-\u0007\r]).*/gm
        )
      ],
      [
        "\r", (
          /^.*?([\n]).*/gm
        )
      ]
    ].forEach(function ([
      separator, rgx
    ]) {
      list.join(separator).replace(rgx, function (match0, char) {
        throw new Error(
          "Weird character "
          + JSON.stringify(char)
          + " found in " + name + " "
          + JSON.stringify(match0)
        );
      });
    });
  }

  function globToRegexp(pattern) {
    let ii = 0;
    let isClass = false;
    let strClass = "";
    let strRegex = "";
    pattern = pattern.replace((
      /\/\/+/g
    ), "/");
    pattern = pattern.replace((
      /\*\*\*+/g
    ), "**");
    pattern.replace((
      /\\\\|\\\[|\\\]|\[|\]|./g
    ), function (match0) {
      switch (match0) {
      case "[":
        if (isClass) {
          strClass += "[";
          return;
        }
        strClass += "\u0000";
        strRegex += "\u0000";
        isClass = true;
        return;
      case "]":
        if (isClass) {
          isClass = false;
          return;
        }
        strRegex += "]";
        return;
      default:
        if (isClass) {
          strClass += match0;
          return;
        }
        strRegex += match0;
      }
      return "";
    });
    strClass += "\u0000";
    strClass = strClass.replace((
      /\u0000!/g
    ), "\u0000^");
    strClass = strClass.replace((
      /\u0000-/g
    ), "\u0000\\-");
    strClass = strClass.replace((
      /-\u0000/g
    ), "\\-\u0000");
    strClass = strClass.replace((
      /[\[\]]/g
    ), "\\$&");
    strRegex = strRegex.replace((
      /[$()*+.?\[\\\]\^{|}]/g
    ), "\\$&");
    strRegex = strRegex.replace((
      /\\\*\\\*\/(?:\\\*)+/g
    ), ".*?");
    strRegex = strRegex.replace((
      /(^|\/)\\\*\\\*(\/|$)/gm
    ), "$1.*?$2");
    strRegex = strRegex.replace((
      /(?:\\\*)+/g
    ), "[^\\/]*?");
    strRegex = strRegex.replace((
      /\\\?/g
    ), "[^\\/]");
    strRegex = strRegex.replace((
      /\/$/gm
    ), "\\/.*?");
    ii = 0;
    strClass = strClass.split("\u0000");
    strRegex = strRegex.replace((
      /\u0000/g
    ), function () {
      ii += 1;
      if (strClass[ii] === "") {
        return "";
      }
      return "[" + strClass[ii] + "]";
    });
    strRegex = new RegExp("^" + strRegex + "$", "gm");
    return strRegex;
  }
  globAssertNotWeird(excludeList, "pattern");
  globAssertNotWeird(includeList, "pattern");
  globAssertNotWeird(pathnameList, "pathname");
  pathnameList = pathnameList.join("\n");
  if (includeList.length > 0) {
    includeList = includeList.map(globToRegexp);
    includeList.forEach(function (pattern) {
      pathnameList = pathnameList.replace(pattern, "\u0000$&");
    });
    pathnameList = pathnameList.replace((
      /^[^\u0000].*/gm
    ), "");
    pathnameList = pathnameList.replace((
      /^\u0000+/gm
    ), "");
  }
  excludeList = excludeList.map(globToRegexp);
  excludeList.forEach(function (pattern) {
    pathnameList = pathnameList.replace(pattern, "");
  });
  pathnameList = pathnameList.split("\n").filter(function (elem) {
    return elem;
  });
  return {
    excludeList,
    includeList,
    pathnameList
  };
}
function htmlEscape(str) {
  return String(str).replace((
    /&/g
  ), "&amp;").replace((
    /</g
  ), "&lt;").replace((
    />/g
  ), "&gt;");
}
async function moduleFsInit() {

  if (moduleFs !== undefined) {
    return;
  }
  if (moduleFsInitResolveList !== undefined) {
    return new Promise(function (resolve) {
      moduleFsInitResolveList.push(resolve);
    });
  }
  moduleFsInitResolveList = [];
  [
    moduleChildProcess,
    moduleFs,
    modulePath,
    moduleUrl
  ] = await Promise.all([
    import("child_process"),
    import("fs"),
    import("path"),
    import("url")
  ]);
  while (moduleFsInitResolveList.length > 0) {
    moduleFsInitResolveList.shift()();
  }
}
function v8CoverageListMerge(processCovs) {
  let resultMerged = [];    // List of merged scripts from processCovs.
  let urlToScriptDict = new Map();  // Map scriptCov.url to scriptCovs.

  function compareRangeList(aa, bb) {
    if (aa.startOffset !== bb.startOffset) {
      return aa.startOffset - bb.startOffset;
    }
    return bb.endOffset - aa.endOffset;
  }

  function dictKeyValueAppend(dict, key, val) {
    let list = dict.get(key);
    if (list === undefined) {
      list = [];
      dict.set(key, list);
    }
    list.push(val);
  }

  function mergeTreeList(parentTrees) {
    if (parentTrees.length <= 1) {
      return parentTrees[0];
    }
    return {
      children: mergeTreeListToChildren(parentTrees),
      delta: parentTrees.reduce(function (aa, bb) {
        return aa + bb.delta;
      }, 0),
      end: parentTrees[0].end,
      start: parentTrees[0].start
    };
  }

  function mergeTreeListToChildren(parentTrees) {
    let openRange;
    let parentToChildDict = new Map();    // Map parent to child.
    let queueList;
    let queueListIi = 0;
    let queueOffset;
    let queueTrees;
    let resultChildren = [];
    let startToTreeDict = new Map();    // Map tree.start to tree.
    function nextXxx() {
      let [
        nextOffset, nextTrees
      ] = queueList[queueListIi] || [];
      let openRangeEnd;
      if (queueTrees === undefined) {
        queueListIi += 1;
      } else if (nextOffset === undefined || nextOffset > queueOffset) {
        nextOffset = queueOffset;
        nextTrees = queueTrees;
        queueTrees = undefined;
      } else {
        if (nextOffset === queueOffset) {
          queueTrees.forEach(function (tree) {
            nextTrees.push(tree);
          });
          queueTrees = undefined;
        }
        queueListIi += 1;
      }
      if (nextOffset === undefined) {
        if (openRange !== undefined) {
          resultAppendNextChild();
        }
        return true;
      }
      if (openRange !== undefined && openRange.end <= nextOffset) {
        resultAppendNextChild();
        openRange = undefined;
      }
      if (openRange === undefined) {
        openRangeEnd = nextOffset + 1;
        nextTrees.forEach(function ({
          parentIi,
          tree
        }) {
          openRangeEnd = Math.max(openRangeEnd, tree.end);
          dictKeyValueAppend(parentToChildDict, parentIi, tree);
        });
        queueOffset = openRangeEnd;
        openRange = {
          end: openRangeEnd,
          start: nextOffset
        };
      } else {
        nextTrees.forEach(function ({
          parentIi,
          tree
        }) {
          let right;
          if (tree.end > openRange.end) {
            right = treeSplit(tree, openRange.end);
            if (queueTrees === undefined) {
              queueTrees = [];
            }
            queueTrees.push({
              parentIi,
              tree: right
            });
          }
          dictKeyValueAppend(parentToChildDict, parentIi, tree);
        });
      }
    }
    function resultAppendNextChild() {
      let treesMatching = [];
      parentToChildDict.forEach(function (nested) {
        if (
          nested.length === 1
          && nested[0].start === openRange.start
          && nested[0].end === openRange.end
        ) {
          treesMatching.push(nested[0]);
        } else {
          treesMatching.push({
            children: nested,
            delta: 0,
            end: openRange.end,
            start: openRange.start
          });
        }
      });
      parentToChildDict.clear();
      resultChildren.push(mergeTreeList(treesMatching));
    }
    function treeSplit(tree, offset) {
      let child;
      let ii = 0;
      let leftChildLen = tree.children.length;
      let mid;
      let resultTree;
      let rightChildren;
      while (ii < tree.children.length) {
        child = tree.children[ii];
        if (child.start < offset && offset < child.end) {
          mid = treeSplit(child, offset);
          leftChildLen = ii + 1;
          break;
        }
        if (child.start >= offset) {
          leftChildLen = ii;
          break;
        }
        ii += 1;
      }
      rightChildren = tree.children.splice(
        leftChildLen,
        tree.children.length - leftChildLen
      );
      if (mid !== undefined) {
        rightChildren.unshift(mid);
      }
      resultTree = {
        children: rightChildren,
        delta: tree.delta,
        end: tree.end,
        start: offset
      };
      tree.end = offset;
      return resultTree;
    }
    parentTrees.forEach(function (parentTree, parentIi) {
      parentTree.children.forEach(function (child) {
        dictKeyValueAppend(startToTreeDict, child.start, {
          parentIi,
          tree: child
        });
      });
    });
    queueList = Array.from(startToTreeDict).map(function ([
      startOffset, trees
    ]) {
      return [
        startOffset, trees
      ];
    }).sort(function (aa, bb) {
      return aa[0] - bb[0];
    });
    while (true) {
      if (nextXxx()) {
        break;
      }
    }
    return resultChildren;
  }

  function sortFunc(funcCov) {
    funcCov.ranges = treeToRanges(treeFromSortedRanges(
      funcCov.ranges.sort(compareRangeList)
    ));
    return funcCov;
  }

  function sortScript(scriptCov) {

    scriptCov.functions.forEach(function (funcCov) {
      sortFunc(funcCov);
    });
    scriptCov.functions.sort(function (aa, bb) {
      return compareRangeList(aa.ranges[0], bb.ranges[0]);
    });
    return scriptCov;
  }

  function treeFromSortedRanges(ranges) {
    let root;
    let stack = [];   // Stack of parent trees and parent counts.
    ranges.forEach(function (range) {
      let node = {
        children: [],
        delta: range.count,
        end: range.endOffset,
        start: range.startOffset
      };
      let parent;
      let parentCount;
      if (root === undefined) {
        root = node;
        stack.push([
          node, range.count
        ]);
        return;
      }
      while (true) {
        [
          parent, parentCount
        ] = stack[stack.length - 1];
        if (range.startOffset < parent.end) {
          break;
        }
        stack.pop();
      }
      node.delta -= parentCount;
      parent.children.push(node);
      stack.push([
        node, range.count
      ]);
    });
    return root;
  }

  function treeToRanges(tree) {
    let count;
    let cur;
    let ii;
    let parentCount;
    let ranges = [];
    let stack = [       // Stack of parent trees and counts.
      [
        tree, 0
      ]
    ];
    function normalizeRange(tree) {
      let children = [];
      let curEnd;
      let head;
      let tail = [];
      function endChain() {
        if (tail.length !== 0) {
          head.end = tail[tail.length - 1].end;
          tail.forEach(function (tailTree) {
            tailTree.children.forEach(function (subChild) {
              subChild.delta += tailTree.delta - head.delta;
              head.children.push(subChild);
            });
          });
          tail.length = 0;
        }
        normalizeRange(head);
        children.push(head);
      }
      tree.children.forEach(function (child) {
        if (head === undefined) {
          head = child;
        } else if (
          child.delta === head.delta && child.start === curEnd
        ) {
          tail.push(child);
        } else {
          endChain();
          head = child;
        }
        curEnd = child.end;
      });
      if (head !== undefined) {
        endChain();
      }
      if (children.length === 1) {
        if (
          children[0].start === tree.start
          && children[0].end === tree.end
        ) {
          tree.delta += children[0].delta;
          tree.children = children[0].children;
          return;
        }
      }
      tree.children = children;
    }
    normalizeRange(tree);
    while (stack.length > 0) {
      [
        cur, parentCount
      ] = stack.pop();
      count = parentCount + cur.delta;
      ranges.push({
        count,
        endOffset: cur.end,
        startOffset: cur.start
      });
      ii = cur.children.length - 1;
      while (ii >= 0) {
        stack.push([
          cur.children[ii], count
        ]);
        ii -= 1;
      }
    }
    return ranges;
  }

  if (processCovs.length === 0) {
    return {
      result: []
    };
  }
  processCovs.forEach(function ({
    result
  }) {
    result.forEach(function (scriptCov) {
      dictKeyValueAppend(urlToScriptDict, scriptCov.url, scriptCov);
    });
  });
  urlToScriptDict.forEach(function (scriptCovs) {

    let functions = [];
    let rangeToFuncDict = new Map();
    if (scriptCovs.length === 1) {
      resultMerged.push(sortScript(scriptCovs[0]));
      return;
    }
    scriptCovs.forEach(function ({
      functions
    }) {
      functions.forEach(function (funcCov) {
        dictKeyValueAppend(
          rangeToFuncDict,
          (
            funcCov.ranges[0].startOffset
            + ";" + funcCov.ranges[0].endOffset
          ),
          funcCov
        );
      });
    });
    rangeToFuncDict.forEach(function (funcCovs) {

      let count = 0;
      let isBlockCoverage;
      let merged;
      let ranges;
      let trees = [];
      if (funcCovs.length === 1) {
        functions.push(sortFunc(funcCovs[0]));
        return;
      }
      funcCovs.forEach(function (funcCov) {
        count += (
          funcCov.count !== undefined
          ? funcCov.count
          : funcCov.ranges[0].count
        );
        if (funcCov.isBlockCoverage) {
          trees.push(treeFromSortedRanges(funcCov.ranges));
        }
      });
      if (trees.length > 0) {
        isBlockCoverage = true;
        ranges = treeToRanges(mergeTreeList(trees));
      } else {
        isBlockCoverage = false;
        ranges = [
          {
            count,
            endOffset: funcCovs[0].ranges[0].endOffset,
            startOffset: funcCovs[0].ranges[0].startOffset
          }
        ];
      }
      merged = {
        functionName: funcCovs[0].functionName,
        isBlockCoverage,
        ranges
      };
      if (count !== ranges[0].count) {
        merged.count = count;
      }
      functions.push(merged);
    });
    resultMerged.push(sortScript({
      functions,
      scriptId: scriptCovs[0].scriptId,
      url: scriptCovs[0].url
    }));
  });
  Object.entries(resultMerged.sort(function (aa, bb) {
    return (
      aa.url > bb.url
      ? 1
      : -1
    );
  })).forEach(function ([
    scriptId, scriptCov
  ]) {
    scriptCov.scriptId = scriptId.toString(10);
  });
  return {
    result: resultMerged
  };
}
async function v8CoverageReportCreate({
  consoleError,
  coverageDir,
  processArgv = []
}) {
  let cwd;
  let excludeList = [];
  let exitCode = 0;
  let fileDict;
  let includeList = [];
  let modeIncludeNodeModules;
  let processArgElem;
  let promiseList = [];
  let v8CoverageObj;

  function htmlRender({
    fileList,
    lineList,
    modeIndex,
    pathname
  }) {
    let html;
    let padLines;
    let padPathname;
    let txt;
    let txtBorder;
    html = "";
    html += String(`
<!DOCTYPE html>
<html lang="en">
<head>
<title>V8 Coverage Report</title>
<style>
/* jslint utility2:true */
/*csslint ignore:start*/
.coverage,
.coverage a,
.coverage div,
.coverage pre,
.coverage span,
.coverage table,
.coverage tbody,
.coverage td,
.coverage th,
.coverage thead,
.coverage tr {
  box-sizing: border-box;
  font-family: monospace;
}
/*csslint ignore:end*/

/* css - coverage_report - general */
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
  line-height: 20px;
  margin: 0;
  padding: 5px 10px;
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
.coverage .footer {
  text-align: center;
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

/* css - coverage_report - color */
.coverage td,
.coverage th {
  background: #fff;
}
.coverage .count,
.coverage .coverageHigh {
  background: #9d9;
}
.coverage .count {
  color: #666;
}
.coverage .coverageIgnore {
  background: #ccc;
}
.coverage .coverageLow,
.coverage .uncovered {
  background: #ebb;
}
.coverage .coverageMedium {
  background: #fd7;
}
.coverage .footer,
.coverage .header,
.coverage .lineno {
  background: #ddd;
}
.coverage .percentbar {
  background: #999;
}
.coverage .percentbar div {
  background: #666;
}

/* css - coverage_report - important */
.coverage pre:hover span,
.coverage tr:hover td {
  background: #7d7;
}
.coverage pre:hover span.uncovered,
.coverage tr:hover td.coverageLow {
  background: #f99;
}
</style>
</head>
<body class="coverage">
<!-- header start -->
<div class="header">
<div class="title">V8 Coverage Report</div>
<table>
<thead>
  <tr>
  <th>Files covered</th>
  <th>Lines</th>
  <th>Remaining</th>
  </tr>
</thead>
<tbody>
    `).trim() + "\n";
    if (modeIndex) {
      padLines = String("(ignore) 100.00 %").length;
      padPathname = 32;
      fileList.unshift({
        linesCovered: 0,
        linesTotal: 0,
        modeCoverageIgnoreFile: "",
        pathname: "./"
      });
      fileList.slice(1).forEach(function ({
        linesCovered,
        linesTotal,
        modeCoverageIgnoreFile,
        pathname
      }) {
        if (!modeCoverageIgnoreFile) {
          fileList[0].linesCovered += linesCovered;
          fileList[0].linesTotal += linesTotal;
        }
        padPathname = Math.max(padPathname, pathname.length + 2);
        padLines = Math.max(
          padLines,
          String(linesCovered + " / " + linesTotal).length
        );
      });
    }
    txtBorder = (
      "+" + "-".repeat(padPathname + 2) + "+"
      + "-".repeat(padLines + 2) + "+"
      + "-".repeat(padLines + 2) + "+\n"
    );
    txt = "";
    txt += "V8 Coverage Report\n";
    txt += txtBorder;
    txt += (
      "| " + String("Files covered").padEnd(padPathname, " ") + " | "
      + String("Lines").padStart(padLines, " ") + " | "
      + String("Remaining").padStart(padLines, " ") + " |\n"
    );
    txt += txtBorder;
    fileList.forEach(function ({
      linesCovered,
      linesTotal,
      modeCoverageIgnoreFile,
      pathname
    }, ii) {
      let coverageLevel;
      let coveragePct;
      let fill;
      let str1;
      let str2;
      let xx1;
      let xx2;
      coveragePct = Math.floor(10000 * linesCovered / linesTotal || 0);
      coverageLevel = (
        modeCoverageIgnoreFile
        ? "coverageIgnore"
        : coveragePct >= 8000
        ? "coverageHigh"
        : coveragePct >= 5000
        ? "coverageMedium"
        : "coverageLow"
      );
      coveragePct = String(coveragePct).replace((
        /..$/m
      ), ".$&");
      if (modeIndex && ii === 0) {
        fill = (
          "#" + Math.round(
            (100 - Number(coveragePct)) * 2.21
          ).toString(16).padStart(2, "0")
          + Math.round(
            Number(coveragePct) * 2.21
          ).toString(16).padStart(2, "0")
          + "00"
        );
        str1 = "coverage";
        str2 = coveragePct + " %";
        xx1 = 6 * str1.length + 20;
        xx2 = 6 * str2.length + 20;
        promiseList.push(fsWriteFileWithParents((
          coverageDir + "coverage_badge.svg"
        ), String(`
<svg height="20" width="${xx1 + xx2}" xmlns="http://www.w3.org/2000/svg">
<rect fill="#555" height="20" width="${xx1 + xx2}"/>
<rect fill="${fill}" height="20" width="${xx2}" x="${xx1}"/>
<g
  fill="#fff"
  font-family="verdana, geneva, dejavu sans, sans-serif"
  font-size="11"
  font-weight="bold"
  text-anchor="middle"
>
<text x="${0.5 * xx1}" y="14">${str1}</text>
<text x="${xx1 + 0.5 * xx2}" y="14">${str2}</text>
</g>
</svg>
        `).trim() + "\n"));
        pathname = "";
      }
      txt += (
        "| "
        + String("./" + pathname).padEnd(padPathname, " ") + " | "
        + String(
          modeCoverageIgnoreFile + " " + coveragePct + " %"
        ).padStart(padLines, " ") + " | "
        + " ".repeat(padLines) + " |\n"
      );
      txt += (
        "| " + "*".repeat(
          Math.round(0.01 * coveragePct * padPathname)
        ).padEnd(padPathname, "_") + " | "
        + String(
          linesCovered + " / " + linesTotal
        ).padStart(padLines, " ") + " | "
        + String(
          (linesTotal - linesCovered) + " / " + linesTotal
        ).padStart(padLines, " ") + " |\n"
      );
      txt += txtBorder;
      pathname = htmlEscape(pathname);
      html += String(`
  <tr>
  <td class="${coverageLevel}">
      ${(
        modeIndex
        ? (
          "<a href=\"" + (pathname || "index") + ".html\">. / "
          + pathname + "</a><br>"
        )
        : (
          "<a href=\""
          + "../".repeat(pathname.split("/").length - 1)
          + "index.html\">. / </a>"
          + pathname + "<br>"
        )
      )}
    <div class="percentbar">
      <div style="width: ${coveragePct}%;"></div>
    </div>
  </td>
  <td style="text-align: right;">
    ${modeCoverageIgnoreFile} ${coveragePct} %<br>
    ${linesCovered} / ${linesTotal}
  </td>
  <td style="text-align: right;">
    <br>
    ${linesTotal - linesCovered} / ${linesTotal}
  </td>
  </tr>
    `).trim() + "\n";
    });
    html += String(`
</tbody>
</table>
</div>
<!-- header end -->
    `).trim() + "\n";
    if (!modeIndex) {
      html += String(`
<!-- content start -->
<div class="content">
      `).trim() + "\n";
      lineList.forEach(function ({
        count,
        holeList,
        line,
        startOffset
      }, ii) {
        let chunk;
        let inHole;
        let lineHtml;
        let lineId;
        lineHtml = "";
        lineId = "line_" + (ii + 1);
        switch (count) {
        case -1:
        case 0:
          if (holeList.length === 0) {
            lineHtml += "</span>";
            lineHtml += "<span class=\"uncovered\">";
            lineHtml += htmlEscape(line);
            break;
          }
          line = line.split("").map(function (char) {
            return {
              char,
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
            char,
            isHole
          }) {
            if (inHole !== isHole) {
              lineHtml += htmlEscape(chunk);
              lineHtml += "</span><span";
              if (isHole) {
                lineHtml += " class=\"uncovered\"";
              }
              lineHtml += ">";
              chunk = "";
              inHole = isHole;
            }
            chunk += char;
          });
          lineHtml += htmlEscape(chunk);
          break;
        default:
          lineHtml += htmlEscape(line);
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
${String(count || "-0").padStart(7, " ")}
</span>
<span>${lineHtml}</span>
</pre>
        `).replace((
          /\n/g
        ), "").trim() + "\n";
      });
      html += String(`
</div>
<!-- content end -->
      `).trim() + "\n";
    }
    html += String(`
<div class="footer">
  [
  This document was created with
  <a href="https://github.com/jslint-org/jslint">JSLint</a>
  ]
</div>
</body>
</html>
    `).trim() + "\n";
    promiseList.push(fsWriteFileWithParents(pathname + ".html", html));
    if (!modeIndex) {
      return;
    }
    consoleError("\n" + txt);
    promiseList.push(fsWriteFileWithParents((
      coverageDir + "coverage_report.txt"
    ), txt));
  }

/*
function sentinel() {}
*/

  await moduleFsInit();
  consoleError = consoleError || console.error;
  cwd = process.cwd().replace((
    /\\/g
  ), "/") + "/";
  assertOrThrow(coverageDir, "invalid coverageDir " + coverageDir);
  coverageDir = modulePath.resolve(coverageDir).replace((
    /\\/g
  ), "/") + "/";

  processArgv = processArgv.slice();
  while (processArgv[0] && processArgv[0][0] === "-") {
    processArgElem = processArgv.shift().split("=");
    processArgElem[1] = processArgElem.slice(1).join("=");
    switch (processArgElem[0]) {
    case "--exclude":
      excludeList.push(processArgElem[1]);
      break;
    case "--include":
      includeList.push(processArgElem[1]);
      break;
    case "--include-node-modules":
      modeIncludeNodeModules = !(
        /0|false|null|undefined/
      ).test(processArgElem[1]);
      break;
    }
  }
  if (processArgv.length > 0) {
    await fsWriteFileWithParents(coverageDir + "/touch.txt", "");
    await Promise.all(Array.from(
      await moduleFs.promises.readdir(coverageDir)
    ).map(async function (file) {
      if ((
        /^coverage-\d+?-\d+?-\d+?\.json$/
      ).test(file)) {
        consoleError("rm file " + coverageDir + file);
        await moduleFs.promises.unlink(coverageDir + file);
      }
    }));
    exitCode = await new Promise(function (resolve) {
      moduleChildProcess.spawn(
        (
          processArgv[0] === "npm"
          ? process.platform.replace("win32", "npm.cmd").replace(
            process.platform,
            "npm"
          )
          : processArgv[0]
        ),
        processArgv.slice(1),
        {
          env: Object.assign({}, process.env, {
            NODE_V8_COVERAGE: coverageDir
          }),
          stdio: ["ignore", 1, 2]
        }
      ).on("exit", resolve);
    });
    consoleError(
      `v8CoverageReportCreate - program exited with exitCode=${exitCode}`
    );
  }
  consoleError("v8CoverageReportCreate - merging coverage files...");
  v8CoverageObj = await moduleFs.promises.readdir(coverageDir);
  v8CoverageObj = v8CoverageObj.filter(function (file) {
    return (
      /^coverage-\d+?-\d+?-\d+?\.json$/
    ).test(file);
  });
  v8CoverageObj = await Promise.all(v8CoverageObj.map(async function (file) {
    let data;
    let pathnameDict = Object.create(null);
    data = await moduleFs.promises.readFile(coverageDir + file, "utf8");
    data = JSON.parse(data);
    data.result.forEach(function (scriptCov) {
      let pathname = scriptCov.url;
      if (!pathname.startsWith("file:///")) {
        return;
      }
      pathname = moduleUrl.fileURLToPath(pathname);
      pathname = modulePath.resolve(pathname).replace((
        /\\/g
      ), "/");
      if (pathname.indexOf("[") >= 0 || !pathname.startsWith(cwd)) {
        return;
      }
      pathname = pathname.slice(cwd.length);
      scriptCov.url = pathname;
      pathnameDict[pathname] = scriptCov;
    });
    if (!modeIncludeNodeModules) {
      excludeList.push("node_modules/");
    }
    data.result = globExclude({
      excludeList,
      includeList,
      pathnameList: Object.keys(pathnameDict)
    }).pathnameList.map(function (pathname) {
      return pathnameDict[pathname];
    });
    return data;
  }));
  v8CoverageObj = v8CoverageListMerge(v8CoverageObj);
  await fsWriteFileWithParents(
    coverageDir + "v8_coverage_merged.json",
    JSON.stringify(v8CoverageObj, undefined, 1)
  );
  consoleError("v8CoverageReportCreate - creating html-coverage-report...");
  fileDict = Object.create(null);
  await Promise.all(v8CoverageObj.result.map(async function ({
    functions,
    url: pathname
  }) {
    let lineList;
    let linesCovered;
    let linesTotal;
    let source;
    source = await moduleFs.promises.readFile(pathname, "utf8");
    lineList = [{}];
    source.replace((
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
    lineList[lineList.length - 1].endOffset = source.length;
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
              elem.startOffset <= startOffset
              && startOffset <= elem.endOffset
            ) || (
              elem.startOffset <= endOffset
              && endOffset <= elem.endOffset
            ) || (
              startOffset <= elem.startOffset
              && elem.endOffset <= endOffset
            )
          )) {
            return;
          }
          if (ii + 1 === list.length) {
            if (elem.count === -1) {
              elem.count = count;
            }
            return;
          }
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
    await moduleFs.promises.mkdir((
      modulePath.dirname(coverageDir + pathname)
    ), {
      recursive: true
    });
    fileDict[pathname] = {
      lineList,
      linesCovered,
      linesTotal,
      modeCoverageIgnoreFile: (
        (
          /^\/\*coverage-ignore-file\*\/$/m
        ).test(source.slice(0, 65536))
        ? "(ignore)"
        : ""
      ),
      pathname
    };
    htmlRender({
      fileList: [
        fileDict[pathname]
      ],
      lineList,
      pathname: coverageDir + pathname
    });
  }));
  htmlRender({
    fileList: Object.keys(fileDict).sort().map(function (pathname) {
      return fileDict[pathname];
    }),
    modeIndex: true,
    pathname: coverageDir + "index"
  });
  await Promise.all(promiseList);
  assertOrThrow(
    exitCode === 0,
    "v8CoverageReportCreate - nonzero exitCode " + exitCode
  );
}
v8CoverageReportCreate({
  coverageDir: ".artifact/coverage",
  processArgv: process.argv.slice(2)
});
' 0 "$@" # '
)}

shRunWithScreenshotTxt() {(set -e
# this function will run cmd $@ and screenshot text-output
# https://www.cnx-software.com/2011/09/22/how-to-convert-a-command-line-result-into-an-image-in-linux/
    local EXIT_CODE=0
    local SCREENSHOT_SVG="$1"
    shift
    printf "0\n" > "$SCREENSHOT_SVG.exit_code"
    printf "shRunWithScreenshotTxt - ($* 2>&1)\n" 1>&2
    # run "$@" with screenshot
    (
        "$@" 2>&1 || printf "$?\n" > "$SCREENSHOT_SVG.exit_code"
    ) | tee "$SCREENSHOT_SVG.txt"
    EXIT_CODE="$(cat "$SCREENSHOT_SVG.exit_code")"
    printf "shRunWithScreenshotTxt - EXIT_CODE=$EXIT_CODE - $SCREENSHOT_SVG\n" \
        1>&2
    # format text-output
    node --input-type=module --eval '
import moduleFs from "fs";
(async function () {
    let result = await moduleFs.promises.readFile(
        process.argv[1] + ".txt",
        "utf8"
    );
    let yy = 10;
    // remove ansi escape-code
    result = result.replace((
        /\u001b.*?m/g
    ), "");
    /*
    // format unicode
    result = result.replace((
        /\\u[0-9a-f]{4}/g
    ), function (match0) {
        return String.fromCharCode("0x" + match0.slice(-4));
    });
    */
    // normalize "\r\n"
    result = result.replace((
        /\r\n?/
    ), "\n").trimEnd();
    // limit number-of-lines
    result = result.split("\n").slice(
        0,
        process.env.SH_RUN_WITH_SCREENSHOT_TXT_MAX_LINES || Infinity
    ).join("\n");
    // 96-column wordwrap
    result = result.split("\n").map(function (line) {
        let wordwrap = line.slice(0, 96).padEnd(96, " ");
        line = line.slice(96);
        while (line) {
            wordwrap += "\\\n  " + line.slice(0, 96 - 2).padEnd(96 - 2, " ");
            line = line.slice(96 - 2);
        }
        return wordwrap + " ";
    }).join("\n");
    // html-escape
    result = result.replace((
        /&/g
    ), "&amp;").replace((
        /</g
    ), "&lt;").replace((
        />/g
    ), "&gt;");
    // convert text to svg-tspan
    result = result.split("\n").map(function (line) {
        yy += 22;
        return `<tspan
    lengthAdjust="spacingAndGlyphs"
    textLength="${96 * 8}"
    x="10"
    y="${yy}"
>${line}</tspan>\n`;
    }).join("");
    result = String(`
  <svg height="${yy + 20}" width="800" xmlns="http://www.w3.org/2000/svg">
<rect height="${yy + 20}" fill="#222" width="800"></rect>
<text
    fill="#7f7"
    font-family="consolas, menlo, monospace"
    font-size="14"
    xml:space="preserve"
>
${result}
</text>
</svg>
    `).trim() + "\n";
    moduleFs.promises.writeFile(process.argv[1], result);
}());
' "$SCREENSHOT_SVG" # '
    printf "shRunWithScreenshotTxt - wrote - $SCREENSHOT_SVG\n"
    # cleanup
    rm "$SCREENSHOT_SVG.exit_code" "$SCREENSHOT_SVG.txt"
    return "$EXIT_CODE"
)}

# init ubuntu .bashrc
shBashrcDebianInit || exit "$?"

# init windows-environment
shBashrcWindowsInit

# source myci2.sh
if [ -f ~/myci2.sh ]
then
    . ~/myci2.sh :
fi

# run "$@"
(set -e
    if [ ! "$1" ]
    then
        exit
    fi
    unset shCiArtifactUploadCustom
    unset shCiBaseCustom
    unset shCiBaseCustom2
    unset shCiLintCustom
    unset shCiLintCustom2
    unset shCiNpmPublishCustom
    unset shCiPreCustom
    unset shCiPreCustom2
    if [ -f ./myci2.sh ]
    then
        . ./myci2.sh :
    fi
    if [ -f ./.ci.sh ]
    then
        . ./.ci.sh :
    fi
    if [ -f ./.ci2.sh ]
    then
        . ./.ci2.sh :
    fi
    "$@"
)
