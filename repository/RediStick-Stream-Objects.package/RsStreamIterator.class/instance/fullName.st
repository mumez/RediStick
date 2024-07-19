accessing
fullName
	^ String streamContents: [ :str |
		  str
			  nextPutAll: self streamName;
			  nextPut: $:;
			  nextPutAll: self name;
			  nextPut: $:;
			  nextPutAll: self currentId asString]