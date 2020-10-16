factory
createStickAt: key
	"override"

	| stick |
	stick := RsRediStick targetUrl: self primaryUrl.
	stick beSticky.
	stick userName: self userName password: self password.
	stick connect.
	^ stick