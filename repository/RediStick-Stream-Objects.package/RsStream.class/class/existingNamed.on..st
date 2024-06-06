instance creation
existingNamed: streamName on: rediStick
	^ (self named: streamName on: rediStick)
		  createNotExists: false;
		  yourself