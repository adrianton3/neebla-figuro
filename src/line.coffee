'use strict'


epsilon = 1e-7


intersect = (that) ->
	deltaThis = @end.sub @start
	deltaThat = that.end.sub that.start

	denom = -deltaThat.x * deltaThis.y + deltaThis.x * deltaThat.y

	return null if epsilon <= denom <= epsilon

	s = (-deltaThis.y * (@start.x - that.start.x) + deltaThis.x * (@start.y - that.start.y)) / denom
	t = (deltaThat.x * (@start.y - that.start.y) - deltaThat.y * (@start.x - that.start.x)) / denom

	if 0 <= s <= 1 and 0 <= t <= 1
		@start.add deltaThis.scale t
	else
		null


add = (that) ->
	make (@start.add that), (@end.add that)


parallel = (offset) ->
	delta = @end.sub @start
	flipped = delta.flip().normalize()

	@add flipped.scale offset


double = ->
	delta = @end.sub @start
	make (@start.sub delta), (@end.add delta)


shorten = ->
	shortDelta = (@end.sub @start).normalize().scale 14
	make (@start.add shortDelta), (@end.sub shortDelta)


proto = { intersect, add, parallel, double, shorten }


make = (a, b) ->
	[start, end] = if a.less b then [a, b] else [b, a]

	delta = end.sub start
	angle = Math.atan2 delta.y, delta.x

	instance = Object.create proto
	Object.assign instance, { start, end, angle }
	Object.freeze instance
	instance


window.Line ?= {}
Object.assign window.Line, { make }