printf '> #!/bin/sh
> 
> printf "function foo() {console.log('"'"'hello world'"'"');}\\n" > hello.js
> 
> node jslint.mjs --mode-report hello.js


'
#!/bin/sh

printf "function foo() {console.log('hello world');}\n" > hello.js

node jslint.mjs --mode-report hello.js
