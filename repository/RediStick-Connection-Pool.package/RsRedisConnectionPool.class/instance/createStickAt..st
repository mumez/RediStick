factory
createStickAt: key
	"override"

	| stick |
	stick := RsRediStick targetUrl: self primaryUrl.
	stick beSticky.
	stick username: userName password: password.
	stick connect.
	^ stick