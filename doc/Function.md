# Working with Redis Functions in RediStick

[RediStick](https://github.com/mumez/RediStick) supports [Redis Functions](https://redis.io/docs/latest/develop/programmability/functions-intro/) - server-side Lua functions organized in libraries, offering a more structured alternative to plain `EVAL` scripts.

## Installation

### Installing RediStick Function packages

You can install RediStick Function packages into Pharo (or GemStone/S).

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/src';
  load: #('Function').
```

If you need tests:

```smalltalk
Metacello new
  baseline: 'RediStick';
  repository: 'github://mumez/RediStick/src';
  load: #('Function' 'FunctionTests').
```

## Basic Usage

### Setting up Connection

```smalltalk
stick := RsRediStick targetUrl: 'sync://localhost'.
stick connect.
```

### Loading a Library (FUNCTION LOAD)

A library is Lua source starting with a shebang line (`#!lua name=<library>`) that registers one or more functions via `redis.register_function`.

```smalltalk
code := '#!lua name=mylib
redis.register_function("echo_args", function(keys, args)
    return args[1]
end)'.

"Answers the library name"
stick endpoint functionLoad: code. "'mylib'"

"With REPLACE, to overwrite an existing library of the same name"
stick endpoint functionLoad: code replace: true.

"Shortcut: builds the shebang line for you from a library name and
plain Lua code, then loads with REPLACE always enabled"
luaCode := '
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
stick endpoint functionPut: 'mylib' code: luaCode. "'mylib'"
```

### Calling a Function (FCALL / FCALL_RO)

```smalltalk
"No keys, no args"
stick endpoint fCall: 'echo_args'.

"With args - accepts a single value or a collection"
stick endpoint fCall: 'echo_args' args: 'hello'.
stick endpoint fCall: 'sum_args' args: #(10 20 30).

"With keys and args"
stick endpoint fCall: 'concat_keys_args' keys: 'mykey' args: 'myval'. "'mykey:myval'"
stick endpoint fCall: 'concat_keys_args' keys: #('mykey') args: #('myval').

"Read-only call (function must be registered with the 'no-writes' flag)"
roCode := '
redis.register_function{
    function_name = "read_key",
    callback = function(keys, args)
        return redis.call("get", keys[1])
    end,
    flags = {"no-writes"}
}'.
stick endpoint functionPut: 'mylib_ro' code: roCode.

stick endpoint set: 'somekey' value: 'somevalue'.
stick endpoint fCallRo: 'read_key' keys: 'somekey'. "'somevalue'"
```

### Listing Libraries (FUNCTION LIST)

```smalltalk
"All libraries - answers an Array of RsFunctionLibraryInfo"
libs := stick endpoint functionList.
libs first name.      "'mylib'"
libs first engine.     "'LUA'"
libs first code.       "nil unless WITHCODE was requested"
libs first functions.  "an Array of RsFunctionInfo"
libs first functions collect: #name.        "#('sum_args' 'echo_args' 'concat_keys_args')"
libs second functions collect: #isNoWrites.  "#(true)"

"Filter by LIBRARYNAME pattern"
stick endpoint functionList: 'mylib*'.

"Include library source code (WITHCODE)"
stick endpoint functionList: 'mylib' withCode: true.

"Full control via options block"
stick endpoint functionListUsing: [ :opts |
    opts libraryName: 'mylib'.
    opts withCode: true ].
```

### Backup and Restore (FUNCTION DUMP / RESTORE)

```smalltalk
"Serialize all libraries to a binary payload"
payload := stick endpoint functionDump.

"Restore from a payload"
stick endpoint functionRestore: payload. "nil - error log 'ERR Library mylib already exists'"

"With a policy - APPEND (default), FLUSH, or REPLACE"
stick endpoint functionRestore: payload mode: 'REPLACE'. "'OK'"

"Shortcuts for each policy"
stick endpoint functionRestoreAppending: payload.
stick endpoint functionRestoreFlushing: payload.
stick endpoint functionRestoreReplacing: payload.
```

### Server Statistics (FUNCTION STATS)

```smalltalk
stats := stick endpoint functionStats.
stats runningScript. "nil, or details about a currently running function"
stats engines.        "a Dictionary, e.g. { 'LUA' -> ... }"
```

### Deleting a Library (FUNCTION DELETE)

```smalltalk
stick endpoint functionDelete: 'mylib'. "'OK'"
```

### Deleting All Libraries (FUNCTION FLUSH)

```smalltalk
stick endpoint functionFlush.       "'OK', uses server default mode"
stick endpoint functionFlushAsync.  "'OK', FLUSH ASYNC"
stick endpoint functionFlushSync.   "'OK', FLUSH SYNC"
```

### Killing a Running Function (FUNCTION KILL)

```smalltalk
"Only meaningful while a function is actually executing on the server;
otherwise Redis replies with a NOTBUSY error"
stick endpoint functionKill.
```
