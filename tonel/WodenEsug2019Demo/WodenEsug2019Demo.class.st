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
		wodanic addModelLibraryNamed: 'models/buildings/lighthouse.glb' nodeNamed: 'Lighthouse' with: [ :comp |
			comp
				createCollisionShapeWithAllMeshes
		].
	].

]

{ #category : #'as yet unclassified' }
WodenEsug2019Demo class >> addWodanicToSector: sector at: wodanicPosition [
	| altoModelName dashboardModel |
	
	altoModelName := 'models/computers/alto.glb'.
	dashboardModel := nil.
	sector addGenericObjectAt: wodanicPosition with: [ :wodanic |
		| frontChimneyPosition backChimneyPosition helmWheelBoundingBox wodanicModel driverPosition kinematicBehavior |
		wodanic makeKinematicPhysicsObject.
		
		kinematicBehavior := wodanic addComponent: WodanicKinematicPhysicsBehavior new.

		wodanicModel := 
			wodanic addModelLibraryNamed: 'models/vehicles/wodanic.glb' nodeNamed: 'Wodanic' with: [ :comp |
			comp
				createCollisionShapeWithConvexCollisionTreeNamed: 'WodanicCollisions'.
				
			frontChimneyPosition := comp getChildNodePosition: 'WodanicFrontChimneySmoke'.
			backChimneyPosition := comp getChildNodePosition: 'WodanicBackChimneySmoke'.
			driverPosition := comp getChildNodePosition: 'WodanicDriverLocation'.
			helmWheelBoundingBox := comp getChildNodeBoundingBox: 'WodanicHelmWheel'.
		].

		wodanic addSoundSourceComponentAt: WMVector3F zero with: [ :comp |
			comp loadSoundSample: 'sounds/noise/engine.wav';
				isGlobalSource: false;
				looped: true;
				gain: 0.0;
				pitch: 1.0;
				play.
			kinematicBehavior engineSoundSource: comp
		].

		kinematicBehavior boilerSoundSources: { 
			wodanic addSoundSourceComponentAt: (frontChimneyPosition copy y: 0.0)  with: [ :comp |
				comp loadSoundSample: 'sounds/noise/boiler.wav';
					isGlobalSource: false;
					looped: true;
					gain: 0.6;
					pitch: 1.0;
					play.
			].

			wodanic addSoundSourceComponentAt: (backChimneyPosition copy y: 0.0)  with: [ :comp |
				comp loadSoundSample: 'sounds/noise/boiler.wav';
					isGlobalSource: false;
					looped: true;
					gain: 0.8;
					pitch: 1.0;
					play.
			].
		}.
	
		wodanic addModelLibraryNamed: altoModelName nodeNamed: 'AltoCpu' with: [ :comp |
			comp position: (wodanicModel getChildNodePosition: 'WodanicAltoCpuLocation')
		].
		wodanic addModelLibraryNamed: altoModelName nodeNamed: 'AltoMonitor' with: [ :comp |
			comp localTransform: (wodanicModel getChildNodeTransform: 'WodanicAltoMonitorLocation')
		].
		wodanic addModelLibraryNamed: altoModelName nodeNamed: 'AltoKeyboard' with: [ :comp |
			comp localTransform: (wodanicModel getChildNodeTransform: 'WodanicAltoKeyboardLocation')
		].
		wodanic addModelLibraryNamed: altoModelName nodeNamed: 'AltoMouse' with: [ :comp |
			comp localTransform: (wodanicModel getChildNodeTransform: 'WodanicAltoMouseLocation')
		].
	
		(wodanic buildParticleSystemWith: [ :chimney |
			self createChimneyParticleSystem: chimney
		]) translateTo: frontChimneyPosition.

		(wodanic buildParticleSystemWith: [ :chimney |
			self createChimneyParticleSystem: chimney
		]) translateTo: backChimneyPosition.
	
		wodanic addUseActuationBoxVolume: helmWheelBoundingBox withAction: [ :sender :rayCastingTest |
			dashboardModel ifNil: [ 
				dashboardModel := WodanicDashboardModel new
					vehicle: wodanic;
					vehicleKinematicBehavior: kinematicBehavior.
				dashboardModel openOnRenderTargetTexture: (sector engine resourceCache getNamedRenderTargetTexture: '$AltoRenderTarget' ifAbsent: []) 
			].
		
			kinematicBehavior helmWheelSceneNode ifNil: [
				kinematicBehavior helmWheelSceneNode: (wodanic sceneNode findChildNodeNamed: 'WodanicHelmWheel' ifAbsent: [ nil ]).
		].
			
			sender displacementStrategy: (WodanicDrivingCharacterController new
				vehicle: wodanic;
				vehicleKinematicBehavior: kinematicBehavior;
				localDriverPosition: driverPosition;
				yourself)
		].
	].

]

{ #category : #'as yet unclassified' }
WodenEsug2019Demo class >> atmosphereIntensityForSunIntensity: sunIntensity [
	^ sunIntensity *0.1.
]

{ #category : #'as yet unclassified' }
WodenEsug2019Demo class >> createChimneyParticleSystem: particleSystem [
	| colorRamp |
	
	colorRamp := WDCLinearRamp with: {
		0.15 -> (WMVector4F x: 0.2 y: 0.2 z: 0.2 w: 0.3).
		0.8 -> (WMVector4F x: 1.2 y: 1.2 z: 1.2 w: 0.3).
	}.
	particleSystem boundingBox: (WMBox3DF halfExtent: (WMVector3F x: 4.0 y: 10.0 z: 4.0)).
	particleSystem particleCount: 64.
	
	particleSystem simulationBlock: [ :particleState :index :delta |
		| lifeTime color |
		lifeTime := particleState lifeTime  - delta.
		lifeTime <= 0.0 ifTrue:[
			lifeTime := 1.7 + (particleState nextRandom*1.5).
			particleState
				startingUp: false;
				position: particleState nextRandomVector3F * 1.0;
				velocity: (WMVector3F
					x: particleState nextRandom*0.5
					y: 5.0 + (particleState nextRandom *1.5)
					z: particleState nextRandom*0.5).
		].
	
		color := colorRamp value: lifeTime / 3.0.
		
		particleState
			size: (WMVector3F x: 3.0 y: 3.0);
			velocity: (particleState velocity + (WMVector3F y: -9.8 * delta*0.04));
			position: (particleState position + (particleState velocity *delta));
			color: color;
			lifeTime: lifeTime.
	].
	particleSystem renderingBlock: [ :particleState :particleIndex :s :t |
		| radialPosition particleAttenuation position smokeNoise color |
		radialPosition := (WMVector3F x: s y: t z: 0.0) * 2.0 - (WMVector3F x: 1.0 y: 1.0 z: 0.0).
		particleAttenuation := 1.0 - (radialPosition length smoothStepFrom: 0.3 to: 1.0).
		particleAttenuation := particleAttenuation * (particleState lifeTime smoothStepFrom: 0.0 to: 0.3).
		particleAttenuation := particleAttenuation * (1.0 - (particleState position length smoothStepFrom: 7.0 to: 10.0)).
		
		color := WMVector4F zero.
		particleAttenuation > 0.0 ifTrue: [ 
			position := (WMVector3F x: s - 0.5 y: t -0.5 z: 0.0) * particleState size.
			smokeNoise := (position*0.5 +
			(WMVector3F z: particleIndex asFloat + particleState lifeTime)) fbmSignedGradientNoiseAbsOctaves: 3 lacunarity: 2.745.

			color := (colorRamp value: smokeNoise) * particleAttenuation.
		].
	
		color
	].

]

{ #category : #'as yet unclassified' }
WodenEsug2019Demo class >> createUniverse [
	| engine universe terrainMaterial waterMaterial terrainData underwaterFog sunIntensity |
	engine := WDCEngine default.
	terrainMaterial := engine resourceCache loadMaterial: 'materials/sectors/lake-wallen.json'.
	terrainData := engine resourceCache loadTerrain: 'terrains/sectors/lake-wallen.stterrain'.
	sunIntensity := 30.0.
	
	underwaterFog := WDESFogSettings new.
	underwaterFog useExponentialSquaredFog
		fogColor: (((Color fromHexString: '0E1233') hdrNormalized * sunIntensity*0.01) w: 1.0);
		farDistanceOverride: 500.0;
		fogDensity: 0.01;
		cameraCascadeSplitDistribution: 0.5.
	
	universe := WDESSimpleUniverse for: engine.
	universe
		gameLogicClass: WodenEsug2019DemoGameLogic;
		defaultCameraFarDistance: 6000.0;
		defaultCameraCascadeSplitDistribution: {30.0 . 500.0 . 1000.0};
		defaultCameraToneMappingOperator: #filmic;
		defaultCameraExposure: 0.6;
		defaultFogSettings: (WDESFogSettings new
			fogColor: ((self fogColorForSunIntensity: sunIntensity) w: 1.0);
			useExponentialSquaredFog;
			fogDensity: 0.0003).
	universe buildSector: [ :sector |
		sector buildTerrainMeshWithData: terrainData withMaterial: terrainMaterial.
		(sector buildParticleSystemWith: [ :chimney |
			self createVolcanoParticleSystem: chimney
		]) translateTo: (WMVector3F y: 1000.0).
	
		sector addSoundSourceComponentAt: WMVector3F zero with: [ :comp |
			comp loadSoundSample: 'sounds/environment/wind.wav';
				isGlobalSource: true;
				looped: true;
				gain: 0.5;
				pitch: 1.0;
				play
		].
	
		sector addWaterVolumeAt: WMVector3F zero with: [ :waterEntity :waterComponent |
			waterComponent
				environmentFogSettings: underwaterFog;
				environmentSoundGainFactor: 0.2.
			(waterEntity buildWaterMeshWith: [ :meshBuilder |
				waterMaterial := engine resourceCache loadMaterial: 'materials/water/blue-sea.json'.
				meshBuilder
					material: waterMaterial.
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
					intensity: (WMVector4F x: 1.0 y: 1.0 z: 0.4) normalized * sunIntensity;
					shadowMapDepthBiasConstant: 4.0;
					shadowMapDepthBiasSlope: 10.0;
					rotateDegreesOnX: -45;
					rotateDegreesOnY: -100;
					translateToX: 0.0 y: 1.5 z: 2.5.
					
				skyTexture := self proceduralSkySunDirection: light forwardDirection sunColor: light intensity.
				skyTexture := skyTexture asTextureFor: engine.
				sector addSkyBoxWithTexture: skyTexture
			].
		
		self
			addWodanicToSector: sector at: (WMVector3F z: 4000.0);
			addLighthouseToSector: sector at: (WMVector3F x: -1120.0 y: 110.2 z: 820.0).

		"Lighthouse start point"
		"sector
			addPlayerStartPointAt: (WMVector3F x: -1121.0 y: 112.0 z: 830.0)."

		"Wodanic cabin start point"
		"sector
			addPlayerStartPointAt: (WMVector3F x: 0.0 y: 4.0 z: 4001.0)."

		"Wodanic front start point"
		"sector
			addPlayerStartPointAt: (WMVector3F x: 0.0 y: 4.0 z: 3990.0)."
			
		"Wodanic rear start point"
		sector
			addPlayerStartPointAt: (WMVector3F x: 0.0 y: 4.0 z: 4019.0).

	].

	^ universe
]

{ #category : #'as yet unclassified' }
WodenEsug2019Demo class >> createVolcanoParticleSystem: particleSystem [
	| colorRamp |
	
	colorRamp := WDCLinearRamp with: {
		0.15 -> (WMVector4F x: 0.2 y: 0.2 z: 0.2 w: 0.3).
		0.8 -> (WMVector4F x: 1.0 y: 1.0 z: 1.0 w: 0.3).
	}.
	particleSystem boundingBox: (WMBox3DF halfExtent: (WMVector3F x: 100.0 y: 3000.0 z: 100.0)).
	particleSystem particleCount: 64.
	
	particleSystem simulationBlock: [ :particleState :index :delta |
		| lifeTime color |
		lifeTime := particleState lifeTime  - delta.
		lifeTime <= 0.0 ifTrue:[
			lifeTime := (1.7 + (particleState nextRandom*1.5))*2.0.
			particleState
				startingUp: false;
				position: particleState nextRandomVector3F * 150.0;
				velocity: (WMVector3F
					x: particleState nextRandom*150.0
					y: 400.0 + (particleState nextRandom *150.0)
					z: particleState nextRandom*150.0)*0.5.
		].
	
		color := colorRamp value: lifeTime / 3.0.
		
		particleState
			size: (WMVector3F x: 400.0 y: 400.0);
			velocity: (particleState velocity + (WMVector3F y: -9.8 * delta*0.04));
			position: (particleState position + (particleState velocity *delta));
			color: color;
			lifeTime: lifeTime.
	].
	particleSystem renderingBlock: [ :particleState :particleIndex :s :t |
		| radialPosition particleAttenuation position smokeNoise color |
		radialPosition := (WMVector3F x: s y: t z: 0.0) * 2.0 - (WMVector3F x: 1.0 y: 1.0 z: 0.0).
		particleAttenuation := 1.0 - (radialPosition length smoothStepFrom: 0.3 to: 1.0).
		particleAttenuation := particleAttenuation * (particleState lifeTime smoothStepFrom: 0.0 to: 0.3).
		particleAttenuation := particleAttenuation * (1.0 - (particleState position length smoothStepFrom: 1000.0 to: 2000.0)).
		
		color := WMVector4F zero.
		particleAttenuation > 0.0 ifTrue: [ 
			position := (WMVector3F x: s - 0.5 y: t -0.5 z: 0.0) * particleState size.
			smokeNoise := (position*0.002 +
			(WMVector3F z: particleIndex asFloat + (particleState lifeTime*0.1))) fbmSignedGradientNoiseAbsOctaves: 3 lacunarity: 2.745.

			color := (colorRamp value: smokeNoise) * particleAttenuation.
		].
	
		color
	].

]

{ #category : #'as yet unclassified' }
WodenEsug2019Demo class >> exampleEsugDemo [
	| universe |
	universe := self createUniverse.
	universe createSimulationModel
		open
		spawnPlayer.
		
]

{ #category : #'as yet unclassified' }
WodenEsug2019Demo class >> fogColorForSunIntensity: sunIntensity [
	^ (Color fromHexString: '83b4dd') hdrNormalized * (self atmosphereIntensityForSunIntensity: sunIntensity)
]

{ #category : #'as yet unclassified' }
WodenEsug2019Demo class >> proceduralSkySunDirection: sunDirection sunColor: sunColor [
	| horizonRamp sunIntensity sunAngleSizeCos sunAngleSizeOuterCos shader atmosphereIntensity cloudsColor |
	sunIntensity := sunColor length.
	atmosphereIntensity := sunIntensity / 3.0.
	horizonRamp := WDCLinearRamp with: {
		0.2 -> (self fogColorForSunIntensity: sunIntensity).
		1.5 -> ((Color fromHexString: '001c6f') hdrNormalized * atmosphereIntensity).
	}.
		
	sunAngleSizeCos := 0.5 degreesToRadians cos.
	sunAngleSizeOuterCos := 20.0 degreesToRadians cos.
	cloudsColor := WMVector4F ones * (atmosphereIntensity *2.0).
		
	shader := [ :x :y :z |
		| direction background atmosphere clouds sunCos sunFactor |
		direction := (WMVector3F x: x y: y z: z) normalized.
		sunCos := direction dot: sunDirection.
		sunFactor := sunCos smoothStepFrom: sunAngleSizeOuterCos to: sunAngleSizeCos.

		atmosphere := horizonRamp value: direction y.

		clouds := 0.0.
		direction y > 0.0 ifTrue: [
			|t|
			t := 2.5 / direction y.
			clouds := (direction xz * t) fbmGradientNoiseOctaves: 4 lacunarity: 2.0.
			clouds := (clouds*2.0 - 1.0 max: 0.0) min: 1.0.
		
			clouds := clouds * (direction y smoothStepFrom: 0.5 to: 0.6)
		].
	
		background := atmosphere interpolateTo: cloudsColor at: clouds.
		background interpolateTo: sunColor at: (sunFactor raisedTo: 8.0)
	].

	^ WDCPharoProceduralGPUScriptEvaluator new
		textureExtent: 1024@1024;
		skyCubeMap: true;
		colorFunction: shader;
		evaluate.
]

{ #category : #'see class side' }
WodenEsug2019Demo >> seeClassSide [
]
