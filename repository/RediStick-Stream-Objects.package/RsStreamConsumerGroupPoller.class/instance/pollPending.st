private
pollPending
	| minMessageId |
	minMessageId := RsStreamMessageId zero.
	^ self consumer pendingsAtMost: self readChunkSize after: minMessageId
	