commands-stream
xAdd: key id: id fieldAndValues: fieldAndValues
	^ self xAdd: key createNotExists: false trimOptions: nil id: id fieldsAndValues: fieldAndValues