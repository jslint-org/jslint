/*jslint node: true*/
function printGlobals() {
    'use strict';
    var sortedValues;

    function caseInsensitiveCompare(a, b) {
        return a.toLowerCase().localeCompare(b.toLowerCase());
    }

    function getGlobals() {
        var values = [],
            value;

        for (value in global) {
            if (global.hasOwnProperty(value)) {
                values.push(value);
            }
        }
        return values;
    }

    sortedValues = getGlobals().sort(caseInsensitiveCompare);
    console.log(sortedValues);
}

printGlobals();
