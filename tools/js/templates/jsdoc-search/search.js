var env = require('jsdoc/env'),
    path = require('path'),
    fs = require('fs'),
    _ = require('underscore');

exports.handlers = {
    parseComplete: function (e) {
        var src = env.opts._.map(function (src) { return path.join(env.pwd, src); }),
          fd = fs.openSync(path.join(env.opts.destination, 'angular.jsdoc.search.data.js'), 'w'),
          data;

        data = e.doclets.filter(function(doclet) {
          return !doclet.undocumented && doclet.kind !== 'member';
        })
        .filter(function(doclet) {
            return doclet.access == undefined /*public element*/ &&
                ! doclet.longname.includes("<anonymous>") /*not an inner element*/;
        })
        .map(function(doclet) {
            var obj = {
                    /* see https://jsdoc.app/about-plugins.html for doclet structure */
                    /* see angucomplete-alt component in layout.tmpl for configuration */
                    //name: doclet.name, /* omit name to have a more compact dropdown list */
                    longname: doclet.longname,
//                    kind: doclet.kind,
//                    scope: doclet.scope
            };
            if (obj.longname.startsWith("module:")) {
                obj.longname = obj.longname.slice("module:".length);
                obj._scope = "module";
            }
            else if (doclet.kind == "typedef") {
                obj._scope = "global";
            }
            // else { class }
            return obj;
        });

        fs.writeSync(fd, 'angular.module("search").constant("SEARCH_DATA", ');
        fs.writeSync(fd, JSON.stringify({ src: src, data: data }));
        fs.writeSync(fd, ');');
        fs.closeSync(fd);
    }
};
