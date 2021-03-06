! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays constructors grouping kernel math
sequences math.vectors sequences.deep ;
IN: arrays.shaped

: flat? ( array -- ? ) [ sequence? ] any? not ; inline

GENERIC: array-replace ( object -- shape )

M: f array-replace ;

M: object array-replace drop f ;

M: sequence array-replace
    dup flat? [
        length
    ] [
        [ array-replace ] map
    ] if ;

TUPLE: uniform-shape shape ;
C: <uniform-shape> uniform-shape

TUPLE: abnormal-shape shape ;
C: <abnormal-shape> abnormal-shape

GENERIC: wrap-shape ( object -- shape )

M: integer wrap-shape
    0 2array <uniform-shape> ;

M: sequence wrap-shape
    dup all-equal? [
        [ length ] [ first ] bi 2array <uniform-shape>
    ] [
        <abnormal-shape>
    ] if ;

GENERIC: shape ( array -- shape )

M: sequence shape array-replace wrap-shape ;

GENERIC: shape-capacity ( shape -- n )

M: sequence shape-capacity product ;

M: uniform-shape shape-capacity shape>> product ;

M: abnormal-shape shape-capacity
    shape>> 0 swap [
        [ dup sequence? [ drop ] [ + ] if ] [ 1 + ] if*
    ] deep-each ;

ERROR: underlying-shape-mismatch underlying shape ;

ERROR: no-abnormally-shaped-arrays underlying shape ;

GENERIC: check-underlying-shape ( underlying shape -- underlying shape )

M: abnormal-shape check-underlying-shape
    no-abnormally-shaped-arrays ;

M: uniform-shape check-underlying-shape
    shape>> check-underlying-shape ;
    
M: sequence check-underlying-shape
    2dup [ length ] [ shape-capacity ] bi*
    = [ underlying-shape-mismatch ] unless ; inline

ERROR: shape-mismatch shaped0 shaped1 ;

: check-shape ( shaped-array shaped-array -- shaped-array shaped-array )
    2dup [ shape>> ] bi@
    sequence= [ shape-mismatch ] unless ;

TUPLE: shaped-array underlying shape ;
TUPLE: row-array < shaped-array ;
TUPLE: col-array < shaped-array ;

M: shaped-array length underlying>> length ; inline

M: shaped-array shape shape>> ;

: make-shaped-array ( underlying shape class -- shaped-array )
    [ check-underlying-shape ] dip new
        swap >>shape
        swap >>underlying ; inline

: <shaped-array> ( underlying shape -- shaped-array )
    shaped-array make-shaped-array ; inline

: <row-array> ( underlying shape -- shaped-array )
    row-array make-shaped-array ; inline

: <col-array> ( underlying shape -- shaped-array )
    col-array make-shaped-array ; inline

GENERIC: >shaped-array ( array -- shaped-array )
GENERIC: >row-array ( array -- shaped-array )
GENERIC: >col-array ( array -- shaped-array )

M: sequence >shaped-array
    [ flatten ] [ shape ] bi <shaped-array> ;

M: shaped-array >shaped-array ;

M: shaped-array >row-array
    [ underlying>> ] [ shape>> ] bi <row-array> ;

M: shaped-array >col-array
    [ underlying>> ] [ shape>> ] bi <col-array> ;

M: sequence >col-array
    [ flatten ] [ shape ] bi <col-array> ;

: shaped+ ( a b -- c )
    check-shape
    [ [ underlying>> ] bi@ v+ ]
    [ drop shape>> clone ] 2bi shaped-array boa ;

: shaped-array>array ( shaped-array -- array )
    [ underlying>> ] [ shape>> ] bi rest-slice [ group ] each ;

: reshape ( shaped-array shape -- array )
    check-underlying-shape >>shape ;

: shaped-like ( shaped-array shape -- array )
    [ underlying>> clone ] dip <shaped-array> ;

: repeated-shaped ( shape element -- shaped-array )
    [ [ shape-capacity ] dip <array> ] [ drop ] 2bi <shaped-array> ;

: zeros ( shape -- shaped-array ) 0 repeated-shaped ;

: ones ( shape -- shaped-array ) 1 repeated-shaped ;

: increasing ( shape -- shaped-array )
    [ shape-capacity iota >array ] [ ] bi <shaped-array> ;

: decreasing ( shape -- shaped-array )
    [ shape-capacity iota <reversed> >array ] [ ] bi <shaped-array> ;

: row-length ( shape -- n ) rest-slice product ; inline

: column-length ( shape -- n ) first ; inline

: each-row ( shaped-array quot -- )
    [ [ underlying>> ] [ shape>> row-length <groups> ] bi ] dip
    each ; inline

TUPLE: transposed shaped-array ;

: transposed-shape ( shaped-array -- shape )
    shape>> <reversed> ;

TUPLE: row-traverser shaped-array index ;

GENERIC: next-index ( object -- index )

USE: prettyprint.custom
M: shaped-array pprint* shaped-array>array pprint* ;
M: row-array pprint* shaped-array>array pprint* ;
M: col-array pprint* shaped-array>array flip pprint* ;
