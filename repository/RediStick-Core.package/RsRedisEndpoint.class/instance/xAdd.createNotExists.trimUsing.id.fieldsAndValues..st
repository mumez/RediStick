commands-stream
xAdd: key createNotExists: createNotExists trimUsing: trimOptionsBlock id: id fieldsAndValues: fieldAndValues
	| trimOptions |
	trimOptions := RsStreamTrimOptions new.
	trimOptionsBlock value: trimOptions.
	^ self xAdd: key createNotExists: createNotExists trimOptions: trimOptions id: id fieldsAndValues: fieldAndValues