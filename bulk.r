REBOL [
	; -- Core Header attributes --
	title: {BULK | record based, table engine using a flat block.}
	file: %bulk.r
	version: 1.0.1
	date: lib-bulk
	author: "Maxim Olivier-Adlhoch"
	purpose: "A data-exchange format for use in any REBOL script"
	web: http://www.revault.org/modules/bulk.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'bulk
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/bulk.r

	; -- Licensing details  --
	copyright: "Copyright © 2013 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2013 Maxim Olivier-Adlhoch

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.}

	;-  / history
	history: {
		all history lost  :-(   bulk is used in a few projects.

		v1.0.0 - 2013-09-12
			-changed bulk model so it's using proper, strong modularisation properties of slim. 
			-license changed to Apache v2}
	;-  \ history

	;-  / documentation
	documentation: {
		
		-BULK will is used extensively by GLASS and its various APIs.
		-There is automated unit launch included at the end, remove if you want.
		-Change the unit testing code and data in the header to try out stuff.
		-Bulk was not upgraded to using the slut engine yet... 

		 
		---------
		BULK
		---------
		
		What is bulk?
		---
		a flat table data structure, which allows hierarchical data via the use of bulk data within the
		table.
		
		
		
		why?
		---
		to promote and sponsor an open data exchange format which takes up the least amount of space for
		large data sets, yet provides flexibility for nested data sets.
		
		the specification includes guidelines about every aspect of the the datastructure.  If you find
		an undefined issue, reach me on altme and I'll be sure to discuss it and add it to this
		specification.
		
		
		
		overall specification
		---
		
		A bulk is a block which contains a single header and 0 or more fixed length rows of items.
		
		an item is a single rebol value as undertood by LOAD/NEXT, which must be serializable using mold/all.
		
		at its most basic, a BULK is defined like so:
		
		bulk: [
			[columns: #[integer!]]  
			...
		]
		
		where:
		
			... is an undefined number of rows of data which have 'columns number of items each.
			
			properties in the header are specified using 'SET-WORD notation followed by ZERO OR ONE item 
			of data.  when a set-word follows, its considered undefined. 
			ex: [name: sex: "m"] here, name is considered undefined, so will return NONE!, not "m"
			(note this might change to reflect object spec notation where name: might return "m")
			
			the header MUST inlude the 'COLUMNS: property.  It defines how many items per row.
		
			header may include any number of other properties and expects to be usable as a  'CONSTRUCT
			or map! spec directly.
		
			any WORD! or LIT-WORD! value in the header is expected to be used litteraly, not as a bound,
			evaluatable word.  Because of this, PRINTing the header might provoke errors, you should 
			always PROBE it.  In Red,  the header will be explicitely unbound.
		
			You can obviously have BULK items in a BULK, hence its nested aspect.
			
		
		
		
		so what's the big deal?
		---
		-Anyone can understand and quickly build bulk supporting tools.
		
		-The fact that its a flat table means its extremely memory efficient (REBOL wise) and VERY easy
		 to manipulate, join, extract, etc.
		
		-ONLY the columns property will ever be required (so far) for the low-level tools to be happy
		 because bulk is a simple format to exchange data between arbitrary tools, some include databases
		 and huge but simple datasets.
		
		-Generic tools for conversion, disk & networking can safely convert any bulk with minimal fuss,
		 including the header.
		
		-Programmatically, the header is easily avoided by simply skipping it, and can then be used as a
		 negative skip, if you want to refer to it later.  When skipped, the BULK looks like an ordinary
		 block. Be carefull though, cause some functions like INDEX? calculate from the head, so will
		 consider the header in their results.
		
		-MANY liquid plugs will play around with BULK data.   It is very
		 useful, cause it reduces the number of dependencies to make when data is expected to live alongside
		 each other.  there will be generic bulk creation and extraction tools, reducing the number of plug
		 types to build in some situations.
		
		
		
		Bulk properties
		----
		you may add as many properties as you wish in the bulk header as long as you follow (very)
		simple guidelines.
		
		namely:
			-properties should be type constrained, so their handling remains simple and usefull.
			-when words are used to define a property, they are intended to be literal, not evaluatable
			 words.  You should use LIT-WORD!s, when possible.
			-an unspecified property (property is not in header) is not an error, it returns none, 
			 and your code should adapt with a default value if possible.
		
		some "standard" properties are defined but will never be required for the most basic bulk support
		this being said, if you don't specify them, bulk will not be able to react as automatically as it could.
		
		the specification will only require that their use conforms to their intended goals.
		
		example of possible (eventual) new standard headers:
		
				type:   [word!]
						identifies this bulk as belonging to a specific class of datasets.
						there will be official types.
			   
				date:   [date!]
						when was this bulk created
			   
				source: [file! url! string! word!]
						where does the source data come from.
			   
				doc:    [string! url!]
						documentation about this bulk data be included or refered to via an url
		
				label-column: [word! integer]
						will indicate what column should be used as a "label" for each row.
		
		
		standard properties:
		----
			labels: [word! string! integer!]
					field names given to your columns.
					-should be equal in number to number of columns
					-trailing undefined columns are simply unlabeled.
			   
			label-column: [word! integer]
					will indicate what column should be used as a "label" for each row.
	
			sort-column: [word! integer]
					will indicate what column should be used for sorting by default.
	
		
		
		NOTES:
			-the header IS NOT an object on purpose.
		
			-in Red it will become a map!
		
	}
	;-  \ documentation
	bulk-test-data: {
		good-bulk: [
			[columns: 3 type: labels: [first second third] date:]
			1 2 3
			4 5 6
			7 8 9
		]
		
		good-header-bulk: [
			[columns: 3]
			1 2 3
			4 5 6
			7 8 9
		]
		
		bad-bulk: [
			[columns: one]
			33 33
		]
	}
	bulk-unit-tests: {
		print ""
		print "------------"
		print "Performing unit tests:"
		print "------------"
		print "is-bulk? good-bulk"
		prin ">> "
		probe is-bulk? good-bulk
		print ""
		
		print "is-bulk?/header good-header-bulk"
		prin ">> "
		probe is-bulk?/header good-header-bulk
		
		print ""
		print "is-bulk? bad-bulk"
		prin ">> "
		probe is-bulk? bad-bulk
		
		print ""
		print "get-bulk-property good-bulk 'labels"
		prin ">> "
		probe get-bulk-property good-bulk 'labels
		print "get-bulk-property good-bulk 'date"
		prin ">> "
		probe get-bulk-property good-bulk 'date
		print "get-bulk-property good-bulk 'type"
		prin ">> "
		probe get-bulk-property good-bulk 'type
		
		print ""
		print "set-bulk-property good-bulk 'type  'number-grid"
		prin ">> "
		probe set-bulk-property good-bulk 'type 'number-grid
		
		print ""
		print "set-bulk-property good-bulk 'date now"
		prin ">> "
		probe set-bulk-property good-bulk 'date now
		
		print "get-bulk-property good-bulk 'type"
		prin ">> "
		probe get-bulk-property good-bulk 'type
		
		print ""
		print "insert-bulk-records good-bulk [11 22 33] 2 "
		prin ">> "
		probe insert-bulk-records good-bulk [11 22 33] 2
		
		print ""
		print "insert-bulk-records good-bulk [111 222 333] none "
		prin ">> "
		probe insert-bulk-records good-bulk [111 222 333] none
		
		
		print ""
		print "get-bulk-row good-bulk 2"
		prin ">> "
		probe get-bulk-row good-bulk 2
		
		
		print ""
		print "probe good-bulk"
		probe good-bulk


		print ""
		print "------------"
		ask "Press Enter to quit"
	}
]




;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'bulk
;
;--------------------------------------


slim/register [

	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- LIBS
	;
	;-----------------------------------------------------------------------------------------------------------
	xmlb: slim/open/expose 'xmlb none [load-xml mold-xml xml-attr-grid]
	slim/open/expose 'utils-encoding none [utf8-win1252 strip-bom]
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- GLOBALS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;--------------------------
	;-     	default-null:
	;
	;--------------------------
	default-null: "#[NULL]"

	
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- BINDINGS
	;
	;-----------------------------------------------------------------------------------------------------------
	; declare words to bind locally to context
	
	;--------------------------
	;-     CSV-CTX: [...]
	;
	; Used to store the transient values of the csv file parser
	;--------------------------
	csv-ctx: context [
		;--------------------------
		;-         .table:
		;
		;--------------------------
		.table: []
		
		;--------------------------
		;-         .row:
		;
		;--------------------------
		.row: []
		
		;--------------------------
		;-         .columns-ctx:
		;
		; used whenever we are given a set of columns to use in select & where clauses.
		;--------------------------
		.columns-ctx: none
		
		
		
		;--------------------------
		;-         tag-row-end:
		;
		; Will add ___ROW-END___ at the end of each rows in the table result
		;--------------------------
		tag-row-end: none
		
		
		;--------------------------
		;-         select/where filtering:
		;
		;--------------------------
		.column-names:  .select-clause:  .where-clause: none
		
		;--------------------------
		;-         line-expressions:
		;
		;--------------------------
		.do-each: .do-every: none		
		
		;--------------------------
		;-         .output-columns:
		;
		;--------------------------
		.output-columns: .extra-columns: .orig-row-columns: none
		
		;--------------------------
		;-         .value:
		;
		;--------------------------
		.value: ""
		
		;--------------------------
		;-         .here:
		;
		;--------------------------
		.here: none
		.txt: none
		
		;--------------------------
		;-         .column-count:
		;
		;--------------------------
		.column-count: none
		.old-column-count: none
		
		;--------------------------
		;-         .line-count:
		;
		;--------------------------
		.line-count: 0
		
		;--------------------------
		;-         flow rules:
		;
		;--------------------------
		=ok=: none
		=fail=: [end skip]

		;--------------------------
		;-         whitespaces:
		;
		;--------------------------
		=space=:	charset [ #" " #"^(A0)" #"^(8D)"   #"^(8F)"   #"^(90)" ]
		=tab=:		charset "^-"
		=spacer=:	union =space= =tab=
		=spacers=:	[some =spacer=]
		=nl=:		[ opt =cr= =lf= (++ .line-count)]
		=cr=:		#"^M"
		=lf=:		#"^/" 
		
		;--------------------------
		;-         collectors:
		;
		;--------------------------
		!collect!: [(append .value .txt)]
		!collect-value!: [(append .row copy .value clear .value)]

		;--------------------------
		;-         =separator=:
		;
		;--------------------------
		=separator=: charset ","

		;--------------------------
		;-         =quoted-chars=:
		;
		;--------------------------
		=quoted-chars=: complement charset {"^/^M} ; note we consider the ^/ directly in the rule, to increment line number
		
		;--------------------------
		;-         =unquoted-chars=:
		;
		;--------------------------
		=unquoted-chars=: complement union =separator= charset {^/^M}

		;--------------------------
		;-         =qvalue=:
		;
		;--------------------------
		=qvalue=: [
			{"} 
			;(print {"})
			any [ 
				 [{""} (append .value {"})]
				| [
					copy .txt some [
						=quoted-chars=  
						| =nl= ;(++ .line-count)
					]
					!collect! 
				]
			]
			{"}
		]
		
		;--------------------------
		;-         =uqvalue=:
		;
		;--------------------------
		=uqvalue=: [
			copy .txt some =unquoted-chars= !collect!
		]

		;--------------------------
		;-         =value=:
		;
		;--------------------------
		=value=: [
			[
			 	=qvalue=  ;(prin "Q  - ")
				| =uqvalue= ;(prin "UQ - ")
				| empty-ptr: [=separator= | crlf | end] (.txt: copy "") :empty-ptr
			]
		]

		;--------------------------
		;-         =row=:
		;
		;--------------------------
		=row=:  [
			=value=  !collect-value! 
			any [
				=separator= ;(print "separator")
				=value= !collect-value!
			]
		]
		
				
		;--------------------------
		;-         =csv=:
		;
		;--------------------------
		=csv=: [
			(=not-eof=: =ok=)
			some [
				.here:
				[
					; note that we do not accumulate blank lines in the result dataset.
					any =spacers= =nl= (
					)
					| [
						=not-eof= =row=
						[  =nl= end  (=not-eof=: =fail=) | (-- .line-count) =nl= | end (=not-eof=: =fail=) ]
						(
							if tag-row-end [
								append .row '___ROW-END___
							]
							.old-column-count: .column-count
							.column-count: length? .row
							all [
								.old-column-count
								.column-count <> .old-column-count
								to-error rejoin ["column count mismatch! (line ".line-count ") was : " .old-column-count  " found : " .column-count ]
							]
							
							
							.qualified?: true
							
							;----------------
							; rebuild expression ctx to run any of the clauses.
							; this is reset at each init.
							;
							; we want to run this only once every csv file.						
							;----------------
							if all [
								.column-names
								not .columns-ctx
							][
								;vprint "====================================="
								;vprint "      COMPILING RUN-TIME QUERY"
								;vprint "====================================="
							
								;----------------
								; we need to build an object version of the .column-names
								; this is to bind the where clause to it.
								;
								; note that we add the full row block which you CAN 
								; manipulate BEFORE running the WHERE clause
								;----------------
								.columns-ctx: copy [.row: .line-count: ]
								.output-columns: copy [] ; columns after select-clause if any.
								.orig-row-columns: copy []
								
								foreach word .column-names [
									append .orig-row-columns  to-word word ; makes sure all column names are words (not string!)
									append .columns-ctx to-set-word word
									append .output-columns to-word word
								]
								foreach word [.do-each .do-every .where-clause][
									;--------
									; add any set words from the expressions within the ctx
									; this way it isolates the expression from the calling code
									; and we can add completely new column values in the result!
									;--------
									append .columns-ctx extract-set-words/only any [get word []]
								]
								
								append .columns-ctx none
								
								.columns-ctx: context .columns-ctx
								bind .orig-row-columns .columns-ctx

								if .select-clause [
									if find .select-clause '* [
										; we must fill-in the columns with all columns not yet
										; listed in the select clause
										
										.extra-columns: exclude .output-columns .select-clause
										;v?? .extra-columns

										replace .select-clause '* .extra-columns
									]
									;v?? .select-clause
									
									.output-columns: .select-clause
								]
								
								foreach word [.do-each .do-every .select-clause .where-clause .output-columns][
									words: get word
									;v?? words
									if words [
										bind get word .columns-ctx
									]
								]


;								if .where-clause [
;									bind .where-clause .columns-ctx
;								]
;								if .do-each [
;									bind .do-each .columns-ctx
;								]
;								if .do-every[
;									bind .do-every .columns-ctx
;								]
;								if .select-clause [
;									bind .select-clause .columns-ctx
;								]

								;v?? .output-columns
								;v?? .select-clause

								;vprint "====================================="
								;vprint "    DONE COMPILING RUN-TIME QUERY"
								;vprint "====================================="
							]
							
							; note that extra columns will be set to none, 
							; before all processing is done, which is very useful.	
							
							;v?? .orig-row-columns
							;v?? .row
							if .orig-row-columns [
								set .orig-row-columns .row
							]
							if .columns-ctx [
								.columns-ctx/.row: .row
								.columns-ctx/.line-count: .line-count
							]

							if .do-every [
								; be careful, you can destroy the .row for all other phases,
								; including data accumulation
								do .do-every
							]
							
							;---------------------------
							;  APPLY WHERE CLAUSE FILTER 
							;---------------------------
							if .where-clause [
								;v?? .where-clause
								.qualified?: do .where-clause
								;if .qualified? [
								;	ask "found one"
								;]
							]
							
							if .qualified? [
								;vprint "-----------------------"
								;vprint "ADDING DATA"
								;vprint "-----------------------"
								;v?? .output-columns
								;v?? .do-each
								if .do-each [
									do .do-each
								]
								
								; setting here allows us to load it back on result to generate the labels properly in the bulk.
								unless .output-columns [
									.output-columns: copy .row
								]
								result-row: reduce .output-columns
								;v?? result-row
								append .table result-row
							]
							
							clear .row  
						)
					]
					;---
				]
				
			]
		]


		;--------------------------
		;-         init()
		;--------------------------
		; purpose:  initialise or reset the parse-ctx
		;
		; inputs:   
		;
		; returns:  
		;
		; notes:    
		;
		; to do:    
		;
		; tests:    
		;--------------------------
		init: func [][
			vin "bulk.r/csv-ctx/init()"
			.table: copy []
			.row: copy []
			.value: copy ""
			.here: none
			.txt: none
			.column-count: none
			.old-column-count: none
			.line-count: 0
			.select-clause:  .column-names:  .where-clause: none
			.do-each: .do-every: none
			.columns-ctx: none
			.output-columns: none

			vout
		]
	]


	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- UTILITY CODE
	;
	;-----------------------------------------------------------------------------------------------------------

	
	;-----------------
	;-     find-same()
	;-----------------
	find-same: func [
		series [block!] "note this is not a bulk input but an arbitrary series type"
		item [series! none! ]
		/local s 
	][
		unless none? item [
			while [s: find series item] [
				if same? first s item [return  s]
				series: next s
			]
		]
		none
	]
	


	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- INSPECTION AND CORE CREATION
	;
	;-----------------------------------------------------------------------------------------------------------

	;-----------------
	;-     make-bulk()
	;
	; create a new bulk 
	;-----------------
	make-bulk: funcl [
		columns [integer! block!] "when a block! is given, it's the names of the columns, columns count header is then set automatically.^/Names can be given in string! or word! type."
		/records data [block!]
		/properties props [block! none!]
	][
		vin "make-bulk()"
		either block? columns [
			bulk: compose/deep [[columns: (length? columns)]]
			column-labels/set bulk columns
		][
			; integer! given
			bulk: compose/deep [[columns: (columns)]]
		]
		if records [
			insert-bulk-records bulk data none
		]
		if props [
			set-bulk-properties bulk props
		]
		vout
		bulk
	]
		
	;-----------------
	;-     is-bulk?
	;
	; returns true if data complies to all required bulk prerequisites (including type)
	;-----------------
	is-bulk?: func [		
		blk 
		/header "Only verify header, content might not match columns number"
		/local cols
	][
		all [
			block? blk
			integer? cols: get-bulk-property blk 'columns
			any [
				header
				0 = mod ((length? blk) - 1) cols
			]
		]
	]
	
	
	;-----------------
	;-     symmetric-bulks?()
	;
	; returns true if both bulks are of same shape.
	;
	; currently this only makes sure both bulks have the same number of columns.
	; eventually, if the bulks have column labels, they should be in the same order.
	;-----------------
	symmetric-bulks?: func [
		blk [block!]
		blk2 [block!]
		/strict "this will trigger a stricter verification (undefined for now)"
	][
		(bulk-columns blk) = (bulk-columns blk2)
	]
	
		
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- FILE i/o FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;--------------------------
	;-     read-data()
	;--------------------------
	; purpose:  Get content string
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    Used by all <FORMAT>-to-bulk() functions
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	read-data: funcl [
		data [string! file! binary!]	"Path of the datafile, or its binary|string content"
		/utf8			"Set if the file is in UTF-8 and needs to be converted to ANSI"
	][
		vin "read-data()"
		data: switch type?/word data [
			file! [
				;---
				; If given a file, read the file to get its content to parse
				;
				; /binary is important because many text formats are actually binary in specification
				;         ex: XML and CSV are NOT text formats, but binary.  there are subtle
				;             details like newlines and encodings which depend of very specific
				;             characters which cannot be mangled.
				;---
				as-string read/binary data
			]
			binary! [
				; If given a binary, convert it to a string for parsing
				as-string data
			]
			string! [
				; If given a string, take it as is
				data
			]
		]
		
		
		if utf8 [ data: utf8-win1252/transcode strip-bom data ]
		;probe stats
		vout
		data
	]
		

	;--------------------------
	;-     parse-csv()
	;--------------------------
	; purpose:  Parses a csv string and returns its data in a block
	;
	; inputs:   a binary loaded string of text
	;
	; returns:  just the table data, not yet in bulk format.
	;
	; notes:    - beware CRLF vs LF they are not treated the same by CSV parser.
	;           - any none! parameter is simply ignored.
	;           - /columns is required when using any of the other refinements.
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	parse-csv: funcl [
		data	[string!]	"The data to parse"
		/columns
			column-names [block! none!] "set the column names for expression part of select/where/every/each expressions."
		/select
			s-clause [block! none!] "must reduce to a list of words which columns in column-names."
		/where  
			w-clause [block! none!]  "Expression to run on each line to qualify in output"
		/every
			do-every [block! none!] "do this for each qualified line"
		/each
			do-each [block! none!] "do this for each qualified line"
	][
		vin "parse-csv()"
		;---
		; We want to reinitialize context between each call
		csv-ctx/init
		
		;v?? w-columns
		;v?? w-clause
		
		csv-ctx/.column-names: column-names
		csv-ctx/.select-clause:  s-clause
		csv-ctx/.where-clause:  w-clause
		csv-ctx/.do-every: do-every
		csv-ctx/.do-each: do-each
		
		unless parse/all data csv-ctx/=csv= [
			to-error rejoin ["bulk/parse-csv : CSV format error here: " copy/part csv-ctx/.here 50 ]
		]
		;v?? csv-ctx/.table
		
		vout
		
		first reduce [ csv-ctx/.table csv-ctx/.table: none ]
	]
	
	;--------------------------
	;-     csv-to-bulk()
	;--------------------------
	; purpose:  Converts a csv string or file to a bulk
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    - we use the csv-ctx values after the call to 'PARSE-CSV
	;
	; to do:    /auto-fill  (use the ___ROW-END___ feature of csv parser to detect non symmetric rows)
	;
	; tests:    
	;--------------------------
	csv-to-bulk: funcl [
		csv-data	[string! file! binary!]	"Path of the csv file, or its binary|string content"
		/no-header	"Will store the first row as bulk labels"
		/quiet 		"do not show warnings"
		/utf8		"Set if the file is in UTF-8 and needs to be converted to ANSI"
		/null		
			null-value  [string!]	"The value to convert to none in the bulk, default is #[NULL]"
		/select 
			select-clause [block!] "chose which columns to return.  If not used, returns all columns"
		/where		
			where-clause [block!]"provide a where clause to filter lines AS WE LOAD them.  this may greatly reduce the memory consumption. uses the same mechanism as select-bulk"
		/every		
			do-every [block!] "do this block for every line in source file, filtered or not"
		/each		
			do-each [block!]"do this block for each row in final bulk (after where clause)"
		;/auto-fill "will fill rows missing data (at end)"
	][
		vin  "csv-to-bulk()"
		csv-data: either utf8 [read-data/utf8 csv-data][read-data csv-data]
		
		; - Data integrity verification
		; If the data has more than one row, it should contain at least one crlf
		; The absence of clrf might indicate a wrong file reading => WARNING
		unless quiet [
			unless find csv-data crlf [
				vprint "==============================================================="
				vprint "WARNING! (csv-to-bulk): No crlf found in data"
				vprint {Please use [to-string read/binary <file-path>] to read the file}
				vprint "If the data contains only one row, you can ignore this warning"
				vprint "==============================================================="
			]
		]
		
		
		
		headers?: not no-header
		
		v?? headers?
		if headers? [
			;vprobe copy/part csv-data 2000
			
			;---
			; Parse first line of file if we need columns
			end-of-line: find/tail csv-data LF
		
		
			if end-of-line [
				;vprint "found linefeed"
				header: copy/part csv-data end-of-line
				
				; we must not read line a second time
				csv-data: end-of-line
				
				;v?? header
				
				
				; remove all new-line characters
				;replace/all header CR ""
				;replace/all header LF ""
				
				header-row: parse-csv header
				forall header-row [
					change  header-row to-word first header-row
				]
			]
		]
		
		;vprobe header-row
		;v?? where-clause
		either where-clause [
			;vprint "WE HAVE A WHERE CLAUSE"
			parsed-result: parse-csv/columns/where/every/each/select csv-data header-row where-clause do-every do-each select-clause
		][
			;vprint "WE HAVE NO WHERE CLAUSE"
			parsed-result: parse-csv/columns/every/each/select csv-data header-row do-every do-each select-clause
		]
		;ask "!!!"
		
		
		cols: length? csv-ctx/.output-columns
		
		;---
		; Add column names to the bulk, take them from the first row
		if headers? [
			;head-row: take/part parsed-result cols
			labels: compose/only [labels: (copy csv-ctx/.output-columns)] ; labels is none when /no-header is used
		]

		;---
		; Manage none values in loaded CSV
		;?? null
		;?? null-value
		null-value: any [null-value default-null]

		;?? null-value
		replace/all parsed-result null-value none
		;---
		; create the bulk 		

		bulk: make-bulk/records/properties cols parsed-result labels
		new-line/skip next bulk true cols
		
		vout
		
		;---
		; cleanup and return
		first reduce [ bulk bulk: none ]

	]
	
	;--------------------------
	;-     bulk-to-csv()
	;--------------------------
	; purpose:  Generate a csv writable string from a bulk
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:
	;	- If the given bulk has a labels property, it is added as the first row
	;   - when /flush is used, copy your original bulk if you need to reuse it after,
	;     cause its header will be modified and you can't go back.
	;
	;	- with /flush, we ALWAYS append to given file, so be sure to clear it before first call to 'BULK-TO-CSV
	;
	;	=CONCERNING THE CSV OUTPUT=
	;	(In following, by 'wrapped, we mean that the content is surrounded by double-quotes ("))
	;	- Content containing at least one of
	;		1. newline (lf)
	;		2. double-quote (")
	;		3. comma (,)
	;	  is wrapped
	;	- All double-quotes (") in a wrapped content are escaped with a double-quote
	;	- The newlines in wrapped content must be a lf and not a crlf
	;		e.g. text^M^/text -> "text^/text"
	;			where (^M^/ = clrf) and (^/ = lf)
	; 	  The rows must end by a crlf (except the last one)
	;	- In all other cases, content appears as is without wrapping
	;	- Examples
	;		{text text}		-> {text text}
	;		{text,text}		-> {"text,text"}
	;		{text^/text}	-> {"text^/text"}
	;		{text^M^/text}	-> {"text^/text"}
	;		{text"text}		-> {"text""text"}
	;		{"text"}		-> {"""text"""}
	; to do:    
	;
	; tests:    
	;--------------------------
	bulk-to-csv: funcl [
		blk						[block!]
		/write-to	output-file [file!] "deprecated, replaced by /in "
		/in    		in-data		[file! string!] "Dump the csv data in given destination (when given file!, we set output-file)"
		/null		null-value  [string!]	"The value to use on none! values present in bulk, default is #[NULL]"
		/no-header 	"Do not output the header row."
		/flush		"Flush the bulk content from memory.  Also header column names, if they where present.^/This is used to dump a csv in a serialization loop,^/we don't want to dump the headers at each part of the dump. when file is given, /flush will assume write/append, so clear it first."
	][
		;vin "bulk-to-csv()"
		
		
		null-value: any [
			null-value
			default-null
		]
		
		result: any [
			all [string? in-data  in-data]
			copy ""
		]
		if file? in-data [
			output-file: in-data
		]
		if all [flush   none? output-file] [
			to-error "Cannot use /flush without also specifying output-file (or in-data as a file!)"
		]
		
		
		; Manage header
		unless no-header [
			if labels: get-bulk-property blk 'labels [
				foreach lbl labels [
					either null-value [
						repend result [to-csv-content/default to-string lbl null-value ","]
					][
						repend result [to-csv-content to-string lbl ","]
					]
				]
				take/last result ; Remove trailing comma
				append result crlf
			]
		]
		
		; Manage content rows
		; <smc> Might not be efficient
		col-nbr: bulk-columns blk
		blk-data: next blk ;skip metadata
		forskip blk-data col-nbr [
			c-row: copy/part blk-data col-nbr
			either null-value [
				foreach cell c-row [
					repend result [to-csv-content/default cell null-value ","]
				]
			][
				forach cell c-row [
					repend result [to-csv-content cell ","]
				]
			]
			take/last result ; Remove trailing comma
			append result crlf
		]
		
		
		; Remove trailing crlf
		;take/last result
		;take/last result 
		
		if output-file [
			either flush [
				write/binary/append output-file to-binary result
			][
				write/binary output-file to-binary result
			]
		]
		
		if flush [
			clear-bulk blk
			remove-bulk-property blk 'labels ; we remove these so they don't get dumped a second time.
		]
		;vout
		
		first reduce [result result: none]
	]
	
	;--------------------------
	;-     to-csv-content()
	;--------------------------
	; purpose:  Takes a string and convert it to a csv valid form
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:   - See documentation of bulk-to-csv() 
	;			- All crlf are converted to lf
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	to-csv-content: funcl [
		content								"Can be any value. none is considered as a NULL value"
		/default null-val	[string!]		"The string to use when a cell has no value (= none) default is #[NULL]"
	][
		;vin "to-csv-content()"
		; Manage args
		case [
			none? content [
				content: any [null-val default-null]
			]
			not string? content [
				content: mold/all content
			]
		]
		
		; this implementation is faster than the tightest parse   ( wrap: parse/all content [ any [=wrap-chars= ]] )
		if find content #"," [
			wrap?: true
		]
		
		if find content #"^"" [
			; Escape double-quotes
			wrap?: true   
			replace/all content {"} {""}
		]
	
		if find content lf [
			; csv cells should only contain Line feeds,
			; so we remove the CR
			replace/all content cr ""
			wrap?: true
		]
		
		if wrap? [
			content: rejoin [{"} content {"}]
		]
		;vout
		
		content
	]
	
	;--------------------------
	;-     xml-to-bulk()
	;--------------------------
	; purpose:  
	;
	; inputs:
	;	- xml-data must be valid XML formatted data
	;	- the content style defines if the content is in attributes or in tags content
	;		->attribute: 
	;			{<Root>
	;				<Table key1="val1" key2="val2" ... />
	;				<Table key1="val1" key2="val2" ... />
	;				...
	;			</Root>}
	;		->content:
	;			{<Root>
	;				<Table><key1>val1</key1><key2>val2</key2>...</Table>
	;				<Table><key1>val1</key1><key2>val2</key2>...</Table>
	;				...
	;			</Root>}
	;
	; returns:  
	;
	; notes:    - It is assumed that the keys are in the same order for each row
	;			- The columns that have a NULL value must have "#[NULL]" and should be in the XML for
	;				each row
	;			- Entries can not have more than one value for a given key! It will not be checked and
	;				will break the conversion
	;
	; to do:    - Specify the columns instead of extracting them from the first row
	;
	; tests:    
	;--------------------------
	xml-to-bulk: funcl [
		xml-data	[string! file! binary! block!]	"Path of the xml file, or its rxml block or its binary|string content"
		
		/wt	wrapping-tag	[word! none!] "Default is Root (See inputs doc)"
		/et element-tag		[word! none!] "Default is Table (See inputs doc)"
		/cs content-style	[word! none!] "attribute|content, default is attribute (See inputs doc)"
		/utf8			"Set if the file is in UTF-8 and needs to be converted to ANSI"
	][
		vin "xml-to-bulk()"
		
		; Manage args
		unless wrapping-tag [wrapping-tag: 'Root]
		unless element-tag [element-tag: 'Table]
		unless content-style [content-style: 'attribute]
		
		; Use xmlb Library to load xml string if not already a block
		loaded-data: either block! = type? xml-data [xml-data][
			loaded-data: either utf8 [load-xml read-data/utf8 xml-data][load-xml read-data xml-data]
		]
		
		; Extract only key-values block for each entry
		unless find loaded-data wrapping-tag [
			; I do not use vprint here because the error should always be displayed
			print ["==========================================================================="]
			print ["ERROR!: There was an error in loading the XML file. Received:^/ " loaded-data]
			print ["Not found ->" wrapping-tag]
			print ["==========================================================================="]
			return none
		]
		values: extract/index loaded-data/:wrapping-tag 2 2
		
		; Example
		; col-values: [texts [one two none four] numbers [1 2 3 4] floats [none none 3.0 4.0]]
		;	-> inexistent values are set to none
		; entry-nbr: 4
		columns-values: copy []
		entry-nbr: 0
		foreach entry values [
			entry-nbr: entry-nbr + 1
			foreach [col-name value-container] entry [
				; Manage columns
				; Get the accumulated values for the current column name
				
				;current-col-values: select columns-values col-name ; <SMC> Doesn't work????
				workaround: find columns-values col-name
				current-col-values: if workaround [second workaround]
				
				unless current-col-values [
					; First time we meet this key
					append columns-values col-name
					; Generate none value for all preceding entries
					current-col-values: copy []
					loop (entry-nbr - 1) [append current-col-values none]
					append/only columns-values current-col-values
				]
				
				; Unpack the current-column value
				value: either content-style = 'content [
					; In content mode, we need to extract the value from the value block
					second value-container
				][
					; Else we take the value as is
					value-container	
				]
				
				; Manage NULL values
				if value = default-null [value: none]
				
				append current-col-values value
				
			]
			
			; Append none to columns that current entry doesn't have
			foreach [key values] columns-values [
				if entry-nbr > length? values [
					append values none
				]
			]
		]
		
		; Generate data to build bulk + remove dots prefix from keys names
		labels: copy []
		data-ptr: copy []
		foreach [key values] columns-values [
			if all [
				#"." = first to-string key
				1 < length? to-string key	; To ignore the '. case
			][key: to-word next to-string key]
			
			append labels key
			append/only data-ptr values
		]
		
		bulk-values: copy []
		repeat entry-i entry-nbr [
			foreach ptr data-ptr [
				repend bulk-values [pick ptr entry-i]
			]
		]
		
		
		column-count: length? labels
		total: length? bulk-values
		rows-nbr: total / column-count
		
		unless rows-nbr // 1 = 0 [
			; Number of rows should be whole
			; Generate debug grid for debugging
			debug-grid: xml-attr-grid loaded-data column-count
			write %debug-grid.rdata mold/all debug-grid
			ask "... GENERATED DEBUG GRID ..."
			; I do not use vprint here because the error should always be displayed
			print ["==========================================================================="]
			print ["ERROR!: Got " rows-nbr " rows -> Can not build bulk"]
			print ["==========================================================================="]
			return none
		]
		
		labels: compose/only [labels: (labels)]
		res-bulk: make-bulk/records/properties column-count bulk-values labels
		
		vout
		res-bulk
	]
	
	;--------------------------
	;-     bulk-to-xml()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  The resulting XML will be formatted as 
	;	{<Root>
	;		<Table key1="val1" key2="val2" ... />
	;		<Table key1="val1" key2="val2" ... />
	;		...
	;	</Root>}
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	bulk-to-xml: funcl [
		blk		[block!]	"The bulk to convert to an XML string"
	][
		vin "bulk-to-xml()"
		; Convert bulk to an xmlb structure
		table-content: []
		labels: get-bulk-property blk 'labels
		col-nbr: get-bulk-property blk 'columns
		entry-content: copy []
		
		ci: 0 ; Current index
		foreach value next blk [
			val-index: (mod ci col-nbr) + 1 ; Int from 1 to col-nbr
			val-lbl: pick labels val-index ; Current label
			
			repend entry-content [to-word val-lbl value]
			
			; Reset accumulator at last entry value
			
			if val-index = col-nbr [
				append table-content compose/only [Table (entry-content)]
				entry-content: copy []
			]
			
			ci: ci + 1
			
		]
		
		rxmlb: compose/only [Root (table-content)]
		
		xml-string: mold-xml rxmlb
		
		vout
		xml-string
	]
		
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- ROW MANIPULATION
	;
	;-----------------------------------------------------------------------------------------------------------
	;--------------------------
	;-     insert-objects()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	insert-objects: funcl [
		blk		[block!]
		records	[block!]
		row		[integer! none!]
	][
		;vin "insert-object()"
		
		; vprint "=== Insert records in bulk: ==="
		blk-cols: column-labels blk
		; v?? blk-cols
		
		foreach record-obj records [
			; vprint "===== NEW OBJECT TO INSERT ======"
			; v?? record-obj
			obj-cols: words-of record-obj
			; v?? obj-cols
			foreach col obj-cols [
				; Add column if not present in bulk
				unless find blk-cols col [
					; vprint ["--> Add col " col " to bulk"]
					add-column blk col
				]
				
			]
			; vprint "== BULK AFTER COLS INSERTION =="
			; v?? blk
			
			; vprint "--> Insert data"
			new-blk-cols: column-labels blk
			new-blk-row: copy []
			foreach col new-blk-cols [
				; if the given object doesn't have the data, we insert null
				val: attempt [get in record-obj col]
				; vprint ["Value found for col " col ": " mold/all val]
				append new-blk-row val
			]
			
			; vprint ["Append row to blk: " mold/all new-blk-row]
			insert-bulk-records blk new-blk-row row
		]
		; vprint "=== State of bulk at the end of the insert process ==="
		; v?? blk
		; ask "... post insert-objects ..."
		;vout
	]
	
	;-----------------
	;-     insert-bulk-records()
	;
	; adds one or more records at given index within a bulk.
	;
	; notes:    makes sure the given data is a full record for given bulk.
	;-----------------
	insert-bulk-records: func [
		blk [block!]
		records [block!]
		row [integer! none!]
		/local cols
	][
		vin "insert-bulk-records()"
		cols: get-bulk-property blk 'columns
		either 0 = mod (length? records) cols [
			either row [
				insert at blk (cols - 1 * row + 1) records
			][
				insert tail blk records
			]
	
			; makes probing much easier to analyse
			new-line at head blk 2 true
			new-line/skip next head blk true cols
		][
			to-error "insert-bulk-row(): record length(s) doesn't match bulk record size."
		]
		vout
		blk
	]
	
	
	;-----------------
	;-     append-bulk-records()
	;
	; adds one or more records at end of a bulk
	;
	; notes:    makes sure the given data is a full record for given bulk.
	;-----------------
	append-bulk-records: funcl [
		blk [block!]
		records [block!]
	][
		insert-bulk-records blk records none
	]
	
	
	;-----------------
	;-     clear-bulk()
	;
	; removes all the records from a bulk, but doesn't change header.
	;-----------------
	clear-bulk: funcl [
		blk [block!]
	][
		;vin [{clear-bulk()}]
		either is-bulk? blk [
			clear at blk 2
		][
			to-error "clear-bulk(): supplied data isn't a valid Bulk block!"
		]
		;vout
	]

	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- COLUMN MANIPULATION
	;
	;-----------------------------------------------------------------------------------------------------------

	;--------------------------
	;-     add-column()
	;--------------------------
	; purpose: Add a column to an already created bulk 
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	add-column: funcl [
		blk [block!]
		col-label	[word! string!]
		/val	col-val		"The value for each already present rows for the new column, default is none"
		/prepend			"Will add the column at the beginning instead than at the end"
	][
		vin "add-column()"
		
		; Fill new column content
		rows-nbr: bulk-rows blk
		cols-nbr: bulk-columns blk
		blk-ptr: next blk	; Skip metadata
		
		either prepend [
			loop (rows-nbr) [
				insert blk-ptr col-val
				blk-ptr: skip blk-ptr cols-nbr
				blk-ptr: next blk-ptr ; Because we added a value, we need to push the pointer
			]
		][
			loop (rows-nbr) [
				blk-ptr: skip blk-ptr cols-nbr
				insert blk-ptr col-val
				blk-ptr: next blk-ptr ; Because we added a value, we need to push the pointer
			]
		]
		
		; Add column label
		new-labels: get-bulk-property blk 'labels
		either prepend [insert new-labels col-label][append new-labels col-label]
		
		; Increment columns number
		cols-nbr: cols-nbr + 1
		set-bulk-property blk 'columns cols-nbr
		
		vout
		
		head blk
	]



	;-----------------
	;-     column-idx()
	;
	; if columns are labeled, return the column index matching specified bulk
	; returns none if no labels or name not in list.
	;-----------------
	get-bulk-labels-index:  ; deprecated name
	;---
	column-idx: funcl [
		blk [block!]
		label [word!]
	][
		vin "column-idx()"
		v?? label
		idx: result: if block? labels: get-bulk-property blk 'labels [
			if labels: find labels label [
				index? labels
			]
		]
		
		v?? idx
		vout
		
		idx
	]

	;-----------------
	;-     column-idx()
	;-----------------
	bulk-column-index: ; deprecated
	;---
	column-idx: funcl [
		blk [block!]
		column [integer! word! none!] "none! will select the default label column."
		/default col [integer!] "If column is a word and property doesn't exist, use this column by default. Normally, we would raise an error."
	][
		vin [{column-idx()}]
		colname: column
		v?? column
		switch type?/word column [
			none! [
				;return the index of the default label column
				if col: get-bulk-property blk 'label-column [
					idx: any [
						all [
							integer? col
							col
						]
						; resolve it from labels
						all [
							word? col
							integer? col: column-idx blk col
							col
						]
					]
				]
			]
			word! [
				;column: column-idx blk column
				idx: if block? labels: get-bulk-property blk 'labels [
					if labels: find labels column [
						index? labels
					]
				]
				if all [
					none? idx
					col
				][
					idx: col
				]
			]
		]
		
		unless integer? idx [
			;to-error rejoin ["BULK/bulk-column-index(): specified column (" colname ") does not equate to an integer value"]
			to-error rejoin ["BULK/bulk-column-index(): specified column (" colname ") doesn't map to a column index"]
		]
		
		if idx > bulk-columns blk [
			to-error rejoin ["BULK/bulk-column-index(): column index cannot be larger than number of columns in bulk: " column]
		]	

		vout
		idx
	]
	
	
	;-----------------
	;-     label-column-idx()
	;
	; returns an integer which identifies what is the label column for this bulk, if any
	; returns none if none is defined.
	;---
	get-bulk-label-column: ; deprecated name
	;-----------------
	label-column-idx: func [
		blk [block!]
		/local col
	][
		column-idx none
	]
	
	


	;-----------------
	;-     bulk-columns()
	;-----------------
	bulk-columns: func [
		blk [block!]
	][
		get-bulk-property blk 'columns
	]
	

	;--------------------------
	;-     column-labels()
	;--------------------------
	; purpose:  return the name of columns for the given bulk
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    will return none if they are not set.
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	column-labels: funcl [
		bulk [block!]
		/set names [block!]
	][
		;vin "column-labels()"
		either set [
			forall names [
				name: first names
				switch/default type?/word name [
					word! [] ; all good nothing to do.
					string! [
						change names to-word name
					]
				][
					to-error "bulk/column-labels/set() : column labels can only be set from string! or word! values"
				]
			]	
			set-bulk-property  bulk 'labels names
		][
			get-bulk-property  bulk 'labels
		]
		;vout
	]


	;-----------------
	;-     search-bulk-column()
	;
	; <to do> replace the search mechanism by my profiled fast-find() algorithm on altme.
	;-----------------
	all*: :all
	search-bulk-column: func [
		blk [block!]
		column [word! integer!] "if its a word, it will get the column from that property (which must exist and be an integer)"
		value
		/same "series must be the exact same value, not a mere equality"
		/row "return row instead of row index"
		/all "value is a block of items to search, output is put in a block."
		/local data columns rdata index
	][
		vin [{search-bulk-column()}]

		column: bulk-column-index blk column

		; generate search index		
		index: extract at next blk column columns
		
		; perform search 
		
		either all [
			; in this mode, we find ALL occurrences which match input, even if they occur more than once
			
			rdata: copy []
			foreach item value [
				until [
					; in this mode, we return the FIRST item found only.
					either  all* [
						same
						series? value
					][
						data: find-same index item
					][
						data: find index item
					]
					
					not if data [
						either row [
							append/only rdata get-bulk-row blk index? data
						][
							append/only rdata index? data
						]
					]
				]
			]
			data: rdata
		][
			; in this mode, we return the FIRST item found only.
			either  all* [
				same
				series? value
			][
				data: find-same index value
			][
				data: find index value
			]
			
			if data [
				either row [
					data: get-bulk-row blk index? data
				][
					data: index? data
				]
			]	
		]
		vout
		index: rdata: value: blk: none
		data
	]
	
	;--------------------------
	;-     set-column()
	;--------------------------
	; purpose:  Set one given column to a given value
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	set-column: funcl [
		blk [block!]
		column [word! integer!]
		value
	][
		vin "set-column()"
		if word! = type? column [column: column-idx blk column]
		
		rows-nbr: bulk-rows blk
		cols-nbr: bulk-columns blk
		blk-ptr: next blk	; Skip metadata
		
		loop (rows-nbr) [
			blk-ptr: skip blk-ptr (column - 1)
			change blk-ptr value
			blk-ptr: skip blk-ptr (cols-nbr - column + 1)
		]
		
		vout
	]
		
			
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- PROPERTY MANIPULATION
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;-----------------
	;-     get-bulk-property
	;-----------------
	get-bulk-property: funcl [
		blk [block!]
		prop [word! lit-word! set-word!]
		/index "return the index of the property set-word: instead of its value"
		/block "return the header at position of property instead of its value"
	][
		all [
			block? hdr: pick blk 1
			hdr: find hdr to-set-word prop
			any [
				all [index index? hdr]
				all [block hdr]
				all [
					not set-word? item: pick hdr 2
					item
				]
			]
		]
	]
	
	
	;-----------------
	;-     set-bulk-property()
	;-----------------
	set-bulk-property: funcl [
		blk [block!]
		prop [word! set-word! lit-word!]
		value
	][
		;prop: to-set-word prop
		if set-word? :value [
			to-error "set-bulk-property(): cannot set property as set-word type"
		]
		; property exists, replace value
		either hdr: get-bulk-property/block blk prop [
			;insert next hdr value ; <SMC> Seems like this line doesn't replace the value ... ?
			change next hdr :value
		][
			; new property
			append first blk reduce [to-set-word prop :value]
		]
		:value
	]
	
	
	;-----------------
	;-     set-bulk-properties()
	;-----------------
	set-bulk-properties: funcl [
		blk [block!]
		props [block!]
	][
		until [
			property: pick props 1
			props: next props
			if set-word? :property [
				value: pick props 1
				; we totally ignore unspecified properties
				unless set-word? :value [
					props: next props
					set-bulk-property blk property value
				]
			]
			tail? props
		]
	]
	
	;--------------------------
	;-     remove-bulk-property()
	;--------------------------
	; purpose:  completely removes a property from the bulk header
	;
	; inputs:   bulk and a property name
	;
	; returns:  
	;
	; notes:    you CANNOT remove the columns: property. (error is raised)
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	remove-bulk-property: funcl [
		bulk [block!]
		prop [word! set-word! lit-word!]
	][
		;vin "remove-bulk-property()"
		prop: to-word prop
		if prop = 'columns [
			to-error "remove-bulk-property()  :  cannot remove COLUMNS property ... it is required by bulk."
		]
		
		if hdr: get-bulk-property/block bulk prop [
			remove/part hdr 2
		]
		;vout
		bulk
	]

		
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- DATA CONVERSION
	;
	;-----------------------------------------------------------------------------------------------------------



	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- DATA QUERY
	;
	;-----------------------------------------------------------------------------------------------------------
	select*: :select ; we don't actually use select in the bulk lib but just in case.
	
	;--------------------------
	;-     select-bulk()
	;--------------------------
	; purpose:  takes a bulk, performs an sql like SELECT statement on it.
	;
	; inputs:   supports a results spec and a where clause .
	;
	; returns:  a bulk which is possibly a subset of the given bulk, it is always a copy
	;
	; notes:    the where-clause block will be bound to the bulk columns so you can do
	;			something like [<col-name> = <some value>]
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	select-bulk: funcl [
		blk [block!]
		/where  where-clause  [block!] ; a "doable" rebol block
		/select select-clause [word! block! integer!]
	][
		vin "bulk.r/select-bulk"
		blk-cp: copy blk ; Copy the bulk because we will remove-each on it
		old-labels: get-bulk-property blk-cp 'labels
		
		;--------------------------
		;-         - Apply where clause
		;
		;--------------------------
		if where [
			
			code: compose/deep/only [
				remove-each (old-labels) next blk-cp [
					not do (where-clause)
				]
			]

			do code
		]
		
		;--------------------------
		;-         - Apply select clause
		;
		;--------------------------
		if select [
			; "Blockify" single word or integer
			select-clause: compose [(select-clause)]
			
			; Convert column labels to column indexes
			forall select-clause [
				if word! = type? first select-clause [
					change select-clause column-idx blk first select-clause 
				]
			]
			
			; Only extract selected columns
			col-nbr:  bulk-columns blk-cp
			new-col-nbr: length? select-clause
			; Using extract here, we loose the meta header
			blk-res-content: extract/index next blk-cp col-nbr select-clause
			
			; Build new labels property
			new-labels: extract/index old-labels col-nbr select-clause
			labels: compose/only [labels: (new-labels)]
			
			; Build filtered bulk
			bulk-res: make-bulk/records/properties new-col-nbr blk-res-content labels
			new-line/skip next bulk-res true new-col-nbr
		]
		
		vout
		
		first reduce [ bulk-res bulk-res: none ]
	]

	;--------------------------
	;-     smc-compare()
	;--------------------------
	; purpose: <smc> my take on the compare implementation 
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	smc-compare: funcl [
		bulk-a [block!]
		bulk-b [block!]
		/where  where-clause  [ block! none! ] "select what rows to include in output (default: all rows)"
		/select select-clause [ block! none! ] {define how the output is generated. (default: none! when ==, rejoin [ a.col "!=" b.col] when different) }
		/default def-value	  "what value to use by default when there is no difference (default: none!)"
	][
		vin "compare-smc()"
		
		;--------------------------
		;-         - Get bulk columns labels
		;	These labels will be used to loop over each bulk
		;--------------------------
		cols-a: column-labels bulk-a
		cols-b: column-labels bulk-b
		; Get bulks columns nbr
		cols-nbr-a: bulk-columns bulk-a
		cols-nbr-b: bulk-columns bulk-b
		
		; Create labels [col1, col2, ...] if inexistent
		unless cols-a [
			cols-a: copy []
			repeat i cols-nbr-a [append cols-a to-word rejoin ["col" i]]
		]
		unless cols-b [
			cols-b: copy []
			repeat i cols-nbr-b [append cols-b to-word rejoin ["col" i]]
		]
		
		; Append bulks labels with a. or b.
		forall cols-a [change cols-a to-word rejoin ["a." first cols-a]]
		forall cols-b [change cols-b to-word rejoin ["b." first cols-b]]
		
		;--------------------------
		;-         - Manage args and generate defaults
		;
		;--------------------------

		; by default, output all rows
		where-clause:   any [ where-clause #[true] ]
		
		; Manage default select-clause
		; default: none! when ==, rejoin [ a.col "!=" b.col] when different
		unless select-clause [
			select-clause: copy []
			;cols-a: [a.col1 a.col2 a.col3]
			;cols-b: [b.first-col b.second-col b.col3 b.col4]
			
			; Use the bulk that has the smallest number of cols
			set [cols-min cols-max] either (length? cols-a) > (length? cols-b) [reduce [cols-b cols-a]][reduce [cols-a cols-b]]
			
			i: 1
			foreach col-min cols-min [
				col-max: pick cols-max i
				r-col: compose/deep [(to-set-word col-min) either (col-min) <> (col-max) [rejoin [(col-min) " != " (col-max)]][(def-value)]]
				new-line r-col true
				append select-clause r-col
				++ i
			]
		]			
		
		v?? select-clause
		
		;--------------------------
		;-         - Generate resut bulk
		;
		;--------------------------
		; Get labels for result bulk
		result-labels: copy []
		
		parse/all select-clause [
			some [
				  set .head-lbl set-word! (append result-labels to-word .head-lbl)
				| skip
			]
		]
		bulk-lbl-prop: compose/only [labels: (result-labels)]
		ctx-words: copy result-labels 
		forall ctx-words [change ctx-words to-set-word first ctx-words ]
		
		;--------------------------
		;-         - Compare each row
		;
		;--------------------------
		; Generate the code that will loop over each bulk and generate result rows
		code: compose/deep [
			context [
				(ctx-words) none ; set all local context words to none (just to declare them in the context)
				
				**i: 1
				foreach [(cols-a)] next bulk-a [
					set cols-b get-bulk-row bulk-b **i 
					++ **i
					
					if (where-clause)[
						res-row: reduce [(select-clause)]
						append result res-row
					]
				]
			]
		]
		
		v?? code
		;---
		; Execute comparing code
		result: make block! (length? result-labels) * bulk-rows bulk-a
		do code
		
		;---
		; Generate the result bulk
		bulk-res: make-bulk/records/properties length? result-labels result bulk-lbl-prop
		vout
		
		first reduce [bulk-res bulk-res: none] ; Return result while freeing memory
	]
	
	
	;--------------------------
	;-     compare-bulk()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	compare-bulk: funcl [
		bulk-a [block!]
		bulk-b [block!]
		/where  where-clause  [block!] "select what rows to include in output (default: all rows)"
		/select select-clause [block!] {define how the output is generated. (default: none! when ==, rejoin [ a.col "!=" b.col] when different) }
		/default def-value	  "what value to use by default when there is no difference (default: none!)"
	][
		vin "compare()"
		
		; by default, output all rows
		where-clause:   any [ where-clause #[true] ]
		
		cols-a: column-labels bulk-a
		cols-b: column-labels bulk-b
		
		;---
		; generate default column names if labels are not explicit in bulks
		unless cols-a [
			cols-a: copy []
			repeat i bulk-columns bulk-a [
				append cols-a to-word rejoin ["col" i]
			]
		]
		unless cols-b [
			cols-b: copy []
			repeat i bulk-columns bulk-b [
				append cols-b to-word rejoin ["col" i]
			]
		]
		
		unless select-clause [
			;---
			; find common columns
			common-columns: intersect cols-a cols-b
			
			;---
			; find specific columns (not used for now)
			;columns-a: exclude cols-a common-columns
			;columns-b: exclude cols-b common-columns
			
			v?? common-columns
			;v?? columns-a
			;v?? columns-b
			
			;---
			; add common columns
			select-clause: copy [
			]
			
			foreach col common-columns [
				clause: reduce [
					;---
					; have fun reading following expression  ;-)
					; it generates something like so :   col1: either a.col1 <> b.col1 [rejoin [a.col1 "!=" b.col1]] [#[none]] 
					to-set-word col 'either a-word: to-word rejoin ["a." col ] to-word "<>" b-word: to-word rejoin ["b." col ] compose/deep [rejoin [(a-word) "!=" (b-word)]] [#[none]]   ;  [ a.col "!=" b.col]
				]
				new-line clause true
				append select-clause clause
			]
			
			;---
			; add bulk-b specific columns 
			v?? select-clause
		]
		?? select-clause
 		; to do
 		
 		; extract set words from select-clause
		; (output-columns)
		output-columns: copy []
		parse/all select-clause [
			some [
				  set .set-word set-word! (append output-columns .set-word)
				| skip
			]
		]
		?? output-columns
		; build a set-word version of cols-b to insert within context to keep binding local ...
		b-setwords: copy column-labels bulk-b
		forall b-setwords [change b-setwords to-set-word first b-setwords]
		?? b-setwords
		
		ctx: none
		
		compiled-query: [
			**i: 1
			ctx: context [
				output: make-bulk/properties length? output-columns compose/only [labels: (output-columns)]
				(b-setwords) ; block of setwords
				(output-columns) ;(select-clause-words) ; block of setwords
				foreach (cols-a) bulk-a [
					set (cols-b) get-bulk-row bulk-b **i 
					++ **i
					
					if do (where-clause) [
						append output reduce (select-clause)
					]
				]
			]
		]
		do compose/deep/only compiled-query
		result: ctx/output
		vout
		
		result
	]




	;-----------------
	;-     filter-bulk()
	; 
	; takes a bulk, performs an sql like select statement on it, supports a results spec and a where clause .
	;
	; the mode is only to allow eventual different search algorithms.
	;-----------------
	filter-bulk: funcl [
		blk [block!]
		mode [word!]     ; currently supports ['simple | 'same],
		spec   [block!] ; expects [column [integer! word! none!] filter [any!]]
		/no-copy-same "when output is the same as input, don't copy the input (may same a lot of ram)"
		;/local filter column columns out data skip?
	][
		vin [{filter-bulk()}]
		columns: bulk-columns blK
		;v?? mode
		;v?? spec
		;v?? blk
		
		
		switch/default mode [
			;------
			;-         -simple
			;------
			simple [
				either all [
					2 = length? spec
					integer? column: column-idx/default blk first spec 1
				][
					filter: second spec
					either any [
						none? filter
						empty? filter
					][
						; this means don't filter anything (keep all).
						either no-copy-same [
							out: blk
						][					
							out: copy-bulk blk
						]
					][
						out: make block! length? blk
						out: insert/only out copy first blk
						
						; skip properties
						blk: next blk
						until [
							either series? data: pick blk column [
								if find data :filter [
									out: insert out copy/part blk columns
								]
							][
								if :data = :filter [
									out: insert out copy/part blk columns
								]
							]
							empty? blk: skip blk columns
						]
					]
				][
					to-error rejoin ["bulk.r/filter-bulk(): invalid spec: " mold/all spec "'"]
				]
			]
			
			
			;------
			;-         -same
			;
			; the spec will be a list of labels to extract from the supplied bulk
			; the strings have to be the very same string, not mere textual equivalents.
			;
			; this allows a bulk with similar, but different strings to return only
			; those which are explicitely specified in the block, even if they have the same
			; text.
			;
			; the bulk may contain a property called 'label-column and it MUST be within
			; columns bounds.  Otherwise, the first column is used by default.
			;------
			same [
				column: column-idx/default blk 'label-column 1
				
				out: make block! length? blk
				out: insert/only out copy first blk
				
				; skip properties
				blk: next blk

				until [
					;print ""
					either series? data: pick blk column [
						;v?? data
						;v?? spec
						if find-same :spec data [
							out: insert out copy/part blk columns
						]
					][
						if :data = :spec [
							out: insert out copy/part blk columns
						]
					]
					empty? blk: skip blk columns
				]
			]


			;------
			;-         -delete-same
			;
			; just like same, but removes the matching spec from the given bulk, instead
			; of creating a new one
			;------
			delete-same [
				vprint "Deleting items found in bulk"
				;---	
				; get label column to search
				column: column-idx/default blk 'label-column 1
				out:    blk
				
				;--
				; skip properties
				blk: next blk

				until [
					skip?: not either series? data: pick blk column [
						;v?? data
						;v?? spec
						if find-same :spec data [
							vprint "found data"
							remove/part blk columns
							true
						]
					][
						if :data = :spec [
							remove/part blk columns
							true
						]
					]
					all [
						skip?
						blk: skip blk columns
					]
					empty? blk
				]
			]
		][
			to-error rejoin ["bulk.r/filter-bulk(): Unrecognized filter mode: '" mode "'"]
		]
		vout
		head out
	]
	
	


	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- UNCLASSIFIED
	;
	;-----------------------------------------------------------------------------------------------------------
	
	
	

	
	
	
	
	;-----------------
	;-     get-bulk-row()
	;
	; rows cannot be retrieved if index is < 1
	;-----------------
	get-bulk-row: func [
		blk [block!]
		row [integer! word!] "Index OR 'last"
		/local cols 
	][
		cols: get-bulk-property blk 'columns
		
		row: switch/default row [
			last [
				;probe "LAST BULK!"
				row: bulk-rows blk
			]
		][row]
		
		all [
			integer? row 
			row > 0
			row: copy/part at blk (row - 1 * cols + 2) cols
			not empty? row
			row
		]
	]
	
	
	
	
	
	;-----------------
	;-     bulk-rows()
	;-----------------
	bulk-rows: func [
		blk [block!]
		/local cols
	][
		vin [{bulk-rows()}]
		cols: get-bulk-property blk 'columns
		;v?? blk
		;v?? cols
		cols: to-integer ((length? next blk) / cols)
		
		vout
		cols
	]
	
	
	;-----------------
	;-     copy-bulk()
	;
	; makes a shallow copy of block, with an independent properties header.
	;-----------------
	copy-bulk: func [
		blk [block!]
	][
		vin [{copy-bulk()}]
		blk: copy blk
		blk/1: copy blk/1
		vout
		blk
	]
	
	
	;-----------------
	;-     sort-bulk()
	;-----------------
	sort-bulk: funcl [
		blk [block!]
		/using sort-column [integer! word! none!] "what column to sort on, none defaults to 'sort-column property or first column if undefined."
	][
		sort-column: any [
			any [
				all [
					integer? sort-column
					sort-column
				]
				; get the sort column from a property in the bulk.
				all [
					word? sort-column
					integer? i: column-idx sort-column
					i
				]
			]
			
			; get the default sort column from a property in the bulk.
			all [
				integer? sort-column: get-bulk-property 'sort-column
				sort-column
			]
			
			; default 
			1
		]
		sort/skip/compare next blk (bulk-columns blk) sort-column
		blk
	]
	
	
	
	
	
	
	;--------------------------
	;-     merge-bulks()
	;--------------------------
	; purpose:  Merge 2 bulks if their number of cols match
	;
	; inputs:   
	;
	; returns:  The merged bulks as one bulk
	;
	; notes:    In case of labeled cols, the ones from the first one are kept
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	merge-bulks: funcl [
		blk1	[block!]
		blk2	[block!]
	][
		vin "merge-bulks()"
		; Args checking
		result: either all [
			valid-b1: is-bulk? blk1
			valid-b2: is-bulk? blk2
			sym: symmetric-bulks? blk1 blk2
		][
			accumulator: copy blk1
			append accumulator next blk2	
		][
			
			print "ERROR! (merge-bulks): The 2 provided bulks are incompatible or wrongly typed"
			blk1-lbls: column-labels blk1
			?? blk1-lbls
			blk2-lbls: column-labels blk2
			?? blk2-lbls
			none
		]
		
		
		vout
		result
	]
	
]







;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

