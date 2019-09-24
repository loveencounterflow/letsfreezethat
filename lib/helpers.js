(function() {
  'use strict';
  this.type_of = function(x) {
    var R;
    if ((R = ((Object.prototype.toString.call(x)).slice(8, -1)).toLowerCase()) === 'object') {
      return x.constructor.name.toLowerCase();
    }
    return R;
  };

}).call(this);
