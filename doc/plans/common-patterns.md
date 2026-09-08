# RediStick Implementation Patterns

A reference of implementation patterns worth reusing when planning future work.

## Parameter-Class Pattern: Modeling Mixed-Type Parameters

### Problem

Some Redis commands accept a parameter that mixes sentinel strings such as
`'-'` / `'+'` / `'$'` with an integer timestamp (or a `DateAndTime`)
(e.g. the cursor position for `TS.READ`).

### Bad pattern - let the user pass the raw value directly

```smalltalk
endpoint tsRead: 'temp:1' cursor: '-' using: nil.
```

- Easy to get wrong (a stray space, e.g. `'- '`, silently breaks it)
- Unclear meaning (what `'-'` means isn't obvious without reading the docs)
- Invalid values (e.g. a negative timestamp) get sent through as-is

### Good pattern - introduce a dedicated parameter class

`RsTsReadCursor` (`src/RediStick-TimeSeries/RsTsReadCursor.class.st`) is an example.

```smalltalk
endpoint tsRead: 'temp:1' cursor: RsTsReadCursor earliest.
endpoint tsRead: 'temp:1' cursor: (RsTsReadCursor timestamp: aDateAndTime).
```

Key points:

- **Make the allowed values explicit as class API**: expose only
  domain-vocabulary messages like `#earliest` / `#latest` / `#newest` /
  `#timestamp:`; the raw `'-'` `'+'` `'$'` strings stay internal to the class.
- **Normalize as early as possible**: `#timestamp:` immediately normalizes the
  given `DateAndTime` or integer via `asRediStickUnixTimestampMillis`.
- **Validate at send-time (`#asArgumentValue`), not at construction**: because
  validation runs when the cursor is converted into a command argument rather
  than when it's built, a cursor can be freely reassigned before it's sent.
  Invalid values (nil, a negative timestamp, an unrecognized string) raise
  `RsError` at that point.
- **When several related parameters exist, validate "all set or none set"**:
  `RsTsReadOptions>>#asArray` (`src/RediStick-TimeSeries/RsTsReadOptions.class.st`)
  rejects a state where only one of BLOCK's `milliseconds`/`minCount` is set,
  raising `RsError invalidArguments`. This enforces, at the API level, the
  Redis-side constraint that both must be supplied together or omitted together.

### Bonus: fluent API via an `xxxBy:` builder block

Instead of requiring the caller to construct and pass a parameter-class
instance, add a method that takes a block to build it, as in
`RsRedisEndpoint>>#tsRead:cursorBy:using:`. This yields a fluent API composed
purely of message sends.

```smalltalk
endpoint tsRead: 'temp:1' cursorBy: [ :c | c timestamp: aDateAndTime ].
```

Internally this just creates `RsTsReadCursor new`, evaluates the given block
with it, and delegates to the ordinary `cursor:` variant:

```smalltalk
RsRedisEndpoint >> tsRead: key cursorBy: cursorBlock using: optionsBlock [
	| cursor |
	cursor := RsTsReadCursor new.
	cursorBlock value: cursor.
	^ self tsRead: key cursor: cursor using: optionsBlock
]
```

### When to apply this pattern

- A single parameter of a Redis command can take multiple kinds of values
  (sentinel string / number / date-time, etc.).
- Several related parameters have a mutual constraint such as
  "specify together or omit together."
- Exposing a raw string/symbol directly in the API would force callers to
  read the docs to figure out the correct value.
