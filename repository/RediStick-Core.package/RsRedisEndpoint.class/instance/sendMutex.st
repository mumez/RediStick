accessing
sendMutex
  ^ sendMutex ifNil: [ sendMutex := self portableUtil createMutex ]