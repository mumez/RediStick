"
I test RsGetExOptions, verifying that each option is converted into the correct GETEX command arguments.
"
Class {
	#name : 'RsGetExOptionsTest',
	#superclass : 'TestCase',
	#category : 'RediStick-Tests',
	#package : 'RediStick-Tests'
}

{ #category : 'tests' }
RsGetExOptionsTest >> testAsArrayEmpty [
	self assert: RsGetExOptions new asArray equals: #(  )
]

{ #category : 'tests' }
RsGetExOptionsTest >> testAsArrayWithExpireAtDateAndTime [
	| options |
	options := RsGetExOptions new.
	options expireAt: (DateAndTime fromUnixTime: 1700000000).
	self assert: options asArray equals: #( 'EXAT' 1700000000 )
]

{ #category : 'tests' }
RsGetExOptionsTest >> testAsArrayWithExpireAtInteger [
	| options |
	options := RsGetExOptions new.
	options expireAt: 1700000000.
	self assert: options asArray equals: #( 'EXAT' 1700000000 )
]

{ #category : 'tests' }
RsGetExOptionsTest >> testAsArrayWithExpireAtMillisecondsDateAndTime [
	| options |
	options := RsGetExOptions new.
	options expireAtMilliseconds: (DateAndTime fromUnixTime: 1700000000) + 250 milliSeconds.
	self assert: options asArray equals: #( 'PXAT' 1700000000250 )
]

{ #category : 'tests' }
RsGetExOptionsTest >> testAsArrayWithExpireAtMillisecondsInteger [
	| options |
	options := RsGetExOptions new.
	options expireAtMilliseconds: 1700000000250.
	self assert: options asArray equals: #( 'PXAT' 1700000000250 )
]

{ #category : 'tests' }
RsGetExOptionsTest >> testAsArrayWithExpireIn [
	| options |
	options := RsGetExOptions new.
	options expireIn: 60.
	self assert: options asArray equals: #( 'EX' 60 )
]

{ #category : 'tests' }
RsGetExOptionsTest >> testAsArrayWithExpireInMilliseconds [
	| options |
	options := RsGetExOptions new.
	options expireInMilliseconds: 1500.
	self assert: options asArray equals: #( 'PX' 1500 )
]

{ #category : 'tests' }
RsGetExOptionsTest >> testAsArrayWithPersist [
	| options |
	options := RsGetExOptions new.
	options persist.
	self assert: options asArray equals: #( 'PERSIST' )
]

{ #category : 'tests' }
RsGetExOptionsTest >> testUnknownExpirationModeSignalsInvalidArguments [
	| options error |
	options := RsGetExOptions new.
	options expirationMode: #unknown value: nil.
	error := [ options asArray. nil ] on: RsError do: [ :ex | ex ].
	self assert: error notNil.
	self assert: error kind equals: #InvalidArguments.
	self assert: error messageText equals: 'Unknown GETEX expiration: #unknown'
]

{ #category : 'tests' }
RsGetExOptionsTest >> testExpirationIsOverwritten [
	| options |
	options := RsGetExOptions new.
	options
		expireIn: 60;
		persist.
	self assert: options asArray equals: #( 'PERSIST' ).
	options expireInMilliseconds: 500.
	self assert: options asArray equals: #( 'PX' 500 )
]
