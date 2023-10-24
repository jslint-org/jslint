(set -e
printf '> #!/bin/sh
> 
> printf "function foo() {console.log('"'"'hello world'"'"');}\\n" > hello.js
> 
> # Create JSLint report from file '"'"'hello.js'"'"' in shell.
> 
> node jslint.mjs \\
>     jslint_report=.artifact/jslint_report_hello.html \\
>     hello.js


'
#!/bin/sh

printf "function foo() {console.log('hello world');}\n" > hello.js

# Create JSLint report from file 'hello.js' in shell.

node jslint.mjs \
    jslint_report=.artifact/jslint_report_hello.html \
    hello.js
)
