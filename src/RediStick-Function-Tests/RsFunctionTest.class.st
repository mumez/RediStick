"
I test Redis Function execution and management commands (FCALL, FCALL_RO, FUNCTION LOAD, LIST, DELETE).

Responsibility:
- Verify FCALL execution without keys/args, with args, and with keys and args.
- Verify FCALL_RO read-only function execution.
- Verify FUNCTION LOAD, FUNCTION LIST, and FUNCTION DELETE operations.

Collaborators:
- RsRedisEndpoint
- RsFunctionLibraryInfo
- RsFunctionInfo
"
Class {
	#name : 'RsFunctionTest',
	#superclass : 'RsFunctionTestCase',
	#category : 'RediStick-Function-Tests',
	#package : 'RediStick-Function-Tests'
}

{ #category : 'tests' }
RsFunctionTest >> testFCallNoKeysNoArgs [
	self loadTestLibrary.
	self assert: (stick endpoint fCall: 'echo_args') equals: nil
]

{ #category : 'tests' }
RsFunctionTest >> testFCallRo [
	self loadTestLibraryRo.
	stick endpoint set: 'test:fcallro:key' value: 'secret_value'.
	self assert: (stick endpoint fCallRo: 'read_key' keys: #('test:fcallro:key')) equals: 'secret_value'.
	self assert: (stick endpoint fCallRo: 'read_key' keys: 'test:fcallro:key') equals: 'secret_value'
]

{ #category : 'tests' }
RsFunctionTest >> testFCallWithArgs [
	self loadTestLibrary.
	self assert: (stick endpoint fCall: 'echo_args' args: #('hello')) equals: 'hello'.
	self assert: (stick endpoint fCall: 'echo_args' args: 'world') equals: 'world'.
	self assert: (stick endpoint fCall: 'sum_args' args: #(10 20 30)) equals: 60
]

{ #category : 'tests' }
RsFunctionTest >> testFCallWithKeysAndArgs [
	self loadTestLibrary.
	self assert: (stick endpoint fCall: 'concat_keys_args' keys: #('mykey') args: #('myval')) equals: 'mykey:myval'.
	self assert: (stick endpoint fCall: 'concat_keys_args' keys: 'k1' args: 'v1') equals: 'k1:v1'
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionDelete [
	| libs |
	self loadTestLibrary.
	libs := stick endpoint functionList: 'testlib'.
	self assert: libs size equals: 1.
	
	self assert: (stick endpoint functionDelete: 'testlib') equals: 'OK'.
	libs := stick endpoint functionList: 'testlib'.
	self assert: libs size equals: 0
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionList [
	| libs lib funcNames |
	self loadTestLibrary.
	libs := stick endpoint functionList.
	self assert: libs size equals: 1.
	
	lib := libs first.
	self assert: lib name equals: 'testlib'.
	self assert: lib engine equals: 'LUA'.
	self assert: lib code isNil.
	
	funcNames := lib functions collect: [ :each | each name ].
	self assert: (funcNames includes: 'echo_args').
	self assert: (funcNames includes: 'concat_keys_args').
	self assert: (funcNames includes: 'sum_args')
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionListWithCode [
	| libs lib |
	self loadTestLibrary.
	libs := stick endpoint functionList: 'testlib' withCode: true.
	self assert: libs size equals: 1.
	
	lib := libs first.
	self assert: lib name equals: 'testlib'.
	self assert: lib code notNil.
	self assert: (lib code includesSubstring: 'redis.register_function')
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionListWithPattern [
	| libs |
	self loadTestLibrary.
	self loadTestLibraryRo.
	
	libs := stick endpoint functionList: 'testlib_ro'.
	self assert: libs size equals: 1.
	self assert: libs first name equals: 'testlib_ro'.
	self assert: libs first functions first isNoWrites
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionLoad [
	| name |
	name := self loadTestLibrary.
	self assert: name equals: 'testlib'
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionFlush [
	self loadTestLibrary.
	self assert: stick endpoint functionList size equals: 1.
	self assert: stick endpoint functionFlush equals: 'OK'.
	self assert: stick endpoint functionList size equals: 0
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionFlushAsync [
	self loadTestLibrary.
	self assert: stick endpoint functionList size equals: 1.
	self assert: stick endpoint functionFlushAsync equals: 'OK'.
	self assert: stick endpoint functionList size equals: 0
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionFlushSync [
	self loadTestLibrary.
	self assert: stick endpoint functionList size equals: 1.
	self assert: stick endpoint functionFlushSync equals: 'OK'.
	self assert: stick endpoint functionList size equals: 0
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionKill [
	"No script is running in a unit test context, so Redis replies with an error.
	RsRedisEndpoint does not raise Redis protocol errors to the caller; instead it
	reports them via the stick's onRedisGenericErrorBlock, so capture it there."
	| caughtError |
	caughtError := nil.
	stick onRedisGenericError: [ :ex | caughtError := ex ].
	self assert: stick endpoint functionKill isNil.
	self assert: caughtError notNil.
	self assert: caughtError errorPrefix equals: 'NOTBUSY'
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionStats [
	| stats |
	self loadTestLibrary.
	stats := stick endpoint functionStats.
	self assert: stats runningScript isNil.
	self assert: (stats engines includesKey: 'LUA').
	self assert: (stats engines at: 'LUA') notNil
]
