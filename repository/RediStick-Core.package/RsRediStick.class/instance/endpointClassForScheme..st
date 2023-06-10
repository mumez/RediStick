factory
endpointClassForScheme: schemeName
	schemeName ifNil: [ ^nil ].
	schemeName asString = 'stack' ifTrue: [^RsRedisStackEndpoint].
	^RsRedisEndpoint