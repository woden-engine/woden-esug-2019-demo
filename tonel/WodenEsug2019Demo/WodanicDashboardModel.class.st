Class {
	#name : #WodanicDashboardModel,
	#superclass : #WDAModel,
	#instVars : [
		'vehicle',
		'vehicleKinematicBehavior'
	],
	#category : #WodenEsug2019Demo
}

{ #category : #'as yet unclassified' }
WodanicDashboardModel >> defaultViewClass [
	^ WodanicDashboardView
]

{ #category : #testing }
WodanicDashboardModel >> needsToRender [
	^ super needsToRender and: [ vehicleKinematicBehavior isMoving ].
]

{ #category : #accessing }
WodanicDashboardModel >> vehicle [
	^ vehicle
]

{ #category : #accessing }
WodanicDashboardModel >> vehicle: anObject [
	vehicle := anObject
]

{ #category : #accessing }
WodanicDashboardModel >> vehicleKinematicBehavior [
	^ vehicleKinematicBehavior
]

{ #category : #accessing }
WodanicDashboardModel >> vehicleKinematicBehavior: anObject [
	vehicleKinematicBehavior := anObject
]
