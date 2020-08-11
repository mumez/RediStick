factory
createStickAt: key
	"override"

	| stick |
	stick := RsRediStick targetUrl: self primaryUrl.
	stick beSticky.
	stick connect.
	self authentificateStick: stick.
	^ stick