*RediStick-Stream
xAdd: key id: id fieldAndValues: fieldAndValues
	^ self xAdd: key createNotExists: true trimOptions: nil id: id fieldsAndValues: fieldAndValues