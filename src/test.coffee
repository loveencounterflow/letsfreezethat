'use strict'
assert                    = ( require 'assert' ).strict
log                       = console.log
type_of = ( x ) -> ( ( Object::toString.call x ).replace /^\[object ([^\]]+)\]$/, '$1' ).toLowerCase()

#-----------------------------------------------------------------------------------------------------------
@[ "freeze, modify object copy" ] = ->
  { lets, freeze, thaw, fix, } = require '..'
  d = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], }
  e = lets d, ( d ) -> d.nested.push 11
  assert.deepEqual d, ( { foo: 'bar', nested: [ 2, 3, 5, 7 ] }            ), '^lft@1^'
  assert.deepEqual e, ( { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }        ), '^lft@2^'
  assert.ok ( d isnt e                                                    ), '^lft@3^'
  assert.ok ( Object.isFrozen d                                           ), '^lft@4^'
  assert.ok ( Object.isFrozen d.nested                                    ), '^lft@5^'
  assert.ok ( Object.isFrozen e                                           ), '^lft@6^'
  assert.ok ( Object.isFrozen e.nested                                    ), '^lft@7^'

#-----------------------------------------------------------------------------------------------------------
@[ "use nofreeze option for speedup" ] = ->
  { lets, freeze, thaw, fix, } = ( require '..' ).nofreeze
  d = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], }
  e = lets d, ( d ) -> d.nested.push 11
  assert.deepEqual d, ( { foo: 'bar', nested: [ 2, 3, 5, 7 ] }            ), '^lft@8^'
  assert.deepEqual e, ( { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }        ), '^lft@9^'
  assert.ok ( d isnt e                                                    ), '^lft@10^'
  assert.ok ( not Object.isFrozen d                                           ), '^lft@11^'
  assert.ok ( not Object.isFrozen d.nested                                    ), '^lft@12^'
  assert.ok ( not Object.isFrozen e                                           ), '^lft@13^'
  assert.ok ( not Object.isFrozen e.nested                                    ), '^lft@14^'


#-----------------------------------------------------------------------------------------------------------
@[ "fix select attributes" ] = ->
  { lets, freeze, thaw, fix, } = require '..'
  d   = { foo: 'bar', }
  e   = fix d, 'sql', { query: "select * from main;", }
  assert.ok ( d is e ),                                                       '^lft@15^'
  assert.ok ( not Object.isFrozen d ),                                        '^lft@16^'
  assert.deepEqual ( Object.keys d  ), [ 'foo', 'sql', ],                     '^lft@17^'
  assert.deepEqual d, { foo: 'bar', sql: { query: 'select * from main;' } },  '^lft@18^'
  assert.throws ( -> d.sql       = 'other' ), { message: /Cannot assign to read only property/,   }, '^lft@19^'
  assert.throws ( -> d.sql.query = 'other' ), { message: /Cannot assign to read only property/, }, '^lft@20^'

#-----------------------------------------------------------------------------------------------------------
@[ "use partial freezing (1/3)" ] = ->
  ### Pretest: Ensure invariant behavior for non-special attributes (copy of first test, above): ###
  { lets, freeze, thaw, fix, } = ( require '..' ).partial
  #.........................................................................................................
  d = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], }
  e = lets d, ( d ) -> d.nested.push 11
  assert.deepEqual d, ( { foo: 'bar', nested: [ 2, 3, 5, 7 ] }            ), '^lft@21^'
  assert.deepEqual e, ( { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }        ), '^lft@22^'
  assert.ok ( d isnt e                                                    ), '^lft@23^'
  assert.ok ( Object.isFrozen d                                           ), '^lft@24^'
  assert.ok ( Object.isFrozen d.nested                                    ), '^lft@25^'
  assert.ok ( Object.isFrozen e                                           ), '^lft@26^'
  assert.ok ( Object.isFrozen e.nested                                    ), '^lft@27^'

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
  assert.ok ( ( type_of ( Object.getOwnPropertyDescriptor d, 'count' ).set ) is 'function' ),   '^lft@28^'
  assert.ok ( Object.isSealed d ),                                                              '^lft@29^'
  assert.deepEqual ( Object.keys d ), [ 'foo', 'nested', 'count', ],                            '^lft@30^'
  assert.ok ( d.count is 1                  ), '^lft@31^'
  assert.ok ( d.count is 2                  ), '^lft@32^'
  assert.ok ( ( d.count = 42 ) is 42        ), '^lft@33^'
  assert.ok ( d.count is 43                 ), '^lft@34^'
  assert.throws ( -> d.blah = 'other' ), { message: /Cannot add property blah, object is not extensible/, }, '^lft@35^'
  assert.throws ( -> d.foo  = 'other' ), { message: /Cannot assign to read only property/,                }, '^lft@36^'

#-----------------------------------------------------------------------------------------------------------
@[ "use partial freezing (3/3)" ] = ->
  { lets, freeze, thaw, fix, } = ( require '..' ).partial
  return
  #.........................................................................................................
  counter = 0
  d       = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], }
  e       = lets d, ( d ) -> d.nested.push 11
  d       = lets d, ( d ) -> Object.defineProperty d, 'count',
    enumerable:     true
    configurable:   false
    get:            -> ++counter
    set:            ( value ) -> counter = value
  assert.ok ( ( type_of ( Object.getOwnPropertyDescriptor d, 'count' ).set ) is 'function' ),   '^lft@37^'
  assert.ok ( Object.isSealed d ),                                                              '^lft@38^'
  assert.deepEqual ( Object.keys d ), [ 'foo', 'nested', 'count', ],                            '^lft@39^'
  assert.ok ( d.count is 1                  ), '^lft@40^'
  assert.ok ( d.count is 2                  ), '^lft@41^'
  assert.ok ( ( d.count = 42 ) is 42        ), '^lft@42^'
  assert.ok ( d.count is 43                 ), '^lft@43^'
  assert.throws ( -> d.blah = 'other' ), { message: /Cannot add property blah, object is not extensible/, }, '^lft@44^'
  assert.throws ( -> d.foo  = 'other' ), { message: /Cannot assign to read only property/,                }, '^lft@45^'


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


