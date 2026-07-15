Class {
	#name : 'RsTsAggregationTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsAggregationTest >> testSingleAggregator [
	| agg |
	agg := RsTsAggregation new.
	agg min.
	agg bucketDuration: 1000.
	self assertCollection: agg asArray equals: { 'AGGREGATION'. 'min'. 1000 }
]

{ #category : 'tests' }
RsTsAggregationTest >> testMultipleAggregatorsJoinedByComma [
	| agg |
	agg := RsTsAggregation new.
	agg min; avg; max.
	agg bucketDuration: 20.
	self assertCollection: agg asArray equals: { 'AGGREGATION'. 'min,avg,max'. 20 }
]

{ #category : 'tests' }
RsTsAggregationTest >> testAllAggregatorTokens [
	#( #avg 'avg' #sum 'sum' #min 'min' #max 'max' #range 'range' #count 'count'
	   #countNaN 'countNaN' #countAll 'countAll' #first 'first' #last 'last'
	   #stdP 'std.p' #stdS 'std.s' #varP 'var.p' #varS 'var.s' #twa 'twa' )
		pairsDo: [ :selector :token |
			| agg |
			agg := RsTsAggregation new.
			agg perform: selector.
			agg bucketDuration: 1.
			self assertCollection: agg asArray equals: { 'AGGREGATION'. token. 1 } ]
]
