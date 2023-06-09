loading
loadIdsFrom: anArray
	self results: (anArray collect: [:each | RsSearchResult id: each]).