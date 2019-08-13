Class {
	#name : #WodenEsug2019Demo,
	#superclass : #Object,
	#category : #WodenEsug2019Demo
}

{ #category : #'as yet unclassified' }
WodenEsug2019Demo class >> addAltoToSector: sector at: altoPosition [
	| altoModelName |
	altoModelName := 'models/computers/alto.glb'.

	sector
			addRigidBodyAt: altoPosition + (WMVector3F x: 0 y: 0.5 z: 0.0) with: [ :rigidBody |
				rigidBody addModelLibraryNamed: altoModelName nodeNamed: 'AltoCpu' with: [ :comp |
					comp ensureValidCollisionShape
				]
			];

			addRigidBodyAt: altoPosition + (WMVector3F x: 0 y: 0.8 z: -0.2) with: [ :rigidBody |
				rigidBody addModelLibraryNamed: altoModelName nodeNamed: 'AltoMonitor' with: [ :comp |
					comp ensureValidCollisionShape
				]
			];

			addRigidBodyAt: altoPosition + (WMVector3F x: -0.1 y: 0.8 z: 0.2) with: [ :rigidBody |
				rigidBody addModelLibraryNamed: altoModelName nodeNamed: 'AltoKeyboard' with: [ :comp |
					comp ensureValidCollisionShape
				]
			];

			addRigidBodyAt: altoPosition + (WMVector3F x: 0.3 y: 0.8 z: 0.2) with: [ :rigidBody |
				rigidBody addModelLibraryNamed: altoModelName nodeNamed: 'AltoMouse' with: [ :comp |
					comp ensureValidCollisionShape
				]
			]
]

{ #category : #'as yet unclassified' }
WodenEsug2019Demo class >> addLighthouseToSector: sector at: lighthousePosition [
	sector addGenericObjectAt: lighthousePosition with: [ :wodanic |
		wodanic addModelLibraryNamed: 'lighthouse.glb' nodeNamed: 'Lighthouse' with: [ :comp |
			comp
				createCollisionShapeWithAllMeshes
		].
	].

]

{ #category : #'as yet unclassified' }
WodenEsug2019Demo class >> addWodanicToSector: sector at: wodanicPosition [
	sector addGenericObjectAt: wodanicPosition with: [ :wodanic |
		wodanic addModelLibraryNamed: 'wodanic.glb' nodeNamed: 'Wodanic' with: [ :comp |
			comp
				createCollisionShapeWithConvexCollisionTreeNamed: 'WodanicCollisions'
		].
	].

	self addAltoToSector: sector at: wodanicPosition + (WMVector3F x: 1.5 y: 3.0 z: 0.0).

]

{ #category : #'as yet unclassified' }
WodenEsug2019Demo class >> exampleEsugDemo [
	| engine universe terrainMaterial waterMaterial terrainData |
	engine := WDCEngine default.
	terrainMaterial := engine resourceCache loadMaterial: 'materials/demos/island.json'.
	terrainData := engine resourceCache loadTerrain: 'terrains/sectors/lake-walled.stterrain'.
	
	universe := WDESSimpleUniverse for: engine.
	universe
		defaultCameraFarDistance: 10000.0;
		defaultCameraCascadeSplitDistributionLambda: 1.0.
	universe buildSector: [ :sector |
		sector buildTerrainMeshWithData: terrainData withMaterial: terrainMaterial.
	
		sector addWaterVolumeAt: WMVector3F zero with: [ :waterVolume |
			(waterVolume buildWaterMeshWith: [ :meshBuilder |
				waterMaterial := engine resourceCache loadMaterial: 'materials/demos/ocean.json'.
				meshBuilder
					material: waterMaterial;
					heightScale: 0.1.
				terrainData buildWaterMeshWith: meshBuilder.
				meshBuilder
					addCollisionBoxWithMinHeight: -1000.0 maxHeight: 0.0 
			]) renderable deformationState
				harmonicAt: 1 amplitude: 0.015 frequency: 2.23 center: (WMVector2F zero);
				harmonicAt: 2 amplitude: 0.03 frequency: 0.50 center: (WMVector2F zero).
		].

		sector
			addDirectionalLightWith: [ :light |
				| skyTexture |
				light
					castShadows: true;
					intensity: (WMVector4F x: 1.0 y: 1.0 z: 0.8) normalized * 0.7;
					rotateDegreesOnX: -45;
					rotateDegreesOnY: -100;
					translateToX: 0.0 y: 1.5 z: 2.5.
					
				skyTexture := WDASceneExamples proceduralSkySunDirection: light forwardDirection.
				skyTexture := skyTexture asSRGBTextureFor: engine.
				sector addSkyBoxWithTexture: skyTexture
			].
		
		self
			addWodanicToSector: sector at: (WMVector3F z: 4000.0);
			addLighthouseToSector: sector at: (WMVector3F x: -1120.0 y: 110.2 z: 820.0).

		"Lighthouse start point"
		"sector
			addPlayerStartPointAt: (WMVector3F x: -1121.0 y: 112.0 z: 830.0)."

		"Wodanic entry point"
		sector
			addPlayerStartPointAt: (WMVector3F x: 0.0 y: 4.0 z: 4003.0).
	].

	universe createSimulationModel
		open
		spawnPlayer.
		
]

{ #category : #'see class side' }
WodenEsug2019Demo >> seeClassSide [
]
