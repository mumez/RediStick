"
I test RsSetOptions, verifying that each option is converted into the correct SET command arguments.
"
Class {
	#name : 'RsSetOptionsTest',
	#superclass : 'TestCase',
	#category : 'RediStick-Tests',
	#package : 'RediStick-Tests'
}

{ #category : 'tests' }
RsSetOptionsTest >> testAsArrayEmpty [
	self assert: RsSetOptions new asArray equals: #(  )
]

{ #category : 'tests' }
RsSetOptionsTest >> testAsArrayWithCombinedOptions [
	| options |
	options := RsSetOptions new.
	options
		ifNotExists;
		get;
		expireIn: 1000.
	self assert: options asArray equals: #( 'NX' 'GET' 'EX' 1000 )
]

{ #category : 'tests' }
RsSetOptionsTest >> testConditionIsOverwritten [
	| options |
	options := RsSetOptions new.
	options
		ifNotExists;
		ifAlreadyExists.
	self assert: options asArray equals: #( 'XX' )
]

{ #category : 'tests' }
RsSetOptionsTest >> testExpirationIsOverwritten [
	| options |
	options := RsSetOptions new.
	options
		expireIn: 10;
		keepTtl.
	self assert: options asArray equals: #( 'KEEPTTL' )
]

{ #category : 'tests' }
RsSetOptionsTest >> testExpireAtWithDateAndTime [
	| options time |
	time := DateAndTime year: 2030 month: 1 day: 1 hour: 0 minute: 0 second: 0 offset: (Duration hours: 9).
	options := RsSetOptions new.
	options expireAt: time.
	self assert: options asArray equals: #( 'EXAT' 1893423600 )
]

{ #category : 'tests' }
RsSetOptionsTest >> testExpireAtWithInteger [
	| options |
	options := RsSetOptions new.
	options expireAt: 1893423600.
	self assert: options asArray equals: #( 'EXAT' 1893423600 )
]

{ #category : 'tests' }
RsSetOptionsTest >> testExpireAtMillisecondsWithDateAndTime [
	| options time |
	time := (DateAndTime year: 2030 month: 1 day: 1 hour: 0 minute: 0 second: 0 offset: Duration zero)
		        + 123 milliSeconds.
	options := RsSetOptions new.
	options expireAtMilliseconds: time.
	self assert: options asArray equals: #( 'PXAT' 1893456000123 )
]

{ #category : 'tests' }
RsSetOptionsTest >> testExpireAtMillisecondsWithInteger [
	| options |
	options := RsSetOptions new.
	options expireAtMilliseconds: 1893456000123.
	self assert: options asArray equals: #( 'PXAT' 1893456000123 )
]

{ #category : 'tests' }
RsSetOptionsTest >> testExpireIn [
	| options |
	options := RsSetOptions new.
	options expireIn: 60.
	self assert: options asArray equals: #( 'EX' 60 )
]

{ #category : 'tests' }
RsSetOptionsTest >> testExpireInMilliseconds [
	| options |
	options := RsSetOptions new.
	options expireInMilliseconds: 1500.
	self assert: options asArray equals: #( 'PX' 1500 )
]

{ #category : 'tests' }
RsSetOptionsTest >> testGet [
	| options |
	options := RsSetOptions new.
	options get.
	self assert: options asArray equals: #( 'GET' )
]

{ #category : 'tests' }
RsSetOptionsTest >> testIfAlreadyExists [
	| options |
	options := RsSetOptions new.
	options ifAlreadyExists.
	self assert: options asArray equals: #( 'XX' )
]

{ #category : 'tests' }
RsSetOptionsTest >> testIfDigestEqual [
	| options |
	options := RsSetOptions new.
	options ifDigestEqual: 'abc123'.
	self assert: options asArray equals: #( 'IFDEQ' 'abc123' )
]

{ #category : 'tests' }
RsSetOptionsTest >> testIfDigestNotEqual [
	| options |
	options := RsSetOptions new.
	options ifDigestNotEqual: 'abc123'.
	self assert: options asArray equals: #( 'IFDNE' 'abc123' )
]

{ #category : 'tests' }
RsSetOptionsTest >> testIfEqual [
	| options |
	options := RsSetOptions new.
	options ifEqual: 'old'.
	self assert: options asArray equals: #( 'IFEQ' 'old' )
]

{ #category : 'tests' }
RsSetOptionsTest >> testIfNotEqual [
	| options |
	options := RsSetOptions new.
	options ifNotEqual: 'old'.
	self assert: options asArray equals: #( 'IFNE' 'old' )
]

{ #category : 'tests' }
RsSetOptionsTest >> testIfNotExists [
	| options |
	options := RsSetOptions new.
	options ifNotExists.
	self assert: options asArray equals: #( 'NX' )
]

{ #category : 'tests' }
RsSetOptionsTest >> testKeepTtl [
	| options |
	options := RsSetOptions new.
	options keepTtl.
	self assert: options asArray equals: #( 'KEEPTTL' )
]
