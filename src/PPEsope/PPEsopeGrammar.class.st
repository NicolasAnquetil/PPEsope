Class {
	#name : #PPEsopeGrammar,
	#superclass : #PPCompositeParser,
	#instVars : [
		'file',
		'include',
		'includeName',
		'pointer',
		'pointerName',
		'segact',
		'segadj',
		'segdef',
		'segdes',
		'segini',
		'segsup',
		'spaces',
		'notEndLine',
		'lines',
		'identifier',
		'comma',
		'endOfLine',
		'beginOfLine',
		'segIdentifier',
		'fortranLine',
		'emptyLine'
	],
	#category : #'PPEsope-Parser'
}

{ #category : #'as yet unclassified' }
PPEsopeGrammar class >> getSourceFromFile: filename [
	^ filename asFileReference contents asText
]

{ #category : #tokens }
PPEsopeGrammar >> beginOfLine [
	^ '      ' asParser token
]

{ #category : #tokens }
PPEsopeGrammar >> comma [
	^ $, asParser
]

{ #category : #grammar }
PPEsopeGrammar >> emptyLine [
	^ spaces , endOfLine
]

{ #category : #tokens }
PPEsopeGrammar >> endOfLine [
	^ (Character cr asParser / Character lf asParser)  plus
]

{ #category : #'grammar-helper' }
PPEsopeGrammar >> esopeLine: esopeKeyword [
	^ beginOfLine , spaces, esopeKeyword asParser, segIdentifier, endOfLine
]

{ #category : #tokens }
PPEsopeGrammar >> file [

	^ (segact / segadj / segdef / segdes / segini / segsup / pointer
	   / include / fortranLine / emptyLine) plus
]

{ #category : #grammar }
PPEsopeGrammar >> fortranLine [
	^ (endOfLine negate plus) token optional, endOfLine
]

{ #category : #tokens }
PPEsopeGrammar >> identifier [
	^ #letter asParser , #word asParser star.
]

{ #category : #grammar }
PPEsopeGrammar >> include [
	^ '#include' asParser, spaces, includeName, endOfLine
]

{ #category : #grammar }
PPEsopeGrammar >> includeName [
	^ ($" asParser / $< asParser), (identifier, $. asParser, identifier) token, ($" asParser  / $>  asParser)
]

{ #category : #grammar }
PPEsopeGrammar >> lines [
	^ notEndLine star 
]

{ #category : #grammar }
PPEsopeGrammar >> notEndLine [
	^ beginOfLine, 'end' asParser not, endOfLine negate plus, endOfLine
]

{ #category : #grammar }
PPEsopeGrammar >> pointer [
	^ beginOfLine, 'pointeur' asParser, spaces, pointerName, endOfLine
]

{ #category : #grammar }
PPEsopeGrammar >> pointerName [
	^ identifier, $. asParser, identifier
]

{ #category : #tokens }
PPEsopeGrammar >> rpar [
	^ $) asParser 
]

{ #category : #grammar }
PPEsopeGrammar >> segIdentifier [
	^ endOfLine negate plus
]

{ #category : #grammar }
PPEsopeGrammar >> segact [
	^ self esopeLine: 'segact'
]

{ #category : #grammar }
PPEsopeGrammar >> segadj [
	^ self esopeLine: 'segadj'
]

{ #category : #grammar }
PPEsopeGrammar >> segdef [

	^ (self esopeLine: 'segment') ,
	lines,
	beginOfLine, spaces, 'end' asParser , spaces, 'segment' asParser, endOfLine
]

{ #category : #grammar }
PPEsopeGrammar >> segdes [
	^ self esopeLine: 'segdes'
]

{ #category : #grammar }
PPEsopeGrammar >> segini [
	^ self esopeLine: 'segini'
]

{ #category : #grammar }
PPEsopeGrammar >> segsup [
	^ self esopeLine: 'segsup'
]

{ #category : #tokens }
PPEsopeGrammar >> spaces [
	^ (#blank asParser / #tab asParser) star
]

{ #category : #accessing }
PPEsopeGrammar >> start [
	^ file end
]
