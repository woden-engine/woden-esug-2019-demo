Class {
	#name : #BaselineOfWodenEsug2019Demo,
	#superclass : #BaselineOf,
	#category : #BaselineOfWodenEsug2019Demo
}

{ #category : #baselines }
BaselineOfWodenEsug2019Demo >> baseline: spec [
    <baseline>
    spec for: #'common' do: [
		spec blessing: #baseline.
		spec 
			baseline: #'WodenEngine' with: [
				spec
				repository: 'github://woden-engine/woden/tonel' ].
		spec package: #'WodenEsug2019Demo' with: [
				spec requires: #(#'WodenEngine')].
	]

]
