#!/bin/sh

# POSIX reference
# http://pubs.opengroup.org/onlinepubs/9699919799/utilities/test.html
# http://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html

# sh one-liner
#
# git branch -d -r origin/aa
# git config --global diff.algorithm histogram
# git fetch origin alpha beta master && git fetch upstream alpha beta master
# git fetch origin alpha beta master --tags
# git fetch upstream "refs/tags/*:refs/tags/*"
# git ls-files --stage | sort
# git ls-remote --heads origin
# git update-index --chmod=+x aa.js
# head CHANGELOG.md -n50
# ln -f jslint.mjs ~/jslint.mjs
# openssl rand -base64 32 # random key
# sh jslint_ci.sh shCiBranchPromote origin alpha beta
# sh jslint_ci.sh shRunWithScreenshotTxt .artifact/screenshot_changelog.svg head -n50 CHANGELOG.md
# vim rgx-lowercase \L\1\e

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

shBrowserScreenshot() {(set -e
# this function will run headless-chrome to screenshot url $1 with
# window-size $2
    node --input-type=module -e '
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
        {
            stdio: [
                "ignore", 1, 2
            ]
        }
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
    local BRANCH
    local FILE
    node --input-type=module -e '
process.exit(Number(
    `${process.version.split(".")[0]}.${process.arch}.${process.platform}`
    !== process.env.CI_NODE_VERSION_ARCH_PLATFORM
));
' || return 0
    # init .git/config
    git config --local user.email "github-actions@users.noreply.github.com"
    git config --local user.name "github-actions"
    # init $BRANCH
    BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    git pull --unshallow origin "$BRANCH"
    # init $UPSTREAM_OWNER
    export UPSTREAM_OWNER="${UPSTREAM_OWNER:-jslint-org}"
    # init $UPSTREAM_REPO
    export UPSTREAM_REPO="${UPSTREAM_REPO:-jslint}"
    # screenshot changelog and files
    node --input-type=module -e '
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
        ]
    ].forEach(function (argList) {
        moduleChildProcess.spawn("sh", argList, {
            stdio: [
                "ignore", 1, 2
            ]
        }).on("exit", function (exitCode) {
            if (exitCode) {
                process.exit(exitCode);
            }
        });
    });
}());
' "$@" # '
    shCiArtifactUploadCustom
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
    # update dir branch-$BRANCH
    rm -rf "branch-$BRANCH"
    mkdir -p "branch-$BRANCH"
    (set -e
        cd "branch-$BRANCH"
        git init -b branch1
        git pull --depth=1 .. "$BRANCH"
        rm -rf .git
        git add -f .
    )
    # update root-dir with branch-beta
    if [ "$BRANCH" = beta ]
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
    # update README.md with branch-$BRANCH and $GITHUB_REPOSITORY
    sed -i \
        -e "s|/branch-[0-9A-Z_a-z]*/|/branch-$BRANCH/|g" \
        -e "s|\b$UPSTREAM_OWNER/$UPSTREAM_REPO\b|$GITHUB_REPOSITORY|g" \
        -e "s|\b$UPSTREAM_OWNER\.github\.io/$UPSTREAM_REPO\b|$(
            printf "$GITHUB_REPOSITORY" | sed -e "s|/|.github.io/|"
        )|g" \
        "branch-$BRANCH/README.md"
    git status
    git commit -am "update dir branch-$BRANCH" || true
    # if branch-gh-pages has more than 50 commits,
    # then backup and squash commits
    if [ "$(git rev-list --count gh-pages)" -gt 50 ]
    then
        # backup
        shGitCmdWithGithubToken push origin -f gh-pages:gh-pages-backup
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
        cd "branch-$BRANCH"
        sleep 15
        shDirHttplinkValidate
    )
)}

shCiArtifactUploadCustom() {(set -e
    return
)}

shCiBase() {(set -e
# this function will run base-ci
    # update table-of-contents in README.md
    node --input-type=module -e '
import moduleFs from "fs";
(async function () {
    let data = await moduleFs.promises.readFile("README.md", "utf8");
    data = data.replace((
        /\n# Table of Contents$[\S\s]*?\n\n\n/m
    ), function () {
        let ii = -1;
        let toc = "\n# Table of Contents\n";
        data.replace((
            /(\n\n\n#|\n###) (.*)/g
        ), function (ignore, level, title) {
            if (title === "Table of Contents") {
                ii += 1;
                return "";
            }
            if (ii < 0) {
                return "";
            }
            switch (level.trim()) {
            case "#":
                ii += 1;
                toc += "\n" + ii + ". [" + title + "](#";
                break;
            case "###":
                toc += "    - [" + title + "](#";
                break;
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
    shCiBaseCustom
    git diff
)}

shCiBaseCustom() {(set -e
    return
)}

shCiBranchPromote() {(set -e
# this function will promote branch $REMOTE/$BRANCH1 to branch $REMOTE/$BRANCH2
    local BRANCH1
    local BRANCH2
    local REMOTE
    REMOTE="$1"
    shift
    BRANCH1="$1"
    shift
    BRANCH2="$1"
    shift
    git fetch "$REMOTE" "$BRANCH1"
    git push "$REMOTE" "$REMOTE/$BRANCH1:$BRANCH2" "$@"
)}

shDirHttplinkValidate() {(set -e
# this function will validate http-links embedded in .html and .md files
    node --input-type=module -e '
import moduleFs from "fs";
import moduleHttps from "https";
import moduleUrl from "url";
(async function () {
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
        data.replace((
            /\bhttps?:\/\/.*?(?:[\s")\]]|\W?$)/gm
        ), function (url) {
            let req;
            url = url.slice(0, -1).replace((
                /[\u0022\u0027]/g
            ), "").replace((
                /\/branch-\w+?\//g
            ), "/branch-alpha/").replace((
                /\bjslint-org\/jslint\b/g
            ), process.env.GITHUB_REPOSITORY || "jslint-org/jslint").replace((
                /\bjslint-org\.github\.io\/jslint\b/g
            ), String(
                process.env.GITHUB_REPOSITORY || "jslint-org/jslint"
            ).replace("/", ".github.io/"));
            if (url.startsWith("http://")) {
                throw new Error("shDirHttplinkValidate - insecure link " + url);
            }
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
                if (!(res.statusCode < 400)) {
                    throw new Error(
                        "shDirHttplinkValidate - " + file
                        + " - unreachable link " + url
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
            /(\bhref=|\bsrc=|\burl\(|\[[^]*?\]\()("?.*?)(?:[")\]]|$)/gm
        ), function (ignore, linkType, url) {
            if (!linkType.startsWith("[")) {
                url = url.slice(1);
            }
            if (url.length === 0 || url.startsWith("data:")) {
                return;
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
                    if (!exists) {
                        throw new Error(
                            "shDirHttplinkValidate - " + file
                            + " - unreachable link " + url
                        );
                    }
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
        git config "remote.$REMOTE.url" \
        | sed -e "s|https://|https://x-access-token:$GITHUB_TOKEN@|"
    )"
    EXIT_CODE=0
    # hide $GITHUB_TOKEN in case of err
    git "$CMD" "$URL" "$@" 2>/dev/null || EXIT_CODE="$?"
    printf "shGitCmdWithGithubToken - EXIT_CODE=$EXIT_CODE\n" 1>&2
    return "$EXIT_CODE"
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
    rm .gitconfig.bak
    cp .gitconfig .git/config
    git commit -am "update owner/repo to $1" || true
)}


shGitLsTree() {(set -e
# this function will "git ls-tree" all files committed in HEAD
# example use:
# shGitLsTree | sort -rk3 # sort by date
# shGitLsTree | sort -rk4 # sort by size
    node --input-type=module -e '
import moduleChildProcess from "child_process";
(async function () {
    let result;
    // get file, mode, size
    result = await new Promise(function (resolve) {
        result = "";
        moduleChildProcess.spawn("git", [
            "ls-tree", "-lr", "HEAD"
        ], {
            encoding: "utf8",
            stdio: [
                "ignore", "pipe", 2
            ]
        }).on("exit", function () {
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
        moduleChildProcess.spawn("git", [
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
    node --input-type=module -e '
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
        dict[file] = dict[file] || moduleFs.readFileSync( //jslint-quiet
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
    node --input-type=module -e '
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
            moduleChildProcess.spawn("node", [
                process.env.HOME + "/jslint.mjs", "."
            ], {
                stdio: [
                    "ignore", 1, 2
                ]
            });
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
                moduleChildProcess.spawn(match2, {
                    shell: true,
                    stdio: [
                        "ignore", 1, 2
                    ]
                // print exitCode
                }).on("exit", function (exitCode) {
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
            // console.error(Object.keys(global).map(function(key){return(typeof global[key]===\u0027object\u0027&&global[key]&&global[key]===global[key]?\u0027global\u0027:typeof global[key])+\u0027 \u0027+key;}).sort().join(\u0027\n\u0027)) //jslint-quiet
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
    local SIZE
    echo '
<!DOCTYPE html>
<html lang="en">
<head>
<title>logo</title>
<style>
/* sh jslint_ci.sh shBrowserScreenshot asset_image_logo.html --window-size=512x512 */
/* csslint box-model:false */
/* csslint ignore:start */
*,
*:after,
*:before {
    box-sizing: border-box;
}
@font-face {
    font-family: Daley;
    font-weight: bold;
    src: url("asset_font_daley_bold.woff2") format("woff2");
}
/* csslint ignore:end */
body,
div {
    margin: 0;
}
.container1 {
    background: antiquewhite;
    border: 24px solid darkslategray;
    border-radius: 96px;
    color: darkslategray;
    font-family: Daley;
    height: 512px;
    margin: 0;
    position: relative;
    width: 512px;
    zoom: 100%;
/*
    background: transparent;
    border: 24px solid black;
    color: black;
*/
}
.text1 {
    font-size: 256px;
    left: 44px;
    position: absolute;
    top: 32px;
}
.text2 {
    bottom: 8px;
    font-size: 192px;
    left: 44px;
    position: absolute;
}
</style>
</head>
<body>
<div class="container1">
<div class="text1">JS</div>
<div class="text2">Lint</div>
</div>
</body>
</html>
' > .artifact/asset_image_logo_512.html
    cp asset_font_daley_bold.woff2 .artifact || true
    # screenshot asset_image_logo_512.png
    shBrowserScreenshot .artifact/asset_image_logo_512.html \
        --window-size=512x512 \
        -screenshot=.artifact/asset_image_logo_512.png
    # create various smaller thumbnails
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
    node --input-type=module -e '
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
    node --input-type=module -e '
import moduleFs from "fs";
(async function () {
    function noop(val) {

// this function will do nothing except return <val>

        return val;
    }
    function objectDeepCopyWithKeysSorted(obj) {

// this function will recursively deep-copy <obj> with keys sorted

        let sorted;
        if (typeof obj !== "object" || !obj) {
            return obj;
        }

// recursively deep-copy list with child-keys sorted

        if (Array.isArray(obj)) {
            return obj.map(objectDeepCopyWithKeysSorted);
        }

// recursively deep-copy obj with keys sorted

        sorted = {};
        Object.keys(obj).sort().forEach(function (key) {
            sorted[key] = objectDeepCopyWithKeysSorted(obj[key]);
        });
        return sorted;
    }
    console.error("shJsonNormalize - " + process.argv[1]);
    moduleFs.promises.writeFile(
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
            4
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

shRawLibFetch() {(set -e
# this function will fetch raw-lib from $1
    node --input-type=module -e '
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
(async function () {
    let fetchList;
    let matchObj;
    let replaceList;
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
        /^\/\*jslint-disable\*\/\n\/\*\nshRawLibFetch\n(\{\n[\S\s]*?\n\})([\S\s]*?)\n\*\/\n/m
    ).exec(await moduleFs.promises.readFile(process.argv[1], "utf8"));
    // JSON.parse match1 with comment
    fetchList = JSON.parse(matchObj[1]).fetchList;
    replaceList = JSON.parse(matchObj[1]).replaceList || [];
    // init repoDict, fetchList
    repoDict = {};
    fetchList.forEach(function (elem) {
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
            pipeToBuffer(moduleChildProcess.spawn("node", [
                "-e", elem.node
            ], {
                stdio: [
                    "ignore", "pipe", 2
                ]
            }).stdout, elem, "data");
            return;
        }
        if (elem.sh) {
            pipeToBuffer(moduleChildProcess.spawn(elem.sh, {
                shell: true,
                stdio: [
                    "ignore", "pipe", 2
                ]
            }).stdout, elem, "data");
            return;
        }
        moduleHttps.get(elem.url2 || elem.url.replace(
            "https://github.com/",
            "https://raw.githubusercontent.com/"
        ).replace("/blob/", "/"), function (res) {
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
        fetchList.forEach(function (elem, ii, list) {
            let prefix;
            if (!elem.url) {
                return;
            }
            // init prefix
            prefix = "exports_" + modulePath.dirname(elem.url).replace(
                "https://github.com/",
                ""
            ).replace((
                /\/blob\/[^\/]*/
            ), "/").replace((
                /\W/g
            ), "_").replace((
                /(_)_+|_+$/g
            ), "$1");
            list[ii].exports = prefix + "_" + modulePath.basename(
                elem.url
            ).replace((
                /\.js$/
            ), "").replace((
                /\W/g
            ), "_");
            if (elem.dataUriType) {
                return;
            }
            if (elem.dateCommitted) {
                result += (
                    "\n\n\n/*\n"
                    + "repo " + elem.prefix.replace("/blob/", "/tree/") + "\n"
                    + "committed " + (
                        /\b\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\dZ\b|$/
                    ).exec(elem.dateCommitted.toString())[0] + "\n"
                    + "*/"
                );
            }
            // comment /*...*/
            if (elem.comment) {
                elem.data = "/*\n" + elem.data.toString().trim().replace((
                    /\/\*/g
                ), "/\\*").replace((
                    /\*\//g
                ), "*\\/") + "\n*/";
            }
            // init header and footer
            result += (
                "\n\n\n/*\nfile " + elem.url + "\n*/\n"
                + (elem.header || "")
                + elem.data.toString().trim()
                + (elem.footer || "")
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
        // https://github.com/eslint/eslint/blob/v7.2.0/docs/rules/no-multiple-empty-lines.md //jslint-quiet
        result = result.replace((
            /\n{4,}/g
        ), "\n\n\n");
        // replace from replaceList
        replaceList.forEach(function ({
            aa,
            bb,
            flags
        }) {
            result0 = result;
            result = result.replace(new RegExp(aa, flags), bb);
            if (result0 === result) {
                throw new Error(
                    "shRawLibFetch - cannot find-and-replace snippet "
                    + JSON.stringify(aa)
                );
            }
        });
        // init header
        header = (
            matchObj.input.slice(0, matchObj.index)
            + "/*jslint-disable*/\n/*\nshRawLibFetch\n"
            + JSON.stringify(JSON.parse(matchObj[1]), undefined, 4) + "\n"
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
                    "shRawLibFetch - cannot find-and-replace snippet "
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
                    "shRawLibFetch - cannot find-and-replace snippet "
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
        moduleFs.writeFileSync(process.argv[1], result); //jslint-quiet
    });
}());
' "$@" # '
    git diff
)}

shRmDsStore() {(set -e
# this function will recursively rm .DS_Store from current-dir
# http://stackoverflow.com/questions/2016844/bash-recursively-remove-files
    local NAME
    for NAME in "._*" ".DS_Store" "desktop.ini" "npm-debug.log" "*~"
    do
        find . -iname "$NAME" -print0 | xargs -0 rm -f || true
    done
)}

shRunWithCoverage() {(set -e
# this function will run nodejs command $@ with v8-coverage
# and create coverage-report .artifact/coverage/index.html
    node --input-type=module -e '
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

  function sortProcess(processCov) {
    Object.entries(processCov.result.sort(function (aa, bb) {
      return (
        aa.url < bb.url
        ? -1
        : aa.url > bb.url
        ? 1
        : 0
      );
    })).forEach(function ([
      scriptId, scriptCov
    ]) {
      scriptCov.scriptId = scriptId.toString(10);
    });
    return processCov;
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
  if (processCovs.length === 1) {
    processCovs[0].result.forEach(function (scriptCov) {
      sortScript(scriptCov);
    });
    return sortProcess(processCovs[0]);
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
  return sortProcess({
    result: resultMerged
  });
}
async function v8CoverageReportCreate({
  consoleError,
  coverageDir,
  processArgv = []
}) {
  let cwd;
  let exitCode = 0;
  let fileDict;
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
* {
box-sizing: border-box;
  font-family: consolas, menlo, monospace;
}
/*csslint ignore:end*/
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
.coverage .coverageIgnore{
  background: #ccc;
}
.coverage .coverageLow{
  background: #ebb;
}
.coverage .coverageMedium{
  background: #fd7;
}
.coverage .footer,
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
  background: #7d7;
}
.coverage pre:hover span.uncovered,
.coverage tr:hover td.coverageLow {
  background: #d99;
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
      + "-".repeat(padLines + 2) + "+\n"
    );
    txt = "";
    txt += "V8 Coverage Report\n";
    txt += txtBorder;
    txt += (
      "| " + String("Files covered").padEnd(padPathname, " ") + " | "
      + String("Lines").padStart(padLines, " ") + " |\n"
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
  font-family="dejavu sans, verdana, geneva, sans-serif"
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
        ).padStart(padLines, " ") + " |\n"
      );
      txt += (
        "| " + "*".repeat(
          Math.round(0.01 * coveragePct * padPathname)
        ).padEnd(padPathname, "_") + " | "
        + String(
          linesCovered + " / " + linesTotal
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
                isHole
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

  function pathnameRelativeCwd(pathname) {
    pathname = modulePath.resolve(pathname).replace((
      /\\/g
    ), "/");
    if (!pathname.startsWith(cwd)) {
      return;
    }
    pathname = pathname.slice(cwd.length);
    return pathname;
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
  if (processArgv.length > 0) {
    await fsWriteFileWithParents(coverageDir + "/touch.txt", "");
    await Promise.all(Array.from(
      await moduleFs.promises.readdir(coverageDir)
    ).map(async function (file) {
      if ((
        /^coverage-\d+?-\d+?-\d+?\.json$/
      ).test(file)) {
        console.error("rm file " + coverageDir + file);
        await moduleFs.promises.unlink(coverageDir + file);
      }
    }));
    exitCode = await new Promise(function (resolve) {
      moduleChildProcess.spawn((
        processArgv[0] === "npm"
        ? process.platform.replace("win32", "npm.cmd").replace(
          process.platform,
          "npm"
        )
        : processArgv[0]
      ), processArgv.slice(1), {
        env: Object.assign({}, process.env, {
          NODE_V8_COVERAGE: coverageDir
        }),
        stdio: [
          "ignore", 1, 2
        ]
      }).on("exit", resolve);
    });
  }
  v8CoverageObj = await moduleFs.promises.readdir(coverageDir);
  v8CoverageObj = v8CoverageObj.filter(function (file) {
    return (
      /^coverage-\d+?-\d+?-\d+?\.json$/
    ).test(file);
  });
  v8CoverageObj = await Promise.all(v8CoverageObj.map(async function (file) {
    let data = await moduleFs.promises.readFile(coverageDir + file, "utf8");
    data = JSON.parse(data);
    data.result = data.result.filter(function (scriptCov) {
      let pathname = scriptCov.url;
      if (!pathname.startsWith("file:///")) {
        return;
      }
      pathname = pathnameRelativeCwd(moduleUrl.fileURLToPath(pathname));
      if (
        !pathname
        || pathname.startsWith("[")
        || (
          process.env.npm_config_mode_coverage !== "all"
          && (
            /(?:^|\/)node_modules\//m
          ).test(pathname)
        )
      ) {
        return;
      }
      scriptCov.url = pathname;
      return true;
    });
    return data;
  }));
  v8CoverageObj = v8CoverageListMerge(v8CoverageObj);
  await fsWriteFileWithParents(
    coverageDir + "v8_coverage_merged.json",
    JSON.stringify(v8CoverageObj)
  );
  fileDict = {};
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
          /^\/\*mode-coverage-ignore-file\*\/$/m
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
  process_argv: process.argv.slice(1)
});
' "$@" # '
)}

shRunWithScreenshotTxt() {(set -e
# this function will run cmd $@ and screenshot text-output
# https://www.cnx-software.com/2011/09/22/how-to-convert-a-command-line-result-into-an-image-in-linux/
    local EXIT_CODE
    EXIT_CODE=0
    export SCREENSHOT_SVG="$1"
    shift
    printf "0\n" > "$SCREENSHOT_SVG.exit_code"
    printf "shRunWithScreenshotTxt - ($* 2>&1)\n" 1>&2
    # run "$@" with screenshot
    (set -e
        "$@" 2>&1 || printf "$?\n" > "$SCREENSHOT_SVG.exit_code"
    ) | tee "$SCREENSHOT_SVG.txt"
    EXIT_CODE="$(cat "$SCREENSHOT_SVG.exit_code")"
    printf "shRunWithScreenshotTxt - EXIT_CODE=$EXIT_CODE - $SCREENSHOT_SVG\n" \
        1>&2
    # format text-output
    node --input-type=module -e '
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

shCiMain() {(set -e
# this function will run $@
    if [ "$1" = "" ]
    then
        return
    fi
    # run "$@" with winpty
    export CI_UNAME="${CI_UNAME:-$(uname)}"
    case "$CI_UNAME" in
    MSYS*)
        if [ ! "$CI_WINPTY" ] && [ "$1" != shHttpFileServer ]
        then
            export CI_WINPTY=1
            winpty -Xallow-non-tty -Xplain sh "$0" "$@"
            return
        fi
        ;;
    esac
    # run "$@"
    export NODE_OPTIONS="--unhandled-rejections=strict"
    if [ -f ./.ci.sh ]
    then
        . ./.ci.sh "$@"
    fi
    if [ "$npm_config_mode_coverage" ] && [ "$1" = "node" ]
    then
        shRunWithCoverage "$@"
        return
    fi
    "$@"
)}

# init ubuntu .bashrc
shBashrcDebianInit || return "$?"

shCiMain "$@"
