// rhino.js
// 2009-09-11
/*
Copyright (c) 2002 Douglas Crockford  (www.JSLint.com) Rhino Edition
*/

// This is the Rhino companion to fulljslint.js.

/*global JSLINT */
/*jslint rhino: true, strict: false */

(function (args) {
    var JSON = JSON,
        e,
        i,
        n,
        input,
        fn,
        config;

    if (!JSON) {
        JSON = {
            decode: function (s) {
                var evil = eval;
                try {
                    return evil('(' + s + ')');
                }
                catch (e) {
                    return;
                }
            }
        };
    }

    function is_own(object, name) {
        return Object.prototype.hasOwnProperty.call(object, name);
    }

    function combine(t, o) {
        var n;
        for (n in o) {
            if (is_own(o, n)) {
                t[n] = o[n];
            }
        }
    }

    function usage(exitcode, msg) {
        if (msg) {
            print(msg);
        }
        print("Usage: jslint.js [-hp] [-o options.js] [-s key=value] file.js [file2.js] [...]]");
        print("\t-h\tshow this help");
        print("\t-p\tproduce parseable output");
        print("\t-o FILE\tload options from JSON file");
        print("\t-s k=v\tset option 'k' to 'v'");
        print("");
        quit(exitcode);
    }

    function load_options(filename) {
        var json, options;
        if (!filename) {
            usage(1, 'No configuration file specified for option -o');
        }
        json = readFile(filename);
        if (!json) {
            usage(1, 'Can\'t read configuration file: ' + filename);
        }
        options = JSON.decode(json);
        if (!options) {
            usage(1, 'Not a valid configuration file (JSON)');
        }
        return options;
    }

    function add_option(dict, value) {
        var a, k, v;
        if (!value) {
            usage(1, "No value specified for option '-s'");
        }
        a = value.split('=', 2);
        k = a[0];
        v = a[1];
        switch (v) {
        case 'true':
            v = true;
            break;
        case 'false':
            v = false;
            break;
        default:
        }
        dict[k] = v || true;
    }

    function parse_args(args) {
        var arg,
            files = [],
            hasopts = true,
            moreopts = {},
            parseable = false,
            options = {
                bitwise: true,
                eqeqeq: true,
                immed: true,
                newcap: true,
                nomen: true,
                onevar: true,
                plusplus: true,
                regexp: true,
                rhino: true,
                undef: true,
                white: true
            };

        do {
            arg = args.shift();
            if (!arg) {
                continue;
            }
            if (arg && (arg === '--')) {
                hasopts = false;
                continue;
            }
            if (hasopts && arg.charAt(0) === '-') {
                switch (arg.charAt(1)) {
                case 'o':
                    options = load_options(args.shift());
                    break;
                case 's':
                    add_option(moreopts, args.shift());
                    break;
                case 'h':
                    usage(0);
                    break;
                case 'p':
                    parseable = true;
                    break;
                default:
                    usage(1, "unknown option '" + arg + "'");
                    quit();
                }
                continue;
            }
            files.push(arg);
        } while (arg);
        if (!files.length) {
            usage(1, 'no files specified');
        }
        combine(options, moreopts);
        return {
            files: files,
            options: options,
            parseable: parseable
        };
    }

    config = parse_args(args);

    for (n = 0; n < config.files.length; n += 1) {
        fn = config.files[n];
        input = readFile(fn);
        if (!input) {
            print("jslint: Couldn't open file '" + fn + "'.");
            quit(1);
        }

        if (!JSLINT(input, config.options)) {
            for (i = 0; i < JSLINT.errors.length; i += 1) {
                e = JSLINT.errors[i];
                if (e) {
                    if (config.parseable) {
                        print(fn + ':' + e.line + ':' + e.character + ': ' + e.reason);
                    }
                    else {
                        print('Lint at line ' + e.line + ' character ' +
                                e.character + ': ' + e.reason);
                        print((e.evidence || '').replace(/^\s*(\S*(\s+\S+)*)\s*$/, "$1"));
                    }
                    print('');
                }
            }
            continue;
        } else {
            print("jslint: No problems found in " + fn);
            continue;
        }
    }
    quit(0);
}(arguments));
