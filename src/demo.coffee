{ lets, freeze, thaw, } = require 'letsfreezethat'

d = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], }
e = lets d, ( d ) -> d.nested.push 11
console.log 'd                       		', d                       	 # { foo: 'bar', nested: [ 2, 3, 5, 7 ] }
console.log 'e                       		', e                       	 # { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }
console.log 'd is e                  		', d is e                  	 # false
console.log 'Object.isFrozen d       		', Object.isFrozen d       	 # true
console.log 'Object.isFrozen d.nested		', Object.isFrozen d.nested	 # true
console.log 'Object.isFrozen e       		', Object.isFrozen e       	 # true
console.log 'Object.isFrozen e.nested		', Object.isFrozen e.nested	 # true


{ lets, freeze, thaw, } = ( require '..' ).nofreeze

d = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], }
e = lets d, ( d ) -> d.nested.push 11
console.log 'd                       		', d                       	 # { foo: 'bar', nested: [ 2, 3, 5, 7 ] }
console.log 'e                       		', e                       	 # { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }
console.log 'd is e                  		', d is e                  	 # false
console.log 'Object.isFrozen d       		', Object.isFrozen d       	 # true
console.log 'Object.isFrozen d.nested		', Object.isFrozen d.nested	 # true
console.log 'Object.isFrozen e       		', Object.isFrozen e       	 # true
console.log 'Object.isFrozen e.nested		', Object.isFrozen e.nested	 # true


