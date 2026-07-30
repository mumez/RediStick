Class {
	#name : 'RsTsSchemaOptionsTest',
	#superclass : 'TestCase',
	#category : 'RediStick-TimeSeries-Tests',
	#package : 'RediStick-TimeSeries-Tests'
}

{ #category : 'tests' }
RsTsSchemaOptionsTest >> testDuplicatePolicyBlock [
	| opts |
	opts := RsTsCreateOptions new.
	opts duplicatePolicyBlock.
	self assertCollection: opts asArray equals: { 'DUPLICATE_POLICY'. 'BLOCK' }
]

{ #category : 'tests' }
RsTsSchemaOptionsTest >> testDuplicatePolicyFirst [
	| opts |
	opts := RsTsCreateOptions new.
	opts duplicatePolicyFirst.
	self assertCollection: opts asArray equals: { 'DUPLICATE_POLICY'. 'FIRST' }
]

{ #category : 'tests' }
RsTsSchemaOptionsTest >> testDuplicatePolicyLast [
	| opts |
	opts := RsTsCreateOptions new.
	opts duplicatePolicyLast.
	self assertCollection: opts asArray equals: { 'DUPLICATE_POLICY'. 'LAST' }
]

{ #category : 'tests' }
RsTsSchemaOptionsTest >> testDuplicatePolicyMax [
	| opts |
	opts := RsTsCreateOptions new.
	opts duplicatePolicyMax.
	self assertCollection: opts asArray equals: { 'DUPLICATE_POLICY'. 'MAX' }
]

{ #category : 'tests' }
RsTsSchemaOptionsTest >> testDuplicatePolicyMin [
	| opts |
	opts := RsTsCreateOptions new.
	opts duplicatePolicyMin.
	self assertCollection: opts asArray equals: { 'DUPLICATE_POLICY'. 'MIN' }
]

{ #category : 'tests' }
RsTsSchemaOptionsTest >> testDuplicatePolicySum [
	| opts |
	opts := RsTsCreateOptions new.
	opts duplicatePolicySum.
	self assertCollection: opts asArray equals: { 'DUPLICATE_POLICY'. 'SUM' }
]

{ #category : 'tests' }
RsTsSchemaOptionsTest >> testDuplicatePolicyInheritsToAlterOptions [
	| opts |
	opts := RsTsAlterOptions new.
	opts duplicatePolicyLast.
	self assertCollection: opts asArray equals: { 'DUPLICATE_POLICY'. 'LAST' }
]

{ #category : 'tests' }
RsTsSchemaOptionsTest >> testAlterOptionsIgnoresEncoding [
	| opts |
	opts := RsTsAlterOptions new.
	opts encoding: 'COMPRESSED'.
	self assertCollection: opts asArray equals: #()
]

{ #category : 'tests' }
RsTsSchemaOptionsTest >> testCreateOptionsWithIgnore [
	| opts |
	opts := RsTsCreateOptions new.
	opts duplicatePolicyLast; ignoreMaxTimediff: 1000; ignoreMaxValDiff: 0.5.
	self assertCollection: opts asArray
		equals: { 'DUPLICATE_POLICY'. 'LAST'. 'IGNORE'. 1000. 0.5 }
]
