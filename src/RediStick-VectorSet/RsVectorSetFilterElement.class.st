"
I am the root of a fluent filter-expression builder for Redis's VSIM FILTER
argument.

Responsibility:
- I answer an attribute reference for a given attribute name, the entry
  point for building a filter expression fluently.

Collaborators:
- RsVectorSetSimOptions: creates an instance of me and passes it to the
  block given to #filterBy:, then sends #asFilterString to the resulting
  expression to obtain the FILTER string.
- RsVectorSetFilterAttribute: answered by #@.

Public API and Key Messages:
- #@ aString - answers an RsVectorSetFilterAttribute for the given
  dot-path attribute name (e.g. `elem @ 'year'` refers to `.year`).

Internal Representation:
- (none)
"
Class {
	#name : 'RsVectorSetFilterElement',
	#superclass : 'Object',
	#category : 'RediStick-VectorSet',
	#package : 'RediStick-VectorSet'
}

{ #category : 'accessing' }
RsVectorSetFilterElement >> @ aString [
	^ RsVectorSetFilterAttribute new name: aString
]
