// browser.js
// 2016-08-08
// Copyright (c) 2015 Douglas Crockford  (www.JSLint.com)

/*jslint
    browser, for
*/

/*global
    ADSAFE, REPORT, jslint
*/

/*property
    ___nodes___, check, create, each, enable, error, focus, function, getCheck,
    getName, getTitle, getValue, innerHTML, length, lib, lines, on, onscroll,
    property, q, scrollTop, select, split, style, value
*/

// This is the web script companion file for JSLint. It includes code for
// interacting with the browser and generating the reports.

ADSAFE.lib("browser_ui", function () {
    "use strict";

    var rx_crlf = /\n|\r\n?/;
    var rx_separator = /[\s,;'"]+/;

    function setHTML(bunch, html) {
        bunch.___nodes___[0].innerHTML = html;
    }

    function setScrollTop(bunch, number) {
        bunch.___nodes___[0].scrollTop = number;
    }

    function getScrollTop(bunch) {
        return bunch.___nodes___[0].scrollTop;
    }

    function onscroll(bunch, handler) {
        bunch.___nodes___[0].onscroll = handler;
    }

    return function (dom) {

// This function is the entry point to this web module.

// First get handles to some of the page features.

        var warnings = dom.q("#JSLINT_WARNINGS");
        var warnings_div = warnings.q(">div");
        var options = dom.q("#JSLINT_OPTIONS");
        var global = dom.q("#JSLINT_GLOBAL");
        var property_fieldset = dom.q("#JSLINT_PROPERTYFIELDSET");
        var property = dom.q("#JSLINT_PROPERTY");
        var report_field = dom.q("#JSLINT_REPORT");
        var report_div = report_field.q(">div");
        var select = dom.q("#JSLINT_SELECT");
        var source = dom.q("#JSLINT_SOURCE");
        var number = dom.q("#JSLINT_NUMBER");
        var fudge = dom.q("#JSLINT_FUDGE");
        var aux = dom.q("#JSLINT_AUX");

        function clear() {
            warnings.style("display", "none");
            report_field.style("display", "none");
            property_fieldset.style("display", "none");
            aux.style("display", "none");
            number.value("");
            property.value("");
            report_div.value("");
            source.value("");
            source.focus();
            warnings_div.value("");
        }

        function clear_options() {
            options.q("input_checkbox").check(false);
            options.q("input_text").value("");
            global.value("");
        }

        function show_numbers() {
            var f = +(fudge.getCheck());
            var n = source.getValue().split(rx_crlf).length + f;
            var text = "";
            var i;
            for (i = f; i <= n; i += 1) {
                text += i + "\n";
            }
            number.value(text);
        }

        function mark_scroll() {
            var ss = getScrollTop(source);
            setScrollTop(number, ss);
            var sn = getScrollTop(number);
            if (ss > sn) {
                show_numbers();
                setScrollTop(number, ss);
            }
        }

        function call_jslint() {

// First build the option object.

            var option = Object.create(null);
            options.q("input_checkbox:checked").each(function (node) {
                option[node.getTitle()] = true;
            });
            options.q("input_text").each(function (node) {
                var value = +node.getValue();
                if (isFinite(value) && value > 0) {
                    option[node.getTitle()] = value;
                }
            });

// Call JSLint with the source text, the options, and the predefined globals.

            var global_string = global.getValue();
            var result = jslint(
                source.getValue(),
                option,
                (global_string === "")
                    ? undefined
                    : global_string.split(rx_separator)
            );

// Generate the reports.

            var error_html = REPORT.error(result);
            var function_html = REPORT.function(result);
            var property_text = REPORT.property(result);

// Display the reports.

            setHTML(warnings_div, error_html);
            warnings.style("display", (error_html.length === 0)
                ? "none"
                : "block");
            setHTML(report_div, function_html);
            report_field.style("display", "block");
            if (property_text) {
                property.value(property_text);
                property_fieldset.style("display", "block");
                setScrollTop(property, 0);
                select.enable(true);
            } else {
                property_fieldset.style("display", "none");
                select.enable(false);
            }
            aux.style("display", "block");
            source.select();
        }

        function select_property_directive() {
            property.select();
        }

// Lay in the click handlers.

        dom.q("button").each(function (button) {
            switch (button.getName()) {
            case "JSLint":
                button.on("click", call_jslint);
                break;
            case "clear":
                button.on("click", clear);
                break;
            case "options":
                button.on("click", clear_options);
                break;
            case "select":
                button.on("click", select_property_directive);
                break;
            }
        });
        fudge.on("change", function (ignore) {
            show_numbers();
        });
        source.on("change", function (ignore) {
            show_numbers();
        });
        onscroll(source, function (ignore) {
            mark_scroll();
        });
        source.select();
    };
});
