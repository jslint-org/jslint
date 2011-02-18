# Get the latest source from Douglas Crockford's supporting Github repos and build fullwebjslint.js

git submodule update
cat JSON-js/json2.js  fulljslint.js ADsafe/adsafe.js intercept.js > fullwebjslint.js