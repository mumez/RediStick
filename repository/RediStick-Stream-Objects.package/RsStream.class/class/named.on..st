instance creation
named: streamName on: rediStick
	^ self new
		  name: streamName;
		  stick: rediStick;
		  yourself