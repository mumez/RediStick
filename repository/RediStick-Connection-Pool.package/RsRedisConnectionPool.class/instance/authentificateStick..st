factory
authentificateStick: aStick
	"throw anError if wrong password or username "
	password
		ifNotNil: [ userName
				ifNil: [ aStick endpoint auth: password ]
				ifNotNil: [ aStick endpoint auth: password user: userName ] ]