/*jslint beta, node*/
/*property
    readFileSync, replace, runInNewContext
*/
require("vm").runInNewContext(
    require("fs").readFileSync(__dirname + "/jslint.mjs", "utf8").replace(
        "\nexport default Object.freeze(jslint_export);",
        "\nexports = jslint_export;"
    ).replace(
        "\njslint_import_meta_url = import.meta.url;",
        "\n// jslint_import_meta_url = import.meta.url;"
    ),
    module
);
