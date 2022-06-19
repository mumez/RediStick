factory
createStickAt: key
	"override"
	| stick |
	stick := RsRediStick targetUrl: self primaryUrl.
	stick beSticky. "beSwitchyWithAll: {self primaryUrl. self secondaryUrl}"
	stick connect.
	^ stick