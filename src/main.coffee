'use strict'


space = Space.make()

slopeA = (Vec.make 250, -50).normalize()
slopeB = (Vec.make -1, 300).normalize()

space.addTorus (Vec.make 100, 100), (slopeA.scale 200), (slopeB.scale 300), 10
space.addTorus (Vec.make 150, 150), (slopeA.scale 200), (slopeB.scale 300), 260
space.addTorus (Vec.make 50, 250), (slopeA.scale 400), (slopeB.scale 100), 70

elements = space.compile Vectorizer

canvas = document.getElementById 'can'
context = canvas.getContext '2d'

Rasterizer.rasterize context, {}, elements