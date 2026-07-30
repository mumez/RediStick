Class {
	#name : 'RsTsReducer',
	#superclass : 'Object',
	#instVars : [
		'reducerName'
	],
	#category : 'RediStick-TimeSeries',
	#package : 'RediStick-TimeSeries'
}

{ #category : 'accessing' }
RsTsReducer >> reducerName [
	^ reducerName
]

{ #category : 'accessing' }
RsTsReducer >> reducerName: aString [
	reducerName := aString
]

{ #category : 'reducers' }
RsTsReducer >> avg [
	self reducerName: 'avg'
]

{ #category : 'reducers' }
RsTsReducer >> count [
	self reducerName: 'count'
]

{ #category : 'reducers' }
RsTsReducer >> countAll [
	"Requires Redis TimeSeries 8.6+"
	self reducerName: 'countAll'
]

{ #category : 'reducers' }
RsTsReducer >> countNaN [
	"Requires Redis TimeSeries 8.6+"
	self reducerName: 'countNaN'
]

{ #category : 'reducers' }
RsTsReducer >> first [
	self reducerName: 'first'
]

{ #category : 'reducers' }
RsTsReducer >> last [
	self reducerName: 'last'
]

{ #category : 'reducers' }
RsTsReducer >> max [
	self reducerName: 'max'
]

{ #category : 'reducers' }
RsTsReducer >> min [
	self reducerName: 'min'
]

{ #category : 'reducers' }
RsTsReducer >> range [
	self reducerName: 'range'
]

{ #category : 'reducers' }
RsTsReducer >> stdP [
	self reducerName: 'std.p'
]

{ #category : 'reducers' }
RsTsReducer >> stdS [
	self reducerName: 'std.s'
]

{ #category : 'reducers' }
RsTsReducer >> sum [
	self reducerName: 'sum'
]

{ #category : 'reducers' }
RsTsReducer >> twa [
	self reducerName: 'twa'
]

{ #category : 'reducers' }
RsTsReducer >> varP [
	self reducerName: 'var.p'
]

{ #category : 'reducers' }
RsTsReducer >> varS [
	self reducerName: 'var.s'
]
