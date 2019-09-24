
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
    return Object.freeze ( ( _freeze value ) for value in x )
  #.........................................................................................................
  if typeof x is 'object'
    R = {}
    for key, descriptor of Object.getOwnPropertyDescriptors x
      if _is_computed descriptor
        Object.defineProperty d, key, descriptor
      else
        R[ key ] = _freeze value
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
fix = ( target, name, value ) ->
  Object.defineProperty target, name, {
    enumerable:     true
    writable:       false
    configurable:   false
    value:          freeze value }
  return target

#-----------------------------------------------------------------------------------------------------------
module.exports = {
  lets, freeze, thaw, fix,
  nofreeze: ( require './nofreeze' ),
  partial: ( require './partial' ), }

