Class {
	#name : #PPEsopeFullGrammarTest,
	#superclass : #TestCase,
	#instVars : [
		'parser',
		'sixSpaces'
	],
	#category : #'PPEsope-Tests'
}

{ #category : #running }
PPEsopeFullGrammarTest >> parserClass [

	^ PPEsopeGrammar
]

{ #category : #running }
PPEsopeFullGrammarTest >> setUp [
	super setUp.
	sixSpaces := '      '.
	parser := self parserClass new
]

{ #category : #running }
PPEsopeFullGrammarTest >> testBigFile [
	self deny: (parser parse: PPEsopeGrammarTest esopeBigFile) isPetitFailure 
]

{ #category : #running }
PPEsopeFullGrammarTest >> testEmptyFile [
	self deny: (parser parse: '
') isPetitFailure 
]

{ #category : #running }
PPEsopeFullGrammarTest >> testEsopePointeurFile [
	self deny: (parser parse: '      subroutine stgbrk(
c     == entrees ==
     & alist,splist,
c     == sorties ==
     & rlist,status)
      pointeur alist.list
      return
      end
') isPetitFailure 
]

{ #category : #running }
PPEsopeFullGrammarTest >> testEsopeSegactFile [
	self deny: (parser parse: '      subroutine stgbrk(
c     == entrees ==
     & alist,splist,
c     == sorties ==
     & rlist,status)
      segact,splist
      return
      end
') isPetitFailure 
]

{ #category : #running }
PPEsopeFullGrammarTest >> testEsopeSegadjFile [
	self deny: (parser parse: '      subroutine stgbrk(
c     == entrees ==
     & alist,splist,
c     == sorties ==
     & rlist,status)
                segadj,rlist

      return
      end
') isPetitFailure 
]

{ #category : #running }
PPEsopeFullGrammarTest >> testEsopeSegdesFile [
	self deny: (parser parse: '      subroutine stgbrk(
c     == entrees ==
     & alist,splist,
c     == sorties ==
     & rlist,status)
      segdes,alist

      return
      end
') isPetitFailure 
]

{ #category : #running }
PPEsopeFullGrammarTest >> testEsopeSeginiFile [
	self deny: (parser parse: '      subroutine stgbrk(
c     == entrees ==
     & alist,splist,
c     == sorties ==
     & rlist,status)
              segini,ms

      return
      end
') isPetitFailure 
]

{ #category : #running }
PPEsopeFullGrammarTest >> testNonEsopeFile [
	self deny: (parser parse: '      subroutine stgbrk(
c     == entrees ==
     & alist,splist,
c     == sorties ==
     & rlist,status)
      return
      end
') isPetitFailure 
]

{ #category : #running }
PPEsopeFullGrammarTest >> testSmallFile [
	self deny: (parser parse: PPEsopeGrammarTest esopeSmallFile) isPetitFailure 
]
