Class {
	#name : #WodenEsug2019DemoTitleScreen,
	#superclass : #WDESOverlayScreen,
	#instVars : [
		'sequenceTime',
		'backgroundColor',
		'foregroundColor'
	],
	#category : #WodenEsug2019Demo
}

{ #category : #rendering }
WodenEsug2019DemoTitleScreen >> drawOnBabylonCanvas: canvas [
	| builder mesh |
	builder := canvas driver mesh2DBuilder.
	
	builder fill
		color: backgroundColor;
		rectangle: (0@0 extent: canvas surface extent).

	builder transform
		translateBy: canvas surface extent / 2;
		scaleBy: canvas surface extent y / 240.

	builder transform restoreAfter: [
		builder transform scaleBy: 1.5.
		builder
			text
			color: foregroundColor;
			font: self babylonDefaultFont;

			position: -80 @ -50;
			draw: 'Voyage in the WODANIC ALPHA'.
	].
		
	builder text
		font: self babylonDefaultFont;
		color: foregroundColor;
		position: -20 @ -30;
		draw: 'Episode 0.01';
		position: -100 @ 10;
		draw: 'The mystery of the lighthouse in'; newline; draw: 'the volcanic island of Lake Wallen.'.

	mesh := builder mesh.
	canvas draw: mesh.
]

{ #category : #rendering }
WodenEsug2019DemoTitleScreen >> initialize [
	super initialize.
	sequenceTime := 0.0.
	backgroundColor := Color black.
	foregroundColor := Color black.
]

{ #category : #testing }
WodenEsug2019DemoTitleScreen >> isAlive [
	^ sequenceTime < 10.0.
	"^ sequenceTime < 0.0."
]

{ #category : #testing }
WodenEsug2019DemoTitleScreen >> tick: delta [
	| fadeOut |
	sequenceTime := sequenceTime + delta.

	fadeOut := 1.0 - (sequenceTime smoothStepFrom: 5.5 to: 10.0).
	backgroundColor := WMVector4F w: fadeOut.
	foregroundColor := WMVector4F x: 1.0 y: 1.0 z: 1.0 w: (sequenceTime smoothStepFrom: 0.0 to: 5.0 )*fadeOut.
		
	backgroundColor := backgroundColor asColor.
	foregroundColor := foregroundColor asColor.
	
]
