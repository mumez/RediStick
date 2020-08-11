factory
createStickAt: key
	"override"

	| stick |
	stick := RsRediStick targetUrl: self primaryUrl.
	stick beSticky.
	stick connect.
	^ stick