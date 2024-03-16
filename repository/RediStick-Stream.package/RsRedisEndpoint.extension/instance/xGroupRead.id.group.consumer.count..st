*RediStick-Stream
xGroupRead: key id: id group: group consumer: consumer count: count
	^ self xGroupRead: key id: id group: group consumer: consumer using: [ :opts | opts count: count ] 