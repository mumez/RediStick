startup - shutdown
subscribeAllOnStartUp
	<script>
	self initialize.
	 RsRedisPubsubChannel initialize.
	^self default subscribeAllOnStartUp