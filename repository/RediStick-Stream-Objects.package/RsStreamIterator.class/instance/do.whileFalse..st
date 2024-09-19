actions
do: aBlock whileFalse: endConditionBlock
	^ self by: self settings iterationReadChunkSize do: aBlock whileFalse: endConditionBlock