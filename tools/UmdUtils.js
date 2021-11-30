function generateUmdHeader(classes) {
  return `
(function (root, factory) {
  var hx_exports = factory();
  if (typeof define === "function" && define.amd) {
    define("lightstreamer", ["module"], function(module) {
      var namespace = (module.config()["ns"] ? module.config()["ns"] + "/" : "");
      ${ classes.map((c) => `define(namespace + "${c}", function() { return hx_exports.${c}; });`).join("\n") }
    });
    require(["lightstreamer"]);
  } else {
    var namespace = createNs(extractNs(), root);
    ${ classes.map((c) => `namespace.${c} = hx_exports.${c};`).join("\n") }
  }
  function extractNs() {
    var scripts = window.document.getElementsByTagName("script");
    for (var i = 0, len = scripts.length; i < len; i++) {
      if ("data-lightstreamer-ns" in scripts[i].attributes) {        
        return scripts[i].attributes["data-lightstreamer-ns"].value;
      }
    }
    return null;
  }
  function createNs(ns, root) {
    if (! ns) {
      return root;
    }
    var pieces = ns.split(".");
    var parent = root || window;
    for (var j = 0; j < pieces.length; j++) {
      var qualifier = pieces[j];
      var obj = parent[qualifier];
      if (! (obj && typeof obj == "object")) {
        obj = parent[qualifier] = {};
      }
      parent = obj;
    }
    return parent;
  }
}(typeof self !== "undefined" ? self : this, function () {
`
}

function generateUmdFooter(globalObject) {
  return `
  return ${globalObject};
}));
` 
}

export default {
  generateUmdHeader,
  generateUmdFooter
}