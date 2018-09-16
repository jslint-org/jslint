#!/usr/bin/env node
/*jslint node */
/*property
    argv, basename, column, concat, end, error, exit, filter, forEach, fudge,
    join, jslint, line, lines, main, match, message, on, option, parse, push,
    readFile, replace, request, runInNewContext, slice, trim, trimRight,
    warnings
*/
"use strict";
let chunk_list;
let file;
let fs;
let fudge;
let local;
let modeNext;
let onNext;
let path;
let url;
let vm;
let warning_text;
onNext = function (error, data) {
    if (error) {
        console.error(error.message || error);
        process.exit(1);
    }
    modeNext += 1;
    switch (modeNext) {
    case 1:
        // run this program only in cli-mode
        if (module !== require.main) {
            console.error(
                "jslint-cli can only be run from the command-line"
            );
            return;
        }
        // require builtins
        fs = require("fs");
        path = require("path");
        url = require("url");
        vm = require("vm");
        // init local namespace
        local = {};
        if (!process.argv[2]) {
            console.error(
                "error:   no <file/url> specified\n"
                + "usage:   " + path.basename(__filename) + " <file/url>\n"
                + "example: " + path.basename(__filename) + " example.js\n"
                + "example: " + path.basename(__filename)
                + " https://jslint.com/jslint.js"
            );
            process.exit(1);
        }
        // init jslint
        fs.readFile(path.join(__dirname, "jslint.js"), "utf8", onNext);
        break;
    case 2:
        // bug-workaround - nodejs does not widely support es-modules
        vm.runInNewContext(
            data.replace("export default function", "function"),
            local
        );
        // read data from file
        file = process.argv[2];
        console.error("jslint " + file);
        data = file.match(/^(https?):\/\//);
        if (!data) {
            fs.readFile(file, "utf8", onNext);
            return;
        }
        // read data from http/https url
        require(data[1]).request(url.parse(file), function (response) {
            chunk_list = [];
            response
            .on("data", function (chunk) {
                chunk_list.push(chunk);
            })
            .on("end", function () {
                onNext(null, String(Buffer.concat(chunk_list)));
            })
            .on("error", onNext);
        }).on("error", onNext).end();
        break;
    case 3:
        // jslint data
        data = local.jslint(data
        // ignore first-line shebang in nodejs scripts
        .replace((/^#!/), "//"));
        fudge = data.option.fudge || 0;
        // init warning_text
        warning_text = "";
        // print warnings to stderrr
        data.warnings
        .filter(function (warning) {
            return warning && warning.message;
        })
        // print only first 10 warnings
        .slice(0, 10)
        .forEach(function (warning, ii) {
            warning_text += (
                (" #" + (ii + 1)).slice(-3)
                + " \u001b[31m" + warning.message + "\u001b[39m\n"
                + "    " + String(data.lines[warning.line] || "").trim()
                + "\u001b[90m \/\/ line "
                + (warning.line + fudge)
                + ", col " + (warning.column + fudge)
                + "\u001b[39m\n"
            );
        });
        console.error(warning_text.trimRight() || "ok");
        break;
    }
};
modeNext = 0;
onNext();
