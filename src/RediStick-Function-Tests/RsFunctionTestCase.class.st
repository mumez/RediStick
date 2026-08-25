"
I am a test case base class for Redis Function execution tests.

Responsibility:
- Provide helper methods for loading test Function libraries into Redis.
- Handle cleanup of loaded Function libraries in tearDown.

Collaborators:
- RsRediStick
- RsRedisEndpoint
"
Class {
	#name : 'RsFunctionTestCase',
	#superclass : 'RsRedisTestCase',
	#category : 'RediStick-Function-Tests',
	#package : 'RediStick-Function-Tests'
}

{ #category : 'helpers' }
RsFunctionTestCase >> loadTestLibrary [
	"Loads a test library 'testlib' containing functions:
	  - 'echo_args': returns args[1]
	  - 'concat_keys_args': returns keys[1] .. ':' .. args[1]
	  - 'sum_args': returns sum of numerical args"
	| code |
	code := '#!lua name=testlib
redis.register_function("echo_args", function(keys, args)
    return args[1]
end)
redis.register_function("concat_keys_args", function(keys, args)
    return keys[1] .. ":" .. args[1]
end)
redis.register_function("sum_args", function(keys, args)
    local sum = 0
    for _, v in ipairs(args) do
        sum = sum + tonumber(v)
    end
    return sum
end)'.
	^ stick endpoint functionLoad: code replace: true
]

{ #category : 'helpers' }
RsFunctionTestCase >> loadTestLibraryRo [
	"Loads a read-only test library 'testlib_ro' containing:
	  - 'read_key': returns redis.call('get', keys[1])"
	| code |
	code := '#!lua name=testlib_ro
redis.register_function{
    function_name = "read_key",
    callback = function(keys, args)
        return redis.call("get", keys[1])
    end,
    flags = {"no-writes"}
}'.
	^ stick endpoint functionLoad: code replace: true
]

{ #category : 'running' }
RsFunctionTestCase >> tearDown [
	[ stick endpoint unifiedCommand: #( 'FUNCTION' 'FLUSH' 'SYNC' ) ] on: Error do: [ :ex | ].
	super tearDown
]
