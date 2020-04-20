commands-connection
auth: password
	^ self
		unifiedCommand:
			{'AUTH'.
			password}