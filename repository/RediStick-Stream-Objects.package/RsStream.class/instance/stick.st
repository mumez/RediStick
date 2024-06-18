accessing
stick
	^ stick ifNil: [ stick := self createStick ]