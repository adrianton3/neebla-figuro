'use strict'


add = ({ x, y }) ->
	make @x + x, @y + y


sub = ({ x, y }) ->
	make @x - x, @y - y


scale = (s) ->
	make @x * s, @y * s


normalize = ->
	length = Math.sqrt @x ** 2 + @y ** 2
	make @x / length, @y / length


flip = ->
	make @y, -@x


fromAngle = (angle) ->
	make (Math.cos angle), (Math.sin angle)


equals = ({ x, y }) ->
	@x == x and @y == y


less = ({ x, y }) ->
	@x < x or (@x == x and @y < y)


proto = { add, sub, scale, flip, normalize, equals, less }


make = (x, y) ->
	instance = Object.create proto
	Object.assign instance, { x, y }
	Object.freeze instance
	instance


window.Vec ?= {}
Object.assign window.Vec, { make, fromAngle }