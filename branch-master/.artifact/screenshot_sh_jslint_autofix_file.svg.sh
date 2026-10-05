(set -e
printf '> #!/bin/sh
> 
> printf '"'"'
> /*jslint devel*/
> console.log(
> "hello world");
> '"'"' > hello_autofix.js
> 
> node jslint.mjs jslint_autofix=hello_autofix.js
> 
> cat hello_autofix.js


'
#!/bin/sh

printf '
/*jslint devel*/
console.log(
"hello world");
' > hello_autofix.js

node jslint.mjs jslint_autofix=hello_autofix.js

cat hello_autofix.js
)
