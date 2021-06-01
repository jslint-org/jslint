// browser.js
// 2018-06-16
// Copyright (c) 2015 Douglas Crockford  (www.JSLint.com)

/*jslint
    browser
*/

/*property
    addEventListener, ctrlKey, key, source_line, stack_trace,
    checked, closure, column, context, create, disable, display, edition,
    exports, filter, focus, forEach, froms, functions, getElementById,
    global, id, innerHTML, isArray, join, json, keys, length, level, line,
    lines, map, message, module, name, names, onchange, onclick, onscroll,
    option, parameters, parent, property, push, querySelectorAll, replace, role,
    scrollTop, select, signature, sort, split, stop, style, title, trim, value,
    warnings
*/

import jslint from "./jslint.js";

// This is the web script companion file for JSLint. It includes code for
// interacting with the browser and displaying the reports.

const elem_aux = document.getElementById("JSLINT_AUX");
const elem_boxes = document.querySelectorAll("[type=checkbox]");
const elem_global = document.getElementById("JSLINT_GLOBAL");
const elem_number = document.getElementById("JSLINT_NUMBER");
const elem_property = document.getElementById("JSLINT_PROPERTY");
const elem_property_fieldset = document.getElementById(
    "JSLINT_PROPERTYFIELDSET"
);
const elem_report_field = document.getElementById("JSLINT_REPORT");
const elem_report_list = document.getElementById("JSLINT_REPORT_LIST");
const rx_amp = /&/g;
const rx_gt = />/g;
const rx_lt = /</g;
const elem_select = document.getElementById("JSLINT_SELECT");
const elem_source = document.getElementById("JSLINT_SOURCE");
const elem_warnings = document.getElementById("JSLINT_WARNINGS");
const elem_warnings_list = document.getElementById("JSLINT_WARNINGS_LIST");

function entityify(string) {

// Replace & < > with less destructive entities.

    return String(
        string
    ).replace(
        rx_amp,
        "&amp;"
    ).replace(
        rx_lt,
        "&lt;"
    ).replace(
        rx_gt,
        "&gt;"
    );
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
        message,
        source_line,
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
            entityify(source_line + "\n" + stack_trace),
            "</samp>"
        );
    });
    return output.join("");
}

function function_report(data) {

// Produce the HTML Function Report.

// <dl class=LEVEL><address>LINE_NUMBER</address>FUNCTION_NAME_AND_SIGNATURE
//     <dt>DETAIL</dt><dd>NAMES</dd>
// </dl>

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
    let global = Object.keys(data.global.context).sort();
    let froms = data.froms.sort();
    let exports = Object.keys(data.exports).sort();
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
                        ? "<b>«" + entityify(the_function.name) + "»</b>"
                        : "<b>" + entityify(the_function.name.id) + "</b>"
                    )
                ) + entityify(the_function.signature),
                "</dfn>"
            );
            if (Array.isArray(the_function.parameters)) {
                let params = [];
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
    output.push(
        "<center>JSLint edition ",
        entityify(data.edition),
        "</center>"
    );
    return output.join("");
}

function property_directive(data) {

// Produce the /*property*/ directive.

    let not_first = false;
    let output = ["/*property"];
    let length = 1111;
    let properties = Object.keys(data.property);

    if (properties.length > 0) {
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
}

function show_numbers() {
    elem_number.value = elem_source.value.split(
        /\n|\r\n?/
    ).map(function (
        ignore,
        index
    ) {
        return index + 1;
    }).join("\n");
}

function clear() {
    elem_aux.style.display = "none";
    elem_number.value = "";
    elem_property.value = "";
    elem_property_fieldset.style.display = "none";
    elem_report_field.style.display = "none";
    elem_report_list.innerHTML = "";
    elem_source.focus();
    elem_source.value = "";
    elem_warnings.style.display = "none";
    elem_warnings_list.innerHTML = "";
}

function clear_options() {
    elem_boxes.forEach(function (node) {
        node.checked = false;
    });
    elem_global.innerHTML = "";
}

function call_jslint() {

// First build the option object.

    let option = Object.create(null);
    elem_boxes.forEach(function (node) {
        if (node.checked) {
            option[node.title] = true;
        }
    });

// Call JSLint with the source text, the options, and the predefined globals.

    let global_string = elem_global.value;
    let result = jslint(
        elem_source.value,
        option,
        (
            global_string === ""
            ? undefined
            : global_string.split(
                /[\s,;'"]+/
            )
        )
    );

// Generate the reports.

    let error_html = error_report(result);
    let function_html = function_report(result);
    let property_text = property_directive(result);

// Display the reports.

    elem_warnings_list.innerHTML = error_html;
    elem_warnings.style.display = (
        error_html.length === 0
        ? "none"
        : "block"
    );

    elem_report_list.innerHTML = function_html;
    elem_report_field.style.display = "block";
    if (property_text) {
        elem_property.value = property_text;
        elem_property_fieldset.style.display = "block";
        elem_property.scrollTop = 0;
        elem_select.disable = false;
    } else {
        elem_property_fieldset.style.display = "none";
        elem_select.disable = true;
    }
    elem_aux.style.display = "block";
    elem_source.select();
}

elem_source.onchange = function (ignore) {
    show_numbers();
};

elem_source.onscroll = function () {
    let ss = elem_source.scrollTop;
    elem_number.scrollTop = ss;
    let sn = elem_number.scrollTop;
    if (ss > sn) {
        show_numbers();
        elem_number.scrollTop = ss;
    }
};

document.addEventListener("keydown", function (evt) {
    if (evt.ctrlKey && evt.key === "Enter") {
        call_jslint();
    }
});

document.querySelectorAll("[name='JSLint']").forEach(function (node) {
    node.onclick = call_jslint;
});

document.querySelectorAll("[name='clear']").forEach(function (node) {
    node.onclick = clear;
});

document.getElementById("JSLINT_SELECT").onclick = function () {
    elem_property.focus();
    elem_property.select();
};
document.getElementById("JSLINT_CLEAR_OPTIONS").onclick = clear_options;

elem_source.select();
elem_source.focus();
elem_source.value = `#!/usr/bin/env node
/*jslint node*/
import jslint from "./jslint.mjs";
import https from "https";

/*jslint-disable*/
// TODO: jslint this code-block in the future.
console.log('hello world');
/*jslint-enable*/

eval("console.log('hello world');"); //jslint-quiet

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
}());`;
elem_source.onchange();
call_jslint();
