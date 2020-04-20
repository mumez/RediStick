commands-lists
brPop: keys timeout: seconds
	^ self unifiedCommand: {'BRPOP'} , keys , {seconds}