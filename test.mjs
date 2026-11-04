/*jslint beta, node*/
import jslint from "./jslint.mjs";
import jslintCjs from "./jslint_wrapper_cjs.cjs";
import moduleChildProcess from "child_process";
import moduleFs from "fs";
import modulePath from "path";
import moduleVm from "vm";

let {
    assertErrorThrownAsync,
    assertJsonEqual,
    assertOrThrow,
    debugInline,
    fsWriteFileWithParents,
    globExclude,
    jstestDescribe,
    jstestIt,
    moduleFsInit,
    noop,
    v8CoverageListMerge,
    v8CoverageReportCreate
} = jslint;
let sourceJslintMjs;
let testCoverageMergeData;

function assertMatch(text, rgx) {

// Assert <text> matches regexp <rgx>, showing <text> on failure.

    assertOrThrow(rgx.test(text), text);
}

function childRun(env, source, stdin) {

// Run <source> in a child node with jslint imported, fed <stdin>, and resolve
// its exit-code, stderr and stdout. Clear the parent's test filter, then apply
// <env>.

    return new Promise(function (resolve) {
        moduleChildProcess.execFile(process.execPath, [
            "--input-type=module",
            "--eval",
            "import jslint from \"./jslint.mjs\";\n" + source
        ], {
            env: {
                ...process.env,
                npm_config_mode_test_filter: "",
                ...env
            },

// Kill a hung child, so a broken runner fails this suite instead of hanging it.
// A killed child resolves exit-code null, never a passing 0.

            timeout: 10000
        }, function (err, stdout, stderr) {
            resolve([(
                err
                ? err.code
                : 0
            ), stderr, stdout]);
        }).stdin.end(stdin);
    });
}

await (async function init() {

// Coverage-hack - Ugly-hack to get test-coverage for all initialization-states.

    moduleFsInit();
    moduleFsInit();

// A runner that ended every async test before it ran would also pass the tests
// that check it, so check one async failure here, outside any jstestIt.

    await childRun({}, String(`
jslint.jstestDescribe("aa", function () {
    jslint.jstestIt("bb", async function () {
        await null;
        throw new Error("bb late");
    });
});
    `)).then(function ([exitCode, stderr]) {

// Reported as a failed test, not merely a crash, which also exits 1.

        assertOrThrow(
            exitCode === 1 && (
                / 1\. test it - bb\nError: bb late\n/
            ).test(stderr),
            "jstest passed an async test that failed\n" + stderr
        );
    });

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

function processExit0(exitCode) {
    assertOrThrow(exitCode === 0, exitCode);
}

function processExit1(exitCode) {
    assertOrThrow(exitCode === 1, exitCode);
}

jstestDescribe((
    "test assertXxx handling-behavior"
), function () {
    jstestIt((
        "test assertXxx-error handling-behavior"
    ), async function () {
        // Keep <debugInline> imported, for debugging tests.
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
    "test fsXxx handling-behavior"
), function () {
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
), function () {
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
                "Weird character " +
                JSON.stringify(char).replace((/\\/g), "\\\\") +
                " found in "
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
    "test jslint's autofix handling-behavior"
), function () {
    jstestIt((
        "test autofix-api handling-behavior"
    ), function () {
        let result;
        let source;

// This function will autofix <source_api> through the API - no fs, no cli -
// and assert <autofixed> became <expect_api>. Option node is harmless to
// every fixture here, so one option-object serves them all.

        function assertAutofix(expect_api, source_api) {
            let result_api = jslint.jslint(source_api, {
                autofix: true,
                node: true
            });
            assertOrThrow(
                result_api.autofixed === expect_api,
                JSON.stringify([
                    source_api, result_api.autofixed
                ])
            );
            return result_api;
        }

// Option autofix makes jslint() a PURE fixer. <warnings> and <ok> then
// describe <autofixed>, so a repairable source comes back ok.

        source = (
            "function aa(bb) {\n    return String( bb)+bb;\n}\n" +
            "export default Object.freeze(aa);\n"
        );
        result = assertAutofix((
            "function aa(bb) {\n    return String(bb) + bb;\n}\n" +
            "export default Object.freeze(aa);\n"
        ), source);
        assertOrThrow(result.ok, JSON.stringify(result.warnings));

// Without the option, <autofixed> is undefined and the warnings are the
// source's own.

        result = jslint.jslint(source, {});
        assertOrThrow(result.autofixed === undefined, result.autofixed);
        assertOrThrow(!result.ok, "expected warnings");

// A warning autofix cannot fix BLOCKS the first pass, so there is nothing to
// write and <autofixed> stays undefined.

        result = assertAutofix(undefined, (
            "function aa(bb) {\n    let cc = 0;\n    return String( bb);\n}\n"
        ));
        assertOrThrow(!result.ok, "expected warnings");

// Under beta, expected_a_at_end moves a line-leading operator to just after
// its left operand - past a template's `// x` line, before a trailing
// comment - and an operator alone on its line takes the line with it.

        result = jslint.jslint((
            "const aa = [\n    `\n// x`\n    + 1 // c\n    +\n    2\n];\n" +
            "export default Object.freeze(aa);\n"
        ), {
            autofix: true,
            beta: true
        });
        assertOrThrow(result.autofixed === (
            "const aa = [\n    `\n// x` +\n    1 + // c\n    2\n];\n" +
            "export default Object.freeze(aa);\n"
        ), result.autofixed);

// A tagged template's backtick is NOT an operator to move - moving it would
// put the line break inside the template and change its value.

        source = (
            "function aa() {\n    return String.raw\n    `x${0}`;\n}\n" +
            "export default Object.freeze(aa);\n"
        );
        result = jslint.jslint(source, {
            autofix: true,
            beta: true
        });
        assertOrThrow(
            result.autofixed === undefined && result.ok,
            JSON.stringify([result.autofixed, result.warnings])
        );

// THE FIXER'S LINE MODEL MUST BE THE LINTER'S (jslint_rgx_crlf). A CRLF file
// must come back CRLF - line_list carries NO terminators and the rejoin uses
// the file's OWN first one - and a lone \r, which the linter counts as a line
// break, must not shift every later fix onto the wrong line. Both were real:
// the second deleted spaces from a comment while the warned line stayed
// untouched. A MIXED file is NORMALIZED to that first terminator, which is
// what the second case pins: the fix lands on the right line, the comment is
// untouched, and every \n comes back \r.

        assertAutofix((
            "function aa(bb) {\r\n    if (bb) {\r\n        return bb;\r\n" +
            "    }\r\n    return 0;\r\n}\r\naa();\r\n"
        ), (
            "function aa(bb) {\r\n    if (bb) { return bb; }\r\n" +
            "    return 0;\r\n}\r\naa();\r\n"
        ));
        assertAutofix((
            "function bb(cc) {\r    cc();\r    return String(cc);\r" +
            "    // xx              yy\r}\rbb();\r"
        ), (
            "function bb(cc) {\r    cc();\n    return String( cc);\n" +
            "    // xx              yy\n}\nbb();\n"
        ));

// A WARNING-FREE source is returned UNTOUCHED, never rejoined - otherwise a
// clean mixed-terminator file would come back normalized and get written.

        result = assertAutofix(undefined, (
            "function cc(dd) {\r\n    dd();\r    return 0;\n}\ncc();\n"
        ));
        assertOrThrow(result.ok, JSON.stringify(result.warnings));

// AN EMPTY source is the one input whose rejoin is the EMPTY STRING, which
// the call site's <|| state.source> would read as "nothing happened". It is
// harmless ONLY because state.source is empty too, so the two agree - but a
// non-empty source can never rejoin to "", because a warning implies a token
// implies a non-empty line. Whitespace-only sources are blocked instead:
// unexpected_trailing_space and use_spaces are not in the fixable set.

        [
            "", "\n", "\n\n", " ", "    ", "  \n  ", "\t"
        ].forEach(function (source_degenerate) {
            assertAutofix(undefined, source_degenerate);
        });

// A STOP in a later pass can only be the fixer's own doing - pass 0 parsed to
// the end - so the fix is DISCARDED, never written. test_internal_error throws
// AFTER phase 6, so pass 0 fixes, pass 1 stops on it, and <autofixed> must come
// back undefined instead of carrying pass 0's text.

        result = jslint.jslint("String( 0);\n", {
            autofix: true,
            test_internal_error: true
        });
        assertOrThrow(
            result.stop && result.autofixed === undefined,
            JSON.stringify([result.stop, result.autofixed])
        );

// And the discard is NAMED in this pass's own warnings, so a fixer defect
// cannot pass for an ordinary blocked file. This is also what separates
// "guard fired" from "no fix was ever attempted" - both leave <autofixed>
// undefined.

        assertOrThrow(
            result.warnings.some(function ({
                message
            }) {
                return message.startsWith("[autofix discarded");
            }),
            JSON.stringify(result.warnings.map(function ({
                message
            }) {
                return message;
            }))
        );

// A ONE-LINE source carries NO terminator at all, so jslint_rgx_crlf.exec()
// returns null and the rejoin falls back to '\n' - which is also appended,
// since the fixed code is missing a trailing one.

        result = assertAutofix((
            "function aa(bb) {\n    return bb;\n}\naa();\n"
        ), "function aa(bb) { return bb; } aa();");
        assertOrThrow(result.ok, JSON.stringify(result.warnings));

// The appended terminator is the file's own, here '\r\n'.

        assertAutofix((
            "function aa(bb) {\r\n    return bb;\r\n}\r\naa();\r\n"
        ), "function aa(bb) { return bb; }\r\naa();");

// A used label warns only its placement, so a mid-line label reaches phase 6,
// which splits it onto its own line at column 1.

        assertAutofix(
            String(`
function aa(bb) {
    bb();
cc:
    while (bb) {
        if (bb()) {
            break cc;
        }
        bb();
    }
}
aa();
            `).trim() + "\n",
            String(`
function aa(bb) {
    bb(); cc: while (bb) {
        if (bb()) {
            break cc;
        }
        bb();
    }
}
aa();
            `).trim() + "\n"
        );

// A whitespace-run reaching column 0 is INDENTATION or a line-join, not a gap
// between two tokens on one line, so the fix is DECLINED and the warning is
// reported against a byte-identical file. Here the run is the whole indent of
// a continuation line, which is why the warned column is 9 and not 1.

        result = assertAutofix(undefined, (
            "function aa(bb) {\n    return aa\n        (bb);\n}\naa();\n"
        ));
        assertOrThrow(
            result.warnings.length === 1 &&
            result.warnings[0].code === "unexpected_space_a_b" &&
            result.warnings[0].line === 3 &&
            result.warnings[0].column === 9,
            JSON.stringify(result.warnings)
        );

// A too_long ALREADY in the source does not block autofix - the fix is made,
// and too_long is still reported.

        result = assertAutofix(
            String(`
function aa(bb) {
    return bb;
}
aa("${"a".repeat(80)}");
            `).trim() + "\n",
            String(`
function aa(bb) { return bb; }
aa("${"a".repeat(80)}");
            `).trim() + "\n"
        );
        assertOrThrow(
            result.warnings.length === 1 &&
            result.warnings[0].code === "too_long",
            JSON.stringify(result.warnings)
        );
    });
    jstestIt((
        "test autofix-cli handling-behavior"
    ), async function () {
        let source;

// This function will autofix <name> in .tmp and assert it became <expect>.
// <exit> is processExit1 exactly when a residual warning remains - autofix
// exits nonzero like a plain lint, so `jslint_autofix=x.js && deploy` cannot
// succeed on a file it failed to repair.

        async function autofixFile({
            exit = processExit0,
            expect,
            name,
            process_env,
            source
        }) {
            let file = ".tmp/" + name;
            await fsWriteFileWithParents(file, source);
            await jslint.jslint_cli({
                // suppress error
                console_error: noop,
                mode_cli: true,
                process_argv: [
                    "node",
                    "jslint.mjs",
                    "jslint_autofix=" + file
                ],
                process_env,
                process_exit: exit
            });
            assertOrThrow(
                expect === await moduleFs.promises.readFile(file, "utf8"),
                file
            );
        }

// Whitespace-only warnings - autofix repairs them and the file lints clean.

        await autofixFile({
            expect: (
                "function aa(bb) {\n    return String(bb) + bb;\n}\n" +
                "export default Object.freeze(aa);\n"
            ),
            name: "autofix.mjs",
            source: (
                "function aa(bb) {\n    return String( bb)+bb;\n}\n" +
                "export default Object.freeze(aa);\n"
            )
        });

// A non-whitespace warning blocks phase-5, so the file is REPORTED and left
// BYTE-IDENTICAL.

        source = (
            "function aa(bb) {\n    let cc = 0;\n" +
            "    return String( bb);\n}\n"
        );
        await autofixFile({
            exit: processExit1,
            expect: source,
            name: "autofix_blocked.mjs",
            source
        });

// Indentation is re-indented to the expected column, cascading across passes.

        await autofixFile({
            expect: (
                "function aa(bb) {\n    if (bb) {\n        return bb;\n" +
                "    }\n    return 0;\n}\nexport default Object.freeze(aa);\n"
            ),
            name: "autofix_indent.mjs",
            source: (
                "function aa(bb) {\n        if (bb) {\n  return bb;\n" +
                "        }\n    return 0;\n}\n" +
                "export default Object.freeze(aa);\n"
            )
        });

// A SINGLE-LINE TERNARY WARNS ONLY expected_a_at_b_c, yet what it actually
// wants is a line break before ? and before :. Autofix still gets there,
// because a column-warning on a MID-LINE token means that token belongs on
// its own line - so the break falls out of the column-fix. This is the case
// that justifies the mid-line branch; without it the fixer would skip these
// and never converge.

        await autofixFile({
            expect: (
                "function aa(bb) {\n    return (\n        bb\n        ? 0\n" +
                "        : 1\n    );\n}\nexport default Object.freeze(aa);\n"
            ),
            name: "autofix_ternary.mjs",
            source: (
                "function aa(bb) {\n    return (\n        bb ? 0 : 1\n" +
                "    );\n}\nexport default Object.freeze(aa);\n"
            )
        });

// An UNPARENTHESISED ternary warns something else entirely, which is not in
// fix_list, so the file must come back byte-identical.

        source = (
            "function aa(bb) {\n    return (bb ? 0 : 1);\n}\n" +
            "export default Object.freeze(aa);\n"
        );
        await autofixFile({
            exit: processExit1,
            expect: source,
            name: "autofix_ternary2.mjs",
            source
        });

// A CLOSED-FORM statement block - opener and body on ONE line - needs BOTH
// kinds of fix, in separate passes, because a statement block is always open
// form (jslint_phase5_whitage). First a line-break, then column-fixes for the
// body and the closer the split leaves misplaced. Assert both kinds appear,
// so a regression that drops either one cannot hide behind the end-to-end
// test below.

        assertOrThrow(
            jslint.jslint(
                "function aa(bb) {\n    if (bb) { return bb; }\n" +
                "    return 0;\n}\nexport default Object.freeze(aa);\n"
            ).warnings.some(function ({
                code
            }) {
                return code === "expected_line_break_a_b";
            }),
            "closed-form block must warn expected_line_break_a_b"
        );
        assertOrThrow(
            jslint.jslint(
                "function aa(bb) {\n    if (bb) {\nreturn bb;}\n" +
                "    return 0;\n}\nexport default Object.freeze(aa);\n"
            ).warnings.filter(function ({
                code
            }) {
                return code === "expected_a_at_b_c";
            }).length === 2,
            "the split leaves body AND closer needing a column-fix"
        );

// A one-liner block is split, re-indented and its closer moved, across
// passes. The trailing comment must survive, attached to the closer.

        await autofixFile({
            expect: (
                "function aa(bb) {\n    if (bb) {\n        return bb;\n" +
                "    } // keep me\n    return 0;\n}\n" +
                "export default Object.freeze(aa);\n"
            ),
            name: "autofix_break.mjs",
            source: (
                "function aa(bb) {\n    if (bb) { return bb; } // keep me\n" +
                "    return 0;\n}\nexport default Object.freeze(aa);\n"
            )
        });

// A *.sh file is not javascript: only its `node --eval` blocks are fixed,
// and the surrounding shell must come back byte-identical.

        await autofixFile({
            expect: (
                "shAa() {\n    node --eval '\nconsole.log(\n    0 +\n    0\n" +
                ");\n'\n}\n"
            ),
            name: "autofix_embedded.sh",
            process_env: {
                JSLINT_BETA: "1"
            },
            source: (
                "shAa() {\n    node --eval '\nconsole.log(\n    0\n  + 0\n" +
                ");\n'\n}\n"
            )
        });

// An embedded block with a too_long ALREADY in it is still fixed, and the
// residual too_long still exits nonzero.

        source = String(`
shAa() {
    node --eval '
console.log("${"a".repeat(80)}");
console.log( 0);
'
}
        `).trim() + "\n";
        await autofixFile({
            exit: processExit1,
            expect: source.replace("( 0)", "(0)"),
            name: "autofix_embedded_long.sh",
            source
        });

// A too_long that a fix SURFACES keeps the fix and blocks none after it. The
// join makes line 3 82 columns, and the closed-form block below still needs
// two more passes - its split, then its re-indent.

        source = String(`
/*jslint beta*/
function aa(bb, cc) {
    return bb.${"a".repeat(66)}
    + cc;
}
function dd(ee) { return ee; }
aa(dd(0), 0);
        `).trim() + "\n";
        await autofixFile({
            exit: processExit1,
            expect: source.replace(
                "\n    + cc;",
                " +\n    cc;"
            ).replace(
                "{ return ee; }",
                "{\n    return ee;\n}"
            ),
            name: "autofix_long_join.mjs",
            source
        });

// An *.html file is fixed the same way, but through its <script> blocks and
// with browser:true - mirroring how jslint_from_file lints them.

        await autofixFile({
            expect: (
                "<body>\n<script>\n/*jslint browser*/\nwindow.console.log(\n" +
                "    0\n    + 0\n);\n</script>\n</body>\n"
            ),
            name: "autofix_embedded.html",
            source: (
                "<body>\n<script>\n/*jslint browser*/\nwindow.console.log(\n" +
                "    0\n  + 0\n);\n</script>\n</body>\n"
            )
        });

// A *.md file is linted with mode_conditional, i.e. only blocks carrying a
// /*jslint directive. Autofix inherits that from jslint_from_file, so the
// FIRST block below is repaired and the SECOND is left byte-identical.

        await autofixFile({
            expect: (
                "# aa\n\nnode --eval '\n/*jslint node*/\nconsole.log(\n" +
                "    0 +\n    0\n);\n'\n\nnode --eval '\nconsole.log(\n" +
                "    0\n  + 0\n);\n'\n"
            ),
            name: "autofix_embedded.md",
            process_env: {
                JSLINT_BETA: "1"
            },
            source: (
                "# aa\n\nnode --eval '\n/*jslint node*/\nconsole.log(\n" +
                "    0\n  + 0\n);\n'\n\nnode --eval '\nconsole.log(\n" +
                "    0\n  + 0\n);\n'\n"
            )
        });

// A CRLF or CR container is fixed the same way, and its line terminators
// survive, inside the embedded block too.

        await autofixFile({
            expect: String(
                "shAa() {\n    node --eval '\nconsole.log(\n    0 +\n    0\n" +
                ");\n'\n}\n"
            ).replace((/\n/g), "\r\n"),
            name: "autofix_embedded_crlf.sh",
            process_env: {
                JSLINT_BETA: "1"
            },
            source: String(
                "shAa() {\n    node --eval '\nconsole.log(\n    0\n  + 0\n" +
                ");\n'\n}\n"
            ).replace((/\n/g), "\r\n")
        });
        await autofixFile({
            expect: String(
                "<body>\n<script>\n/*jslint browser*/\nwindow.console.log(\n" +
                "    0\n    + 0\n);\n</script>\n</body>\n"
            ).replace((/\n/g), "\r"),
            name: "autofix_embedded_cr.html",
            source: String(
                "<body>\n<script>\n/*jslint browser*/\nwindow.console.log(\n" +
                "    0\n  + 0\n);\n</script>\n</body>\n"
            ).replace((/\n/g), "\r")
        });

// A missing file exits 1 with the error printed, like a plain lint - not an
// unhandled rejection that never reaches process_exit.

        await jslint.jslint_cli({
            // suppress error
            console_error: noop,
            mode_cli: true,
            process_argv: [
                "node",
                "jslint.mjs",
                "jslint_autofix=.tmp/autofix_missing.mjs"
            ],
            process_exit: processExit1
        });

// A DIRECTORY rides the same walk as a plain lint of one, and every file whose
// lint returns <autofixed> is written back; a clean file is left alone.

        await fsWriteFileWithParents(
            ".tmp/autofix_dir/aa.mjs",
            "String( 0);\n"
        );
        await fsWriteFileWithParents(
            ".tmp/autofix_dir/bb.mjs",
            "String(0);\n"
        );
        await jslint.jslint_cli({
            // suppress error
            console_error: noop,
            mode_cli: true,
            process_argv: [
                "node",
                "jslint.mjs",
                "jslint_autofix=.tmp/autofix_dir"
            ],
            process_exit: processExit0
        });
        assertOrThrow(
            (
                await moduleFs.promises.readFile(
                    ".tmp/autofix_dir/aa.mjs",
                    "utf8"
                )
            ) === "String(0);\n",
            ".tmp/autofix_dir/aa.mjs"
        );
        assertOrThrow(
            (
                await moduleFs.promises.readFile(
                    ".tmp/autofix_dir/bb.mjs",
                    "utf8"
                )
            ) === "String(0);\n",
            ".tmp/autofix_dir/bb.mjs"
        );
    });
});

jstestDescribe((
    "test jslint's cli handling-behavior"
), function () {
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
        "test cli-cjs-lint-file handling-behavior"
    ), async function () {

// Through the cjs wrapper, <jslint_cli> must lint, not resolve 0 unseen: in
// its old new-context sandbox there was no process, so the cli returned early.

        await fsWriteFileWithParents(
            ".tmp/cli_cjs_lint_file/aa.js",
            "let aa = 1;\n"
        );
        assertJsonEqual(
            await jslintCjs.jslint_cli({
                console_error: noop,
                mode_cli: true,
                process_argv: [
                    "node",
                    "jslint.mjs",
                    ".tmp/cli_cjs_lint_file/aa.js"
                ],
                process_exit: processExit1
            }),
            1
        );
    });
    jstestIt((
        "test cli-embedded-line-offset handling-behavior"
    ), async function () {

// An embedded block whose opening tag is LINE 1 of its container has no line
// terminator before it, so the offset arithmetic must still yield 1 - a
// precedence slip once made it 0, and every warning in the block reported one
// line too high. <foo> sits on file-line 3 and must be reported there.

        const stderr_list = [];
        await fsWriteFileWithParents(
            ".tmp/embedded_line1.html",
            "<script>\n/*jslint browser*/\nfoo;\n</script>\n"
        );
        await jslint.jslint_cli({
            console_error: function (msg) {
                stderr_list.push(String(msg));
            },
            mode_cli: true,
            process_argv: [
                "node",
                "jslint.mjs",
                ".tmp/embedded_line1.html"
            ],
            process_exit: processExit1
        });
        assertOrThrow(
            stderr_list.some(function (msg) {
                return msg.includes("line 3, column 1");
            }),
            JSON.stringify(stderr_list)
        );
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
        "test cli-file-kinds handling-behavior"
    ), async function () {
        await moduleFs.promises.mkdir(
            ".tmp/invalid_file/invalid_file.js",
            {recursive: true}
        );
        [
            ".",                // test dir handling-behavior
            ".tmp/invalid_file",// test invalid-file handling-behavior
            "jslint.mjs",       // test file handling-behavior
            undefined           // test file-undefined handling-behavior
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
    jstestIt((
        "test cli-null-case handling-behavior"
    ), function () {
        jslint.jslint_cli({
            mode_noop: true,
            process_exit: processExit0
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
        "test cli-report-embedded handling-behavior"
    ), async function () {

// A container-file returns no single lint-result, so jslint_report refuses it
// with exit 1 instead of crashing on the missing <warnings>.

        await fsWriteFileWithParents(".tmp/jslint_report.md", "# aa\n");
        await jslint.jslint_cli({
            // suppress error
            console_error: noop,
            mode_cli: true,
            process_argv: [
                "node",
                "jslint.mjs",
                "jslint_report=.tmp/jslint_report_embedded.html",
                ".tmp/jslint_report.md"
            ],
            process_exit: processExit1
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
            source: "String();"
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
});

jstestDescribe((
    "test jslint's no-warnings handling-behavior"
), function () {
    jstestIt((
        "test jslint's no-warnings handling-behavior"
    ), function () {
        Object.values({
            array: [
                "new Array(0);"
            ],
            async_await: [
                (`
/*jslint fart*/
let aa = 0;
aa = async () => {
    try {
        return await aa();
    } catch (err) {
        await err();
    }
};
await aa();
                `),
                "async function aa() {\n    await aa();\n}\nawait aa();",

// PR-405 - Bugfix - fix expression after "await" mis-identified as statement.

                "async function aa() {\n    await aa;\n}\nawait aa();",
                (`
async function aa() {
    try {
        return await aa();
    } catch (err) {
        await err();
    }
}
await aa();
                `)
            ],

// PR-351 - Add BigInt support.

            bigint: [
                (`
String(0b0n);
String(0o0n);
String(0x0n);
String(BigInt(0n));
String(typeof String === "bigint");
                `)
            ],
            date: [
                (`
Date.getTime();
String().getTime();
String.aa().getTime();
                `)
            ],
            destructure: [

// PR-500 - Unify ES2015-destructure-logic.

                [
                    (`
(function ({expr}) {
    aa(bb, cc, dd, ee, ff, gg);
}());
                    `),
                    (`
(function for_loop() {
    for (const {expr} of for_loop) {
        aa(bb, cc, dd, ee, ff, gg);
    }
}());
                    `),
                    (`
/*jslint fart*/
(({expr}) => {
    aa(bb, cc, dd, ee, ff, gg);
}());
                    `),
                    "const {expr}",
                    "let {expr}",
                    "let [aa, bb, cc, dd, ee, ff, gg] = 0;\n{expr}"
                ].map(function (source) {
                    let expr = String(`
[
    {
        cc,
        dd = 0,
        dd: ee,
        ee: [{bb}],
        ...aa
    },
    [
        gg,
        ...ff
    ]
]
                    `).trim();
                    if ((/function for_loop/).test(source)) {
                        expr = expr.replace((/\n/g), "\n    ");
                    }
                    source = source.trim().replace("{expr}", expr);
                    if (!(/\=>|function/).test(source)) {
                        source = (`
${source} = (function () {
    return;
}());
aa(bb, cc, dd, ee, ff, gg);
                        `);
                    }
                    return source;
                }),

// PR-459 - Allow destructuring-assignment after function-definition.

                (`
let aa;
let bb;
function cc() {
    return;
}
[aa, bb] = cc();
aa(bb, cc);
                `),

// PR-514 - Bugfix - Walk a default in destructuring-assignment, so 'cc' is
// used.

                (`
let aa;
let cc = 0;
[
    [
        aa = cc
    ]
] = [];
aa();
                `)
            ],
            directive: [
                (`
#!/usr/bin/env node
/*global aa*/
/*jslint browser:false, node*/
/*property bb*/
"use strict";
aa.bb();
                `)
            ],
            ellipsis: [

// PR-483 - Allow parenthesis after ellipsis inside a function call.

                (`
String(0, ...(
    String()
    ? 0
    : 1
));
                `),

// Issue #401 - Add ES2018-syntax for object-literal-spread-operator.

                (`
let aa;
aa = [
    0,
    ...aa(),
    0,
    ...aa,
    0,
    ...aa.aa,
    0
];
aa = {
    aa: 0,
    ...aa(),
    bb: 0,
    ...aa,
    cc: 0,
    ...aa.aa,
    dd: 0
};
aa();
                `)
            ],
            fart: [
                (`
/*jslint fart*/
let aa = async (bb, [cc, dd], {ee, ff}, ...gg) => {
    await bb(cc, dd, ee, ff, gg);
};
aa();
                `),
                "let aa = () => 0;\naa();"
            ],
            for: [
                (`
async function aa(bb, cc) {
    for (; bb < 0; bb += 1) { //jslint-ignore-line
        bb(cc);
    }
    for (bb = 0; bb < 0; bb += 1) { //jslint-ignore-line
        bb(cc);
    }
    for (cc in bb) { //jslint-ignore-line
        bb(cc);
    }
    for (cc of bb) { //jslint-ignore-line
        cc();
    }
    for (const ii in bb) { //jslint-ignore-line
        bb(cc, ii);
    }
    for (const ii of bb) {
        bb(cc, ii);
    }
    for (let ii = 0; ii < 0; ii += 1) {
        bb(cc, ii);
    }
    for (let ii of bb) {
        bb(cc, ii);
    }
    for await (const ii of bb) {
        bb(cc, ii);
    }
    for await (let ii of bb) {
        bb(cc, ii);
    }
    for (const ii of await (bb())) {
        bb(cc, ii);
    }
}
aa();
                `),

// PR-514 - Bugfix - Walk the iterable of destructured for..of.

                (`
function aa(bb) {
    for (const [cc, dd] of bb) {
        cc(dd);
    }
    for (const {ee} of bb) {
        ee();
    }
}
aa();
                `),

// PR-514 - Bugfix - A ';' in a method-body inside a for-loop-head is not a
// for-loop-semicolon.

                (`
function aa(bb) {
    for (const cc in { //jslint-ignore-line
        dd() {
            return;
        }
    }) {
        bb(cc);
    }
}
aa();
                `),

// PR-514 - Bugfix - The '}' of a '${' does not pop the '{' of a function-body
// in a for-loop-head, since '${' is pushed too.

                (`
function aa(bb) {
    for (const cc of function () {
        return \`\${bb}\`;
    }()) { //jslint-ignore-line
        bb(cc);
    }
}
aa();
                `)
            ],
            import: [
                `let aa = 0;\nimport(aa).then(aa).catch(aa).finally(aa);`,
                `let aa = await import("aa");\naa();`,
                `let aa = await import("aa", {with: {type: "json"}});\naa();`,
                `let {aa, bb} = await import("aa");\naa(bb);`
            ],
            indent_method: [
                (`
String
    .aa
    .aa()
    .aa(0)
    .aa(
        0,
        [0],
        \`${0}\`
    )
    .aa(
        String
            .aa()
            .aa(0)
            .aa(
                0,
                [0],
                \`${0}\`
            )
    )
    .aa(function ({
        aa
    }) {
        return aa;
    });
                `)
            ],
            jslint_disable: [
                "/*jslint-disable*/\n0\n/*jslint-enable*/"
            ],
            jslint_ignore_line: [
                "0 //jslint-ignore-line",
                "new aa //jslint-ignore-line"
            ],
            json: [
                "{\"aa\":[[],-0,null]}"
            ],
            label: [
                (`
function aa() {
bb: do {
        if (true) {
            break bb;
        }
    } while (true);
}
aa();
                `),
                (`
function aa() {
bb: for (const ii of aa) {
        if (ii) {
            break bb;
        }
    }
}
aa();
                `),
                (`
function aa() {
bb: for (let ii = 0; ii < 0; ii += 1) {
        if (ii) {
            break bb;
        }
    }
}
aa();
                `),
                (`
function aa() {
bb: switch (aa) {
    case 0:
        break bb;
    }
}
aa();
                `),
                (`
function aa() {
bb: while (true) {
        if (true) {
            break bb;
        }
    }
}
aa();
                `)
            ],
            literal: [
                "String(\"\".at());",
                "String(\"\\u{000041}\");",
                "String(\"\\u{10FFFF}\");",
                "String(String.raw`\\u{110000}${0}\\u0`);",
                "String([].at());",
                "String(`\\u{000041}`);",
                "String(`\\u{10FFFF}`);"
            ],
            logical_assignment: [

// PR-514 - Bugfix - '??=' and '||=' assign an unassigned variable.

                (`
function aa(bb) {
    let cc;
    cc ??= bb;
    return cc;
}
aa();
                `),
                (`
function aa(bb) {
    let cc;
    cc ||= bb;
    return cc;
}
aa();
                `),
                "let aa = 0;\naa &&= 0;",
                "let aa = 0;\naa ??= 0;",
                "let aa = 0;\naa ||= 0;"
            ],
            loop: [
                (`
function aa() {
    do {
        aa();
    } while (aa());
}
aa();
                `),

// PR-378 - Relax warning "function_in_loop".

                (`
function aa() {
    while (true) {
        (function () {
            return;
        }());
    }
}
aa();
                `)
            ],
            module: [
                "export default Object.freeze();",

// PR-439 - Add grammar for "export async function ...".

                (`
export default Object.freeze(async function () {
    return await 0;
});
                `),
                // `import "aa";`,
                `import * as aa from "aa";\naa();`,
                `import aa from "aa" with {type: "json"};\naa();`,
                `import aa from "aa";\naa();`,
                `import aa, {aa as bb, cc} from "aa";\naa(bb, cc);`,
                `import {} from "aa";`
            ],
            new: [
                "new String`aa`();"
            ],
            number: [
                "String(0.0e0);",
                "String(0b0);",
                "String(0o0);",
                "String(0x0);"
            ],

// PR-390 - Add numeric-separator support.

            numeric_separator: [
                "String(0.0_0_0);",
                "String(0b0_1111_1111n);",
                "String(0o0_1237_1237n);",
                "String(0x0_123f_123fn);",
                "String(1_234_234.1_234_234E1_234_234);"
            ],
            optional_chaining: [
                "String().aa?.bb?.cc();",
                "delete String?.[0];",
                "delete String?.aa;"
            ],
            param: [
                "function aa({aa, bb}) {\n    return {aa, bb};\n}\naa();",
                (`
function aa({constructor}) {
    return {constructor};
}
aa();
                `)
            ],
            property: [
                "String[`!`]();"
            ],
            regexp: [
                `RegExp.escape("");`,
                `String(/(?!.)(?:.)(?=.)/);`,
                `String(/(?im-s:.)/);`,
                `String(/./dgimsuy);`,
                `String(/./dgimsvy);`,
                `String(/[\\--\\-]/);`,
                `function aa() {\n    return /./;\n}\naa();`
            ],
            scope: [
                "(function aa(bb = aa) {\n    aa(bb);\n}());",

// PR-514 - Bugfix - A 'var' named after its named function expression is a new
// writable binding, so assigning it does not warn bad_assignment_a.

                (`
String(function aa() {
    var aa = 0; //jslint-ignore-line
    aa = 1;
    return aa;
});
                `),

// PR-514 - A parameter named after its named function expression shadows the
// name, like any parameter shadowing an outer name, so it does not warn.

                "String(function aa(aa) {\n    return aa;\n});",

// PR-514 - Bugfix - A 'var' redeclared in a nested block keeps the first one,
// so a use between the two does not warn temporal_dead_zone_a.

                (`
function aa() {
    var bb = 0;
    bb();
    if (aa) {
        var bb = 1; //jslint-ignore-line
        bb();
    }
}
aa();
                `),
                "function aa(bb = aa) {\n    aa(bb);\n}\naa();",
                (`
function bb(cc) {
    return cc;
}
bb(function aa() {
    return;
});
                `),
                (`
if (String) {
    let aa = 0;
    aa();
} else {
    let aa = 0;
    aa();
}
                `),
                (`
if (String) {
    var aa = 0; //jslint-ignore-line
}
aa();
                `)
            ],
            ternary: [
                (`
String(
    String()
    ? 0
    : 1
);
String(
    String()
    ? \`$\{0}\`
    : \`$\{1}\`
);

// PR-394 - Bugfix
// Fix jslint falsely believing megastring literals \`0\` and \`1\` are similar.

String(
    String()
    ? \`0\`
    : \`1\`
);

// PR-510 - Bugfix - Fix jslint treating tagged templates as equal.

String(
    String()
    ? String\`$\{0}$\{0}\`
    : String\`$\{0}$\{1}\`
);
                `)
            ],
            try_catch_finally: [
                (`
try {
    String();
} catch (err) {
    err();
} finally {
    String();
}
                `),
                (`
try {
    String();
} catch (err) {
    var aa = err; //jslint-ignore-line
} finally {
    String(aa);
}
                `)
            ],
            use_strict: [
                (`
"use strict";
function aa() {
    "use strict";
    return;
}
aa();
                `)
            ],
            var: [
                "const aa = 0;\naa();\n",
                "let aa = 0;\naa();\n",
                "var aa = 0;\naa();\n"
            ]
        }).forEach(function (codeList) {
            let elemPrv = "";
            codeList.flat().flat().forEach(function (source) {
                let warnings;
                source = source.trim();
                // Assert codeList is sorted.
                assertOrThrow(elemPrv < source, JSON.stringify([
                    elemPrv, source
                ], undefined, 4));
                elemPrv = source;
                [
                    jslint.jslint,
                    jslintCjs.jslint
                ].forEach(function (jslint) {
                    warnings = jslint(source, {
                        beta: true
                    }).warnings;
                    assertOrThrow(
                        warnings.length === 0,
                        `\n\n${source}\n\n${JSON.stringify(
                            warnings,
                            undefined,
                            4
                        )}`
                    );
                });
            });
        });
    });
});

jstestDescribe((
    "test jslint's option handling-behavior"
), function () {

// Samples group by option, so each option is one test with a unique name.

    const sampleDict = Object.groupBy([
        [{bitwise: true}, "String(String | 0);"],
        [{browser: true}, ";\nString(new XMLHttpRequest());"],
        [{convert: true}, "String(\"aa\" + 0);"],
        [{couch: true}, "registerType();"],
        [{devel: true}, "debugger;"],

// PR-404 - Alias "evil" to jslint-directive "eval" for backwards-compat.

        [{eval: true, evil: true}, "new Function();\neval();"],

// PR-514 - Bugfix - A string-key named get aa does not duplicate an accessor.

        [{getset: true}, String(`
String({
    get aa() {
        return;
    },
    "get aa": 0
});
        `).trim()],
        [{getset: true}, "String({get aa() {\n    return;\n}});"],
        [{getset: true}, "String({set aa(aa) {\n    return aa;\n}});"],
        [{indent2: true}, sourceJslintMjs.replace((/    /g), "  ")],
        [{indent2: true}, "function aa() {\n  return;\n}\naa();"],
        [{long: true}, "/".repeat(100)],

// PR-404 - Alias "nomen" to jslint-directive "name" for backwards-compat.

        [{name: true, nomen: true}, "let aa = 0;\naa._();"],
        [{node: true}, "require();"],
        [{single: true}, "String('aa');"],

// PR-404 - Add new directive "subscript" to play nice with Google Closure.

        [{subscript: true}, "String[\"aa\"]();"],
        [{test_internal_error: true}, ""],
        [{test_unknown_warning_code: true}, ""],
        [{this: true}, "String(this);"],
        [{trace: true}, ""],
        [{unordered: true}, (`
function aa({bb, aa}) {
    switch (aa) {
    case 1:
        break;
    case 0:
        break;
    default:
        return {bb, aa};
    }
}
aa();
            `)],
        [{unordered: true}, "let {bb, aa} = 0;\naa(bb);"],
        [
            {variable: true},
            (`
function aa() {
    if (aa) {
        let bb = 0;
        return bb;
    }
}
            `)
        ],
        [{variable: true}, "let bb = 0;\nlet aa = 0;\naa(bb);"],
        [{white: true}, "\t"]
    ], function ([
        option_dict
    ]) {
        return JSON.stringify(option_dict);
    });
    let elemPrv = "";
    for (const [key, sampleList] of Object.entries(sampleDict)) {
        jstestIt((
            `test option=${key} handling-behavior`
        ), function () {
            for (const [option_dict, sample] of sampleList) {
                const elemNow = JSON.stringify([option_dict, sample.trim()]);
                const warningsLength = (
                    (
                        option_dict.test_internal_error ||
                        option_dict.test_unknown_warning_code
                    )
                    ? 1
                    : 0
                );
                let source = sample.trim();
                // Assert list is sorted.
                assertOrThrow(
                    elemPrv < elemNow,
                    JSON.stringify(
                        [elemPrv, elemNow],
                        undefined,
                        4
                    )
                );
                elemPrv = elemNow;
                option_dict.beta = true;
                for (const lint of [jslint.jslint, jslintCjs.jslint]) {
                    // test jslint's option handling-behavior
                    let warnings;
                    warnings = lint(
                        source,
                        option_dict
                    ).warnings;
                    assertOrThrow(
                        warnings.length === warningsLength,
                        JSON.stringify([source, warnings], undefined, 4)
                    );
                    // test jslint's directive handling-behavior
                    source = (
                        "/*jslint " +
                        JSON
                            .stringify(option_dict)
                            .slice(1, -1)
                            .replace((/"/g), "") +
                        "*/\n" +
                        source.replace((/^#!/), "//")
                    );
                    warnings = lint(source).warnings;
                    assertOrThrow(
                        warnings.length === warningsLength,
                        JSON.stringify([source, warnings], undefined, 4)
                    );
                }
            }
        });
    }
});

jstestDescribe((
    "test jslint's report handling-behavior"
), function () {
    jstestIt((
        "test report-autofix handling-behavior"
    ), function () {
        let result;

// The report's Autofix section SPEAKS ONLY AFTER THE BUTTON - index.html sets
// <autofix> on the button's own lint-result, so a plain JSLint renders an
// empty, default-coloured body. Blocked - a residual warning outside
// jslint_autofix_warning_list - is the ONLY state that goes red, and a fixable
// residual still reads as success.

        function reportAutofix(source, autofix) {
            let html = jslint.jslint_report({
                ...jslint.jslint(source, {}),
                autofix
            });
            return html.slice(
                html.indexOf("<fieldset\n    class="),
                html.indexOf("<fieldset id=\"JSLINT_REPORT_WARNINGS\"")
            );
        }

        function reportAutofixExpect(klass, body) {
            return (
                "<fieldset\n    class=\"\n    " + klass + "\n    \"\n" +
                "    id=\"JSLINT_REPORT_AUTOFIX\"\n>\n" +
                "<legend>Report: Autofix</legend>\n" +
                "<div class=\"center\">\n    " + body + "\n</div>\n" +
                "</fieldset>\n"
            );
        }

// A clean source autofixes to itself, and the click is STILL a success - an
// empty body would read to the clicker as a missing success message.

        result = reportAutofix((
            "function aa(bb) {\n    return bb;\n}\naa();\n"
        ), true);
        assertOrThrow(
            result === reportAutofixExpect("", "Autofix successful."),
            result
        );

// A residual warning INSIDE the fixable set is not a blocker, so every
// jslint_autofix_warning_list member must survive the <some> callback.

        result = reportAutofix((
            "function aa(bb) {\n    return String( bb);\n}\naa();\n"
        ), true);
        assertOrThrow(
            result === reportAutofixExpect("", "Autofix successful."),
            result
        );

// A residual too_long is not a blocker either - autofix fixes around it.

        result = reportAutofix(String(`
function aa(bb) {
    return bb;
}
aa("${"a".repeat(80)}");
        `).trim() + "\n", true);
        assertOrThrow(
            result === reportAutofixExpect("", "Autofix successful."),
            result
        );

// A warning outside the set blocks, and the class is what paints it red.

        result = reportAutofix("console.log(1);\n", true);
        assertOrThrow(
            result === reportAutofixExpect("blocked", (
                "Autofix blocked. Fix non-whitespace warnings below."
            )),
            result
        );

// A plain JSLint is ALWAYS empty and default-coloured, even on a source that
// WOULD block - <autofix> is undefined, so <some> never runs.

        result = reportAutofix("console.log(1);\n", undefined);
        assertOrThrow(result === reportAutofixExpect("", ""), result);
    });
    jstestIt((
        "test report-function-detail handling-behavior"
    ), function () {
        let result;

// This function will return the function details in the report of <source>,
// each <dl> on its own line.

        function reportFunction(source) {
            const html = jslint.jslint_report(jslint.jslint(source, {}));
            return html.slice(
                html.indexOf("<div class=\"level level1\">"),
                html.lastIndexOf("</div>\n</fieldset>")
            ).replace((/<dl>/g), "\n<dl>");
        }

// PR-516 - Bugfix - The report's function details list block-scoped names and
// catch-variables, and mark closure only across a function boundary.

        result = reportFunction(String(`
let ee = 0;
function aa(gg) {
    let bb = 0;
    let ff = 0;
    if (aa) {
        let cc = 1;
        aa(bb, cc, ee, gg);
    }
    try {
        aa(String);
    } catch (err) {
        aa(function () {
            return err;
        });
    }
    return function () {
        return ff;
    };
}
aa();
        `).trim() + "\n");
        assertOrThrow(result === String(`
<div class="level level1"><address>2: 1</address><dfn>aa(gg)</dfn>
<dl><dt>parameter</dt><dd>gg</dd></dl>
<dl><dt>variable</dt><dd>bb, cc, ff</dd></dl>
<dl><dt>exception</dt><dd>err</dd></dl>
<dl><dt>closure</dt><dd>err, ff</dd></dl>
<dl><dt>global</dt><dd>String, aa, ee</dd></dl></div>
<div class="level level2"><address>12: 12</address><dfn>«aa»()</dfn>
<dl><dt>outer</dt><dd>err</dd></dl></div>
<div class="level level2"><address>16: 12</address><dfn>«anonymous»()</dfn>
<dl><dt>outer</dt><dd>ff</dd></dl></div>
        `).trim() + "\n", result);

// PR-516 - Bugfix - A named function expression's name is outer only in a
// nested function, and a function lists an outer 'bb' even beside its own
// block-scoped 'bb'.

        result = reportFunction(String(`
function aa() {
    let bb = 0;
    function cc() {
        if (cc) {
            cc(bb);
        }
        if (cc) {
            let bb = 1;
            cc(bb);
        }
    }
    return function dd() {
        return dd(cc, function () {
            return dd;
        });
    };
}
aa();
        `).trim() + "\n");
        assertOrThrow(result === String(`
<div class="level level1"><address>1: 1</address><dfn>aa()</dfn>
<dl><dt>variable</dt><dd>bb, cc</dd></dl>
<dl><dt>closure</dt><dd>bb, cc</dd></dl></div>
<div class="level level2"><address>3: 5</address><dfn>cc()</dfn>
<dl><dt>variable</dt><dd>bb</dd></dl>
<dl><dt>outer</dt><dd>bb, cc</dd></dl></div>
<div class="level level2"><address>12: 12</address><dfn>dd()</dfn>
<dl><dt>outer</dt><dd>cc</dd></dl></div>
<div class="level level3"><address>13: 23</address><dfn>«cc»()</dfn>
<dl><dt>outer</dt><dd>dd</dd></dl></div>
        `).trim() + "\n", result);
    });
    jstestIt((
        "test report-function-name handling-behavior"
    ), function () {

// PR-516 - Bugfix - A method or accessor is named after its property, not
// after the identifier before it.

        assertJsonEqual(jslint.jslint(String(`
/*jslint getset*/
String({
    aa() {
        return;
    },
    get bb() {
        return;
    },
    cc: 0,
    dd() {
        return;
    }
});
        `).trim() + "\n").functions.map(function ({name}) {
            return name;
        }), ["aa", "get bb", "dd"]);

// PR-516 - Bugfix - A function after a keyword is anonymous, except after
// 'default', the name the spec gives it.

        assertJsonEqual(jslint.jslint(String(`
String(function () {
    return function () {
        return;
    };
}, typeof function () {
    return;
});
export default function () {
    return;
}
        `).trim() + "\n").functions.map(function ({name}) {
            return name;
        }), ["String", "anonymous", "anonymous", "default"]);

// PR-516 - Bugfix - A keyword used as a property name still names a function.

        assertJsonEqual(jslint.jslint(String(`
const aa = {
    delete: function () {
        return;
    }
};
aa.catch = function () {
    return;
};
String(aa?.finally || function () {
    return;
});
String(aa
? null
: function () {
    return;
});
        `).trim() + "\n").functions.map(function ({name}) {
            return name;
        }), ["delete", "catch", "finally", "anonymous"]);
    });
    jstestIt((
        "test report-function-signature handling-behavior"
    ), function () {
        const a38 = "a".repeat(38);

// PR-516 - Bugfix - A signature keeps default values and drops comments, and a
// multi-line destructure joins with no space inside its brackets. A default
// value longer than 40 characters, or holding a megastring, shows as an
// ellipsis, but a backtick inside a string or regexp does not count.

        assertJsonEqual(jslint.jslint(String(`
function aa(bb, cc = 1, ...dd) {
    return [bb, cc, dd];
}
function ee({
    ff,
    gg = "" // Comment.
}, hh) {
    return [ff, gg, hh];
}
function ii(jj = function () {
    return "a default value longer than forty characters";
}, kk = [0, 1], ll = \`\${kk}\`) {
    return [jj, kk, ll];
}
function mm(
    nn /* Comment. */,
    oo = [
        1
    ],
    pp = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    qq = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    rr = [\`a\`, 1]
) {
    return [nn, oo, pp, qq, rr];
}
function ss(tt = "\`", uu = /\`/) {
    return [tt, uu];
}
function vv(ww = (xx = 1) => "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa") {
    return ww;
}
        `).trim() + "\n").functions.map(function ({signature}) {
            return signature;
        }), [
            "(bb, cc = 1, ...dd)",
            "({ff, gg = \"\"}, hh)",
            "(jj = \u2026, kk = [0, 1], ll = \u2026)",
            "()",
            `(nn, oo = [1], pp = "${a38}", qq = \u2026, rr = \u2026)`,
            "(tt = \"`\", uu = /`/)",
            "(ww = \u2026)",
            "(xx = 1)"
        ]);

// A parse that stops inside a parameter list leaves the signature '('.

        assertJsonEqual(jslint.jslint(
            "function aa(bb, 0) {}\n"
        ).functions.map(function ({signature}) {
            return signature;
        }), ["("]);
    });
});

jstestDescribe((
    "test jslint's warnings handling-behavior"
), function () {
    jstestIt((
        "test binding-power handling-behavior"
    ), function () {

// PR-514 - Bugfix - Binding-powers follow the spec's grammar, as tabled in
// MDN Operator precedence. Each source returns the expression beside the
// parameters, so none is unused, and lists the warning codes it must raise.

        for (const [expression, expect] of [
            ["(-aa) ** 2", []],
            ["-aa ** 2", ["wrap_subexpression_a_b"]],
            ["-aa++", ["unexpected_a"]],
            ["[aa] ** 2", []],
            ["aa ** -2", []],
            ["aa ?? (bb || cc)", []],
            ["aa ?? bb && cc", ["wrap_subexpression_a_b"]],
            ["aa ?? bb ?? cc", []],
            ["aa || bb ?? cc", ["wrap_subexpression_a_b"]],
            ["typeof aa ** 2", ["wrap_subexpression_a_b"]]
        ]) {
            const result = jslint.jslint(String(`
function ff(aa, bb, cc) {
    return [aa, bb, cc, ${expression}];
}
ff();
            `).trim() + "\n");
            assertJsonEqual(result.warnings.map(function ({code}) {
                return code;
            }), expect, expression);
        }

// PR-514 - Bugfix - The operand of 'void' is parsed at rbp 150, like every
// unary operator, so 'void 0 + 0' is '(void 0) + 0'.

        assertOrThrow(
            jslint.jslint("String(void 0 + 0);\n").tokens.find(function ({
                id
            }) {
                return id === "+";
            }).expression[0].id === "void",
            "void 0 + 0"
        );

// PR-514 - Bugfix - A relational right side of a for-loop-head 'of' or 'in'
// does not warn on the head's own 'of' or 'in'.

        for (const [operator, expect] of [
            ["in", ["expected_a_b", "expected_a"]],
            ["of", ["expected_a"]]
        ]) {
            assertJsonEqual(jslint.jslint(String(`
function ff(aa, bb) {
    for (aa ${operator} bb < aa) {
        bb();
    }
}
ff();
            `).trim() + "\n").warnings.map(function ({code}) {
                return code;
            }), expect, operator);
        }

// PR-514 - A 'for in' suggests 'for...of Object.keys', not 'Object.keys'.

        assertJsonEqual(jslint.jslint(String(`
function ff(aa) {
    for (const bb in aa) {
        aa(bb);
    }
}
ff();
        `).trim() + "\n").warnings.map(function ({message}) {
            return message;
        }), ["Expected 'for...of Object.keys' and instead saw 'for in'."]);

// PR-514 - Bugfix - '**=' is one assignment token, '**' takes a space on each
// side like '*', and a line break before a postfix '++' ends the expression.

        for (const [source, expect] of [
            ["let aa = 2;\naa **= 2;\n", []],
            [
                "let aa = 2;\naa = aa**2;\n",
                ["expected_space_a_b", "expected_space_a_b"]
            ],
            [
                "let aa = 0;\nlet bb = 0;\naa\n++bb;\n",
                [
                    "unexpected_expression_a",
                    "expected_a_after_b",
                    "unexpected_expression_a"
                ]
            ]
        ]) {
            assertJsonEqual(jslint.jslint(source).warnings.map(function ({
                code
            }) {
                return code;
            }), expect, source);
        }
        assertJsonEqual(jslint.jslint("let aa = 2;\naa = aa**2;\n", {
            autofix: true
        }).autofixed, "let aa = 2;\naa = aa ** 2;\n");
    });
    jstestIt((
        "test warning-test-cause handling-behavior"
    ), async function () {

// This function will validate each fixture in each '// test_cause:' block of
// jslint.mjs. A "(live)" source must run the code below its block, by V8 block
// coverage. A warning must be shown, with the code below its block on the
// stack that option trace records. Then validate the roster of fixtures filed
// up the stack, and that each raise site in jslint.mjs has a fixture.

        const controlList = [];
        const fixtureLineList = [];
        const fixtureList = [];
        const raiserList = ["stop", "stop_at", "warn", "warn_at"];
        const rgxFixtureLine = (
            /^\/\/ (?!\/\/).*, \d+\](?: \/\/jslint-ignore-line)?$/gm
        );
        const rgxFrame = (
            /^ {4}at (?:(?:Object\.)?([\w.]+).*? \()?.*?jslint\.mjs:(\d+):/gm
        );
        const stackTraceLimit = Error.stackTraceLimit;
        function fixturePush(list, cause, anchor) {

// This function will push to <list> the fixture <cause>, whose block sits
// directly above the code at offset <anchor> in jslint.mjs.

            const line = (
                sourceJslintMjs.slice(0, anchor).match(/\n/g).length + 1
            );
            const [source, fn, code, aa, column] = cause;
            const warnings = jslintTrace(source);

// List each warning with its frames in jslint.mjs, by the stack that option
// trace records, as [name, line] innermost first, and the frames above the
// raisers, whose first is the line that raised it. An anonymous function's
// frame has no name.

            const warningsRaised = warnings.map(function (warning) {
                const frameList = Array.from(
                    String(warning.stack_trace).matchAll(rgxFrame),
                    function ([ignore, name, line]) {
                        return [name, Number(line)];
                    }
                );
                return {
                    aboveList: frameList.filter(function ([name]) {
                        return !raiserList.includes(name);
                    }),
                    frameList,
                    warning
                };
            });

// A second warning on one token is dropped, so check the warnings the user
// sees, never the ones raised.

            const warningsShown = warningsRaised.filter(function ({warning}) {
                return (
                    warning.code === code &&
                    String(warning.b || warning.a || "") === aa &&
                    warning.column === column
                );
            });

// The shown warning raised through the code under the block.

            const warningsVia = warningsShown.filter(function ({frameList}) {
                return frameList.some(function ([ignore, at]) {
                    return at === line;
                });
            });
            list.push({
                anchor,

// Name the line of the code under the block, so a failure points at it.

                at: "jslint.mjs:" + line,
                cause: JSON.stringify(cause),
                code,

// Validate no internal-error. A crash mid-walk still runs every branch before
// it, so a coverage-check alone passes straight through one, and "0``" threw
// in post_b_binary for years with its cause declared and green.

                codeless: warnings.some(function (warning) {
                    return warning.code === undefined;
                }),
                fn,

// A fixture has exactly 5 fields. Field 3 "(live)" marks a branch reached with
// no warning of its own, documenting how, so it is not taken for deadcode. Any
// other field 3 must be a warning shown below, so a typo fails there.

                known: cause.length === 5 && (
                    code !== "(live)" || (aa === "" && column === 0)
                ),

// Field 2 of a warning names the function that raised it, the first named one
// above the raisers in the stack that option trace records, so a fixture may
// be filed up the stack, above the call that leads down to the raise site.

                raise: warningsVia[0]?.aboveList[0],
                raiser: warningsVia[0]?.aboveList.find(function ([name]) {
                    return name;
                })?.[0],
                shown: code === "(live)" || warningsShown.length > 0,

// A "(live)" block must not sit on a raise whose warning shows, since a
// warning fixture checks more.

                silent: code !== "(live)" || warningsRaised.every(function ({
                    aboveList
                }) {
                    return aboveList[0]?.[1] !== line;
                }),
                source,
                via: code === "(live)" || warningsVia.length > 0
            });
        }
        function jslintTrace(source) {

// This function will lint <source> with option trace, keeping every frame,
// since a fixture filed up the stack can sit past V8's default of 10. Restore
// the limit even if jslint throws, so no other test inherits it.

            Error.stackTraceLimit = Infinity;
            try {
                return jslint.jslint(source, {
                    beta: true,
                    trace: true
                }).warnings;
            } finally {
                Error.stackTraceLimit = stackTraceLimit;
            }
        }

        sourceJslintMjs.replace((
            /(\n\s*?\/\/\s*?test_cause:\s*?)(\S[\S\s]*?\S)(\n\n\s*?) *?\S/g
        ), function (match0, header, causeList, footer, offset) {
            const rgxAnchor = (/(?:\/\/.*\n\s*)*(?:[?:]\s*)?/y);
            let tmp;
            // console.error(match0);
            // Validate header.
            assertOrThrow(header === "\n\n// test_cause:\n", match0);
            // Validate footer.
            assertOrThrow(footer === "\n\n", match0);
            fixtureLineList.push(...match0.match(rgxFixtureLine));
            // Validate causeList.
            causeList = causeList.replace((
                /^\/\/ /gm
            ), "").replace((
                /^\["\n([\S\s]*?)\n"(,.*?)$/gm
            ), function (ignore, source, param) {
                source = "[" + JSON.stringify(source) + param;
                return source;
            }).replace((
                / \/\/jslint-ignore-line$/gm
            ), "");
            tmp = causeList.split("\n").map(function (cause) {
                return (
                    "[" +
                    JSON.parse(cause).map(function (elem) {
                        return JSON.stringify(elem);
                    }).join(", ") +
                    "]"
                );
            }).sort().filter(function (cause, ii, list) {
                return cause !== list[ii - 1];
            }).join("\n");
            assertOrThrow(
                causeList === tmp,
                "\n" + causeList + "\n\n" + tmp
            );

// Anchor the block to the first code below it, past any comment paragraph and
// a leading '?' or ':' of a ternary branch.

            rgxAnchor.lastIndex = offset + match0.length - 1;
            rgxAnchor.exec(sourceJslintMjs);
            for (const cause of causeList.split("\n")) {
                fixturePush(
                    fixtureList,
                    JSON.parse(cause),
                    rgxAnchor.lastIndex
                );
            }
            return "";
        });

// Validate each fixture's last line was parsed in a block, so a misspelled
// header fails, naming the lines it hid, instead of hiding its block. The
// count catches a line that two blocks share. Commented-out code keeps its
// blocks as '// // test_cause:', unchecked.

        assertJsonEqual(sourceJslintMjs.match(rgxFixtureLine).filter(
            function (line) {
                return !fixtureLineList.includes(line);
            }
        ), []);
        assertJsonEqual(
            sourceJslintMjs.match(rgxFixtureLine).length,
            fixtureLineList.length
        );

// Negative controls: each bad fixture, filed in the block of a good one, must
// fail exactly the named check, so a weakened checker turns this test red.

        for (const [good, bad, expect] of [
            [
                [
                    "/*jslint test_internal_error*/\nif(0%0){}",
                    "condition",
                    "(live)",
                    "",
                    0
                ],
                ["codeless", "silent"]
            ], [
                ["if(0%0){}", "condition", "unexpectd_a", "%", 5],
                ["inFn", "shown", "via"]
            ], [
                ["if(0%0){}", "condition", "(live)", "", 0],
                ["silent"]
            ], [
                ["if(0%0){}", "condition", "(live)", "aa", 0],
                ["known", "silent"]
            ], [
                ["if(0%0){}", "condition", "(live)", "", 5],
                ["known", "silent"]
            ], [
                ["if(0%0){}", "condition", "unexpected_a", "%", 5, "extra"],
                ["known"]
            ], [
                ["if(0%0){}", "condition", "unexpected_a", "%", 6],
                ["inFn", "shown", "via"]
            ], [
                ["if(0%0){}", "condition", "unexpected_a", "&", 5],
                ["inFn", "shown", "via"]
            ], [
                ["if(0%0){}", "condition", "empty_block", "{", 8],
                ["inFn", "via"]
            ], [
                ["if(0%0){}", "warn", "unexpected_a", "%", 5],
                ["inFn"]
            ], [
                ["if(0&0){}", "condition", "unexpected_a", "&", 5],
                ["inFn", "live", "via"]
            ]
        ].map(function ([bad, expect]) {
            return [
                "[\"if(0%0){}\",\"condition\",\"unexpected_a\",\"%\",5]",
                bad,
                expect
            ];
        }).concat([
            [
                "[\"let aa=!!0;\",\"post_u_unary\",\"expected_a_b\",\"!!\",8]",
                ["!!0", "post_u_unary", "expected_a_b", "!!", 1],
                ["inFn", "shown", "via"]
            ], [
                "[\"aa=/./vu\",\"lex_regexp\",\"unexpected_a\",\"u\",8]",
                ["aa=/./u;if(0){}", "lex_regexp", "unexpected_a", "0", 12],
                ["inFn", "live", "via"]
            ], [

// Filed up the stack above the wrong caller: <check_left> raises it through
// <infix_lbracket>, not through the call under this block in <infix_dot>.

                "[\"aa=[]?.aa\",\"check_left\",\"unexpected_a\",\"?.\",6]",
                ["\"\".aa;0[0]", "check_left", "unexpected_a", "[", 8],
                ["inFn", "via"]
            ], [

// Raised here but dropped, since <post_a_pluseq> warned on the token first,
// so the warning shown is another site's.

                (
                    "[\"aa-=undefined\",\"post_a_assignment\"," +
                    "\"unexpected_a\",\"undefined\",5]"
                ),
                [
                    "aa+=undefined",
                    "post_a_assignment",
                    "unexpected_a",
                    "undefined",
                    5
                ],
                ["inFn", "via"]
            ]
        ])) {
            const found = fixtureList.find(function ({cause}) {
                return cause === good;
            });
            assertOrThrow(found, `control's good fixture is missing: ${good}`);
            fixturePush(controlList, bad, found.anchor);
            controlList.at(-1).expect = expect;
        }

// Measure each fixture's coverage in a child, since taking precise coverage
// resets the counters that NODE_V8_COVERAGE dumps at exit.

        await childRun({
            NODE_V8_COVERAGE: ""
        }, String(`
import moduleFs from "fs";
import moduleInspector from "inspector/promises";
const fixtureList = JSON.parse(moduleFs.readFileSync(0, "utf8"));
const resultList = [];
const session = new moduleInspector.Session();
session.connect();
await session.post("Profiler.enable");
await session.post("Profiler.startPreciseCoverage", {
    callCount: true,
    detailed: true
});
for (const [offset, source] of fixtureList) {
    const result = [0, ""];
    const span = [Infinity, Infinity];
    jslint(source, {
        beta: true
    });
    for (const {functionName, ranges} of (
        await session.post("Profiler.takePreciseCoverage")
    ).result.find(function ({url}) {
        return url.endsWith("/jslint.mjs");
    }).functions) {
        for (const range of ranges) {
            const width = range.endOffset - range.startOffset;
            if (range.startOffset <= offset && offset < range.endOffset) {
                if (width <= span[0]) {
                    result[0] = range.count;
                    span[0] = width;
                }
                if (functionName && width < span[1]) {
                    result[1] = functionName;
                    span[1] = width;
                }
            }
        }
    }
    resultList.push(result);
}
process.stdout.write(JSON.stringify(resultList));
        `).trim() + "\n", JSON.stringify(
            fixtureList.concat(controlList).map(function ({anchor, source}) {
                return [anchor, source];
            })
        )).then(function ([exitCode, stderr, stdout]) {
            const hostDict = {};
            const raiseDict = {};
            let recordList;
            assertOrThrow(exitCode === 0, stderr);
            recordList = JSON.parse(stdout).map(function ([count, name], ii) {
                const {
                    at,
                    cause,
                    code,
                    codeless,
                    expect = [],
                    fn,
                    known,
                    raise,
                    raiser,
                    shown,
                    silent,
                    via
                } = fixtureList.concat(controlList)[ii];
                let check;
                if (ii < fixtureList.length) {
                    raiseDict[raise?.[1]] = true;

// A fixture filed up the stack pairs the function holding its block with the
// one that raised it.

                    if (name !== fn) {
                        hostDict[name + " <- " + fn] = true;
                    }
                }
                check = {
                    codeless: !codeless,

// Field 2 of a (live) fixture names the function holding the block.

                    inFn: fn === (
                        code === "(live)"
                        ? name
                        : raiser
                    ),
                    known,
                    live: count > 0,
                    shown,
                    silent,
                    via
                };
                return {
                    at,
                    cause,
                    expect,
                    fail: Object.keys(check).filter(function (key) {
                        return !check[key];
                    })
                };
            });

// List every fixture whose failed checks differ from those expected: none for
// a fixture, exactly the named ones for a negative control.

            assertJsonEqual(recordList.filter(function ({expect, fail}) {
                return String(fail) !== String(expect);
            }), []);

// Validate the roster of fixtures filed up the stack, as "host <- raiser"
// pairs, so each new pair is a reviewed decision and a filing far up the stack
// fails, which <via> alone accepts from any frame. A rename of either function
// shows as one pair missing and one extra. No counts: a fixture added or moved
// within a known pair is not a review.

            assertJsonEqual(Object.keys(hostDict).sort(), [
                "infix_dot <- check_left",
                "infix_grave <- check_left",
                "infix_lbracket <- check_left",
                "infix_lparen <- check_left",
                "jslint_phase3_parse <- check_ordered",
                "post_s_var <- name_lookup",
                "prefix_destructure <- check_ordered",
                "prefix_destructure <- name_parse",
                "prefix_function <- check_ordered",
                "prefix_lbrace <- check_ordered",
                "stmt_export <- check_ordered",
                "stmt_export <- semicolon",
                "stmt_switch <- check_ordered_case",
                "whitage_default <- one_space_only"
            ]);

// Validate each raise site in jslint.mjs raises the warning of some fixture,
// except the raisers' own calls, and a test hook raising an unknown code.

            assertJsonEqual(sourceJslintMjs.replace((
                /^ {4}function (?:stop|warn)(?:_at)?\([\S\s]*?\n {4}\}\n/gm
            ), function (match0) {
                return match0.replace(/[^\n]/g, "");
            }).split("\n").map(function (text, ii) {
                return [ii + 1, text.trim()];
            }).filter(function ([line, text]) {
                return (
                    !text.startsWith("//") &&
                    (/(?:^|[^\w.])(?:stop|warn)(?:_at)?\(/m).test(text) &&
                    !text.includes("\"test_unknown_warning_code\"") &&
                    !raiseDict[line]
                );
            }), []);
        });
    });
});

jstestDescribe((
    "test jslint_wrapper_vscode handling-behavior"
), function () {
    jstestIt((
        "test jslint_wrapper_vscode commands handling-behavior"
    ), async function () {

// Load the extension against a stub vscode api, then drive every command.
// Like vscode, the stub's <registerTextEditorCommand> runs its callback inside
// <edit>, and <edit> applies the builder's edits once the callback returns.

        const commandDict = {};
        const moduleStub = {
            exports: {}
        };
        const sourceWrapper = await moduleFs.promises.readFile(
            "jslint_wrapper_vscode.js",
            "utf8"
        );
        const state = {};
        const subscriptions = [];
        const vscode = {
            Diagnostic: function (ignore, message) {
                return {
                    message
                };
            },
            DiagnosticSeverity: {},
            ProgressLocation: {},
            Range: noop,
            commands: {
                registerCommand: function (id, callback) {
                    commandDict[id] = callback;
                    return [id, "registerCommand"];
                },
                registerTextEditorCommand: function (id, callback) {
                    commandDict[id] = function () {
                        return state.editor.edit(function (edit) {
                            callback(state.editor, edit);
                        });
                    };
                    return [id, "registerTextEditorCommand"];
                }
            },
            languages: {
                createDiagnosticCollection: function () {
                    return {
                        clear: function () {
                            delete state.diagnosticList;
                        },
                        set: function (ignore, list) {
                            state.diagnosticList = list.map(function ({
                                message
                            }) {
                                return message;
                            });
                        }
                    };
                }
            },
            window: {
                withProgress: function (ignore, callback) {
                    return callback({
                        report: noop
                    });
                }
            }
        };
        function editorCreate(text, selection) {
            state.source = text;
            state.editor = {
                document: {
                    getText: function (range) {
                        return (
                            range
                            ? state.source.slice(
                                offsetAt(range.start),
                                offsetAt(range.end)
                            )
                            : state.source
                        );
                    },
                    lineAt: function ({
                        line
                    }) {
                        const lineList = state.source.split("\n");
                        return {
                            range: {
                                end: {
                                    character: lineList[line].length,
                                    line
                                },
                                start: {
                                    character: 0,
                                    line
                                }
                            },
                            rangeIncludingLineBreak: {
                                end: (
                                    line + 1 < lineList.length
                                    ? {
                                        character: 0,
                                        line: line + 1
                                    }
                                    : {
                                        character: lineList[line].length,
                                        line
                                    }
                                ),
                                start: {
                                    character: 0,
                                    line
                                }
                            }
                        };
                    },
                    save: function () {

// Stand in for a format-on-save that rewrites the text.

                        state.source = "let cc = 3;\n";
                        return Promise.resolve(true);
                    },
                    validateRange: noop
                },
                edit: function (callback) {
                    const editList = [];
                    callback({
                        insert: function (position, text) {
                            editList.push([position, position, text]);
                        },
                        replace: function (range, text) {

// An undefined range, from the stub <validateRange>, is the whole document.

                            editList.push([range?.start, range?.end, text]);
                        }
                    });

// Resolve offsets against the text before any edit, then apply right to left.
// On a tie the later edit goes first, so an insert lands before a replace.

                    editList.map(function ([start, end, text], ii) {
                        return [
                            (
                                start
                                ? offsetAt(start)
                                : 0
                            ),
                            (
                                end
                                ? offsetAt(end)
                                : state.source.length
                            ),
                            text,
                            ii
                        ];
                    }).sort(function (aa, bb) {
                        return bb[0] - aa[0] || bb[3] - aa[3];
                    }).forEach(function ([start, end, text]) {
                        state.source = (
                            state.source.slice(0, start) +
                            text +
                            state.source.slice(end)
                        );
                    });
                    return Promise.resolve(true);
                },
                selection
            };
            vscode.window.activeTextEditor = state.editor;
        }
        function offsetAt({
            character,
            line
        }) {
            return state.source.split("\n").slice(0, line).reduce(function (
                sum,
                text
            ) {
                return sum + text.length + 1;
            }, character);
        }
        moduleVm.runInThisContext(String(`
(function (__dirname, exports, module, require) {
${sourceWrapper}
})
        `).trim() + "\n")(
            modulePath.resolve("."),
            moduleStub.exports,
            moduleStub,
            function (id) {
                return (
                    id === "vscode"
                    ? vscode
                    : id === "vm"
                    ? moduleVm
                    : moduleFs
                );
            }
        );

// Activation reuses moduleStub to load jslint, so read activate first.

        moduleStub.exports.activate({
            subscriptions
        });
        assertJsonEqual(subscriptions, [
            ["jslint.autofix", "registerCommand"],
            ["jslint.clear", "registerCommand"],
            ["jslint.disableRegion", "registerTextEditorCommand"],
            ["jslint.ignoreLine", "registerTextEditorCommand"],
            ["jslint.lint", "registerCommand"],
            ["jslint.lintAndSave", "registerCommand"]
        ]);

// With no active editor, clear still clears and the rest return quietly.

        state.diagnosticList = ["aa"];
        await commandDict["jslint.clear"]();
        assertJsonEqual(state.diagnosticList, undefined);
        await commandDict["jslint.autofix"]();
        await commandDict["jslint.lint"]();
        await commandDict["jslint.lintAndSave"]();
        assertJsonEqual(state.diagnosticList, undefined);

// Lint ignores the context menu's uri argument, and resolves only after the
// warnings are set.

        editorCreate("let aa = 1;\n");
        await commandDict["jslint.lint"]("file:///aa.js");
        assertJsonEqual(state.diagnosticList, ["JSLint - Unused 'aa'."]);

// Lint-and-save lints the text as saved.

        editorCreate("let bb = 2;\n");
        await commandDict["jslint.lintAndSave"]();
        assertJsonEqual(state.diagnosticList, ["JSLint - Unused 'cc'."]);

// Autofix rewrites the text, then re-lints it.

        editorCreate("function aa() {\n  return 1;\n}\naa();\n");
        await commandDict["jslint.autofix"]();
        assertJsonEqual(
            state.source,
            "function aa() {\n    return 1;\n}\naa();\n"
        );
        assertJsonEqual(state.diagnosticList, []);

// Disable-region, with a cursor: wrap the cursor's line.

        editorCreate("aa();\nbb();\n", {
            end: {
                character: 2,
                line: 0
            },
            isEmpty: true,
            start: {
                character: 2,
                line: 0
            }
        });
        await commandDict["jslint.disableRegion"]();
        assertJsonEqual(
            state.source,
            "/*jslint-disable*/\naa();\n/*jslint-enable*/\nbb();\n"
        );

// Disable-region, with a selection ending at the start of a line: the enable
// directive goes before that line, not after it.

        editorCreate("aa();\nbb();\ncc();\n", {
            end: {
                character: 0,
                line: 2
            },
            isEmpty: false,
            start: {
                character: 0,
                line: 0
            }
        });
        await commandDict["jslint.disableRegion"]();
        assertJsonEqual(
            state.source,
            "/*jslint-disable*/\naa();\nbb();\n/*jslint-enable*/\ncc();\n"
        );

// Disable-region, on a last line with no line break: add one first.

        editorCreate("aa();", {
            end: {
                character: 0,
                line: 0
            },
            isEmpty: true,
            start: {
                character: 0,
                line: 0
            }
        });
        await commandDict["jslint.disableRegion"]();
        assertJsonEqual(
            state.source,
            "/*jslint-disable*/\naa();\n/*jslint-enable*/"
        );

// Ignore-line: append the directive to the end of the selection's last line.

        editorCreate("aa();\nbb();\n", {
            end: {
                character: 2,
                line: 1
            },
            isEmpty: true,
            start: {
                character: 2,
                line: 1
            }
        });
        await commandDict["jslint.ignoreLine"]();
        assertJsonEqual(state.source, "aa();\nbb(); //jslint-ignore-line\n");
    });
});

jstestDescribe((
    "test jstestXxx handling-behavior"
), function () {
    jstestIt((
        "test jstestDescribe-body-hang handling-behavior"
    ), async function () {

// An async body that hangs before registering any test fails at exit as a
// pending body, instead of passing with 0 tests. With nothing alive, the hang
// exits at once.

        const [exitCode, stderr] = await childRun({}, String(`
jslint.jstestDescribe("aa", async function () {
    await new Promise(jslint.noop);
    jslint.jstestIt("bb", jslint.noop);
});
        `));
        assertJsonEqual(exitCode, 1);
        assertMatch(stderr, /1\. test it pending - aa - jstestDescribe body\n {2}tests total {2}- 1\n {2}tests failed - 1\n/);
    });
    jstestIt((
        "test jstestDescribe-body-throw handling-behavior"
    ), async function () {

// A describe body that throws crashes node, and the exit report lists the body
// and the tests it did register as pending; an invalid filter regexp throws
// from that body too. A falsy throw fails the same.

        const [
            [exitCode, stderr],
            [exitCode2, stderr2],
            [exitCode3, stderr3]
        ] = await Promise.all([
            childRun({}, String(`
jslint.jstestDescribe("aa", function () {
    jslint.jstestIt("bb", jslint.noop);
    throw new Error("aa body broke");
});
            `)),
            childRun({
                npm_config_mode_test_filter: "("
            }, String(`
jslint.jstestDescribe("aa", function () {
    jslint.jstestIt("bb", jslint.noop);
});
            `)),
            childRun({}, String(`
jslint.jstestDescribe("aa", function () {
    jslint.jstestIt("bb", jslint.noop);
    throw undefined;
});
            `))
        ]);
        assertJsonEqual([exitCode, exitCode2, exitCode3], [1, 1, 1]);
        assertMatch(stderr, /1\. test it pending - aa - jstestDescribe body\n[\s\S]*2\. test it pending - aa - bb\n[\s\S]*tests failed - 2\n[\s\S]*Error: aa body broke\b/);
        assertMatch(stderr2, /1\. test it pending - aa - jstestDescribe body\n[\s\S]*SyntaxError: Invalid regular/);
        assertMatch(stderr3, /1\. test it pending - aa - jstestDescribe body\n[\s\S]*tests failed - 2\n[\s\S]*ERR_UNHANDLED_REJECTION/);
    });
    jstestIt((
        "test jstestDescribe-concurrent handling-behavior"
    ), async function () {

// A describe's tests run concurrently: bb waits on an event cc emits, which
// hangs if they run one after another.

        const [exitCode, stderr] = await childRun({}, String(`
import {EventEmitter} from "node:events";
const ee = new EventEmitter();
jslint.jstestDescribe("aa", function () {
    jslint.jstestIt("bb", function () {
        return new Promise(function (resolve) {
            ee.once("go", resolve);
        });
    });
    jslint.jstestIt("cc", function () {
        ee.emit("go");
    });
});
        `));
        assertJsonEqual(exitCode, 0);
        assertMatch(stderr, /tests total {2}- 2\n {2}tests failed - 0\n/);
    });
    jstestIt((
        "test jstestDescribe-order handling-behavior"
    ), async function () {

// The runner fails a describe's tests out of order, and a describe out of order
// with the one before it, each as one more failed test.

        const [exitCode, stderr] = await childRun({}, String(`
jslint.jstestDescribe("cc", function () {
    jslint.jstestIt("bb", jslint.noop);
    jslint.jstestIt("aa", jslint.noop);
});
jslint.jstestDescribe("aa", function () {
    jslint.jstestIt("dd", jslint.noop);
});
        `));
        assertJsonEqual(exitCode, 1);
        assertMatch(stderr, /tests failed - 2\n/);
        assertOrThrow(stderr.includes(
            "\"aa\" must sort before \"bb\""
        ), stderr);
        assertOrThrow(stderr.includes(
            "\"aa\" must sort before \"cc\""
        ), stderr);

// A failure its describe printed is not listed again at exit.

        assertOrThrow(!stderr.includes("test it failed"), stderr);
    });
    jstestIt((
        "test jstestDescribe-order-edge handling-behavior"
    ), async function () {

// Only a describe's first bad pair fails. A duplicate fails, and so does a
// non-string name, since '>=' would be false for it and let it pass.

        const resultList = await Promise.all([
            ["aa", "cc", "bb", "aa"],
            ["aa", "aa"],
            [undefined, "bb"]
        ].map(function (descriptionList) {
            return childRun({}, String(`
jslint.jstestDescribe("aa", function () {
    for (const description of ${JSON.stringify(descriptionList)}) {
        jslint.jstestIt(description ?? undefined, jslint.noop);
    }
});
            `));
        }));
        assertJsonEqual(resultList.map(function ([exitCode, stderr]) {
            return [exitCode, stderr.match(/\S+ must sort before .*|duplicate description .*/g)];
        }), [
            [1, ["\"bb\" must sort before \"cc\""]],
            [1, ["duplicate description \"aa\""]],
            [1, ["\"bb\" must sort before undefined"]]
        ]);
    });
    jstestIt((
        "test jstestIt-filter handling-behavior"
    ), async function () {

// Opt-in npm_config_mode_test_filter runs only "cc - dd", and a describe left
// with no test prints nothing.

        const [exitCode, stderr] = await childRun({
            npm_config_mode_test_filter: "^cc - dd$"
        }, String(`
jslint.jstestDescribe("aa", function () {
    jslint.jstestIt("bb", jslint.noop);
});
jslint.jstestDescribe("cc", function () {
    jslint.jstestIt("dd", jslint.noop);
    jslint.jstestIt("ee", function () {
        throw new Error();
    });
});
        `));
        assertJsonEqual(exitCode, 0);
        assertMatch(stderr, /test describe - cc\n.*1\. test it - dd\b[\s\S]*tests total {2}- 1\n/);
        assertOrThrow(!stderr.includes("test describe - aa"), stderr);
        assertOrThrow(!stderr.includes("test it - ee"), stderr);
    });
    jstestIt((
        "test jstestIt-filter-empty handling-behavior"
    ), async function () {

// A filter that matches no test fails the run, so a stray or mistyped filter
// cannot skip the whole suite and pass.

        const [exitCode, stderr] = await childRun({
            npm_config_mode_test_filter: "^zz$"
        }, String(`
jslint.jstestDescribe("aa", function () {
    jslint.jstestIt("bb", jslint.noop);
});
        `));
        assertJsonEqual(exitCode, 1);
        assertMatch(stderr, /no test matched npm_config_mode_test_filter="\^zz\$"\n {2}tests total {2}- 0\n/);
    });
    jstestIt((
        "test jstestIt-late handling-behavior"
    ), async function () {

// A jstestIt after an await in an async describe body, from a timer after the
// body settled, or before any describe, throws: only the body's synchronous
// part registers. The first crashes the body, leaving it and bb pending.

        const resultList = await Promise.all([
            String(`
jslint.jstestDescribe("aa", async function () {
    jslint.jstestIt("bb", jslint.noop);
    await null;
    jslint.jstestIt("cc", jslint.noop);
});
            `),
            String(`
jslint.jstestDescribe("aa", function () {
    setTimeout(function () {
        jslint.jstestIt("cc", jslint.noop);
    }, 10);
    jslint.jstestIt("bb", function () {
        return new Promise(function (resolve) {
            setTimeout(resolve, 50);
        });
    });
});
            `),
            String(`
jslint.jstestIt("cc", jslint.noop);
            `)
        ].map(function (source) {
            return childRun({}, source);
        }));
        assertJsonEqual(resultList.map(function ([exitCode]) {
            return exitCode;
        }), [1, 1, 1]);
        assertMatch(resultList[0][1], /1\. test it pending - aa - jstestDescribe body\n[\s\S]*2\. test it pending - aa - bb\n[\s\S]*tests failed - 2\n/);
        resultList.forEach(function ([ignore, stderr]) {
            assertOrThrow(stderr.includes(
                "jstestIt \"cc\" called outside a jstestDescribe body, or" +
                " after an await"
            ), stderr);
        });
    });
    jstestIt((
        "test jstestIt-late-filtered handling-behavior"
    ), async function () {

// A late jstestIt throws even when the filter would skip it, so a filter never
// hides a test registered after its describe settled.

        const [exitCode, stderr] = await childRun({
            npm_config_mode_test_filter: "^aa - bb$"
        }, String(`
jslint.jstestDescribe("aa", function () {
    setTimeout(function () {
        jslint.jstestIt("cc", jslint.noop);
    }, 10);
    jslint.jstestIt("bb", function () {
        return new Promise(function (resolve) {
            setTimeout(resolve, 50);
        });
    });
});
        `));
        assertJsonEqual(exitCode, 1);
        assertOrThrow(stderr.includes(
            "jstestIt \"cc\" called outside a jstestDescribe body, or after" +
            " an await"
        ), stderr);
    });
    jstestIt((
        "test jstestIt-throw-non-error handling-behavior"
    ), async function () {

// A test that throws undefined or a string, or rejects with no reason, fails
// and prints what it threw, without crashing the runner's report. The exit
// report prints a string too, for a failure a hung sibling kept unprinted.

        const [[exitCode, stderr], [exitCode2, stderr2]] = await Promise.all([
            childRun({}, String(`
jslint.jstestDescribe("aa", function () {
    jslint.jstestIt("bb", function () {
        throw undefined;
    });
    jslint.jstestIt("cc", function () {
        return Promise.reject();
    });
    jslint.jstestIt("dd", function () {
        throw "dd string";
    });
    jslint.jstestIt("ee", function () {
        throw Object.create(null);
    });
});
            `)),
            childRun({}, String(`
jslint.jstestDescribe("aa", function () {
    jslint.jstestIt("bb", function () {
        throw "bb string";
    });
    jslint.jstestIt("bc", function () {
        throw 0;
    });
    jslint.jstestIt("cc", function () {
        setTimeout(process.exit, 100);
        return new Promise(jslint.noop);
    });
});
            `))
        ]);
        assertJsonEqual([exitCode, exitCode2], [1, 1]);
        assertMatch(stderr, /1\. test it - bb\nundefined\b[\s\S]*2\. test it - cc\nundefined\b[\s\S]*3\. test it - dd\ndd string\b[\s\S]*4\. test it - ee\n\[object\][\s\S]*tests failed - 4\n/);
        assertOrThrow(!stderr.includes("TypeError"), stderr);
        assertMatch(stderr2, /test it failed - aa - bb\nbb string\n[\s\S]*test it failed - aa - bc\n0\n[\s\S]*tests failed - 3\n/);
    });
    jstestIt((
        "test jstestOnExit-exit-code handling-behavior"
    ), async function () {

// 256 failed tests exit 1, not their count, which an 8-bit exit status would
// wrap to a passing 0.

        const [exitCode, stderr] = await childRun({}, String(`
jslint.jstestDescribe("aa", function () {
    let ii = 0;
    while (ii < 256) {
        jslint.jstestIt(String(1000 + ii), function () {
            throw new Error();
        });
        ii += 1;
    }
});
        `));
        assertJsonEqual(exitCode, 1);
        assertMatch(stderr, /tests total {2}- 256\n {2}tests failed - 256\n/);
    });
    jstestIt((
        "test jstestOnExit-pending handling-behavior"
    ), async function () {

// A test still pending at exit counts as failed, in red, though its describe
// never prints. With nothing alive, the hang exits at once, since jstest keeps
// no timer; else <childRun>'s 10 s watchdog kills it.

        const [exitCode, stderr] = await childRun({}, String(`
jslint.jstestDescribe("aa", function () {
    jslint.jstestIt("bb", function () {
        return new Promise(jslint.noop);
    });
});
        `));
        assertJsonEqual(exitCode, 1);
        assertMatch(stderr, /\[31m {2}\S+ 1\. test it pending - aa - bb\n {2}tests total {2}- 1\n {2}tests failed - 1\n/);
        assertOrThrow(!stderr.includes("test describe - aa"), stderr);
    });
    jstestIt((
        "test jstestOnExit-unprinted handling-behavior"
    ), async function () {

// betadog's flake: bb fails before its emit, cc waits on that emit forever,
// then something ends the process. bb's error, stored in a describe that never
// prints, still shows and counts.

        const [exitCode, stderr] = await childRun({}, String(`
import {EventEmitter} from "node:events";
const ee = new EventEmitter();
jslint.jstestDescribe("aa", function () {
    jslint.jstestIt("bb", async function () {
        throw new Error("bb real error");
    });
    jslint.jstestIt("cc", function () {
        setTimeout(process.exit, 100);
        return new Promise(function (resolve) {
            ee.once("done", resolve);
        });
    });
});
        `));
        assertJsonEqual(exitCode, 1);
        assertMatch(stderr, /1\. test it failed - aa - bb\nError: bb real error\n[\s\S]*2\. test it pending - aa - cc\n {2}tests total {2}- 2\n {2}tests failed - 2\n/);
    });
    jstestIt((
        "test jstestReport-numbering handling-behavior"
    ), async function () {

// The exit report numbers on from the tests already printed, and leaves out a
// passed test whose describe never printed, here ee beside its hung sibling.

        const [exitCode, stderr] = await childRun({}, String(`
jslint.jstestDescribe("aa", function () {
    jslint.jstestIt("bb", jslint.noop);
});
jslint.jstestDescribe("cc", function () {
    jslint.jstestIt("dd", function () {
        setTimeout(process.exit, 100);
        return new Promise(jslint.noop);
    });
    jslint.jstestIt("ee", jslint.noop);
});
        `));
        assertJsonEqual(exitCode, 1);
        assertMatch(stderr, /1\. test it - bb\b[\s\S]*✘ 2\. test it pending - cc - dd\n/);
        assertOrThrow(!stderr.includes("cc - ee"), stderr);
    });
});

jstestDescribe((
    "test v8CoverageListMerge handling-behavior"
), function () {
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
        "test merge-empty-list handling-behavior"
    ), function () {
        assertJsonEqual(v8CoverageListMerge([]), {
            result: []
        });
    });
    jstestIt((
        "test merge-fixture handling-behavior"
    ), function () {
        for (const file of [
            "test_coverage_merge_is_block_coverage_test.json",
            "test_coverage_merge_issue_2_mixed_is_block_coverage_test.json",
            "test_coverage_merge_node_10_internal_errors_one_of_test.json",
            "test_coverage_merge_reduced_test.json",
            "test_coverage_merge_simple_test.json",
            "test_coverage_merge_various_test.json"
        ]) {
            for (const {expected, inputs} of testCoverageMergeData[file]) {
                assertJsonEqual(v8CoverageListMerge(inputs), expected, file);
            }
        }
    });
    jstestIt((
        "test merge-node-sqlite-files handling-behavior"
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
    jstestIt((
        "test merge-one-list handling-behavior"
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
        "test merge-two-identical-lists handling-behavior"
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
    jstestIt((
        "test merge-unshared-function handling-behavior"
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
});

jstestDescribe((
    "test v8CoverageReportCreate handling-behavior"
), function () {
    jstestIt((
        "test coverage-hole-closing-midline handling-behavior"
    ), async function () {

// Pin two branches of <v8CoverageReportCreate> that line coverage cannot see.
// A hole ending before end-of-line must close with a bare span, the
// deadcode-dispelled case, and a hole on an ignored line must render "ignore".
// Passing 0 makes each "&& ..." a hole, while the ";" after it is covered.

        const dir = ".tmp/coverage_hole/";
        const file = dir + "coverage_hole.js";
        await fsWriteFileWithParents(file, (
            "function aa(bb) {\n" +
            "    return bb && bb.cc;\n" +
            "}\n" +
            "function dd(ee) {\n" +
            "    return ee && ee.ff; //coverage-ignore-line\n" +
            "}\n" +
            "aa(0);\n" +
            "dd(0);\n"
        ));
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
        assertOrThrow((
            await moduleFs.promises.readFile(dir + file + ".html", "utf8")
        ).includes(
            "<span class=\"uncovered\">&amp;&amp; bb.cc</span><span>;</span>"
        ), "expected a hole closing mid-line in " + dir + file + ".html");
        assertOrThrow((
            await moduleFs.promises.readFile(dir + file + ".html", "utf8")
        ).includes(
            "<span class=\"ignore\">&amp;&amp; ee.ff</span><span>;"
        ), "expected an ignored hole in " + dir + file + ".html");
    });
    jstestIt((
        "test coverage-ignore handling-behavior"
    ), function () {
        switch (noop() && noop()) { //coverage-ignore-line
        case 1: //coverage-ignore-line
            break; //coverage-ignore-line
/*coverage-disable*/
        case 2:
            break;
/*coverage-enable*/
        case undefined:
            break;
        }
    });
    jstestIt((
        "test coverage-report-jslint-mjs handling-behavior"
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
        "test null-case handling-behavior"
    ), async function () {
        await assertErrorThrownAsync(function () {
            return v8CoverageReportCreate({});
        }, "invalid coverageDir");
    });
    jstestIt((
        "test report-fixture handling-behavior"
    ), async function () {
        const fixtureList = [
            [
                "v8CoverageReportCreate_high.js", (
                    "switch(0){\n" +
                    "case 0:break;\n" +
                    "}\n"
                )
            ], [
                "v8CoverageReportCreate_ignore.js", (
                    "/*coverage-ignore-file*/\n" +
                    "switch(0){\n" +
                    "case 0:break;\n" +
                    "case 1:break;//coverage-ignore-line\n" +
                    "/*coverage-disable*/\n" +
                    "case 2:break;\n" +
                    "/*coverage-enable*/\n" +
                    "}\n"
                )
            ], [
                "v8CoverageReportCreate_low.js", (
                    "switch(0){\n" +
                    "case 1:break;\n" +
                    "case 2:break;\n" +
                    "case 3:break;\n" +
                    "case 4:break;\n" +
                    "}\n"
                )
            ], [
                "v8CoverageReportCreate_medium.js", (
                    "switch(0){\n" +
                    "case 0:break;\n" +
                    "case 1:break;\n" +
                    "case 2:break;\n" +
                    "}\n"
                )
            ]
        ];
        await Promise.all(fixtureList.map(async function ([
            file, data
        ], ii) {
            const dir = ".tmp/coverage_" + ii + "/";
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
        }));
    });
});
