initialize-release
initialize
	super initialize.
	lock := Monitor new.
	connections := Dictionary new