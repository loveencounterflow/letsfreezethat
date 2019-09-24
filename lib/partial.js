(function() {
  'use strict';
  var _freeze, _is_computed, _thaw, fix, freeze, lets, lets_compute, thaw;

  //-----------------------------------------------------------------------------------------------------------
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
  _is_computed = function(descriptor) {
    var keys;
    return ((keys = Object.keys(descriptor)).includes('set')) || (keys.includes('get'));
  };

  //-----------------------------------------------------------------------------------------------------------
  _freeze = function(x) {
    var R, descriptor, key, ref, value;
    //.........................................................................................................
    if (Array.isArray(x)) {
      return Object.seal((function() {
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
      ref = Object.getOwnPropertyDescriptors(x);
      for (key in ref) {
        descriptor = ref[key];
        if (_is_computed(descriptor)) {
          Object.defineProperty(R, key, descriptor);
        } else {
          if (Array.isArray(descriptor.value)) {
            descriptor.value = _freeze(descriptor.value);
          }
          descriptor.configurable = false;
          descriptor.writable = false;
          Object.defineProperty(R, key, descriptor);
        }
      }
      return Object.seal(R);
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
        R[key] = _thaw(value);
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
  lets_compute = function(original, name, get, set = null) {
    var descriptor, draft, type;
    draft = thaw(original);
    descriptor = {
      enumerable: true,
      configurable: false
    };
    if (get != null) {
      if ((type = typeof get) !== 'function') {
        throw new Error(`µ77631 expected a function, got a ${type}`);
      }
      descriptor.get = get;
    }
    if (set != null) {
      if (!(((!set) != null) || (type = typeof set) === 'function')) {
        throw new Error(`µ77631 expected a function, got a ${type}`);
      }
      descriptor.set = set;
    }
    Object.defineProperty(draft, name, descriptor);
    return freeze(draft);
  };

  //-----------------------------------------------------------------------------------------------------------
  fix = function(target, name, value) {
    Object.defineProperty(target, name, {
      enumerable: true,
      writable: false,
      configurable: false,
      value: freeze(value)
    });
    return target;
  };

  //-----------------------------------------------------------------------------------------------------------
  module.exports = {
    lets,
    freeze,
    thaw,
    fix,
    lets_compute,
    nofreeze: require('./nofreeze'),
    partial: require('./partial')
  };

}).call(this);
