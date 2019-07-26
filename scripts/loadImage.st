Metacello new
  baseline: 'WodenEsug2019Demo';
  repository: 'gitlocal://tonel';
  load.

"Save the image"
(Smalltalk saveAs: 'woden-demo')
    ifFalse: [ Smalltalk snapshot: false andQuit: true ].
