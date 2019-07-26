Class {
	#name : #WDEDShortSamples,
	#superclass : #Object,
	#category : #WodenEsug2019Demo
}

{ #category : #'as yet unclassified' }
WDEDShortSamples class >> example01PoolAlto [
	| engine universe waterMaterial altoModelName |
	engine := WDCEngine default.
	altoModelName := 'models/computers/alto.glb'.

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
			];
		
			addRigidBodyAt: (WMVector3F x: -4.5 y: 0.5 z: 0.0) with: [ :rigidBody |
				rigidBody addModelLibraryNamed: altoModelName nodeNamed: 'AltoCpu' with: [ :comp |
					comp ensureValidCollisionShape
				]
			];

			addRigidBodyAt: (WMVector3F x: -4.5 y: 0.8 z: -0.2) with: [ :rigidBody |
				rigidBody addModelLibraryNamed: altoModelName nodeNamed: 'AltoMonitor' with: [ :comp |
					comp ensureValidCollisionShape
				]
			];

			addRigidBodyAt: (WMVector3F x: -4.6 y: 0.8 z: 0.2) with: [ :rigidBody |
				rigidBody addModelLibraryNamed: altoModelName nodeNamed: 'AltoKeyboard' with: [ :comp |
					comp ensureValidCollisionShape
				]
			];

			addRigidBodyAt: (WMVector3F x: -4.3 y: 0.8 z: 0.2) with: [ :rigidBody |
				rigidBody addModelLibraryNamed: altoModelName nodeNamed: 'AltoMouse' with: [ :comp |
					comp ensureValidCollisionShape
				]
			];
		
			addPlayerStartPointAt: (WMVector3F x: -2.0 y: 2.0 z: 4.0)
	].

	universe createSimulationModel
		open
		spawnPlayer.

]
