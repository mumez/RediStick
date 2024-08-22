private
pollPending
	| minMessageId |
	minMessageId := self currentId ifNil: [ RsStreamMessageId zero ].
	^ self consumer pendingsAtMost: self readChunkSize after: minMessageId
	