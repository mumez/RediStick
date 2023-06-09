private
populateDateOn: endpoint
	endpoint hSet:'rs:test:doc:1' dictionary: ({'id'-> 1. 'name'->'Pharo Smalltalk'} as: Dictionary).
	endpoint hSet:'rs:test:doc:2' dictionary: ({'id'-> 2. 'name'->'Squeak Smalltalk'} as: Dictionary).
	endpoint hSet:'rs:test:doc:3' dictionary: ({'id'-> 3. 'name'->'VisualWorks Smalltalk'} as: Dictionary).
	endpoint hSet:'rs:test:doc:4' dictionary: ({'id'-> 4. 'name'->'VisualAge Smalltalk'} as: Dictionary).