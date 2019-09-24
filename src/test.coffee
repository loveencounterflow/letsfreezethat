'use strict'
assert                    = ( require 'assert' ).strict
log                       = console.log
{ type_of, }              = require './helpers'


#-----------------------------------------------------------------------------------------------------------
@[ "freeze, modify object copy" ] = ->
  { lets, freeze, thaw, fix, } = require '..'
  d = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], u: { v: { w: 'x', }, }, }
  e = lets d, ( d ) -> d.nested.push 11
  assert.deepEqual d, ( { foo: 'bar', nested: [ 2, 3, 5, 7 ], u: { v: { w: 'x', }, }, }     ), '^lft@100^'
  assert.deepEqual e, ( { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ], u: { v: { w: 'x', }, }, } ), '^lft@101^'
  assert.ok ( d isnt e                                                        ), '^lft@102^'
  assert.ok ( Object.isFrozen d                                               ), '^lft@103^'
  assert.ok ( Object.isFrozen d.nested                                        ), '^lft@104^'
  assert.ok ( Object.isFrozen d.u                                             ), '^lft@105^'
  assert.ok ( Object.isFrozen d.u.v                                           ), '^lft@106^'
  assert.ok ( Object.isFrozen d.u.v.w                                         ), '^lft@107^'
  assert.ok ( Object.isFrozen e                                               ), '^lft@108^'
  assert.ok ( Object.isFrozen e.nested                                        ), '^lft@109^'
  assert.ok ( Object.isFrozen e.u                                             ), '^lft@110^'
  assert.ok ( Object.isFrozen e.u.v                                           ), '^lft@111^'
  assert.ok ( Object.isFrozen e.u.v.w                                         ), '^lft@112^'
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "use nofreeze option for speedup" ] = ->
  { lets, freeze, thaw, fix, } = ( require '..' ).nofreeze
  d = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], }
  e = lets d, ( d ) -> d.nested.push 11
  assert.deepEqual d, ( { foo: 'bar', nested: [ 2, 3, 5, 7 ] }                ), '^lft@113^'
  assert.deepEqual e, ( { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }            ), '^lft@114^'
  assert.ok ( d isnt e                                                        ), '^lft@115^'
  assert.ok ( not Object.isFrozen d                                           ), '^lft@116^'
  assert.ok ( not Object.isFrozen d.nested                                    ), '^lft@117^'
  assert.ok ( not Object.isFrozen e                                           ), '^lft@118^'
  assert.ok ( not Object.isFrozen e.nested                                    ), '^lft@119^'
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "circular references cause custom error" ] = ->
  { lets, freeze, thaw, fix, } = require '..'
  d = { a: 42, }
  assert.throws ( -> d = lets d, ( d ) -> d.d = d ), { message: /unable to freeze circular/ }, '^left@xxx^'
  d = [ 4, 8, 16, ]
  # d = lets d, ( d ) -> d.push d
  assert.throws ( -> d = lets d, ( d ) -> d.push d ), { message: /unable to freeze circular/ }, '^left@xxx^'
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "fix select attributes" ] = ->
  { lets, freeze, thaw, fix, } = require '..'
  d   = { foo: 'bar', }
  e   = fix d, 'sql', { query: "select * from main;", }
  assert.ok ( d is e ),                                                       '^lft@120^'
  assert.ok ( not Object.isFrozen d ),                                        '^lft@121^'
  assert.deepEqual ( Object.keys d  ), [ 'foo', 'sql', ],                     '^lft@122^'
  assert.deepEqual d, { foo: 'bar', sql: { query: 'select * from main;' } },  '^lft@123^'
  assert.throws ( -> d.sql       = 'other' ), { message: /Cannot assign to read only property/,   }, '^lft@124^'
  assert.throws ( -> d.sql.query = 'other' ), { message: /Cannot assign to read only property/, }, '^lft@125^'
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "use partial freezing (1/3)" ] = ->
  ### Pretest: Ensure invariant behavior for non-special attributes (copy of first test, above): ###
  { lets, freeze, thaw, fix, } = ( require '..' ).partial
  #.........................................................................................................
  d = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], }
  e = lets d, ( d ) -> d.nested.push 11
  # log '^7763^', Object.getOwnPropertyDescriptor d, 'nested'
  # log '^7763^', Object.getOwnPropertyDescriptor e, 'nested'
  assert.throws ( -> d.nested.push 'other' ), { message: /Cannot add property/,             }, '^lft@126^'
  assert.throws ( -> d.foo  = 'other' ), { message: /Cannot assign to read only property/,  }, '^lft@127^'
  assert.throws ( -> d.blah = 'other' ), { message: /Cannot add property/,                  }, '^lft@128^'
  log '^5589^', d
  log '^5589^', e
  assert.deepEqual d, ( { foo: 'bar', nested: [ 2, 3, 5, 7 ] }            ), '^lft@129^'
  assert.deepEqual e, ( { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }        ), '^lft@130^'
  assert.ok ( d isnt e                                                    ), '^lft@131^'
  assert.ok ( Object.isSealed d                                           ), '^lft@132^'
  assert.ok ( Object.isSealed e                                           ), '^lft@133^'
  assert.ok ( Object.isSealed d.nested                                    ), '^lft@134^'
  assert.ok ( Object.isSealed e.nested                                    ), '^lft@135^'
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "use partial freezing (2/3)" ] = ->
  ### Pretest: test approximate 'manual' implementation of partial freezing, implemented using object
  sealing and selective `fix()`ing of attributes: ###
  { lets, freeze, thaw, fix, } = ( require '..' ).partial
  #.........................................................................................................
  counter = 0
  d       = { foo: 'bar', nested: [ 2, 3, 5, 7, ], }
  e       = d.nested.push 11
  Object.defineProperty d, 'foo',    { enumerable: true, writable: false, configurable: false, value: freeze d.foo }
  Object.defineProperty d, 'nested', { enumerable: true, writable: false, configurable: false, value: freeze d.nested }
  Object.defineProperty d, 'count',
    enumerable:     true
    configurable:   false
    get:            -> ++counter
    set:            ( value ) -> counter = value
  # log Object.getOwnPropertyDescriptors d
  Object.seal d
  #.........................................................................................................
  assert.ok ( ( type_of ( Object.getOwnPropertyDescriptor d, 'count' ).set ) is 'function' ),   '^lft@136^'
  assert.ok ( Object.isSealed d ),                                                              '^lft@137^'
  assert.deepEqual ( Object.keys d ), [ 'foo', 'nested', 'count', ],                            '^lft@138^'
  assert.ok ( d.count is 1                  ), '^lft@139^'
  assert.ok ( d.count is 2                  ), '^lft@140^'
  assert.ok ( ( d.count = 42 ) is 42        ), '^lft@141^'
  assert.ok ( d.count is 43                 ), '^lft@142^'
  assert.throws ( -> d.blah = 'other' ), { message: /Cannot add property blah, object is not extensible/, }, '^lft@143^'
  assert.throws ( -> d.foo  = 'other' ), { message: /Cannot assign to read only property/,                }, '^lft@144^'
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "use partial freezing (3/3)" ] = ->
  { lets, freeze, thaw, fix, lets_compute, } = ( require '..' ).partial
  # log '^!!!!!!!!!!!!!!!!!!!!!!!!!!^'; return
  #.........................................................................................................
  counter = 0
  d       = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], u: { v: { w: 'x', }, }, }
  e       = lets d, ( d ) -> d.nested.push 11
  d       = lets_compute d, 'count', ( -> ++counter ), ( ( x ) -> counter = x )
  # d       = lets d, ( d ) -> Object.defineProperty d, 'count',
  #   enumerable:     true
  #   configurable:   false
  #   get:            -> ++counter
  #   set:            ( value ) -> counter = value
  assert.ok ( ( type_of ( Object.getOwnPropertyDescriptor d, 'count' ).set ) is 'function' ),   '^lft@145^'
  log '^3341^', d
  log '^3341^', Object.getOwnPropertyDescriptor d, 'u'
  log '^3341^', Object.getOwnPropertyDescriptor d.u, 'v'
  log '^3341^', Object.getOwnPropertyDescriptor d.u.v, 'w'
  assert.deepEqual d.u, { v: { w: 'x', }, },                                                    '^lft@146^'
  assert.ok ( Object.isSealed d ),                                                              '^lft@147^'
  assert.ok ( Object.isSealed d.u ),                                                            '^lft@148^'
  assert.deepEqual ( Object.keys d ), [ 'foo', 'nested', 'count', ],                            '^lft@149^'
  assert.ok ( d.count is 1                  ), '^lft@150^'
  assert.ok ( d.count is 2                  ), '^lft@151^'
  assert.ok ( ( d.count = 42 ) is 42        ), '^lft@152^'
  assert.ok ( d.count is 43                 ), '^lft@153^'
  assert.throws ( -> d.blah = 'other' ), { message: /Cannot add property blah, object is not extensible/, }, '^lft@154^'
  assert.throws ( -> d.foo  = 'other' ), { message: /Cannot assign to read only property/,                }, '^lft@155^'
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "may pass in null to lets_compute as getter, setter" ] = ->
  { lets, lets_compute, } = ( require '..' ).partial
  # log '^!!!!!!!!!!!!!!!!!!!!!!!!!!^'; return
  #.........................................................................................................
  counter = 0
  d       = lets { foo: 'bar', }
  d       = lets_compute d, 'count', ( -> ++counter )
  assert.ok ( d.count is 1                  ), '^lft@156^'
  assert.ok ( d.count is 2                  ), '^lft@157^'
  #.........................................................................................................
  counter = 0
  d       = lets { foo: 'bar', }
  d       = lets_compute d, 'count', ( -> ++counter ), null
  assert.ok ( d.count is 1                  ), '^lft@158^'
  assert.ok ( d.count is 2                  ), '^lft@159^'
  #.........................................................................................................
  counter = 0
  d       = lets { foo: 'bar', }
  d       = lets_compute d, 'count', null, ( -> ++counter )
  #.........................................................................................................
  counter = 0
  d       = lets { foo: 'bar', }
  assert.throws ( -> lets_compute d, 'count', null, null ), /must define getter or setter/, '^lft@160^'

#-----------------------------------------------------------------------------------------------------------
@[ "lets_compute keeps object identity" ] = ->
  { lets, freeze, thaw, lets_compute, } = ( require '..' ).partial
  #.........................................................................................................
  class Otherclass
    constructor: ->
      @this_is_otherclass = true
    g: -> ( 'Otherclass.' + k for k of @ )
  #.........................................................................................................
  class Someclass extends Otherclass
    constructor: ->
      super()
      @this_is_someclass = true
    f: -> ( 'Someclass.' + k for k of @ )
  #.........................................................................................................
  test_something_ok = ( x, n ) ->
    tests = [
      -> assert.ok ( ( ( require 'util' ).inspect x ).startsWith 'Someclass' ), '^lft@161^' + "(##{n})"
      -> assert.deepEqual ( Object.getOwnPropertyNames x ), [ 'this_is_otherclass', 'this_is_someclass' ], '^lft@162^' + "(##{n})"
      -> assert.ok     x.hasOwnProperty 'this_is_otherclass',  '^lft@163^' + "(##{n})"
      -> assert.ok     x.hasOwnProperty 'this_is_someclass',   '^lft@164^' + "(##{n})"
      -> assert.ok not x.hasOwnProperty 'f',                   '^lft@165^' + "(##{n})"
      -> assert.ok not x.hasOwnProperty 'g',                   '^lft@166^' + "(##{n})"
      -> assert.deepEqual x.g(), [ 'Otherclass.this_is_otherclass', 'Otherclass.this_is_someclass' ], '^lft@167^' + "(##{n})"
      -> assert.deepEqual x.f(), [ 'Someclass.this_is_otherclass', 'Someclass.this_is_someclass' ], '^lft@168^' + "(##{n})"
      ]
    error_count = 0
    for test, idx in tests
      # log test.toString()
      try
        test()
      catch error
        error_count++
        log '^lft@169^', "ERROR:", error.message
    if error_count > 0
      assert.ok false, "^lft@162^(##{n}) #{error_count} tests failed"
    return null
  #.........................................................................................................
  tests = [
    #.......................................................................................................
    ->
      something = new Someclass
      test_something_ok something, '1'
    #.......................................................................................................
    ->
      something = new Someclass
      d = lets {}
      d = lets_compute d, 'something', ( -> something )
      test_something_ok d.something, '2'
    #.......................................................................................................
    ->
      something = new Someclass
      d = lets {}
      d = lets_compute d, 'something', ( -> something )
      d = freeze d
      test_something_ok d.something, '3'
    #.......................................................................................................
    ->
      something = new Someclass
      d = lets {}
      d = lets_compute d, 'something', ( -> something )
      d = thaw d
      test_something_ok d.something, '4'
    #.......................................................................................................
    ->
      something = new Someclass
      d = lets {}
      d = lets_compute d, 'something', ( -> something )
      d = lets d, ( d ) -> d.other = 42
      test_something_ok d.something, '5'
    ]
  #.........................................................................................................
  do =>
    error_count = 0
    for test in tests
      try
        test()
      catch error
        error_count++
        log '^lft@170^', "ERROR:", error.message
    if error_count > 0
      assert.ok false, "^lft@162^ #{error_count} tests failed"
    return null
  return null


############################################################################################################
if require.main is module then do =>
  error_count = 0
  for name, test of @
    log name
    try
      await test.call @
    catch error
      log "ERROR:", error.message
      error_count++
  if error_count isnt 0
    log "there were errors"
    process.exit 1
  log "ok"


