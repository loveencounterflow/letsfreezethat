'use strict'

{ lets, freeze, thaw, fix, } = require '..'

d = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], }
e = lets d, ( d ) -> d.nested.push 11
console.log()
console.log()
console.log 'd                          ', d                         # { foo: 'bar', nested: [ 2, 3, 5, 7 ] }
console.log 'e                          ', e                         # { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }
console.log 'd is e                     ', d is e                    # false
console.log 'Object.isFrozen d          ', Object.isFrozen d         # true
console.log 'Object.isFrozen d.nested   ', Object.isFrozen d.nested  # true
console.log 'Object.isFrozen e          ', Object.isFrozen e         # true
console.log 'Object.isFrozen e.nested   ', Object.isFrozen e.nested  # true

d = { foo: 'bar', }
console.log()
console.log 'd                          ', d
fix d, 'sql', { query: "select * from main;", }
console.log 'd                          ', d
console.log ( k for k of d )
try d.sql       = 'other' catch error then console.log error.message # Cannot assign to read only property 'sql' of object '#<Object>'
try d.sql.query = 'other' catch error then console.log error.message # Cannot assign to read only property 'query' of object '#<Object>'
console.log 'd                          ', d


{ lets, freeze, thaw, fix, } = ( require '..' ).nofreeze

d = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], }
e = lets d, ( d ) -> d.nested.push 11
console.log()
console.log()
console.log 'd                          ', d                         # { foo: 'bar', nested: [ 2, 3, 5, 7 ] }
console.log 'e                          ', e                         # { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }
console.log 'd is e                     ', d is e                    # false
console.log 'Object.isFrozen d          ', Object.isFrozen d         # true
console.log 'Object.isFrozen d.nested   ', Object.isFrozen d.nested  # true
console.log 'Object.isFrozen e          ', Object.isFrozen e         # true
console.log 'Object.isFrozen e.nested   ', Object.isFrozen e.nested  # true

d = { foo: 'bar', }
console.log()
console.log 'd                          ', d
fix d, 'sql', { query: "select * from main;", }
console.log 'd                          ', d
console.log ( k for k of d )
try d.sql       = {}      catch error then console.log error.message
try d.sql.query = 'other' catch error then console.log error.message
console.log 'd                          ', d

