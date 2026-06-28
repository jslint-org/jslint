(set -e
printf '> #!/bin/sh
> 
> node --input-type=module --eval '"'"'
> 
> /*jslint devel*/
> import jslint from "./jslint.mjs";
> import fs from "fs";
> (async function () {
>     let result;
>     let source = "function foo() {console.log(\\u0027hello world\\u0027);}\\n";
> 
> // Create JSLint report from <source> in javascript.
> 
>     result = jslint.jslint(source);
>     result = jslint.jslint_report(result);
>     result = `<body class="JSLINT_ JSLINT_REPORT_">\\n${result}</body>\\n`;
> 
>     await fs.promises.mkdir(".artifact/", {recursive: true});
>     await fs.promises.writeFile(".artifact/jslint_report_hello.html", result);
>     console.error("wrote file .artifact/jslint_report_hello.html");
> }());
> 
> '"'"'


'
#!/bin/sh

node --input-type=module --eval '

/*jslint devel*/
import jslint from "./jslint.mjs";
import fs from "fs";
(async function () {
    let result;
    let source = "function foo() {console.log(\u0027hello world\u0027);}\n";

// Create JSLint report from <source> in javascript.

    result = jslint.jslint(source);
    result = jslint.jslint_report(result);
    result = `<body class="JSLINT_ JSLINT_REPORT_">\n${result}</body>\n`;

    await fs.promises.mkdir(".artifact/", {recursive: true});
    await fs.promises.writeFile(".artifact/jslint_report_hello.html", result);
    console.error("wrote file .artifact/jslint_report_hello.html");
}());

'
)
