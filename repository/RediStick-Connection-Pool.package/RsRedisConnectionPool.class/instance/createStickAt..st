factory
createStickAt: key
	"override"
	| stick |
	stick := RsRediStick targetUrl: self primaryUrl.
	stick onError: [ :e | e pass ].
	stick beSticky.
	stick connect.
	^ stick