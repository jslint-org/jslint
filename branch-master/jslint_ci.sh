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
# sh jslint_ci.sh shRunWithScreenshotTxt .build/screenshot-changelog.svg head -n50 CHANGELOG.md
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
(function () {
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
    file = ".build/screenshot-browser-" + encodeURIComponent(file).replace((
        /%/g
    ), "_").toLowerCase() + ".png";
    moduleChildProcess.spawn(
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
    ).on("exit", function (exitCode) {
        console.error(
            "shBrowserScreenshot"
            + "\n  - url - " + url
            + "\n  - wrote - " + file
            + "\n  - timeElapsed - " + (Date.now() - timeStart) + " ms"
            + "\n  - EXIT_CODE=" + exitCode
        );
    });
}());
' "$@" # '
)}

shCiArtifactUpload() {(set -e
# this function will upload build-artifacts to branch-gh-pages
    local BRANCH
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
    # screenshot asset-image-logo
    shImageLogoCreate &
    # screenshot web-demo
    shBrowserScreenshot \
        "https://$UPSTREAM_OWNER.github.io/\
$UPSTREAM_REPO/branch-beta/index.html"
    # screenshot changelog and files
    node --input-type=module -e '
import moduleChildProcess from "child_process";
(function () {
    [
        // parallel-task - screenshot changelog
        [
            "jslint_ci.sh",
            "shRunWithScreenshotTxt",
            ".build/screenshot-changelog.svg",
            "head",
            "-n50",
            "CHANGELOG.md"
        ],
        // parallel-task - screenshot files
        [
            "jslint_ci.sh",
            "shRunWithScreenshotTxt",
            ".build/screenshot-files.svg",
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
    # screenshot curl
    if [ -f jslint.mjs ]
    then
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
    fi
    # seo - inline css-assets and invalidate cached-assets
    node --input-type=module -e '
import moduleFs from "fs";
(async function () {
    let cacheKey = Math.random().toString(36).slice(-4);
    let fileDict = {};
    await Promise.all([
        "asset-codemirror-rollup.css",
        "browser.mjs",
        "index.html"
    ].map(async function (file) {
        try {
            fileDict[file] = await moduleFs.promises.readFile(file, "utf8");
        } catch (ignore) {
            process.exit();
        }
    }));

// inline css-assets

    fileDict["index.html"] = fileDict["index.html"].replace((
        "\n<link rel=\"stylesheet\" href=\"asset-codemirror-rollup.css\">\n"
    ), function () {
        return (
            "\n<style>\n"
            + fileDict["asset-codemirror-rollup.css"].trim()
            + "\n</style>\n"
        );
    });
    fileDict["index.html"] = fileDict["index.html"].replace((
        "\n<style class=\"JSLINT_REPORT_STYLE\"></style>\n"
    ), function () {
        return fileDict["browser.mjs"].match(
            /\n<style\sclass="JSLINT_REPORT_STYLE">\n[\S\s]*?\n<\/style>\n/
        )[0];
    });

// invalidate cached-assets

    fileDict["browser.mjs"] = fileDict["browser.mjs"].replace((
        /^import\u0020.+?\u0020from\u0020".+?\.(?:js|mjs)\b/gm
    ), function (match0) {
        return `${match0}?cc=${cacheKey}`;
    });
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
    # add dir .build
    git add -f .build
    git commit -am "add dir .build"
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
        rm -rf .build
        git checkout beta .
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

shCiBase() {(set -e
# this function will run base-ci
    # create jslint.cjs
    cp jslint.mjs jslint.js
    cat jslint.mjs | sed \
        -e "s|^// module.exports = |module.exports = |" \
        -e "s|^export default Object.freeze(|// &|" \
        -e "s|^jslint_import_meta_url = |// &|" \
        > jslint.cjs
    # run test with coverage-report
    # coverage-hack - test jslint's invalid-file handling-behavior
    mkdir -p .test-dir.js
    # test jslint's cli handling-behavior
    printf "node jslint.cjs .\n"
    node jslint.cjs .
    printf "node jslint.mjs .\n"
    node jslint.mjs .
    printf "node test.mjs\n"
    (set -e
        # coverage-hack - test jslint's cli handling-behavior
        export JSLINT_BETA=1
        shRunWithCoverage node test.mjs
    )
    # update edition in README.md, jslint.mjs from CHANGELOG.md
    node --input-type=module -e '
import moduleFs from "fs";
(async function () {
    let dict;
    let versionBeta;
    let versionMaster;
    dict = {};
    await Promise.all([
        "CHANGELOG.md",
        "README.md",
        "jslint.mjs"
    ].map(async function (file) {
        dict[file] = await moduleFs.promises.readFile(file, "utf8");
    }));
    Array.from(dict["CHANGELOG.md"].matchAll(
        /\n\n#\u0020(v\d\d\d\d\.\d\d?\.\d\d?(.*?)?)\n/g
    )).slice(0, 2).forEach(function ([
        ignore, version, isBeta
    ]) {
        versionBeta = versionBeta || version;
        versionMaster = versionMaster || (!isBeta && version);
    });
    [
        {
            file: "README.md",
            src: dict["README.md"].replace((
                /\bv\d\d\d\d\.\d\d?\.\d\d?\b/m
            ), versionMaster),
            src0: dict["README.md"]
        }, {
            file: "jslint.mjs",
            src: dict["jslint.mjs"].replace((
                /^let\u0020jslint_edition\u0020=\u0020".*?";$/m
            ), `let jslint_edition = "${versionBeta}";`),
            src0: dict["jslint.mjs"]
        }
    ].forEach(function ({
        file,
        src,
        src0
    }) {
        if (src !== src0) {
            console.error(`update file ${file}`);
            moduleFs.promises.writeFile(file, src);
        }
    });
}());
' "$@" # '
    # update table-of-contents in README.md
    node --input-type=module -e '
import moduleFs from "fs";
(async function () {
    let data = await moduleFs.promises.readFile("README.md", "utf8");
    data = data.replace((
        /\n#\u0020Table\u0020of\u0020Contents$[\S\s]*?\n\n\n/m
    ), function () {
        let ii = -1;
        let toc = "\n# Table of Contents\n";
        data.replace((
            /\n\n\n#\u0020(.*)/g
        ), function (ignore, match1) {
            if (match1 === "Table of Contents") {
                ii += 1;
                return;
            }
            if (ii < 0) {
                return;
            }
            ii += 1;
            toc += ii + ". [" + match1 + "](#" + match1.toLowerCase().replace((
                /[^\u0020\-0-9A-Z_a-z]/g
            ), "").replace((
                /\u0020/g
            ), "-") + ")\n";
            return "";
        });
        toc += "\n\n";
        return toc;
    });
    await moduleFs.promises.writeFile("README.md", data);
}());
' "$@" # '
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
        if (!(
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
# this function will git init && git fetch utility2 base
    git init
    git config core.autocrlf input
    git remote add devenv \
        https://github.com/kaizhu256/devenv
    git fetch devenv base
    git reset devenv/base
    git checkout -b alpha
    git add .
    git commit -am "initial commit"
    curl -Lf -o .git/config \
https://raw.githubusercontent.com/kaizhu256/devenv/alpha/.gitconfig
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
/*jslint bitwise, name*/
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
        dict[file] = dict[file] || moduleFs.readFileSync(
            modulePath.resolve(file),
            "utf8"
        ).split("\n");
        dict[file][lineno - 1] = str;
        return "";
    });
    Object.entries(dict).forEach(function ([
        file, data
    ]) {
        moduleFs.promise.writeFile(file, data.join("\n"));
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
/*
 * this function will start http-file-server
 */
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
/*
 * this function will jslint current-directory
 */
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
/*
 * this function will start repl-debugger
 */
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
            /^(\S+)\u0020(.*?)\n/
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
                    /^git\u0020/
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
/*
 * this function will watch current-directory for changes
 */
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
/* sh jslint_ci.sh shBrowserScreenshot asset-image-logo.html --window-size=512x512 */
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
    src: url("asset-font-daley-bold.woff2") format("woff2");
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
' > .build/asset-image-logo-512.html
    cp asset-font-daley-bold.woff2 .build || true
    # screenshot asset-image-logo-512.png
    shBrowserScreenshot .build/asset-image-logo-512.html \
        --window-size=512x512 \
        -screenshot=.build/asset-image-logo-512.png
    # create various smaller thumbnails
    for SIZE in 32 64 128 256
    do
        convert -resize "${SIZE}x${SIZE}" .build/asset-image-logo-512.png \
            ".build/asset-image-logo-$SIZE.png"
        printf \
"shImageLogoCreate - wrote - .build/asset-image-logo-$SIZE.png\n" 1>&2
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
            /[\t\u0020]+$/gm
        ), "");
        // remove leading-newline before ket
        result = result.replace((
            /\n+?(\n\u0020*?\})/g
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
            /\n\/\*\nfile\u0020none\n\*\/\n\/\*jslint-enable\*\/\n([\S\s]+)/
        ), function (ignore, match1) {
            result += "\n\n" + match1.trim() + "\n";
        });
        // write to file
        moduleFs.writeFileSync(process.argv[1], result); //jslint-quiet
    });
}());
' "$@" # '
    git diff 2>/dev/null || true
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
# and create coverage-report .build/coverage/index.html
    local EXIT_CODE
    EXIT_CODE=0
    export DIR_COVERAGE=.build/coverage/
    rm -rf "$DIR_COVERAGE"
    mkdir -p "$DIR_COVERAGE"
    (set -e
        export NODE_V8_COVERAGE="$DIR_COVERAGE"
        "$@"
    ) || EXIT_CODE="$?"
    if [ "$EXIT_CODE" = 0 ]
    then
        node --input-type=module -e '
import moduleFs from "fs";
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
         * https://stackoverflow.com/questions/7381974/which-characters-need-to-be-escaped-on-html //jslint-quiet
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
.coverage .coverageIgnore{
    background: #ccc;
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
    background: #7d7;
}
.coverage pre:hover span.uncovered,
.coverage tr:hover td.coverageLow {
    background: #d99;
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
        txt += "coverage-report\n";
        txt += txtBorder;
        txt += (
            "| " + String("files covered").padEnd(padPathname, " ") + " | "
            + String("lines").padStart(padLines, " ") + " |\n"
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
            if (!lineList && ii === 0) {
                fill = (
                    // red
                    "#" + Math.round(
                        (100 - Number(coveragePct)) * 2.21
                    ).toString(16).padStart(2, "0")
                    // green
                    + Math.round(
                        Number(coveragePct) * 2.21
                    ).toString(16).padStart(2, "0")
                    + // blue
                    "00"
                );
                str1 = "coverage";
                str2 = coveragePct + " %";
                xx1 = 6 * str1.length + 20;
                xx2 = 6 * str2.length + 20;
                // fs - write coverage-badge.svg
                moduleFs.promises.writeFile((
                    DIR_COVERAGE + "/coverage-badge.svg"
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
                `).trim() + "\n");
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
            pathname = stringHtmlSafe(pathname);
            html += `<tr>
<td class="${coverageLevel}">
            ${(
                lineList
                ? (
                    "<a href=\"index.html\">./ </a>"
                    + pathname + "<br>"
                )
                : (
                    "<a href=\"" + (pathname || "index") + ".html\">./ "
                    + pathname + "</a><br>"
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
        await moduleFs.promises.mkdir(modulePath.dirname(pathname), {
            recursive: true
        });
        // fs - write *.html
        moduleFs.promises.writeFile(pathname + ".html", html);
        if (lineList) {
            return;
        }
        // fs - write coverage.txt
        console.error("\n" + txt);
        moduleFs.promises.writeFile((
            DIR_COVERAGE + "/coverage-report.txt"
        ), txt);
    }
    data = await moduleFs.promises.readdir(DIR_COVERAGE);
    await Promise.all(data.map(async function (file) {
        if ((
            /^coverage-.*?\.json$/
        ).test(file)) {
            data = await moduleFs.promises.readFile((
                DIR_COVERAGE + file
            ), "utf8");
            // fs - rename to coverage-v8.json
            moduleFs.promises.rename(
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
        if (!url.startsWith("file:///")) {
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
            !pathname.startsWith(cwd)
            || pathname.startsWith(cwd + "[")
            || (
                process.env.npm_config_mode_coverage !== "all"
                && pathname.indexOf("/node_modules/") >= 0
            )
        ) {
            return;
        }
        pathname = pathname.replace(cwd, "");
        src = await moduleFs.promises.readFile(pathname, "utf8");
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
        await moduleFs.promises.mkdir((
            modulePath.dirname(DIR_COVERAGE + pathname)
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
                ).test(src.slice(0, 65536))
                ? "(ignore)"
                : ""
            ),
            pathname,
            src
        };
        await htmlRender({
            fileList: [
                fileDict[pathname]
            ],
            lineList,
            pathname: DIR_COVERAGE + pathname
        });
    }));
    await htmlRender({
        fileList: Object.keys(fileDict).sort().map(function (pathname) {
            return fileDict[pathname];
        }),
        pathname: DIR_COVERAGE + "index"
    });
}());
' "$@" # '
        find "$DIR_COVERAGE"
    fi
    printf "shRunWithCoverage - EXIT_CODE=$EXIT_CODE\n" 1>&2
    return "$EXIT_CODE"
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
    printf "shRunWithScreenshotTxt - EXIT_CODE=$EXIT_CODE\n" 1>&2
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
    # run "$@" with winpty
    export CI_UNAME="${CI_UNAME:-$(uname)}"
    case "$CI_UNAME" in
    MSYS*)
        if [ ! "$CI_WINPTY" ] && [ "$1" != shHttpFileServer ]
        then
            export CI_WINPTY=1
            winpty -Xallow-non-tty -Xplain sh jslint_ci.sh "$@"
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
