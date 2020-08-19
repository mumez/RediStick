private
authentificate
	password
		ifNotNil: [ userName
				ifNil: [ self endpoint auth: password ]
				ifNotNil: [ self endpoint auth: password user: userName ] ]