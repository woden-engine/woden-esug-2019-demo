Class {
	#name : #WodanicDrivingCharacterController,
	#superclass : #WDESCharacterDrivingVehicleDisplacementStrategy,
	#instVars : [
		'localDriverPosition'
	],
	#category : #WodenEsug2019Demo
}

{ #category : #accessing }
WodanicDrivingCharacterController >> localDriverPosition [
	^ localDriverPosition
]

{ #category : #accessing }
WodanicDrivingCharacterController >> localDriverPosition: anObject [
	localDriverPosition := anObject
]

{ #category : #simulation }
WodanicDrivingCharacterController >> prePhysicsTick: delta [
]

{ #category : #hooks }
WodanicDrivingCharacterController >> vehicleDriverPosition [
	^ vehicle sectorTransform transformPosition3: localDriverPosition
]
