actions
assureExistence
	[self endpoint xGroupCreate: self streamName group: self name id: self fromId createNotExists: true] on: Error do: [ :ex | ex inspect ]