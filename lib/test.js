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
    }, '^lft@1^');
    assert.deepEqual(e, {
      foo: 'bar',
      nested: [2, 3, 5, 7, 11],
      u: {
        v: {
          w: 'x'
        }
      }
    }, '^lft@2^');
    assert.ok(d !== e, '^lft@3^');
    assert.ok(Object.isFrozen(d), '^lft@4^');
    assert.ok(Object.isFrozen(d.nested), '^lft@5^');
    assert.ok(Object.isFrozen(d.u), '^lft@6^');
    assert.ok(Object.isFrozen(d.u.v), '^lft@7^');
    assert.ok(Object.isFrozen(d.u.v.w), '^lft@8^');
    assert.ok(Object.isFrozen(e), '^lft@9^');
    assert.ok(Object.isFrozen(e.nested), '^lft@10^');
    assert.ok(Object.isFrozen(e.u), '^lft@11^');
    assert.ok(Object.isFrozen(e.u.v), '^lft@12^');
    assert.ok(Object.isFrozen(e.u.v.w), '^lft@13^');
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
    }, '^lft@14^');
    assert.deepEqual(e, {
      foo: 'bar',
      nested: [2, 3, 5, 7, 11]
    }, '^lft@15^');
    assert.ok(d !== e, '^lft@16^');
    assert.ok(!Object.isFrozen(d), '^lft@17^');
    assert.ok(!Object.isFrozen(d.nested), '^lft@18^');
    assert.ok(!Object.isFrozen(e), '^lft@19^');
    assert.ok(!Object.isFrozen(e.nested), '^lft@20^');
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
    assert.ok(d === e, '^lft@21^');
    assert.ok(!Object.isFrozen(d), '^lft@22^');
    assert.deepEqual(Object.keys(d), ['foo', 'sql'], '^lft@23^');
    assert.deepEqual(d, {
      foo: 'bar',
      sql: {
        query: 'select * from main;'
      }
    }, '^lft@24^');
    assert.throws((function() {
      return d.sql = 'other';
    }), {
      message: /Cannot assign to read only property/
    }, '^lft@25^');
    assert.throws((function() {
      return d.sql.query = 'other';
    }), {
      message: /Cannot assign to read only property/
    }, '^lft@26^');
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["use partial freezing (1/3)"] = function() {
    /* Pretest: Ensure invariant behavior for non-special attributes (copy of first test, above): */
    var d, d2, d_thawed, e, fix, freeze, is_readonly, lets, matcher_a, matcher_b, matcher_c, thaw;
    ({lets, freeze, thaw, fix} = (require('..')).partial);
    is_readonly = function(d, key) {
      var descriptor;
      descriptor = Object.getOwnPropertyDescriptor(d, key);
      return (!descriptor.writable) && (!descriptor.configurable);
    };
    //.........................................................................................................
    matcher_a = {
      foo: 'bar',
      nested: [2, 3, 5, 7],
      u: {
        v: {
          w: 'x'
        }
      }
    };
    matcher_b = {
      foo: 'bar',
      nested: [2, 3, 5, 7, 11],
      u: {
        v: {
          w: 'x'
        }
      }
    };
    matcher_c = {
      foo: 'other',
      nested: [2, 3, 5, 7, 'other'],
      u: {
        v: {
          w: 'other'
        }
      },
      blah: 'other'
    };
    d = lets(matcher_a);
    e = lets(d, function(d) {
      return d.nested.push(11);
    });
    assert.ok(d !== e, '^lft@27^');
    assert.ok(d !== matcher_a, '^lft@28^');
    assert.deepEqual(d, matcher_a, '^lft@29^');
    assert.deepEqual(e, matcher_b, '^lft@30^');
    assert.ok(is_readonly(d, 'nested'), '^lft@31^');
    assert.ok(is_readonly(d, 'u'), '^lft@32^');
    assert.ok(is_readonly(d.u, 'v'), '^lft@33^');
    assert.ok(is_readonly(d.u.v, 'w'), '^lft@34^');
    assert.ok(Object.isSealed(d), '^lft@35^');
    assert.ok(Object.isSealed(d.nested), '^lft@36^');
    assert.ok(Object.isSealed(d.u), '^lft@37^');
    assert.ok(Object.isSealed(d.u.v), '^lft@38^');
    assert.ok(Object.isSealed(e), '^lft@39^');
    assert.ok(Object.isSealed(e.nested), '^lft@40^');
    assert.ok(Object.isSealed(e.u), '^lft@41^');
    assert.ok(Object.isSealed(e.u.v), '^lft@42^');
    assert.throws((function() {
      return d.nested.push('other');
    }), {
      message: /Cannot add property/
    }, '^lft@43^');
    assert.throws((function() {
      return d.foo = 'other';
    }), {
      message: /Cannot assign to read only property/
    }, '^lft@44^');
    assert.throws((function() {
      return d.blah = 'other';
    }), {
      message: /Cannot add property/
    }, '^lft@45^');
    //.........................................................................................................
    d2 = lets(d, function(d_copy) {
      assert.ok(d !== d_copy, '^lft@46^');
      assert.ok(!is_readonly(d_copy, 'nested'), '^lft@47^');
      assert.ok(!is_readonly(d_copy, 'u'), '^lft@48^');
      assert.ok(!is_readonly(d_copy.u, 'v'), '^lft@49^');
      assert.ok(!is_readonly(d_copy.u.v, 'w'), '^lft@50^');
      assert.ok(!Object.isSealed(d_copy), '^lft@51^');
      assert.ok(!Object.isSealed(d_copy.nested), '^lft@52^');
      assert.ok(!Object.isSealed(d_copy.u), '^lft@53^');
      assert.ok(!Object.isSealed(d_copy.u.v), '^lft@54^');
      try {
        d_copy.nested.push('other');
      } catch (error1) {
        e = error1;
        throw new Error('^lft@55^ ' + e.message);
      }
      try {
        d_copy.foo = 'other';
      } catch (error1) {
        e = error1;
        throw new Error('^lft@56^ ' + e.message);
      }
      try {
        d_copy.blah = 'other';
      } catch (error1) {
        e = error1;
        throw new Error('^lft@57^ ' + e.message);
      }
      try {
        return d_copy.u.v.w = 'other';
      } catch (error1) {
        e = error1;
        throw new Error('^lft@58^ ' + e.message);
      }
    });
    assert.ok(d2 !== d, '^lft@59^');
    assert.deepEqual(d, matcher_a, '^lft@60^');
    assert.deepEqual(d2, matcher_c, '^lft@61^');
    //.........................................................................................................
    d_thawed = thaw(d);
    assert.deepEqual(d_thawed, d, '^lft@62^');
    assert.ok(d !== d_thawed, '^lft@63^');
    assert.ok(!is_readonly(d_thawed, 'nested'), '^lft@64^');
    assert.ok(!is_readonly(d_thawed, 'u'), '^lft@65^');
    assert.ok(!is_readonly(d_thawed.u, 'v'), '^lft@66^');
    assert.ok(!is_readonly(d_thawed.u.v, 'w'), '^lft@67^');
    assert.ok(!Object.isSealed(d_thawed), '^lft@68^');
    assert.ok(!Object.isSealed(d_thawed.nested), '^lft@69^');
    assert.ok(!Object.isSealed(d_thawed.u), '^lft@70^');
    assert.ok(!Object.isSealed(d_thawed.u.v), '^lft@71^');
    try {
      d_thawed.nested.push('other');
    } catch (error1) {
      e = error1;
      throw new Error('^lft@72^ ' + e.message);
    }
    try {
      d_thawed.foo = 'other';
    } catch (error1) {
      e = error1;
      throw new Error('^lft@73^ ' + e.message);
    }
    try {
      d_thawed.blah = 'other';
    } catch (error1) {
      e = error1;
      throw new Error('^lft@74^ ' + e.message);
    }
    try {
      d_thawed.u.v.w = 'other';
    } catch (error1) {
      e = error1;
      throw new Error('^lft@75^ ' + e.message);
    }
    assert.deepEqual(d_thawed, matcher_c, '^lft@76^');
    //.........................................................................................................
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["use partial freezing (2/3)"] = function() {
    /* Pretest: test approximate 'manual' implementation of partial freezing, implemented using object
    sealing and selective `fix()`ing of attributes: */
    var counter, d, e, fix, freeze, lets, open_vz, thaw;
    ({lets, freeze, thaw, fix} = (require('..')).partial);
    //.........................................................................................................
    counter = 0;
    d = {
      foo: 'bar',
      nested: [2, 3, 5, 7],
      u: {
        v: {
          w: 'x'
        }
      }
    };
    e = d.nested.push(11);
    open_vz = {
      a: 123
    };
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
    Object.defineProperty(d, 'open_vz', {
      enumerable: true,
      configurable: false,
      get: function() {
        return open_vz;
      }
    });
    // log Object.getOwnPropertyDescriptors d
    Object.seal(d);
    //.........................................................................................................
    assert.ok((type_of((Object.getOwnPropertyDescriptor(d, 'count')).set)) === 'function', '^lft@77^');
    assert.ok(Object.isSealed(d), '^lft@78^');
    assert.deepEqual(Object.keys(d), ['foo', 'nested', 'u', 'count', 'open_vz'], '^lft@79^');
    assert.ok(d.count === 1, '^lft@80^');
    assert.ok(d.count === 2, '^lft@81^');
    assert.ok((d.count = 42) === 42, '^lft@82^');
    assert.ok(d.count === 43, '^lft@83^');
    assert.throws((function() {
      return d.blah = 'other';
    }), {
      message: /Cannot add property blah, object is not extensible/
    }, '^lft@84^');
    assert.throws((function() {
      return d.foo = 'other';
    }), {
      message: /Cannot assign to read only property/
    }, '^lft@85^');
    try {
      d.open_vz.new_property = 42;
    } catch (error1) {
      e = error1;
      throw new Error('^lft@86^ ' + e.message);
    }
    assert.deepEqual(d.open_vz.new_property, 42, '^lft@87^');
    return null;
  };

  //-----------------------------------------------------------------------------------------------------------
  this["use partial freezing (3/3)"] = function() {
    var counter, d, e, fix, freeze, lets, lets_compute, open_vz, thaw;
    ({lets, freeze, thaw, fix, lets_compute} = (require('..')).partial);
    //.........................................................................................................
    counter = 0;
    open_vz = {
      a: 123
    };
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
    d = lets_compute(d, 'open_vz', (function() {
      return open_vz;
    }));
    assert.ok((type_of((Object.getOwnPropertyDescriptor(d, 'count')).set)) === 'function', '^lft@88^');
    assert.ok(d.count === 1, '^lft@89^');
    assert.ok(d.count === 2, '^lft@90^');
    assert.ok((d.count = 42) === 42, '^lft@91^');
    assert.ok(d.count === 43, '^lft@92^');
    assert.ok(d.open_vz === open_vz, '^lft@93^');
    try {
      d.open_vz.new_property = 'new value';
    } catch (error1) {
      e = error1;
      throw new Error('^lft@94^ ' + e.message);
    }
    assert.ok(d.open_vz === open_vz, '^lft@93^');
    assert.deepEqual(open_vz, {
      a: 123,
      new_property: 'new value'
    }, '^lft@93^');
    assert.throws((function() {
      return d.blah = 'other';
    }), {
      message: /Cannot add property blah, object is not extensible/
    }, '^lft@84^');
    assert.throws((function() {
      return d.foo = 'other';
    }), {
      message: /Cannot assign to read only property/
    }, '^lft@85^');
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
    assert.ok(d.count === 1, '^lft@95^');
    assert.ok(d.count === 2, '^lft@96^');
    //.........................................................................................................
    counter = 0;
    d = lets({
      foo: 'bar'
    });
    d = lets_compute(d, 'count', (function() {
      return ++counter;
    }), null);
    assert.ok(d.count === 1, '^lft@97^');
    assert.ok(d.count === 2, '^lft@98^');
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
    }), /must define getter or setter/, '^lft@99^');
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
        '^lft@100^' + `(#${n})`);
        },
        function() {
          return assert.deepEqual(Object.getOwnPropertyNames(x),
        ['this_is_otherclass',
        'this_is_someclass'],
        '^lft@101^' + `(#${n})`);
        },
        function() {
          return assert.ok(x.hasOwnProperty('this_is_otherclass',
        '^lft@102^' + `(#${n})`));
        },
        function() {
          return assert.ok(x.hasOwnProperty('this_is_someclass',
        '^lft@103^' + `(#${n})`));
        },
        function() {
          return assert.ok(!x.hasOwnProperty('f',
        '^lft@104^' + `(#${n})`));
        },
        function() {
          return assert.ok(!x.hasOwnProperty('g',
        '^lft@105^' + `(#${n})`));
        },
        function() {
          return assert.deepEqual(x.g(),
        ['Otherclass.this_is_otherclass',
        'Otherclass.this_is_someclass'],
        '^lft@106^' + `(#${n})`);
        },
        function() {
          return assert.deepEqual(x.f(),
        ['Someclass.this_is_otherclass',
        'Someclass.this_is_someclass'],
        '^lft@107^' + `(#${n})`);
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
          log('^lft@108^', "ERROR:", error.message);
        }
      }
      if (error_count > 0) {
        assert.ok(false, `^lft@86^(#${n}) ${error_count} tests failed`);
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
          log('^lft@109^', "ERROR:", error.message);
        }
      }
      if (error_count > 0) {
        assert.ok(false, `^lft@88^ ${error_count} tests failed`);
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
