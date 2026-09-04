# Feature: Raw bytes write mode (skip UTF8 encoding when sending)

## Goal

Kanban issue `1788438796232-送信時にbytearrayはuft8文字列にencodeしないオプション追加`:
today RediStick sends both `String` and `ByteArray` command values by first turning them into a
UTF8-encoded byte stream. That's lossy for values that are already raw bytes (e.g. a `String`
built from arbitrary binary data) — round-tripping through UTF8 encoding can corrupt bytes that
aren't valid UTF8. The goal is an opt-in mode where sending is byte-for-byte, no UTF8 transcoding.

Issue's proposed approach (adopted as-is):
- Rename `shouldReturnRawBytes` → `shouldUseRawBytes` (same accessor pair, one flag now governs
  both read-raw and write-raw behavior).
- Rename `returnRawBytesWhile:` → `useRawBytesWhile:`.
- Make the write path skip UTF8 encoding when the flag is `true`.

## Orchestration Shape

sequential: implement (TDD) → test → lint & review, all via claude, against the existing
`/home/mumez/git/RediStick` checkout.

## Working Directory

`/home/mumez/git/RediStick` (the current RediStick checkout — this is existing feature work on
an established codebase, not a from-scratch build).

## Script

```Smalltalk
| script |
script := AgenticBrowser scriptBy: [ :builder |
	builder sharedDirectoryPath: '/home/mumez/git/RediStick'.
	builder seq: {
		builder topicBy: [ :t |
			t title: 'Implement raw bytes write mode (TDD)'.
			t prompt: 'RediStick is a Redis client for Pharo Smalltalk (Tonel-format source under src/). Implement this feature using TDD.

Context — kanban issue 1788438796232 (送信時にByteArrayはutf8文字列にencodeしないオプション追加):
Today, when RediStick sends command values to Redis, both String and ByteArray values that are
not already a raw ByteArray end up passed through UTF8 encoding. That is lossy for values that
already are raw bytes (e.g. a String built from arbitrary binary data whose bytes are not valid
UTF8) — re-encoding as UTF8 can corrupt them. We want an opt-in mode where sending skips UTF8
transcoding entirely.

Relevant existing code (already investigated, use as your starting map — verify current line
numbers yourself since the file may have shifted):
- src/RediStick-Core/RsRedisEndpoint.class.st — has an existing raw-bytes-for-reading feature:
  instance variable `shouldReturnRawBytes`, accessors `shouldReturnRawBytes` / `shouldReturnRawBytes:`
  (category ~line 1197), `returnRawBytesWhile:` (~line 901, evaluates a block with the flag
  temporarily true, restoring the previous value in an ensure:), and `unifiedCommand:` reads the
  flag (~line 1235) to decide whether to return raw bytes from replies. There is also a private
  method `utf8BytesFromString: aString` (category private-encoding, ~line 1266) which delegates to
  `self portableUtil utf8BytesFromString: aString` — this is the single choke point used both by
  `writeString: aString` (~line 1294, used for inline commands like QUIT, PING-style literals) and,
  indirectly, by every SET-style command value going through `writeUnifiedCommand:` (~line 1304),
  which calls `ea asRediStickBytesUsing: self` for each arg.
- src/RediStick-Core/Object.extension.st — `Object >> asRediStickBytesUsing: aRedisEndpoint` is
  `^ aRedisEndpoint utf8BytesFromString: self asString`. This is what String (and anything without
  its own override) goes through when passed as a command value arg (e.g. `endpoint set: key value: aString`).
- src/RediStick-Core/ByteArray.extension.st — `ByteArray >> asRediStickBytesUsing: aRedisEndpoint`
  already just returns `self` (raw bytes, no encoding) — ByteArray values passed as command args
  are already unaffected by UTF8 encoding. The actual problem is String values that represent raw
  binary data, which go through Object''s default and hit `utf8BytesFromString:`.
- src/RediStick-Tests/RsRedisEndpointTest.class.st — existing tests reference
  `shouldReturnRawBytes` / `shouldReturnRawBytes:` / `returnRawBytesWhile:` (search the file; there
  are several call sites covering the read-side feature).

What to build, following the issue''s proposed approach:
1. Rename `shouldReturnRawBytes` (ivar + both accessor methods) to `shouldUseRawBytes` throughout
   RsRedisEndpoint.class.st. Update every call site, including inside `unifiedCommand:`.
2. Rename `returnRawBytesWhile:` to `useRawBytesWhile:`. Same body/semantics (temporarily sets the
   flag true, restores the previous value via ensure:, even on error).
3. Change `utf8BytesFromString: aString` so that when `self shouldUseRawBytes` is true, it returns
   the raw bytes of the string directly (e.g. `aString asByteArray`) instead of calling
   `self portableUtil utf8BytesFromString: aString`. Keep the existing nil-check
   (`aString ifNil: [ ^nil ]`) before that branch. Since both `writeString:` and
   `Object>>asRediStickBytesUsing:` route through this one method, this single change makes both
   the inline-command path and the SET-style value-arg path skip UTF8 encoding under the flag —
   don''t special-case `writeString:` separately, and don''t touch ByteArray.extension.st (it is
   already correct).
4. Update every existing reference to the old names (`shouldReturnRawBytes`,
   `shouldReturnRawBytes:`, `returnRawBytesWhile:`) across the whole src/ tree (production code and
   RsRedisEndpointTest.class.st) to the new names — this is a rename, not an addition, so the old
   names should not remain anywhere.
5. Update the "Raw Bytes Mode" section of CLAUDE.md at the repo root to reflect the new method
   names and the fact that the flag now also governs write-side (non-UTF8) encoding, not just
   read-side raw replies.

TDD process — do this in order, don''t skip steps:
1. Write a new failing test in RsRedisEndpointTest (e.g. testUseRawBytesWhileSendingStringNotUtf8Encoded)
   that: builds a String from bytes that are NOT valid UTF8 (e.g. a lone byte in the 0x80-0xFF
   range, or any byte sequence that would be mangled by UTF8 encode/decode), sends it as a value
   via `endpoint useRawBytesWhile: [ endpoint set: key value: theRawString ]`, then reads it back
   raw (e.g. `endpoint useRawBytesWhile: [ endpoint get: key ]` or however the existing raw-read
   API composes) and asserts the bytes round-trip exactly, byte for byte. Also add/keep a
   regression test that confirms the OLD renamed methods still work for the read-side use case
   (rewritten to use the new names) — reuse the existing read-side tests just renamed, don''t
   delete coverage.
2. Run the new test via the smalltalk test tooling (import the RediStick-Core and
   RediStick-Tests packages, then run RsRedisEndpointTest) and confirm it fails for the expected
   reason (UTF8 corruption / MNU on old method names) before implementing.
3. Implement the rename + utf8BytesFromString: change described above.
4. Re-import and re-run RsRedisEndpointTest until the new test and all renamed tests pass.

Validate every Tonel file you edit with the smalltalk-validator tools before importing.'.
			t goal: 'the new raw-bytes write-mode test and all renamed raw-bytes tests in RsRedisEndpointTest pass' ]
	} agentBy: [ :a | a claude ].
	builder seq: {
		builder topicBy: [ :t |
			t title: 'Run full test suite and report'.
			t prompt: 'The previous step implemented a raw-bytes write mode for RediStick (renamed
shouldReturnRawBytes -> shouldUseRawBytes, returnRawBytesWhile: -> useRawBytesWhile:, and changed
utf8BytesFromString: in src/RediStick-Core/RsRedisEndpoint.class.st to skip UTF8 encoding when the
flag is set). Re-import the RediStick-Core and RediStick-Tests packages (and any other packages
touched) into the running Smalltalk image from their Tonel sources under src/, then run the full
RsRedisEndpointTest suite plus any other test classes referencing the renamed methods. Report a
clear pass/fail count and paste any failure messages verbatim — do not just say "tests pass"
without showing the actual run output. If anything fails, fix it and re-run until the full suite
is green, since this test step is meant to catch regressions from the previous rename across the
whole codebase, not just the new test.' ]
	} agentBy: [ :a | a claude ].
	builder seq: {
		builder topicBy: [ :t |
			t title: 'Lint and review'.
			t prompt: 'Review the changes made in this orchestration for the RediStick raw-bytes
write-mode feature (renaming shouldReturnRawBytes -> shouldUseRawBytes and
returnRawBytesWhile: -> useRawBytesWhile: in src/RediStick-Core/RsRedisEndpoint.class.st, the
utf8BytesFromString: behavior change, updated tests in
src/RediStick-Tests/RsRedisEndpointTest.class.st, and the CLAUDE.md doc update). Consult the
st-lint skill (or the smalltalk-validator MCP tools) and run it against every changed Tonel (.st)
file to check for syntax and best-practice issues. Also consult the smalltalk-developer skill''s
style guide section and check the changes against it (method categorization, class comment
placement, naming conventions). Fix whatever issues either check surfaces, re-validating after
each fix. Confirm at the end that no old references to shouldReturnRawBytes or
returnRawBytesWhile: remain anywhere in src/ or CLAUDE.md.' ]
	} agentBy: [ :a | a claude ] ].
script forkRunThen: [ :orc | Transcript crShow: 'Done: ' , orc result ]
	onTimeout: [ :timeoutStep :ex | Transcript crShow: 'Timed out: ' , timeoutStep printString ].
script register
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via st-eval.
`forkRunThen:onTimeout:` runs the orchestration in the background and returns immediately — watch
for the completion block's own report (via Transcript), the `onTimeout:` block's report if a step
stalls, or check progress with `AbOrchestrationManager default orchestrationAt: <orchestration script id>`.
