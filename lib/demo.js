(function() {
  'use strict';
  var d, e, error, fix, freeze, k, lets, thaw;

  ({lets, freeze, thaw, fix} = require('..'));

  d = lets({
    foo: 'bar',
    nested: [2, 3, 5, 7]
  });

  e = lets(d, function(d) {
    return d.nested.push(11);
  });

  console.log();

  console.log();

  console.log('d                          ', d); // { foo: 'bar', nested: [ 2, 3, 5, 7 ] }

  console.log('e                          ', e); // { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }

  console.log('d is e                     ', d === e); // false

  console.log('Object.isFrozen d          ', Object.isFrozen(d)); // true

  console.log('Object.isFrozen d.nested   ', Object.isFrozen(d.nested)); // true

  console.log('Object.isFrozen e          ', Object.isFrozen(e)); // true

  console.log('Object.isFrozen e.nested   ', Object.isFrozen(e.nested)); // true

  d = {
    foo: 'bar'
  };

  console.log();

  console.log('d                          ', d); // { foo: 'bar', nested: [ 2, 3, 5, 7 ] }

  fix(d, 'sql', {
    query: "select * from main;"
  });

  console.log('d                          ', d); // { foo: 'bar', nested: [ 2, 3, 5, 7 ] }

  console.log((function() {
    var results;
    results = [];
    for (k in d) {
      results.push(k);
    }
    return results;
  })());

  try {
    d.sql = 'other';
  } catch (error1) {
    error = error1;
    console.log(error.message);
  }

  try {
    d.sql.query = 'other';
  } catch (error1) {
    error = error1;
    console.log(error.message);
  }

  console.log('d                          ', d); // { foo: 'bar', nested: [ 2, 3, 5, 7 ] }

  ({lets, freeze, thaw, fix} = (require('..')).nofreeze);

  d = lets({
    foo: 'bar',
    nested: [2, 3, 5, 7]
  });

  e = lets(d, function(d) {
    return d.nested.push(11);
  });

  console.log();

  console.log();

  console.log('d                          ', d); // { foo: 'bar', nested: [ 2, 3, 5, 7 ] }

  console.log('e                          ', e); // { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }

  console.log('d is e                     ', d === e); // false

  console.log('Object.isFrozen d          ', Object.isFrozen(d)); // true

  console.log('Object.isFrozen d.nested   ', Object.isFrozen(d.nested)); // true

  console.log('Object.isFrozen e          ', Object.isFrozen(e)); // true

  console.log('Object.isFrozen e.nested   ', Object.isFrozen(e.nested)); // true

  d = {
    foo: 'bar'
  };

  console.log();

  console.log('d                          ', d); // { foo: 'bar', nested: [ 2, 3, 5, 7 ] }

  fix(d, 'sql', {
    query: "select * from main;"
  });

  console.log('d                          ', d); // { foo: 'bar', nested: [ 2, 3, 5, 7 ] }

  console.log((function() {
    var results;
    results = [];
    for (k in d) {
      results.push(k);
    }
    return results;
  })());

  try {
    d.sql = 'other';
  } catch (error1) {
    error = error1;
    console.log(error.message);
  }

  try {
    d.sql.query = 'other';
  } catch (error1) {
    error = error1;
    console.log(error.message);
  }

  console.log('d                          ', d); // { foo: 'bar', nested: [ 2, 3, 5, 7 ] }

}).call(this);
