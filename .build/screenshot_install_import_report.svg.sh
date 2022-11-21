printf '> #!/bin/sh
> 
> node --input-type=module -e '"'"'
> 
> /*jslint devel*/
> import jslint from "./jslint.mjs";
> import fs from "fs";
> (async function () {
>     let report;
>     let result;
>     let source = "function foo() {console.log(\\u0027hello world\\u0027);}\\n";
>     result = jslint(source);
>     report = jslint.report(result);
>     await fs.promises.writeFile(".jslint_report.html", report);
>     console.error("jslint - created html-report .jslint_report.html");
> }());
> 
> '"'"'


'
#!/bin/sh

node --input-type=module -e '

/*jslint devel*/
import jslint from "./jslint.mjs";
import fs from "fs";
(async function () {
    let report;
    let result;
    let source = "function foo() {console.log(\u0027hello world\u0027);}\n";
    result = jslint(source);
    report = jslint.report(result);
    await fs.promises.writeFile(".jslint_report.html", report);
    console.error("jslint - created html-report .jslint_report.html");
}());

'
