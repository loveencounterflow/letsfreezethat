(function() {
  'use strict';
  var CND, Multimix, alert, assign, badge, debug, deep_copy, deep_freeze, echo, freeze_lets, frozen, help, info, lets, log, nofreeze_lets, rpr, shallow_copy, shallow_freeze, urge, warn, whisper;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'LFTNG';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  Multimix = require('multimix');

  //...........................................................................................................
  frozen = Object.isFrozen;

  assign = Object.assign;

  shallow_freeze = Object.freeze;

  shallow_copy = function(x, ...P) {
    return assign((Array.isArray(x) ? [] : {}), x, ...P);
  };

  ({
    klona: deep_copy
  } = require('klona/json'));

  //===========================================================================================================
  deep_freeze = function(d) {
    var k, v;
    if ((!d) || d === true) {
      /* immediately return for zero, empty string, null, undefined, NaN, false, true: */
      return d;
    }
    /* thx to https://github.com/lukeed/klona/blob/master/src/json.js */
    switch (Object.prototype.toString.call(d)) {
      case '[object Array]':
        k = d.length;
        while (k--) {
          if (!(((v = d[k]) != null) && ((typeof v) === 'object'))) {
            continue;
          }
          d[k] = deep_freeze(v);
        }
        return shallow_freeze(d);
      case '[object Object]':
        for (k in d) {
          v = d[k];
          if (!((v != null) && ((typeof v) === 'object'))) {
            continue;
          }
          d[k] = deep_freeze(v);
        }
        return shallow_freeze(d);
    }
    return d;
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  freeze_lets = lets = function(original, modifier) {
    var draft;
    draft = this.thaw(original);
    if (modifier != null) {
      modifier(draft);
    }
    return deep_freeze(draft);
  };

  //-----------------------------------------------------------------------------------------------------------
  freeze_lets.assign = function(me, ...P) {
    return deep_freeze(deep_copy(shallow_copy(me, ...P)));
  };

  freeze_lets.freeze = function(me) {
    return deep_freeze(me);
  };

  freeze_lets.thaw = function(me) {
    return deep_copy(me);
  };

  freeze_lets.get = function(me, k) {
    return me[k];
  };

  freeze_lets.set = function(me, k, v) {
    var R;
    R = shallow_copy(me);
    R[k] = v;
    return shallow_freeze(R);
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  nofreeze_lets = function(original, modifier) {
    var draft;
    draft = this.thaw(original);
    if (modifier != null) {
      modifier(draft);
    }
    /* TAINT do not copy */
    return deep_copy(draft);
  };

  //-----------------------------------------------------------------------------------------------------------
  nofreeze_lets.assign = function(me, ...P) {
    return deep_copy(shallow_copy(me, ...P));
  };

  nofreeze_lets.freeze = function(me) {
    return me;
  };

  nofreeze_lets.thaw = function(me) {
    return deep_copy(me);
  };

  nofreeze_lets.get = freeze_lets.get;

  nofreeze_lets.set = function(me, k, v) {
    var R;
    R = shallow_copy(me);
    R[k] = v;
    return R;
  };

  //===========================================================================================================

  //-----------------------------------------------------------------------------------------------------------
  module.exports = {freeze_lets, nofreeze_lets};

}).call(this);

//# sourceMappingURL=main.js.map