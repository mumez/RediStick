actions
filter: aNumericField min: aMin max: aMax
    self options addAll: {
				'FILTER'.
				aNumericField asString.
				aMin asString.
				aMax asString }.