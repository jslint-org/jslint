// browser.mjs
// Original Author: Douglas Crockford (https://www.jslint.com).

// This is free and unencumbered software released into the public domain.

// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

// In jurisdictions that recognize copyright laws, the author or authors
// of this software dedicate any and all copyright interest in the
// software to the public domain. We make this dedication for the benefit
// of the public at large and to the detriment of our heirs and
// successors. We intend this dedication to be an overt act of
// relinquishment in perpetuity of all present and future rights to this
// software under copyright law.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
// OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

// For more information, please refer to <http://unlicense.org/>


/*jslint beta, browser*/

/*property
    dom_style_report_unmatched,
    indentSelection,
    slice, somethingSelected,
    CodeMirror, Pos, Tab, addEventListener, checked, click, closest, closure,
    column, context, ctrlKey, currentTarget, dispatchEvent, display, edition,
    editor, error, exports, extraKeys, filter, forEach, from, fromTextArea,
    froms, functions, global, globals, gutters, id, indentUnit, indentWithTabs,
    innerHTML, isArray, join, json, key, keys, length, level, line, lineNumbers,
    lineWrapping, line_source, lint, lintOnChange, map, matchBrackets, message,
    metaKey, mode, mode_stop, module, name, names, offsetWidth, onclick,
    onkeyup, outerHTML, parameters, parent, performLint, preventDefault,
    property, push, querySelector, querySelectorAll, registerHelper, replace,
    replaceSelection, result, reverse, role, search, setSize, setValue,
    severity, showTrailingSpace, signature, sort, split, stack_trace, stop,
    stopPropagation, style, target, test, textContent, to, trim, value,
    warnings, width
*/

import jslint from "./jslint.mjs";

// This is the web script companion file for JSLint. It includes code for
// interacting with the browser and displaying the reports.

let editor;
let jslint_option_dict = {
    lintOnChange: false
};
let mode_debug;

function dom_style_report_unmatched() {

// Debug css-style.

    let style_list = [];
    Array.from(document.querySelectorAll("style")).forEach(function (elem) {
        elem.innerHTML.replace((
            /\/\*[\S\s]*?\*\/|;|\}/g
        ), "\n").replace((
            /^([^\n\u0020@].*?)[,{:].*?$/gm
        ), function (match0, match1) {
            let ii;
            try {
                ii = document.querySelectorAll(match1).length;
            } catch (err) {
                console.error(match1 + "\n" + err); //jslint-quiet
            }
            if (ii <= 1 && !(
                /^0\u0020(?:(body\u0020>\u0020)?(?:\.button|\.readonly|\.styleColorError|\.textarea|\.uiAnimateSlide|a|base64|body|code|div|input|pre|textarea)(?:,|\u0020\{))|^[1-9]\d*?\u0020#/m
            ).test(ii + " " + match0)) {
                style_list.push(ii + " " + match0);
            }
            return "";
        });
    });
    style_list.sort().reverse().forEach(function (elem, ii, list) {
        console.error( //jslint-quiet
            "dom_style_report_unmatched " + (list.length - ii) + ". " + elem
        );
    });
}

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
        return (
            (Array.isArray(list) && list.length > 0)
            ? (
                "<div>"
                + "<dt>" + entityify(title) + "</dt>"
                + "<dd>" + list.join(", ") + "</dd>"
                + "</div>"
            )
            : ""
        );
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

    html += "<div class=\"JSLINT_\" id=\"JSLINT_REPORT_HTML\">\n";
    html += String(`
<style class="JSLINT_REPORT_STYLE">
/*csslint
    box-model: false,
    ids:false,
    overqualified-elements: false
*/
/*csslint ignore:start*/
@font-face {
    font-display: swap;
    font-family: "Daley";
    src: url(
"data:font/woff2;base64,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\
/7xoEqvL+2E8VOyCTuT/7j269Zy4jUtN+g4="
    ) format("woff2");
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

.JSLINT_ {
    font-family: daley, sans-serif;
    font-size: 14px;
    -ms-text-size-adjust: none;
    -webkit-text-size-adjust: none;
    text-size-adjust: none;
}
.JSLINT_ fieldset legend,
.JSLINT_ .center {
    font-family: daley, sans-serif;
    font-size: 14px;
    text-align: center;
}
.JSLINT_ fieldset textarea,
.JSLINT_ #JSLINT_REPORT_FUNCTIONS dt,
.JSLINT_ #JSLINT_REPORT_WARNINGS samp {
    font-size: 12px;
}
.JSLINT_ fieldset textarea,
.JSLINT_ #JSLINT_REPORT_FUNCTIONS > div {
    font-family: monospace;
}
.JSLINT_ fieldset > div {
    font-family: sans-serif;
}

body {
    background: antiquewhite;
}
.JSLINT_ fieldset {
    background: gainsboro;
    clear: both;
    margin: 16px 40px;
    width: auto;
}
.JSLINT_ fieldset address {
    float: right;
}
.JSLINT_ fieldset legend {
    background: darkslategray;
    color: white;
    padding: 4px 0;
    width: 100%;
}
.JSLINT_ fieldset textarea {
    padding: 4px;
    resize: none;
    white-space: pre;
    width: 100%;
}
.JSLINT_ fieldset textarea::selection {
    background: wheat;
}
.JSLINT_ fieldset > div {
    padding: 16px;
    width: 100%;
    word-wrap: break-word;
}
.JSLINT_ #JSLINT_REPORT_FUNCTIONS dl {
    background: cornsilk;
    padding: 8px 16px;
}
.JSLINT_ #JSLINT_REPORT_FUNCTIONS dl.level0 {
    background: white;
}
.JSLINT_ #JSLINT_REPORT_FUNCTIONS dl.level1 {
    /* yellow */
    background: #ffffe0;
    margin-left: 16px;
}
.JSLINT_ #JSLINT_REPORT_FUNCTIONS dl.level2 {
    /* green */
    background: #e0ffe0;
    margin-left: 32px;
}
.JSLINT_ #JSLINT_REPORT_FUNCTIONS dl.level3 {
    /* blue */
    background: #D0D0ff;
    margin-left: 48px;
}
.JSLINT_ #JSLINT_REPORT_FUNCTIONS dl.level4 {
    /* purple */
    background: #ffe0ff;
    margin-left: 64px;
}
.JSLINT_ #JSLINT_REPORT_FUNCTIONS dl.level5 {
    /* red */
    background: #ffe0e0;
    margin-left: 80px;
}
.JSLINT_ #JSLINT_REPORT_FUNCTIONS dl.level6 {
    /* orange */
    background: #ffe390;
    margin-left: 96px;
}
.JSLINT_ #JSLINT_REPORT_FUNCTIONS dl.level7 {
    /* gray */
    background: #e0e0e0;
    margin-left: 112px;
}
.JSLINT_ #JSLINT_REPORT_FUNCTIONS dl.level8 {
    margin-left: 128px;
}
.JSLINT_ #JSLINT_REPORT_FUNCTIONS dl.level9 {
    margin-left: 144px;
}
.JSLINT_ #JSLINT_REPORT_FUNCTIONS dl dd {
    line-height: 20px;
    padding-left: 120px;
}
.JSLINT_ #JSLINT_REPORT_FUNCTIONS dl dfn {
    display: block;
    font-style: normal;
    font-weight: bold;
    line-height: 20px;
}
.JSLINT_ #JSLINT_REPORT_FUNCTIONS dl div {
    position: relative
}
.JSLINT_ #JSLINT_REPORT_FUNCTIONS dl dt {
    font-style: italic;
    line-height: 20px;
    position: absolute;
    text-align: right;
    width: 100px;
}
.JSLINT_ #JSLINT_REPORT_PROPERTIES {
    background: transparent;
}
.JSLINT_ #JSLINT_REPORT_PROPERTIES textarea {
    background: honeydew;
    height: 100px;
}
.JSLINT_ #JSLINT_REPORT_WARNINGS cite {
    display: block;
    margin: 16px 0 4px 0;
    overflow-x: hidden;
    white-space: pre-line;
}
.JSLINT_ #JSLINT_REPORT_WARNINGS cite:nth-child(1) {
    margin-top: 0;
}
.JSLINT_ #JSLINT_REPORT_WARNINGS samp {
    background: lavenderblush;
    display: block;
    padding: 4px;
    white-space: pre-wrap;
}
.JSLINT_ #JSLINT_REPORT_WARNINGS > div {
    background: pink;
    max-height: 400px;
    overflow-y: auto;
}
.JSLINT_ #JSLINT_REPORT_WARNINGS > legend {
/* Google Lighthouse Accessibility - Background and foreground colors do not */
/* have a sufficient contrast ratio. */
    /* background: indianred; */
    background: #b44;
}
</style>
            `).trim();
    html += "<fieldset id=\"JSLINT_REPORT_WARNINGS\">\n";
    html += "<legend>Report: Warnings</legend>\n";
    html += "<div>\n";
    if (stop) {
        html += "<div class=\"center\">JSLint was unable to finish.</div>\n";
    }
    warnings.forEach(function ({
        column,
        line,
        line_source,
        message,
        stack_trace = ""
    }, ii) {
        html += (
            "<cite>"
            + "<address>" + entityify(line + ": " + column) + "</address>"
            + entityify((ii + 1) + ". " + message)
            + "</cite>"
            + "<samp>"
            + entityify(line_source.slice(0, 400) + "\n" + stack_trace)
            + "</samp>\n"
        );
    });
    if (warnings.length === 0) {
        html += "<div class=\"center\">There are no warnings.</div>\n";
    }
    html += "</div>\n";
    html += "</fieldset>\n";

// Produce the /*property*/ directive.

    html += "<fieldset id=\"JSLINT_REPORT_PROPERTIES\">\n";
    html += "<legend>Report: Properties</legend>\n";
    html += "<label>\n";
    html += "<textarea readonly>";
    html += "/*property";
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
    html += "</textarea>\n";
    html += "</label>\n";
    html += "</fieldset>\n";

// Produce the HTML Function Report.
// <dl class=LEVEL><address>LINE_NUMBER</address>FUNCTION_NAME_AND_SIGNATURE
//     <dt>DETAIL</dt><dd>NAMES</dd>
// </dl>

    html += "<fieldset id=\"JSLINT_REPORT_FUNCTIONS\">\n";
    html += "<legend>Report: Functions</legend>\n";
    html += "<div>\n";
    if (json) {

// Bugfix - fix website crashing when linting pure json-object.
// return (

        html += (
            warnings.length === 0
            ? "<div class=\"center\">JSON: good.</div>\n"
            : "<div class=\"center\">JSON: bad.</div>\n"
        );
    } else if (functions.length === 0) {
        html += "<div class=\"center\">There are no functions.</div>\n";
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
        html += "<dl class=level0>\n";
        html += detail(module, global);
        html += detail("import from", froms);
        html += detail("export", exports);
        html += "</dl>\n";
    }
    functions.forEach(function (the_function) {
        let {
            context,
            level,
            line,
            name,

// Bugfix - fix html-report from crashing if parameters is undefined.

            parameters = [],
            signature
        } = the_function;
        let list = Object.keys(context);
        let params;
        html += (
            "<dl class=level" + entityify(level) + ">"
            + "<address>" + entityify(line) + "</address>"
            + "<dfn>"
            + (
                name === "=>"
                ? entityify(signature) + " =>"
                : (
                    typeof name === "string"
                    ? "\u00ab" + entityify(name) + "\u00bb"
                    : entityify(name.id)
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
        html += detail("parameter", params.sort());
        list.sort();
        html += detail("variable", list.filter(function (id) {
            return (
                context[id].role === "variable"
                && context[id].parent === the_function
            );
        }));
        html += detail("exception", list.filter(function (id) {
            return context[id].role === "exception";
        }));
        html += detail("closure", list.filter(function (id) {
            return (
                context[id].closure === true
                && context[id].parent === the_function
            );
        }));
        html += detail("outer", list.filter(function (id) {
            return (
                context[id].parent !== the_function
                && context[id].parent.id !== "(global)"
            );
        }));
        html += detail(module, list.filter(function (id) {
            return context[id].parent.id === "(global)";
        }));
        html += detail("label", list.filter(function (id) {
            return context[id].role === "label";
        }));
        html += "</dl>\n";
    });
    html += "</div>\n";
    html += "</fieldset>\n";
    html += String(`
<script>
/*jslint browser*/
(function () {
    "use strict";
    function jslint_ui_onresize() {
        let width = document.querySelector(
            "#JSLINT_REPORT_PROPERTIES"
        ).offsetWidth;
        document.querySelectorAll(
            ".JSLINT_ fieldset > div"
        ).forEach(function (elem) {
            if (!elem.closest("#JSLINT_REPORT_PROPERTIES")) {
                elem.style.width = width + "px";
            }
        });
    }
    window.onload = jslint_ui_onresize;
    window.onresize = jslint_ui_onresize;
}());
</script>
    `).trim();
    html += "</div>\n";
    return html;
}

async function jslint_ui_call() {
// This function will run jslint in browser and create html-reports.

// Show ui-loader-animation.

    document.querySelector("#uiLoader1 > div").textContent = "Linting";
    document.querySelector("#uiLoader1").style.display = "flex";
    try {

// Wait awhile before running cpu-intensive linter so ui-loader doesn't jank.

        await new Promise(function (resolve) {
            setTimeout(resolve);
        });

// Update jslint_option_dict from ui-inputs.

        document.querySelectorAll(
            "#JSLINT_OPTIONS input[type=checkbox]"
        ).forEach(function (elem) {
            jslint_option_dict[elem.value] = elem.checked;
        });

// Execute linter.

        editor.performLint();

// Generate the reports.
// Display the reports.

        document.querySelector(
            "#JSLINT_REPORT_HTML"
        ).outerHTML = jslint_report_html(jslint_option_dict.result);
        jslint_ui_onresize();
    } catch (err) {
        console.error(err); //jslint-quiet
    }

// Hide ui-loader-animation.

    setTimeout(function () {
        document.querySelector("#uiLoader1").style.display = "none";
    }, 500);
}

function jslint_ui_onresize() {
    let content_width = document.querySelector(
        "#JSLINT_OPTIONS"
    ).offsetWidth;

// Set explicit content-width for overflow to work properly.

    document.querySelectorAll(
        ".JSLINT_ fieldset > div"
    ).forEach(function (elem) {
        if (!elem.closest("#JSLINT_OPTIONS")) {
            elem.style.width = content_width + "px";
        }
    });
    editor.setSize(content_width);
}

(function () {
    let CodeMirror = window.CodeMirror;

// Init edition.

    document.querySelector("#JSLINT_EDITION").textContent = (
        "Edition: " + jslint.edition
    );

// Init mode_debug.
    mode_debug = (
        /\bdebug=1\b/
    ).test(location.search);

// Init CodeMirror editor.

    editor = CodeMirror.fromTextArea(document.querySelector(
        "#JSLINT_SOURCE textarea"
    ), {
        extraKeys: {
            "Shift-Tab": "indentLess",
            Tab: function (cm) {
                if (cm.somethingSelected()) {
                    cm.indentSelection("add");
                    return;
                }
                cm.replaceSelection("    ");
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
            jslint_ui_call();
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
            jslint_ui_call();
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
        case "toggle_all_options":
            document.querySelectorAll(
                "#JSLINT_OPTIONS input[type=checkbox]"
            ).forEach(function (elem) {
                if (elem.checked) {
                    elem.checked = false;
                } else {
                    elem.checked = true;
                }
            });
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
    ).onclick = function (evt) {
        let elem;
        elem = evt.target.closest(
            "#JSLINT_OPTIONS div[title]"
        );
        elem = elem && elem.querySelector("input[type=checkbox]");
        if (elem && elem !== evt.target) {
            evt.preventDefault();
            evt.stopPropagation();
            elem.checked = !elem.checked;
        }
    };
    window.addEventListener("load", jslint_ui_onresize);
    window.addEventListener("resize", jslint_ui_onresize);
    if (!mode_debug) {
        editor.setValue(String(`
#!/usr/bin/env node

/*jslint browser, node*/
/*global caches, indexedDb*/ //jslint-quiet

import https from "https";
import jslint from \u0022./jslint.mjs\u0022;

/*jslint-disable*/
    Syntax error.\u0020\u0020\u0020\u0020
/*jslint-enable*/

eval("console.log(\\"hello world\\");"); //jslint-quiet

// Optional directives.
// .... /*jslint beta*/ .......... Enable experimental warnings.
// .... /*jslint bitwise*/ ....... Allow bitwise operators.
// .... /*jslint browser*/ ....... Assume browser environment.
// .... /*jslint convert*/ ....... Allow conversion operators.
// .... /*jslint debug*/ ......... Include jslint stack-trace in warnings.
// .... /*jslint devel*/ ......... Allow console.log() and friends.
// .... /*jslint for*/ ........... Allow for-statement.
// .... /*jslint getset*/ ........ Allow get() and set().
// .... /*jslint indent2*/ ....... Use 2-space indent.
// .... /*jslint long*/ .......... Allow long lines.
// .... /*jslint name*/ .......... Allow weird property names.
// .... /*jslint node*/ .......... Assume Node.js environment.
// .... /*jslint single*/ ........ Allow single-quote strings.
// .... /*jslint this*/ .......... Allow 'this'.
// .... /*jslint unordered*/ ..... Allow unordered cases, params, properties,
// ................................... and variables.
// .... /*jslint variable*/ ...... Allow unordered const and let declarations
// ................................... that are not at top of function-scope.
// .... /*jslint white: true...... Allow messy whitespace.

(async function () {
    let result = await new Promise(function (resolve) {
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
        `).trim());
    }
    if (mode_debug) {
        document.querySelector(
            "#JSLINT_OPTIONS input[value=debug]"
        ).click();
    }
    document.querySelector("button[name='JSLint']").click();

// Debug css-style.

    window.dom_style_report_unmatched = dom_style_report_unmatched;
}());
