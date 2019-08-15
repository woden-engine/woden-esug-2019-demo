Class {
	#name : #WodanicDrivingCharacterController,
	#superclass : #WDESCharacterDrivingVehicleDisplacementStrategy,
	#instVars : [
		'localDriverPosition'
	],
	#category : #WodenEsug2019Demo
}

{ #category : #simulation }
WodanicDrivingCharacterController >> activateUseCommand [
	super activateUseCommand.

	vehicleKinematicBehavior
		engineDirection: 0.0;
		turnDirection: 0.0.
]

{ #category : #'as yet unclassified' }
WodanicDrivingCharacterController >> applyVehicleAngleDelta: angleDelta [
	character headAngle: character headAngle + (WMVector3F y: angleDelta)
]

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
	super prePhysicsTick: delta.
	vehicleKinematicBehavior
		engineDirection: character leftStickDirection y;
		turnDirection: character leftStickDirection x
]

{ #category : #hooks }
WodanicDrivingCharacterController >> vehicleDriverPosition [
	^ vehicle sectorTransform transformPosition3: localDriverPosition
]
