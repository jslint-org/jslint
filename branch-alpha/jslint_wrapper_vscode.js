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
    Diagnostic, DiagnosticSeverity, ProgressLocation, Range, Warning, Window,
    activate, activeTextEditor, autofix, autofixed, cancellable, character,
    clear, column, commands, createDiagnosticCollection, document, edit, end,
    endsWith, exports, getText, increment, insert, isEmpty, jslint, languages,
    line, lineAt, lineCount, location, map, message, module, push, range,
    rangeIncludingLineBreak, readFileSync, registerCommand,
    registerTextEditorCommand, replace, report, runInNewContext, save,
    selection, set, slice, start, subscriptions, title, uri, validateRange,
    warnings, window, withProgress
*/

"use strict";

function activate({
    subscriptions
}) {
/**
 * @param {vscode.ExtensionContext} context
 */
// This method is called when your extension is activated.
// Your extension is activated the very first time the command is executed.

// Directly print diagnostic without language-server.
// https://stackoverflow.com/questions/35581332
// /create-diagnostics-entries-without-language-server-in-visual-studio-code

    let diagnosticCollection;
    let jslint;
    let vscode;

// PR-513 - Add command "JSLint - Autofix Whitespace".

    async function jslintAutofix() {
        const editor = vscode.window.activeTextEditor;
        let result;
        if (!editor) {
            return;
        }
        result = editor.document.getText();
        result = jslint.jslint(result, {
            autofix: true
        });
        if (result.autofixed !== undefined) {
            await editor.edit(function (editBuilder) {
                editBuilder.replace(editor.document.validateRange(
                    new vscode.Range(0, 0, editor.document.lineCount, 0)
                ), result.autofixed);
            });
        }
        await jslintLint();
    }

    function jslintClear() {
        return vscode.window.withProgress({
            cancellable: false,
            location: vscode.ProgressLocation.Window,
            title: "JSLint clear warnings ..."
        }, async function (progress) {
            progress.report({
                increment: 0
            });

// Clear "Problems" tab.

            diagnosticCollection.clear();

// Wait awhile for flicker to give user visual confirmation "Problems" tab
// is refreshed.

            await new Promise(function (resolve) {
                setTimeout(resolve, 500);
            });

            progress.report({
                increment: 100
            });
        });
    }

    function jslintDisableRegion({
        document,
        selection
    }, edit) {
        let range;
        let text;
        edit.insert({
            character: 0,
            line: selection.start.line
        }, "/*jslint-disable*/\n");
        range = document.lineAt(selection.end).rangeIncludingLineBreak;
        text = document.getText(range);

// If selection-end is EOL without preceding line-break,
// then prepend line-break before directive.

        if (!text.endsWith("\n")) {
            text += "\n/*jslint-enable*/";

// If selection-end is start of a new line, then prepend directive before it.

        } else if (!selection.isEmpty && selection.end.character === 0) {
            text = "/*jslint-enable*/\n" + text;

// Append directive to selection-end.

        } else {
            text += "/*jslint-enable*/\n";
        }
        edit.replace(range, text);
    }

    function jslintIgnoreLine({
        document,
        selection
    }, edit) {
        edit.insert({
            character: document.lineAt(selection.end).range.end.character,
            line: selection.end.line
        }, " //jslint-ignore-line");
    }

    function jslintLint() {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            return;
        }
        return vscode.window.withProgress({
            cancellable: false,
            location: vscode.ProgressLocation.Window,
            title: "JSLint lint file ..."
        }, async function (progress) {
            let result;
            progress.report({
                increment: 0
            });

// Clear "Problems" tab, all files, not just this one - intentional: every
// jslint command lints one file, so the tab shows only that file's warnings.

            diagnosticCollection.clear();
            result = editor.document.getText();
            result = jslint.jslint(result);
            result = result.warnings.slice(0, 100).map(function ({
                column,
                line,
                // line_source,
                message
            }) {
                return new vscode.Diagnostic(
                    // code: line_source,
                    {
                        end: {
                            character: column - 1,
                            line: line - 1
                        },
                        start: {
                            character: column - 1,
                            line: line - 1
                        }
                    },
                    `JSLint - ${message}`,
                    vscode.DiagnosticSeverity.Warning
                );
            });

// Wait awhile for flicker to give user visual confirmation "Problems" tab
// is refreshed.

            await new Promise(function (resolve) {
                setTimeout(resolve, 100);
            });

// Update "Problems" tab.

            diagnosticCollection.set(editor.document.uri, result);
            progress.report({
                increment: 100
            });
        });
    }

// PR-429 - Add manual lint-on-save command.

    async function jslintLintAndSave() {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            return;
        }
        await editor.document.save();
        await jslintLint();
    }

// Initialize vscode and jslint.

    vscode = require("vscode");
    diagnosticCollection = vscode.languages.createDiagnosticCollection(
        "jslint"
    );
    require("vm").runInNewContext(
        (
            "\"use strict\";"
            + require("fs").readFileSync( //jslint-ignore-line
                __dirname + "/jslint.mjs",
                "utf8"
            ).replace(
                "\nexport default Object.freeze(jslint_export);",
                "\nmodule.exports = jslint_export;"
            ).replace(
                "\njslint_import_meta_url = import.meta.url;",
                "\n// jslint_import_meta_url = import.meta.url;"
            )
        ),
        {
            module
        }
    );
    jslint = module.exports;

// Register extension commands.
// Async commands use <registerCommand>: <registerTextEditorCommand> drops the
// callback's promise, so the command ends before its work does, and errors go
// unreported. Only the two sync edit-builder commands keep it.

    subscriptions.push(vscode.commands.registerCommand((
        "jslint.autofix"
    ), jslintAutofix));
    subscriptions.push(vscode.commands.registerCommand((
        "jslint.clear"
    ), jslintClear));
    subscriptions.push(vscode.commands.registerTextEditorCommand((
        "jslint.disableRegion"
    ), jslintDisableRegion));
    subscriptions.push(vscode.commands.registerTextEditorCommand((
        "jslint.ignoreLine"
    ), jslintIgnoreLine));
    subscriptions.push(vscode.commands.registerCommand((
        "jslint.lint"
    ), jslintLint));
    subscriptions.push(vscode.commands.registerCommand((
        "jslint.lintAndSave"
    ), jslintLintAndSave));
}

exports.activate = activate;
