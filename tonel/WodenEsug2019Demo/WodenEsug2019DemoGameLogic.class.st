Class {
	#name : #WodenEsug2019DemoGameLogic,
	#superclass : #WDAESGameLogic,
	#category : #WodenEsug2019Demo
}

{ #category : #'as yet unclassified' }
WodenEsug2019DemoGameLogic >> spawnPlayer [
	self addGlobalOverlay: (WodenEsug2019DemoTitleScreen new engine: self engine).
	^ super spawnPlayer
]
