(set -e
printf '> #!/bin/sh
> 
> node --input-type=module --eval '"'"'
> 
> /*jslint devel*/
> 
> // Import JSLint in ES Module environment.
> 
> import jslint from "./jslint.mjs";
> 
> let globals = ["caches", "indexedDb"];
> let options = {browser: true};
> let result;
> let source = "console.log(\\u0027hello world\\u0027);\\n";
> 
> // JSLint <source> and print <formatted_message>.
> 
> result = jslint.jslint(source, options, globals);
> result.warnings.forEach(function ({
>     formatted_message
> }) {
>     console.error(formatted_message);
> });
> 
> '"'"'


'
#!/bin/sh

node --input-type=module --eval '

/*jslint devel*/

// Import JSLint in ES Module environment.

import jslint from "./jslint.mjs";

let globals = ["caches", "indexedDb"];
let options = {browser: true};
let result;
let source = "console.log(\u0027hello world\u0027);\n";

// JSLint <source> and print <formatted_message>.

result = jslint.jslint(source, options, globals);
result.warnings.forEach(function ({
    formatted_message
}) {
    console.error(formatted_message);
});

'
)
