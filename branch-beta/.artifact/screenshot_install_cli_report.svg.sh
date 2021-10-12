printf '> #!/bin/sh
> 
> printf "function foo() {console.log('"'"'hello world'"'"');}\\n" > hello.js
> 
> node jslint.mjs \\
>     jslint_report=.artifact/jslint_report_hello.html \\
>     hello.js


'
#!/bin/sh

printf "function foo() {console.log('hello world');}\n" > hello.js

node jslint.mjs \
    jslint_report=.artifact/jslint_report_hello.html \
    hello.js
