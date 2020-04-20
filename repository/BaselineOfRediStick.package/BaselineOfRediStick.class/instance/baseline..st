baseline
baseline: spec
	<baseline>

	spec for: #'common' do: [
		self stick: spec.
		spec 
			package: 'RediStick-Core'.
		spec 
			group: 'default' with: #('Core');
			group: 'Core' with: #('RediStick-Core')].
