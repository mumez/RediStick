Class {
	#name : 'RsError',
	#superclass : 'SkError',
	#category : 'RediStick-Core',
	#package : 'RediStick-Core'
}

{ #category : 'instance creation' }
RsError class >> canNotGetReply [
	^self kind: #CannotGetReply
]

{ #category : 'instance creation' }
RsError class >> invalidReplyToken [
	^self kind: #InvalidReplyToken
]

{ #category : 'instance creation' }
RsError class >> pubsub [
	^self kind: #Pubsub
]
