\ Part 2 of the JonesForth tutorial.
\ This one is added word-by-word as they are succesfully executed

\ Define / and MOD in terms of /MOD
: / /MOD SWAP DROP ;
: MOD /MOD DROP ;

\ Some char constant
: '\n' 10 ;
: BL 32 ; \ BL (blank) is standard FORTH word for space.

: CR '\n' EMIT ;
: SPACE BL EMIT ;

: NEGATE 0 SWAP - ;

: TRUE 1 ;
: FALSE 0 ;
: NOT 0= ;

\ LITERAL takes whatever on the stack and compiles LIT <foo>
: LITERAL IMMEDIATE
    ' LIT ,
    ,
;

: ':'
    [
    CHAR :
    ]
    LITERAL
;

: ';' [ CHAR ; ] LITERAL ;
: '(' [ CHAR ( ] LITERAL ;
: ')' [ CHAR ) ] LITERAL ;
: '"' [ CHAR " ] LITERAL ;
: 'A' [ CHAR A ] LITERAL ;
: '0' [ CHAR 0 ] LITERAL ;
: '-' [ CHAR - ] LITERAL ;
: '.' [ CHAR . ] LITERAL ;

: [COMPILE] IMMEDIATE
    WORD
    FIND
    >CFA
    ,
;

: RECURSE IMMEDIATE
    LATEST @
    >CFA
    ,
;

\ Conditionals Statements

: IF IMMEDIATE
    ' 0BRANCH ,
    HERE @
    0 ,
;

: THEN IMMEDIATE
    DUP
    HERE @ SWAP -
    SWAP !
;

: ELSE IMMEDIATE
    ' BRANCH ,
    HERE @
    0 ,
    SWAP
    DUP
    HERE @ SWAP -
    SWAP !
;

: UNLESS IMMEDIATE
    ' NOT ,
    [COMPILE] IF
;

\ Loop Construct

: BEGIN IMMEDIATE
    HERE @
;

: UNTIL IMMEDIATE
    ' 0BRANCH ,
    HERE @ -
    ,
;

: AGAIN IMMEDIATE
    ' BRANCH ,
    HERE @
    ,
;

: WHILE IMMEDIATE
    ' 0BRANCH ,
    HERE @
    0 ,
;

: REPEAT IMMEDIATE
    ' BRANCH ,
    SWAP
    HERE @ - ,
    DUP
    HERE @ SWAP -
    SWAP !
;

\ Comments
: ( IMMEDIATE
    1
    BEGIN
        KEY
        DUP '(' = IF
            DROP
            1+
        ELSE
            ')' = IF
                1-
            THEN
        THEN
    DUP 0= UNTIL
    DROP
;

( Now we can nest ( ... ) as much as we want )

\ Stack Manipulation
: NIP ( x y -- y ) SWAP DROP ;
: TUCK ( x y -- y x y ) SWAP OVER ;
: PICK ( x_u ... x_1 x_0 u -- x_u ... x_1 x_0 x_u )
    1+
    8 * ( multiply by the word size )
    DSP@ +
    @
;

\ Writes N spaces to stdout
: SPACES ( n -- )
    BEGIN
        DUP 0>
    WHILE
        SPACE
	1-
    REPEAT
    DROP
;

\ Standard word for manipulating BASE.
: DECIMAL ( -- ) 10 BASE ! ;
: HEX ( -- ) 16 BASE ! ;

( Printing Numbers )

: U. ( u -- )
    BASE @ /MOD
    ?DUP IF       ( if quotient <> 0 then )
        RECURSE   ( print the quotient )
    THEN

    ( print the remainder )
    DUP 10 < IF
        '0'
    ELSE
        10 -
	'A'
    THEN
    +
    EMIT
;

( Printing the content of the stack )
: .S ( -- )
    DSP@
    BEGIN
        DUP S0 @ <
    WHILE
        DUP @ U.
	SPACE
	8+
    REPEAT
    DROP
;

( Returns the width of an unsigned number (in characters) in the current base )
: UWIDTH
    BASE @ /
    ?DUP IF
        RECURSE 1+
    ELSE
        1
    THEN
;

: U.R ( u width -- )
    SWAP
    DUP
    UWIDTH
    ROT
    SWAP -
    SPACES
    U.
;

: .R ( n width -- )
    SWAP ( width n )
    DUP 0< IF
        NEGATE ( width u )
	1      ( save flag to remember that it was negative | width u 1 )
        SWAP   ( width 1 u )
        ROT    ( 1 u width )
        1-     ( 1 u width-1 )
    ELSE
	0      ( width u 0 )
	SWAP   ( width 0 u )
	ROT    ( 0 u width )
    THEN
    SWAP   ( flag width u )
    DUP    ( flag width u u )
    UWIDTH ( flag width u uwidth )
    ROT    ( flag u uwidth width )
    SWAP - ( flag u width-uwidth )

    SPACES ( flag u )
    SWAP   ( u flag )

    IF
        '-' EMIT
    THEN
    U.
;

( Finally )
: . 0 .R SPACE ;

( The real U. )
: U. U. SPACE ;

: ? ( addr -- ) @ . ;

