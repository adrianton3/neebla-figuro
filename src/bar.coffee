'use strict'


proto = {}


make = (line, capAngles, width, hue) ->
	instance = Object.create proto

	Object.assign instance, {
		line
		capAngles
		width
		angle: line.angle
		free: false
		hue
	}
	Object.seal instance
	instance


window.Bar ?= {}
Object.assign window.Bar, { make }