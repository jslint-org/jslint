#!/usr/bin/env node

/**
 *  @title: jslint wrapper for nodejs.
 *  @author: Dylan Mao(maverickpuss AT gmail.com)
 *  @note: this wrapper is totally for FEer's sake, and the default config
 *         file is hence prepared for browser environment, you can also
 *         specify your own config file instead.
 *
 *  usage:
 *  
 *  node cli.js --config=.jslint.conf --file=d.js
 *  
 *  jslint warning appears like: 
 *
 *  ----
 *  de-Dylan:JSLint dylan$ node cli.js --config=.jslint.conf --file=cli.js
 *  cli.js:L0 C0  unexpected_char_a:  Unexpected character '#'.
 *
 *  1 errors
 *  ----
 *
 *  when no errors: no output
 */

var fs = require("fs"),
    path = require("path"),
    minimatch = require("minimatch"),
    jslint = require("./jslint"),
    configFilePath = null,
    jsFilePath = null,
    jsFileText = "";
    configObj = null,
    lintResult = null,
    lintReport = [];

// try resolving file paths
process.argv.forEach(function(argStr, idx) {
    var matchConfig = (/^--config=([\w\/\.\-]+)$/gi).exec(argStr),
        matchFile = (/^--file=([\w\/\.\-]+)$/gi).exec(argStr);        

    if (matchConfig !== null) {
        configFilePath = matchConfig[1];
    }

    if (matchFile !== null) {
        jsFilePath = matchFile[1];
    }
});

if (configFilePath !== null) {
    try {
        // TODO: cache config file for better performance
        configObj = JSON.parse(fs.readFileSync(configFilePath, "utf-8"));
    } catch(e) {
        console.log("Failed to open config file, please check JSON syntax.");
        process.exit(1);
    }

    // note, this is a custom field(made up by me :P)
    // bypass the ignored files in the given 'ignore' Array.
    // be sure that it should be an `Array`!!
    if (configObj.ignore) {
        for (var i=0; i<configObj.ignore.length; i++) {
            // this file need to be ignored.
            if (jsFilePath.minimatch(configObj.ignore[i])) {
                // console.log("This file has been ignored, check your
                // .jslint.conf for more details.");
                process.exit(0);
            }
        }
    }


    try {
        // file path based on current working directory
        jsFileText = fs.readFileSync(jsFilePath, "utf-8");
    } catch(e) {
        console.log("Failed to read js file, please check.");
        process.exit(1);
    }

    lintResult = jslint(jsFileText, configObj.option_object, configObj.global_array);

    // no warnings, we are good to go.
    if (lintResult.warnings.length === 0) {
        process.exit(0);
    } else {
        lintResult.warnings.forEach(function(item, idx) {
            lintReport.push([
                jsFilePath,
                ":L",
                item.line,
                " C",
                item.column,
                "  ",
                item.code,
                ":  ",
                item.message
            ].join(""));
        });

        lintReport.push(["\n", lintResult.warnings.length, " errors"].join(""));
        console.log(lintReport.join("\n"));
    }
} else {
    console.error("Fatal error! No config file found, now exit.");
    process.exit(1);
}
