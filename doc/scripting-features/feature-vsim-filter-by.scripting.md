# Feature: VSIM fluent filter API (`filterBy:`)

## Goal

`RsVectorSetSimOptions` gains a `filterBy:` method that accepts a block. The block receives a root object (`elem`) representing the VSIM FILTER expression's implicit document root. Sending messages to `elem` (attribute access via `@`, comparisons, logical combinators) builds an AST-like expression object; calling `asFilterString` on the built expression renders the exact string VSIM's `FILTER` argument expects (e.g. `'.year >= 1980 and .rating > 7'`). The existing `filter:` (raw string) API keeps working unchanged.

## Orchestration Shape

sequential, three independent phases each in its own `seq:` block: implement (TDD, goal-driven) → run tests (no goal) → lint & review (goal-driven), all via claude, against the existing repo.

## Working Directory

`/home/mumez/git/RediStick` (existing checked-out RediStick repo, current branch `feature/vector-sets`)

## Background researched before generating this script

- `RsRedisEndpoint >> vSim:queryBy:using:` (in `src/RediStick-VectorSet/RsRedisEndpoint.extension.st`) builds VSIM args via `RsVectorSetSimOptions >> asArray`, which does `self filter ifNotNil: [ :f | opts addAll: { 'FILTER'. f } ]` — `filter` is stored purely as a String today, set via `RsVectorSetSimOptions >> filter:`.
- `RsVectorSetSimOptions` (`src/RediStick-VectorSet/RsVectorSetSimOptions.class.st`) instVars: `withScores withAttribs count ef filter filterEf truth noThread`.
- Existing filter test: `RsVectorSetTest >> testVSimWithFilter` (`src/RediStick-VectorSet-Tests/RsVectorSetTest.class.st`) uses `opts filter: '.foo == "bar"'` — a raw string. Test style: `self setUpSimTestSet: 'vs:sim:<feature>'` for a unique key, then `stick endpoint vSim: key queryBy: [...] using: [...]`, then assert on `(results collect: [:each | each element]) asArray`.
- `RsTsFilter`/`RsTsFilterBuilder` (`src/RediStick-TimeSeries/`) were checked as a possible reference but are NOT directly reusable: TimeSeries filters are a flat list of independent `label OP value` filters (implicitly AND-ed as separate command args), not a single boolean expression string. VSIM's FILTER argument is a single expression string supporting `&&`/`and`, `||`/`or`, `!`/`not`, comparisons (`==`, `!=`, `>`, `>=`, `<`, `<=`), `in` with array literals, dot-attribute access (`.name`), and parentheses for grouping — see https://redis.io/docs/latest/develop/data-types/vector-sets/filtered-search/#expression-syntax. So a real AST with `and:`/`or:`/`not` composition is needed here, unlike the flat TS filter list. Reuse only the *style* conventions from TS (class-side factory methods, cascades, `asString`-style rendering, colocated `*Test` classes), not the TS class structure itself.
- Package layout: new classes belong in `src/RediStick-VectorSet/` (implementation) and `src/RediStick-VectorSet-Tests/` (tests), alongside the existing `RsVectorSetSimOptions`, `RsVectorSetSimQuery`, `RsVectorSetSimResult`, `RsVectorSetTest`, `RsVectorSetTestCase`.

## Script

```Smalltalk
| script |
script := AgenticBrowser scriptBy: [ :builder |
    builder sharedDirectoryPath: '/home/mumez/git/RediStick'.

    builder seq: {
        builder topicBy: [ :t |
            t title: 'Implement VSIM filterBy: fluent API (TDD)'.
            t prompt: 'In the RediStick Pharo Smalltalk repo (already checked out at this working directory, Tonel format, current branch feature/vector-sets), implement a fluent filter-building API for the Redis Vector Set VSIM command''s FILTER argument, following strict TDD (write a failing test first, then implement, then verify it passes).

CONTEXT (already researched, do not re-derive):
- RsVectorSetSimOptions (src/RediStick-VectorSet/RsVectorSetSimOptions.class.st) currently has a `filter:` setter storing a raw String, consumed by `asArray` as `self filter ifNotNil: [ :f | opts addAll: { ''FILTER''. f } ]`. Do NOT change this string-based mechanism or its wire format - it must keep working exactly as today for backward compatibility.
- RsRedisEndpoint>>vSim:queryBy:using: (src/RediStick-VectorSet/RsRedisEndpoint.extension.st) is the command entry point; it does not need to change.
- Existing integration test style: RsVectorSetTest (src/RediStick-VectorSet-Tests/RsVectorSetTest.class.st), e.g. testVSimWithFilter uses `self setUpSimTestSet: ''vs:sim:<feature>''` for a unique key then `stick endpoint vSim: key queryBy: [...] using: [...]` then asserts on `(results collect: [:each | each element]) asArray`.
- The VSIM FILTER expression syntax (Redis docs: https://redis.io/docs/latest/develop/data-types/vector-sets/filtered-search/#expression-syntax) supports: comparisons `==`, `!=`, `>`, `>=`, `<`, `<=`; logical `and`/`&&`, `or`/`||`, `not`/`!`; dot-attribute access like `.year`; numeric and string (double-quoted) literals; array literals for the `in` operator, e.g. `.color in ["red","blue"]`; and parentheses for grouping.

REQUIREMENTS:
1. Add new classes in src/RediStick-VectorSet/ (package RediStick-VectorSet, one class per Tonel file, following this repo''s Tonel conventions) implementing a small filter-expression AST:
   - A root/element object (e.g. `RsVectorSetFilterElement`) that responds to `@ aString` (attribute access) and returns an attribute-reference object.
   - An attribute-reference object (e.g. `RsVectorSetFilterAttribute`) that responds to comparison messages against a Smalltalk literal (Number, String, or a Collection for `in:`) and returns a boolean expression node: `=` (renders as `==`), `~=` (renders as `!=`), `>`, `>=`, `<`, `<=`, and `in:` (renders as `in [...]` with a bracketed, comma-separated, quoted-as-needed literal list).
   - Boolean expression nodes (comparisons, and/or/not) all support `&` (AND), `|` (OR), and unary `not` for further composition, so expressions like `((elem @ ''year'') >= 1980) & ((elem @ ''rating'') > 7)` type-check and compose.
   - Every expression node implements `asFilterString` producing the exact VSIM FILTER string. Simple two-term AND/OR chains should render without superfluous parentheses (e.g. `.year >= 1980 and .rating > 7`, matching the example in the feature request), but nested/mixed logical combinations must add parentheses where needed to preserve the intended grouping (e.g. NOT and mixed AND/OR).
   - String literal values must be rendered double-quoted in the output; numeric literals rendered as-is.
   - Keep this AST class hierarchy minimal - do not over-engineer beyond what is needed for `=, ~=, >, >=, <, <=, in:, &, |, not` and array/string/number literals.
2. Add `RsVectorSetSimOptions >> filterBy: aBlock` which creates the root element object, evaluates `aBlock value: rootElement`, calls `asFilterString` on the result, and passes that string to the existing `filter:` setter (so the wire format and `asArray` logic are completely unchanged - `filterBy:` is pure sugar over `filter:`).
3. Keep `filter:` (raw String) working exactly as before - do not remove or alter it. Both `filter:` and `filterBy:` must be usable independently.
4. Write unit tests for the new AST classes'' `asFilterString` output (no Redis connection needed) in a new test class in src/RediStick-VectorSet-Tests/ (e.g. `RsVectorSetFilterTest`), covering: single comparisons for each operator, `in:` with a literal array, AND/OR combination without extra parens for the simple two-term case, a NOT case, and a mixed AND/OR case that needs parentheses to disambiguate.
5. Add at least one integration test to RsVectorSetTest (src/RediStick-VectorSet-Tests/RsVectorSetTest.class.st) that mirrors `testVSimWithFilter` but uses `filterBy:` instead of a raw string, verifying the real VSIM command run against Redis returns the expected filtered element(s).
6. Validate every new/edited Tonel file with the smalltalk-validator MCP tools (or the st-validate skill) before importing, then import the RediStick-VectorSet and RediStick-VectorSet-Tests packages via the smalltalk-interop MCP tools (or st-import skill) and run the tests via smalltalk-interop run_class_test / run_package_test (or the st-test skill) to confirm they pass before moving on.

Do not touch any other package or unrelated file.'.
            t goal: 'RsVectorSetFilterElement/Attribute/expression AST classes and RsVectorSetSimOptions>>filterBy: are implemented and imported into the running image, and both the new RsVectorSetFilterTest unit tests and the new filterBy: integration test in RsVectorSetTest pass' ]
    } agentBy: [ :a | a claude ].

    builder seq: {
        builder topicBy: [ :t |
            t title: 'Run full VectorSet test suite'.
            t prompt: 'In the RediStick repo at this working directory, re-import the RediStick-VectorSet and RediStick-VectorSet-Tests packages (they may have just been changed) using the smalltalk-interop MCP tools or the st-import skill, then run the full RsVectorSetTest test class and the new RsVectorSetFilterTest test class (via smalltalk-interop run_class_test, or the st-test skill). Report exact pass/fail counts for each test class and the full text of any failures or errors. Do not fix anything yet in this step - just report results clearly.' ]
    } agentBy: [ :a | a claude ].

    builder seq: {
        builder topicBy: [ :t |
            t title: 'Lint and review VSIM filterBy: changes'.
            t prompt: 'In the RediStick repo at this working directory, review the Tonel files changed for the VSIM filterBy: fluent filter feature (the new filter AST classes under src/RediStick-VectorSet/, the filterBy: addition to RsVectorSetSimOptions, and the new/changed tests under src/RediStick-VectorSet-Tests/). Consult the st-lint skill (or the smalltalk-validator MCP tools'' lint_tonel_smalltalk_from_file) against every changed/added Tonel file, and consult the smalltalk-developer skill''s style guide section for this project''s Smalltalk conventions (naming, method categorization, class comments, cascade usage, avoiding over-engineering). Fix whatever issues are found directly in the Tonel files, re-validate, re-import via smalltalk-interop (or st-import), and re-run the RsVectorSetFilterTest and RsVectorSetTest test classes via smalltalk-interop run_class_test (or st-test) to confirm everything still passes after your fixes. Report a summary of what was found and fixed.'.
            t goal: 'all changed Tonel files pass lint/validation and this project''s style guide, and RsVectorSetFilterTest plus RsVectorSetTest still pass after any fixes' ]
    } agentBy: [ :a | a claude ]
].
script forkRunThen: [ :orc | Transcript crShow: 'Done: ' , orc result ].
script register
```

## How to run

Paste the script above into a Pharo Playground, or ask the assistant to run it via st-eval. `forkRunThen:` runs the orchestration in the background and returns immediately — watch for the `forkRunThen:` block's own report (e.g. via Transcript), or check progress with `AbOrchestrationManager default orchestrationAt: <orchestration script id>` (the id printed by `script register`).
