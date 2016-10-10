// report.js
// 2016-10-10
// Copyright (c) 2015 Douglas Crockford  (www.JSLint.com)

// Generate JSLint HTML reports.

/*property
    closure, column, context, edition, error, filter, forEach, fudge, function,
    functions, global, id, froms, isArray, join, json, keys, length, level,
    line, lines, message, module, name, names, option, parameters, property,
    push, replace, role, signature, sort, stop, warnings
*/

var REPORT = (function () {
    "use strict";

    var rx_amp = /&/g;
    var rx_gt = />/g;
    var rx_lt = /</g;

    function entityify(string) {

// Replace & < > with less destructive entities.

        return String(string)
            .replace(rx_amp, "&amp;")
            .replace(rx_lt, "&lt;")
            .replace(rx_gt, "&gt;");
    }

    return {

        error: function error_report(data) {

// Produce the HTML Error Report.

// <cite><address>LINE_NUMBER</address>MESSAGE</cite>
// <samp>EVIDENCE</samp>

            var fudge = +!!data.option.fudge;
            var output = [];
            if (data.stop) {
                output.push("<center>J<u>SLint</u> was unable to finish.</center>");
            }
            data.warnings.forEach(function (warning) {
                output.push(
                    "<cite><address>",
                    entityify(warning.line + fudge),
                    ".",
                    entityify(warning.column + fudge),
                    "</address>",
                    entityify(warning.message),
                    "</cite><samp>",
                    entityify(data.lines[warning.line] || ""),
                    "</samp>"
                );
            });
            return output.join("");
        },

        function: function function_report(data) {

// Produce the HTML Function Report.

// <dl class=LEVEL><address>LINE_NUMBER</address>FUNCTION_NAME_AND_SIGNATURE
//     <dt>DETAIL</dt><dd>NAMES</dd>
// </dl>

            var fudge = +!!data.option.fudge;
            var mode = (data.module)
                ? "module"
                : "global";
            var output = [];

            if (data.json) {
                return (data.warnings.length === 0)
                    ? "<center>JSON: good.</center>"
                    : "<center>JSON: bad.</center>";
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
            var global = Object.keys(data.global.context).sort();
            var froms = data.froms.sort();
            var exports = Object.keys(data.exports).sort()
            if (global.length + froms.length + exports.length > 0) {
                output.push("<dl class=level0>");
                detail(mode, global);
                detail("import from", froms);
                detail("export", exports);
                output.push("</dl>");
            }

            if (data.functions.length > 0) {
                data.functions.forEach(function (the_function) {
                    var context = the_function.context;
                    var list = Object.keys(context);
                    output.push(
                        "<dl class=level",
                        entityify(the_function.level),
                        "><address>",
                        entityify(the_function.line + fudge),
                        "</address><dfn>",
                        (the_function.name === "=>")
                            ? entityify(the_function.signature) + " =>"
                            : (
                                (typeof the_function.name === "string")
                                    ? "<b>«" + entityify(the_function.name)
                                        + "»</b>"
                                    : "<b>" + entityify(the_function.name.id)
                                        + "</b>"
                            ) + entityify(the_function.signature),
                        "</dfn>"
                    );
                    if (Array.isArray(the_function.parameters)) {
                        var params = [];
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
                        var the_variable = context[id];
                        return the_variable.role === "variable" &&
                                the_variable.function === the_function;
                    }));
                    detail("exception", list.filter(function (id) {
                        return context[id].role === "exception";
                    }));
                    detail("closure", list.filter(function (id) {
                        var the_variable = context[id];
                        return the_variable.closure === true &&
                                the_variable.function === the_function;
                    }));
                    detail("outer", list.filter(function (id) {
                        var the_variable = context[id];
                        return the_variable.function !== the_function &&
                                the_variable.function.id !== "(global)";
                    }));
                    detail(mode, list.filter(function (id) {
                        return context[id].function.id === "(global)";
                    }));
                    detail("label", list.filter(function (id) {
                        return context[id].role === "label";
                    }));
                    output.push("</dl>");
                });
            }
            output.push(
                "<center>J<u>SLint</u> edition ",
                entityify(data.edition),
                "</center>"
            );
            return output.join("");
        },

        property: function property_directive(data) {

// Produce the /*property*/ directive.

            var not_first = false;
            var output = ["/*property"];
            var length = 1111;
            var properties = Object.keys(data.property);

            if (properties.length > 0) {
                properties.sort().forEach(function (key) {
                    if (not_first) {
                        output.push(",");
                        length += 2;
                    }
                    not_first = true;
                    if (length + key.length > 78) {
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
    };
}());
