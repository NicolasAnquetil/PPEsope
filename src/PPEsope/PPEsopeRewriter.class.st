Class {
	#name : #PPEsopeRewriter,
	#superclass : #PPEsopeGrammar,
	#instVars : [
		'stream'
	],
	#category : #'PPEsope-Parser'
}

{ #category : #accessing }
PPEsopeRewriter class >> ignoredNames [
	^ super ignoredNames , #(stream)
]

{ #category : #regex }
PPEsopeRewriter class >> regexForEsopeWithArray [

	self flag: #FIXME. "how to deal with: ur.ubb(jr + 1).
	By now, we have ESOat(ur, ubb)(jr+1) instead of ESOar(ESOat(ub, ubb), jr + 1).
	By now we are not able to process this kind of statement when the subscript is an expression and not a litteral integer"
	^ '([a-zA-Z][a-zA-Z0-9]+\.[a-zA-Z][a-zA-Z0-9]+)\(([a-zA-Z0-9.]+)\)' asRegexIgnoringCase
]

{ #category : #regex }
PPEsopeRewriter class >> regexForEsopeWithDot [
	^ '[a-zA-Z][a-zA-Z0-9]+\.[a-zA-Z][a-zA-Z0-9]+' asRegexIgnoringCase
]

{ #category : #regex }
PPEsopeRewriter class >> regexForEsopeWithSlash [
	^ '([a-zA-Z][a-zA-Z0-9]+\.[a-zA-Z][a-zA-Z0-9]+)\(/[a-zA-Z0-9.]+\)' asRegexIgnoringCase
]

{ #category : #regex }
PPEsopeRewriter class >> rewriteFrom: esopeFile to: annotatedFile [

	| rewriter |
	rewriter := self new.
	rewriter parse: esopeFile.
	annotatedFile asFileReference writeStreamDo: [ :stream | 
		stream truncate.
		stream << (rewriter output
			 replaceAll: Character cr
			 with: Character lf) ]
]

{ #category : #rules }
PPEsopeRewriter >> addLineSeparator [

	stream << Character cr
]

{ #category : #rules }
PPEsopeRewriter >> annotateByEsopePrefix [

	stream << 'cESO  '
]

{ #category : #utilities }
PPEsopeRewriter >> copyTokens: nodes from: start to: end [
	start to: end do: [ :i | stream << (nodes at: i) ]
]

{ #category : #grammar }
PPEsopeRewriter >> fortranLine [
	"(lineEnd negate plus) token optional, lineEnd"

	^ super fortranLine
		==> [ :nodes | 
			| line |
			line := ''
				writeStreamDo: [ :str | 
					nodes do: [ :node | str << node value ].
					str contents ].
			(line asLowercase beginsWith: 'c')
				ifTrue: [ stream << line ]
				ifFalse: [ stream
						<<
							(self
								translateEsopeAt: (self translateEsopeArray: (self translateEsopeSlash: line))) ] ]
				
]

{ #category : #utilities }
PPEsopeRewriter >> fortranOperator: esopeAtIdentifier [

	| uppercaseIdentifier |
	uppercaseIdentifier := esopeAtIdentifier asUppercase.
	^ self logicalOperators anySatisfy: [ :operator | 
		  (uppercaseIdentifier beginsWith: operator) or: [ 
			  uppercaseIdentifier endsWith: operator ] ]
]

{ #category : #utilities }
PPEsopeRewriter >> fortranOperator: esopeAtIdentifier from: start to: end [

	| uppercaseIdentifier |
	(start <= 1 or: [ end >= esopeAtIdentifier size ]) ifTrue: [ ^ false ].

	uppercaseIdentifier := (esopeAtIdentifier
		                        copyFrom: start - 1
		                        to: end + 1) asUppercase.
	^ self logicalOperators anySatisfy: [ :operator | 
		  (uppercaseIdentifier beginsWith: operator) or: [ 
			  uppercaseIdentifier endsWith: operator ] ]
]

{ #category : #initialization }
PPEsopeRewriter >> initStream [
	stream := '' writeStream
]

{ #category : #initialization }
PPEsopeRewriter >> initialize [
	super initialize.
	
	self initStream.
]

{ #category : #utilities }
PPEsopeRewriter >> logicalOperators [

	^ #( '.EQ.' '.LT.' '.LE.' '.GT.' '.GE.' '.NE.' '.OR.' '.AND.' '.NOT.'
	     '.TRUE.' '.FALSE.' '.EQV.' '.NEQV.' )
]

{ #category : #rules }
PPEsopeRewriter >> optionalBlanks [

	^ super optionalBlanks
	  ==> [ :nodes | nodes ifNil: [ '' token ] ifNotNil: [ :tk | tk ] ]
]

{ #category : #accessing }
PPEsopeRewriter >> output [

	^ stream contents
]

{ #category : #accessing }
PPEsopeRewriter >> outputForSegment [

	^ stream contents replaceAll: Character tab  with: Character cr
]

{ #category : #grammar }
PPEsopeRewriter >> pointer [
	" beginOfLine, spaces, 'pointeur' asPParser, spaces, pointerName, endOfLine"

	^ super pointer
		==> [ :nodes | stream << 'cESO  '.
				self copyTokens: nodes from: 2 to: nodes size
			]
]

{ #category : #utilities }
PPEsopeRewriter >> processLinesInsideSegment: anOrderedCollection [
	"  (beginOfLine, 'end' asPParser not, endOfLine negate plus, endOfLine) star"
	anOrderedCollection do: [ :line |
			stream << 'cESO  '.
			self copyTokens: line from: 3 to: 4
		 ]
]

{ #category : #rules }
PPEsopeRewriter >> processNodes: nodes [

	self annotateByEsopePrefix.
	^ self copyTokens: nodes from: 2 to: nodes size
]

{ #category : #grammar }
PPEsopeRewriter >> segact [
	"beginOfLine, spaces, 'segact' asPParser, segIdentifier, endOfLine"

	^ super segact
		==> [ :nodes | stream << 'cESO  '.
				self copyTokens: nodes from: 2 to: nodes size
			]
]

{ #category : #grammar }
PPEsopeRewriter >> segadj [
	"beginOfLine, spaces, 'segadj' asPParser, segIdentifier, endOfLine"

	^ super segadj
		==> [ :nodes | stream << 'cESO  '.
				self copyTokens: nodes from: 2 to: nodes size
			]
]

{ #category : #grammar }
PPEsopeRewriter >> segdef [
	"beginOfLine, spaces, 'segment' asPParser, segIdentifier, endOfLine,
	lines,
	beginOfLine, spaces, 'end' asPParser , spaces, 'segment' asPParser, endOfLine"
	
	^ super segdef
	==> [ :nodes |
		stream << 'cESO  '.
		self copyTokens: nodes from: 2 to: 5.
		self processLinesInsideSegment: (nodes at: 6).
		stream << 'cESO  '.
		self copyTokens: nodes from: 8  to: 12
		]
]

{ #category : #grammar }
PPEsopeRewriter >> segdes [
	" beginOfLine, spaces, 'segdes' asPParser, segIdentifier, endOfLine"

	^ super segdes
		==> [ :nodes | stream << 'cESO  '.
				self copyTokens: nodes from: 2 to: nodes size
			]
]

{ #category : #grammar }
PPEsopeRewriter >> segini [
	" beginOfLine, spaces, 'segini' asPParser, segIdentifier, endOfLine"

	^ super segini
		==> [ :nodes | stream << 'cESO  '.
				self copyTokens: nodes from: 2 to: nodes size
			]
]

{ #category : #grammar }
PPEsopeRewriter >> segsup [
	" beginOfLine , spaces, 'segsup' asPParser, segIdentifier, endOfLine"

	^ super segsup
		==> [ :nodes | stream << 'cESO  '.
				self copyTokens: nodes from: 2 to: nodes size
			]
]

{ #category : #grammar }
PPEsopeRewriter >> spaces [
	^super spaces
	==> [ :nodes |
		nodes ifNil: [ '' token ] ifNotNil: [ :tk | tk ]
		]
]

{ #category : #utilities }
PPEsopeRewriter >> translateEsopeArray: inputStream [

	| regex i |
	i := 1.
	'' writeStreamDo: [ :outputStream | 
		regex := self class regexForEsopeWithArray.
		(regex matchingRangesIn: inputStream) do: [ :interval | 
			(self
				 fortranOperator: inputStream
				 from: interval first
				 to: interval last) ifFalse: [ 
				i to: interval first - 1 do: [ :idx | 
				outputStream nextPut: (inputStream at: idx) ].
				outputStream << 'ESOar('.
				i := interval first.
				[ (inputStream at: i) == $( ] whileFalse: [ 
					outputStream nextPut: (inputStream at: i).
					i := i + 1 ].
				outputStream nextPut: $,.
				[ (inputStream at: i) == $) ] whileFalse: [ 
					outputStream nextPut: (inputStream at: i + 1).
					i := i + 1 ].
				i + 1 to: interval last do: [ :idx | 
				outputStream nextPut: (inputStream at: idx) ].
				i := interval last + 1 ] ].
		i to: inputStream size do: [ :idx | 
		outputStream nextPut: (inputStream at: idx) ].
		^ outputStream contents ]
]

{ #category : #utilities }
PPEsopeRewriter >> translateEsopeAt: inputStream [

	| regex i |
	i := 1.
	'' writeStreamDo: [ :outputStream | 
		regex := self class regexForEsopeWithDot.
		(regex matchingRangesIn: inputStream) do: [ :interval | 
			(self
				 fortranOperator: inputStream
				 from: interval first
				 to: interval last) ifFalse: [ 
				i to: interval first - 1 do: [ :idx | 
				outputStream nextPut: (inputStream at: idx) ].
				outputStream << 'ESOat('.
				i := interval first.
				[ (inputStream at: i) == $. ] whileFalse: [ 
					outputStream nextPut: (inputStream at: i).
					i := i + 1 ].
				outputStream nextPut: $,.
				i + 1 to: interval last do: [ :idx | 
				outputStream nextPut: (inputStream at: idx) ].
				outputStream nextPut: $).
				i := interval last + 1 ] ].
		i to: inputStream size do: [ :idx | 
		outputStream nextPut: (inputStream at: idx) ].
		^ outputStream contents ]
]

{ #category : #utilities }
PPEsopeRewriter >> translateEsopeSlash: inputStream [

	| regex i |
	i := 1.
	'' writeStreamDo: [ :outputStream | 
		regex := self class regexForEsopeWithSlash.
		(regex matchingRangesIn: inputStream) do: [ :interval | 
			i to: interval first - 1 do: [ :idx | 
			outputStream nextPut: (inputStream at: idx) ].
			outputStream << 'ESOsl('.
			i := interval first.
			[ (inputStream at: i) == $( ] whileFalse: [ 
				outputStream nextPut: (inputStream at: i).
				i := i + 1 ].
			outputStream nextPut: $,.
			i + 2 to: interval last do: [ :idx | 
			outputStream nextPut: (inputStream at: idx) ].
			i := interval last + 1 ].
		i to: inputStream size do: [ :idx | 
		outputStream nextPut: (inputStream at: idx) ].
		^ outputStream contents ]
]
