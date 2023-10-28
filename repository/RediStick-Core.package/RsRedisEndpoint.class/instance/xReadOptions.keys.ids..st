commands-stream
xReadOptions: options keys: keys ids: ids
	| args |
	args := { 'XREAD' } asOrderedCollection.
	args addAll: options asArray.
	args add: 'STREAMS'.
	args addAll: keys.
	args addAll: ids.
	^ self unifiedCommand: args