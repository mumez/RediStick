consumers
consumersInfo
	| consumersInfo |
	consumersInfo :=  self endpoint xInfoConsumers: self streamName group: self name.
	^ consumersInfo inject: Dictionary new into: [ :sum :each | sum at: each name put: each; yourself ]