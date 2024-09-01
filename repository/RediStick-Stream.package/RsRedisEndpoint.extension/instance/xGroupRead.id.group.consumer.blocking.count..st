*RediStick-Stream
xGroupRead: key id: id group: group consumer: consumer blocking: milliseconds count: count
	^ self
		  xGroupRead: key
		  id: id
		  group: group
		  consumer: consumer
		  using: [ :opts |
			  opts
				  blocking: milliseconds;
				  count: count ]