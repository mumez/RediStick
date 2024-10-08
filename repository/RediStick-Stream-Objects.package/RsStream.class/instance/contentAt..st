reading
contentAt: aMessageId
	| conts |
	conts :=  self contentsFrom: aMessageId to: aMessageId.
	conts ifEmpty: [ ^ nil ].
	^ conts first