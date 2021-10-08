/*jslint beta, node*/
import moduleFs from "fs";
import jslint from "./jslint.mjs";

let {
    assert_or_throw: assertOrThrow,
    debug_inline: debugInline
} = jslint;

function noop(val) {
/*
 * this function will do nothing except return val
 */
    return val;
}

(function testCaseFsXxx() {
/*
 * this function will test fs_xxx's handling-behavior
 */
    // test fs_rm_recursive handling-behavior
    jslint.fs_rm_recursive(".artifact/fs_rm_recursive");
    jslint.fs_rm_recursive(".artifact/fs_rm_recursive", {
        process_version: "v12"
    });
    // test fs_write_file_with_parents handling-behavior
    (async function () {
        await jslint.fs_rm_recursive(".artifact/fs_write_file_with_parents");
        await jslint.fs_write_file_with_parents(
            ".artifact/fs_write_file_with_parents/aa/bb/cc",
            "aa"
        );
    }());
}());

(function testCaseJslintCli() {
/*
 * this function will test jslint's cli handling-behavior
 */
    function processExit0(exitCode) {
        assertOrThrow(exitCode === 0, exitCode);
    }
    function processExit1(exitCode) {
        assertOrThrow(exitCode === 1, exitCode);
    }
    // test null-case handling-behavior
    jslint.jslint_cli({
        mode_noop: true,
        process_exit: processExit0
    });
    [
        ".",            // test dir handling-behavior
        "jslint.mjs",   // test file handling-behavior
        undefined       // test file-undefined handling-behavior
    ].forEach(function (file) {
        jslint.jslint_cli({
            console_error: noop,        // suppress error
            file,
            mode_cli: true,
            process_exit: processExit0
        });
    });
    // test apidoc handling-behavior
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
    // test cjs handling-behavior
    jslint.jslint_cli({
        cjs_module: {
            exports: {}
        },
        cjs_require: {},
        process_exit: processExit0
    });
    // test file-error handling-behavior
    jslint.jslint_cli({
        // suppress error
        console_error: noop,
        file: "undefined",
        mode_cli: true,
        process_exit: processExit1
    });
    // test syntax-error handling-behavior
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
    // test report handling-behavior
    jslint.jslint_cli({
        // suppress error
        console_error: noop,
        mode_cli: true,
        process_argv: [
            "node",
            "jslint.mjs",
            "jslint_report=.artifact/jslint_report.html",
            "jslint.mjs"
        ],
        process_exit: processExit0
    });
    // test report-error handling-behavior
    jslint.jslint_cli({
        // suppress error
        console_error: noop,
        mode_cli: true,
        process_argv: [
            "node",
            "jslint.mjs",
            "jslint_report=.artifact/jslint_report.html",
            "syntax-error.js"
        ],
        process_exit: processExit1,
        source: "syntax error"
    });
    // test report-json handling-behavior
    jslint.jslint_cli({
        // suppress error
        console_error: noop,
        mode_cli: true,
        process_argv: [
            "node",
            "jslint.mjs",
            "jslint_report=.artifact/jslint_report.html",
            "aa.json"
        ],
        process_exit: processExit0,
        source: "[]"
    });
    // test report-misc handling-behavior
    jslint.jslint_cli({
        // suppress error
        console_error: noop,
        mode_cli: true,
        process_argv: [
            "node",
            "jslint.mjs",
            "jslint_report=.artifact/jslint_report.html",
            "aa.js"
        ],
        process_exit: processExit1,
        source: "(aa)=>aa; function aa([aa]){}"
    });
    // test report-json-error handling-behavior
    jslint.jslint_cli({
        // suppress error
        console_error: noop,
        mode_cli: true,
        process_argv: [
            "node",
            "jslint.mjs",
            "jslint_report=.artifact/jslint_report.html",
            "aa.json"
        ],
        process_exit: processExit1,
        source: "["
    });
    // test plugin-vim handling-behavior
    jslint.jslint_cli({
        // suppress error
        console_error: noop,
        mode_cli: true,
        process_argv: [
            "node",
            "jslint.mjs",
            "jslint_plugin_vim",
            "syntax-error.js"
        ],
        process_exit: processExit1,
        source: "syntax error"
    });
}());

(function testCaseJslintCodeValidate() {
/*
 * this function will validate each code is valid in jslint
 */
    Object.values({
        array: [
            "new Array(0);"
        ],
        async_await: [
            "async function aa() {\n    await aa();\n}",
            "async function aa() {\n"
            + "    try {\n"
            + "        aa();\n"
            + "    } catch (err) {\n"
            + "        await err();\n"
            + "    }\n"
            + "}\n",
            "async function aa() {\n"
            + "    try {\n"
            + "        await aa();\n"
            + "    } catch (err) {\n"
            + "        await err();\n"
            + "    }\n"
            + "}\n"
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
        fart: [
            "function aa() {\n    return () => 0;\n}"
        ],
        jslint_disable: [
            "/*jslint-disable*/\n0\n/*jslint-enable*/"
        ],
        jslint_quiet: [
            "0 //jslint-quiet"
        ],
        json: [
            "{\"aa\":[[],-0,null]}"
        ],
        label: [
            "function aa() {\n"
            + "bb:\n"
            + "    while (true) {\n"
            + "        if (true) {\n"
            + "            break bb;\n"
            + "        }\n"
            + "    }\n"
            + "}\n"
        ],
        loop: [
            "function aa() {\n    do {\n        aa();\n    } while (aa());\n}"
        ],
        module: [
            "export default Object.freeze();",
            "import {aa, bb} from \"aa\";\naa(bb);",
            "import {} from \"aa\";",
            "import(\"aa\").then(function () {\n    return;\n});",
            "let aa = 0;\nimport(aa).then(aa).then(aa).catch(aa).finally(aa);"
        ],
        number: [
            "let aa = 0.0e0;",
            "let aa = 0b0;",
            "let aa = 0o0;",
            "let aa = 0x0;"
        ],
        optional_chaining: [
            "let aa = aa?.bb?.cc;"
        ],
        param: [
            "function aa({aa, bb}) {\n"
            + "    return {aa, bb};\n"
            + "}\n",
            "function aa({constructor}) {\n"
            + "    return {constructor};\n"
            + "}\n"
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
                "let aa = (\n    aa()\n    ? 0\n    : 1\n) "
                + "&& (\n    aa()\n    ? 0\n    : 1\n);"
            ),
            "let aa = (\n    aa()\n    ? `${0}`\n    : `${1}`\n);"
        ],
        try_catch: [
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

// PR-363 - Bugfix - add test against false-warning
// <uninitialized 'bb'> in code '/*jslint node*/\nlet {aa:bb} = {}; bb();'

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
            warnings = jslint.jslint(code, {
                beta: true
            }).warnings;
            assertOrThrow(
                warnings.length === 0,
                JSON.stringify([code, warnings])
            );
        });
    });
}());

(async function testCaseJslintOption() {
/*
 * this function will test jslint's option handling-behavior
 */
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
            "new Function();\neval();", {eval: true}, []
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
            String(
                await moduleFs.promises.readFile("jslint.mjs", "utf8")
            ).replace((
                /    /g
            ), "  "),
            {indent2: true},
            []
        ], [
            "function aa() {\n  return;\n}", {indent2: true}, []
        ], [
            "/".repeat(100), {long: true}, []
        ], [
            "let aa = aa._;", {name: true}, []
        ], [
            "require();", {node: true}, []
        ], [
            "let aa = 'aa';", {single: true}, []
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
        let elemNow = JSON.stringify([
            option_dict, source, global_list
        ]);
        // Assert list is sorted.
        assertOrThrow(elemPrv < elemNow, JSON.stringify([
            elemPrv, elemNow
        ], undefined, 4));
        elemPrv = elemNow;
        option_dict.beta = true;
        // test jslint's option handling-behavior
        assertOrThrow(
            jslint.jslint(
                source,
                option_dict,
                global_list
            ).warnings.length === 0,
            "jslint.jslint(" + JSON.stringify([
                source, option_dict, global_list
            ]) + ")"
        );
        // test jslint's directive handling-behavior
        source = (
            "/*jslint " + JSON.stringify(option_dict).slice(1, -1).replace((
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
        assertOrThrow(jslint.jslint(source).warnings.length === 0, source);
    });
    assertOrThrow(jslint.jslint("", {
        test_internal_error: true
    }).warnings.length === 1);
}());

(async function testCaseJslintWarningsValidate() {
/*
 * this function will validate each jslint <warning> is raised with given
 * malformed <code>
 */
    String(
        await moduleFs.promises.readFile("jslint.mjs", "utf8")
    ).replace((
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
            / \/\/jslint-quiet$/gm
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
        assertOrThrow(causeList === tmp, "\n" + causeList + "\n\n" + tmp);
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
}());

(function testCaseMisc() {
/*
 * this function will test misc handling-behavior
 */

    // test debugInline's handling-behavior
    debugInline();
    // test assertOrThrow's handling-behavior
    try {
        assertOrThrow(undefined, "undefined");
    } catch (ignore) {}
    try {
        assertOrThrow(undefined, new Error());
    } catch (ignore) {}
}());
