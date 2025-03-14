comparing
compareSubId: other
	| leftId rightId |
	leftId := self subId ifNil: [0].
	rightId := other subId ifNil: [0].
	^ leftId asNumber < rightId asNumber 