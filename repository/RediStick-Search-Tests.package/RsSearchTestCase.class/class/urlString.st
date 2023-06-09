accessing
urlString
	^ super urlString ifNotNil: [ :str | str copyReplaceAll: 'sync:' with: 'stack:' ]