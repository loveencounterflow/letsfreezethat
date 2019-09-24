
'use strict'


#-----------------------------------------------------------------------------------------------------------
freeze = ( x ) ->
  try
    return _freeze x
  catch error
    if error.name is 'RangeError' and error.message is 'Maximum call stack size exceeded'
      throw new Error "µ45666 unable to freeze circular objects"
    throw error

#-----------------------------------------------------------------------------------------------------------
thaw = ( x ) ->
  try
    return _thaw x
  catch error
    if error.name is 'RangeError' and error.message is 'Maximum call stack size exceeded'
      throw new Error "µ45667 unable to thaw circular objects"
    throw error

#-----------------------------------------------------------------------------------------------------------
_is_computed = ( descriptor ) ->
  return ( ( keys = Object.keys descriptor ).includes 'set' ) or ( keys.includes 'get' )

#-----------------------------------------------------------------------------------------------------------
_freeze = ( x ) ->
  #.........................................................................................................
  if Array.isArray x
    return Object.seal ( ( _freeze value ) for value in x )
  #.........................................................................................................
  if typeof x is 'object'
    R = {}
    for key, descriptor of Object.getOwnPropertyDescriptors x
      if _is_computed descriptor
        Object.defineProperty R, key, descriptor
      else
        if Array.isArray descriptor.value
          descriptor.value = _freeze descriptor.value
        descriptor.configurable = false
        descriptor.writable     = false
        Object.defineProperty R, key, descriptor
    return Object.seal R
  #.........................................................................................................
  return x

#-----------------------------------------------------------------------------------------------------------
_thaw = ( x ) ->
  #.........................................................................................................
  if Array.isArray x
    return ( ( _thaw value ) for value in x )
  #.........................................................................................................
  if typeof x is 'object'
    R = {}
    R[ key ] = _thaw value for key, value of x
    return R
  #.........................................................................................................
  return x

#-----------------------------------------------------------------------------------------------------------
lets = ( original, modifier ) ->
  draft = thaw original
  modifier draft if modifier?
  return freeze draft

#-----------------------------------------------------------------------------------------------------------
lets_compute = ( original, name, get, set = null ) ->
  draft = thaw original
  descriptor      = { enumerable: true, configurable: false, }
  if get?
    unless ( type = typeof get ) is 'function'
      throw new Error "µ77631 expected a function, got a #{type}"
    descriptor.get  = get
  if set?
    unless ( not set )? or ( type = typeof set ) is 'function'
      throw new Error "µ77631 expected a function, got a #{type}"
    descriptor.set  = set
  Object.defineProperty draft, name, descriptor
  return freeze draft

#-----------------------------------------------------------------------------------------------------------
fix = ( target, name, value ) ->
  Object.defineProperty target, name, {
    enumerable:     true
    writable:       false
    configurable:   false
    value:          freeze value }
  return target

#-----------------------------------------------------------------------------------------------------------
module.exports = {
  lets, freeze, thaw, fix, lets_compute,
  nofreeze: ( require './nofreeze' ),
  partial: ( require './partial' ), }

