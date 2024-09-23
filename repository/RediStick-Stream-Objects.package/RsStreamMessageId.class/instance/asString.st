printing
asString
	^ String streamContents: [ :strm | self printOn: strm ]