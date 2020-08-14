commands-connection
auth: password user: userName
	^ self
		unifiedCommand:
			{'AUTH'.
			userName.
			password}