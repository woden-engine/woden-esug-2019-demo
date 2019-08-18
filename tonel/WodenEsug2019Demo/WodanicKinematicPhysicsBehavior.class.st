Class {
	#name : #WodanicKinematicPhysicsBehavior,
	#superclass : #WDESKinematicPhysicsBehavior,
	#instVars : [
		'linearVelocity',
		'linearAcceleration',
		'linearDamping',
		'terminalSpeed',
		'engineDirection',
		'turnDirection',
		'engineAcceleration',
		'timeToReachMaxAcceleration',
		'helmAngle',
		'maxHelmAngle',
		'timeToReachMaxHelmAngle',
		'helmWheelSceneNode',
		'maxHelmWheelAngle',
		'helmAngleFactor',
		'helmWheelAngle',
		'engineAccelerationTargetTau',
		'helmAngleTargetTau',
		'angularVelocity',
		'currentDriver',
		'engineSoundSource',
		'boilerSoundSources'
	],
	#category : #WodenEsug2019Demo
}

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> boilerSoundSources [
	^ boilerSoundSources
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> boilerSoundSources: anObject [
	boilerSoundSources := anObject
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> currentDriver [
	^ currentDriver
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> currentDriver: aDriver [
	currentDriver := aDriver
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> engineAcceleration [
	^ engineAcceleration
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> engineDirection [
	^ engineDirection
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> engineDirection: anObject [
	engineDirection := anObject
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> engineSoundSource [
	^ engineSoundSource
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> engineSoundSource: anObject [
	engineSoundSource := anObject
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> helmAngleFactor [
	^ helmAngleFactor
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> helmWheelSceneNode [
	^ helmWheelSceneNode
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> helmWheelSceneNode: anObject [
	helmWheelSceneNode := anObject
]

{ #category : #simulation }
WodanicKinematicPhysicsBehavior >> initialize [
	super initialize.
	linearVelocity := WMVector3F zero.
	linearAcceleration := WMVector3F zero.
	engineAcceleration := 0.0.
	engineDirection := 0.0.
	turnDirection := 0.0.
	linearDamping := 0.8.
	terminalSpeed := 40.0.
	engineAccelerationTargetTau := 2.0.
	helmAngleTargetTau := 2.0.

	maxHelmAngle := 90 degreesToRadians.
	maxHelmWheelAngle := 270 degreesToRadians.

	helmAngleFactor := 0.0.
	helmAngle := 0.0.
	helmWheelAngle := 0.0.

	angularVelocity := 0.0.
	boilerSoundSources := #().
]

{ #category : #simulation }
WodanicKinematicPhysicsBehavior >> isMoving [
	(linearVelocity closeTo: WMVector3F zero) ifFalse: [ ^ true ].
	(linearAcceleration closeTo: WMVector3F zero) ifFalse: [ ^ true ].
	(engineAcceleration closeTo: 0.0) ifFalse: [ ^ true ].
	(helmAngleFactor closeTo: 0.0) ifFalse: [ ^ true ].
	^  false
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> linearAcceleration [
	^ linearAcceleration
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> linearAcceleration: anObject [
	linearAcceleration := anObject
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> linearDamping [
	^ linearDamping
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> linearDamping: anObject [
	linearDamping := anObject
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> linearVelocity [
	^ linearVelocity
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> linearVelocity: anObject [
	linearVelocity := anObject
]

{ #category : #simulation }
WodanicKinematicPhysicsBehavior >> maxAcceleration [
	^ terminalSpeed / linearDamping
]

{ #category : #simulation }
WodanicKinematicPhysicsBehavior >> prePhysicsTick: delta [
	| maxAccel helmRotation oldTransform engineAccelerationFactor |

	"Reach the engine target acceleration with an exponential curve"
	maxAccel := self maxAcceleration.
	engineAcceleration := engineAcceleration interpolateTo: maxAccel*engineDirection at: 1.0 - ((delta negated * engineAccelerationTargetTau) exp).
	engineAccelerationFactor := engineAcceleration abs / maxAccel.

	"Reach the helm target angle with an exponential curve"
	helmAngleFactor := helmAngleFactor interpolateTo: turnDirection at: 1.0 - ((delta negated * helmAngleTargetTau) exp).

	helmAngle := maxHelmAngle * helmAngleFactor.
	helmWheelAngle := maxHelmWheelAngle * helmAngleFactor.

	helmWheelSceneNode ifNotNil: [
		helmWheelSceneNode transform: (WMReversibleAffineTransformF identity
			orthonormal: (WMMatrix3F zrot: helmWheelAngle negated) translation: helmWheelSceneNode position)
	].

	engineSoundSource ifNotNil: [
		engineSoundSource
			pitch: engineAccelerationFactor;
			gain: engineAccelerationFactor*2.0.
		boilerSoundSources do: [ :source |
			source
				pitch: (1.0 interpolateTo: 1.5 at: engineAccelerationFactor);
				gain: (0.8 interpolateTo: 2.0 at: engineAccelerationFactor)
		]
	].
	
	self isMoving ifFalse: [ ^ self ].
	
	helmRotation := WMMatrix3F yrot: helmAngle negated.
	
	angularVelocity := helmAngle negated * (engineAcceleration / maxAccel) * 0.2.
	
	oldTransform := self ownerEntity transform.

	linearAcceleration := (oldTransform transformVector3: (helmRotation transformVector3: (WMVector3F z: engineAcceleration negated)))
		- (linearVelocity*linearDamping).
	linearVelocity := linearVelocity + (linearAcceleration*delta).
	currentDriver ifNotNil: [ 
		currentDriver applyVehicleAngleDelta: angularVelocity *delta
	].

	self ownerEntity
		transform: (WMReversibleAffineTransformF identity
			orthonormal: (WMMatrix3F yrot: angularVelocity *delta) * oldTransform matrix translation: oldTransform translation + (linearVelocity * delta))
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> terminalSpeed [
	^ terminalSpeed
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> terminalSpeed: anObject [
	terminalSpeed := anObject
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> turnDirection [
	^ turnDirection
]

{ #category : #accessing }
WodanicKinematicPhysicsBehavior >> turnDirection: anObject [
	turnDirection := anObject
]
