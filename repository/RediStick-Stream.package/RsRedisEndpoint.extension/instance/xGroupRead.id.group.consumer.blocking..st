*RediStick-Stream
xGroupRead: key id: id group: group consumer: consumer blocking: milliseconds
	^ self xGroupRead: key id: id group: group consumer: consumer using: [ :opts | opts blocking: milliseconds ] 