factory
connectionPool
	^ connectionPool ifNil: [connectionPool := self connectionPoolClass default]