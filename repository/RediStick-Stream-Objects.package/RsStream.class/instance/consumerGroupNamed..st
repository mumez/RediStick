consumer-groups
consumerGroupNamed: groupName
	^ (self consumerGroupClass named: groupName on: self) assureExistence 