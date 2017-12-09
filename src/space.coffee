'use strict'


split = (a, b, intersection) ->
	directionA = (a.line.end.sub a.line.start).normalize()

	halfWidth = (b.width.top + b.width.low + 1) / 2

	startLine = Line.make a.line.start, intersection.sub (directionA.scale halfWidth)
	endLine = Line.make (intersection.add directionA.scale halfWidth), a.line.end

	startBar = Bar.make(
		startLine
		{ start: a.capAngles.start, end: b.angle }
		a.width
		a.hue
	)

	endBar = Bar.make(
		endLine
		{ start: b.angle, end: a.capAngles.end }
		a.width
		a.hue
	)

	[startBar, endBar]


splitRandom = (a, b, intersection) ->
	if Math.random() < 0.5
		{
			index: a.index
			halves: split a.bar, b.bar, intersection
		}
	else
		{
			index: b.index
			halves: split b.bar, a.bar, intersection
		}


findPair = (bars) ->
	for i in [0...bars.length]
		bar = bars[i]

		continue if bar.free

		for j in [i + 1...bars.length]
			candidate = bars[j]

			maybeIntersection = bar.line.intersect candidate.line
			if maybeIntersection
				return {
					a: { index: i, bar }
					b: { index: j, bar: candidate }
					intersection: maybeIntersection
				}

		bar.free = true

	return null


splitAll = (startBars) ->
	bars = [startBars...]

	pair = findPair bars
	while pair?
		{ index, halves } = splitRandom pair.a, pair.b, pair.intersection
		bars[index] = halves[0]
		bars.push halves[1]
		pair = findPair bars

	bars


addTorus = (o, a, b, hue) ->
	@tori.push { o, a, b, hue }

	lineTop = (Line.make o, (o.add a)).shorten()
	lineLow = (Line.make (o.add b), (o.add a.add b)).shorten()
	lineLeft = (Line.make o, (o.add b)).shorten()
	lineRight = (Line.make (o.add a), (o.add a.add b)).shorten()

	top = Bar.make(
		lineTop
		{ start: lineLeft.angle, end: lineRight.angle }
		{ top: 15, mid: 5, low: 15 }
		hue
	)

	low = Bar.make(
		lineLow
		{ start: lineLeft.angle, end: lineRight.angle }
		{ top: 15, mid: 5, low: 15 }
		hue
	)

	left = Bar.make(
		lineLeft
		{ start: lineTop.angle, end: lineLow.angle }
		{ top: 15, mid: 5, low: 15 }
		hue
	)

	right = Bar.make(
		lineRight
		{ start: lineTop.angle, end: lineLow.angle }
		{ top: 15, mid: 5, low: 15 }
		hue
	)

	@bars.push top, low, left, right

	return


compile = ->
	@split = splitAll @bars

	return


draw = (context) ->
	@split.forEach (bar) ->
		context.drawBar bar
		return

	@tori.forEach ({ o, a, b, hue }) ->
		context.drawTorusCorners o, a, b, hue
		return

	return


proto = { addTorus, compile, draw }


make = ->
	instance = Object.create proto
	Object.assign instance, { tori: [], bars: [], split: [] }
	Object.seal instance
	instance


window.Space ?= {}
Object.assign window.Space, { make }