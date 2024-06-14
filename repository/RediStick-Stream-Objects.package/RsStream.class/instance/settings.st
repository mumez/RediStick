accessing
settings

	^ settings ifNil: [ settings := RsStreamSettings default ]