/*jslint node*/
import jslint from "./jslint.js";

function assertOrThrow(passed, err) {
/*
 * this function will throw <err> if <passed> is falsy
 */
    if (!passed) {
        throw err;
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

(function testCaseJslintWarningsValidate() {
/*
 * this function will validate each jslint <warning> is raised with given
 * malformed <code>
 */
    Object.entries({
        and: [
            "aa && aa || aa"
        ],
        bad_assignment_a: [
            "/*jslint for*/\nfunction aa(){for (0 in aa){}}",
            "0=0",
            "const aa=0;for(aa in aa){}"
        ],
        bad_directive_a: [
            "/*jslint !*/"
        ],
        bad_get: [
            "/*jslint getset*/\naa={get aa(aa){}}"
        ],
        bad_module_name_a: [
            "import aa from \"!aa\""
        ],
        bad_option_a: [
            "/*global aa:true*/",
            "/*jslint undefined*/"
        ],
        bad_property_a: [
            "aa._",
            "{\"__proto__\":0}"
        ],
        bad_set: [
            "/*jslint getset*/\naa={set aa(){}}"
        ],
        duplicate_a: [
            "aa={\"aa\":0,\"aa\":0}",
            "let aa;export {aa,aa}",
            "{\"aa\":0,\"aa\":0}"
        ],
        empty_block: [
            "function aa(){}"
        ],
        escape_mega: [],
        expected_a: [],
        expected_a_at_b_c: [
            "(function(){let aa;bb:while(aa()){aa();}}());",
            "function aa(){\n bb:while(aa){aa();}}",
            "let aa=aa(\naa\n()\n);",
            "let aa={\n    aa:\n0\n};"
        ],
        expected_a_b: [
            "!!aa",
            "([])=>0",
            "(aa)=>{}",
            "(aa?0:aa)",
            "(aa?aa:0)",
            "(aa?false:true)",
            "(aa?true:false)",
            "/=0",
            "0!=0",
            "0==0",
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
        expected_a_b_from_c_d: [
            "{\"aa\":0"
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
        expected_a_next_at_b: [],
        expected_digits_after_a: [
            "0x"
        ],
        expected_four_digits: [
            "\"\\u0\""
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
        expected_line_break_a_b: [
            "function aa(){bb:while(aa){aa();}}"
        ],
        expected_regexp_factor_a: [
            "/ /"
        ],
        expected_space_a_b: [
            "(function(){return;}());",
            "/**//**/",
            "let aa=(aa?1:2);",
            "let aa=0;"
        ],
        expected_statements_a: [],
        expected_string_a: [
            "import(aa).then(aa)",
            "typeof 0===0"
        ],
        expected_type_string_a: [
            "typeof 0===\"aa\""
        ],
        freeze_exports: [
            "export default Object.aa()",
            "export function aa(){}"
        ],
        function_in_loop: [
            "function aa(){while(0){aa.map(()=>0);}}",
            "function aa(){while(0){aa.map(function(){});}}"
        ],
        infix_in: [
            "aa in aa"
        ],
        label_a: [
            "aa:while(0){aa;}"
        ],
        misplaced_a: [
            "if(0){import aa from \"aa\";}"
        ],
        misplaced_directive_a: [
            "let aa;\n/*global aa*/"
        ],
        missing_await_statement: [
            "async function aa(){}"
        ],
        missing_browser: [
            "/*global aa*/"
        ],
        missing_m: [
            "aa=/$^/"
        ],
        naked_block: [],
        nested_comment: [
            "/*/*",
            "/*/**/"
        ],
        not_label_a: [
            "aa:{break aa;}"
        ],
        number_isNaN: [
            "NaN===NaN",
            "isNaN(0)"
        ],
        out_of_scope_a: [
            "aa:{function aa(aa){break aa;}}",
            "function aa(){bb();}\nfunction bb(){}"
        ],
        redefinition_a_b: [
            "let aa;let aa"
        ],
        required_a_optional_b: [
            "function aa(aa=0,...){}",
            "function aa(aa=0,[]){}",
            "function aa(aa=0,{}){}",
            "function aa(aa=1,bb){}"
        ],
        reserved_a: [
            "let undefined"
        ],
        subscript_a: [
            "aa[`aa`]"
        ],
        todo_comment: [
            "// todo"
        ],
        too_long: [
            "//".repeat(100)
        ],
        too_many_digits: [
            "\"\\u{123456}\""
        ],
        unclosed_comment: [
            "/*"
        ],
        unclosed_mega: [
            "`aa"
        ],
        unclosed_string: [
            "\"\\",
            "\"aa"
        ],
        undeclared_a: [
            "aa"
        ],
        unexpected_a: [
            "((0))",
            "(+0?+0:+0)()",
            "(/./)?.foo",
            "/*/",
            "/_/",
            "0 instanceof 0",
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
            "aa=/_//",
            "aa=/_/z",
            "aa=aa++",
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
            "this",
            "try{}finally{break;}",
            "void 0",
            "while((0)){}",
            "while(0){}",
            "yield /_/",
            "{//\n}",
            "{0:0}",
            "{\"\\u{1234}\":0}",
            "{\"aa\":",
            "{\"aa\":'aa'}"
        ],
        unexpected_a_after_b: [
            "0a"
        ],
        unexpected_a_before_b: [
            "aa=\"\\a\""
        ],
        unexpected_at_top_level_a: [],
        unexpected_char_a: [
            "#"
        ],
        unexpected_comment: [
            "`${//}`"
        ],
        unexpected_directive_a: [
            "/*global aa*/\nimport aa from \"aa\""
        ],
        unexpected_expression_a: [
            "+[]",
            "+new aa()",
            "aa++",
            "typeof 0===typeof 0"
        ],
        unexpected_label_a: [
            "aa:aa"
        ],
        unexpected_parens: [
            "aa=(function(){})"
        ],
        unexpected_space_a_b: [
            "let aa=( 0 );",
            "let aa=aa(\n) ( );"
        ],
        unexpected_statement_a: [],
        unexpected_trailing_space: [],
        unexpected_typeof_a: [
            "typeof aa===\"undefined\""
        ],
        uninitialized_a: [
            "/*jslint node*/\nlet aa;aa();"
        ],
        unordered_param_a: [
            "function aa({bb,aa}){}",
            "let{bb,aa}=0"
        ],
        unordered_property_a: [
            "aa={bb,aa}"
        ],
        unreachable_a: [
            "function aa(){while(0){break;0;}}"
        ],
        unregistered_property_a: [
            "/*property aa*/\naa.bb"
        ],
        unsafe: [],
        unused_a: [
            "/*jslint node*/\nlet aa;",
            "function aa(aa){return;}"
        ],
        use_double: [
            "''"
        ],
        use_open: [
            "0?0:0",
            "aa=0?0:0"
        ],
        use_spaces: [
            "\t"
        ],
        var_loop: [
            "function aa(){while(0){var aa;}}"
        ],
        var_switch: [
            "function aa(){switch(0){case 0:var aa;}}"
        ],
        weird_condition_a: [
            "let aa=0&&0",
            "let aa=0||0",
            "let aa=``&&``"
        ],
        weird_expression_a: [
            "aa=RegExp.aa",
            "aa=RegExp[0]",
            "aa[[0]]",
            "self=self[0]",
            "window=window[0]"
        ],
        weird_loop: [
            "function aa(){do {break;}while(0);}",
            "function aa(){while(0){break;}}"
        ],
        weird_relation_a: [
            "if(0===0){0;}"
        ],
        wrap_condition: [
            "(aa&&!aa?0:1)"
        ],
        wrap_immediate: [
            "aa=function(){}()"
        ],
        wrap_parameter: [
            "aa=>0"
        ],
        wrap_regexp: [
            "!/_/"
        ],
        wrap_unary: [
            "0 - -0"
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
                    `jslint failed to warn "${expectedWarning}" with ` +
                    `malfomed code "${malformedCode}"`
                )
            );
        });
    });
}());
