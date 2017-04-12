# Get the latest source from Douglas Crockford's supporting Github repos and build fullwebjslint.js

echo "Initializing Git submodules..."
git submodule init
echo "Getting latest JSLint..."
git pull
echo "Updating submodules..."
git submodule update
cat JSON-js/json2.js  fulljslint.js ADsafe/adsafe.js intercept.js > fullwebjslint.js
echo "JSLint updated and built into 'fullwebjslint.js'"