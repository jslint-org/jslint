// The Unlicense
//
// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.
//
// In jurisdictions that recognize copyright laws, the author or authors
// of this software dedicate any and all copyright interest in the
// software to the public domain. We make this dedication for the benefit
// of the public at large and to the detriment of our heirs and
// successors. We intend this dedication to be an overt act of
// relinquishment in perpetuity of all present and future rights to this
// software under copyright law.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
// OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.


// This wrapper will integrate JSLint with CodeMirror's lint.js addon.
// Requires CodeMirror and JSLint.
//
// Example usage:
/*
<!DOCTYPE html>
    <link rel="stylesheet" href="https://codemirror.net/lib/codemirror.css">
    <link rel="stylesheet" href="https://codemirror.net/addon/lint/lint.css">
    <script defer src="https://codemirror.net/lib/codemirror.js"></script>
    <script defer
        src="https://codemirror.net/mode/javascript/javascript.js"></script>
    <script defer src="https://codemirror.net/addon/lint/lint.js"></script>
    <script type="module" src="./jslint.mjs?window_jslint=1"></script>
    <script defer src="./jslint_wrapper_codemirror.js"></script>
<textarea id="editor1">console.log('hello world');</textarea>
<script type=module>
window.addEventListener("load", function () {
    window.CodeMirror.fromTextArea(document.getElementById(
        "editor1"
    ), {
        gutters: ["CodeMirror-lint-markers"],
        indentUnit: 4,
        lineNumbers: true,
        lint: {lintOnChange: true},
        mode: "javascript"
    });
});
</script>
</html>
*/

/*jslint browser, devel*/
/*global CodeMirror define exports jslint module require*/
/*property
    Pos, amd, column, error, from, globals, jslint, line, map, message,
    mode_stop, registerHelper, result, severity, signal, source, to, warnings
*/

(function (mod) {
    "use strict";

// CommonJS

    if (typeof exports === "object" && typeof module === "object") {
        mod(require("../../lib/codemirror"));

// AMD

    } else if (typeof define === "function" && define.amd) {
        define(["../../lib/codemirror"], mod);

// Plain browser env

    } else {
        mod(CodeMirror);
    }
}(function (CodeMirror) {
    "use strict";
    if (!window.jslint) {
        console.error(
            "Error: window.jslint not defined,"
            + " CodeMirror JavaScript linting cannot run."
        );
        return [];
    }
    CodeMirror.registerHelper("lint", "javascript", function (
        source,
        options,
        editor
    ) {
        let result;

// Emit <options> before linter is run, so it can be modified
// before passing to jslint.
//
// Example usage:
//  editor.on("lintJslintBefore", function (options) {
//      options.browser = true;
//      options.node = true;
//      options.globals = ["caches", "indexedDb"];
//  });

        options.source = source;
        CodeMirror.signal(editor, "lintJslintBefore", options);

// Run jslint.

        result = jslint.jslint(source, options, options.globals);

// Emit <result> after linter is run, so it can be used to generate reports.
//
// Example usage:
//  editor.on("lintJslintAfter", function (options) {
//      divReport.innerHTML = jslint.jslint_report(options.result);
//  });

        options.result = result;
        CodeMirror.signal(editor, "lintJslintAfter", options);

// Return warnings.

        return result.warnings.map(function ({
            column,
            line,
            message,
            mode_stop
        }) {
            return {
                from: CodeMirror.Pos(line - 1, column - 1), //jslint-ignore-line
                message,
                severity: (
                    mode_stop
                    ? "error"
                    : "warning"
                ),
                to: CodeMirror.Pos(line - 1, column) //jslint-ignore-line
            };
        });
    });
}));
