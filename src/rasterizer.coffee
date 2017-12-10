'use strict'


rasterize = (context, palette, elements) ->
	elements.forEach ({ points, color }) ->
#		context.fillStyle = palette[color]
		context.fillStyle = color

		context.beginPath()

		context.moveTo points[0].x, points[0].y
		for i in [0...points.length]
			point = points[i]
			context.lineTo point.x, point.y

		context.fill()

		return


window.Rasterizer ?= {}
Object.assign(
	window.Rasterizer
	{
		rasterize
	}
)