// browser.js
// 2018-06-16
// Copyright (c) 2015 Douglas Crockford  (www.JSLint.com)

/*jslint
    beta
    browser
*/

/*property
    click,
    CodeMirror, Tab, addEventListener, checked, closure, column, context,
    create, ctrlKey, display, edition, exports, extraKeys, filter, forEach,
    fromTextArea, froms, functions, getElementById, getValue, global, id,
    indentUnit, indentWithTabs, innerHTML, isArray, join, jslint_result, json,
    key, keys, length, level, line, lineNumbers, lineWrapping, line_source,
    matchBrackets, message, metaKey, mode, module, name, names, onclick,
    parameters, parent, property, push, querySelector, querySelectorAll,
    replace, replaceSelection, role, scrollTop, setValue, showTrailingSpace,
    signature, sort, split, stack_trace, stop, style, textContent, title, value,
    warnings
*/

import jslint from "./jslint.js?cc=ni7i";

// This is the web script companion file for JSLint. It includes code for
// interacting with the browser and displaying the reports.

let editor;

function entityify(string) {

// Replace & < > with less destructive entities.

    return String(string).replace((
        /&/g
    ), "&amp;").replace((
        /</g
    ), "&lt;").replace((
        />/g
    ), "&gt;");
}

function error_report(data) {

// Produce the HTML Error Report.

// <cite><address>LINE_NUMBER</address>MESSAGE</cite>
// <samp>EVIDENCE</samp>

    let output = [];
    if (data.stop) {
        output.push("<center>JSLint was unable to finish.</center>");
    }
    data.warnings.forEach(function ({
        column,
        line,
        line_source,
        message,
        stack_trace = ""
    }) {
        output.push(
            "<cite><address>",
            entityify(line),
            ".",
            entityify(column),
            "</address>",
            entityify(message),
            "</cite><samp>",
            entityify(line_source + "\n" + stack_trace),
            "</samp>"
        );
    });
    if (output.length === 0) {
        output.push("<center>There are no warnings.</center>");
    }
    return output.join("");
}

function function_report(data) {

// Produce the HTML Function Report.

// <dl class=LEVEL><address>LINE_NUMBER</address>FUNCTION_NAME_AND_SIGNATURE
//     <dt>DETAIL</dt><dd>NAMES</dd>
// </dl>

    let exports;
    let froms;
    let global;
    let mode = (
        data.module
        ? "module"
        : "global"
    );
    let output = [];

    if (data.json) {
        return (
            data.warnings.length === 0
            ? "<center>JSON: good.</center>"
            : "<center>JSON: bad.</center>"
        );
    }

    function detail(title, array) {
        if (Array.isArray(array) && array.length > 0) {
            output.push(
                "<dt>",
                entityify(title),
                "</dt><dd>",
                array.join(", "),
                "</dd>"
            );
        }
    }

    if (data.functions.length === 0) {
        output.push("<center>There are no functions.</center>");
    }
    global = Object.keys(data.global.context).sort();
    froms = data.froms.sort();
    exports = Object.keys(data.exports).sort();
    if (global.length + froms.length + exports.length > 0) {
        output.push("<dl class=level0>");
        detail(mode, global);
        detail("import from", froms);
        detail("export", exports);
        output.push("</dl>");
    }

    if (data.functions.length > 0) {
        data.functions.forEach(function (the_function) {
            let context = the_function.context;
            let list = Object.keys(context);
            let params;
            output.push(
                "<dl class=level",
                entityify(the_function.level),
                "><address>",
                entityify(the_function.line),
                "</address><dfn>",
                (
                    the_function.name === "=>"
                    ? entityify(the_function.signature) + " =>"
                    : (
                        typeof the_function.name === "string"
                        ? (
                            "<b>\u00ab" + entityify(the_function.name)
                            + "\u00bb</b>"
                        )
                        : "<b>" + entityify(the_function.name.id) + "</b>"
                    )
                ) + entityify(the_function.signature),
                "</dfn>"
            );
            if (Array.isArray(the_function.parameters)) {
                params = [];
                the_function.parameters.forEach(function extract(name) {
                    if (name.id === "{" || name.id === "[") {
                        name.names.forEach(extract);
                    } else {
                        if (name.id !== "ignore") {
                            params.push(name.id);
                        }
                    }
                });
                detail(
                    "parameter",
                    params.sort()
                );
            }
            list.sort();
            detail("variable", list.filter(function (id) {
                let the_variable = context[id];
                return (
                    the_variable.role === "variable"
                    && the_variable.parent === the_function
                );
            }));
            detail("exception", list.filter(function (id) {
                return context[id].role === "exception";
            }));
            detail("closure", list.filter(function (id) {
                let the_variable = context[id];
                return (
                    the_variable.closure === true
                    && the_variable.parent === the_function
                );
            }));
            detail("outer", list.filter(function (id) {
                let the_variable = context[id];
                return (
                    the_variable.parent !== the_function
                    && the_variable.parent.id !== "(global)"
                );
            }));
            detail(mode, list.filter(function (id) {
                return context[id].parent.id === "(global)";
            }));
            detail("label", list.filter(function (id) {
                return context[id].role === "label";
            }));
            output.push("</dl>");
        });
    }
    return output.join("");
}

function property_directive(data) {

// Produce the /*property*/ directive.

    let length = 1111;
    let not_first = false;
    let output = ["/*property"];
    let properties = Object.keys(data.property);

    properties.sort().forEach(function (key) {
        if (not_first) {
            output.push(",");
            length += 2;
        }
        not_first = true;
        if (length + key.length >= 80) {
            length = 4;
            output.push("\n   ");
        }
        output.push(" ", key);
        length += key.length;
    });
    output.push("\n*/\n");
    return output.join("");
}

function call_jslint() {
    let global_string;
    let option;
    let result;

// Show ui-loader-animation.

    document.getElementById("uiLoader1").style.display = "flex";

// First build the option object.

    option = Object.create(null);
    document.querySelectorAll("input[type=checkbox]").forEach(function (elem) {
        if (elem.checked) {
            option[elem.title] = true;
        }
    });

// Call JSLint with the source text, the options, and the predefined globals.

    global_string = document.getElementById("JSLINT_GLOBAL").value;
    result = jslint(
        editor.getValue(),
        option,
        (
            global_string === ""
            ? undefined
            : global_string.split(
                /[\s,;'"]+/
            )
        )
    );

// Debug result.

    globalThis.jslint_result = result;

// Generate the reports.
// Display the reports.

    document.getElementById(
        "JSLINT_WARNINGS_LIST"
    ).innerHTML = error_report(result);
    document.getElementById(
        "JSLINT_REPORT_LIST"
    ).innerHTML = function_report(result);
    document.getElementById(
        "JSLINT_PROPERTY"
    ).value = property_directive(result);
    document.getElementById("JSLINT_PROPERTY").scrollTop = 0;

// Hide ui-loader-animation.

    setTimeout(function () {
        document.getElementById("uiLoader1").style.display = "none";
    }, 500);
}

(function () {

// Init edition.

    document.getElementById("JSLINT_EDITION").textContent = (
        `Edition: ${jslint.edition}`
    );

// Init event-handling.

    document.addEventListener("keydown", function (evt) {
        if ((evt.ctrlKey || evt.metaKey) && evt.key === "Enter") {
            call_jslint();
        }
    });
    document.querySelector("button[name='JSLint']").onclick = call_jslint;
    document.querySelector(
        "button[name='clear_source']"
    ).onclick = function () {
        editor.setValue("");
    };
    document.querySelector(
        "button[name='clear_options']"
    ).onclick = function () {
        document.querySelectorAll(
            "input[type=checkbox]"
        ).forEach(function (elem) {
            elem.checked = false;
        });
        document.getElementById("JSLINT_GLOBAL").value = "";
    };

// Init CodeMirror editor.

    editor = globalThis.CodeMirror.fromTextArea(document.getElementById(
        "JSLINT_SOURCE"
    ), {
        extraKeys: {
            Tab: function (editor) {
                editor.replaceSelection("    ");
            }
        },
        indentUnit: 4,
        indentWithTabs: false,
        lineNumbers: true,
        lineWrapping: true,
        matchBrackets: true,
        mode: "text/javascript",
        showTrailingSpace: true
    });
    editor.setValue(`#!/usr/bin/env node

/*jslint beta node*/

import jslint from \u0022./jslint.mjs\u0022;
import https from "https";

// Optional directives.
// .... /*jslint beta*/ .......... Enable extra warnings currently in beta.
// .... /*jslint bitwise*/ ....... Allow bitwise operators.
// .... /*jslint browser*/ ....... Assume browser environment.
// .... /*jslint convert*/ ....... Allow conversion operators.
// .... /*jslint couch*/ ......... Assume CouchDb environment.
// .... /*jslint debug*/ ......... Include jslint stack-trace in warnings.
// .... /*jslint devel*/ ......... Allow console.log() and friends.
// .... /*jslint eval*/ .......... Allow eval().
// .... /*jslint for*/ ........... Allow for-statement.
// .... /*jslint getset*/ ........ Allow get() and set().
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
    "console.log('hello world');"
);

(async function () {
    let result;
    result = await new Promise(function (resolve) {
        https.request("https://www.jslint.com/jslint.js", function (res) {
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
    document.querySelector("button[name='JSLint']").click();
}());
