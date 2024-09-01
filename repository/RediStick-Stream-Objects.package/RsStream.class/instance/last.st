reading
last
	"^ self endpoint xRead: self name id: RsStreamMessageId max"
	| elems |
	elems := self last: 1.
	^ elems ifNotEmpty: [ elems first ] ifEmpty: [  ]