consumers
consumerNamed: consumerName
	^ (self consumerClass named: consumerName on: self) assureExistence