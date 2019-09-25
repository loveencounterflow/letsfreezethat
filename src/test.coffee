'use strict'
assert                    = ( require 'assert' ).strict
log                       = console.log
{ type_of, }              = require './helpers'


#-----------------------------------------------------------------------------------------------------------
@[ "freeze, modify object copy" ] = ->
  { lets, freeze, thaw, fix, } = require '..'
  d = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], u: { v: { w: 'x', }, }, }
  e = lets d, ( d ) -> d.nested.push 11
  assert.deepEqual d, ( { foo: 'bar', nested: [ 2, 3, 5, 7 ], u: { v: { w: 'x', }, }, }     ), '^lft@1^'
  assert.deepEqual e, ( { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ], u: { v: { w: 'x', }, }, } ), '^lft@2^'
  assert.ok ( d isnt e                                                        ), '^lft@3^'
  assert.ok ( Object.isFrozen d                                               ), '^lft@4^'
  assert.ok ( Object.isFrozen d.nested                                        ), '^lft@5^'
  assert.ok ( Object.isFrozen d.u                                             ), '^lft@6^'
  assert.ok ( Object.isFrozen d.u.v                                           ), '^lft@7^'
  assert.ok ( Object.isFrozen d.u.v.w                                         ), '^lft@8^'
  assert.ok ( Object.isFrozen e                                               ), '^lft@9^'
  assert.ok ( Object.isFrozen e.nested                                        ), '^lft@10^'
  assert.ok ( Object.isFrozen e.u                                             ), '^lft@11^'
  assert.ok ( Object.isFrozen e.u.v                                           ), '^lft@12^'
  assert.ok ( Object.isFrozen e.u.v.w                                         ), '^lft@13^'
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "use nofreeze option for speedup" ] = ->
  { lets, freeze, thaw, fix, } = ( require '..' ).nofreeze
  d = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], }
  e = lets d, ( d ) -> d.nested.push 11
  assert.deepEqual d, ( { foo: 'bar', nested: [ 2, 3, 5, 7 ] }                ), '^lft@14^'
  assert.deepEqual e, ( { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }            ), '^lft@15^'
  assert.ok ( d isnt e                                                        ), '^lft@16^'
  assert.ok ( not Object.isFrozen d                                           ), '^lft@17^'
  assert.ok ( not Object.isFrozen d.nested                                    ), '^lft@18^'
  assert.ok ( not Object.isFrozen e                                           ), '^lft@19^'
  assert.ok ( not Object.isFrozen e.nested                                    ), '^lft@20^'
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
  assert.ok ( d is e ),                                                       '^lft@21^'
  assert.ok ( not Object.isFrozen d ),                                        '^lft@22^'
  assert.deepEqual ( Object.keys d  ), [ 'foo', 'sql', ],                     '^lft@23^'
  assert.deepEqual d, { foo: 'bar', sql: { query: 'select * from main;' } },  '^lft@24^'
  assert.throws ( -> d.sql       = 'other' ), { message: /Cannot assign to read only property/,   }, '^lft@25^'
  assert.throws ( -> d.sql.query = 'other' ), { message: /Cannot assign to read only property/, }, '^lft@26^'
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "use partial freezing (1/3)" ] = ->
  ### Pretest: Ensure invariant behavior for non-special attributes (copy of first test, above): ###
  { lets, freeze, thaw, fix, } = ( require '..' ).partial
  is_readonly = ( d, key ) ->
    descriptor = Object.getOwnPropertyDescriptor d, key
    return ( not descriptor.writable ) and ( not descriptor.configurable )
  #.........................................................................................................
  matcher_a = { foo: 'bar',   nested: [ 2, 3, 5, 7,          ], u: { v: { w: 'x',     }, }, }
  matcher_b = { foo: 'bar',   nested: [ 2, 3, 5, 7, 11,      ], u: { v: { w: 'x',     }, }, }
  matcher_c = { foo: 'other', nested: [ 2, 3, 5, 7, 'other', ], u: { v: { w: 'other', }, }, blah: 'other', }
  d         = lets matcher_a
  e         = lets d, ( d ) -> d.nested.push 11
  assert.ok ( d isnt e                      ), '^lft@27^'
  assert.ok ( d isnt matcher_a              ), '^lft@28^'
  assert.deepEqual d, matcher_a,               '^lft@29^'
  assert.deepEqual e, matcher_b,               '^lft@30^'
  assert.ok ( is_readonly d,      'nested'  ), '^lft@31^'
  assert.ok ( is_readonly d,      'u'       ), '^lft@32^'
  assert.ok ( is_readonly d.u,    'v'       ), '^lft@33^'
  assert.ok ( is_readonly d.u.v,  'w'       ), '^lft@34^'
  assert.ok ( Object.isSealed d             ), '^lft@35^'
  assert.ok ( Object.isSealed d.nested      ), '^lft@36^'
  assert.ok ( Object.isSealed d.u           ), '^lft@37^'
  assert.ok ( Object.isSealed d.u.v         ), '^lft@38^'
  assert.ok ( Object.isSealed d.u.v.w       ), '^lft@39^'
  assert.ok ( Object.isSealed e             ), '^lft@40^'
  assert.ok ( Object.isSealed e.nested      ), '^lft@41^'
  assert.ok ( Object.isSealed e.u           ), '^lft@42^'
  assert.ok ( Object.isSealed e.u.v         ), '^lft@43^'
  assert.ok ( Object.isSealed e.u.v.w       ), '^lft@44^'
  assert.throws ( -> d.nested.push 'other' ), { message: /Cannot add property/,             }, '^lft@45^'
  assert.throws ( -> d.foo  = 'other' ), { message: /Cannot assign to read only property/,  }, '^lft@46^'
  assert.throws ( -> d.blah = 'other' ), { message: /Cannot add property/,                  }, '^lft@47^'
  #.........................................................................................................
  d2 = lets d, ( d_copy ) ->
    assert.ok ( d isnt d_copy ),  '^lft@48^'
    assert.ok ( not is_readonly d_copy,      'nested'  ), '^lft@49^'
    assert.ok ( not is_readonly d_copy,      'u'       ), '^lft@50^'
    assert.ok ( not is_readonly d_copy.u,    'v'       ), '^lft@51^'
    assert.ok ( not is_readonly d_copy.u.v,  'w'       ), '^lft@52^'
    assert.ok ( not Object.isSealed d_copy             ), '^lft@53^'
    assert.ok ( not Object.isSealed d_copy.nested      ), '^lft@54^'
    assert.ok ( not Object.isSealed d_copy.u           ), '^lft@55^'
    assert.ok ( not Object.isSealed d_copy.u.v         ), '^lft@56^'
    try d_copy.nested.push 'other' catch e then throw new Error '^lft@57^ ' + e.message
    try d_copy.foo  = 'other'      catch e then throw new Error '^lft@58^ ' + e.message
    try d_copy.blah = 'other'      catch e then throw new Error '^lft@59^ ' + e.message
    try d_copy.u.v.w = 'other'     catch e then throw new Error '^lft@60^ ' + e.message
  assert.ok ( d2 isnt d ), '^lft@61^'
  assert.deepEqual d,  matcher_a,               '^lft@62^'
  assert.deepEqual d2, matcher_c,               '^lft@63^'
  #.........................................................................................................
  d_thawed = thaw d
  assert.deepEqual d_thawed, d,                           '^lft@64^'
  assert.ok ( d isnt d_thawed ),                          '^lft@65^'
  assert.ok ( not is_readonly d_thawed,      'nested'  ), '^lft@66^'
  assert.ok ( not is_readonly d_thawed,      'u'       ), '^lft@67^'
  assert.ok ( not is_readonly d_thawed.u,    'v'       ), '^lft@68^'
  assert.ok ( not is_readonly d_thawed.u.v,  'w'       ), '^lft@69^'
  assert.ok ( not Object.isSealed d_thawed             ), '^lft@70^'
  assert.ok ( not Object.isSealed d_thawed.nested      ), '^lft@71^'
  assert.ok ( not Object.isSealed d_thawed.u           ), '^lft@72^'
  assert.ok ( not Object.isSealed d_thawed.u.v         ), '^lft@73^'
  try d_thawed.nested.push 'other' catch e then throw new Error '^lft@74^ ' + e.message
  try d_thawed.foo  = 'other'      catch e then throw new Error '^lft@75^ ' + e.message
  try d_thawed.blah = 'other'      catch e then throw new Error '^lft@76^ ' + e.message
  try d_thawed.u.v.w = 'other'     catch e then throw new Error '^lft@77^ ' + e.message
  assert.deepEqual d_thawed, matcher_c,               '^lft@78^'
  #.........................................................................................................
  return null

# #-----------------------------------------------------------------------------------------------------------
# @[ "use partial freezing (2/3)" ] = ->
#   ### Pretest: test approximate 'manual' implementation of partial freezing, implemented using object
#   sealing and selective `fix()`ing of attributes: ###
#   { lets, freeze, thaw, fix, } = ( require '..' ).partial
#   #.........................................................................................................
#   counter = 0
#   d       = { foo: 'bar', nested: [ 2, 3, 5, 7, ], u: { v: { w: 'x', }, }, }
#   e       = d.nested.push 11
#   Object.defineProperty d, 'foo',    { enumerable: true, writable: false, configurable: false, value: freeze d.foo }
#   Object.defineProperty d, 'nested', { enumerable: true, writable: false, configurable: false, value: freeze d.nested }
#   Object.defineProperty d, 'count',
#     enumerable:     true
#     configurable:   false
#     get:            -> ++counter
#     set:            ( value ) -> counter = value
#   # log Object.getOwnPropertyDescriptors d
#   Object.seal d
#   #.........................................................................................................
#   assert.ok ( ( type_of ( Object.getOwnPropertyDescriptor d, 'count' ).set ) is 'function' ),   '^lft@79^'
#   assert.ok ( Object.isSealed d ),                                                              '^lft@80^'
#   assert.deepEqual ( Object.keys d ), [ 'foo', 'nested', 'count', ],                            '^lft@81^'
#   assert.ok ( d.count is 1                  ), '^lft@82^'
#   assert.ok ( d.count is 2                  ), '^lft@83^'
#   assert.ok ( ( d.count = 42 ) is 42        ), '^lft@84^'
#   assert.ok ( d.count is 43                 ), '^lft@85^'
#   assert.throws ( -> d.blah = 'other' ), { message: /Cannot add property blah, object is not extensible/, }, '^lft@86^'
#   assert.throws ( -> d.foo  = 'other' ), { message: /Cannot assign to read only property/,                }, '^lft@87^'
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @[ "use partial freezing (3/3)" ] = ->
#   { lets, freeze, thaw, fix, lets_compute, } = ( require '..' ).partial
#   # log '^!!!!!!!!!!!!!!!!!!!!!!!!!!^'; return
#   #.........................................................................................................
#   counter = 0
#   d       = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], u: { v: { w: 'x', }, }, }
#   e       = lets d, ( d ) -> d.nested.push 11
#   d       = lets_compute d, 'count', ( -> ++counter ), ( ( x ) -> counter = x )
#   # d       = lets d, ( d ) -> Object.defineProperty d, 'count',
#   #   enumerable:     true
#   #   configurable:   false
#   #   get:            -> ++counter
#   #   set:            ( value ) -> counter = value
#   assert.ok ( ( type_of ( Object.getOwnPropertyDescriptor d, 'count' ).set ) is 'function' ),   '^lft@88^'
#   log '^3341^', d
#   log '^3341^', Object.getOwnPropertyDescriptor d, 'u'
#   log '^3341^', Object.getOwnPropertyDescriptor d.u, 'v'
#   log '^3341^', Object.getOwnPropertyDescriptor d.u.v, 'w'
#   assert.deepEqual d.u, { v: { w: 'x', }, },                                                    '^lft@89^'
#   assert.ok ( Object.isSealed d   ),                                                              '^lft@90^'
#   assert.ok ( Object.isSealed d.u ),                                                            '^lft@91^'
#   assert.ok ( Object.isSealed d.u.v ),                                                            '^lft@92^'
#   assert.deepEqual ( Object.keys d ), [ 'foo', 'nested', 'count', ],                            '^lft@93^'
#   assert.ok ( d.count is 1                  ), '^lft@94^'
#   assert.ok ( d.count is 2                  ), '^lft@95^'
#   assert.ok ( ( d.count = 42 ) is 42        ), '^lft@96^'
#   assert.ok ( d.count is 43                 ), '^lft@97^'
#   assert.throws ( -> d.blah = 'other' ), { message: /Cannot add property blah, object is not extensible/, }, '^lft@98^'
#   assert.throws ( -> d.foo  = 'other' ), { message: /Cannot assign to read only property/,                }, '^lft@99^'
#   return null

# #-----------------------------------------------------------------------------------------------------------
# @[ "may pass in null to lets_compute as getter, setter" ] = ->
#   { lets, lets_compute, } = ( require '..' ).partial
#   # log '^!!!!!!!!!!!!!!!!!!!!!!!!!!^'; return
#   #.........................................................................................................
#   counter = 0
#   d       = lets { foo: 'bar', }
#   d       = lets_compute d, 'count', ( -> ++counter )
#   assert.ok ( d.count is 1                  ), '^lft@100^'
#   assert.ok ( d.count is 2                  ), '^lft@101^'
#   #.........................................................................................................
#   counter = 0
#   d       = lets { foo: 'bar', }
#   d       = lets_compute d, 'count', ( -> ++counter ), null
#   assert.ok ( d.count is 1                  ), '^lft@102^'
#   assert.ok ( d.count is 2                  ), '^lft@103^'
#   #.........................................................................................................
#   counter = 0
#   d       = lets { foo: 'bar', }
#   d       = lets_compute d, 'count', null, ( -> ++counter )
#   #.........................................................................................................
#   counter = 0
#   d       = lets { foo: 'bar', }
#   assert.throws ( -> lets_compute d, 'count', null, null ), /must define getter or setter/, '^lft@104^'

# #-----------------------------------------------------------------------------------------------------------
# @[ "lets_compute keeps object identity" ] = ->
#   { lets, freeze, thaw, lets_compute, } = ( require '..' ).partial
#   #.........................................................................................................
#   class Otherclass
#     constructor: ->
#       @this_is_otherclass = true
#     g: -> ( 'Otherclass.' + k for k of @ )
#   #.........................................................................................................
#   class Someclass extends Otherclass
#     constructor: ->
#       super()
#       @this_is_someclass = true
#     f: -> ( 'Someclass.' + k for k of @ )
#   #.........................................................................................................
#   test_something_ok = ( x, n ) ->
#     tests = [
#       -> assert.ok ( ( ( require 'util' ).inspect x ).startsWith 'Someclass' ), '^lft@105^' + "(##{n})"
#       -> assert.deepEqual ( Object.getOwnPropertyNames x ), [ 'this_is_otherclass', 'this_is_someclass' ], '^lft@^' + "(##{n})"
#       -> assert.ok     x.hasOwnProperty 'this_is_otherclass',  '^lft@^' + "(##{n})"
#       -> assert.ok     x.hasOwnProperty 'this_is_someclass',   '^lft@^' + "(##{n})"
#       -> assert.ok not x.hasOwnProperty 'f',                   '^lft@^' + "(##{n})"
#       -> assert.ok not x.hasOwnProperty 'g',                   '^lft@^' + "(##{n})"
#       -> assert.deepEqual x.g(), [ 'Otherclass.this_is_otherclass', 'Otherclass.this_is_someclass' ], '^lft@^' + "(##{n})"
#       -> assert.deepEqual x.f(), [ 'Someclass.this_is_otherclass', 'Someclass.this_is_someclass' ], '^lft@^' + "(##{n})"
#       ]
#     error_count = 0
#     for test, idx in tests
#       # log test.toString()
#       try
#         test()
#       catch error
#         error_count++
#         log '^lft@^', "ERROR:", error.message
#     if error_count > 0
#       assert.ok false, "^lft@86^(##{n}) #{error_count} tests failed"
#     return null
#   #.........................................................................................................
#   tests = [
#     #.......................................................................................................
#     ->
#       something = new Someclass
#       test_something_ok something, '1'
#     #.......................................................................................................
#     ->
#       something = new Someclass
#       d = lets {}
#       d = lets_compute d, 'something', ( -> something )
#       test_something_ok d.something, '2'
#     #.......................................................................................................
#     ->
#       something = new Someclass
#       d = lets {}
#       d = lets_compute d, 'something', ( -> something )
#       d = freeze d
#       test_something_ok d.something, '3'
#     #.......................................................................................................
#     ->
#       something = new Someclass
#       d = lets {}
#       d = lets_compute d, 'something', ( -> something )
#       d = thaw d
#       test_something_ok d.something, '4'
#     #.......................................................................................................
#     ->
#       something = new Someclass
#       d = lets {}
#       d = lets_compute d, 'something', ( -> something )
#       d = lets d, ( d ) -> d.other = 42
#       test_something_ok d.something, '5'
#     ]
#   #.........................................................................................................
#   do =>
#     error_count = 0
#     for test in tests
#       try
#         test()
#       catch error
#         error_count++
#         log '^lft@^', "ERROR:", error.message
#     if error_count > 0
#       assert.ok false, "^lft@88^ #{error_count} tests failed"
#     return null
#   return null


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


