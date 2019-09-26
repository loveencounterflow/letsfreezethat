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
  assert.ok ( Object.isSealed e             ), '^lft@39^'
  assert.ok ( Object.isSealed e.nested      ), '^lft@40^'
  assert.ok ( Object.isSealed e.u           ), '^lft@41^'
  assert.ok ( Object.isSealed e.u.v         ), '^lft@42^'
  assert.throws ( -> d.nested.push 'other' ), { message: /Cannot add property/,             }, '^lft@43^'
  assert.throws ( -> d.foo  = 'other' ), { message: /Cannot assign to read only property/,  }, '^lft@44^'
  assert.throws ( -> d.blah = 'other' ), { message: /Cannot add property/,                  }, '^lft@45^'
  #.........................................................................................................
  d2 = lets d, ( d_copy ) ->
    assert.ok ( d isnt d_copy ),  '^lft@46^'
    assert.ok ( not is_readonly d_copy,      'nested'  ), '^lft@47^'
    assert.ok ( not is_readonly d_copy,      'u'       ), '^lft@48^'
    assert.ok ( not is_readonly d_copy.u,    'v'       ), '^lft@49^'
    assert.ok ( not is_readonly d_copy.u.v,  'w'       ), '^lft@50^'
    assert.ok ( not Object.isSealed d_copy             ), '^lft@51^'
    assert.ok ( not Object.isSealed d_copy.nested      ), '^lft@52^'
    assert.ok ( not Object.isSealed d_copy.u           ), '^lft@53^'
    assert.ok ( not Object.isSealed d_copy.u.v         ), '^lft@54^'
    try d_copy.nested.push 'other' catch e then throw new Error '^lft@55^ ' + e.message
    try d_copy.foo  = 'other'      catch e then throw new Error '^lft@56^ ' + e.message
    try d_copy.blah = 'other'      catch e then throw new Error '^lft@57^ ' + e.message
    try d_copy.u.v.w = 'other'     catch e then throw new Error '^lft@58^ ' + e.message
  assert.ok ( d2 isnt d ), '^lft@59^'
  assert.deepEqual d,  matcher_a,               '^lft@60^'
  assert.deepEqual d2, matcher_c,               '^lft@61^'
  #.........................................................................................................
  d_thawed = thaw d
  assert.deepEqual d_thawed, d,                           '^lft@62^'
  assert.ok ( d isnt d_thawed ),                          '^lft@63^'
  assert.ok ( not is_readonly d_thawed,      'nested'  ), '^lft@64^'
  assert.ok ( not is_readonly d_thawed,      'u'       ), '^lft@65^'
  assert.ok ( not is_readonly d_thawed.u,    'v'       ), '^lft@66^'
  assert.ok ( not is_readonly d_thawed.u.v,  'w'       ), '^lft@67^'
  assert.ok ( not Object.isSealed d_thawed             ), '^lft@68^'
  assert.ok ( not Object.isSealed d_thawed.nested      ), '^lft@69^'
  assert.ok ( not Object.isSealed d_thawed.u           ), '^lft@70^'
  assert.ok ( not Object.isSealed d_thawed.u.v         ), '^lft@71^'
  try d_thawed.nested.push 'other' catch e then throw new Error '^lft@72^ ' + e.message
  try d_thawed.foo  = 'other'      catch e then throw new Error '^lft@73^ ' + e.message
  try d_thawed.blah = 'other'      catch e then throw new Error '^lft@74^ ' + e.message
  try d_thawed.u.v.w = 'other'     catch e then throw new Error '^lft@75^ ' + e.message
  assert.deepEqual d_thawed, matcher_c,               '^lft@76^'
  #.........................................................................................................
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "use partial freezing (2/3)" ] = ->
  ### Pretest: test approximate 'manual' implementation of partial freezing, implemented using object
  sealing and selective `fix()`ing of attributes: ###
  { lets, freeze, thaw, fix, } = ( require '..' ).partial
  #.........................................................................................................
  counter = 0
  d       = { foo: 'bar', nested: [ 2, 3, 5, 7, ], u: { v: { w: 'x', }, }, }
  e       = d.nested.push 11
  open_vz = { a: 123, }
  Object.defineProperty d, 'foo',    { enumerable: true, writable: false, configurable: false, value: freeze d.foo }
  Object.defineProperty d, 'nested', { enumerable: true, writable: false, configurable: false, value: freeze d.nested }
  Object.defineProperty d, 'count',
    enumerable:     true
    configurable:   false
    get:            -> ++counter
    set:            ( value ) -> counter = value
  Object.defineProperty d, 'open_vz',
    enumerable:     true
    configurable:   false
    get:            -> open_vz
  # log Object.getOwnPropertyDescriptors d
  Object.seal d
  #.........................................................................................................
  assert.ok ( ( type_of ( Object.getOwnPropertyDescriptor d, 'count' ).set ) is 'function' ),   '^lft@77^'
  assert.ok ( Object.isSealed d ),                                                              '^lft@78^'
  assert.deepEqual ( Object.keys d ), [ 'foo', 'nested', 'u', 'count', 'open_vz', ],            '^lft@79^'
  assert.ok ( d.count is 1                  ), '^lft@80^'
  assert.ok ( d.count is 2                  ), '^lft@81^'
  assert.ok ( ( d.count = 42 ) is 42        ), '^lft@82^'
  assert.ok ( d.count is 43                 ), '^lft@83^'
  assert.throws ( -> d.blah = 'other' ), { message: /Cannot add property blah, object is not extensible/, }, '^lft@84^'
  assert.throws ( -> d.foo  = 'other' ), { message: /Cannot assign to read only property/,                }, '^lft@85^'
  try d.open_vz.new_property = 42 catch e then throw new Error '^lft@86^ ' + e.message
  assert.deepEqual d.open_vz.new_property, 42, '^lft@87^'
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "use partial freezing (3/3)" ] = ->
  { lets, freeze, thaw, fix, lets_compute, } = ( require '..' ).partial
  #.........................................................................................................
  counter = 0
  open_vz = { a: 123, }
  d       = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], u: { v: { w: 'x', }, }, }
  e       = lets d, ( d ) -> d.nested.push 11
  d       = lets_compute d, 'count', ( -> ++counter ), ( ( x ) -> counter = x )
  d       = lets_compute d, 'open_vz', ( -> open_vz )
  assert.ok ( ( type_of ( Object.getOwnPropertyDescriptor d, 'count' ).set ) is 'function' ),   '^lft@88^'
  assert.ok ( d.count is 1                  ), '^lft@89^'
  assert.ok ( d.count is 2                  ), '^lft@90^'
  assert.ok ( ( d.count = 42 ) is 42        ), '^lft@91^'
  assert.ok ( d.count is 43                 ), '^lft@92^'
  assert.ok ( d.open_vz is open_vz          ), '^lft@93^'
  try d.open_vz.new_property = 'new value' catch e then throw new Error '^lft@94^ ' + e.message
  assert.ok ( d.open_vz is open_vz          ), '^lft@95^'
  assert.deepEqual open_vz, { a: 123, new_property: 'new value', }, '^lft@96^'
  assert.throws ( -> d.blah = 'other' ), { message: /Cannot add property blah, object is not extensible/, }, '^lft@97^'
  assert.throws ( -> d.foo  = 'other' ), { message: /Cannot assign to read only property/,                }, '^lft@98^'
  lets d, ( d ) ->
    dsc = Object.getOwnPropertyDescriptor d, 'count'
    assert.deepEqual dsc.configurable, true, '^lft@99^'
  lets d, ( d ) ->
    dsc = Object.getOwnPropertyDescriptor d, 'open_vz'
    assert.deepEqual dsc.configurable, true, '^lft@100^'
  return null

#-----------------------------------------------------------------------------------------------------------
@[ "may pass in null to lets_compute as getter, setter" ] = ->
  { lets, lets_compute, } = ( require '..' ).partial
  # log '^!!!!!!!!!!!!!!!!!!!!!!!!!!^'; return
  #.........................................................................................................
  counter = 0
  d       = lets { foo: 'bar', }
  d       = lets_compute d, 'count', ( -> ++counter )
  assert.ok ( d.count is 1                  ), '^lft@101^'
  assert.ok ( d.count is 2                  ), '^lft@102^'
  #.........................................................................................................
  counter = 0
  d       = lets { foo: 'bar', }
  d       = lets_compute d, 'count', ( -> ++counter ), null
  assert.ok ( d.count is 1                  ), '^lft@^'
  assert.ok ( d.count is 2                  ), '^lft@^'
  #.........................................................................................................
  counter = 0
  d       = lets { foo: 'bar', }
  d       = lets_compute d, 'count', null, ( -> ++counter )
  #.........................................................................................................
  counter = 0
  d       = lets { foo: 'bar', }
  assert.throws ( -> lets_compute d, 'count', null, null ), /must define getter or setter/, '^lft@^'

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
      -> assert.ok ( ( ( require 'util' ).inspect x ).startsWith 'Someclass' ), '^lft@^' + "(##{n})"
      -> assert.deepEqual ( Object.getOwnPropertyNames x ), [ 'this_is_otherclass', 'this_is_someclass' ], '^lft@^' + "(##{n})"
      -> assert.ok     x.hasOwnProperty 'this_is_otherclass',  '^lft@^' + "(##{n})"
      -> assert.ok     x.hasOwnProperty 'this_is_someclass',   '^lft@^' + "(##{n})"
      -> assert.ok not x.hasOwnProperty 'f',                   '^lft@^' + "(##{n})"
      -> assert.ok not x.hasOwnProperty 'g',                   '^lft@^' + "(##{n})"
      -> assert.deepEqual x.g(), [ 'Otherclass.this_is_otherclass', 'Otherclass.this_is_someclass' ], '^lft@^' + "(##{n})"
      -> assert.deepEqual x.f(), [ 'Someclass.this_is_otherclass', 'Someclass.this_is_someclass' ], '^lft@^' + "(##{n})"
      ]
    error_count = 0
    for test, idx in tests
      # log test.toString()
      try
        test()
      catch error
        error_count++
        log '^lft@^', "ERROR:", error.message
    if error_count > 0
      assert.ok false, "^lft@^(##{n}) #{error_count} tests failed"
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
        log '^lft@^', "ERROR:", error.message
    if error_count > 0
      assert.ok false, "^lft@^ #{error_count} tests failed"
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


