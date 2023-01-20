angular
  .module('search', ['angucomplete-alt'])
  .controller('SearchController', ['SEARCH_DATA', '$window', function (searchData, $window) {
      var me = this;

      me.docs = searchData.data;
      me.src = searchData.src;

      me.search = function (selected) {
          var doc,
              path,
              url;

          if (selected) {
              doc = selected.originalObject;
              if (doc._scope == "module") {
                  path = "module-" + doc.longname;
              }
              else if (doc._scope == "global") {
                  path = "global#" + doc.longname;
              }
              else {
                  // class
                  path = doc.longname;
              }
              if (path.includes("#")) {
                  // instance member
                  var parts = path.split("#");
                  url = parts[0] + ".html#" + parts[1];
              }
              else if (path.includes(".")) {
                  // static member
                  var parts = path.split(".");
                  url = parts[0] + ".html#." + parts[1];
              }
              else {
                  // type name
                  url = path + ".html";
              }
              $window.location = url;
          }
      };
  }]);
