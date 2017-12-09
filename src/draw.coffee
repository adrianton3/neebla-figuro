'use strict'


drawLine = (a, b) ->
	@context.beginPath()
	@context.moveTo a.x, a.y
	@context.lineTo b.x, b.y
	@context.stroke()

	return


drawPolygon = (points, color) ->
	@context.fillStyle = color
	@context.beginPath()

	point = points[0]
	@context.moveTo point.x, point.y

	for point in points
		@context.lineTo point.x, point.y

	@context.fill()

	return


computeBar = ({ line, capAngles, width }) ->
	delta = line.end.sub line.start
	flipped = delta.flip().normalize()

	startTop = line.start.add (flipped.scale width.top)
	startMid = line.start.add (flipped.scale width.mid)
	startLow = line.start.sub (flipped.scale width.low)

	endTop = line.end.add (flipped.scale width.top)
	endMid = line.end.add (flipped.scale width.mid)
	endLow = line.end.sub (flipped.scale width.low)

	preStartTop = startTop.sub delta
	preStartMid = startMid.sub delta
	preStartLow = startLow.sub delta

	postEndTop = endTop.add delta
	postEndMid = endMid.add delta
	postEndLow = endLow.add delta

	startCapOffset = (Vec.fromAngle capAngles.start).scale (width.top + width.low)
	endCapOffset = (Vec.fromAngle capAngles.end).scale (width.top + width.low)

	startCapTop = line.start.sub startCapOffset
	startCapLow = line.start.add startCapOffset

	endCapTop = line.end.sub endCapOffset
	endCapLow = line.end.add endCapOffset

	{
		start: {
			top: (Line.make preStartTop, postEndTop).intersect (Line.make startCapTop, startCapLow)
			mid: (Line.make preStartMid, postEndMid).intersect (Line.make startCapTop, startCapLow)
			low: (Line.make preStartLow, postEndLow).intersect (Line.make startCapTop, startCapLow)
		}
		end: {
			top: (Line.make preStartTop, postEndTop).intersect (Line.make endCapTop, endCapLow)
			mid: (Line.make preStartMid, postEndMid).intersect (Line.make endCapTop, endCapLow)
			low: (Line.make preStartLow, postEndLow).intersect (Line.make endCapTop, endCapLow)
		}
	}


drawBar = (bar) ->
	{ start, end } = computeBar bar

	@drawPolygon(
		[start.top, end.top, end.mid, start.mid],
		"hsl(#{bar.hue}, 70%, 30%)"
	)

	@drawPolygon(
		[start.mid, end.mid, end.low, start.low],
		"hsl(#{bar.hue}, 70%, 50%)"
	)

	@drawLine start.top, end.top
	@drawLine start.mid, end.mid
	@drawLine start.low, end.low

	return


computeTopLeftCorner = (a, b) ->
	topA = (a.line.parallel a.width.top).double()
	midA = (a.line.parallel a.width.mid).double()
	lowA = (a.line.parallel -a.width.low).double()

	topB = (b.line.parallel b.width.top).double()
	midB = (b.line.parallel b.width.mid).double()
	lowB = (b.line.parallel -b.width.low).double()

	{
		top: topA.intersect topB
		mid: midA.intersect midB
		low: lowA.intersect lowB
		topAlowB: topA.intersect lowB
		lowAtopB: lowA.intersect topB
		midAlowB: midA.intersect lowB
		lowAmidB: lowA.intersect midB
	}


computeTopRightCorner = (a, b) ->
	topA = (a.line.parallel a.width.top).double()
	midA = (a.line.parallel a.width.mid).double()
	lowA = (a.line.parallel -a.width.low).double()

	topB = (b.line.parallel b.width.top).double()
	midB = (b.line.parallel b.width.mid).double()
	lowB = (b.line.parallel -b.width.low).double()

	top = topA.intersect topB
	mid = midA.intersect midB

	midAlowB = midA.intersect lowB

	{
		top
		midAtopB: midA.intersect topB
		lowAtopB: lowA.intersect topB
		midAlowB
		topAbackB: midAlowB.sub mid.sub top
		lowAmidB: lowA.intersect midB
		low: lowA.intersect lowB
	}


computeLowRightCorner = (a, b) ->
	topA = (a.line.parallel a.width.top).double()
	midA = (a.line.parallel a.width.mid).double()
	lowA = (a.line.parallel -a.width.low).double()

	topB = (b.line.parallel b.width.top).double()
	midB = (b.line.parallel b.width.mid).double()
	lowB = (b.line.parallel -b.width.low).double()

	{
		top: topA.intersect topB
		mid: midA.intersect midB
		low: lowA.intersect lowB
		topAmidB: topA.intersect midB
		topAlowB: topA.intersect lowB
		midAtopB: midA.intersect topB
		lowAtopB: lowA.intersect topB
	}


computeLowLeftCorner = (a, b) ->
	topA = (a.line.parallel a.width.top).double()
	midA = (a.line.parallel a.width.mid).double()
	lowA = (a.line.parallel -a.width.low).double()

	topB = (b.line.parallel b.width.top).double()
	midB = (b.line.parallel b.width.mid).double()
	lowB = (b.line.parallel -b.width.low).double()

	top = topA.intersect topB
	mid = midA.intersect midB

	lowAmidB = lowA.intersect midB

	{
		top
		topAmidB: topA.intersect midB
		topAlowB: topA.intersect lowB
		midAlowB: midA.intersect lowB
		lowAmidB
		low: lowA.intersect lowB
		backAtopB: lowAmidB.sub mid.sub top
	}


drawTopLeftCorner = (args..., hue) ->
	c = computeTopLeftCorner args...

	@drawPolygon(
		[c.top, c.topAlowB, c.midAlowB, c.mid, c.lowAmidB, c.lowAtopB],
		"hsl(#{hue}, 70%, 30%)"
	)

	@drawPolygon(
		[c.mid, c.midAlowB, c.low, c.lowAmidB],
		"hsl(#{hue}, 70%, 50%)"
	)

	@drawLine c.top, c.topAlowB
	@drawLine c.mid, c.midAlowB
	@drawLine c.top, c.lowAtopB
	@drawLine c.mid, c.lowAmidB
	@drawLine c.top, c.mid

	return


drawTopRightCorner = (args..., hue) ->
	c = computeTopRightCorner args...

	@drawPolygon(
		[c.top, c.topAbackB, c.midAlowB, c.midAtopB],
		"hsl(#{hue}, 70%, 30%)"
	)

	@drawPolygon(
		[c.midAtopB, c.midAlowB, c.low, c.lowAtopB],
		"hsl(#{hue}, 70%, 50%)"
	)

	@drawLine c.top, c.topAbackB
	@drawLine c.midAtopB, c.midAlowB
	@drawLine c.lowAtopB, c.lowAmidB
	@drawLine c.midAlowB, c.low
	@drawLine c.topAbackB, c.midAlowB

	return


drawLowRightCorner = (args..., hue) ->
	c = computeLowRightCorner args...

	@drawPolygon(
		[c.top, c.topAmidB, c.mid, c.midAtopB],
		"hsl(#{hue}, 70%, 30%)"
	)

	@drawPolygon(
		[c.topAmidB, c.topAlowB, c.low, c.lowAtopB, c.midAtopB, c.mid],
		"hsl(#{hue}, 70%, 50%)"
	)

	@drawLine c.midAtopB, c.mid
	@drawLine c.lowAtopB, c.low
	@drawLine c.topAmidB, c.mid
	@drawLine c.topAlowB, c.low
	@drawLine c.top, c.mid

	return


drawLowLeftCorner = (args..., hue) ->
	c = computeLowLeftCorner args...

	@drawPolygon(
		[c.top, c.topAmidB, c.lowAmidB, c.backAtopB],
		"hsl(#{hue}, 70%, 30%)"
	)

	@drawPolygon(
		[c.topAmidB, c.topAlowB, c.low, c.lowAmidB],
		"hsl(#{hue}, 70%, 50%)"
	)

	@drawLine c.lowAmidB, c.low
	@drawLine c.top, c.backAtopB
	@drawLine c.topAmidB, c.lowAmidB
	@drawLine c.topAlowB, c.midAlowB
	@drawLine c.backAtopB, c.lowAmidB

	return


drawTorusCorners = (o, a, b, hue) ->
	lineTop = (Line.make o, (o.add a)).shorten()
	lineLow = (Line.make (o.add b), (o.add a.add b)).shorten()
	lineLeft = (Line.make o, (o.add b)).shorten()
	lineRight = (Line.make (o.add a), (o.add a.add b)).shorten()

	top = Bar.make(
		lineTop
		{ start: lineLeft.angle, end: lineRight.angle }
		{ top: 15, mid: 5, low: 15 }
	)

	low = Bar.make(
		lineLow
		{ start: lineLeft.angle, end: lineRight.angle }
		{ top: 15, mid: 5, low: 15 }
	)

	left = Bar.make(
		lineLeft
		{ start: lineTop.angle, end: lineLow.angle }
		{ top: 15, mid: 5, low: 15 }
	)

	right = Bar.make(
		lineRight
		{ start: lineTop.angle, end: lineLow.angle }
		{ top: 15, mid: 5, low: 15 }
	)

	@drawTopLeftCorner top, left, hue
	@drawTopRightCorner top, right, hue
	@drawLowRightCorner low, right, hue
	@drawLowLeftCorner low, left, hue

	return


proto = {
	drawLine
	drawPolygon
	drawBar
	drawTopLeftCorner
	drawTopRightCorner
	drawLowRightCorner
	drawLowLeftCorner
	drawTorusCorners
}


make = (canvas) ->
	context = canvas.getContext '2d'

	instance = Object.create proto
	Object.assign instance, { canvas, context }
	Object.freeze instance
	instance


window.Draw ?= {}
Object.assign window.Draw, { make }