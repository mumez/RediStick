startup - shutdown
subscribeAllAndStart
	<script>
	self initialize.
	RsRedisPubsubChannel initialize.
	^self default subscribeAllAndStart