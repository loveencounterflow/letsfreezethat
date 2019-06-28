
# Let's Freeze Tha{t|w}!

[LetsFreezeThat](https://github.com/loveencounterflow/letsfreezethat) is an unapologetically small
and minimalisitc library to make working with immutable objects in JavaScript less of a chore.

```
npm install letsfreezethat
```

```coffee
{ lets, freeze, thaw, } = require 'letsfreezethat'

d = lets { foo: 'bar', nested: [ 2, 3, 5, 7, ], }  									 # create object
e = lets d, ( d ) -> d.nested.push 11																 # modify copy in callback
console.log 'd                       		', d                       	 # { foo: 'bar', nested: [ 2, 3, 5, 7 ] }
console.log 'e                       		', e                       	 # { foo: 'bar', nested: [ 2, 3, 5, 7, 11 ] }
console.log 'd is e                  		', d is e                  	 # false
console.log 'Object.isFrozen d       		', Object.isFrozen d       	 # true
console.log 'Object.isFrozen d.nested		', Object.isFrozen d.nested	 # true
console.log 'Object.isFrozen e       		', Object.isFrozen e       	 # true
console.log 'Object.isFrozen e.nested		', Object.isFrozen e.nested	 # true
```

LetsFreezeThat copies the core functionality of [immer](https://github.com/immerjs/immer) (also see
[here](https://hackernoon.com/introducing-immer-immutability-the-easy-way-9d73d8f71cb3)); the basic
insight being that

* deeply immutable objects are a great idea for quitre a few reasons;
* working with immutable objects—especially to obtain copies with deeply nested updates—can be a pain in
  JavaScript since the language does zilch to support you;
* JavaScript does have lexical scopes and lightweight function syntax;
* so let's use callbacks that demarcate the scope where modification of object graphs is acceptable.

Now `immer` does a lot more than that as it also allows you to track changes and so on. It also allows
you to improve performance by foregoing `object.freeze()` altogether (something that I may implement
in LetsFreezeThat at a later point in time).

What I wanted was a library so small that performance was probably optimal; turns out 50 LOC is generous
for a functional subset of `immeer`.


## Usage

you can use the `lets()`, `freeze()` and `thaw()` methods by `require`ing them as in `{ lets, freeze, thaw,
} = require 'letsfreezethat'`, but *probably* you only want `lets()`. `lets()` is similar to `immer`'s
`produce()`, except simpler.

`lets()` takes a value to start with, call it `d`, and an optional callback function to modify `d`.

Where the callback is not given, `lets d` is equivalent to `freeze d` which returns a copy of `d` with all
properties recursively frozen.

Where the callback *is* given, that's where you can modify a temporary copy of the first argument `d`. I've
come to always name those copies the same—actually `d` most of the time, but that can be confusing. In short,
you should think of

```coffee
d = lets d, ( d ) -> d.foo = 'baz'
```

as if it was written more like this:

```coffee
frozen_data_v2 = lets frozen_data_v1, ( mutable_copy ) -> mutable_copy.foo = 'baz'
```

# Performance

LetsFreezeThat is around 2.7 times as fast as `immer`, according to my highly scientific tests.








