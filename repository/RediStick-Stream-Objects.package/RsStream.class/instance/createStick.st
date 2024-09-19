factory
createStick
	| newStick |
	newStick := RsRediStick targetUrl: self settings targetUrl.
	newStick beSticky.
	newStick connect.
	^ newStick