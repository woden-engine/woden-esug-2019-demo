Class {
	#name : #WodanicDashboardView,
	#superclass : #WDAViewWithBabylon,
	#category : #WodenEsug2019Demo
}

{ #category : #rendering }
WodanicDashboardView >> drawHorizontalBarWithValue: value at: position with: builder [
	| extent rectangle |
	extent := (value abs * 0.7 min: 0.7) @ 0.1.
	
	(value closeTo: 0.0) ifTrue: [ 
		builder fill
			color: Color blue;
			rectangle: (position - (0.01@0.05) extent: 0.02@0.1).
		^ self
	].
	
	value < 0 ifTrue: [
		rectangle := (position - (extent x@0) extent: extent).
		builder fill
			horizontalGradientBounds: rectangle start: Color red end: Color green;
			rectangle: rectangle.
	] ifFalse: [ 
		rectangle := (position extent: extent).
		builder fill
			horizontalGradientBounds: rectangle start: Color green end: Color red;
			rectangle: rectangle.
	].


]

{ #category : #rendering }
WodanicDashboardView >> drawOnBabylonCanvas: canvas [
	| builder state |
	canvas clear: Color black.
	builder := canvas driver mesh2DBuilder.

	builder transform restoreAfter: [
		builder transform
			scaleBy: 512.0 @ -512;
			translateBy: 1.0 @ -1.0.
			
		state := model vehicleKinematicBehavior.
		self
			drawHorizontalBarWithValue: state helmAngleFactor at: 0@0.8 with: builder;
			drawVerticalBarWithValue: state linearVelocity length / state terminalSpeed at: -0.5@0 with: builder;
			drawVerticalBarWithValue: state engineAcceleration / state maxAcceleration at: 0.5@0 with: builder
	].

	canvas draw: builder mesh.
]

{ #category : #rendering }
WodanicDashboardView >> drawVerticalBarWithValue: value at: position with: builder [
	| extent rectangle |
	extent := 0.1 @ (value abs * 0.7 min: 0.7).
	
	(value closeTo: 0.0) ifTrue: [ 
		builder fill
			color: Color blue;
			rectangle: (position - (0.05@0.01) extent: 0.1@0.02).
		^ self
	].
	
	value < 0 ifTrue: [
		rectangle := (position - (0 @ extent y) extent: extent).
		builder fill
			verticalGradientBounds: rectangle start: Color red end: Color green;
			rectangle: rectangle.
	] ifFalse: [
		rectangle := (position extent: extent).
		builder fill
			verticalGradientBounds: rectangle start: Color green end: Color red;
			rectangle: rectangle.
	].


]
