// browser.js
// 2018-06-16
// Copyright (c) 2015 Douglas Crockford  (www.JSLint.com)

/*jslint
    browser
*/

/*property
    checked, create, disable, display, error, focus, forEach, function,
    getElementById, innerHTML, join, length, map, onchange, onclick, onscroll,
    property, querySelectorAll, scrollTop, select, split, style, title, value
*/

import jslint from "./jslint.js";
import report from "./report.js";

// This is the web script companion file for JSLint. It includes code for
// interacting with the browser and displaying the reports.

let rx_crlf = /\n|\r\n?/;
let rx_separator = /[\s,;'"]+/;

let fudge_unit = 0;

const aux = document.getElementById("JSLINT_AUX");
const boxes = document.querySelectorAll("[type=checkbox]");
const fudge = document.getElementById("JSLINT_FUDGE");
const global = document.getElementById("JSLINT_GLOBAL");
const number = document.getElementById("JSLINT_NUMBER");
const property = document.getElementById("JSLINT_PROPERTY");
const property_fieldset = document.getElementById("JSLINT_PROPERTYFIELDSET");
const report_field = document.getElementById("JSLINT_REPORT");
const report_list = document.getElementById("JSLINT_REPORT_LIST");
const source = document.getElementById("JSLINT_SOURCE");
const select = document.getElementById("JSLINT_SELECT");
const warnings = document.getElementById("JSLINT_WARNINGS");
const warnings_list = document.getElementById("JSLINT_WARNINGS_LIST");

function show_numbers() {
    number.value = source.value.split(rx_crlf).map(function (ignore, index) {
        return index + fudge_unit;
    }).join("\n");
}

function clear() {
    aux.style.display = "none";
    number.value = "";
    property.value = "";
    property_fieldset.style.display = "none";
    report_field.style.display = "none";
    report_list.innerHTML = "";
    source.focus();
    source.value = "";
    warnings.style.display = "none";
    warnings_list.innerHTML = "";
}

function fudge_change() {
    fudge_unit = Number(fudge.checked);
    show_numbers();
}

function clear_options() {
    boxes.forEach(function (node) {
        node.checked = false;
    });
    fudge_change();
    global.innerHTML = "";
}

function call_jslint() {

// First build the option object.

    let option = Object.create(null);
    boxes.forEach(function (node) {
        if (node.checked) {
            option[node.title] = true;
        }
    });

// Call JSLint with the source text, the options, and the predefined globals.

    let global_string = global.value;
    let result = jslint(
        source.value,
        option,
        (
            global_string === ""
            ? undefined
            : global_string.split(rx_separator)
        )
    );

// Generate the reports.

    let error_html = report.error(result);
    let function_html = report.function(result);
    let property_text = report.property(result);

// Display the reports.

    warnings_list.innerHTML = error_html;
    warnings.style.display = (
        error_html.length === 0
        ? "none"
        : "block"
    );

    report_list.innerHTML = function_html;
    report_field.style.display = "block";
    if (property_text) {
        property.value = property_text;
        property_fieldset.style.display = "block";
        property.scrollTop = 0;
        select.disable = false;
    } else {
        property_fieldset.style.display = "none";
        select.disable = true;
    }
    aux.style.display = "block";
    source.select();
}

fudge.onchange = fudge_change;

source.onchange = function (ignore) {
    show_numbers();
};

source.onscroll = function () {
    let ss = source.scrollTop;
    number.scrollTop = ss;
    let sn = number.scrollTop;
    if (ss > sn) {
        show_numbers();
        number.scrollTop = ss;
    }
};

document.querySelectorAll("[name='JSLint']").forEach(function (node) {
    node.onclick = call_jslint;
});

document.querySelectorAll("[name='clear']").forEach(function (node) {
    node.onclick = clear;
});

document.getElementById("JSLINT_SELECT").onclick = function () {
    property.focus();
    property.select();
};
document.getElementById("JSLINT_CLEAR_OPTIONS").onclick = clear_options;

fudge_change();
source.select();
source.focus();
