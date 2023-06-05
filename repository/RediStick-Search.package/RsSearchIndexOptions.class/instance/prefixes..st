actions
prefixes: prefixes
	| prefixesString |
	prefixesString := ' ' join: prefixes.
    self basicPrefix: prefixes size with: prefixesString