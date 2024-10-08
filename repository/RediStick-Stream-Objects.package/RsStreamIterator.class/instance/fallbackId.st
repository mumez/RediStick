private
fallbackId
	^ self stream first
		  ifNotNil: [ :first | first id ]
		  ifNil: [ RsStreamMessageId zero ]