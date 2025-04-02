(set -e
printf '> #!/bin/sh
> 
> node --eval '"'"'
> 
> /*jslint devel*/
> (async function () {
>     let globals = ["caches", "indexedDb"];
>     let jslint;
>     let options = {browser: true};
>     let result;
>     let source = "console.log(\\u0027hello world\\u0027);\\n";
> 
> // Import JSLint in CommonJS environment.
> 
>     jslint = await import("./jslint.mjs");
>     jslint = jslint.default;
> 
> // JSLint <source> and print <formatted_message>.
> 
>     result = jslint.jslint(source, options, globals);
>     result.warnings.forEach(function ({
>         formatted_message
>     }) {
>         console.error(formatted_message);
>     });
> }());
> 
> '"'"'


'
#!/bin/sh

node --eval '

/*jslint devel*/
(async function () {
    let globals = ["caches", "indexedDb"];
    let jslint;
    let options = {browser: true};
    let result;
    let source = "console.log(\u0027hello world\u0027);\n";

// Import JSLint in CommonJS environment.

    jslint = await import("./jslint.mjs");
    jslint = jslint.default;

// JSLint <source> and print <formatted_message>.

    result = jslint.jslint(source, options, globals);
    result.warnings.forEach(function ({
        formatted_message
    }) {
        console.error(formatted_message);
    });
}());

'
)
