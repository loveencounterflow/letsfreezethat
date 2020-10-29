

'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'LFTNG'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
Multimix                  = require 'multimix'
#...........................................................................................................
frozen                    = Object.isFrozen
assign                    = Object.assign
shallow_freeze            = Object.freeze
shallow_copy              = ( x, P... ) -> assign ( if Array.isArray x then [] else {} ), x, P...
{ klona: deep_copy, }     = require 'klona/json'


#===========================================================================================================
deep_freeze = ( d ) ->
  ### immediately return for zero, empty string, null, undefined, NaN, false, true: ###
  return d if ( not d ) or d is true
  ### thx to https://github.com/lukeed/klona/blob/master/src/json.js ###
  switch ( Object::toString.call d )
    when '[object Array]'
      k = d.length
      while ( k-- )
        continue unless ( v = d[ k ] )? and ( ( typeof v ) is 'object' )
        d[ k ] = deep_freeze v
      return shallow_freeze d
    when '[object Object]'
      for k, v of d
        continue unless v? and ( ( typeof v ) is 'object' )
        d[ k ] = deep_freeze v
      return shallow_freeze d
  return d

#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
freeze_lets = lets = ( original, modifier ) ->
  draft = @thaw original
  modifier draft if modifier?
  return deep_freeze draft

#-----------------------------------------------------------------------------------------------------------
freeze_lets.assign    = ( me, P...  ) -> deep_freeze  deep_copy shallow_copy  me, P...
freeze_lets.freeze    = ( me        ) -> deep_freeze                          me
freeze_lets.thaw      = ( me        ) ->              deep_copy               me
freeze_lets.get       = ( me, k     ) -> me[ k ]
freeze_lets.set       = ( me, k, v  ) ->
  R       = shallow_copy me
  R[ k ]  = v
  return shallow_freeze R


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
nofreeze_lets = ( original, modifier ) ->
  draft = @thaw original
  modifier draft if modifier?
  ### TAINT do not copy ###
  return deep_copy draft

#-----------------------------------------------------------------------------------------------------------
nofreeze_lets.assign  = ( me, P...  ) -> deep_copy shallow_copy me, P...
nofreeze_lets.freeze  = ( me        ) ->                        me
nofreeze_lets.thaw    = ( me        ) -> deep_copy              me
nofreeze_lets.get     = freeze_lets.get
nofreeze_lets.set     = ( me, k, v  ) ->
  R       = shallow_copy me
  R[ k ]  = v
  return R


#===========================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
module.exports = { freeze_lets, nofreeze_lets, }



