'use strict'


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


vectorizeBar = (bar) ->
	{ start, end } = computeBar bar

	[{
		points: [start.top, end.top, end.mid, start.mid]
		color: "hsl(#{bar.hue}, 70%, 30%)"
	}, {
		points: [start.mid, end.mid, end.low, start.low]
		color: "hsl(#{bar.hue}, 70%, 50%)"
	}]


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


vectorizeTopLeftCorner = (args..., hue) ->
	c = computeTopLeftCorner args...

	[{
		points: [c.top, c.topAlowB, c.midAlowB, c.mid]
		color: "hsl(#{hue}, 70%, 30%)"
	}, {
		points: [c.top, c.mid, c.lowAmidB, c.lowAtopB]
		color: "hsl(#{hue}, 70%, 30%)" # 20%
	}, {
		points: [c.mid, c.midAlowB, c.low, c.lowAmidB]
		color: "hsl(#{hue}, 70%, 50%)"
	}]


vectorizeTopRightCorner = (args..., hue) ->
	c = computeTopRightCorner args...

	[{
		points: [c.top, c.topAbackB, c.midAlowB, c.midAtopB]
		color: "hsl(#{hue}, 70%, 30%)"
	}, {
		points: [c.midAtopB, c.midAlowB, c.low, c.lowAtopB]
		color: "hsl(#{hue}, 70%, 50%)"
	}]


vectorizeLowRightCorner = (args..., hue) ->
	c = computeLowRightCorner args...

	[{
		points: [c.top, c.topAmidB, c.mid]
		color: "hsl(#{hue}, 70%, 30%)" # 20%
	}, {
		points: [c.top, c.mid, c.midAtopB]
		color: "hsl(#{hue}, 70%, 30%)"
	}, {
		points: [c.topAmidB, c.topAlowB, c.low, c.lowAtopB, c.midAtopB, c.mid]
		color: "hsl(#{hue}, 70%, 50%)"
	}]


vectorizeLowLeftCorner = (args..., hue) ->
	c = computeLowLeftCorner args...

	[{
		points: [c.top, c.topAmidB, c.lowAmidB, c.backAtopB]
		color: "hsl(#{hue}, 70%, 30%)"
	}, {
		points: [c.topAmidB, c.topAlowB, c.low, c.lowAmidB]
		color: "hsl(#{hue}, 70%, 50%)"
	}]


vectorizeTorusCorners = (o, a, b, hue) ->
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

	[
		(vectorizeTopLeftCorner top, left, hue)...
		(vectorizeTopRightCorner top, right, hue)...
		(vectorizeLowRightCorner low, right, hue)...
		(vectorizeLowLeftCorner low, left, hue)...
	]


window.Vectorizer ?= {}
Object.assign(
	window.Vectorizer
	{
		vectorizeBar
		vectorizeTorusCorners
	}
)