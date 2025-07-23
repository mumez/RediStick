Class {
	#name : 'BaselineOfRediStick',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfRediStick',
	#package : 'BaselineOfRediStick'
}

{ #category : 'baseline' }
BaselineOfRediStick >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		self stick: spec.
		spec 
			package: 'RediStick-Core' with: [spec requires: 'Stick'].
		spec package: 'RediStick-Connection-Pool' with: [
				spec requires: #('RediStick-Core')].
		spec package: 'RediStick-Pubsub' with: [
				spec requires: #('RediStick-Connection-Pool')].
		spec package: 'RediStick-Tests' with: [
				spec requires: #('RediStick-Core' 'RediStick-Connection-Pool' 'RediStick-Pubsub')].
			
		spec package: 'RediStick-Stream' with: [
				spec requires: #('RediStick-Core')].
		spec package: 'RediStick-Stream-Tests' with: [
				spec requires: #('RediStick-Tests' 'RediStick-Stream')].
		spec package: 'RediStick-Stream-Objects' with: [
				spec requires: #('RediStick-Stream')].
		spec package: 'RediStick-Stream-Objects-Tests' with: [
				spec requires: #('RediStick-Tests' 'RediStick-Stream-Objects')].
			
		spec package: 'RediStick-Search' with: [
				spec requires: #('RediStick-Core')].
		spec package: 'RediStick-Search-Tests' with: [
				spec requires: #('RediStick-Tests' 'RediStick-Search')].
			
		spec 
			group: 'default' with: #('Core');
			group: 'Core' with: #('RediStick-Core');
			group: 'ConnectionPool' with: #('RediStick-Connection-Pool');
			group: 'Pubsub' with: #('RediStick-Pubsub');
			group: 'Tests' with: #('RediStick-Tests').
			
		spec
			group: 'Stream' with: #('RediStick-Stream');
			group: 'StreamTests' with: #('RediStick-Stream-Tests').
			
		spec
			group: 'StreamObjects' with: #('RediStick-Stream-Objects');
			group: 'StreamObjectsTests' with: #('RediStick-Stream-Objects-Tests').
			
		spec
			group: 'Search' with: #('RediStick-Search');
			group: 'SearchTests' with: #('RediStick-Search-Tests')].

]

{ #category : 'external projects' }
BaselineOfRediStick >> stick: spec [
	spec
		baseline: 'Stick'
		with: [ spec
				repository: 'github://mumez/Stick/src';
				loads: 'default' ]
]
