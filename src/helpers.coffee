'use strict'

@type_of   = ( x ) ->
	if ( R = ( ( Object::toString.call x ).slice 8, -1 ).toLowerCase() ) is 'object'
		return x.constructor.name.toLowerCase()
	return R



