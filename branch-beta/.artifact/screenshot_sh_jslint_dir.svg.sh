(set -e
printf '> #!/bin/sh
> 
> # JSLint directory '"'"'.'"'"'
> 
> node jslint.mjs .


'
#!/bin/sh

# JSLint directory '.'

node jslint.mjs .
)
