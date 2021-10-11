printf '> #!/bin/sh
> 
> git clone https://github.com/mapbox/node-sqlite3 \\
>     --branch=v5.0.2 \\
>     --depth=1 \\
>     --single-branch
> 
> (set -e
>     cd node-sqlite3
>     npm install
>     node ../jslint.mjs \\
>         v8_coverage_report=.artifact/coverage_sqlite3 \\
>         npm run test
> )
> 
> cp -a node-sqlite3/.artifact .


'
#!/bin/sh

git clone https://github.com/mapbox/node-sqlite3 \
    --branch=v5.0.2 \
    --depth=1 \
    --single-branch

(set -e
    cd node-sqlite3
    npm install
    node ../jslint.mjs \
        v8_coverage_report=.artifact/coverage_sqlite3 \
        npm run test
)

cp -a node-sqlite3/.artifact .
