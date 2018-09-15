#!/usr/bin/env node
/*jslint node */
/*property
    argv,
    assert,
    autofix,
    basename,
    error,
    exit,
    fs,
    join,
    jslint,
    main,
    message,
    option,
    readFile,
    replace,
    runInNewContext,
    source_autofixed,
    writeFile
*/
"use strict";
let fs;
let local;
let modeNext;
let onNext;
let path;
let vm;
onNext = function (error, data) {
    if (error) {
        console.error(error.message);
        return;
    }
    modeNext += 1;
    switch (modeNext) {
    case 1:
        // run this program only in cli-mode
        if (module !== require.main) {
            console.error(
                "jslint-autofix can only be run from the command-line"
            );
            return;
        }
        // require builtins
        fs = require("fs");
        path = require("path");
        vm = require("vm");
        // init local namespace
        local = {};
        if (!process.argv[2]) {
            console.error(
                "error:   no <file> specified\n"
                + "usage:   " + path.basename(__filename) + " <file>\n"
                + "example: " + path.basename(__filename) + " example.js"
            );
            process.exit(1);
        }
        fs.readFile(path.join(__dirname, "jslint.js"), "utf8", onNext);
        break;
    case 2:
        // bug-workaround - nodejs does not widely support es-modules
        vm.runInNewContext(
            data.replace("export default function", "function"),
            local
        );
        // read file-data
        fs.readFile(process.argv[2], "utf8", onNext);
        break;
    case 3:
        // autofix file-data
        console.error(
            "jslint-autofix - autofixing file " + process.argv[2] + " ..."
        );
        data = local.jslint(data, {autofix: true});
        if (typeof data.source_autofixed !== "string") {
            onNext(new Error(
                "jslint-autofix - could not autofix file " + process.argv[2]
            ));
            return;
        }
        // save autofixed file-data
        fs.writeFile(
            process.argv[2] + ".autofixed.js",
            data.source_autofixed,
            onNext
        );
        break;
    case 4:
        console.error(
            "jslint-autofix - saved autofixed file - " + process.argv[2]
            + ".autofixed.js"
        );
        break;
    }
};
modeNext = 0;
onNext();
