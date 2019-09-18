
# Let's Freeze Tha{t|w}!

[LetsFreezeThat](https://github.com/loveencounterflow/letsfreezethat) is an unapologetically minimal library
to make working with immutable objects in JavaScript less of a chore.

```
npm install letsfreezethat
```

```coffee
{ lets, freeze, thaw, } = require 'letsfreezethat'

d = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], }                    # create object
e = lets d, ( d ) -> d.nested.push 11                                # modify copy in callback
console.log 'd                          ', d                         # { foo: 'bar', nested: [ 2, 3, 5, 7 ] }
console.log 'e                          ', e                         # { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }
console.log 'd is e                     ', d is e                    # false
console.log 'Object.isFrozen d          ', Object.isFrozen d         # true
console.log 'Object.isFrozen d.nested   ', Object.isFrozen d.nested  # true
console.log 'Object.isFrozen e          ', Object.isFrozen e         # true
console.log 'Object.isFrozen e.nested   ', Object.isFrozen e.nested  # true
```

LetsFreezeThat copies the core functionality of [immer](https://github.com/immerjs/immer) (also see
[here](https://hackernoon.com/introducing-immer-immutability-the-easy-way-9d73d8f71cb3)); the basic
insight being that

* deeply immutable objects are a great idea for quite a few reasons;
* working with immutable objects—especially to obtain copies with deeply nested updates—can be a pain in
  JavaScript since the language does zilch to support you;
* JavaScript does have lexical scopes and lightweight function syntax;
* so let's use callbacks that demarcate the scope where modification of object graphs is acceptable.

Now `immer` does a lot more than that as it also allows you to track changes and so on. It also allows
you to improve performance by foregoing `object.freeze()` altogether (something that I may implement
in LetsFreezeThat at a later point in time).

What I wanted was a library so small that performance was probably optimal; turns out 50 LOC is generous
for a functional subset of `immer`.

## Let's `fix()` That!

As of version 2, there's also a `fix()` method that allows to hammer down a particular attribute of
a given target object:

```
{ fix, } = require 'letsfreezethat'
d = { foo: 'bar', }
fix d, 'sql', { query: "select * from main;", }
console.log ( k for k of d ) # [ 'foo', 'sql' ]
try d.sql       = 'other' catch error then console.log error.message # Cannot assign to read only property 'sql' of object '#<Object>'
try d.sql.query = 'other' catch error then console.log error.message # Cannot assign to read only property 'query' of object '#<Object>'
```

`fix()` takes three arguments: the `target` object, a `name`, and a `value`. After calling `fix target,
name, value`, `target[ name ]` will equal `value`, as if one had used assignment, as in `target[ name ] =
value`. However, the attribute will be tacked onto `target` using `Object.defineProperty` with a descriptor
`{ enumerable: true, writable: false, configurable: false, value: ( freeze value ), }`, so it cannot (in
strict mode) be altered itself (because it is frozen), nor can `target[ name ]` be re-assigned or modified
(because it is not writable and not configurable).

Thus, `fix()` covers a middle ground between all-out freezing and having everything mutable, all the time.
It is suitable for those situation where some parts of a given state object have to remain updatable when
other parts are not meant to be fiddled with.

Observe that the `nofreeze` version of `fix()` uses plain assignment and no attribute configuration, so
`nofreeze.fix target, name, value` is just a fancy way of writing `target[ name ] = value`. This detail may
change in the future.


## Usage

You can use the `lets()`, `freeze()` and `thaw()` methods by `require`ing them as in `{ lets, freeze, thaw,
} = require 'letsfreezethat'`, but *probably* you only want `lets()`. `lets()` is similar to `immer`'s
`produce()`, except simpler.

`lets()` takes a value to start with, call it `d`, and an optional callback function to modify `d`.

Where the callback is not given, `lets d` is equivalent to `freeze d` which returns a copy of `d` with all
properties recursively frozen.

Where the callback *is* given, that's where you can modify a temporary copy of the first argument `d`. I've
come to always name those copies the same—`d` most of the time—but that *can* be confusing at first.

You should think of

```coffee
d = lets { key: 'word', value: 'OMG', }
d = lets d, ( d ) -> d.size = 3
```

as though it was written more like this:

```coffee
frozen_data_v1 = lets { key: 'word', value: 'OMG', }
frozen_data_v2 = lets frozen_data_v1, ( draft ) -> draft.size = 3
```

The second style has the advantage of being more explicit about the identity of the various values involved;
also, it is sometimes important to be able to reference back to some property of `frozen_data_v1` after the
changes, so there's nothing wrong with writing it the more eloquent way.

Observe you can also use `freeze()` and `thaw()` to the same effect:

```coffee
{ lets
  freeze
  thaw }        = require 'letsfreezethat'

...

original_data   = { key: 'word', value: 'OMG', }
frozen_data_v1  = freeze original_data

...

draft           = thaw frozen_data_v1
draft.size      = 3
frozen_data_v2  = freeze draft

...

```

This is more explicit but also more repetitive.


## Performance And `nofreeze` Option

According to my highly scientific tests, LetsFreezeThat is roughly around 3 times as fast as `immer`. When
your software works to plan and you made sure you used `'use strict'` so JavaScript would have throw an
error if you had accidentally tried to modify a frozen value, you can get some extra miles for free by
replacing `{ lets, freeze, thaw, } = require 'letsfreezethat'` with `{ lets, freeze, thaw, } = ( require
'letsfreezethat' ).nofreeze`. These methods avoid to call `Object.freeze()` and run about twice as fast as
the freezing versions: `thaw()` just returns its only argument, making it a no-op; `freeze()` just performs
a deep copy; `lets()` will likewise make a deep copy, and the value that you can modify in the callback will
be the return value of the method.



## What it Does, and What it Doesn't

* LetsFreezeThat always gives back a copy of the value passed in, no matter whether you use `lets()`,
  `freeze()`, or `thaw()`; this means that even when you don't manipulate a value, the old reference will
  remain untouched:

  ```coffee
  d = lets d, ( d ) -> # do nothing
  ```

  This is different from `immer`'s `produce()`, which will give you back the original object in case no
  modification was made.

* LetsFreezeThat does *not* do structural sharing or copy-on-write (COW), nor will it do so in the future.
  Both structural sharing and COW are great techniques to drive down memory requirements, enhance cache
  locality and save on garbage collection cycles, but they do come with additional complexities.

  The intended use case for LetsFreezeThat are situations where you have many rather small, rather shallow
  objects, which offer little opportunity for the benefits of structural sharing and COW to kick in.

* LetsFreezeThat does *not* track changes; if you need a report on what properties were affected by some
  part of your program, use `immer` instead. While having a change manifest may be potentially useful when,
  say, persisting an object to a DB, those benefits will diminish with smaller object size, same as with
  structural sharing.








