consumer-groups
consumerGroupNamed: groupName fromId: fromId
	| consumerGroup |
	consumerGroup := self consumerGroupClass named: groupName on: self from: fromId.
	consumerGroup assureExistence.
	^ consumerGroup