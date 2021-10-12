(set -e
printf '> #!/bin/sh
> 
> git clone https://github.com/mapbox/node-sqlite3 \\
>     --branch=v5.0.2 \\
>     --depth=1 \\
>     --single-branch
> 
> cd node-sqlite3
> npm install
> 
> # v8_coverage_report
> node ../jslint.mjs \\
>     v8_coverage_report=.artifact/coverage_sqlite3 \\
>     npm run test
> 
> cp -a .artifact ..


'
#!/bin/sh

git clone https://github.com/mapbox/node-sqlite3 \
    --branch=v5.0.2 \
    --depth=1 \
    --single-branch 2>/dev/null || true


cd node-sqlite3

git checkout 60a022c511a37788e652c271af23174566a80c30
npm install

# v8_coverage_report
node ../jslint.mjs \
    v8_coverage_report=.artifact/coverage_sqlite3 \
    npm run test

cp -a .artifact ..
)
