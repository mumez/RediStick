tests
testUserNamePasswordShouldNotRaiseDNU
	[ connectionPool userName: nil password: self goodPassword ]
		on: MessageNotUnderstood
		do: [ self fail ]