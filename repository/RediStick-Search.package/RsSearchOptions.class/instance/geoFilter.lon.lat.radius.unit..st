actions
geoFilter: aGeoField lon: aLon lat: aLat radius: aRadius unit: aUnit
    self options addAll: {
				'GEOFILTER'.
				aGeoField asString.
				aLon asString.
				aLat asString.
				aRadius asString.
				aUnit asString }.