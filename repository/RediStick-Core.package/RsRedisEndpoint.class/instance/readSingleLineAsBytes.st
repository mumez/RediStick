private replies
readSingleLineAsBytes
	| upToCr |
	upToCr := self socketStream upTo: 13 "Character cr asInteger".
	^ self socketStream peek = 10 "Character lf asInteger"
		ifTrue: [ self socketStream next. upToCr ]
		ifFalse: [ upToCr , self parseSingleLine ]