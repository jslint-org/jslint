(set -e
printf '> #!/bin/sh
> 
> printf "console.log('"'"'hello world'"'"');\\n" > hello.js
> 
> node jslint.mjs hello.js


'
#!/bin/sh

printf "console.log('hello world');\n" > hello.js

node jslint.mjs hello.js
)
