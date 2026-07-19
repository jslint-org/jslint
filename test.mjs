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
                    "const {expr}",
                    "let {expr}",
                    "let [aa, bb, cc, dd, ee, ff, gg] = 0;\n{expr}"
                ].map(function (source) {
                    source = source.trim().replace("{expr}", String(`
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
                    `).trim());
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
/*jslint for*/
function aa(bb) {
    for (bb = 0; bb < 0; bb += 1) {
        bb();
    }
    for (const bb in bb) { //jslint-ignore-line
        bb();
    }
    for (const bb of bb) { //jslint-ignore-line
        bb();
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
                "0 //jslint-ignore-line"
            ],
            json: [
                "{\"aa\":[[],-0,null]}"
            ],
            label: [
                (`
function aa() {
bb:
    while (true) {
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
                "String([].at());"
            ],
            logical_assignment: [
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
                "String().aa?.bb?.cc();"
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
                `String(/(?ims-ims:.)/);`,
                `String(/./dgimsuvy);`,
                `String(/[\\--\\-]/);`,
                `function aa() {\n    return /./;\n}\naa();`
            ],
            scope: [
                "(function aa(bb = aa) {\n    aa(bb);\n}());",
                "function aa(bb = aa) {\n    aa(bb);\n}\naa();",
                //!! (`
//!! if (String) {
    //!! let aa = 0;
    //!! aa();
//!! } else {
    //!! let aa = 0;
    //!! aa();
//!! }
                //!! `),
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
), function testBehaviorJslintOption() {
    let elemPrv = "";
    [
        [{bitwise: true}, "String(String | 0);"],
        [{browser: true}, ";\nString(new XMLHttpRequest());"],
        [{convert: true}, "String(\"aa\" + 0);"],
        [{couch: true}, "registerType();"],
        [{devel: true}, "debugger;"],

// PR-404 - Alias "evil" to jslint-directive "eval" for backwards-compat.

        [{eval: true, evil: true}, "new Function();\neval();"],
        [
            {for: true},
            (`
function aa(aa) {
    for (aa = 0; aa < 0; aa += 1) {
        aa();
    }
}
aa();
            `)
        ],
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
    ].forEach(function ([
        option_dict, source
    ]) {
        source = source.trim();
        jstestIt((
            `test option=${JSON.stringify(option_dict)} handling-behavior`
        ), function () {
            let elemNow = JSON.stringify([
                option_dict, source
            ]);
            let warningsLength = (
                option_dict.test_internal_error
                ? 1
                : 0
            );
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
            [
                jslint.jslint,
                jslintCjs.jslint
            ].forEach(function (jslint) {
                // test jslint's option handling-behavior
                let warnings;
                warnings = jslint(
                    source,
                    option_dict
                ).warnings;
                assertOrThrow(
                    warnings.length === warningsLength,
                    `\n\n${source}\n\n${JSON.stringify(warnings, undefined, 4)}`
                );
                // test jslint's directive handling-behavior
                source = (
                    "/*jslint "
                    + JSON
                        .stringify(option_dict)
                        .slice(1, -1)
                        .replace((/"/g), "")
                    + "*/\n"
                    + source.replace((/^#!/), "//")
                );
                warnings = jslint(source).warnings;
                assertOrThrow(
                    warnings.length === warningsLength,
                    `\n\n${source}\n\n${JSON.stringify(warnings, undefined, 4)}`
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
                + "case 1:break;//coverage-ignore-line\n"
                + "/*coverage-disable*/\n"
                + "case 2:break;\n"
                + "/*coverage-enable*/\n"
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
