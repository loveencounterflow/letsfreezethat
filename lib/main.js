(function() {
  //-----------------------------------------------------------------------------------------------------------
  var _freeze, _thaw, freeze, lets, thaw;

  freeze = function(x) {
    var error;
    try {
      return _freeze(x);
    } catch (error1) {
      error = error1;
      if (error.name === 'RangeError' && error.message === 'Maximum call stack size exceeded') {
        throw new Error("µ45666 unable to freeze circular objects");
      }
      throw error;
    }
  };

  //-----------------------------------------------------------------------------------------------------------
  thaw = function(x) {
    var error;
    try {
      return _thaw(x);
    } catch (error1) {
      error = error1;
      if (error.name === 'RangeError' && error.message === 'Maximum call stack size exceeded') {
        throw new Error("µ45667 unable to thaw circular objects");
      }
      throw error;
    }
  };

  //-----------------------------------------------------------------------------------------------------------
  _freeze = function(x) {
    var R, key, value;
    //.........................................................................................................
    if (Array.isArray(x)) {
      return Object.freeze((function() {
        var i, len, results;
        results = [];
        for (i = 0, len = x.length; i < len; i++) {
          value = x[i];
          results.push(_freeze(value));
        }
        return results;
      })());
    }
    //.........................................................................................................
    if (typeof x === 'object') {
      R = {};
      for (key in x) {
        value = x[key];
        R[key] = _freeze(value);
      }
      return Object.freeze(R);
    }
    //.........................................................................................................
    return x;
  };

  //-----------------------------------------------------------------------------------------------------------
  _thaw = function(x) {
    var R, key, value;
    //.........................................................................................................
    if (Array.isArray(x)) {
      return (function() {
        var i, len, results;
        results = [];
        for (i = 0, len = x.length; i < len; i++) {
          value = x[i];
          results.push(_thaw(value));
        }
        return results;
      })();
    }
    //.........................................................................................................
    if (typeof x === 'object') {
      R = {};
      for (key in x) {
        value = x[key];
        R[key] = thaw(value);
      }
      return R;
    }
    //.........................................................................................................
    return x;
  };

  //-----------------------------------------------------------------------------------------------------------
  lets = function(original, modifier) {
    var draft;
    draft = thaw(original);
    if (modifier != null) {
      modifier(draft);
    }
    return freeze(draft);
  };

  //-----------------------------------------------------------------------------------------------------------
  module.exports = {lets, freeze, thaw};

}).call(this);
