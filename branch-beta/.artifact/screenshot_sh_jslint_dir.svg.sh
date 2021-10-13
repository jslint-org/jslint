(set -e
printf '> #!/bin/sh
> 
> # JSLint directory '"'"'.'"'"'
> 
> node jslint.mjs .


'
#!/bin/sh

# JSLint directory '.'

node jslint.mjs . 2>&1 | head -n 100
)
