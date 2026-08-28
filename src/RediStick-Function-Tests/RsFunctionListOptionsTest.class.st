"
I test the RsFunctionListOptions options builder.

Responsibility:
- Verify command line argument generation for FUNCTION LIST options.

Collaborators:
- RsFunctionListOptions
"
Class {
	#name : 'RsFunctionListOptionsTest',
	#superclass : 'TestCase',
	#category : 'RediStick-Function-Tests',
	#package : 'RediStick-Function-Tests'
}

{ #category : 'tests' }
RsFunctionListOptionsTest >> testDefaults [
	| opts |
	opts := RsFunctionListOptions new.
	self assert: opts libraryName isNil.
	self deny: opts withCode.
	self assert: opts asArray equals: #()
]

{ #category : 'tests' }
RsFunctionListOptionsTest >> testLibraryName [
	| opts |
	opts := RsFunctionListOptions new.
	opts libraryName: 'mylib*'.
	self assert: opts asArray equals: #('LIBRARYNAME' 'mylib*')
]

{ #category : 'tests' }
RsFunctionListOptionsTest >> testWithCode [
	| opts |
	opts := RsFunctionListOptions new.
	opts withCode: true.
	self assert: opts asArray equals: #('WITHCODE')
]

{ #category : 'tests' }
RsFunctionListOptionsTest >> testLibraryNameAndWithCode [
	| opts |
	opts := RsFunctionListOptions new.
	opts libraryName: 'mylib'.
	opts withCode: true.
	self assert: opts asArray equals: #('LIBRARYNAME' 'mylib' 'WITHCODE')
]
