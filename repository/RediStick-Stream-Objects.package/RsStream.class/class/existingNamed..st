instance creation
existingNamed: streamName
	^ self new
		  createNotExists: false;
		  yourself