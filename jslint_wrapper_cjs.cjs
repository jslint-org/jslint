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


/*jslint beta, node*/
/*property
    href, pathToFileURL, readFileSync, replace, runInThisContext, stringify
*/

// PR-513 - Run jslint.mjs in THIS context, wrapped as a function, not in a new
// one: a new context has no process or console, so <jslint_cli> linted nothing
// and resolved 0. Its ' import(' calls go to <import_cjs>, the real one here;
// the file url lets its cli self-detect.

const fileJslint = __dirname + "/jslint.mjs";
const jslintRun = require("vm").runInThisContext(
    "(function (import_cjs, module) {\"use strict\";" +
    require("fs")
        .readFileSync(fileJslint, "utf8")
        .replace(
            "\nexport default Object.freeze(jslint_export);",
            "\nmodule.exports = jslint_export;"
        )
        .replace(
            "\njslint_import_meta_url = import.meta.url;",
            (
                "\njslint_import_meta_url = " +
                JSON.stringify(require("url").pathToFileURL(fileJslint).href) +
                ";"
            )
        )
        .replace((/ import\(/g), " import_cjs(") +
    "\n})"
);
jslintRun(function (specifier) {
    return import(specifier);
}, module);
