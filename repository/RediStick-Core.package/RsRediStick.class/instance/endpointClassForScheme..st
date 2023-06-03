factory
endpointClassForScheme: schemeName
	schemeName ifNil: [ ^nil ].
	schemeName = 'stack' ifTrue: [^RsRedisStackEndpoint].
	^RsRedisEndpoint