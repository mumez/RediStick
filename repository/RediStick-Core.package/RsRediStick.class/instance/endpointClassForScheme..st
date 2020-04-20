factory
endpointClassForScheme: schemeName
	schemeName ifNil: [ ^nil ].
	^RsRedisEndpoint 