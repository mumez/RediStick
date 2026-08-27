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
RsFunctionTest >> testFCallWithByteArrayArgs [
	| bytes result |
	self loadTestLibrary.
	bytes := #[104 101 108 108 111].
	result := stick endpoint fCall: 'echo_args' args: bytes.
	self assert: result equals: 'hello'
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
RsFunctionTest >> testFunctionLoadWithCrlf [
	| code name |
	code := '#!lua name=crlflib' , String crlf ,
		'redis.register_function("crlf_echo", function(keys, args)' , String crlf ,
		'    return args[1]' , String crlf ,
		'end)'.
	name := stick endpoint functionLoad: code replace: true.
	self assert: name equals: 'crlflib'.
	self assert: (stick endpoint fCall: 'crlf_echo' args: 'ok') equals: 'ok'
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionPut [
	| luaCode libs |
	luaCode := 'redis.register_function("echo_args", function(keys, args)
    return args[1]
end)'.
	self assert: (stick endpoint functionPut: 'testlib' code: luaCode) equals: 'testlib'.

	libs := stick endpoint functionList: 'testlib'.
	self assert: libs size equals: 1.
	self assert: libs first name equals: 'testlib'.
	self assert: (stick endpoint fCall: 'echo_args' args: 'hello') equals: 'hello'
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionPutReplacesExisting [
	| luaCode |
	self loadTestLibrary.
	luaCode := 'redis.register_function("echo_args", function(keys, args)
    return args[1]
end)'.
	self assert: (stick endpoint functionPut: 'testlib' code: luaCode) equals: 'testlib'.
	self assert: stick endpoint functionList size equals: 1
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

{ #category : 'tests' }
RsFunctionTest >> testFunctionStatsFromNil [
	self assert: (RsFunctionStats fromArrayOrDictionary: nil) isNil.
	self assert: (RsFunctionInfo fromArrayOrDictionary: nil) isNil.
	self assert: (RsFunctionLibraryInfo fromArrayOrDictionary: nil) isNil
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionDumpAndRestore [
	| payload libs |
	self loadTestLibrary.
	payload := stick endpoint functionDump.
	self assert: payload notNil.

	stick endpoint functionFlush.
	self assert: stick endpoint functionList size equals: 0.

	self assert: (stick endpoint functionRestore: payload) equals: 'OK'.
	libs := stick endpoint functionList.
	self assert: libs size equals: 1.
	self assert: libs first name equals: 'testlib'
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionRestoreWithModeFlush [
	| payload libs |
	self loadTestLibrary.
	payload := stick endpoint functionDump.

	self assert: (stick endpoint functionRestore: payload mode: 'FLUSH') equals: 'OK'.
	libs := stick endpoint functionList.
	self assert: libs size equals: 1.
	self assert: libs first name equals: 'testlib'
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionRestoreWithModeReplace [
	| payload libs |
	self loadTestLibrary.
	payload := stick endpoint functionDump.

	self assert: (stick endpoint functionRestore: payload mode: 'REPLACE') equals: 'OK'.
	libs := stick endpoint functionList.
	self assert: libs size equals: 1.
	self assert: libs first name equals: 'testlib'
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionRestoreAppending [
	| payload libs |
	self loadTestLibrary.
	payload := stick endpoint functionDump.
	stick endpoint functionFlush.

	self assert: (stick endpoint functionRestoreAppending: payload) equals: 'OK'.
	libs := stick endpoint functionList.
	self assert: libs size equals: 1.
	self assert: libs first name equals: 'testlib'
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionRestoreFlushing [
	| payload libs |
	self loadTestLibrary.
	payload := stick endpoint functionDump.

	self assert: (stick endpoint functionRestoreFlushing: payload) equals: 'OK'.
	libs := stick endpoint functionList.
	self assert: libs size equals: 1.
	self assert: libs first name equals: 'testlib'
]

{ #category : 'tests' }
RsFunctionTest >> testFunctionRestoreReplacing [
	| payload libs |
	self loadTestLibrary.
	payload := stick endpoint functionDump.

	self assert: (stick endpoint functionRestoreReplacing: payload) equals: 'OK'.
	libs := stick endpoint functionList.
	self assert: libs size equals: 1.
	self assert: libs first name equals: 'testlib'
]
