deleting
deleteAtIds: streamMessageIds
	^ self endpoint xDel: self name ids: streamMessageIds