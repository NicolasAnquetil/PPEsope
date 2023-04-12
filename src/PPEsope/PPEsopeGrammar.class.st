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
		'endOfLine',
		'beginOfLine',
		'segIdentifier',
		'fortranLine',
		'emptyLine',
		'pointerKeyword',
		'endToken',
		'segmentToken'
	],
	#category : #'PPEsope-Parser'
}

{ #category : #'as yet unclassified' }
PPEsopeGrammar class >> getSourceFromFile: filename [
	^ filename asFileReference contents asText
]

{ #category : #tokens }
PPEsopeGrammar >> beginOfLine [
	^ '      ' asParser flatten
]

{ #category : #tokens }
PPEsopeGrammar >> dotToken [

	^ self symbol: $.
]

{ #category : #grammar }
PPEsopeGrammar >> emptyLine [
	^ spaces , endOfLine
]

{ #category : #tokens }
PPEsopeGrammar >> endOfLine [
	^ (Character cr asParser / Character lf asParser)  plus flatten
]

{ #category : #tokens }
PPEsopeGrammar >> endToken [
	^'end' asParser flatten
]

{ #category : #'grammar-helper' }
PPEsopeGrammar >> esopeLine: esopeKeyword [
	^ beginOfLine , spaces, esopeKeyword asParser flatten , segIdentifier, endOfLine
]

{ #category : #grammar }
PPEsopeGrammar >> file [

	^ (segact / segadj / segdef / segdes / segini / segsup / pointer
	   / include / fortranLine / emptyLine) plus
]

{ #category : #grammar }
PPEsopeGrammar >> fortranLine [
	^ (endOfLine negate star flatten) , endOfLine
]

{ #category : #tokens }
PPEsopeGrammar >> identifier [
	^ (#letter asParser , #word asParser star) flatten.
]

{ #category : #grammar }
PPEsopeGrammar >> include [
	^ '#include' asParser flatten, spaces, includeName, endOfLine
]

{ #category : #grammar }
PPEsopeGrammar >> includeName [
	^ ($" asParser, identifier, $. asParser, identifier , $"  asParser) flatten /
	($< asParser, identifier, $. asParser, identifier , $>  asParser) flatten
]

{ #category : #grammar }
PPEsopeGrammar >> lines [
	^ notEndLine star 
]

{ #category : #grammar }
PPEsopeGrammar >> notEndLine [
	" A line not starting with ' end' (so not an 'end <something>' line)"
	^ beginOfLine, 'end' asParser not, endOfLine negate plus flatten, endOfLine
]

{ #category : #tokens }
PPEsopeGrammar >> optionalBlanks [

	^ #blank asPParser star flatten
]

{ #category : #grammar }
PPEsopeGrammar >> pointer [
	^ beginOfLine, pointerKeyword , spaces, pointerName, endOfLine
]

{ #category : #tokens }
PPEsopeGrammar >> pointerKeyWord [

	^ (self terminal: 'pointeur') flatten
]

{ #category : #tokens }
PPEsopeGrammar >> pointerKeyword [
	^'pointeur' asParser flatten
]

{ #category : #tokens }
PPEsopeGrammar >> pointerName [
	^ (identifier, $. asParser, identifier) flatten
]

{ #category : #tokens }
PPEsopeGrammar >> segIdentifier [
	^ endOfLine negate plus flatten
]

{ #category : #grammar }
PPEsopeGrammar >> segact [
	"beginOfLine , spaces, 'segact' asParser, segIdentifier, endOfLine"
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
	beginOfLine, spaces, endToken , spaces, segmentToken , endOfLine
]

{ #category : #grammar }
PPEsopeGrammar >> segdes [
	^ self esopeLine: 'segdes'
]

{ #category : #grammar }
PPEsopeGrammar >> segini [
	^ self esopeLine: 'segini'
]

{ #category : #tokens }
PPEsopeGrammar >> segmentToken [
	^'segment' asParser flatten
]

{ #category : #grammar }
PPEsopeGrammar >> segsup [
	^ self esopeLine: 'segsup'
]

{ #category : #tokens }
PPEsopeGrammar >> spaces [
	^ (#blank asParser / #tab asParser) star flatten
]

{ #category : #grammar }
PPEsopeGrammar >> start [
	^ file end
]

{ #category : #'grammar-helper' }
PPEsopeGrammar >> symbol: aLetter [

	^ aLetter asPParser
]

{ #category : #'grammar-helper' }
PPEsopeGrammar >> terminal: aString [
	^ aString asPParser caseInsensitive
]
