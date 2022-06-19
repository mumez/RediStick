baseline
baseline: spec
	<baseline>

	spec for: #'common' do: [
		self stick: spec.
		spec 
			package: 'RediStick-Core' with: [spec requires: 'Stick'].
		spec package: 'RediStick-Connection-Pool' with: [
				spec requires: #('RediStick-Core')].
		spec package: 'RediStick-Pubsub' with: [
				spec requires: #('RediStick-Core')].
		spec package: 'RediStick-Tests' with: [
				spec requires: #('RediStick-Core' 'RediStick-Connection-Pool' 'RediStick-Pubsub')].
		spec 
			group: 'default' with: #('Core');
			group: 'Core' with: #('RediStick-Core');
			group: 'ConnectionPool' with: #('RediStick-Connection-Pool');
			group: 'Pubsub' with: #('RediStick-Pubsub');
			group: 'Tests' with: #('RediStick-Tests')].
