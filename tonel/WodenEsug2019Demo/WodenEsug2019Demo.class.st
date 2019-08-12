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
WodenEsug2019Demo class >> exampleTest01PoolAlto [
	| engine universe waterMaterial |
	engine := WDCEngine default.

	universe := WDESSimpleUniverse for: engine.
	universe defaultCameraFarDistance: 100.0.
	universe buildSector: [ :sector |
		sector buildGenericMeshWith: [ :meshBuilder |
			WDASceneExamples constructPoolMeshWith: meshBuilder.
		].

		sector
			addDirectionalLightWith: [ :light |
				| skyTexture |
				light
					castShadows: true;
					intensity: (WMVector4F x: 1.0 y: 1.0 z: 0.8) normalized * 0.7;
					rotateDegreesOnX: -35;
					rotateDegreesOnY: -180;
					translateToX: 0.0 y: 1.5 z: 2.5.
					
				skyTexture := WDASceneExamples proceduralSkySunDirection: light forwardDirection.
				skyTexture := skyTexture asSRGBTextureFor: engine.
				sector addSkyBoxWithTexture: skyTexture
			];
			addWaterVolumeAt: (WMVector3F y: -0.3) with: [ :waterVolume |
				(waterVolume buildWaterMeshWith: [ :meshBuilder |
				
					waterMaterial := engine resourceCache loadMaterial: 'materials/demos/water.json'.
					meshBuilder
						material: waterMaterial;
						heightScale: 0.1;
						createGridWithSize: (WMVector2F x: 5.0 y: 5.0) subdivisions: 64;
						addBoxCollisionShape: (WMBox3DF
							halfExtent: (WMVector3F x: 2.5 y: 1.0 z: 2.5)
							center: (WMVector3F y: -1.0))
				]) renderable deformationState
					harmonicAt: 1 amplitude: 0.05 frequency: -1.1 center: WMVector2F new;
					harmonicAt: 2 amplitude: 0.02 frequency: 2.23 direction: (WMVector2F y: -1.0);
					harmonicAt: 3 amplitude: 0.015 frequency: 1.80 direction: (WMVector2F x: 1.0).
			].
		
		self addAltoToSector: sector at: (WMVector3F x: -4.5 y: 0.0 z: 0.0).
		

		sector		
			addPlayerStartPointAt: (WMVector3F x: -2.0 y: 2.0 z: 4.0)
	].

	universe createSimulationModel
		open
		spawnPlayer.

]

{ #category : #'as yet unclassified' }
WodenEsug2019Demo class >> exampleTest02Island [
	| engine universe terrainMaterial waterMaterial terrainData altoModelName |
	engine := WDCEngine default.
	terrainMaterial := engine resourceCache loadMaterial: 'materials/demos/island.json'.
	terrainData := engine resourceCache loadTerrain: 'terrains/demos/procedural/island.stterrain'.
	altoModelName := 'models/computers/alto.glb'.
	
	universe := WDESSimpleUniverse for: engine.
	universe defaultCameraFarDistance: 250.0.
	universe buildSector: [ :sector |
		sector buildTerrainMeshWithData: terrainData withMaterial: terrainMaterial.

		sector addGenericObjectAt: (WMVector3F x: -20.0 y: 0.0 z: 90.0) with: [ :lighthouse |
			lighthouse addModelLibraryNamed: 'lighthouse.glb' nodeNamed: 'Lighthouse' with: [ :comp |
				comp
					createCollisionShapeWithAllMeshes
			].
		].
		
		sector addGenericObjectAt: (WMVector3F x: 0.0 y: 0.0 z: 180.0) with: [ :lighthouse |
			lighthouse addModelLibraryNamed: 'wodanic.glb' nodeNamed: 'Wodanic' with: [ :comp |
				comp
					createCollisionShapeWithAllMeshes
			].
		].
	
		sector addWaterVolumeAt: WMVector3F zero with: [ :waterVolume |
			(waterVolume buildWaterMeshWith: [ :meshBuilder |
				waterMaterial := engine resourceCache loadMaterial: 'materials/demos/ocean.json'.
				meshBuilder
					material: waterMaterial;
					heightScale: 0.1;
					createClipMapWithLevels: 3 size: (WMVector2F x: 40.0 y: 40.0) subdivisions: 128;
					terrainExtent: 1024@1024;
					addBoxCollisionShape: (WMBox3DF
						halfExtent: (WMVector3F x: 200.0 y: 200.0 z: 200.0)
						center: (WMVector3F y: -200.0))
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
		
		self addAltoToSector: sector at: (WMVector3F x: 1.5 y: 3.0 z: 180.0).
		sector
			addPlayerStartPointAt: (WMVector3F x: 0.0 y: 4.0 z: 183.0)
	].

	universe createSimulationModel
		open
		spawnPlayer.
		
]

{ #category : #'see class side' }
WodenEsug2019Demo >> seeClassSide [
]
