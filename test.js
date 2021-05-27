/*jslint node*/
import fs from "fs";
import jslint from "./jslint.js";

function assertOrThrow(passed, msg) {
/*
 * this function will throw <msg> if <passed> is falsy
 */
    if (!passed) {
        throw new Error(msg);
    }
}

function noop() {
/*
 * this function will do nothing
 */
    return;
}

(function testCaseJslintCli() {
/*
 * this function will test jslint's cli handling-behavior
 */
    process.exit = function (exitCode) {
        assertOrThrow(!exitCode, exitCode);
    };
    jslint("", {
        cli_mode: true,
        file: "jslint.js"
    });
    jslint("", {
        cli_mode: true,
        // suppress error
        console_error: noop,
        file: "syntax_error.js",
        option: {
            debug: true
        },
        source: "syntax error"
    });
    jslint("", {
        cli_mode: true,
        file: "aa.html",
        source: "<script>\nlet aa = 0;\n</script>\n"
    });
}());

(function testCaseJslintMisc() {
/*
 * this function will test jslint's misc handling-behavior
 */
    // test assertOrThrow's throw handling-behavior
    try {
        assertOrThrow(undefined, new Error());
    } catch (ignore) {}
}());

(function testCaseJslintOption() {
/*
 * this function will test jslint's option handling-behavior
 */
    assertOrThrow(jslint([""], {
        bitwise: true,
        browser: true,
        convert: true,
        couch: true,
        debug: true,
        devel: true,
        eval: true,
        for: true,
        fudge: true,
        getset: true,
        long: true,
        node: true,
        single: true,
        this: true,
        white: true
    }).warnings.length === 0);
    assertOrThrow(jslint("", {
        test_uncaught_error: true
    }).warnings.length === 1);
}());

(function testCaseJslintCodeValidate() {
/*
 * this function will validate each code is valid in jslint
 */
    Object.values({
        Array: [
            "new Array(1);"
        ],
        Date: [
            "Date.getTime();",
            "let aa = aa().getTime();",
            "let aa = aa.aa().getTime();"
        ],
        Number: [
            "let aa = 0.0e0;",
            "let aa = 0b0;",
            "let aa = 0o0;",
            "let aa = 0x0;"
        ],
        RegExp: [
            "function aa() {\n    return /./;\n}",
            "let aa = /(?!.)(?:.)(?=.)/;"
        ],
        async_await: [
            "async function aa() {\n    await aa();\n}"
        ],
        directives: [
            "#!\n/*jslint browser:false, node*/\n\"use strict\";",
            "/*jslint browser*/\n;",
            "/*jslint devel*/\ndebugger;",
            "/*jslint eval*/\nnew Function();\neval();",
            "/*jslint getset*/\nlet aa = {get aa() {\n    return;\n}};",
            "/*jslint getset*/\nlet aa = {set aa(aa) {\n    return aa;\n}};",
            "/*jslint this*/\nlet aa = this;",
            "/*jslint white*/\n\t",
            "/*property aa bb*/"
        ],
        fart: [
            "function aa() {\n    return () => 1;\n}"
        ],
        json: [
            "{\"aa\":[[],-1,null]}"
        ],
        label: [
            "function aa() {\nbb:\n    while (true) {\n        if (true) {\n"
            + "            break bb;\n        }\n    }\n}"
        ],
        loop: [
            "function aa() {\n    do {\n        aa();\n    } while (aa());\n}"
        ],
        misc: [
            ""
        ],
        module: [
            "export default Object.freeze();",
            "import {aa, bb} from \"aa\";\naa(bb);",
            "import {} from \"aa\";",
            "import(\"aa\").then(function () {\n    return;\n});"
        ],
        optional_chaining: [
            "let aa = aa?.bb?.cc;"
        ],
        property: [
            "let aa = aa[`!`];"
        ],
        ternary: [
            "let aa = (\n    aa()\n    ? 0\n    : 1\n) "
            + "&& (\n    aa()\n    ? 0\n    : 1\n);"
        ],
        var: [
            "let [...aa] = [...aa];",
            "let [\n    aa, bb = 1\n] = 0;",
            "let {aa, bb} = 0;",
            "let {\n    aa: bb\n} = 0;"
        ]
    }).forEach(function (codeList) {
        codeList.forEach(function (code) {
            let warnings;
            warnings = jslint(code).warnings;
            assertOrThrow(warnings.length === 0, [code, warnings]);
        });
    });
}());

(async function testCaseJslintWarningsValidate() {
/*
 * this function will validate each jslint <warning> is raised with given
 * malformed <code>
 */
    Object.entries({
        expected_a_at_b_c: [
            "(function(){let aa;bb:while(aa()){aa();}}());",
            "function aa(){\n bb:while(aa){aa();}}",
            "let aa=aa(\naa\n()\n);",
            "let aa={\n    aa:\n0\n};"
        ],
        expected_a_b: [
            "([])=>0",
            "(aa)=>{}",
            "(aa?0:aa)",
            "(aa?aa:0)",
            "(aa?false:true)",
            "(aa?true:false)",
            ";{",
            "`${/ /}`",
            "`${`",
            "`${{`",
            "aa.aa=undefined",
            "aa=+aa",
            "aa=/[ ]/",
            "aa=/aa{/",
            "aa=0+\"\"",
            "aa=\"\"+\"\"",
            "async",
            "delete [0]",
            "for(;;){}",
            "isFinite(0)",
            "let aa;var aa;",
            "new Array(\"\")",
            "new Date().getTime()",
            "new Object()"
        ],
        expected_a_before_b: [
            ".0",
            "/*jslint eval*/\nFunction;eval",
            "=>0",
            "\"\\u{12345\"",
            "aa=/(:)/",
            "aa=/=/",
            "aa=/?/",
            "aa=/[/",
            "let Aa=Aa()",
            "let Aa=Aa.Aa()",
            "new Aa"
        ],
        expected_identifier_a: [
            "(0)=>0",
            "aa.0",
            "aa?.0",
            "function aa(0){}",
            "function aa([aa]){}\nfunction aa([aa],[aa,aa=aa],[0]){}",
            "function aa({aa}){}\nfunction aa({aa},{aa:aa,aa=aa},{aa:0}){}",
            "function(){}",
            "import {",
            "let aa={0:0}",
            "let {0}=0",
            "let {aa:0}=0"
        ],
        expected_space_a_b: [
            "(function(){return;}());",
            "/**//**/",
            "let aa=(aa?0:1);",
            "let aa=0;"
        ],
        required_a_optional_b: [
            "function aa(aa=0,...){}",
            "function aa(aa=0,[]){}",
            "function aa(aa=0,{}){}",
            "function aa(aa=0,bb){}"
        ],
        too_long: [
            "//".repeat(100)
        ],
        unexpected_a: [
            "((0))",
            "(+0?+0:+0)()",
            "(/./)?.foo",
            "/*/",
            "/./",
            "0===(0==0)",
            "0[0][0]",
            "0|0",
            ";",
            "Function",
            "[-0x0]",
            "[0x0]",
            "\"aa\"?.bb",
            "`${/[`]/}`",
            "`${/`/}`",
            "`${\"`\"}`",
            "aa((0))",
            "aa+=NaN",
            "aa/=0",
            "aa=/[0-]/",
            "aa=/.//",
            "aa=/./z",
            "aa={aa:aa}",
            "aa={set aa(){}}",
            "arguments",
            "await",
            "debugger",
            "eval",
            "export aa",
            "export const aa=0",
            "for(aa in aa){}",
            "for(const ii=0;;){}",
            "for(ii=0;ii<0;ii++){}",
            "for(ii=0;ii<0;ii+=0){}",
            "function aa(){for(0;0;0){break;}}",
            "function aa(){try{return;}catch(ignore){}finally{return;}}",
            "function aa(){try{}catch(ignore){}finally{switch(0){case 0:}}}",
            "function aa(){while(0){continue;}}",
            "function aa(){while(0){try{0;}catch(ignore){}finally{continue;}}}",
            "function aa(){}0",
            "function aa(){}\n[]",
            "function ignore(){let ignore;}",
            "ignore",
            "ignore:",
            "import ignore from \"aa\"",
            "import {ignore} from \"aa\"",
            "let aa=[]?.bb",
            "new Date.UTC()",
            "new Function()",
            "new Symbol()",
            "switch(0){case 0:break;case 0:break}",
            "switch(0){case 0:break;default:break;}",
            "switch(0){case 0:break;default:}",
            "this",
            "try{throw 0;try{}catch(){}}catch(){}",
            "try{}finally{break;}",
            "void 0",
            "while((0)){}",
            "while(0){}",
            "{//\n}",
            "{0:0}",
            "{\"\\u{1234}\":0}",
            "{\"aa\":",
            "{\"aa\":'aa'}"
        ]
    }).forEach(function ([
        expectedWarning, malformedCodeList
    ]) {
        malformedCodeList.forEach(function (malformedCode) {
            assertOrThrow(
                jslint(malformedCode).warnings.some(function ({
                    code
                }) {
                    return code === expectedWarning;
                }),
                new Error(
                    `jslint failed to warn "${expectedWarning}" with `
                    + `malfomed code "${malformedCode}"`
                )
            );
        });
    });
    Array.from(String(
        await fs.promises.readFile("jslint.js", "utf8")
    ).matchAll(new RegExp((
        "\\s*?"
        + "(\\/\\/\\s*?cause:.*?\\n(?:\\/\\/.*?\\n)*?)"
        + "(\\s*?\\n[^\\/].*?(?:\\n\\s*?\".*?)?$)"
    ), "gm"))).forEach(function ([
        match0, causeList, warning
    ]) {
        let expectedWarningCode;
        let fnc;
        // debug match0
        console.error(match0.trim().replace((/\n\n/g), "\n"));
        assertOrThrow(
            match0.indexOf("\n\n" + causeList + "\n    ") === 0,
            JSON.stringify([
                match0, causeList
            ], undefined, 4)
        );
        warning = warning.match(
            "("
            + "expected_at"
            + "|no_space_only"
            + "|one_space_only"
            + "|one_space"
            + "|stop"
            + "|stop_at"
            + "|warn"
            + "|warn_at"
            + ")"
            + "\\\u0028\\s*?\"?"
            + "(\\S[^\n\"]+)"
        );
        if (warning) {
            expectedWarningCode = warning[2];
            fnc = warning[1];
            switch (fnc) {
            case "expected_at":
                expectedWarningCode = "expected_a_at_b_c";
                break;
            case "no_space_only":
                expectedWarningCode = "unexpected_space_a_b";
                break;
            case "one_space":
            case "one_space_only":
                expectedWarningCode = "expected_space_a_b";
                break;
            }
        }
        causeList.split(
            /\/\/\u0020cause:[\n|\u0020]/
        ).slice(1).forEach(function (cause) {
            assertOrThrow(cause === cause.trim() + "\n", JSON.stringify(cause));
            cause = (
                cause[0] === "\""
                ? JSON.parse(cause)
                : cause.replace((
                    /^\/\/\u0020/gm
                ), "")
            );
            assertOrThrow(
                jslint(cause).warnings.some(function ({
                    code
                }) {
                    return code === expectedWarningCode;
                }) || !expectedWarningCode,
                "\n" + cause.trim()
            );
        });
    });
}());
