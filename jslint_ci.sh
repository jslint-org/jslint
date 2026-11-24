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

# POSIX reference
# http://pubs.opengroup.org/onlinepubs/9699919799/utilities/test.html
# http://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html

# sh one-liner
: '
git add .; npm run test2; git checkout .
git branch -d -r origin/aa
git config --global diff.algorithm histogram
git fetch --prune
git fetch origin alpha beta master && git fetch upstream alpha beta master
git fetch origin alpha beta master --tags
git fetch upstream "refs/tags/*:refs/tags/*"
git ls-files --stage | sort
git ls-remote --heads origin
git update-index --chmod=+x aa.js
openssl rand -base64 32 # random key
sh jslint_ci.sh shRunWithScreenshotTxt .artifact/screenshot_changelog.svg head -n50 CHANGELOG.md
'

# charset - ascii
# \u0000\u0001\u0002\u0003\u0004\u0005\u0006\u0007
# \b\t\n\u000b\f\r\u000e\u000f
# \u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017
# \u0018\u0019\u001a\u001b\u001c\u001d\u001e\u001f
#  !\"#$%&'()*+,-./0123456789:;<=>?
# @ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_
# `abcdefghijklmnopqrstuvwxyz{|}~\u007f

# shellcheck disable=SC2015,SC3021,SC3044
shBashrcDebianInit() {
# This function will init debian:stable /etc/skel/.bashrc.
# https://salsa.debian.org/debian/bash/-/blob/e17f75c7869a4a00dbad36503c1965040b22ef32/debian/skel.bashrc
    if [ ! "$BASH_VERSION" ]
    then
        return
    fi
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
    #[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
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
        #alias grep='grep --color=auto'
        #alias fgrep='fgrep --color=auto'
        #alias egrep='egrep --color=auto'
    fi
    # colored GCC warnings and errors
    #export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
    # some more ls aliases
    #alias ll='ls -l'
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
# This function will init windows-environment.
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
    # if (! alias curl 2>/dev/null) && [ -f c:/windows/system32/curl.exe ]
    # then
    #     alias curl=c:/windows/system32/curl.exe
    # fi
    # alias node.exe
    if (! alias node 2>/dev/null)
    then
        alias node=node.exe
    fi
}

shBrowserScreenshot() {(set -e
# This function will run headless-chrome to screenshot url $1.
    node --input-type=module --eval '
import moduleChildProcess from "child_process";
import moduleFs from "fs";
import moduleOs from "os";
import modulePath from "path";
(async function () {
    const cwd = process.cwd().replace((/\\/g), "/");
    const timeStart = Date.now();
    const tmpdir = await moduleFs.promises.mkdtemp(
        moduleOs.tmpdir() + "/shBrowserScreenshot-"
    );
    let child;
    let exitCode;
    let file;
    let url = process.argv[1];
    // A scheme has 2+ chars, so a windows drive "C:" is a local path. Decode
    // a url, or encodeURIComponent below encodes its "%" a second time. A
    // "file:///C:/" pathname is "/C:/", so drop that "/" to match cwd.
    if ((/^\w{2,}:/).test(url)) {
        file = decodeURIComponent(new URL(url).pathname).replace((
            /^\/(?=[A-Za-z]:)/
        ), "");
    } else {
        url = modulePath.resolve(url).replace((/\\/g), "/");
        file = url;
    }
    // Remove prefix $PWD from file.
    if (String(file + "/").startsWith(cwd + "/")) {
        file = file.replace(cwd, "");
    }
    file = ".artifact/screenshot_browser_" + encodeURIComponent(file).replace((
        /%/g
    ), "_").toLowerCase() + ".png";
    child = moduleChildProcess.spawn(
        (
            process.platform === "darwin"
            ? "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
            : process.platform === "win32"
            ? "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"
            : "/usr/bin/google-chrome-stable"
        ),
        [
            "--headless",
            "--hide-scrollbars",
            "--ignore-certificate-errors",
            "--incognito",
            "--screenshot",
            "--timeout=30000",
            "--user-data-dir=" + tmpdir,
            "--window-size=800,800",
            //
            "--disable-audio-input",
            "--disable-audio-output",
            "--disable-gpu",
            //
            "-screenshot=" + modulePath.resolve(file),
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
    await moduleFs.promises.rm(tmpdir, {recursive: true});
    console.error(
        "shBrowserScreenshot" +
        "\n  - url - " + url +
        "\n  - wrote - " + file +
        "\n  - timeElapsed - " + (Date.now() - timeStart) + " ms" +
        "\n  - EXIT_CODE=" + exitCode
    );
}());
' "$@" # '
)}

shCiArtifactUpload() {(set -e
# This function will upload build-artifacts to branch-gh-pages.
#
# shCiArtifactUploadCustom() {(set -e
# # This function will run custom-code to upload build-artifacts.
#     return
# )}
    if ! shCiMatrixIsmainName || \
        [ ! -f package.json ] || \
        ! grep -Eq '^ {4}"shCiArtifactUpload": 1,$' package.json
    then
        return
    fi
    # install graphicsmagick
    if (! command -v gm >/dev/null)
    then
        sudo apt-get update
        sudo apt-get install -y graphicsmagick
    fi
    # mkdir .artifact/
    mkdir -p .artifact/
    # init .git/config
    git config --local user.email "github-actions@users.noreply.github.com"
    git config --local user.name "github-actions"
    # init $GITHUB_BRANCH0
    export GITHUB_BRANCH0="$(git branch --show-current)"
    git pull --unshallow origin "$GITHUB_BRANCH0"
    # init $UPSTREAM_XXX
    export UPSTREAM_REPOSITORY="$(sed -En \
        -e 's|.*"git\+https://github\.com/([^"]+)\.git".*|\1|p' \
        package.json
    )"
    if [ ! "$UPSTREAM_REPOSITORY" ]
    then
        printf "shCiArtifactUpload - missing UPSTREAM_REPOSITORY\n" >&2
        exit 1
    fi
    export UPSTREAM_GITHUB_IO="$(
        printf "%s" "$UPSTREAM_REPOSITORY" | sed -e "s|/|.github.io/|"
    )"
    # init $GITHUB_XXX
    export GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-$UPSTREAM_REPOSITORY}"
    export GITHUB_GITHUB_IO="$(
        printf "%s" "$GITHUB_REPOSITORY" | sed -e "s|/|.github.io/|"
    )"
    # screenshot changelog and files
    PID_LIST=""
    # parallel-task - screenshot changelog
    shRunWithScreenshotTxt .artifact/screenshot_changelog.svg \
        head -n50 CHANGELOG.md &
    PID_LIST="$PID_LIST $!"
    # parallel-task - screenshot files
    shRunWithScreenshotTxt .artifact/screenshot_package_listing.svg \
        shGitLsTree &
    PID_LIST="$PID_LIST $!"
    # parallel-task - screenshot logo
    shImageLogoCreate &
    PID_LIST="$PID_LIST $!"
    shPidListWait screenshot "$PID_LIST"
    # shCiArtifactUploadCustom
    if (command -v shCiArtifactUploadCustom >/dev/null)
    then
        shCiArtifactUploadCustom
    fi
    # 1px-border around browser-screenshot
    if (ls .artifact/screenshot_browser_*.png >/dev/null 2>&1)
    then
        gm mogrify -crop 798x598 -bordercolor black -border 1 \
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
        if [ -f .artifact/apidoc.html ]
        then
            cp -a .artifact/apidoc.html .
            git add -f apidoc.html
        fi
    fi
    # update README.md with branch-$GITHUB_BRANCH0 and $GITHUB_REPOSITORY
    sed -i.bak \
        -e "s|/branch-[a-z]*/|/branch-$GITHUB_BRANCH0/|g" \
        -e "s|\\b$UPSTREAM_GITHUB_IO\\b|$GITHUB_GITHUB_IO|g" \
        -e "s|\\b$UPSTREAM_REPOSITORY\\b|$GITHUB_REPOSITORY|g" \
        -e "s|_2fbranch-[a-z]*_2f|_2fbranch-${GITHUB_BRANCH0}_2f|g" \
        "branch-$GITHUB_BRANCH0/README.md" && \
        rm -f "branch-$GITHUB_BRANCH0/README.md".bak
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
# This function will run base-ci.
#
# shCiBaseCustom() {(set -e
# # This function will run custom-code for base-ci.
#     return
# )}
#
# shCiLintCustom() {(set -e
# # This function will run custom-code to lint files.
# )}
    export GITHUB_BRANCH0="$(git branch --show-current)"
    # Auto-correct common errors in package.json.
    # Check npm-version >= 10.0.0, before running npm-pkg-fix
    if [ "$(npm --version | cut -d"." -f1)" -ge 10 ]
    then
        npm pkg fix
    fi
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
import moduleChildProcess from "child_process";
import moduleFs from "fs";
(async function () {
    const fileDict = {};
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
                /(\[(?:main|master)<br>\()v\d\d\d\d\.\d\d?\.\d\d?\b[^)]*?(\))/g
            ), `$1v${versionMaster}$2`)
        }, {
            file: "package.json",
            src: fileDict["package.json"].replace((
                / {4}"version": "\d\d\d\d\.\d\d?\.\d\d?(?:-.*?)?"/
            ), `${" ".repeat(4)}"version": "${versionBeta}"`)
        }, {
            file: fileMain,
            // update version
            src: fileDict[fileMain].replace((
                /^const version = ".*?";$/m
            ), `const version = "v${versionBeta}";`)
        }
    ].map(async function ({
        file,
        src
    }) {
        const src0 = fileDict[file];
        if (src !== src0) {
            console.error(`update file ${file}`);
            fileModified = file;
            await moduleFs.promises.writeFile(file, src);
        }
    }));
    if (fileModified) {
        moduleChildProcess.spawn(
            "git",
            ["diff"],
            {stdio: ["ignore", 1, 2]}
        ).on("exit", function () {
            throw new Error("modified file " + fileModified);
        });
    }
}());
' # '
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
            case "\n\n\n<br><br>\n\n#":
                ii += 1;
                toc += "\n" + ii + ". [" + title + "](#";
                break;
            case "\n\n\n<br><br>\n\n###":
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
' # '
    FILE_LIST=""
    FILE_LIST="$FILE_LIST *.sh"
    for FILE in .ci.sh .ci2.sh
    do
        if [ -f "$FILE" ]
        then
            FILE_LIST="$FILE_LIST $FILE"
        fi
    done
    # shellcheck disable=SC2086
    shLintShell $FILE_LIST
    # check shell-functions in ascii-order
    for FILE in $FILE_LIST
    do
        if ! grep -o "^[A-Za-z_][A-Za-z0-9_]*() {" "$FILE" | sed "s/() {//" |
            LC_ALL=C sort -c
        then
            printf "%s - shell-functions not in ascii-order\n" "$FILE" >&2
            exit 1
        fi
    done
    JSLINT_BETA=1 node jslint.mjs .
    for FILE in .ci.sh .ci2.sh
    do
        if [ -f "$FILE" ]
        then
            JSLINT_BETA=1 node jslint.mjs "$FILE"
        fi
    done
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
    git --no-pager diff
)}

shCiMatrixIsmainName() {(set -e
# This function will return 0 if current ci-job is main job.
    CI_MATRIX_NAME="$(printf "%s" "$CI_MATRIX_NAME" | xargs)"
    [ "$CI_MATRIX_NAME" ] && [ "$CI_MATRIX_NAME" = "$CI_MATRIX_NAME_MAIN" ]
)}

shCiMatrixIsmainNodeversion() {(set -e
# This function will return 0 if current ci-job is main job.
    [ "$CI_MATRIX_NODE_VERSION" ] && \
        [ "$CI_MATRIX_NODE_VERSION" = "$CI_MATRIX_NODE_VERSION_MAIN" ]
)}

shCiPre() {(set -e
# This function will run pre-ci.
#
# shCiPreCustom() {(set -e
# # This function will run custom-code for pre-ci.
#     return
# )}
    if [ -f ./myci2.sh ]
    then
        . ./myci2.sh
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

shCiPublishNpm() {(set -e
# This function will publish npm-package.
#
# shCiPublishNpmCustom() {(set -e
# # This function will run custom-code to publish npm-package.
#     # npm publish --access public
# )}
    if [ ! -f package.json ] || \
        ! grep -Eq '^ {4}"shCiPublishNpm": 1,$' package.json
    then
        return
    fi
    # init package.json for npm-publish
    npm install
    # update package-name
    if [ "$NPM_REGISTRY" = github ]
    then
        sed -i.bak \
            -e "s|^    \"name\":.*|    \"name\": \"@$GITHUB_REPOSITORY\",|" \
            package.json && \
            rm -f package.json.bak
    fi
    if (command -v shCiPublishNpmCustom >/dev/null)
    then
        shCiPublishNpmCustom
    fi
)}

shCiPublishPypi() {(set -e
# This function will publish pypi-package.
#
# shCiPublishPypiCustom() {(set -e
# # This function will run custom-code to publish pypi-package.
#     # npm publish --access public
# )}
    if [ ! -f pyproject.toml ] || \
        ! grep -q '^shCiPublishPypi = 1$' pyproject.toml
    then
        return
    fi
    if (command -v shCiPublishPypiCustom >/dev/null)
    then
        shCiPublishPypiCustom
    fi
)}

shDirHttplinkValidate() {(set -e
# This function will validate http-links embedded in .html and .md files.
    # init $GITHUB_BRANCH0
    export GITHUB_BRANCH0="${GITHUB_BRANCH0:-alpha}"
    # init $UPSTREAM_XXX
    export UPSTREAM_REPOSITORY="$(sed -En \
        -e 's|.*"git\+https://github\.com/([^"]+)\.git".*|\1|p' \
        package.json
    )"
    if [ ! "$UPSTREAM_REPOSITORY" ]
    then
        printf "shDirHttplinkValidate - missing UPSTREAM_REPOSITORY\n" >&2
        exit 1
    fi
    export UPSTREAM_GITHUB_IO="$(
        printf "%s" "$UPSTREAM_REPOSITORY" | sed -e "s|/|.github.io/|"
    )"
    # init $GITHUB_XXX
    export GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-$UPSTREAM_REPOSITORY}"
    export GITHUB_GITHUB_IO="$(
        printf "%s" "$GITHUB_REPOSITORY" | sed -e "s|/|.github.io/|"
    )"
    node --input-type=module --eval '
import moduleAssert from "assert";
import moduleFs from "fs";
(async function () {
    const {
        GITHUB_BRANCH0,
        GITHUB_GITHUB_IO,
        GITHUB_REPOSITORY,
        UPSTREAM_GITHUB_IO,
        UPSTREAM_REPOSITORY
    } = process.env;
    const dict = {};
    Array.from(
        await moduleFs.promises.readdir(".")
    ).forEach(async function (file) {
        let data;
        if (
            file === "CHANGELOG.md" ||
            file.startsWith(".") ||
            !(/.\.html$|.\.md$/m).test(file)
        ) {
            return;
        }
        data = await moduleFs.promises.readFile(file, "utf8");
        // ignore link-rel-preconnect
        data = data.replace((
            /<link\b.+?\brel="preconnect".+?>/g
        ), "");
        data.replace((
            /\bhttps?:\/\/.+?([\s")\]]|\W?$)(<!--no-validate-->)?/gm
        ), function (url, removeLast, noValidate) {
            const timeStart = Date.now();
            if (removeLast && removeLast !== "/") {
                url = url.slice(0, -1);
            }
            url = url.replace((/["\u0027]/g), "");
            url = url.replace(
                (/\/branch-[a-z]+?\//g),
                `/branch-${GITHUB_BRANCH0}/`
            );
            url = url.replace(
                (/_2fbranch-[a-z]+?_2f/g),
                `_2fbranch-${GITHUB_BRANCH0}_2f`
            );
            url = url.replace(
                new RegExp(`\\b${UPSTREAM_REPOSITORY}\\b`, "g"),
                GITHUB_REPOSITORY
            );
            url = url.replace(
                new RegExp(`\\b${UPSTREAM_GITHUB_IO}\\b`, "g"),
                GITHUB_GITHUB_IO
            );
            if ((
                /^http:\/\/(?:127\.0\.0\.1|localhost|www\.w3\.org\/2000\/svg)(?:[\/:]|$)|^https:\/\/github\.com\/[\w.\-\/]+?\/compare\/[\w.\-\/]+?\.\.\.\w/m
            ).test(url) || noValidate) {
                return "";
            }
            moduleAssert.ok(
                !url.startsWith("http://"),
                `shDirHttplinkValidate - insecure-link - ${file} - ${url}`
            );
            // ignore duplicate-link
            if (dict.hasOwnProperty(url)) {
                return "";
            }
            dict[url] = true;
            fetch(url, {
                headers: {
                    "user-agent": "undefined"
                },
                redirect: "manual",
                signal: AbortSignal.timeout(60000)
            }).then(function (res) {
                console.error(
                    `shDirHttplinkValidate - ${res.status}` +
                    ` - ${file} - ${url} - ${Date.now() - timeStart}ms`
                );
                moduleAssert.ok(res.status < 400);
                res.body?.cancel();
            }, function (err) {
                console.error(
                    `shDirHttplinkValidate - error` +
                    ` - ${file} - ${url} - ${Date.now() - timeStart}ms`
                );
                throw err;
            });
            return "";
        });
        data.replace((
            /(\bhref=|\bsrc=|\burl\(|\[[^]+?\]\()("?.+?)(?:[")\]]|$)/gm
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
                        `shDirHttplinkValidate - ${Boolean(exists)}` +
                        ` - ${file} - ${url}`
                    );
                    moduleAssert.ok(exists);
                });
            }
            return "";
        });
    });
}());
' # '
)}

shDuList() {(set -e
# This function will du $1 and sort its subdir by size.
    du -md1 "$1" | sort -nr
)}

shGitCmdWithGithubToken() {(set -e
# This function will run git $CMD with $MY_GITHUB_TOKEN.
    printf "shGitCmdWithGithubToken %s\n" "$*"
    if [ -f .git/config ]
    then
        # security - scrub token from url
        sed -i.bak -e "s|://.*@|://|g" .git/config && \
            rm -f .git/config.bak
    fi
    CMD="$1"
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
    if (printf "%s" "$URL" | grep -qv "^https://")
    then
        URL="$(git config "remote.$URL.url")"
    fi
    if [ "$MY_GITHUB_TOKEN" ]
    then
        URL="$(
            printf "%s" "$URL" | \
            sed -e "s|https://|https://x-access-token:$MY_GITHUB_TOKEN@|"
        )"
    fi
    EXIT_CODE=0
    # hide $MY_GITHUB_TOKEN in case of err
    git "$CMD" "$URL" "$@" 2>/dev/null || EXIT_CODE="$?"
    printf "shGitCmdWithGithubToken - EXIT_CODE=%s\n" "$EXIT_CODE" 1>&2
    return "$EXIT_CODE"
)}

shGitCommitPushOrSquash() {(set -e
# This function will, if $COMMIT_COUNT > $COMMIT_LIMIT,
# then backup, squash, force-push,
# else normal-push.
    BRANCH="$(git branch --show-current)"
    COMMIT_MESSAGE="${1:-$(git --no-pager diff HEAD --stat)}"
    COMMIT_LIMIT="$2"
    MODE_NOBACKUP="$3"
    MODE_SQUASH="$4"
    git commit -am "$COMMIT_MESSAGE" || true
    COMMIT_COUNT="$(git rev-list --count HEAD)"
    if [ "$COMMIT_COUNT" -gt "$COMMIT_LIMIT" ]
    then
        MODE_SQUASH=squash
    fi
    printf "shGitCommitPushOrSquash \
COMMIT_COUNT=%s COMMIT_LIMIT=%s MODE_SQUASH=%s\n" \
        "$COMMIT_COUNT" "$COMMIT_LIMIT" "$MODE_SQUASH"
    if [ "$MODE_SQUASH" != squash ]
    then
        shGitCmdWithGithubToken push origin "$BRANCH"
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
    git branch -D __tmp1 2>/dev/null || true
    git checkout --orphan __tmp1
    git commit --quiet -am "$COMMIT_MESSAGE" || true
    # reset branch to squashed-commit
    git push . "__tmp1:$BRANCH" -f
    git checkout "$BRANCH"
    # force-push squashed-commit
    shGitCmdWithGithubToken push origin "$BRANCH" -f
)}

shGitGc() {(set -e
# This function will gc unreachable .git objects.
# http://stackoverflow.com/questions/3797907/how-to-remove-unused-objects-from-a-git-repository
    git remote prune origin
    git \
        -c gc.reflogExpire=0 \
        -c gc.reflogExpireUnreachable=0 \
        -c gc.rerereresolved=0 \
        -c gc.rerereunresolved=0 \
        -c gc.pruneExpire=now \
        gc
)}

shGitInitBase() {(set -e
# This function will git init && create basic git-template from jslint-org/base.
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
    sed -i.bak -e "s|owner/repo|${1:-owner/repo}|" .gitconfig && \
        rm -f .gitconfig.bak
    cp .gitconfig .git/config
    git commit -am "update owner/repo to $1" || true
)}

shGitLsTree() {(set -e
# This function will "git ls-tree" all files committed in HEAD.
# The sha256 column hashes the WORKING-TREE file, not the git blob,
# so it can be compared against a copy sent elsewhere with
# `sha256sum <file> | cut -c1-8`.
#
# example usage:
# shGitLsTree | sort -rk3 # sort by date
# shGitLsTree | sort -rk4 # sort by size
    node --input-type=module --eval '
import moduleChildProcess from "child_process";
import moduleCrypto from "crypto";
import moduleFs from "fs";
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
        /^(\S+?) +?\S+? +?\S+? +?(\S+?)\t(.+?)$/gm
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
    // get date, hash
    result.forEach(function (elem) {
        result[0].size += elem.size;
        elem.hash = "sha256  ";
        if (elem.file !== ".") {
            try {
                elem.hash = moduleCrypto.createHash(
                    "sha256"
                ).update(
                    moduleFs.readFileSync(elem.file) //jslint-ignore-line
                ).digest("hex").slice(0, 8);
            } catch (ignore) {
                elem.hash = "?".repeat(8);
            }
        }
        moduleChildProcess.spawn(
            "git",
            ["log", "--max-count=1", "--format=%at", "--", elem.file],
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
                String(ii + ".").padStart(iiPad, " ") +
                "  " + elem.mode +
                "  " + elem.date +
                "  " + String(
                    Math.ceil(elem.size / 1024)
                ).padStart(sizePad, " ") + " KB" +
                "  " + elem.hash +
                "  " + elem.file +
                "\n"
            );
        }).join(""));
    });
}());
' # '
)}

shGitSquashPop() {(set -e
# This function will squash HEAD to given $COMMIT.
# http://stackoverflow.com/questions/5189560
# /how-can-i-squash-my-last-x-commits-together-using-git
    COMMIT="$1"
    MESSAGE="$2"
    # reset git to previous $COMMIT
    git reset "$COMMIT"
    git add .
    # commit HEAD immediately after previous $COMMIT
    git commit --allow-empty -am "$MESSAGE" || true
    printf "\n\n\n\n"
    git --no-pager log -n 4
)}

shGithubCheckoutRemote() {(set -e
# This function will run like actions/checkout, except checkout remote-branch.
    # GITHUB_REF_NAME="owner/repo/branch"
    GITHUB_REF_NAME="$1"
    if (printf "%s" "$GITHUB_REF_NAME" | grep -q ".*/.*/.*")
    then
        # branch - */*/*
        git fetch origin alpha
        # assert latest ci
        if git rev-parse "$GITHUB_REF_NAME" 2>/dev/null && \
            [ "$(git rev-parse "$GITHUB_REF_NAME")" != \
                "$(git rev-parse origin/alpha)" ]
        then
            git push -f origin "origin/alpha:$GITHUB_REF_NAME"
            shGithubWorkflowDispatch "$GITHUB_REPOSITORY" "$GITHUB_REF_NAME"
            return 1
        fi
    else
        # branch - alpha, beta, master
        GITHUB_REF_NAME="$GITHUB_REPOSITORY/$GITHUB_REF_NAME"
    fi
    GITHUB_REPOSITORY="$(printf "%s" "$GITHUB_REF_NAME" | cut -d'/' -f1,2)"
    GITHUB_REF_NAME="$(printf "%s" "$GITHUB_REF_NAME" | cut -d'/' -f3)"
    # replace current git-checkout with $GITHUB_REF_NAME
    rm -rf ./* ./..?* ./.[!.]*
    shGitCmdWithGithubToken clone \
        "https://github.com/$GITHUB_REPOSITORY" __tmp1 \
        --branch="$GITHUB_REF_NAME" --depth=1 --single-branch
    mv __tmp1/.git .
    cp __tmp1/.gitconfig .git/config
    rm -rf __tmp1
    git reset "origin/$GITHUB_REF_NAME" --hard
    # fetch jslint_ci.sh from trusted source
    shGitCmdWithGithubToken fetch origin alpha:__tmp1 --depth=1 -f
    for FILE in .ci.sh .ci2.sh jslint_ci.sh myci2.sh
    do
        if [ -f "$FILE" ]
        then
            git checkout __tmp1 "$FILE"
        fi
    done
)}

shGithubCiWait() {(set -e
# This function will run shGithubPrFlow ci_wait.
#
# example usage:
# shGithubCiWait upstream/beta
# shGithubCiWait upstream/beta dispatch
    shGithubPrFlow ci_wait "$@"
)}

shGithubFileDownload() {(set -e
# This function will download file $1 from github repo/branch.
# https://docs.github.com/en/rest/reference/repos#create-or-update-file-contents
# example usage:
# shGithubFileDownload octocat/hello-world/master/hello.txt
    shGithubFileDownloadUpload download "$1" "$2"
)}

shGithubFileDownloadUpload() {(set -e
# This function will upload file $2 to github repo/branch $1.
# https://docs.github.com/en/rest/reference/repos#create-or-update-file-contents
# example usage:
# shGithubFileUpload octocat/hello-world/master/hello.txt hello.txt
    shGithubTokenExport
    node --input-type=module --eval '
import moduleAssert from "assert";
import moduleFs from "fs";
import modulePath from "path";
(async function () {
    let branch;
    let [mode, path, content] = process.argv.slice(1);
    let repo;
    let responseBuf;
    let url;
    async function httpRequest({
        method,
        payload
    }) {
        const res = await fetch(`${url}?ref=${branch}`, {
            body: payload,
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
        });
        responseBuf = Buffer.from(await res.arrayBuffer());
        moduleAssert.ok(
            (res.status < 400 || (res.status === 404 && mode === "upload")),
            (
                `shGithubFileUpload - ${res.status}` +
                ` - failed to download/upload file ${url} - ` +
                responseBuf.slice(0, 1024).toString()
            )
        );
    }
    console.error(
        mode === "download"
        ? `shGithubFileDownload - ${process.argv[2]}`
        : `shGithubFileUpload - ${process.argv[2]}`
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
# This function will upload file $2 to github repo/branch $1.
# https://docs.github.com/en/rest/reference/repos#create-or-update-file-contents
# example usage:
# shGithubFileUpload octocat/hello-world/master/hello.txt hello.txt
    shGithubFileDownloadUpload upload "$1" "$2"
)}

shGithubPrFlow() {(set -e
# This function will run one step of the pull-request and release flow on
# remote <origin|upstream>, where origin tests the flow on the fork. Every step
# is safe to re-run except create, since a pull-request is created once.
#
# branch <remote> <pr|release> [version] [squash-base]
#     commit pending changes onto alpha as a pull-commit built from
#     CHANGELOG.md, and push it to origin as branch-p<date> or
#     branch-v<version>
# create <remote> <pr|release> [issue,issue]
#     open its pull-request against beta
# merge | merge_rebase | merge_squash <remote>
#     wait for its github-ci, then merge it
# cleanup <remote>
#     after the merge, sync alpha, beta and, for a release, master, waiting for
#     github-ci after each push, delete the head-branch, and save the draft
#     github-release of a release
# release <remote>
#     save the draft github-release of master again
# publish <remote>
#     publish the draft github-release, which triggers publish.yml
# all <remote> <pr|release> [version] [squash-base]
#     branch, create, merge (pr) or merge_squash (release), and cleanup,
#     resuming by state, and never publish
# ci_wait <remote>/<branch> [dispatch]
#     wait for the newest github-ci runs on the commit at <remote>/<branch>
#
# example usage:
# sh jslint_ci.sh shGithubPrFlow branch upstream pr
# sh jslint_ci.sh shGithubPrFlow create upstream pr 519
# sh jslint_ci.sh shGithubPrFlow merge_squash upstream
# sh jslint_ci.sh shGithubPrFlow cleanup upstream
# sh jslint_ci.sh shGithubPrFlow all upstream pr v2026.11.1 __pr_beta_pre
# sh jslint_ci.sh shGithubPrFlow all upstream release v2026.11.1
# sh jslint_ci.sh shGithubPrFlow publish upstream
    shGithubTokenExport
    # The script passes the 32k command-line limit of windows, so feed it to
    # node on stdin, keeping the --eval form that jslint lints.
    node() {(set -e
        CODE="$3"
        shift 3
        printf "%s" "$CODE" | command node --input-type=module - "$@"
    )}
    node --input-type=module --eval '
import moduleAssert from "assert";
import moduleChildProcess from "child_process";
import moduleFs from "fs";
(async function () {
    const msCiInterval = 1000 * (
        process.env.MY_GITHUB_TOKEN
        ? 60
        : 120
    );
    const msCiTotal = 30 * 60 * 1000;
    // Argument 1 is "-", the script read from stdin.
    const [
        subcmd, ...argList
    ] = process.argv.slice(2);
    let modePr = "";
    let prText;
    let remote = "";
    async function all() {

// This function will run the flow of mode <pr|release> unattended, resuming by
// state. A saved draft or release ends a release. A merged pull-request goes to
// cleanup, as does HEAD at <remote>/beta with no pending change in mode pr. An
// open one at HEAD goes to merge, and else branch and create run first.

        const isRelease = argList[1] === "release";
        let found;
        let pr;
        let prState;
        let tagLog = "";
        let top;
        moduleAssert.ok(
            ["pr", "release"].includes(argList[1]),
            "shGithubPrFlow all - usage: all <origin|upstream> <pr|release>" +
            " [version] [squash-base]"
        );
        modePr = argList[1];
        if (isRelease) {
            top = await versionTop("", true);
            moduleAssert.ok(
                !argList[2] || versionNormalize(argList[2]) === top.version,
                `shGithubPrFlow all - CHANGELOG.md tops with v${top.version}` +
                `, not v${versionNormalize(argList[2])}`
            );
            tagLog = `v${top.version} `;
            found = await releaseFind(await repoOf(remote), `v${top.version}`);
        } else {
            await gitRun(["fetch", remote, "beta"]);
        }
        if (found) {
            // A draft or release of the tag on another commit is not done, as
            // when the version was not bumped.
            await gitRun(["fetch", remote, "master"]);
            moduleAssert.ok(
                found.target_commitish === await gitOutput([
                    "rev-parse", `${remote}/master`
                ]),
                `shGithubPrFlow all - v${top.version} targets` +
                ` ${found.target_commitish}, not ${remote}/master`
            );
            moduleAssert.ok(
                !(await gitOutput(["status", "--porcelain"])) &&
                // A hand commit past the release is unreleased too.
                await gitTryCode([
                    "diff", "--quiet", "HEAD", `${remote}/master`
                ]) === 0,
                `shGithubPrFlow all - change past ${remote}/master, but` +
                ` v${top.version} is already released - bump the version`
            );
            log(`v${top.version} already released, nothing to do`);
            return;
        }
        prState = await prGet(
            isRelease
            ? `branch-v${top.version}`
            : ""
        );
        pr = prState.merged;
        // A cleanup stopped after its reset leaves HEAD at <remote>/beta.
        if (pr || (
            !isRelease &&
            await gitOutput(["rev-parse", "HEAD"]) ===
            await gitOutput(["rev-parse", `${remote}/beta`]) &&
            !(await gitOutput(["status", "--porcelain"]))
        )) {
            log(
                pr
                ? `${tagLog}already merged - ${pr.html_url}`
                : `HEAD at ${remote}/beta with no pending change`
            );
        } else {
            pr = prState.open;
            if (!pr) {
                await branch();
                await create();
            } else {
                moduleAssert.ok(
                    pr.head.ref.startsWith("branch-v") === isRelease,
                    `shGithubPrFlow all - open ${pr.html_url} is not mode` +
                    ` ${modePr}`
                );
                // Merging the open pull-request would leave out a pending
                // change.
                moduleAssert.ok(
                    !(await gitOutput(["status", "--porcelain"])),
                    `shGithubPrFlow all - pending change, not in open` +
                    ` ${pr.html_url} - run branch first`
                );
                log(`${tagLog}already open - ${pr.html_url}`);
            }
            await merge(
                isRelease
                ? "merge_squash"
                : "merge"
            );
        }
        await cleanup();
        // A change made after the merge, or during its ci, is not in it.
        moduleAssert.ok(
            !(await gitOutput(["status", "--porcelain"])),
            "shGithubPrFlow all - cleaned up, but a pending change is left" +
            " for the next pull-request"
        );
    }
    async function branch() {

// This function will commit pending changes onto alpha as a pull-commit built
// from CHANGELOG.md, and push it to origin as branch-p<date> for mode pr, or
// branch-v<version> for mode release.

        const issueFile = (
            await gitTry([
                "grep", "--untracked", "-Eil", "-e", "^ *?(//|#) pr-xxx - "
            ])
        ).split("\n").filter(Boolean);
        const ownerOrigin = (await repoOf("origin")).split("/")[0];
        const repoUpstream = await upstreamRepo();
        let branchPull = "";
        let branchSquash = "HEAD";
        let changelogNew;
        let changelogOld;
        let commitMessage;
        let fileList;
        let head;
        let pr;
        let prBranch = "";
        let prXxx;
        let preSha;
        let res;
        let tip;
        let top;
        let version;
        await modeParse();
        await gitRun(["fetch", remote, "beta"]);
        // Take the number of the newest pull-commit since <remote>/beta, so a
        // hand commit atop it keeps the number its tags carry.
        prXxx = (/^- (PR-\d+) /m).exec(await gitOutput([
            "log", "--format=%s", `${remote}/beta..HEAD`
        ]))?.[1];
        head = await gitOutput(["rev-parse", "HEAD"]);
        top = await versionTop("", modePr === "release");
        version = versionNormalize(
            argList[2] || new Date().toISOString().slice(0, 10)
        );
        if (modePr === "release") {
            moduleAssert.ok(
                !argList[2] || version === top.version,
                `shGithubPrFlow branch - CHANGELOG.md tops with` +
                ` v${top.version}` +
                `, not v${version}`
            );
            version = `v${top.version}`;
            branchPull = `branch-${version}`;
            moduleAssert.ok(
                !(await releaseFind(await repoOf(remote), version)),
                `shGithubPrFlow branch - ${version} already released`
            );
        }
        // A pull-request merged at HEAD, or of this release, is done, so a
        // re-run goes to cleanup rather than push a second one. An earlier one
        // merged from a branch of the same name, on the same day, is not.
        pr = (await prGet(branchPull)).merged;
        moduleAssert.ok(
            !pr,
            "shGithubPrFlow branch - already merged - run cleanup" + (
                // A fix merged over a release would keep it from master.
                pr?.head.ref.startsWith("branch-v")
                ? `, after a failed ci on ${remote}/beta passes on re-run`
                : `, or if ${remote}/beta fails its ci, git reset` +
                ` ${remote}/beta and branch the fix`
            ) + ` - ${pr?.html_url}`
        );
        // A pull-commit on an alpha that lacks <remote>/beta squashes nothing
        // and stacks an empty duplicate on a re-run. A merge, checked above,
        // also leaves alpha lacking it.
        moduleAssert.ok(
            await isSquashBase("HEAD"),
            `shGithubPrFlow branch - HEAD lacks ${remote}/beta - merge it first`
        );
        // Give the shell a sha, never the text of the argument.
        if (argList[3]) {
            branchSquash = await gitTry([
                "rev-parse", "--verify", `${argList[3]}^{commit}`
            ]);
            moduleAssert.ok(
                branchSquash && await isSquashBase(branchSquash),
                `shGithubPrFlow branch - squash-base ${argList[3]} is not a` +
                ` commit between ${remote}/beta and HEAD`
            );
        }
        // Keep the number of HEAD on re-run, so a pushed fix keeps the number
        // its tags carry, if github has no issue of that number yet, or it is
        // the still-open pull-request from origin, whose branch then gets the
        // push on any later day.
        if (prXxx) {
            res = await githubRequest(
                "GET",
                `/repos/${repoUpstream}/issues/${prXxx.slice(3)}`
            );
            moduleAssert.ok(
                [200, 404].includes(res.status),
                `shGithubPrFlow branch - read ${prXxx} - ${res.status}` +
                ` ${res.text}`
            );
        }
        if (!prXxx) {
            res = await githubRequest(
                "GET",
                `/repos/${repoUpstream}/issues?per_page=1&state=all`
            );
            moduleAssert.ok(
                res.json?.[0]?.number,
                `shGithubPrFlow branch - cannot read newest issue` +
                ` - ${res.status}`
            );
            prXxx = `PR-${res.json[0].number + 1}`;
        } else if (res.status === 404) {
            log(`keep unused ${prXxx}`);
        } else {
            res = await githubRequest(
                "GET",
                `/repos/${repoUpstream}/pulls/${prXxx.slice(3)}`
            );
            moduleAssert.ok(
                [200, 404].includes(res.status),
                `shGithubPrFlow branch - read pull-request ${prXxx}` +
                ` - ${res.status} ${res.text}`
            );
            prBranch = (
                (
                    res.json?.state === "open" &&
                    // Github owners are case-insensitive.
                    res.json.head?.label?.toLowerCase().startsWith(
                        `${ownerOrigin.toLowerCase()}:`
                    )
                )
                ? res.json.head.label.slice(ownerOrigin.length + 1)
                : ""
            );
            // A taken number stays in the pull-commit, so only a reset drops
            // it, and its tags would go stale under a new number.
            moduleAssert.ok(
                prBranch,
                `shGithubPrFlow branch - ${prXxx} is taken upstream - git` +
                ` reset ${remote}/beta, write its tags back as pr-xxx, then` +
                " re-run, or if github opened it as #M, write them as PR-M"
            );
            // Only a branch-* head is found again at merge and create, and the
            // push goes to that name unchanged. A slash in it escapes the
            // branch-* glob create finds it by, and branch-v* is a release.
            moduleAssert.ok(
                (/^branch-(?!v)[\w.\-]+$/).test(prBranch),
                `shGithubPrFlow branch - open ${prXxx} is on ${prBranch},` +
                " not a pr-mode branch-* head"
            );
            log(`keep open ${prXxx} on ${prBranch}`);
        }
        if (modePr === "release") {
            commitMessage = `# ${version}\n${top.body}`;
        } else {
            // Name only items missing from <remote>/beta CHANGELOG.md, so the
            // message repeats no released item.
            changelogNew = top.body.split(/\n(?=- )/);
            changelogOld = (
                await gitTry([
                    "show",
                    `refs/remotes/${remote}/beta:CHANGELOG.md`
                ])
            ).replace((/\r/g), "").split("\n");
            changelogNew = changelogNew.filter(function (item) {
                return !changelogOld.includes(item.split("\n")[0]);
            });
            moduleAssert.ok(
                changelogNew.length > 0,
                `shGithubPrFlow branch - CHANGELOG.md top section has no item` +
                ` missing from ${remote}/beta:CHANGELOG.md`
            );
            commitMessage = String(
                `- ${prXxx} ${changelogNew.join("\n")}`
            ).replace("\n", "\n\n");
            // A kept open pull-request takes the push on its own head-branch.
            branchPull = prBranch || `branch-p${version}`;
            pr = (await prGet(branchPull)).open;
            // An open pr-mode pull-request, as on a re-run on origin, numbered
            // apart from upstream, is kept too, if the tip check below finds
            // its head in HEAD.
            if (!prBranch && (/^branch-(?!v)[\w.\-]+$/).test(pr?.head.ref)) {
                branchPull = pr.head.ref;
            }
            // Never force-push over another open pull-request at HEAD, which
            // create inside all would then adopt.
            moduleAssert.ok(
                !pr || pr.head.ref === branchPull,
                `shGithubPrFlow branch - ${pr?.html_url} is open on` +
                ` ${pr?.head.ref} - merge or close it first`
            );
        }
        // A re-run, with no squash given, rebuilds everything since the last
        // squash base, rather than stack a duplicate, an origin test merge or
        // a hand fix on it.
        preSha = await gitTry([
            "rev-parse", "--verify", `refs/heads/__pr_${branchMerge()}_pre`
        ]);
        if (
            !argList[3] &&
            preSha &&
            preSha !== head &&
            await isSquashBase(preSha)
        ) {
            branchSquash = `__pr_${branchMerge()}_pre`;
            log(`re-run, squash ${branchSquash}`);
        }
        // A pull-commit with nothing in it would push the commits under it
        // unsquashed, and still exit 0.
        moduleAssert.ok(
            (
                modePr === "release" ||
                issueFile.length > 0 ||
                await gitOutput(["rev-parse", branchSquash]) !== head ||
                await gitOutput(["status", "--porcelain"])
            ),
            "shGithubPrFlow branch - nothing to commit - pass a squash-base"
        );
        // The push goes to origin for either remote, so never over a commit
        // HEAD lacks, such as of a pull-request on the other remote, and the
        // lease on the push keeps it so through the slow test.
        tip = (
            await gitOutput(["ls-remote", "origin", `refs/heads/${branchPull}`])
        ).split("\t")[0];
        moduleAssert.ok(
            !tip || await gitTryCode([
                "merge-base", "--is-ancestor", tip, "HEAD"
            ]) === 0,
            `shGithubPrFlow branch - origin ${branchPull} holds ${tip},` +
            " not in HEAD - delete it after its pull-request merges or closes"
        );
        prText = prTextCreate(commitMessage, "");
        // Test before the tags are written, so a stop in the slow test leaves
        // pr-xxx in place.
        moduleAssert.ok(
            await shRun(`
(set -e
    . ./jslint_ci.sh
    npm run test2
    shDirHttplinkValidate
)
            `) === 0,
            "shGithubPrFlow branch - test failed"
        );
        // Write the tags last, and put pr-xxx back if the push fails, so a
        // re-run numbers them afresh rather than leave a stale number.
        fileList = await Promise.all(issueFile.map(async function (file) {
            const data = await moduleFs.promises.readFile(file, "utf8");
            await moduleFs.promises.writeFile(file, data.replace(
                (/^( *)(\/\/|#) pr-xxx - /gim),
                `$1$2 ${prXxx} - `
            ));
            return [file, data];
        }));
        // security - The message lands in a single-quoted shell string.
        commitMessage = commitMessage.trim().replace((/\u0027/g), "$&\"$&\"$&");
        if (await shRun(`
(set -e
    . ./jslint_ci.sh
    git reset "${branchSquash}"
    git push . HEAD:__pr_"${branchMerge()}"_pre -f
    shGitSquashPop alpha \u0027${commitMessage}\u0027
    [ "$(git rev-parse HEAD)" != \
        "$(git rev-parse __pr_"${branchMerge()}"_pre)" ]
    git push . HEAD:__pr_"${branchMerge()}" -f
    git --no-pager diff "${tip || "HEAD"}"
    git push --atomic origin +alpha:alpha alpha:"${branchPull}" \
        --force-with-lease=refs/heads/"${branchPull}":"${tip}"
    printf "\n\n\n\n"
    git --no-pager log -n 4
)
        `) !== 0) {
            await Promise.all(fileList.map(function ([file, data]) {
                return moduleFs.promises.writeFile(file, data);
            }));
            // Put HEAD back too, so the number of its pull-commit survives.
            await gitRun(["reset", head]);
            moduleAssert.ok(false, "shGithubPrFlow branch - push failed");
        }
        prTextPrint();
    }
    function branchMerge() {
        return (
            modePr === "release"
            ? "master"
            : "beta"
        );
    }
    async function branchPushed() {

// This function will name the head-branch the push of HEAD made, which a kept
// pull-request or a push on an earlier day names apart from today, or "".

        const branchList = (
            await gitOutput([
                "for-each-ref",
                "--points-at",
                "HEAD",
                "--format=%(refname:lstrip=3)",
                "refs/remotes/origin/branch-*"
            ])
        ).split("\n").filter(Boolean);
        moduleAssert.ok(
            branchList.length <= 1,
            `shGithubPrFlow ${subcmd} - several branches hold HEAD` +
            ` - ${branchList}`
        );
        return branchList[0] || "";
    }
    async function ciPoll({describe, isOldOk, label, name, path, runListGet}) {

// This function will poll github <path> until its runs all pass and settle,
// failing on a failed run, on no run in 5 minutes, or at 30 minutes. A changed
// run list restarts the settle-time, so a late workflow is caught.

        // A push of a commit that ran before still starts new runs within
        // seconds, so trust only old runs after this wait.
        const msLate = 15 * 1000;
        const msNorun = 5 * 60 * 1000;
        const msSettle = 60 * 1000;
        const timeStart = Date.now();
        let key;
        let keyPrv = "";
        let line = "";
        let msNow = 0;
        let msSeen = 0;
        let result;
        let runList;
        let runListBad;
        function logTick(message) {
            log(
                `${label} - ` +
                `${Math.floor(msElapsed() / 60000)}m / ${msCiTotal / 60000}m` +
                ` - ${message}`,
                name
            );
        }
        function msElapsed() {
            return Date.now() - timeStart;
        }
        function runIsDone(run) {
            return run.status === "completed";
        }
        function runIsOld(run) {
            // A run done a settle-time ago, by the clock of github, had its own
            // settle-time for a late workflow, as on a re-run.
            return msNow - Date.parse(run.updated_at) >= msSettle;
        }
        while (true) {
            result = await githubRequest("GET", path).catch(function (err) {
                return {status: 0, text: err.message};
            });
            // A 403 with no rate-limit headers is a forbidden token, not a
            // limit.
            moduleAssert.ok(
                !(
                    [401, 404, 422].includes(result.status) ||
                    (result.status === 403 && !result.retryMs)
                ),
                `shGithubPrFlow ${name} - ${label}` +
                ` - ${result.status} ${result.text}`
            );
            if (result.status === 200) {
                // Both run lists hold one page of 100.
                moduleAssert.ok(
                    !(result.json.total_count > 100),
                    `shGithubPrFlow ${name} - ${label} - too many runs` +
                    ` - ${result.json.total_count}`
                );
                msNow = Date.parse(result.date);
                runList = runListGet(result.json);
                line = (
                    runList.length > 0
                    ? describe(runList)
                    : "no run yet"
                );
                // Print every poll, so a long wait shows it is alive.
                logTick(line);
                moduleAssert.ok(
                    runList.length > 0 || msElapsed() < msNorun,
                    `shGithubPrFlow ${name} - ${label}` +
                    " - no run found in 5 minutes"
                );
                runListBad = runList.filter(function (run) {
                    return runIsDone(run) && ![
                        "neutral", "skipped", "success"
                    ].includes(run.conclusion);
                });
                moduleAssert.ok(
                    runListBad.length === 0,
                    `shGithubPrFlow ${name} - ${label} - failed - ` +
                    runListBad.map(function (run) {
                        return `${run.name} ${run.conclusion} ${run.html_url}`;
                    }).join(", ")
                );
                key = runList.map(function (run) {
                    return run.workflow_id || run.id;
                }).sort().join();
                if (key !== keyPrv) {
                    msSeen = msElapsed();
                    keyPrv = key;
                }
                if (
                    runList.length > 0 &&
                    runList.every(runIsDone) && (
                        msElapsed() - msSeen >= msSettle ||
                        (
                            isOldOk &&
                            msElapsed() >= msLate &&
                            runList.every(runIsOld)
                        )
                    )
                ) {
                    log(`${label} - ok`, name);
                    return;
                }
            } else {
                logTick(
                    `retry after ${result.status}` +
                    ` ${String(result.text).slice(0, 200)}`
                );
            }
            moduleAssert.ok(
                !(result.retryMs && result.retryMs > msCiTotal - msElapsed()),
                `shGithubPrFlow ${name} - rate-limited past the deadline` +
                ` - ${result.text}`
            );
            moduleAssert.ok(
                msElapsed() < msCiTotal,
                `shGithubPrFlow ${name} - ${label}` +
                ` - no result in 30 minutes - ${line}`
            );
            // Sleep no later than the deadline, so one last poll runs there.
            await new Promise(function (resolve) {
                setTimeout(resolve, Math.max(0, Math.min(
                    Math.max(msCiInterval, result.retryMs || 0),
                    msCiTotal - msElapsed()
                )));
            });
        }
    }
    async function ciWait(remoteName, branchName, mode) {

// This function will wait for the newest github-ci runs on the commit at
// <remoteName>/<branchName>. Mode dispatch first triggers workflow ci.yml on
// <branchName>, then waits only for runs created after that.

        const repo = await repoOf(remoteName);
        const sha = await gitOutput([
            "rev-parse", `refs/remotes/${remoteName}/${branchName}`
        ]);
        let msDispatch = 0;
        let result;
        moduleAssert.ok(
            !mode || mode === "dispatch",
            `shGithubPrFlow ci_wait - unknown mode "${mode}"`
        );
        if (mode === "dispatch") {
            result = await githubRequest(
                "POST",
                `/repos/${repo}/actions/workflows/ci.yml/dispatches`,
                {ref: branchName}
            );
            moduleAssert.ok(
                result.status === 204,
                `shGithubPrFlow ci_wait - dispatch - ${result.status}` +
                ` ${result.text}`
            );
            // Use the clock of github, which stamps the run, minus 5s of skew.
            msDispatch = Date.parse(result.date) - 5000;
        }
        await ciPoll({
            describe: function (runList) {
                return runList.map(function (run) {
                    return `${run.name} ${run.status} ${run.conclusion}`;
                }).join(", ");
            },
            isOldOk: true,
            label: `${repo} ${branchName}`,
            name: "ci_wait",
            path: (
                `/repos/${repo}/actions/runs` +
                `?branch=${encodeURIComponent(branchName)}` +
                `&head_sha=${sha}&per_page=100`
            ),
            runListGet: function (json) {
                // Keep the newest push or dispatch run of each workflow, as a
                // later entry of the same workflow overwrites an earlier one.
                return Object.values(Object.fromEntries(
                    json.workflow_runs.filter(function (run) {
                        return (
                            ["push", "workflow_dispatch"].includes(run.event) &&
                            Date.parse(run.created_at) >= msDispatch
                        );
                    }).sort(function (aa, bb) {
                        return aa.run_number - bb.run_number;
                    }).map(function (run) {
                        return [run.workflow_id, run];
                    })
                ));
            }
        });
    }
    async function cleanup() {

// This function will cleanup the pull-request merged into beta of <remote>,
// waiting for github-ci after each push, and deleting the head-branch only
// after all ci passes. After a release, it saves the draft github-release.
// It writes nothing before its checks pass, so re-run it after a fix.

        const repoOrigin = await repoOf("origin");
        const repoRemote = await repoOf(remote);
        let headSha;
        let isOrigin;
        let isRefV;
        let isRelease;
        let pr;
        let res;
        let sha;
        let tag;
        await gitRun(["checkout", "alpha"]);
        await gitRun(["fetch", remote, "beta"]);
        // A killed git exits null, never 0.
        moduleAssert.ok(
            await gitTryCode([
                "--no-pager", "diff", "--stat", "--exit-code", "alpha",
                `${remote}/beta`
            ]) === 0,
            `shGithubPrFlow cleanup - alpha differs from ${remote}/beta`
        );
        sha = await gitOutput(["rev-parse", `${remote}/beta`]);
        res = await githubRequest(
            "GET",
            `/repos/${repoRemote}/pulls` +
            "?state=closed&base=beta&sort=updated&direction=desc&per_page=100"
        );
        pr = res.json && res.json.find(function (elem) {
            return elem.merged_at && elem.merge_commit_sha === sha;
        });
        moduleAssert.ok(
            pr,
            `shGithubPrFlow cleanup - no pull-request of ${repoRemote}` +
            ` merged as ${sha} - ${res.status}`
        );
        // Origin is the owner of the head label, as <prGet> finds it, so
        // a renamed fork is still origin. Github owners are case-insensitive.
        isOrigin = String(pr.head.label).toLowerCase().startsWith(
            `${repoOrigin.split("/")[0].toLowerCase()}:`
        );
        isRefV = pr.head.ref.startsWith("branch-v");
        // Release only a branch-v* head from origin, so a contributor branch of
        // that name cannot push master.
        isRelease = isOrigin && isRefV;
        // All names a mode, which the merged pull-request must match, however
        // all reached here.
        moduleAssert.ok(
            modePr !== "pr" || !isRefV,
            `shGithubPrFlow ${subcmd} - merged ${pr.html_url} is a release,` +
            " not mode pr"
        );
        moduleAssert.ok(
            modePr !== "release" || isRelease,
            `shGithubPrFlow ${subcmd} - merged ${pr.html_url} from` +
            ` ${pr.head.label} is not a release of ${repoOrigin}`
        );
        log(`merged ${pr.head.ref}`);
        if (!isOrigin && isRefV) {
            log("head-branch not in origin, no release");
        }
        // A release pushes beta to <remote>/master without force, so check it
        // fast-forwards before the first push.
        if (isRelease) {
            await gitRun(["fetch", remote, "master"]);
            moduleAssert.ok(
                await gitTryCode([
                    "merge-base", "--is-ancestor", `${remote}/master`, sha
                ]) === 0,
                `shGithubPrFlow cleanup - ${remote}/master is not in` +
                ` ${remote}/beta`
            );
            // A tag with no release would take the release. One with its own
            // release is a re-run.
            tag = `v${(await versionTop(sha, true)).version}`;
            res = await releaseFind(repoRemote, tag);
            moduleAssert.ok(
                !res || res.target_commitish === sha,
                `shGithubPrFlow cleanup - ${tag} exists for` +
                ` ${res?.target_commitish}, not ${sha} - ${res?.html_url}`
            );
            if (!res) {
                await tagAssertNone(repoRemote, tag);
            }
        }
        await ciWait(remote, "beta");
        // Keep the backup of the pre-merge alpha on a re-run.
        if (await gitOutput(["rev-parse", "alpha"]) !== sha) {
            await gitRun(["push", ".", "alpha:__pr_upstream_pre", "-f"]);
        }
        await gitRun(["reset", `${remote}/beta`]);
        await gitRun(["push", ".", "alpha:beta", "-f"]);
        await gitRun(["push", "origin", "alpha", "beta", "-f"]);
        await ciWait("origin", "alpha");
        await ciWait("origin", "beta");
        if (remote === "upstream") {
            await gitRun(["push", "upstream", "alpha", "-f"]);
            await ciWait("upstream", "alpha");
        }
        if (isRelease) {
            // Local master mirrors <remote>/master, and so does origin/master
            // for upstream, so only <remote>/master guards against a
            // non-fast-forward, and a test on origin cannot block the real
            // release after it.
            await gitRun(["push", ".", "beta:master", "-f"]);
            if (remote === "upstream") {
                await gitRun(["push", "origin", "master", "-f"]);
                await ciWait("origin", "master");
            }
            await gitRun(["push", remote, "master"]);
            await ciWait(remote, "master");
        }
        // Delete the head-branch only if it still holds the merged commit,
        // since a second pull-request on the same day reuses its name.
        headSha = (
            await gitOutput([
                "ls-remote", "origin", `refs/heads/${pr.head.ref}`
            ])
        ).split("\t")[0];
        if (!isOrigin || !pr.head.ref.startsWith("branch-")) {
            // Delete only a branch this flow pushed, never a master head.
            log("head-branch not a branch-* in origin, kept");
        } else if (!headSha) {
            log("head-branch already deleted");
        } else if (headSha !== pr.head.sha) {
            log("head-branch moved since merge, kept");
        } else {
            await gitRun([
                "push",
                "origin",
                `--force-with-lease=refs/heads/${pr.head.ref}:${pr.head.sha}`,
                `:refs/heads/${pr.head.ref}`
            ]);
        }
        await gitRun(["push", ".", "alpha:__pr_upstream", "-f"]);
        if (isRelease) {
            await release();
        }
    }
    async function create() {

// This function will open the pull-request of the branch pushed for HEAD,
// against beta of <remote>. A pull-request is created once, so a re-run on an
// open one fails.

        // Open only on the head-branch the push of HEAD made, never on one
        // whose content HEAD has moved past since.
        const branchPull = await branchPushed();
        const commitMessage = await gitOutput(["log", "-1", "--format=%B"]);
        const ownerOrigin = (await repoOf("origin")).split("/")[0];
        const prNumber = Number((/^- PR-(\d+) /).exec(commitMessage)?.[1]);
        const repoRemote = await repoOf(remote);
        let pr;
        let res;
        await modeParse();
        moduleAssert.ok(
            branchPull,
            "shGithubPrFlow create - no branch-* holds HEAD - run branch"
        );
        // Only create itself takes an issue list, since all puts the version
        // there.
        prText = prTextCreate(
            commitMessage,
            (subcmd === "create" && argList[2]) || ""
        );
        prTextPrint();
        pr = (await prGet(branchPull)).open;
        if (pr) {
            // A re-run of create fails, since it opens nothing, but all goes
            // on to merge the pull-request that branch kept open.
            moduleAssert.ok(
                subcmd === "all",
                `shGithubPrFlow create - already open - ${pr.html_url}`
            );
            log(`pull-request already open - ${pr.html_url}`);
            return;
        }
        // A test on origin gets a number of the fork, so skip the check.
        if (modePr === "pr" && remote === "upstream") {
            // Github numbers issues and pull-requests in one sequence, so
            // the newest must sit just below the number the tags carry.
            res = await githubRequest(
                "GET",
                `/repos/${await upstreamRepo()}/issues?per_page=1&state=all`
            );
            moduleAssert.ok(
                res.json?.[0]?.number === prNumber - 1,
                `shGithubPrFlow create - newest issue is` +
                ` #${res.json?.[0]?.number}` +
                `, so github will not number this PR-${prNumber}`
            );
        }
        res = await githubRequest("POST", `/repos/${repoRemote}/pulls`, {
            base: "beta",
            body: prText.description,
            head: `${ownerOrigin}:${branchPull}`,
            title: prText.title
        });
        moduleAssert.ok(
            res.status === 201,
            `shGithubPrFlow create - ${res.status} ${res.text}`
        );
        moduleAssert.ok(
            (
                modePr === "release" ||
                remote === "origin" ||
                res.json.number === prNumber
            ),
            `shGithubPrFlow create - github numbered ${res.json.html_url}` +
            `, not PR-${prNumber}, so fix the tags and title`
        );
        log(`opened ${res.json.html_url}`);
    }
    function fileRead(sha, file) {
        return (
            sha
            ? gitOutput(["show", `${sha}:${file}`])
            : moduleFs.promises.readFile(file, "utf8")
        );
    }
    async function gitOutput(list) {
        return (await new Promise(function (resolve, reject) {
            moduleChildProcess.execFile(
                "git",
                list,
                {encoding: "utf8", maxBuffer: 256 * 1024 * 1024},
                function (err, stdout) {
                    return (
                        err
                        ? reject(err)
                        : resolve(stdout)
                    );
                }
            );
        })).trim();
    }
    async function gitRun(list) {
        moduleAssert.ok(
            await gitTryCode(list) === 0,
            `shGithubPrFlow ${subcmd} - git ${list.join(" ")} failed`
        );
    }
    function gitTry(list) {
        return gitOutput(list).catch(function () {
            return "";
        });
    }
    function gitTryCode(list) {
        return new Promise(function (resolve) {
            moduleChildProcess.spawn("git", list, {
                stdio: ["ignore", 1, 2]
            }).on("exit", resolve);
        });
    }
    async function githubRequest(method, path, body) {
        const res = await fetch(`https://api.github.com${path}`, {
            body: body && JSON.stringify(body),
            headers: {
                accept: "application/vnd.github+json",
                "x-github-api-version": "2022-11-28",
                ...(process.env.MY_GITHUB_TOKEN && {
                    authorization: `Bearer ${process.env.MY_GITHUB_TOKEN}`
                })
            },
            method
        });
        const text = await res.text();
        return {
            date: res.headers.get("date"),
            json: (res.ok && text) && JSON.parse(text),
            // Rate-limited, so retry after the time github asks for.
            retryMs: (
                (res.headers.get("retry-after") && (
                    1000 * Number(res.headers.get("retry-after"))
                )) || (
                    res.headers.get("x-ratelimit-remaining") === "0" &&
                    1000 * Number(res.headers.get("x-ratelimit-reset")) -
                    Date.now()
                )
            ),
            status: res.status,
            text
        };
    }
    async function isSquashBase(sha) {

// This function will check <sha> lies between <remote>/beta and HEAD, so a
// pull-commit squashed onto it holds only this change.

        return (
            await gitTryCode([
                "merge-base", "--is-ancestor", `${remote}/beta`, sha
            ]) === 0 &&
            await gitTryCode(["merge-base", "--is-ancestor", sha, "HEAD"]) === 0
        );
    }
    function log(message, name = subcmd) {
        console.error(
            new Date().toISOString().replace((/\.\d+Z$/), "Z") +
            ` - shGithubPrFlow ${name} - ${message}`
        );
    }
    async function merge(name) {

// This function will wait for the github-ci of the open pull-request of HEAD,
// then merge it with the message github offers. A squash instead keeps the
// pull-commit message plus " (#N)", since a pr-mode pull-request carries every
// alpha commit since beta, and the default lists them all, dropping PR-xxx.

        const modeMerge = name.replace((/^merge_?/), "") || "merge";
        const repoRemote = await repoOf(remote);
        let commitMessage;
        let pr;
        let prState;
        let res;
        let sha;
        prState = await prGet(await branchPushed());
        pr = prState.open;
        // Merged by hand at HEAD is done, so a chained cleanup still runs.
        if (!pr) {
            pr = prState.merged;
            moduleAssert.ok(
                pr,
                `shGithubPrFlow ${name} - no open or merged pull-request` +
                " of HEAD, or HEAD moved since branch - run branch"
            );
            log(`already merged ${pr.html_url}`, name);
            return;
        }
        sha = pr.head.sha;
        // Merge nothing pushed to the head-branch by another clone.
        moduleAssert.ok(
            sha === await gitOutput(["rev-parse", "HEAD"]),
            `shGithubPrFlow ${name} - open ${pr.html_url} is not at HEAD`
        );
        // Github may number a pull-request apart from its tags, as when an
        // issue opens during create, which then fails with it open.
        commitMessage = await gitOutput(["log", "-1", "--format=%B", sha]);
        moduleAssert.ok(
            (
                remote === "origin" ||
                pr.head.ref.startsWith("branch-v") ||
                commitMessage.startsWith(`- PR-${pr.number} `)
            ),
            `shGithubPrFlow ${name} - github numbered ${pr.html_url}` +
            `, not the PR-N of its tags`
        );
        // The check-runs of the pull-request repo include its own pull_request
        // runs, which a push-only wait skips.
        await ciPoll({
            describe: function (runList) {
                return runList.filter(function (run) {
                    return run.status === "completed";
                }).length + ` of ${runList.length} done`;
            },
            isOldOk: false,
            label: `${repoRemote}#${pr.number}`,
            name,
            path: `/repos/${repoRemote}/commits/${sha}/check-runs?per_page=100`,
            runListGet: function (json) {
                return json.check_runs;
            }
        });
        res = await githubRequest(
            "PUT",
            `/repos/${repoRemote}/pulls/${pr.number}/merge`,
            {
                merge_method: modeMerge,
                // Merge only the commit ci passed on.
                sha,
                ...(modeMerge === "squash" && {
                    commit_message: commitMessage.replace((/^.*\n*/), ""),
                    commit_title: (
                        `${commitMessage.split("\n")[0]} (#${pr.number})`
                    )
                })
            }
        );
        moduleAssert.ok(
            res.status === 200,
            `shGithubPrFlow ${name} - ${res.status} ${res.text}`
        );
        log(`${modeMerge} ${pr.html_url} as ${res.json.sha}`, name);
    }
    async function modeParse() {
        modePr = argList[1];
        moduleAssert.ok(
            ["pr", "release"].includes(modePr),
            `shGithubPrFlow ${subcmd} - usage: ${subcmd} <origin|upstream>` +
            " <pr|release> ..."
        );
        moduleAssert.ok(
            await gitOutput(["rev-parse", "--abbrev-ref", "HEAD"]) === "alpha",
            `shGithubPrFlow ${subcmd} - checkout alpha first`
        );
    }
    async function prGet(name) {

// This function will find the open and the merged pull-request from a branch-*
// head of origin, at HEAD, or by head-branch <name>, open, or merged for a
// branch-v release, since github updates a head sha only after a push.

        const head = await gitOutput(["rev-parse", "HEAD"]);
        const ownerOrigin = (await repoOf("origin")).split("/")[0];
        const res = await githubRequest(
            "GET",
            `/repos/${await repoOf(remote)}/pulls` +
            "?state=all&base=beta&sort=updated&direction=desc&per_page=100"
        );
        let list;
        moduleAssert.ok(
            res.status === 200,
            `shGithubPrFlow ${subcmd} - ${res.status} ${res.text}`
        );
        // Github owners are case-insensitive.
        list = res.json.filter(function (elem) {
            return (
                String(elem.head.label).toLowerCase().startsWith(
                    `${ownerOrigin.toLowerCase()}:branch-`
                ) &&
                (elem.head.sha === head || (
                    // A pr branch is named by its day, so a merged one of
                    // that name may be an earlier pull-request.
                    elem.head.ref === name &&
                    (name.startsWith("branch-v") || elem.state === "open")
                ))
            );
        });
        moduleAssert.ok(
            list.filter(function (elem) {
                return elem.state === "open";
            }).length <= 1,
            `shGithubPrFlow ${subcmd} - several open pull-requests of HEAD`
        );
        return {
            merged: list.find(function (elem) {
                return elem.merged_at;
            }),
            open: list.find(function (elem) {
                return elem.state === "open";
            })
        };
    }
    function prTextCreate(message, issue) {

// This function will build the pull-request title and description from the
// pull-commit message, checking them before anything is written.

        const lineList = message.trim().split("\n");
        const rest = lineList.slice(1).join("\n").trim();
        const title = (
            modePr === "release"
            ? lineList[0]
            : lineList[0].replace((/^- PR-\d+ /), "")
        );
        moduleAssert.ok(
            (/^(?:\d+(?:,\d+)*)?$/).test(issue),
            `shGithubPrFlow ${subcmd} - bad issue list "${issue}"`
        );
        moduleAssert.ok(
            (
                modePr === "release"
                ? /^# v\d/
                : /^- PR-\d+ - /
            ).test(lineList[0]),
            `shGithubPrFlow ${subcmd} - commit message does not fit mode` +
            ` ${modePr}`
        );
        moduleAssert.ok(
            title.length <= 256,
            `shGithubPrFlow ${subcmd} - title over 256 chars - ${title}`
        );
        return {
            description: (
                modePr === "release"
                ? rest
                : [
                    issue && issue.split(",").map(function (number) {
                        return `Fixes #${number}.`;
                    }).join(" "),
                    `This PR will:\n${title}`,
                    rest && `This PR will additionally:\n${rest}`
                ].filter(Boolean).join("\n\n")
            ),
            title
        };
    }
    function prTextPrint() {
        // Set the block apart from the git log printed just before it.
        process.stderr.write("\n\n\n\n");
        console.error(String(`
shGithubPrFlow ${subcmd} - title:

${prText.title}

shGithubPrFlow ${subcmd} - description:

${prText.description}
        `).trim() + "\n");
    }
    async function publish() {

// This function will publish the draft github-release of <remote>/master,
// which triggers publish.yml, after checking its tag against CHANGELOG.md,
// package.json and pyproject.toml.

        const repoRemote = await repoOf(remote);
        const urlRun = (
            `https://github.com/${repoRemote}/actions/workflows/publish.yml`
        );
        let release;
        let res;
        let sha;
        let top;
        await gitRun(["fetch", remote, "master"]);
        sha = await gitOutput(["rev-parse", `${remote}/master`]);
        top = await versionTop(sha, true);
        release = await releaseFind(repoRemote, `v${top.version}`);
        moduleAssert.ok(
            release,
            `shGithubPrFlow publish - no draft v${top.version} - run release`
        );
        // A release of an older master is not this one, as when the version
        // was not bumped.
        moduleAssert.ok(
            release.target_commitish === sha,
            `shGithubPrFlow publish - v${top.version} targets` +
            ` ${release.target_commitish}, not ${remote}/master ${sha}`
        );
        // A re-run after a failed publish.yml re-runs that workflow, not this.
        if (!release.draft) {
            log(
                `v${top.version} already published - ${release.html_url}` +
                ` - re-run a failed publish.yml at ${urlRun}`
            );
            return;
        }
        // Publishing binds a tag made since release to the draft.
        await tagAssertNone(repoRemote, `v${top.version}`);
        res = await githubRequest(
            "PATCH",
            `/repos/${repoRemote}/releases/${release.id}`,
            {draft: false}
        );
        moduleAssert.ok(
            res.status === 200,
            `shGithubPrFlow publish - ${res.status} ${res.text}`
        );
        log(`published ${res.json.html_url} - publish.yml at ${urlRun}`);
    }
    async function release() {

// This function will save a draft github-release of master of <remote>, for
// the version atop its CHANGELOG.md, after its github-ci passes. It writes
// nothing before its checks pass, and never a second draft, and a re-run finds
// a draft or release of the same commit as done.

        const repoRemote = await repoOf(remote);
        let found;
        let res;
        let sha;
        let tag;
        let top;
        await gitRun(["fetch", remote, "master"]);
        sha = await gitOutput(["rev-parse", `${remote}/master`]);
        moduleAssert.ok(
            await gitOutput(["rev-parse", "master"]) === sha,
            `shGithubPrFlow release - master differs from ${remote}/master`
        );
        await ciWait(remote, "master");
        top = await versionTop(sha, true);
        tag = `v${top.version}`;
        found = await releaseFind(repoRemote, tag);
        // A re-run, as of cleanup, finds its own draft or release done.
        if (found?.target_commitish === sha) {
            log(`${tag} already saved - ${found.html_url}`, "release");
            return;
        }
        moduleAssert.ok(
            !found,
            `shGithubPrFlow release - ${tag} already exists as a ` + (
                found?.draft
                ? "draft"
                : "release"
            ) + ` - ${found?.html_url}`
        );
        await tagAssertNone(repoRemote, tag);
        // Never retry, since a lost reply could mean a saved draft, which a
        // re-run then finds above.
        res = await githubRequest("POST", `/repos/${repoRemote}/releases`, {
            body: top.body,
            draft: true,
            generate_release_notes: true,
            name: `${tag} - ${top.itemFirst.slice(2)}`,
            tag_name: tag,
            target_commitish: sha
        });
        moduleAssert.ok(
            res.status === 201,
            `shGithubPrFlow release - create draft - ${res.status} ${res.text}`
        );
        log(`saved draft ${tag} - ${res.json.html_url}`, "release");
    }
    async function releaseFind(repo, tag) {

// This function will find the draft or release of <tag>, since only a listing
// of releases shows drafts.

        const res = await githubRequest(
            "GET",
            `/repos/${repo}/releases?per_page=100`
        );
        moduleAssert.ok(
            res.status === 200,
            `shGithubPrFlow ${subcmd} - list releases - ${res.status}` +
            ` ${res.text}`
        );
        return res.json.find(function (elem) {
            return elem.tag_name === tag;
        });
    }
    async function repoOf(name) {
        const repo = (
            /github\.com[\/:]([^\/]+\/[^\/]+?)(?:\.git)?\/?$/
        ).exec(await gitTry(["config", `remote.${name}.url`]))?.[1];
        moduleAssert.ok(
            repo,
            `shGithubPrFlow ${subcmd} - cannot parse url of remote ${name}`
        );
        return repo;
    }
    function shRun(script) {
        return new Promise(function (resolve) {
            moduleChildProcess.spawn("sh", ["-c", script], {
                stdio: ["ignore", 1, 2]
            }).on("exit", resolve);
        });
    }
    async function tagAssertNone(repo, tag) {

// This function will fail if <repo> has git tag <tag>, which a release would
// bind to some other commit.

        const res = await githubRequest(
            "GET",
            `/repos/${repo}/git/matching-refs/tags/${tag}`
        );
        moduleAssert.ok(
            res.status === 200,
            `shGithubPrFlow ${subcmd} - list tags - ${res.status} ${res.text}`
        );
        moduleAssert.ok(
            !res.json.some(function (elem) {
                return elem.ref === `refs/tags/${tag}`;
            }),
            `shGithubPrFlow ${subcmd} - tag ${tag} already exists,` +
            " and a release would bind to it"
        );
    }
    async function upstreamRepo() {
        const repo = (
            /"git\+https:\/\/github\.com\/([^"]+)\.git"/
        ).exec(await moduleFs.promises.readFile("package.json", "utf8"))?.[1];
        moduleAssert.ok(
            repo,
            `shGithubPrFlow ${subcmd} - missing upstream repository in` +
            " package.json"
        );
        return repo;
    }
    function versionNormalize(version) {

// This function will turn a date 2026-01-05 into 2026.1.5, and drop a leading
// v, keeping a suffix -rc1.

        return String(version)
            .trim()
            .replace((/^v/), "")
            .replace((/^(\d{4})-0?(\d+)-0?(\d+)$/), "$1.$2.$3")
            // security - The version reaches a branch name.
            .replace((/[^\w.\-]/g), "_");
    }
    async function versionTop(sha, isCheck) {

// This function will take the first "# v" heading of CHANGELOG.md, skipping
// "# Todo", with its entries up to the next heading, from commit <sha>, or
// the working tree if none, and if <isCheck>, check package.json and
// pyproject.toml agree.

        const [
            ,
            version,
            body = ""
        ] = (
            /^# v(\S+)\n([\s\S]*?)(?:^# |(?![\s\S]))/m
        ).exec(
            (await fileRead(sha, "CHANGELOG.md")).replace((/\r/g), "")
        ) || [];
        let itemFirst;
        let versionPackage;
        let versionPypi;
        itemFirst = body.trim().split("\n").find(function (line) {
            return line.startsWith("- ");
        });
        moduleAssert.ok(
            version && itemFirst,
            `shGithubPrFlow ${subcmd} - no "# v<version>" with entries in` +
            " CHANGELOG.md"
        );
        // security - The version reaches a shell script and a branch name.
        moduleAssert.ok(
            (/^[\w.\-]+$/).test(version),
            `shGithubPrFlow ${subcmd} - bad CHANGELOG.md version "${version}"`
        );
        if (isCheck) {
            versionPackage = JSON.parse(
                await fileRead(sha, "package.json")
            ).version;
            // A pypi-package, as in sqlmath, publishes the version in
            // pyproject.toml, less any "-" suffix.
            versionPypi = (
                /^version = "([^"]*)"\r?$/m
            ).exec(await fileRead(sha, "pyproject.toml").catch(function () {
                return "";
            }))?.[1];
            moduleAssert.ok(
                version === versionPackage,
                `shGithubPrFlow ${subcmd} - CHANGELOG.md version ${version}` +
                ` differs from package.json version ${versionPackage}`
            );
            moduleAssert.ok(
                !versionPypi || versionPypi === version.split("-")[0],
                `shGithubPrFlow ${subcmd} - CHANGELOG.md version ${version}` +
                ` differs from pyproject.toml version ${versionPypi}`
            );
        }
        return {body: body.trim(), itemFirst, version};
    }
    // Fail closed, so only a finished step exits 0.
    process.exitCode = 1;
    remote = argList[0] || "";
    if (subcmd === "ci_wait") {
        remote = remote.split("/")[0];
        moduleAssert.ok(
            remote && argList[0].includes("/"),
            "shGithubPrFlow ci_wait - usage: ci_wait <remote>/<branch>" +
            " [dispatch]"
        );
        // Wait on the commit the remote holds now, not a stale tracking-ref.
        await gitRun(["fetch", remote, argList[0].slice(remote.length + 1)]);
        await ciWait(remote, argList[0].slice(remote.length + 1), argList[1]);
    } else {
        const stepDict = {
            all,
            branch,
            cleanup,
            create,
            merge,
            merge_rebase: merge,
            merge_squash: merge,
            publish,
            release
        };
        moduleAssert.ok(
            Object.hasOwn(stepDict, subcmd),
            "shGithubPrFlow - usage: <all|branch|ci_wait|cleanup|create" +
            "|merge|merge_rebase|merge_squash|publish|release> ..."
        );
        moduleAssert.ok(
            ["origin", "upstream"].includes(remote),
            `shGithubPrFlow ${subcmd} - usage: ${subcmd} <origin|upstream> ...`
        );
        // Without a token, drafts are invisible and writes fail late.
        moduleAssert.ok(
            process.env.MY_GITHUB_TOKEN,
            `shGithubPrFlow ${subcmd} - needs MY_GITHUB_TOKEN`
        );
        await stepDict[subcmd](subcmd);
    }
    process.exitCode = 0;
}());
' "$@" # '
)}

shGithubTokenExport() {
# This function will export $MY_GITHUB_TOKEN from file.
    if [ ! "$MY_GITHUB_TOKEN" ]
    then
        # Drop any CR or LF, which an editor on windows may leave in the file.
        export MY_GITHUB_TOKEN="$(
            tr -d '\r\n' < ~/.mysecret2/.my_github_token
        )"
    fi
}

shGithubWorkflowDispatch() {(set -e
# This function will trigger github-workflow on given $REPO and $BRANCH.
# example usage:
# shGithubWorkflowDispatch octocat/hello-world master
    shGithubTokenExport
    REPO="$1"
    shift
    BRANCH="$1"
    shift
    EXIT_CODE=0
    curl \
"https://api.github.com/repos/$REPO/actions/workflows/ci.yml/dispatches" \
        --ssl-no-revoke \
        -H "accept: application/vnd.github.v3+json" \
        -H "authorization: Bearer $MY_GITHUB_TOKEN" \
        -X POST \
        -d '{"ref":"'"$BRANCH"'"}' \
        -s \
        "$@" || EXIT_CODE="$?"
    printf "shGithubWorkflowDispatch - EXIT_CODE=%s\n" "$EXIT_CODE" 1>&2
    return "$EXIT_CODE"
)}

shGrep() {(set -e
# This function will recursively grep . for $REGEXP.
    REGEXP="$1"
    shift
    FILE_FILTER="\
/\\.|~$|/(obj|release)/|(\\b|_)(\\.[0-9]|\
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
raw|rollup|\
swp|\
tmp|\
vendor)s{0,1}(\\b|_)\
"
    find . -type f |
        grep -v -E "$FILE_FILTER" |
        tr "\n" "\000" |
        xargs -0 grep -HIin -E "$REGEXP" "$@" |
        tee "$(
            node --eval 'process.stdout.write(require("os").tmpdir())'
        )/shGrep.txt" || true
)}

shGrepReplace() {(set -e
# This function will inline grep-and-replace shGrep.txt in node's os.tmpdir.
    node --input-type=module --eval '
import moduleFs from "fs";
import moduleOs from "os";
import modulePath from "path";
(async function () {
    "use strict";
    let data;
    let dict = {};
    data = await moduleFs.promises.readFile(
        `${moduleOs.tmpdir()}/shGrep.txt`,
        "utf8"
    );
    data = data.replace((
        /^(.+?):(\d+?):([^\n]*)/gm
    ), function (ignore, file, lineno, str) {
        dict[file] = dict[file] || moduleFs.readFileSync( //jslint-ignore-line
            modulePath.resolve(file),
            "utf8"
        ).split("\n");
        if (dict[file][lineno - 1] === undefined) {
            throw new Error(
                `shGrepReplace - ${file} has no line ${lineno}, grep is stale`
            );
        }
        // Keep the "\r" of a crlf line, which only windows grep strips.
        // Grep splits on "\n" alone, so <str> runs to it past any lone "\r".
        dict[file][lineno - 1] = (
            (dict[file][lineno - 1].endsWith("\r") && !str.endsWith("\r"))
            ? str + "\r"
            : str
        );
        return "";
    });
    Object.entries(dict).forEach(function ([
        file, data
    ]) {
        moduleFs.promises.writeFile(file, data.join("\n"));
    });
}());
' # '
)}

shHttpFileServer() {(set -e
# This function will run simple node http-file-server on port $PORT.
    if [ ! "$npm_config_mode_auto_restart" ]
    then
        export npm_config_mode_auto_restart=1
        while true
        do
            printf "\n"
            git --no-pager diff 2>/dev/null | cat || true
            printf "\nshHttpFileServer - (re)starting %s\n" "$*"
            # Reset per run, or one 77 restarts every later clean exit too
            EXIT_CODE=0
            (shHttpFileServer "$@") || EXIT_CODE="$?"
            printf "\nshHttpFileServer - EXIT_CODE=%s\n" "$EXIT_CODE"
            # if $EXIT_CODE != 77, then exit process
            # http://en.wikipedia.org/wiki/Unix_signal
            if [ "$EXIT_CODE" != 77 ]
            then
                break
            fi
            # else restart process after 1 second
            sleep 1
        done
        return "$EXIT_CODE"
    fi
    node --input-type=module --eval '
import moduleChildProcess from "child_process";
import moduleFs from "fs";
import moduleHttp from "http";
import modulePath from "path";
import moduleRepl from "repl";
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
        // Init pathname, decoded so "%20" finds "a b.html"; the
        // parent-directory check below runs on the decoded path
        pathname = new URL(req.url, "http://localhost").pathname;
        try {
            pathname = decodeURIComponent(pathname);
        } catch (ignore) {
            res.statusCode = 400;
            res.end();
            return;
        }
        // A NUL would make fs throw outside any handler and crash the server.
        if (pathname.includes(String.fromCharCode(0))) {
            res.statusCode = 400;
            res.end();
            return;
        }
        // debug - serverLog
        res.on("close", function () {
            if (pathname === "/favicon.ico") {
                return;
            }
            console.error(
                "serverLog - " +
                new Date(timeStart).toISOString() + " - " +
                (Date.now() - timeStart) + "ms - " +
                (res.statusCode || 0) + " " + req.method + " " + pathname
            );
        });
        // debug - echo request
        if (pathname === "/echo") {
            res.write(JSON.stringify(req.headers, undefined, 4) + "\n");
            req.pipe(res);
            return;
        }
        // Replace trailing "/" with "/index.html".
        file = pathname.slice(1).replace((
            /\/$|^$/m
        ), "$&index.html");
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
                            "\\u" +
                            chr.charCodeAt(0).toString(16).padStart(4, 0)
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
                    "console.error(Object.keys(" + match2 +
                    ").map(function(key){return(" +
                    "typeof " + match2 + "[key]===\u0027object\u0027&&" +
                    match2 + "[key]&&" +
                    match2 + "[key]===global[key]" +
                    "?\u0027global\u0027" +
                    ":typeof " + match2 + "[key]" +
                    ")+\u0027 \u0027+key;" +
                    "}).sort().join(\u0027\\n\u0027))\n"
                );
                break;
            // syntax-sugar - print String(value)
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
# This function will create .png logo.
    if [ ! -f asset_image_logo_256.html ]
    then
        return
    fi
    FILE=".artifact/asset_image_logo_256.png"
    shBrowserScreenshot asset_image_logo_256.html \
        "-screenshot=$(node --print "path.resolve(process.argv[1])" "$FILE")"
    gm mogrify -crop 256x256 "$FILE"
    printf "shImageLogoCreate - wrote - %s\n" "$FILE" 1>&2
    # convert to svg @ https://convertio.co/png-svg/
)}

shImageToDataUri() {(set -e
# This function will convert image $1 to data-uri string.
    node --input-type=module --eval '
import moduleFs from "fs";
(async function () {
    let file;
    let mime;
    let result;
    file = process.argv[1];
    if ((/^https:\/\//).test(file)) {
        result = await fetch(file);
        if (!result.ok) {
            console.error(`shImageToDataUri - http ${result.status} ${file}`);
            process.exitCode = 1;
            return;
        }
        result = Buffer.from(await result.arrayBuffer());
    } else {
        result = await moduleFs.promises.readFile(file);
    }
    // MIME subtype from the extension; "svg" and "jpg" are not subtypes
    mime = file.match(/\.[^.]*?$|$/m)[0].slice(1).toLowerCase();
    mime = (
        mime === "jpg"
        ? "jpeg"
        : mime === "svg"
        ? "svg+xml"
        : mime
    );
    result = `data:image/${mime};base64,${result.toString("base64")}`;
    result = result.replace((/.{72}/g), "$&\\\n");
    console.log(result);
}());
' "$@" # '
)}

shJsonNormalize() {(set -e
# This function will:
# 1. read json-data from file $1
# 2. normalize json-data
# 3. write normalized json-data back to file $1
    node --input-type=module --eval '
import moduleFs from "fs";
function noop(value) {

// This function will do nothing except return <value>.

    return value;
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

shLintPython() {(set -e
# This function will lint python file.
# https://docs.astral.sh/ruff/rules/
    FILE_LIST="$*"
    (
    printf "\n\nlint ruff\n"
    OPTION=""
    # autofix
    OPTION="$OPTION --fix"
    OPTION="$OPTION --select=ALL"
    #
    # ANNXXX flake8-annotations
    OPTION="$OPTION --ignore=ANN"
    #
    # C901 - complex-structure
    # {name} is too complex ({complexity} > {max_complexity})
    OPTION="$OPTION --ignore=C901"
    #
    # D203 - incorrect-blank-line-before-class
    # 1 blank line required before class docstring
    OPTION="$OPTION --ignore=D203"
    #
    # D212 - multi-line-summary-first-line
    # Multi-line docstring summary should start at the first line
    OPTION="$OPTION --ignore=D212"
    #
    # D401 - non-imperative-mood
    # First line of docstring should be in imperative mood: "{first_line}"
    OPTION="$OPTION --ignore=D401"
    #
    # D404 - docstring-starts-with-this
    # First word of the docstring should not be "This"
    OPTION="$OPTION --ignore=D404"
    #
    # ERA001 - commented-out-code
    # Found commented-out code
    OPTION="$OPTION --ignore=ERA001"
    #
    # PLR0912 - too-many-branches
    # Too many branches ({branches} > {max_branches})
    OPTION="$OPTION --ignore=PLR0912"
    #
    # PLR0913 - too-many-arguments
    # Too many arguments in function definition ({c_args} > {max_args})
    OPTION="$OPTION --ignore=PLR0913"
    #
    # PLR0915 - too-many-statements
    # Too many statements ({statements} > {max_statements})
    OPTION="$OPTION --ignore=PLR0915"
    #
    # S603 - subprocess-without-shell-equals-true
    # subprocess call: check for execution of untrusted input
    OPTION="$OPTION --ignore=S603"
    #
    # S607 - start-process-with-partial-path
    # Starting a process with a partial executable path
    OPTION="$OPTION --ignore=S607"
    #
    # S608 - hardcoded-sql-expression
    # Possible SQL injection vector through string-based query construction
    OPTION="$OPTION --ignore=S608"
    #
    # T201 - print
    # print found
    OPTION="$OPTION --ignore=T201"
    # shellcheck disable=SC2086
    ruff check $OPTION $FILE_LIST
    ) &
    PID_LIST="$PID_LIST $!"
    #
    (
    printf "lint pycodestyle\n"
    OPTION="--ignore="
    #
    # E116 - unexpected-indentation-comment
    # Unexpected indentation (comment)
    OPTION="$OPTION,E116"
    #
    # E261 - too-few-spaces-before-inline-comment
    # Insert at least two spaces before an inline comment
    OPTION="$OPTION,E261"
    #
    # Line break occurred before a binary operator (W503)
    # Line breaks should occur after the binary operator to keep all variable
    # names aligned.
    OPTION="$OPTION,W503"
    # shellcheck disable=SC2086
    pycodestyle $OPTION $FILE_LIST
    ) &
    PID_LIST="$PID_LIST $!"
    #
    shPidListWait shLintPython "$PID_LIST"
    printf "lint successful\n\n"
)}

shLintShell() {(set -e
# This function will shellcheck shell-files $@.
    if (! shellcheck --version >/dev/null 2>&1)
    then
        # Say so, or a skipped lint prints the same nothing as a clean one
        printf "shLintShell - shellcheck not installed, SKIPPED %s\n" "$*" >&2
        return
    fi
    FILE_LIST="$*"
    OPTION=""
    # https://www.shellcheck.net/wiki/
    # SC1090 – Can't follow non-constant source.
    # Use a directive to specify location
    OPTION="$OPTION --exclude=SC1090"
    # SC1091 – Not following: (error message here)
    OPTION="$OPTION --exclude=SC1091"
    # SC2016 – Expressions don't expand in single quotes,
    # use double quotes for that.
    OPTION="$OPTION --exclude=SC2016"
    # SC2030 – Modification of var is local (to subshell caused by pipeline).
    OPTION="$OPTION --exclude=SC2030"
    # SC2031 – var was modified in a subshell. That change might be lost.
    OPTION="$OPTION --exclude=SC2031"
    # SC2119 – Use `foo "$@"` if function's `$1` should mean script's `$1`.
    OPTION="$OPTION --exclude=SC2119"
    # SC2115 – Use `"${var:?}"` to ensure this never expands to `/*` .
    OPTION="$OPTION --exclude=SC2155"
    EXIT_CODE=0
    # shellcheck disable=SC2086
    shellcheck $OPTION $FILE_LIST >/dev/null || EXIT_CODE="$?"
    if [ "$EXIT_CODE" != 0 ]
    then
        # shellcheck disable=SC2086
        shellcheck $OPTION $FILE_LIST | head -n 50
    fi
    return "$EXIT_CODE"
)}

shNpmPublishV0() {(set -e
# This function will npm-publish name $1 with bare package.json.
    DIR=/tmp/shNpmPublishV0
    rm -rf "$DIR" && mkdir -p "$DIR" && cd "$DIR"
    printf "{\"name\":\"%s\",\"version\":\"0.0.1\"}\n" "$1" > package.json
    shift
    npm publish "$@"
)}

shPidListWait() {
# This function will wait for all process-pid in $PID_LIST to exit.
    EXIT_CODE=0
    PID_LIST="$2"
    TASK="$1"
    for PID in $PID_LIST
    do
        printf "%s - pid=%s ...\n" "$TASK" "$PID"
        wait "$PID" || EXIT_CODE="$?"
        printf "%s - pid=%s EXIT_CODE=%s\n" "$TASK" "$PID" "$EXIT_CODE"
    done
    printf "%s - pid=done EXIT_CODE=%s\n\n\n\n" "$TASK" "$EXIT_CODE"
    return "$EXIT_CODE"
}

shRmDsStore() {(set -e
# This function will recursively rm .DS_Store from current-dir.
# http://stackoverflow.com/questions/2016844/bash-recursively-remove-files
    for NAME in "._*" ".DS_Store" "desktop.ini" "npm-debug.log" "*~"
    do
        find . -iname "$NAME" -print0 | xargs -0 rm -f || true
    done
)}

shRollupFetch() {(set -e
# This function will fetch raw-lib from $1.
    node --input-type=module --eval '
import moduleChildProcess from "child_process";
import moduleFs from "fs";
import modulePath from "path";
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
        elem.flags = elem.flags || "";
        elem.substr = elem.substr || "";
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
                "shRollupFetch - cannot find-and-replace snippet " +
                JSON.stringify(aa)
            );
        }
    });
    return data;
}
(async function () {
    let fetchCount = 0;
    let fetchList;
    let matchObj;
    let promiseList = [];
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
    matchObj[1] = {
        fetchList: [],
        replaceList: [],
        ...JSON.parse(matchObj[1])
    };
    fetchList = JSON.parse(JSON.stringify(matchObj[1].fetchList));
    // init repoDict, fetchList
    repoDict = {};
    fetchList.forEach(async function (elem) {
        let child;
        let res;
        let url;
        if (!elem.url) {
            return;
        }
        elem.prefix = elem.url.split("/").slice(0, 7).join("/");
        // fetch dateCommitted
        if (!repoDict.hasOwnProperty(elem.prefix)) {
            repoDict[elem.prefix] = true;
            promiseList.push(fetch(elem.prefix.replace(
                "/blob/",
                "/commits/"
            )).then(async function (res) {
                elem.dateCommitted = Buffer.from(await res.arrayBuffer());
            }));
        }
        // Fetch file; a failed sub-command throws, or its empty output would
        // be saved as the file
        if (elem.node || elem.sh) {
            child = moduleChildProcess.spawn(
                (
                    elem.node
                    ? "node"
                    : "sh"
                ),
                [
                    (
                        elem.node
                        ? "-e"
                        : "-c"
                    ),
                    elem.node || elem.sh
                ],
                {stdio: ["ignore", "overlapped", 2]}
            );
            pipeToBuffer(child.stdout, elem, "data");
            child.on("exit", function (exitCode) {
                if (exitCode !== 0) {
                    throw new Error(
                        "shRollupFetch - exitCode " + exitCode + " " +
                        (elem.node || elem.sh)
                    );
                }
            });
            return;
        }
        fetchCount += 1;
        await new Promise(function (resolve) {
            setTimeout(resolve, fetchCount * 50);
        });
        url = elem.url2 || elem.url.replace(
            "https://github.com/",
            "https://raw.githubusercontent.com/"
        ).replace("/blob/", "/");
        res = await fetch(url);
        fetchCount -= 1;
        console.error(`shRollupFetch - ${fetchCount} remaining fetches`);
        if (!res.ok) {
            console.error(`shRollupFetch - http ${res.status} ${url}`);
            process.exitCode = 1;
            return;
        }
        elem.data = Buffer.from(await res.arrayBuffer());
    });
    await Promise.all(promiseList);
    // Parse fetched data; write nothing if a fetch failed, or the rollup
    // would be written with pieces missing
    process.on("exit", function (exitCode) {
        let rollupBody;
        let rollupBody0;
        let rollupHeader;
        if (exitCode !== 0) {
            return;
        }
        rollupBody = "";
        fetchList.forEach(function (elem) {
            let {
                comment,
                data,
                dataUriType,
                dateCommitted,
                footer = "",
                header = "",
                prefix,
                replaceList = [],
                url
            } = elem;
            if (!url) {
                return;
            }
            elem.exports = (
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
                ) +
                "_" +
                (
                    modulePath.basename(
                        url
                    ).replace((
                        /\.js$/
                    ), "").replace((
                        /\W/g
                    ), "_")
                )
            );
            elem.replaceList = replaceList;
            if (dataUriType) {
                return;
            }
            if (dateCommitted && dateCommitted.toString()) {
                rollupBody += (
                    "\n\n\n/*\n" +
                    "repo " + prefix.replace("/blob/", "/tree/") + "\n" +
                    "committed " + new Date(
                        (
                            /"(\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d[^"]*?)"/
                        ).exec(dateCommitted.toString())?.[1] ||
                        "1970-01-01T00:00:00Z"
                    ).toISOString().replace((/\.\d*?Z/), "Z") + "\n" +
                    "*/"
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
            rollupBody += (
                "\n\n\n/*\nfile " + url + "\n*/\n" +
                header +
                data.trim() +
                footer
            );
        });
        rollupBody = (
            "\n" + rollupBody.trim() +
            "\n\n\n/*\nfile none\n*/\n/*jslint-enable*/\n"
        );
        // comment #!
        rollupBody = rollupBody.replace((
            /^#!/gm
        ), "// $&");
        // normalize newline
        rollupBody = rollupBody.replace((
            /\r\n|\r/g
        ), "\n");
        // remove trailing-whitespace
        rollupBody = rollupBody.replace((
            /[\t ]+$/gm
        ), "");
        // remove leading-newline before ket
        rollupBody = rollupBody.replace((
            /\n+?(\n *?\})/g
        ), "$1");
        // eslint - no-multiple-empty-lines
        // https://github.com/eslint/eslint/blob/v7.2.0/docs/rules/no-multiple-empty-lines.md //jslint-ignore-line
        rollupBody = rollupBody.replace((
            /\n{4,}/g
        ), "\n\n\n");
        // replace from replaceList
        rollupBody = replaceListReplace(matchObj[1].replaceList, rollupBody);
        // init rollupHeader
        rollupHeader = (
            matchObj.input.slice(0, matchObj.index) +
            "/*jslint-disable*/\n/*\nshRollupFetch\n" +
            JSON.stringify(
                objectDeepCopyWithKeysSorted(matchObj[1]),
                undefined,
                4
            ) + "\n" +
            matchObj[2].split("\n\n").filter(function (elem) {
                return elem.trim();
            }).map(function (elem) {
                return elem.trim().replace((
                    /\*\//g
                ), "*\\\\/").replace((
                    /\/\*/g
                ), "/\\\\*") + "\n";
            }).sort().join("\n") + "*/\n\n"
        );
        // replace from rollupHeader-diff
        rollupHeader.replace((
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
            rollupBody0 = rollupBody;
            // disable $-escape in replacement-string
            rollupBody = rollupBody.replace(aa, function () {
                return bb;
            });
            if (rollupBody0 === rollupBody) {
                throw new Error(
                    "shRollupFetch - cannot find-and-replace snippet " +
                    JSON.stringify(aa)
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
                "data:" + dataUriType + ";base64," +
                data.toString("base64")
            );
            rollupBody0 = rollupBody;
            rollupBody = rollupBody.replace(
                new RegExp("^" + exports + "$", "gm"),
                // disable $-escape in replacement-string
                function () {
                    return data;
                }
            );
            if (rollupBody0 === rollupBody) {
                throw new Error(
                    "shRollupFetch - cannot find-and-replace snippet " +
                    JSON.stringify(exports)
                );
            }
        });
        // init footer
        rollupBody = rollupHeader + rollupBody;
        matchObj.input.replace((
            /\n\/\*\nfile none\n\*\/\n\/\*jslint-enable\*\/\n([\S\s]+)/
        ), function (ignore, match1) {
            rollupBody += "\n\n" + match1.trim() + "\n";
        });
        // write to file
        moduleFs.writeFileSync( //jslint-ignore-line
            process.argv[1],
            rollupBody
        );
    });
}());
' "$@" # '
    git --no-pager diff
)}

shRunWithCoverage() {(set -e
# This function will run nodejs command $@ with v8-coverage
# and create coverage-report .artifact/coverage/index.html.
    node --input-type=module --eval '
/*jslint white*/
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
     "Weird character " +
     JSON.stringify(char) +
     " found in " + name + " " +
     JSON.stringify(match0)
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
 return String(str)
  .replace((/&/g), "&amp;")
  .replace((/</g), "&lt;")
  .replace((/>/g), "&gt;");
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
 let resultMerged = [];   // List of merged scripts from processCovs.
 let urlToScriptDict = new Map(); // Map scriptCov.url to scriptCovs.

 function compareRangeList(aa, bb) {
  if (aa.startOffset !== bb.startOffset) {
   return aa.startOffset - bb.startOffset;
  }
  return bb.endOffset - aa.endOffset;
 }

 function dictKeyValueAppend(dict, key, value) {
  let list = dict.get(key);
  if (list === undefined) {
   list = [];
   dict.set(key, list);
  }
  list.push(value);
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
  let parentToChildDict = new Map();   // Map parent to child.
  let queueList;
  let queueListIi = 0;
  let queueOffset;
  let queueTrees;
  let resultChildren = [];
  let startToTreeDict = new Map();  // Map tree.start to tree.
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
     nested.length === 1 &&
     nested[0].start === openRange.start &&
     nested[0].end === openRange.end
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
  let stack = [     // Stack of parent trees and counts.
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
     children[0].start === tree.start &&
     children[0].end === tree.end
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
      funcCov.ranges[0].startOffset +
      ";" + funcCov.ranges[0].endOffset
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
 color: #333;
}
.coverage .coverageIgnore {
 background: #ccc;
}
.coverage .coverageLow,
.coverage .ignore {
 background: #ccc;
}
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
.coverage pre:hover span.ignore,
.coverage tr:hover td.coverageIgnore {
 background: #ccc;
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
   "+" + "-".repeat(padPathname + 2) + "+" +
   "-".repeat(padLines + 2) + "+" +
   "-".repeat(padLines + 2) + "+\n"
  );
  txt = "";
  txt += "V8 Coverage Report\n";
  txt += txtBorder;
  txt += (
   "| " + String("Files covered").padEnd(padPathname, " ") + " | " +
   String("Lines").padStart(padLines, " ") + " | " +
   String("Remaining").padStart(padLines, " ") + " |\n"
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
   coveragePct = Number(coveragePct / 100).toFixed(2);
   if (modeIndex && ii === 0) {
    fill = (
     "#" + Math.round(
      (100 - Number(coveragePct)) * 2.21
     ).toString(16).padStart(2, "0") +
     Math.round(
      Number(coveragePct) * 2.21
     ).toString(16).padStart(2, "0") +
     "00"
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
    "| " +
    String("./" + pathname).padEnd(padPathname, " ") + " | " +
    String(
     modeCoverageIgnoreFile + " " + coveragePct + " %"
    ).padStart(padLines, " ") + " | " +
    " ".repeat(padLines) + " |\n"
   );
   txt += (
    "| " + "*".repeat(
     Math.round(0.01 * coveragePct * padPathname)
    ).padEnd(padPathname, "_") + " | " +
    String(
     linesCovered + " / " + linesTotal
    ).padStart(padLines, " ") + " | " +
    String(
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
     "<a href=\"" + (pathname || "index") + ".html\">. / " +
     pathname + "</a><br>"
    )
    : (
     "<a href=\"" +
     "../".repeat(pathname.split("/").length - 1) +
     "index.html\">. / </a>" +
     pathname + "<br>"
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
    ignoreLine,
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
       lineHtml += (
        (isHole && ignoreLine)
        ? "</span><span class=\"ignore\">"
        : isHole
        ? "</span><span class=\"uncovered\">"
        : "</span><span>"
       );
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
     (count <= 0 && ignoreLine)
     ? "ignore"
     : count <= 0
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
   let processArgv0 = processArgv[0];
   if (processArgv0 === "npm") {
    processArgv0 = process.platform
     .replace("win32", "npm.cmd")
     .replace(process.platform, "npm");
   }
   moduleChildProcess.spawn(
    processArgv0,
    processArgv.slice(1),
    {
     env: {
      ...process.env,
      NODE_V8_COVERAGE: coverageDir
     },
     shell: (
      processArgv0.endsWith(".bat") ||
      processArgv0.endsWith(".cmd")
     ),
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
  let ignoreBlock = false;
  let lineList;
  let linesCovered;
  let linesTotal;
  let source;
  source = await moduleFs.promises.readFile(pathname, "utf8");
  lineList = [{}];
  source.replace((
   /(?<![^\n\r])(?!(?<=\r)\n)[^\n\r]*/g
  ), function (line, startOffset) {
   if (line === "/*coverage-disable*/") {
    ignoreBlock = true;
   }
   lineList[lineList.length - 1].endOffset = startOffset - 1;
   lineList.push({
    count: -1,
    endOffset: 0,
    holeList: [],
    ignoreLine: (
     ignoreBlock || line.endsWith("//coverage-ignore-line")
    ),
    line,
    startOffset
   });
   if (line === "/*coverage-enable*/") {
    ignoreBlock = false;
   }
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
  linesCovered = 0;
  lineList.forEach(function ({
   count,
   ignoreLine
  }) {
   linesCovered += count > 0 || ignoreLine;
  });
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
# This function will run cmd $@ and screenshot text-output.
# https://www.cnx-software.com/2011/09/22/how-to-convert-a-command-line-result-into-an-image-in-linux/
    EXIT_CODE=0
    SCREENSHOT_SVG="$1"
    shift
    printf "0\n" > "$SCREENSHOT_SVG.exit_code"
    printf "shRunWithScreenshotTxt - (%s 2>&1)\n" "$*" 1>&2
    # run "$@" with screenshot
    (
        "$@" 2>&1 || printf "%s\n" "$?" > "$SCREENSHOT_SVG.exit_code"
    ) | tee "$SCREENSHOT_SVG.txt"
    EXIT_CODE="$(cat "$SCREENSHOT_SVG.exit_code")"
    printf "shRunWithScreenshotTxt - EXIT_CODE=%s - %s\n" \
        "$EXIT_CODE" "$SCREENSHOT_SVG" \
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
        /\r\n?/g
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
    printf "shRunWithScreenshotTxt - wrote - %s\n" "$SCREENSHOT_SVG"
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
    . ~/myci2.sh
fi

# run "$@"
(set -e
    if [ ! "$1" ]
    then
        exit
    fi
    unset -f shCiArtifactUploadCustom
    unset -f shCiBaseCustom
    unset -f shCiBaseCustom2
    unset -f shCiLintCustom
    unset -f shCiLintCustom2
    unset -f shCiPreCustom
    unset -f shCiPreCustom2
    unset -f shCiPublishNpmCustom
    unset -f shCiPublishPypiCustom
    if [ -f ./myci2.sh ]
    then
        . ./myci2.sh
    fi
    if [ -f ./.ci.sh ]
    then
        . ./.ci.sh
    fi
    if [ -f ./.ci2.sh ]
    then
        . ./.ci2.sh
    fi
    "$@"
)
