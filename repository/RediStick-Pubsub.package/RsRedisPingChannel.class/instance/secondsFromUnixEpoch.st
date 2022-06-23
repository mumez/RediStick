private
secondsFromUnixEpoch
	^ (DateAndTime now asUTC - DateAndTime unixEpoch) asSeconds