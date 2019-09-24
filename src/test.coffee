'use strict'
assert                    = ( require 'assert' ).strict
log                       = console.log
type_of = ( x ) -> ( ( Object::toString.call x ).replace /^\[object ([^\]]+)\]$/, '$1' ).toLowerCase()

#-----------------------------------------------------------------------------------------------------------
@[ "freeze, modify object copy" ] = ->
  { lets, freeze, thaw, fix, } = require '..'
  d = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], }
  e = lets d, ( d ) -> d.nested.push 11
  assert.deepEqual d, ( { foo: 'bar', nested: [ 2, 3, 5, 7 ] }            ), '^lft@100^'
  assert.deepEqual e, ( { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }        ), '^lft@101^'
  assert.ok ( d isnt e                                                    ), '^lft@102^'
  assert.ok ( Object.isFrozen d                                           ), '^lft@103^'
  assert.ok ( Object.isFrozen d.nested                                    ), '^lft@104^'
  assert.ok ( Object.isFrozen e                                           ), '^lft@105^'
  assert.ok ( Object.isFrozen e.nested                                    ), '^lft@106^'
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "use nofreeze option for speedup" ] = ->
  { lets, freeze, thaw, fix, } = ( require '..' ).nofreeze
  d = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], }
  e = lets d, ( d ) -> d.nested.push 11
  assert.deepEqual d, ( { foo: 'bar', nested: [ 2, 3, 5, 7 ] }                ), '^lft@107^'
  assert.deepEqual e, ( { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }            ), '^lft@108^'
  assert.ok ( d isnt e                                                        ), '^lft@109^'
  assert.ok ( not Object.isFrozen d                                           ), '^lft@110^'
  assert.ok ( not Object.isFrozen d.nested                                    ), '^lft@111^'
  assert.ok ( not Object.isFrozen e                                           ), '^lft@112^'
  assert.ok ( not Object.isFrozen e.nested                                    ), '^lft@113^'
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
  assert.ok ( d is e ),                                                       '^lft@114^'
  assert.ok ( not Object.isFrozen d ),                                        '^lft@115^'
  assert.deepEqual ( Object.keys d  ), [ 'foo', 'sql', ],                     '^lft@116^'
  assert.deepEqual d, { foo: 'bar', sql: { query: 'select * from main;' } },  '^lft@117^'
  assert.throws ( -> d.sql       = 'other' ), { message: /Cannot assign to read only property/,   }, '^lft@118^'
  assert.throws ( -> d.sql.query = 'other' ), { message: /Cannot assign to read only property/, }, '^lft@119^'
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
  assert.throws ( -> d.nested.push 'other' ), { message: /Cannot add property/,             }, '^lft@120^'
  assert.throws ( -> d.foo  = 'other' ), { message: /Cannot assign to read only property/,  }, '^lft@121^'
  assert.throws ( -> d.blah = 'other' ), { message: /Cannot add property/,                  }, '^lft@122^'
  assert.deepEqual d, ( { foo: 'bar', nested: [ 2, 3, 5, 7 ] }            ), '^lft@123^'
  assert.deepEqual e, ( { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }        ), '^lft@124^'
  assert.ok ( d isnt e                                                    ), '^lft@125^'
  assert.ok ( Object.isSealed d                                           ), '^lft@126^'
  assert.ok ( Object.isSealed e                                           ), '^lft@127^'
  assert.ok ( Object.isSealed d.nested                                    ), '^lft@128^'
  assert.ok ( Object.isSealed e.nested                                    ), '^lft@129^'
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
  assert.ok ( ( type_of ( Object.getOwnPropertyDescriptor d, 'count' ).set ) is 'function' ),   '^lft@130^'
  assert.ok ( Object.isSealed d ),                                                              '^lft@131^'
  assert.deepEqual ( Object.keys d ), [ 'foo', 'nested', 'count', ],                            '^lft@132^'
  assert.ok ( d.count is 1                  ), '^lft@133^'
  assert.ok ( d.count is 2                  ), '^lft@134^'
  assert.ok ( ( d.count = 42 ) is 42        ), '^lft@135^'
  assert.ok ( d.count is 43                 ), '^lft@136^'
  assert.throws ( -> d.blah = 'other' ), { message: /Cannot add property blah, object is not extensible/, }, '^lft@137^'
  assert.throws ( -> d.foo  = 'other' ), { message: /Cannot assign to read only property/,                }, '^lft@138^'
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "use partial freezing (3/3)" ] = ->
  { lets, freeze, thaw, fix, } = ( require '..' ).partial
  # log '^!!!!!!!!!!!!!!!!!!!!!!!!!!^'; return
  #.........................................................................................................
  counter = 0
  d       = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], }
  e       = lets d, ( d ) -> d.nested.push 11
  d       = lets d, ( d ) -> Object.defineProperty d, 'count',
    enumerable:     true
    configurable:   false
    get:            -> ++counter
    set:            ( value ) -> counter = value
  assert.ok ( ( type_of ( Object.getOwnPropertyDescriptor d, 'count' ).set ) is 'function' ),   '^lft@139^'
  assert.ok ( Object.isSealed d ),                                                              '^lft@140^'
  assert.deepEqual ( Object.keys d ), [ 'foo', 'nested', 'count', ],                            '^lft@141^'
  assert.ok ( d.count is 1                  ), '^lft@142^'
  assert.ok ( d.count is 2                  ), '^lft@143^'
  assert.ok ( ( d.count = 42 ) is 42        ), '^lft@144^'
  assert.ok ( d.count is 43                 ), '^lft@145^'
  assert.throws ( -> d.blah = 'other' ), { message: /Cannot add property blah, object is not extensible/, }, '^lft@146^'
  assert.throws ( -> d.foo  = 'other' ), { message: /Cannot assign to read only property/,                }, '^lft@147^'
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


