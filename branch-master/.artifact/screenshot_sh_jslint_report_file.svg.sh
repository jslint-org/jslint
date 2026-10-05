(set -e
printf '> #!/bin/sh
> 
> printf "function foo() {console.log('"'"'hello world'"'"');}\\n" > hello_report.js
> 
> # Create JSLint report from file '"'"'hello_report.js'"'"' in shell.
> 
> node jslint.mjs \\
>     jslint_report=.artifact/jslint_report_hello.html \\
>     hello_report.js


'
#!/bin/sh

printf "function foo() {console.log('hello world');}\n" > hello_report.js

# Create JSLint report from file 'hello_report.js' in shell.

node jslint.mjs \
    jslint_report=.artifact/jslint_report_hello.html \
    hello_report.js
)
