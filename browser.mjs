// browser.mjs
// 2018-06-16
// Copyright (c) 2015 Douglas Crockford  (www.JSLint.com)

/*jslint beta, browser*/

/*property
    CodeMirror, Pos,
    bind,
    click, currentTarget,
    closest,
    debug, dispatchEvent,
    editor,
    from,
    globals, gutters,
    lint, lintOnChange,
    map, mode_stop,
    offsetWidth, onchange, onkeyup,
    performLint, preventDefault,
    registerHelper, result,
    search, setSize, severity, stopPropagation,
    target, test, to, trim,
    CodeMirror, Tab, addEventListener, checked, closure, column, context,
    create, ctrlKey, display, edition, exports, extraKeys, filter, forEach,
    fromTextArea, froms, functions, getElementById, getValue, global, id,
    indentUnit, indentWithTabs, outerHTML, isArray, join, jslint_result, json,
    key, keys, length, level, line, lineNumbers, lineWrapping, line_source,
    matchBrackets, message, metaKey, mode, module, name, names, onclick,
    parameters, parent, property, push, querySelector, querySelectorAll,
    replace, replaceSelection, role, scrollTop, setValue, showTrailingSpace,
    signature, sort, split, stack_trace, stop, style, textContent, value,
    warnings
*/

import jslint from "./jslint.mjs";

// This is the web script companion file for JSLint. It includes code for
// interacting with the browser and displaying the reports.

let editor;
let jslint_option_dict = {
    lintOnChange: false
};
let mode_debug;

function jslint_plugin_codemirror(CodeMirror) {

// This function will integrate jslint with CodeMirror's lint addon.
// Requires CodeMirror and jslint.

    CodeMirror.registerHelper("lint", "javascript", function (text, options) {
        options.result = jslint(text, options, options.globals);
        return options.result.warnings.map(function ({
            column,
            line,
            message,
            mode_stop
        }) {
            return {
                from: CodeMirror.Pos(line - 1, column - 1), //jslint-quiet
                message,
                severity: (
                    mode_stop
                    ? "error"
                    : "warning"
                ),
                to: CodeMirror.Pos(line - 1, column) //jslint-quiet
            };
        });
    });
}

function jslint_report_html({
    exports,
    froms,
    functions,
    global,
    json,
    module,
    property,
    stop,
    warnings
}) {

// This function will create html-reports for warnings, properties, and
// functions from jslint's results.
// example usage:
//  let result = jslint("console.log('hello world')");
//  let html = jslint_report_html(result);

    let html = "";
    let length_80 = 1111;

    function detail(title, list) {
        if (Array.isArray(list) && list.length > 0) {
            html += `<dt>${entityify(title)}</dt><dd>${list.join(", ")}</dd>`;
        }
    }

    function entityify(str) {

// Replace & < > with less destructive html-entities.

        return String(str).replace((
            /&/g
        ), "&amp;").replace((
            /</g
        ), "&lt;").replace((
            />/g
        ), "&gt;");
    }

// Produce the HTML Error Report.
// <cite><address>LINE_NUMBER</address>MESSAGE</cite>
// <samp>EVIDENCE</samp>

    html += `<div class="JSLINT_" id="JSLINT_REPORT_HTML">`;
    html += String(`
<style id="#JSLINT_REPORT_STYLE">
/*csslint
    box-model: false,
    ids:false,
    overqualified-elements: false
*/
/*csslint ignore:start*/
@font-face {
    font-display: swap;
    font-family: "Programma";
    font-weight: bold;
    src: url("asset-font-programma-bold.woff2") format("woff2");
}
@font-face {
    font-display: swap;
    font-family: "Daley";
    font-weight: bold;
    src: url("asset-font-daley-bold.woff2") format("woff2");
}
*,
*:after,
*:before {
    border: 0;
    box-sizing: border-box;
    margin: 0;
    padding: 0;
}
/*csslint ignore:end*/
.JSLINT_ address,
.JSLINT_ cite,
.JSLINT_ dt {
    font-family: serif;
}
.JSLINT_ dd,
.JSLINT_ dfn,
.JSLINT_ samp {
    font-family: programma, monospace;
}
.JSLINT_ textarea {
    font-family: monospace;
    font-size: 12px;
}


.JSLINT_ {
    background: antiquewhite;
}
.JSLINT_ address {
    float: right;
    font-size: 90%;
    margin-left: 16px;
}
.JSLINT_ dd {
    font-weight: bold;
    margin-left: 8em;
    padding-bottom: 2px;
}
.JSLINT_ dfn {
    display: block;
    font-style: normal;
    font-weight: bold;
    padding-bottom: 2px;
}
.JSLINT_ dl {
    background: cornsilk;
    padding: 4px 16px 0 16px;
}
.JSLINT_ dl.level0 {
    background: white;
}
.JSLINT_ dl.level1 {
    /* yellow */
    background: #ffffe0;
    margin-left: 16px;
}
.JSLINT_ dl.level2 {
    /* green */
    background: #e0ffe0;
    margin-left: 2em;
}
.JSLINT_ dl.level3 {
    /* blue */
    background: #D0D0ff;
    margin-left: 3em;
}
.JSLINT_ dl.level4 {
    /* purple */
    background: #ffe0ff;
    margin-left: 4em;
}
.JSLINT_ dl.level5 {
    /* red */
    background: #ffe0e0;
    margin-left: 5em;
}
.JSLINT_ dl.level6 {
    /* orange */
    background: #ffe390;
    margin-left: 6em;
}
.JSLINT_ dl.level7 {
    /* gray */
    background: #e0e0e0;
    margin-left: 7em;
}
.JSLINT_ dl.level8 {
    margin-left: 8em;
}
.JSLINT_ dl.level9 {
    margin-left: 9em;
}
.JSLINT_ dt {
    float: left;
    font-size: 75%;
    font-style: italic;
    text-align: right;
    width: 8em;
}
.JSLINT_ fieldset {
    background: gainsboro;
    clear: both;
    margin: 16px 40px;
    width: auto;
}
.JSLINT_ fieldset > div {
    padding: 16px;
    width: 100%;
}
.JSLINT_ legend {
    background: darkslategray;
    color: white;
    font-style: normal;
    font-weight: normal;
    padding: 0.25em 0;
    text-align: center;
    width: 100%;
}
.JSLINT_ textarea {
    padding: 0.5%;
    resize: none;
    white-space: pre;
    width: 100%;
}
.JSLINT_ textarea::selection {
    background: wheat;
}
#JSLINT_REPORT_PROPERTIES {
    background: transparent;
}
#JSLINT_REPORT_PROPERTIES textarea {
    background: honeydew;
    height: 100px;
}
#JSLINT_REPORT_WARNINGS cite {
    display: block;
    font-style: normal;
    margin-top: 16px;
    overflow-x: hidden;
}
#JSLINT_REPORT_WARNINGS cite:nth-child(1) {
    margin-top: 0;
}
#JSLINT_REPORT_WARNINGS samp {
    background: lavenderblush;
    display: block;
    font-style: normal;
    font-weight: bold;
    padding: 4px;
    white-space: pre-wrap;
}
#JSLINT_REPORT_WARNINGS > div {
    background: pink;
    max-height: 400px;
    overflow-y: auto;
}
#JSLINT_REPORT_WARNINGS > legend {
    background: indianred;
}
</style>
            `).trim();
    html += `<fieldset id="JSLINT_REPORT_WARNINGS">`;
    html += `<legend>Report: Warnings</legend>`;
    html += `<div>`;
    if (stop) {
        html += "<center>JSLint was unable to finish.</center>";
    }
    warnings.forEach(function ({
        column,
        line,
        line_source,
        message,
        stack_trace = ""
    }) {
        html += `<cite>`;
        html += `<address>${entityify(line)}.${entityify(column)}</address>`;
        html += entityify(message);
        html += `</cite>`;
        html += `<samp>${entityify(line_source + "\n" + stack_trace)}</samp>`;
    });
    if (warnings.length === 0) {
        html += "<center>There are no warnings.</center>";
    }
    html += `</div>`;
    html += `</fieldset>`;

// Produce the /*property*/ directive.

    html += `<fieldset id="JSLINT_REPORT_PROPERTIES">`;
    html += `<legend>Report: Properties</legend>`;
    html += `<textarea rows="4" readonly>`;
    html += `/\*property`;
    Object.keys(property).sort().forEach(function (key, ii) {
        if (ii !== 0) {
            html += ",";
            length_80 += 2;
        }
        if (length_80 + key.length >= 80) {
            length_80 = 4;
            html += "\n   ";
        }
        html += " " + key;
        length_80 += key.length;
    });
    html += "\n*/\n";
    html += `</textarea>`;
    html += `</fieldset>`;

// Produce the HTML Function Report.
// <dl class=LEVEL><address>LINE_NUMBER</address>FUNCTION_NAME_AND_SIGNATURE
//     <dt>DETAIL</dt><dd>NAMES</dd>
// </dl>

    html += `<fieldset id="JSLINT_REPORT_FUNCTIONS">`;
    html += `<legend>Report: Functions</legend>`;
    html += `<div>`;
    if (json) {
        return (
            warnings.length === 0
            ? "<center>JSON: good.</center>"
            : "<center>JSON: bad.</center>"
        );
    }
    if (functions.length === 0) {
        html += "<center>There are no functions.</center>";
    }
    exports = Object.keys(exports).sort();
    froms.sort();
    global = Object.keys(global.context).sort();
    module = (
        module
        ? "module"
        : "global"
    );
    if (global.length + froms.length + exports.length > 0) {
        html += "<dl class=level0>";
        detail(module, global);
        detail("import from", froms);
        detail("export", exports);
        html += "</dl>";
    }
    functions.forEach(function (the_function) {
        let {
            context,
            level,
            line,
            name,
            parameters,
            signature
        } = the_function;
        let list = Object.keys(context);
        let params;
        html += (
            "<dl class=level"
            + entityify(level)
            + "><address>"
            + entityify(line)
            + "</address><dfn>"
            + (
                name === "=>"
                ? entityify(signature) + " =>"
                : (
                    typeof name === "string"
                    ? (
                        "<b>\u00ab" + entityify(name)
                        + "\u00bb</b>"
                    )
                    : "<b>" + entityify(name.id) + "</b>"
                )
            ) + entityify(signature)
            + "</dfn>"
        );
        params = [];
        parameters.forEach(function extract({
            id,
            names
        }) {
            switch (id) {
            case "[":
            case "{":

// Recurse extract.

                names.forEach(extract);
                break;
            case "ignore":
                break;
            default:
                params.push(id);
            }
        });
        detail("parameter", params.sort());
        list.sort();
        detail("variable", list.filter(function (id) {
            return (
                context[id].role === "variable"
                && context[id].parent === the_function
            );
        }));
        detail("exception", list.filter(function (id) {
            return context[id].role === "exception";
        }));
        detail("closure", list.filter(function (id) {
            return (
                context[id].closure === true
                && context[id].parent === the_function
            );
        }));
        detail("outer", list.filter(function (id) {
            return (
                context[id].parent !== the_function
                && context[id].parent.id !== "(global)"
            );
        }));
        detail(module, list.filter(function (id) {
            return context[id].parent.id === "(global)";
        }));
        detail("label", list.filter(function (id) {
            return context[id].role === "label";
        }));
        html += "</dl>";
    });
    html += `</div>`;
    html += `</fieldset>`;
    html += `</div>`;
    return html;
}

function jslint_with_ui() {
// This function will run jslint in browser and create html-reports.

// Show ui-loader-animation.

    document.getElementById("uiLoader1").style.display = "flex";

// Execute linter.

    editor.performLint();

// Generate the reports.
// Display the reports.

    document.querySelector(
        "#JSLINT_REPORT_HTML"
    ).outerHTML = jslint_report_html(jslint_option_dict.result);

// Hide ui-loader-animation.

    setTimeout(function () {
        document.getElementById("uiLoader1").style.display = "none";
    }, 500);
}

(function () {
    let CodeMirror = window.CodeMirror;

// Init edition.

    document.getElementById("JSLINT_EDITION").textContent = (
        `Edition: ${jslint.edition}`
    );

// Init mode_debug.
    mode_debug = (
        /\bdebug=1\b/
    ).test(location.search);

// Init CodeMirror editor.

    editor = CodeMirror.fromTextArea(document.getElementById(
        "JSLINT_SOURCE"
    ), {
        extraKeys: {
            Tab: function (editor) {
                editor.replaceSelection("    ");
            }
        },
        gutters: ["CodeMirror-lint-markers"],
        indentUnit: 4,
        indentWithTabs: false,
        lineNumbers: true,
        lineWrapping: true,
        lint: jslint_option_dict,
        matchBrackets: true,
        mode: "text/javascript",
        showTrailingSpace: true
    });
    window.editor = editor;

// Init CodeMirror linter.

    jslint_plugin_codemirror(CodeMirror);

// Init event-handling.

    document.addEventListener("keydown", function (evt) {
        switch ((evt.ctrlKey || evt.metaKey) && evt.key) {
        case "Enter":
        case "e":
            evt.preventDefault();
            evt.stopPropagation();
            jslint_with_ui();
            break;
        }
    });
    document.querySelector(
        "#JSLINT_BUTTONS"
    ).onclick = function ({
        target
    }) {
        switch (target.name) {
        case "JSLint":
            jslint_with_ui();
            break;
        case "clear_options":
            document.querySelectorAll(
                "#JSLINT_OPTIONS input[type=checkbox]"
            ).forEach(function (elem) {
                elem.checked = false;
            });
            document.querySelector("#JSLINT_GLOBALS").value = "";
            document.querySelector("#JSLINT_OPTIONS").click();
            document.querySelector("#JSLINT_GLOBALS").dispatchEvent(
                new Event("keyup")
            );
            break;
        case "clear_source":
            editor.setValue("");
            break;
        }
    };
    document.querySelector(
        "#JSLINT_GLOBALS"
    ).onkeyup = function ({
        currentTarget
    }) {
        jslint_option_dict.globals = currentTarget.value.trim().split(
            /[\s,;'"]+/
        );
    };
    document.querySelector(
        "#JSLINT_OPTIONS"
    ).onclick = function ({
        target
    }) {
        let elem;
        elem = target.closest(
            "#JSLINT_OPTIONS div[title]"
        );
        elem = elem && elem.querySelector("input[type=checkbox]");
        if (elem && elem !== target) {
            elem.checked = !elem.checked;
        }
        document.querySelectorAll(
            "#JSLINT_OPTIONS input[type=checkbox]"
        ).forEach(function (elem) {
            jslint_option_dict[elem.value] = elem.checked;
        });
    };
    window.addEventListener("resize", function () {
        editor.setSize(document.querySelector(
            "#JSLINT_OPTIONS"
        ).offsetWidth);
    });
    window.addEventListener("load", function () {
        window.dispatchEvent(new Event("resize"));
    });
    if (!mode_debug) {
        editor.setValue(`#!/usr/bin/env node

/*jslint browser, node*/
/*global $, jQuery*/ //jslint-quiet

import https from "https";
import jslint from \u0022./jslint.mjs\u0022;

// Optional directives.
// .... /*jslint beta*/ .......... Enable experimental warnings.
// .... /*jslint bitwise*/ ....... Allow bitwise operators.
// .... /*jslint browser*/ ....... Assume browser environment.
// .... /*jslint convert*/ ....... Allow conversion operators.
// .... /*jslint couch*/ ......... Assume CouchDb environment.
// .... /*jslint debug*/ ......... Include jslint stack-trace in warnings.
// .... /*jslint devel*/ ......... Allow console.log() and friends.
// .... /*jslint eval*/ .......... Allow eval().
// .... /*jslint for*/ ........... Allow for-statement.
// .... /*jslint getset*/ ........ Allow get() and set().
// .... /*jslint indent2*/ ....... Allow 2-space indent.
// .... /*jslint long*/ .......... Allow long lines.
// .... /*jslint name*/ .......... Allow weird property names.
// .... /*jslint node*/ .......... Assume Node.js environment.
// .... /*jslint single*/ ........ Allow single-quote strings.
// .... /*jslint test_internal_error*/ ... Test jslint's internal-error
// ........................................... handling-ability.
// .... /*jslint this*/ .......... Allow 'this'.
// .... /*jslint unordered*/ ..... Allow unordered cases, params, properties,
// ................................... and variables.
// .... /*jslint variable*/ ...... Allow unordered const and let declarations
// ................................... that are not at top of function-scope.
// .... /*jslint white: true...... Allow messy whitespace.

/*jslint-disable*/
// TODO: jslint this code-block in future.
console.log('hello world');
/*jslint-enable*/

// Suppress warnings on next-line.
eval( //jslint-quiet
    "console.log(\\"hello world\\");"
);

(async function () {
    let result;
    result = await new Promise(function (resolve) {
        https.request("https://www.jslint.com/jslint.mjs", function (res) {
            result = "";
            res.on("data", function (chunk) {
                result += chunk;
            }).on("end", function () {
                resolve(result);
            }).setEncoding("utf8");
        }).end();
    });
    result = jslint(result);
    result.warnings.forEach(function ({
        formatted_message
    }) {
        console.error(formatted_message);
    });
}());
`);
    }
    document.querySelector("button[name='JSLint']").click();
}());
