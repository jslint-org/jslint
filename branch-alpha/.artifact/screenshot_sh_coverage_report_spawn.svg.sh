(set -e
printf '> #!/bin/sh
> 
> git clone https://github.com/mapbox/node-sqlite3 node-sqlite3-sh \\
>     --branch=v5.0.2 \\
>     --depth=1 \\
>     --single-branch
> 
> cd node-sqlite3-sh
> npm install
> 
> # Create V8 coverage report from program `npm run test` in shell.
> 
> node ../jslint.mjs \\
>     v8_coverage_report=../.artifact/coverage_sqlite3_sh/ \\
>     --exclude-node-modules=true \\
>     --exclude=test/foo.js,test/bar.js \\
>     --exclude=test/baz.js \\
>     npm run test


'
#!/bin/sh

git clone https://github.com/mapbox/node-sqlite3 node-sqlite3-sh \
    --branch=v5.0.2 \
    --depth=1 \
    --single-branch 2>/dev/null || true


cd node-sqlite3-sh

git checkout 60a022c511a37788e652c271af23174566a80c30
npm install

# Create V8 coverage report from program `npm run test` in shell.

node ../jslint.mjs \
    v8_coverage_report=../.artifact/coverage_sqlite3_sh/ \
    --exclude-node-modules=true \
    --exclude=test/foo.js,test/bar.js \
    --exclude=test/baz.js \
    npm run test
)
