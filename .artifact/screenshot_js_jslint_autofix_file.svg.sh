(set -e
printf '> #!/bin/sh
> 
> node --input-type=module --eval '"'"'
> 
> /*jslint devel*/
> import jslint from "./jslint.mjs";
> let result;
> let source = (`
> /*jslint devel*/
> console.log(
> "hello world");
> `);
> 
> result = jslint.jslint(source, {autofix: true});
> console.log(result.autofixed);
> 
> '"'"'


'
#!/bin/sh

node --input-type=module --eval '

/*jslint devel*/
import jslint from "./jslint.mjs";
let result;
let source = (`
/*jslint devel*/
console.log(
"hello world");
`);

result = jslint.jslint(source, {autofix: true});
console.log(result.autofixed);

'
)
