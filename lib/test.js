(function() {
  'use strict';
  var assert, log, type_of;

  assert = (require('assert')).strict;

  log = console.log;

  type_of = function(x) {
    return ((Object.prototype.toString.call(x)).replace(/^\[object ([^\]]+)\]$/, '$1')).toLowerCase();
  };

  //-----------------------------------------------------------------------------------------------------------
  this["freeze, modify object copy"] = function() {
    var d, e, fix, freeze, lets, thaw;
    ({lets, freeze, thaw, fix} = require('..'));
    d = lets({
      foo: 'bar',
      nested: [2, 3, 5, 7]
    });
    e = lets(d, function(d) {
      return d.nested.push(11);
    });
    assert.deepEqual(d, {
      foo: 'bar',
      nested: [2, 3, 5, 7]
    }, '^lft@100^');
    assert.deepEqual(e, {
      foo: 'bar',
      nested: [2, 3, 5, 7, 11]
    }, '^lft@101^');
    assert.ok(d !== e, '^lft@102^');
    assert.ok(Object.isFrozen(d), '^lft@103^');
    assert.ok(Object.isFrozen(d.nested), '^lft@104^');
    assert.ok(Object.isFrozen(e), '^lft@105^');
    assert.ok(Object.isFrozen(e.nested), '^lft@106^');
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["use nofreeze option for speedup"] = function() {
    var d, e, fix, freeze, lets, thaw;
    ({lets, freeze, thaw, fix} = (require('..')).nofreeze);
    d = lets({
      foo: 'bar',
      nested: [2, 3, 5, 7]
    });
    e = lets(d, function(d) {
      return d.nested.push(11);
    });
    assert.deepEqual(d, {
      foo: 'bar',
      nested: [2, 3, 5, 7]
    }, '^lft@107^');
    assert.deepEqual(e, {
      foo: 'bar',
      nested: [2, 3, 5, 7, 11]
    }, '^lft@108^');
    assert.ok(d !== e, '^lft@109^');
    assert.ok(!Object.isFrozen(d), '^lft@110^');
    assert.ok(!Object.isFrozen(d.nested), '^lft@111^');
    assert.ok(!Object.isFrozen(e), '^lft@112^');
    assert.ok(!Object.isFrozen(e.nested), '^lft@113^');
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["circular references cause custom error"] = function() {
    var d, fix, freeze, lets, thaw;
    ({lets, freeze, thaw, fix} = require('..'));
    d = {
      a: 42
    };
    assert.throws((function() {
      return d = lets(d, function(d) {
        return d.d = d;
      });
    }), {
      message: /unable to freeze circular/
    }, '^left@xxx^');
    d = [4, 8, 16];
    // d = lets d, ( d ) -> d.push d
    assert.throws((function() {
      return d = lets(d, function(d) {
        return d.push(d);
      });
    }), {
      message: /unable to freeze circular/
    }, '^left@xxx^');
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["fix select attributes"] = function() {
    var d, e, fix, freeze, lets, thaw;
    ({lets, freeze, thaw, fix} = require('..'));
    d = {
      foo: 'bar'
    };
    e = fix(d, 'sql', {
      query: "select * from main;"
    });
    assert.ok(d === e, '^lft@114^');
    assert.ok(!Object.isFrozen(d), '^lft@115^');
    assert.deepEqual(Object.keys(d), ['foo', 'sql'], '^lft@116^');
    assert.deepEqual(d, {
      foo: 'bar',
      sql: {
        query: 'select * from main;'
      }
    }, '^lft@117^');
    assert.throws((function() {
      return d.sql = 'other';
    }), {
      message: /Cannot assign to read only property/
    }, '^lft@118^');
    assert.throws((function() {
      return d.sql.query = 'other';
    }), {
      message: /Cannot assign to read only property/
    }, '^lft@119^');
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["use partial freezing (1/3)"] = function() {
    /* Pretest: Ensure invariant behavior for non-special attributes (copy of first test, above): */
    var d, e, fix, freeze, lets, thaw;
    ({lets, freeze, thaw, fix} = (require('..')).partial);
    //.........................................................................................................
    d = lets({
      foo: 'bar',
      nested: [2, 3, 5, 7]
    });
    e = lets(d, function(d) {
      return d.nested.push(11);
    });
    // log '^7763^', Object.getOwnPropertyDescriptor d, 'nested'
    // log '^7763^', Object.getOwnPropertyDescriptor e, 'nested'
    assert.throws((function() {
      return d.nested.push('other');
    }), {
      message: /Cannot add property/
    }, '^lft@120^');
    assert.throws((function() {
      return d.foo = 'other';
    }), {
      message: /Cannot assign to read only property/
    }, '^lft@121^');
    assert.throws((function() {
      return d.blah = 'other';
    }), {
      message: /Cannot add property/
    }, '^lft@122^');
    assert.deepEqual(d, {
      foo: 'bar',
      nested: [2, 3, 5, 7]
    }, '^lft@123^');
    assert.deepEqual(e, {
      foo: 'bar',
      nested: [2, 3, 5, 7, 11]
    }, '^lft@124^');
    assert.ok(d !== e, '^lft@125^');
    assert.ok(Object.isSealed(d), '^lft@126^');
    assert.ok(Object.isSealed(e), '^lft@127^');
    assert.ok(Object.isSealed(d.nested), '^lft@128^');
    assert.ok(Object.isSealed(e.nested), '^lft@129^');
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["use partial freezing (2/3)"] = function() {
    /* Pretest: test approximate 'manual' implementation of partial freezing, implemented using object
    sealing and selective `fix()`ing of attributes: */
    var counter, d, e, fix, freeze, lets, thaw;
    ({lets, freeze, thaw, fix} = (require('..')).partial);
    //.........................................................................................................
    counter = 0;
    d = {
      foo: 'bar',
      nested: [2, 3, 5, 7]
    };
    e = d.nested.push(11);
    Object.defineProperty(d, 'foo', {
      enumerable: true,
      writable: false,
      configurable: false,
      value: freeze(d.foo)
    });
    Object.defineProperty(d, 'nested', {
      enumerable: true,
      writable: false,
      configurable: false,
      value: freeze(d.nested)
    });
    Object.defineProperty(d, 'count', {
      enumerable: true,
      configurable: false,
      get: function() {
        return ++counter;
      },
      set: function(value) {
        return counter = value;
      }
    });
    // log Object.getOwnPropertyDescriptors d
    Object.seal(d);
    //.........................................................................................................
    assert.ok((type_of((Object.getOwnPropertyDescriptor(d, 'count')).set)) === 'function', '^lft@130^');
    assert.ok(Object.isSealed(d), '^lft@131^');
    assert.deepEqual(Object.keys(d), ['foo', 'nested', 'count'], '^lft@132^');
    assert.ok(d.count === 1, '^lft@133^');
    assert.ok(d.count === 2, '^lft@134^');
    assert.ok((d.count = 42) === 42, '^lft@135^');
    assert.ok(d.count === 43, '^lft@136^');
    assert.throws((function() {
      return d.blah = 'other';
    }), {
      message: /Cannot add property blah, object is not extensible/
    }, '^lft@137^');
    assert.throws((function() {
      return d.foo = 'other';
    }), {
      message: /Cannot assign to read only property/
    }, '^lft@138^');
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["use partial freezing (3/3)"] = function() {
    var counter, d, e, fix, freeze, lets, lets_compute, thaw;
    ({lets, freeze, thaw, fix, lets_compute} = (require('..')).partial);
    // log '^!!!!!!!!!!!!!!!!!!!!!!!!!!^'; return
    //.........................................................................................................
    counter = 0;
    d = lets({
      foo: 'bar',
      nested: [2, 3, 5, 7]
    });
    e = lets(d, function(d) {
      return d.nested.push(11);
    });
    d = lets_compute(d, 'count', (function() {
      return ++counter;
    }), (function(x) {
      return counter = x;
    }));
    // d       = lets d, ( d ) -> Object.defineProperty d, 'count',
    //   enumerable:     true
    //   configurable:   false
    //   get:            -> ++counter
    //   set:            ( value ) -> counter = value
    assert.ok((type_of((Object.getOwnPropertyDescriptor(d, 'count')).set)) === 'function', '^lft@139^');
    assert.ok(Object.isSealed(d), '^lft@140^');
    assert.deepEqual(Object.keys(d), ['foo', 'nested', 'count'], '^lft@141^');
    assert.ok(d.count === 1, '^lft@142^');
    assert.ok(d.count === 2, '^lft@143^');
    assert.ok((d.count = 42) === 42, '^lft@144^');
    assert.ok(d.count === 43, '^lft@145^');
    assert.throws((function() {
      return d.blah = 'other';
    }), {
      message: /Cannot add property blah, object is not extensible/
    }, '^lft@146^');
    assert.throws((function() {
      return d.foo = 'other';
    }), {
      message: /Cannot assign to read only property/
    }, '^lft@147^');
    return null;
  };

  //###########################################################################################################
  if (require.main === module) {
    (async() => {
      var error, error_count, name, ref, test;
      error_count = 0;
      ref = this;
      for (name in ref) {
        test = ref[name];
        log(name);
        try {
          await test.call(this);
        } catch (error1) {
          error = error1;
          log("ERROR:", error.message);
          error_count++;
        }
      }
      if (error_count !== 0) {
        log("there were errors");
        process.exit(1);
      }
      return log("ok");
    })();
  }

}).call(this);
