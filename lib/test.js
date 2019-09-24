(function() {
  'use strict';
  var assert, log, type_of;

  assert = (require('assert')).strict;

  log = console.log;

  ({type_of} = require('./helpers'));

  //-----------------------------------------------------------------------------------------------------------
  this["freeze, modify object copy"] = function() {
    var d, e, fix, freeze, lets, thaw;
    ({lets, freeze, thaw, fix} = require('..'));
    d = lets({
      foo: 'bar',
      nested: [2, 3, 5, 7],
      u: {
        v: {
          w: 'x'
        }
      }
    });
    e = lets(d, function(d) {
      return d.nested.push(11);
    });
    assert.deepEqual(d, {
      foo: 'bar',
      nested: [2, 3, 5, 7],
      u: {
        v: {
          w: 'x'
        }
      }
    }, '^lft@100^');
    assert.deepEqual(e, {
      foo: 'bar',
      nested: [2, 3, 5, 7, 11],
      u: {
        v: {
          w: 'x'
        }
      }
    }, '^lft@101^');
    assert.ok(d !== e, '^lft@102^');
    assert.ok(Object.isFrozen(d), '^lft@103^');
    assert.ok(Object.isFrozen(d.nested), '^lft@104^');
    assert.ok(Object.isFrozen(d.u), '^lft@105^');
    assert.ok(Object.isFrozen(d.u.v), '^lft@106^');
    assert.ok(Object.isFrozen(d.u.v.w), '^lft@107^');
    assert.ok(Object.isFrozen(e), '^lft@108^');
    assert.ok(Object.isFrozen(e.nested), '^lft@109^');
    assert.ok(Object.isFrozen(e.u), '^lft@110^');
    assert.ok(Object.isFrozen(e.u.v), '^lft@111^');
    assert.ok(Object.isFrozen(e.u.v.w), '^lft@112^');
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
    }, '^lft@113^');
    assert.deepEqual(e, {
      foo: 'bar',
      nested: [2, 3, 5, 7, 11]
    }, '^lft@114^');
    assert.ok(d !== e, '^lft@115^');
    assert.ok(!Object.isFrozen(d), '^lft@116^');
    assert.ok(!Object.isFrozen(d.nested), '^lft@117^');
    assert.ok(!Object.isFrozen(e), '^lft@118^');
    assert.ok(!Object.isFrozen(e.nested), '^lft@119^');
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
    assert.ok(d === e, '^lft@120^');
    assert.ok(!Object.isFrozen(d), '^lft@121^');
    assert.deepEqual(Object.keys(d), ['foo', 'sql'], '^lft@122^');
    assert.deepEqual(d, {
      foo: 'bar',
      sql: {
        query: 'select * from main;'
      }
    }, '^lft@123^');
    assert.throws((function() {
      return d.sql = 'other';
    }), {
      message: /Cannot assign to read only property/
    }, '^lft@124^');
    assert.throws((function() {
      return d.sql.query = 'other';
    }), {
      message: /Cannot assign to read only property/
    }, '^lft@125^');
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
    }, '^lft@126^');
    assert.throws((function() {
      return d.foo = 'other';
    }), {
      message: /Cannot assign to read only property/
    }, '^lft@127^');
    assert.throws((function() {
      return d.blah = 'other';
    }), {
      message: /Cannot add property/
    }, '^lft@128^');
    log('^5589^', d);
    log('^5589^', e);
    assert.deepEqual(d, {
      foo: 'bar',
      nested: [2, 3, 5, 7]
    }, '^lft@129^');
    assert.deepEqual(e, {
      foo: 'bar',
      nested: [2, 3, 5, 7, 11]
    }, '^lft@130^');
    assert.ok(d !== e, '^lft@131^');
    assert.ok(Object.isSealed(d), '^lft@132^');
    assert.ok(Object.isSealed(e), '^lft@133^');
    assert.ok(Object.isSealed(d.nested), '^lft@134^');
    assert.ok(Object.isSealed(e.nested), '^lft@135^');
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
    assert.ok((type_of((Object.getOwnPropertyDescriptor(d, 'count')).set)) === 'function', '^lft@136^');
    assert.ok(Object.isSealed(d), '^lft@137^');
    assert.deepEqual(Object.keys(d), ['foo', 'nested', 'count'], '^lft@138^');
    assert.ok(d.count === 1, '^lft@139^');
    assert.ok(d.count === 2, '^lft@140^');
    assert.ok((d.count = 42) === 42, '^lft@141^');
    assert.ok(d.count === 43, '^lft@142^');
    assert.throws((function() {
      return d.blah = 'other';
    }), {
      message: /Cannot add property blah, object is not extensible/
    }, '^lft@143^');
    assert.throws((function() {
      return d.foo = 'other';
    }), {
      message: /Cannot assign to read only property/
    }, '^lft@144^');
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
      nested: [2, 3, 5, 7],
      u: {
        v: {
          w: 'x'
        }
      }
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
    assert.ok((type_of((Object.getOwnPropertyDescriptor(d, 'count')).set)) === 'function', '^lft@145^');
    log('^3341^', d);
    log('^3341^', Object.getOwnPropertyDescriptor(d, 'u'));
    log('^3341^', Object.getOwnPropertyDescriptor(d.u, 'v'));
    log('^3341^', Object.getOwnPropertyDescriptor(d.u.v, 'w'));
    assert.deepEqual(d.u, {
      v: {
        w: 'x'
      }
    }, '^lft@146^');
    assert.ok(Object.isSealed(d), '^lft@147^');
    assert.ok(Object.isSealed(d.u), '^lft@148^');
    assert.deepEqual(Object.keys(d), ['foo', 'nested', 'count'], '^lft@149^');
    assert.ok(d.count === 1, '^lft@150^');
    assert.ok(d.count === 2, '^lft@151^');
    assert.ok((d.count = 42) === 42, '^lft@152^');
    assert.ok(d.count === 43, '^lft@153^');
    assert.throws((function() {
      return d.blah = 'other';
    }), {
      message: /Cannot add property blah, object is not extensible/
    }, '^lft@154^');
    assert.throws((function() {
      return d.foo = 'other';
    }), {
      message: /Cannot assign to read only property/
    }, '^lft@155^');
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["may pass in null to lets_compute as getter, setter"] = function() {
    var counter, d, lets, lets_compute;
    ({lets, lets_compute} = (require('..')).partial);
    // log '^!!!!!!!!!!!!!!!!!!!!!!!!!!^'; return
    //.........................................................................................................
    counter = 0;
    d = lets({
      foo: 'bar'
    });
    d = lets_compute(d, 'count', (function() {
      return ++counter;
    }));
    assert.ok(d.count === 1, '^lft@156^');
    assert.ok(d.count === 2, '^lft@157^');
    //.........................................................................................................
    counter = 0;
    d = lets({
      foo: 'bar'
    });
    d = lets_compute(d, 'count', (function() {
      return ++counter;
    }), null);
    assert.ok(d.count === 1, '^lft@158^');
    assert.ok(d.count === 2, '^lft@159^');
    //.........................................................................................................
    counter = 0;
    d = lets({
      foo: 'bar'
    });
    d = lets_compute(d, 'count', null, (function() {
      return ++counter;
    }));
    //.........................................................................................................
    counter = 0;
    d = lets({
      foo: 'bar'
    });
    return assert.throws((function() {
      return lets_compute(d, 'count', null, null);
    }), /must define getter or setter/, '^lft@160^');
  };

  //-----------------------------------------------------------------------------------------------------------
  this["lets_compute keeps object identity"] = function() {
    var Otherclass, Someclass, freeze, lets, lets_compute, test_something_ok, tests, thaw;
    ({lets, freeze, thaw, lets_compute} = (require('..')).partial);
    //.........................................................................................................
    Otherclass = class Otherclass {
      constructor() {
        this.this_is_otherclass = true;
      }

      g() {
        var k, results;
        results = [];
        for (k in this) {
          results.push('Otherclass.' + k);
        }
        return results;
      }

    };
    //.........................................................................................................
    Someclass = class Someclass extends Otherclass {
      constructor() {
        super();
        this.this_is_someclass = true;
      }

      f() {
        var k, results;
        results = [];
        for (k in this) {
          results.push('Someclass.' + k);
        }
        return results;
      }

    };
    //.........................................................................................................
    test_something_ok = function(x, n) {
      var error, error_count, i, idx, len, test, tests;
      tests = [
        function() {
          return assert.ok(((require('util')).inspect(x)).startsWith('Someclass'),
        '^lft@161^' + `(#${n})`);
        },
        function() {
          return assert.deepEqual(Object.getOwnPropertyNames(x),
        ['this_is_otherclass',
        'this_is_someclass'],
        '^lft@162^' + `(#${n})`);
        },
        function() {
          return assert.ok(x.hasOwnProperty('this_is_otherclass',
        '^lft@163^' + `(#${n})`));
        },
        function() {
          return assert.ok(x.hasOwnProperty('this_is_someclass',
        '^lft@164^' + `(#${n})`));
        },
        function() {
          return assert.ok(!x.hasOwnProperty('f',
        '^lft@165^' + `(#${n})`));
        },
        function() {
          return assert.ok(!x.hasOwnProperty('g',
        '^lft@166^' + `(#${n})`));
        },
        function() {
          return assert.deepEqual(x.g(),
        ['Otherclass.this_is_otherclass',
        'Otherclass.this_is_someclass'],
        '^lft@167^' + `(#${n})`);
        },
        function() {
          return assert.deepEqual(x.f(),
        ['Someclass.this_is_otherclass',
        'Someclass.this_is_someclass'],
        '^lft@168^' + `(#${n})`);
        }
      ];
      error_count = 0;
      for (idx = i = 0, len = tests.length; i < len; idx = ++i) {
        test = tests[idx];
        try {
          // log test.toString()
          test();
        } catch (error1) {
          error = error1;
          error_count++;
          log('^lft@169^', "ERROR:", error.message);
        }
      }
      if (error_count > 0) {
        assert.ok(false, `^lft@162^(#${n}) ${error_count} tests failed`);
      }
      return null;
    };
    //.........................................................................................................
    tests = [
      function() {        //.......................................................................................................
        var something;
        something = new Someclass;
        return test_something_ok(something,
      '1');
      },
      function() {        //.......................................................................................................
        var d,
      something;
        something = new Someclass;
        d = lets({});
        d = lets_compute(d,
      'something',
      (function() {
          return something;
        }));
        return test_something_ok(d.something,
      '2');
      },
      function() {        //.......................................................................................................
        var d,
      something;
        something = new Someclass;
        d = lets({});
        d = lets_compute(d,
      'something',
      (function() {
          return something;
        }));
        d = freeze(d);
        return test_something_ok(d.something,
      '3');
      },
      function() {        //.......................................................................................................
        var d,
      something;
        something = new Someclass;
        d = lets({});
        d = lets_compute(d,
      'something',
      (function() {
          return something;
        }));
        d = thaw(d);
        return test_something_ok(d.something,
      '4');
      },
      function() {        //.......................................................................................................
        var d,
      something;
        something = new Someclass;
        d = lets({});
        d = lets_compute(d,
      'something',
      (function() {
          return something;
        }));
        d = lets(d,
      function(d) {
          return d.other = 42;
        });
        return test_something_ok(d.something,
      '5');
      }
    ];
    (() => {      //.........................................................................................................
      var error, error_count, i, len, test;
      error_count = 0;
      for (i = 0, len = tests.length; i < len; i++) {
        test = tests[i];
        try {
          test();
        } catch (error1) {
          error = error1;
          error_count++;
          log('^lft@170^', "ERROR:", error.message);
        }
      }
      if (error_count > 0) {
        assert.ok(false, `^lft@162^ ${error_count} tests failed`);
      }
      return null;
    })();
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
