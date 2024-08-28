accessing
claimMinIdleMilliseconds

	^ claimMinIdleMilliseconds ifNil: [ claimMinIdleMilliseconds := self settings claimMinIdleMilliseconds ]