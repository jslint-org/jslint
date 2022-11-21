/*jslint beta, node*/
import jslint from "./jslint.mjs";
import jslintCjs from "./jslint_wrapper_cjs.cjs";
import moduleFs from "fs";
import modulePath from "path";

let {
    assertErrorThrownAsync,
    assertJsonEqual,
    assertOrThrow,
    debugInline,
    fsWriteFileWithParents,
    globExclude,
    jstestDescribe,
    jstestIt,
    jstestOnExit,
    moduleFsInit,
    noop,
    v8CoverageListMerge,
    v8CoverageReportCreate
} = jslint;
let sourceJslintMjs;
let testCoverageMergeData;

await (async function init() {

// Coverage-hack - Ugly-hack to get test-coverage for all initialization-states.

    moduleFsInit();
    moduleFsInit();

// Cleanup directory .tmp

    await moduleFs.promises.rm(".tmp", {
        recursive: true
    }).catch(noop);

// init sourceJslintMjs

    sourceJslintMjs = await moduleFs.promises.readFile("jslint.mjs", "utf8");

// init testCoverageMergeData

    testCoverageMergeData = JSON.parse(
        await moduleFs.promises.readFile(
            "test_coverage_merge_data.json",
            "utf8"
        )
    );
}());

jstestDescribe((
    "test fsXxx handling-behavior"
), function testBehaviorFsXxx() {
    jstestIt((
        "test fsWriteFileWithParents handling-behavior"
    ), async function () {
        await Promise.all([
            1, 2, 3, 4
        ].map(async function () {
            await fsWriteFileWithParents(
                ".tmp/fsWriteFileWithParents/aa/bb/cc",
                "aa"
            );
        }));
        assertJsonEqual(
            await moduleFs.promises.readFile(
                ".tmp/fsWriteFileWithParents/aa/bb/cc",
                "utf8"
            ),
            "aa"
        );
    });
});

jstestDescribe((
    "test globXxx handling-behavior"
), function testBehaviorGlobXxx() {
    jstestIt((
        "test globAssertNotWeird-error handling-behavior"
    ), async function () {
        await Promise.all([
            "\n",
            "\r",
            "\u0000"
        ].map(async function (char) {
            await assertErrorThrownAsync(function () {
                return globExclude({
                    pathnameList: [
                        "aa",
                        `cc/${char}/dd`,
                        "bb"
                    ]
                });
            }, (
                "Weird character "
                + JSON.stringify(char).replace("\\", "\\\\")
                + " found in "
            ));
        }));
    });
    jstestIt((
        "test globExclude handling-behavior"
    ), function () {
        let pathnameList = [
            ".dockerignore",
            ".eslintrc.js",
            ".gitignore",
            ".npmignore",
            ".travis.yml",
            "/node_modules/aa/bb/cc.js",
            "/node_modules/aa/bb/dd.js",
            "CHANGELOG.md",
            "CONTRIBUTING.md",
            "Dockerfile",
            "LICENSE",
            "Makefile",
            "README.md",
            "appveyor.yml",
            "benchmark/insert-transaction.sql",
            "benchmark/insert.js",
            "binding.gyp",
            "cloudformation/ci.template.js",
            "deps/common-sqlite.gypi",
            "deps/extract.py",
            "deps/sqlite-autoconf-3340000.tar.gz",
            "deps/sqlite3.gyp",
            "examples/simple-chaining.js",
            "lib/index.js",
            "lib/sqlite3-binding.js",
            "lib/sqlite3.js",
            "lib/trace.js",
            "node_modules/aa/bb/cc.js",
            "node_modules/aa/bb/dd.js",
            "package.json",
            "scripts/build-appveyor.bat",
            "scripts/build-local.bat",
            "scripts/build_against_electron.sh",
            "scripts/build_against_node.sh",
            "scripts/build_against_node_webkit.sh",
            "scripts/build_for_node_webkit.cmd",
            "scripts/install_node.sh",
            "scripts/validate_tag.sh",
            "sqlite3.js",
            "src/async.h",
            "src/backup.cc",
            "src/backup.h",
            "src/database.cc",
            "src/database.h",
            "src/gcc-preinclude.h",
            "src/macros.h",
            "src/node_sqlite3.cc",
            "src/statement.cc",
            "src/statement.h",
            "src/threading.h",
            "test/affected.test.js",
            "test/backup.test.js",
            "test/blob.test.js",
            "test/cache.test.js",
            "test/constants.test.js",
            "test/database_fail.test.js",
            "test/each.test.js",
            "test/exec.test.js",
            "test/extension.test.js",
            "test/fts-content.test.js",
            "test/interrupt.test.js",
            "test/issue-108.test.js",
            "test/json.test.js",
            "test/map.test.js",
            "test/named_columns.test.js",
            "test/named_params.test.js",
            "test/null_error.test.js",
            "test/nw/.gitignore",
            "test/nw/Makefile",
            "test/nw/index.html",
            "test/nw/package.json",
            "test/open_close.test.js",
            "test/other_objects.test.js",
            "test/parallel_insert.test.js",
            "test/prepare.test.js",
            "test/profile.test.js",
            "test/rerun.test.js",
            "test/scheduling.test.js",
            "test/serialization.test.js",
            "test/support/createdb-electron.js",
            "test/support/createdb.js",
            "test/support/elmo.png",
            "test/support/helper.js",
            "test/support/prepare.db",
            "test/support/script.sql",
            "test/trace.test.js",
            "test/unicode.test.js",
            "test/upsert.test.js",
            "test/verbose.test.js",
            "tools/docker/architecture/linux-arm/Dockerfile",
            "tools/docker/architecture/linux-arm/run.sh",
            "tools/docker/architecture/linux-arm64/Dockerfile",
            "tools/docker/architecture/linux-arm64/run.sh"
        ];
        [
            "tes?/",
            "tes[-t-]/",
            "tes[-t]/",
            "tes[0-9A-Z_a-z-]/",
            "tes[t-]/",
            "test/**/*.js"
        ].forEach(function (aa) {
            [
                "li*/*.js",
                "li?/*.js",
                "lib/",
                "lib/*",
                "lib/**/*.js",
                "lib/*.js"
            ].forEach(function (bb) {
                [
                    "",
                    "**/node_modules/",
                    "node_modules/"
                ].forEach(function (cc) {
                    assertJsonEqual(
                        globExclude({
                            excludeList: [
                                "tes[!0-9A-Z_a-z-]/",
                                "tes[^0-9A-Z_a-z-]/",
                                "test/suppor*/*elper.js",
                                "test/suppor?/?elper.js",
                                "test/support/helper.js"
                            ].concat(aa, cc),
                            includeList: [
                                "**/*.cjs",
                                "**/*.js",
                                "**/*.mjs",
                                "lib/sqlite3.js"
                            ].concat(bb),
                            pathnameList
                        }).pathnameList,
                        [
                            ".eslintrc.js",
                            "benchmark/insert.js",
                            "cloudformation/ci.template.js",
                            "examples/simple-chaining.js",
                            "lib/index.js",
                            "lib/sqlite3-binding.js",
                            "lib/sqlite3.js",
                            "lib/trace.js",
                            "sqlite3.js"
                        ].concat(
                            cc === "**/node_modules/"
                            ? [
                                "node_modules/aa/bb/cc.js",
                                "node_modules/aa/bb/dd.js"
                            ]
                            : cc === "node_modules/"
                            ? [
                                "/node_modules/aa/bb/cc.js",
                                "/node_modules/aa/bb/dd.js"
                            ]
                            : [
                                "/node_modules/aa/bb/cc.js",
                                "/node_modules/aa/bb/dd.js",
                                "node_modules/aa/bb/cc.js",
                                "node_modules/aa/bb/dd.js"
                            ]
                        ).sort()
                    );
                });
            });
        });
    });
    jstestIt((
        "test globToRegexp handling-behavior"
    ), function () {
        Object.entries({
            "*": (
                /^[^\/]*?$/gm
            ),
            "**": (
                /^.*?$/gm
            ),
            "***": (
                /^.*?$/gm
            ),
            "****": (
                /^.*?$/gm
            ),
            "****////****": (
                /^.*?$/gm
            ),
            "***///***": (
                /^.*?$/gm
            ),
            "**/*": (
                /^.*?$/gm
            ),
            "**/node_modules/": (
                /^.*?\/node_modules\/.*?$/gm
            ),
            "**/node_modules/**/*": (
                /^.*?\/node_modules\/.*?$/gm
            ),
            "?": (
                /^[^\/]$/gm
            ),
            "[!0-9A-Za-z-]": (
                /^[^0-9A-Za-z\-]$/gm
            ),
            "[0-9A-Za-z-]": (
                /^[0-9A-Za-z\-]$/gm
            ),
            "[[]] ]][[": (
                /^[\[]\] \]\][\[]$/gm
            ),
            "[]": (
                /^$/gm
            ),
            "[^0-9A-Za-z-]": (
                /^[^0-9A-Za-z\-]$/gm
            ),
            "aa/bb/cc": (
                /^aa\/bb\/cc$/gm
            ),
            "aa/bb/cc/": (
                /^aa\/bb\/cc\/.*?$/gm
            ),
            "li*/*": (
                /^li[^\/]*?\/[^\/]*?$/gm
            ),
            "li?/*": (
                /^li[^\/]\/[^\/]*?$/gm
            ),
            "lib/": (
                /^lib\/.*?$/gm
            ),
            "lib/*": (
                /^lib\/[^\/]*?$/gm
            ),
            "lib/**/*.js": (
                /^lib\/.*?\.js$/gm
            ),
            "lib/*.js": (
                /^lib\/[^\/]*?\.js$/gm
            ),
            "node_modules/": (
                /^node_modules\/.*?$/gm
            ),
            "node_modules/**/*": (
                /^node_modules\/.*?$/gm
            ),
            "tes[!0-9A-Z_a-z-]/**/*": (
                /^tes[^0-9A-Z_a-z\-]\/.*?$/gm
            ),
            "tes[0-9A-Z_a-z-]/**/*": (
                /^tes[0-9A-Z_a-z\-]\/.*?$/gm
            ),
            "tes[^0-9A-Z_a-z-]/**/*": (
                /^tes[^0-9A-Z_a-z\-]\/.*?$/gm
            ),
            "test/**/*": (
                /^test\/.*?$/gm
            ),
            "test/**/*.js": (
                /^test\/.*?\.js$/gm
            ),
            "test/suppor*/*elper.js": (
                /^test\/suppor[^\/]*?\/[^\/]*?elper\.js$/gm
            ),
            "test/suppor?/?elper.js": (
                /^test\/suppor[^\/]\/[^\/]elper\.js$/gm
            ),
            "test/support/helper.js": (
                /^test\/support\/helper\.js$/gm
            )
        }).forEach(function ([
            pattern, rgx
        ]) {
            assertJsonEqual(
                globExclude({
                    excludeList: [
                        pattern
                    ]
                }).excludeList[0].source,
                rgx.source
            );
            assertJsonEqual(
                globExclude({
                    includeList: [
                        pattern
                    ]
                }).includeList[0].source,
                rgx.source
            );
        });
    });
});

jstestDescribe((
    "test jslint's cli handling-behavior"
), function testBehaviorJslintCli() {
    function processExit0(exitCode) {
        assertOrThrow(exitCode === 0, exitCode);
    }
    function processExit1(exitCode) {
        assertOrThrow(exitCode === 1, exitCode);
    }
    jstestIt((
        "test cli-null-case handling-behavior"
    ), function () {
        jslint.jslint_cli({
            mode_noop: true,
            process_exit: processExit0
        });
    });
    jstestIt((
        "test cli-window-jslint handling-behavior"
    ), function () {
        [
            "&window_jslint=",
            "&window_jslint=12",
            "&window_jslint=1?",
            "&window_jslint=?",
            "?window_jslint=",
            "?window_jslint=12",
            "?window_jslint=1?",
            "?window_jslint=?",
            "window_jslint=1",
            "window_jslint=1&",
            "window_jslint=12",
            "window_jslint=1?"
        ].forEach(function (import_meta_url) {
            jslint.jslint_cli({
                import_meta_url
            });
            assertOrThrow(globalThis.jslint === undefined);
        });
        [
            "&window_jslint=1",
            "&window_jslint=1&",
            "?window_jslint=1",
            "?window_jslint=1&"
        ].forEach(function (import_meta_url) {
            jslint.jslint_cli({
                import_meta_url
            });
            assertOrThrow(globalThis.jslint === jslint);
            delete globalThis.jslint;
        });
    });
    jstestIt((
        "test cli-cjs-and-invalid-file handling-behavior"
    ), async function () {
        await fsWriteFileWithParents(".test_dir.cjs/touch.txt", "");
        [
            ".",            // test dir handling-behavior
            "jslint.mjs",   // test file handling-behavior
            undefined       // test file-undefined handling-behavior
        ].forEach(function (file) {
            jslint.jslint_cli({
                file,
                mode_cli: true,
                process_env: {
                    JSLINT_BETA: "1"
                },
                process_exit: processExit0
            });
        });
    });
    jstestIt((
        "test cli-apidoc handling-behavior"
    ), function () {
        jslint.jslint_cli({
            mode_cli: true,
            process_argv: [
                "node",
                "jslint.mjs",
                "jslint_apidoc=.artifact/apidoc.html",
                JSON.stringify({
                    example_list: [
                        "README.md",
                        "test.mjs",
                        "jslint.mjs"
                    ],
                    github_repo: "https://github.com/jslint-org/jslint",
                    module_list: [
                        {
                            pathname: "./jslint.mjs"
                        }
                    ],
                    package_name: "JSLint",
                    version: jslint.jslint_edition
                })
            ],
            process_exit: processExit0
        });
    });
    jstestIt((
        "test cli-file-error handling-behavior"
    ), function () {
        jslint.jslint_cli({
            // suppress error
            console_error: noop,
            file: "undefined",
            mode_cli: true,
            process_exit: processExit1
        });
    });
    jstestIt((
        "test cli-syntax-error handling-behavior"
    ), function () {
        jslint.jslint_cli({
            // suppress error
            console_error: noop,
            file: "syntax-error.js",
            mode_cli: true,
            option: {
                trace: true
            },
            process_exit: processExit1,
            source: "syntax error"
        });
    });
    jstestIt((
        "test cli-report handling-behavior"
    ), function () {
        jslint.jslint_cli({
            // suppress error
            console_error: noop,
            mode_cli: true,
            process_argv: [
                "node",
                "jslint.mjs",
                "jslint_report=.tmp/jslint_report.html",
                "jslint.mjs"
            ],
            process_exit: processExit0
        });
    });
    jstestIt((
        "test cli-report-error handling-behavior"
    ), function () {
        jslint.jslint_cli({
            // suppress error
            console_error: noop,
            mode_cli: true,
            process_argv: [
                "node",
                "jslint.mjs",
                "jslint_report=.tmp/jslint_report.html",
                "syntax-error.js"
            ],
            process_exit: processExit1,
            source: "syntax error"
        });
    });
    jstestIt((
        "test cli-report-json handling-behavior"
    ), function () {
        jslint.jslint_cli({
            // suppress error
            console_error: noop,
            mode_cli: true,
            process_argv: [
                "node",
                "jslint.mjs",
                "jslint_report=.tmp/jslint_report.html",
                "aa.json"
            ],
            process_exit: processExit0,
            source: "[]"
        });
    });
    jstestIt((
        "test cli-report-json-error handling-behavior"
    ), function () {
        jslint.jslint_cli({
            // suppress error
            console_error: noop,
            mode_cli: true,
            process_argv: [
                "node",
                "jslint.mjs",
                "jslint_report=.tmp/jslint_report.html",
                "aa.json"
            ],
            process_exit: processExit1,
            source: "["
        });
    });
    jstestIt((
        "test cli-report-misc handling-behavior"
    ), function () {
        jslint.jslint_cli({
            // suppress error
            console_error: noop,
            mode_cli: true,
            process_argv: [
                "node",
                "jslint.mjs",
                "jslint_report=.tmp/jslint_report.html",
                "aa.js"
            ],
            process_exit: processExit0,
            source: "let aa = 0;"
        });
        jslint.jslint_cli({
            // suppress error
            console_error: noop,
            mode_cli: true,
            process_argv: [
                "node",
                "jslint.mjs",
                "jslint_report=.tmp/jslint_report.html",
                "aa.js"
            ],
            process_exit: processExit1,
            source: "(aa)=>aa; function aa([aa]){}"
        });
    });
    jstestIt((
        "test cli-jslint-wrapper-vim handling-behavior"
    ), function () {
        jslint.jslint_cli({
            // suppress error
            console_error: noop,
            mode_cli: true,
            process_argv: [
                "node",
                "jslint.mjs",
                "jslint_wrapper_vim",
                "syntax-error.js"
            ],
            process_exit: processExit1,
            source: "syntax error"
        });
    });
});

jstestDescribe((
    "test jslint's no-warnings handling-behavior"
), function testBehaviorJslintNoWarnings() {
    jstestIt((
        "test jslint's no-warnings handling-behavior"
    ), function () {
        Object.values({
            array: [
                "new Array(0);"
            ],
            async_await: [
                "async function aa() {\n    await aa();\n}",

// PR-405 - Bugfix - fix expression after "await" mis-identified as statement.

                "async function aa() {\n    await aa;\n}",
                (
                    "async function aa() {\n"
                    + "    try {\n"
                    + "        aa();\n"
                    + "    } catch (err) {\n"
                    + "        await err();\n"
                    + "    }\n"
                    + "}\n"
                ),
                (
                    "async function aa() {\n"
                    + "    try {\n"
                    + "        await aa();\n"
                    + "    } catch (err) {\n"
                    + "        await err();\n"
                    + "    }\n"
                    + "}\n"
                ),

// PR-370 - Add top-level-await support.

                "await String();\n"
            ],

// PR-351 - Add BigInt support.

            bigint: [
                "let aa = 0b0n;\n",
                "let aa = 0o0n;\n",
                "let aa = 0x0n;\n",
                "let aa = BigInt(0n);\n",
                "let aa = typeof aa === \"bigint\";\n"
            ],
            date: [
                "Date.getTime();",
                "let aa = aa().getTime();",
                "let aa = aa.aa().getTime();"
            ],
            directive: [
                "#!\n/*jslint browser:false, node*/\n\"use strict\";",
                "/*property aa bb*/"
            ],
            for: [
                (
                    "/*jslint for*/\n"
                    + "function aa(bb) {\n"
                    + "    for (bb = 0; bb < 0; bb += 1) {\n"
                    + "        bb();\n"
                    + "    }\n"
                    + "}\n"
                )
            ],
            jslint_disable: [
                "/*jslint-disable*/\n0\n/*jslint-enable*/"
            ],
            jslint_ignore_line: [
                "0 //jslint-ignore-line"
            ],
            json: [
                "{\"aa\":[[],-0,null]}"
            ],
            label: [
                (
                    "function aa() {\n"
                    + "bb:\n"
                    + "    while (true) {\n"
                    + "        if (true) {\n"
                    + "            break bb;\n"
                    + "        }\n"
                    + "    }\n"
                    + "}\n"
                )
            ],
            loop: [
                (
                    "function aa() {\n"
                    + "    do {\n"
                    + "        aa();\n"
                    + "    } while (aa());\n"
                    + "}\n"
                ),

// PR-378 - Relax warning "function_in_loop".

                (
                    "function aa() {\n"
                    + "    while (true) {\n"
                    + "        (function () {\n"
                    + "            return;\n"
                    + "        }());\n"
                    + "    }\n"
                    + "}\n"
                )
            ],
            module: [
                "export default Object.freeze();",
                "import {aa, bb} from \"aa\";\naa(bb);",
                "import {} from \"aa\";",
                "import(\"aa\").then(function () {\n    return;\n});",
                (
                    "let aa = 0;\n"
                    + "import(aa).then(aa).then(aa)"
                    + ".catch(aa).finally(aa);\n"
                )
            ],
            number: [
                "let aa = 0.0e0;",
                "let aa = 0b0;",
                "let aa = 0o0;",
                "let aa = 0x0;"
            ],

// PR-390 - Add numeric-separator support.

            numeric_separator: [
                "let aa = 0.0_0_0;",
                "let aa = 0b0_1111_1111n;\n",
                "let aa = 0o0_1234_1234n;\n",
                "let aa = 0x0_1234_1234n;\n",
                "let aa = 1_234_234.1_234_234E1_234_234;"
            ],
            optional_chaining: [
                "let aa = aa?.bb?.cc;"
            ],
            param: [
                "function aa({aa, bb}) {\n    return {aa, bb};\n}\n",
                (
                    "function aa({constructor}) {\n"
                    + "    return {constructor};\n"
                    + "}\n"
                )
            ],
            property: [
                "let aa = aa[`!`];"
            ],
            regexp: [
                "function aa() {\n    return /./;\n}",
                "let aa = /(?!.)(?:.)(?=.)/;",
                "let aa = /./gimuy;",
                "let aa = /[\\--\\-]/;"
            ],
            ternary: [
                (
                    "let aa = (\n"
                    + "    aa()\n"
                    + "    ? 0\n"
                    + "    : 1\n"
                    + ") "
                    + "&& (\n"
                    + "    aa()\n"
                    + "    ? 0\n"
                    + "    : 1\n"
                    + ");"
                ),
                (
                    "let aa = (\n"
                    + "    aa()\n"
                    + "    ? `${0}`\n"
                    + "    : `${1}`\n"
                    + ");"
                ),

// PR-394 - Bugfix
// Fix jslint falsely believing megastring literals `0` and `1` are similar.

                (
                    "let aa = (\n"
                    + "    aa()\n"
                    + "    ? `0`\n"
                    + "    : `1`\n"
                    + ");"
                )
            ],
            try_catch: [
                (
                    "let aa = 0;\n"
                    + "try {\n"
                    + "    aa();\n"
                    + "} catch (err) {\n"
                    + "    aa = err;\n"
                    + "}\n"
                    + "try {\n"
                    + "    aa();\n"
                    + "} catch (err) {\n"
                    + "    aa = err;\n"
                    + "}\n"
                    + "aa();\n"
                )
            ],
            try_finally: [
                (
                    "let aa = 0;\n"
                    + "try {\n"
                    + "    aa();\n"
                    + "} finally {\n"
                    + "    aa();\n"
                    + "}\n"
                )
            ],
            use_strict: [
                (
                    "\"use strict\";\n"
                    + "let aa = 0;\n"
                    + "function bb() {\n"
                    + "    \"use strict\";\n"
                    + "    return aa;\n"
                    + "}\n"
                )
            ],
            var: [

// PR-363 - Bugfix
// Add test against false-warning <uninitialized 'bb'> in code
// '/*jslint node*/\nlet {aa:bb} = {}; bb();'.

                "/*jslint node*/\n",
                ""
            ].map(function (directive) {
                return [
                    "let [\n    aa, bb = 0\n] = 0;\naa();\nbb();",
                    "let [...aa] = [...aa];\naa();",
                    "let constructor = 0;\nconstructor();",
                    "let {\n    aa: bb\n} = 0;\nbb();",
                    "let {\n    aa: bb,\n    bb: cc\n} = 0;\nbb();\ncc();",
                    "let {aa, bb} = 0;\naa();\nbb();",
                    "let {constructor} = 0;\nconstructor();"
                ].map(function (code) {
                    return directive + code;
                });
            }).flat()
        }).forEach(function (codeList) {
            let elemPrv = "";
            codeList.forEach(function (code) {
                let warnings;
                // Assert codeList is sorted.
                assertOrThrow(elemPrv < code, JSON.stringify([
                    elemPrv, code
                ], undefined, 4));
                elemPrv = code;
                [
                    jslint.jslint,
                    jslintCjs.jslint
                ].forEach(function (jslint) {
                    warnings = jslint(code, {
                        beta: true
                    }).warnings;
                    assertOrThrow(
                        warnings.length === 0,
                        JSON.stringify([code, warnings])
                    );
                });
            });
        });
    });
});

jstestDescribe((
    "test jslint's option handling-behavior"
), function testBehaviorJslintOption() {
    let elemPrv = "";
    [
        [
            "let aa = aa | 0;", {bitwise: true}, []
        ], [
            ";\naa(new XMLHttpRequest());", {browser: true}, ["aa"]
        ], [
            "let aa = \"aa\" + 0;", {convert: true}, []
        ], [
            "registerType();", {couch: true}, []
        ], [
            "debugger;", {devel: true}, []
        ], [

// PR-404 - Alias "evil" to jslint-directive "eval" for backwards-compat.

            "new Function();\neval();", {eval: true, evil: true}, []
        ], [
            "let aa = () => 0;", {fart: true}, []
        ], [
            (
                "let aa = async (bb, {cc, dd}, [ee, ff], ...gg) => {\n"
                + "    bb += 1;\n"
                + "    return await (bb + cc + dd + ee + ff + gg);\n"
                + "};\n"
            ), {fart: true}, []
        ], [
            (
                "function aa(aa) {\n"
                + "    for (aa = 0; aa < 0; aa += 1) {\n"
                + "        aa();\n"
                + "    }\n"
                + "}\n"
            ), {for: true}, []
        ], [
            "let aa = {get aa() {\n    return;\n}};", {getset: true}, []
        ], [
            "let aa = {set aa(aa) {\n    return aa;\n}};", {getset: true}, []
        ], [
            sourceJslintMjs.replace((
                /    /g
            ), "  "), {indent2: true}, []
        ], [
            "function aa() {\n  return;\n}", {indent2: true}, []
        ], [
            "/".repeat(100), {long: true}, []
        ], [

// PR-404 - Alias "nomen" to jslint-directive "name" for backwards-compat.

            "let aa = aa._;", {name: true, nomen: true}, []
        ], [
            "require();", {node: true}, []
        ], [
            "let aa = 'aa';", {single: true}, []
        ], [

// PR-404 - Add new directive "subscript" to play nice with Google Closure.

            "aa[\"aa\"] = 1;", {subscript: true}, ["aa"]
        ], [
            "", {test_internal_error: true}, []
        ], [
            "let aa = this;", {this: true}, []
        ], [
            "", {trace: true}, []
        ], [
            (
                "function aa({bb, aa}) {\n"
                + "    switch (aa) {\n"
                + "    case 1:\n"
                + "        break;\n"
                + "    case 0:\n"
                + "        break;\n"
                + "    default:\n"
                + "        return {bb, aa};\n"
                + "    }\n"
                + "}\n"
            ), {unordered: true}, []
        ], [
            "let {bb, aa} = 0;", {unordered: true}, []
        ], [
            (
                "function aa() {\n"
                + "    if (aa) {\n"
                + "        let bb = 0;\n"
                + "        return bb;\n"
                + "    }\n"
                + "}\n"
            ), {variable: true}, []
        ], [
            "let bb = 0;\nlet aa = 0;", {variable: true}, []
        ], [
            "\t", {white: true}, []
        ]
    ].forEach(function ([
        source, option_dict, global_list
    ]) {
        jstestIt((
            `test option=${JSON.stringify(option_dict)} handling-behavior`
        ), function () {
            let elemNow = JSON.stringify([
                option_dict, source, global_list
            ]);
            let warningsLength = (
                option_dict.test_internal_error
                ? 1
                : 0
            );
            // Assert list is sorted.
            assertOrThrow(elemPrv < elemNow, JSON.stringify([
                elemPrv, elemNow
            ], undefined, 4));
            elemPrv = elemNow;
            option_dict.beta = true;
            [
                jslint.jslint,
                jslintCjs.jslint
            ].forEach(function (jslint) {
                // test jslint's option handling-behavior
                assertOrThrow(
                    jslint(
                        source,
                        option_dict,
                        global_list
                    ).warnings.length === warningsLength,
                    "jslint.jslint(" + JSON.stringify([
                        source, option_dict, global_list
                    ]) + ")"
                );
                // test jslint's directive handling-behavior
                source = (
                    "/*jslint " + JSON.stringify(
                        option_dict
                    ).slice(1, -1).replace((
                        /"/g
                    ), "") + "*/\n"
                    + (
                        global_list.length === 0
                        ? ""
                        : "/*global " + global_list.join(",") + "*/\n"
                    )
                    + source.replace((
                        /^#!/
                    ), "//")
                );
                assertOrThrow(
                    jslint(source).warnings.length === warningsLength,
                    source
                );
            });
        });
    });
});

jstestDescribe((
    "test jslint's warnings handling-behavior"
), function testBehaviorJslintWarnings() {
    jstestIt((
        "test jslint's warning handling-behavior"
    ), function () {

// this function will validate each jslint <warning> is raised with given
// malformed <code>

        sourceJslintMjs.replace((
            /(\n\s*?\/\/\s*?test_cause:\s*?)(\S[\S\s]*?\S)(\n\n\s*?) *?\S/g
        ), function (match0, header, causeList, footer) {
            let tmp;
            // console.error(match0);
            // Validate header.
            assertOrThrow(header === "\n\n// test_cause:\n", match0);
            // Validate footer.
            assertOrThrow(footer === "\n\n", match0);
            // Validate causeList.
            causeList = causeList.replace((
                /^\/\/ /gm
            ), "").replace((
                /^\["\n([\S\s]*?)\n"(,.*?)$/gm
            ), function (ignore, source, param) {
                source = "[" + JSON.stringify(source) + param;
                assertOrThrow(source.length > (80 - 3), source);
                return source;
            }).replace((
                / \/\/jslint-ignore-line$/gm
            ), "");
            tmp = causeList.split("\n").map(function (cause) {
                return (
                    "["
                    + JSON.parse(cause).map(function (elem) {
                        return JSON.stringify(elem);
                    }).join(", ")
                    + "]"
                );
            }).sort().join("\n");
            assertOrThrow(
                causeList === tmp,
                "\n" + causeList + "\n\n" + tmp
            );
            causeList.split("\n").forEach(function (cause) {
                cause = JSON.parse(cause);
                tmp = jslint.jslint(cause[0], {
                    beta: true,
                    test_cause: true
                }).causes;
                // Validate cause.
                assertOrThrow(
                    tmp[JSON.stringify(cause.slice(1))],
                    (
                        "\n" + JSON.stringify(cause) + "\n\n"
                        + Object.keys(tmp).sort().join("\n")
                    )
                );
            });
            return "";
        });
    });
});

jstestDescribe((
    "test jstestXxx handling-behavior"
), function testBehaviorJstestXxx() {
    jstestIt((
        "test jstestDescribe error handling-behavior"
    ), function () {
        throw new Error();
    }, "pass");
    jstestIt((
        "test jstestOnExit tests-failed handling-behavior"
    ), function () {
        jstestOnExit(undefined, "testsFailed");
    });
});

jstestDescribe((
    "test misc handling-behavior"
), function testBehaviorMisc() {
    jstestIt((
        "test misc handling-behavior"
    ), async function () {
        // test debugInline handling-behavior
        noop(debugInline);
        // test assertErrorThrownAsync error handling-behavior
        await assertErrorThrownAsync(function () {
            return assertErrorThrownAsync(noop);
        });
        // test assertJsonEqual error handling-behavior
        await assertErrorThrownAsync(function () {
            assertJsonEqual(1, 2);
        });
        await assertErrorThrownAsync(function () {
            assertJsonEqual(1, 2, "undefined");
        });
        await assertErrorThrownAsync(function () {
            assertJsonEqual(1, 2, {});
        });
        // test assertOrThrow error handling-behavior
        await assertErrorThrownAsync(function () {
            assertOrThrow(undefined, "undefined");
        });
        await assertErrorThrownAsync(function () {
            assertOrThrow(undefined, new Error());
        });
    });
});

jstestDescribe((
    "test v8CoverageListMerge handling-behavior"
), function testBehaviorV8CoverageListMerge() {
    let functionsInput = JSON.stringify([
        {
            functionName: "test",
            isBlockCoverage: true,
            ranges: [
                {
                    count: 2,
                    endOffset: 4,
                    startOffset: 0
                },
                {
                    count: 1,
                    endOffset: 2,
                    startOffset: 1
                },
                {
                    count: 1,
                    endOffset: 3,
                    startOffset: 2
                }
            ]
        }
    ]);
    jstestIt((
        "accepts empty arrays for `v8CoverageListMerge`"
    ), function () {
        assertJsonEqual(v8CoverageListMerge([]), {
            result: []
        });
    });
    jstestIt((
        "funcCovs.length === 1"
    ), function () {
        assertJsonEqual(v8CoverageListMerge([
            {
                result: [
                    {
                        functions: [
                            {
                                functionName: "test",
                                isBlockCoverage: true,
                                ranges: [
                                    {
                                        count: 2,
                                        endOffset: 4,
                                        startOffset: 0
                                    }
                                ]
                            }
                        ],
                        moduleUrl: "/lib.js",
                        scriptId: "1"
                    }
                ]
            },
            {
                result: [
                    {
                        functions: [],
                        moduleUrl: "/lib.js",
                        scriptId: "2"
                    }
                ]
            }
        ]), {
            result: [
                {
                    functions: [
                        {
                            functionName: "test",
                            isBlockCoverage: true,
                            ranges: [
                                {
                                    count: 2,
                                    endOffset: 4,
                                    startOffset: 0
                                }
                            ]
                        }
                    ],
                    scriptId: "0"
                }
            ]
        });
    });
    jstestIt((
        "accepts arrays with a single item for `v8CoverageListMerge`"
    ), function () {
        assertJsonEqual(v8CoverageListMerge([
            {
                result: [
                    {
                        functions: JSON.parse(functionsInput),
                        moduleUrl: "/lib.js",
                        scriptId: "123"
                    }
                ]
            }
        ]), {
            result: [
                {
                    functions: [
                        {
                            functionName: "test",
                            isBlockCoverage: true,
                            ranges: [
                                {
                                    count: 2,
                                    endOffset: 4,
                                    startOffset: 0
                                },
                                {
                                    count: 1,
                                    endOffset: 3,
                                    startOffset: 1
                                }
                            ]
                        }
                    ],
                    moduleUrl: "/lib.js",
                    scriptId: "0"
                }
            ]
        });
    });
    jstestIt((
        "accepts arrays with two identical items for"
        + " `v8CoverageListMerge`"
    ), function () {
        assertJsonEqual(v8CoverageListMerge([
            {
                result: [
                    {
                        functions: JSON.parse(functionsInput),
                        scriptId: "123",
                        url: "/lib.js"
                    }, {
                        functions: JSON.parse(functionsInput),
                        scriptId: "123",
                        url: "/lib.js"
                    }
                ]
            }
        ]), {
            result: [
                {
                    functions: [
                        {
                            functionName: "test",
                            isBlockCoverage: true,
                            ranges: [
                                {
                                    count: 4,
                                    endOffset: 4,
                                    startOffset: 0
                                },
                                {
                                    count: 2,
                                    endOffset: 3,
                                    startOffset: 1
                                }
                            ]
                        }
                    ],
                    scriptId: "0",
                    url: "/lib.js"
                }
            ]
        });
    });
    [
        "test_coverage_merge_is_block_coverage_test.json",
        "test_coverage_merge_issue_2_mixed_is_block_coverage_test.json",
        "test_coverage_merge_node_10_internal_errors_one_of_test.json",
        "test_coverage_merge_reduced_test.json",
        "test_coverage_merge_simple_test.json",
        "test_coverage_merge_various_test.json"
    ].forEach(function (file) {
        jstestIt(file, function () {
            file = testCoverageMergeData[file];
            file.forEach(function ({
                expected,
                inputs
            }) {
                assertJsonEqual(v8CoverageListMerge(inputs), expected);
            });
        });
    });
    jstestIt((
        "merge multiple node-sqlite coverage files"
    ), function () {
        let data1 = [
            "test_v8_coverage_node_sqlite_9884_1633662346346_0.json",
            "test_v8_coverage_node_sqlite_13216_1633662333140_0.json"
        ].map(function (file) {
            return testCoverageMergeData[file];
        });
        let data2 = testCoverageMergeData[
            "test_v8_coverage_node_sqlite_merged.json"
        ];
        data1 = v8CoverageListMerge(data1);
        data1 = v8CoverageListMerge([data1]);

// Debug data1.
// await moduleFs.promises.writeFile(
//     ".test_v8_coverage_node_sqlite_merged.json",
//     JSON.stringify(objectDeepCopyWithKeysSorted(data1), undefined, 4) + "\n"
// );

        assertJsonEqual(data1, data2);
    });
});

jstestDescribe((
    "test v8CoverageReportCreate handling-behavior"
), function testBehaviorV8CoverageReportCreate() {
    jstestIt((
        "test null-case handling-behavior"
    ), async function () {
        await assertErrorThrownAsync(function () {
            return v8CoverageReportCreate({});
        }, "invalid coverageDir");
    });
    jstestIt((
        "test coverage-report jslint.mjs handling-behavior"
    ), async function () {
        // test remove-old-coverage handling-behavior
        await fsWriteFileWithParents(
            ".tmp/coverage_jslint/coverage-0-0-0.json",
            ""
        );
        await jslint.jslint_cli({
            console_error: noop, // comment to debug
            mode_cli: true,
            process_argv: [
                "node", "jslint.mjs",
                "v8_coverage_report=.tmp/coverage_jslint",
                "--exclude=aa.js",
                "--include-node-modules=1",
                "--include=jslint.mjs",
                "node", "jslint.mjs"
            ]
        });
    });
    [
        [
            "v8CoverageReportCreate_high.js", (
                "switch(0){\n"
                + "case 0:break;\n"
                + "}\n"
            )
        ], [
            "v8CoverageReportCreate_ignore.js", (
                "/*coverage-ignore-file*/\n"
                + "switch(0){\n"
                + "case 0:break;\n"
                + "}\n"
            )
        ], [
            "v8CoverageReportCreate_low.js", (
                "switch(0){\n"
                + "case 1:break;\n"
                + "case 2:break;\n"
                + "case 3:break;\n"
                + "case 4:break;\n"
                + "}\n"
            )
        ], [
            "v8CoverageReportCreate_medium.js", (
                "switch(0){\n"
                + "case 0:break;\n"
                + "case 1:break;\n"
                + "case 2:break;\n"
                + "}\n"
            )
        ]
    ].forEach(function ([
        file, data
    ], ii) {
        jstestIt(file, async function () {
            let dir = ".tmp/coverage_" + ii + "/";
            file = dir + file;
            await fsWriteFileWithParents(file, data);
            await jslint.jslint_cli({
                console_error: noop, // comment to debug
                mode_cli: true,
                process_argv: [
                    "node", "jslint.mjs",
                    "v8_coverage_report=" + dir,
                    "node",
                    file
                ]
            });
        });
    });
    jstestIt((
        "test npm handling-behavior"
    ), async function () {
        await jslint.jslint_cli({
            console_error: noop, // comment to debug
            mode_cli: true,
            process_argv: [
                "node", "jslint.mjs",
                "v8_coverage_report=.tmp/coverage_npm",
                "npm", "--version"
            ]
        });
    });
    jstestIt((
        "test misc handling-behavior"
    ), async function () {
        await Promise.all([
            [
                ".tmp/coverage_misc/aa.js", "\n".repeat(0x100)
            ], [
                ".tmp/coverage_misc/coverage-0-0-0.json", JSON.stringify({
                    "result": [
                        {
                            "functions": [
                                {
                                    "functionName": "",
                                    "isBlockCoverage": true,
                                    "ranges": [
                                        {
                                            "count": 1,
                                            "endOffset": 0xf0,
                                            "startOffset": 0x10
                                        },
                                        {
                                            "count": 1,
                                            "endOffset": 0x40,
                                            "startOffset": 0x20
                                        },
                                        {
                                            "count": 1,
                                            "endOffset": 0x80,
                                            "startOffset": 0x60
                                        },
                                        {
                                            "count": 0,
                                            "endOffset": 0x45,
                                            "startOffset": 0x25
                                        },
                                        {
                                            "count": 0,
                                            "endOffset": 0x85,
                                            "startOffset": 0x65
                                        }
                                    ]
                                }
                            ],
                            "scriptId": "0",
                            "url": "file:///" + modulePath.resolve(
                                ".tmp/coverage_misc/aa.js"
                            )
                        }
                    ]
                }, undefined, 4)
            ]
        ].map(async function ([
            file, data
        ]) {
            await fsWriteFileWithParents(file, data);
        }));
        await jslint.jslint_cli({
            console_error: noop, // comment to debug
            mode_cli: true,
            process_argv: [
                "node", "jslint.mjs",
                "v8_coverage_report=.tmp/coverage_misc"
                // "node", ".tmp/coverage_misc/aa.js"
            ]
        });
    });
});
