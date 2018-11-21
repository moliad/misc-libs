REBOL [
	; -- Core Header attributes --
	title: {BULK | record based, table engine using a flat block.}
	file: %bulk.r
	version: 1.0.0
	date: 2013-9-12
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
			[columns: [integer!]]  
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
			[columns: 3 type: labels: ['first 'second 'third] date:]
			1 2 3
			4 5 6
			7 8 9
		]
		
		good-header-bulk: [
			[columns: 4]
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

	xmlb: slim/open/expose 'xmlb none [load-xml mold-xml]
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- PARSING RULES
	;
	;-----------------------------------------------------------------------------------------------------------
	
	
	
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
		;-         tag-row-end:
		;
		; Will add ___ROW-END___ at the end of each rows in the table result
		;--------------------------
		tag-row-end: none
		

		
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
			some [ 
				  [{""} (append .value {"})]
				| [
					copy .txt 
					some [
						=quoted-chars=  
						| =lf= (++ .line-count)
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
			]
			;(print .value)
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
			some [
				.here:
				;(print .here)
				;(print first .here)
				[
					[
						=row= (print "END ROW")
						[ =nl= | end ]
						(
							
							if tag-row-end [
								append .row '___ROW-END___
							]
							;++ .line-count
							.old-column-count: .column-count
							.column-count: length? .row
							(?? .column-count)
							
							all [
								.old-column-count
								.column-count <> .old-column-count
								to-error rejoin ["column count mismatch! (line ".line-count ") was : " .old-column-count  " found : " .column-count ]
							]
							;?? .column-count
							;.column-count: 
							append .table .row 
							clear .row  
							;probe "____ROW____"
						)
					]
					;---
					; note that we do not accumulate blank lines in the result dataset.
					| opt =spacers= =nl= (
						;++ .line-count
						;probe "____BLANK LINE____" 
					)
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
				to-string read/binary data
			]
			binary! [
				; If given a binary, convert it to a string for parsing
				to-string data
			]
			string! [
				; If given a string, take it as is
				data
			]
		]
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
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	parse-csv: funcl [
		data	[string!]	"The data to parse"
	][
		vin "parse-csv()"
		;---
		; We want to reinitialize context between each call
		csv-ctx/init
		
		unless parse/all data csv-ctx/=csv= [
			to-error rejoin ["bulk/parse-csv : CSV format error here: " copy/part csv-ctx/.here 50 ]
		]
		
		v?? csv-ctx/.table
		
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
		csv-data	 [string! file! binary!]	"Path of the csv file, or its binary|string content"
		/no-header	    "Will store the first row as bulk labels"
		;/auto-fill  "will fill rows missing data (at end)"
	][
		vin  "csv-to-bulk()"
		csv-data: read-data csv-data
		v?? csv-data
		
		; - Data integrity verification
		; If the data has more than one row, it should contain at least one crlf
		; The absence of clrf might indicate a wrong file reading => WARNING
		unless find csv-data crlf [
			vprint "==============================================================="
			vprint "WARNING! (csv-to-bulk): No crlf found in data"
			vprint {Please use [to-string read/binary <file-path>] to read the file}
			vprint "If the data contains only one row, you can ignore this warning"
			vprint "==============================================================="
		]
		
		parsed-result: parse-csv csv-data
		
		
		cols: csv-ctx/.column-count
		v?? cols
		
		;---
		; Add column names to the bulk, take them from the first row
		unless no-header [
			head-row: take/part parsed-result cols
			forall head-row [
				change  head-row to-lit-word first head-row
			]
			labels: compose/only [labels: (head-row)] ; labels is none when /no-header is used
		]

		v?? parsed-result
		v?? labels
		ask "!"

		;---
		; create the bulk 		
		bulk: make-bulk/records/properties cols parsed-result labels
		vprobe type? bulk
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
		/write-to	output-file [file!]
		/no-header "Do not output the header row."
	][
		result: ""
		
		vin "bulk-to-csv()"
		
		; Manage header
		unless no-header [
			if labels: get-bulk-property bulk-test 'labels [
				foreach lbl labels [
					repend result [to-csv-content to-string lbl ","]
				]
				remove back tail result ; Remove trailing comma
				append result crlf
			]
		]
		
		; Manage content rows
		; <smc> Might not be efficient
		col-nbr: bulk-columns blk
		blk-data: next blk ;skip metadata
		forskip blk-data col-nbr [
			c-row: copy/part blk-data col-nbr
			foreach cell c-row [
				repend result [to-csv-content cell ","]
			]
			remove back tail result ; Remove trailing comma
			append result crlf
		]
		
		remove back tail result
		remove back tail result ; Remove trailing crlf
		
		if write-to [
			write/binary output-file to-binary result
		]
		vout
		
		result
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
		content	[string!]
	][
		;vin "to-csv-content()"
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
	; inputs:   Valid XML formatted as
	;	{<Root>
	;		<Table key1="val1" key2="val2" ... />
	;		<Table key1="val1" key2="val2" ... />
	;		...
	;	</Root>}
	;
	; returns:  
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	xml-to-bulk: funcl [
		xml-data	[string! file! binary!]	"Path of the xml file, or its binary|string content"
	][
		vin "xml-to-bulk()"
		; Use xmlb Library to load xml string
		loaded-data: load-xml read-data xml-data
		; Extract only key-values block for each entry
		values: extract/index loaded-data/Root 2 2
		
		; Generate labels
		labels: none
		lbl-lit-words: copy []
		bulk-valid-values: copy []
		column-count: 0
		foreach entry values [
			foreach [key value] entry [
				unless labels [
					; On first entry, generate labels...
					append lbl-lit-words to-lit-word key
					; ...and count columns number
					column-count: column-count + 1
				]
				append bulk-valid-values value
			]
			labels: compose/only [labels: (lbl-lit-words)]
		]
		
		res-bulk: make-bulk/records/properties column-count bulk-valid-values labels
		
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
	

	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- COLUMN MANIPULATION
	;
	;-----------------------------------------------------------------------------------------------------------

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
	;-     column-idx()
	;
	; if columns are labeled, return the column index matching specified bulk
	; returns none if no labels or name not in list.
	;-----------------
;	get-bulk-labels-index:  ; deprecated name
;	;---
;	column-idx: func [
;		blk [block!]
;		label [word!]
;		/local labels
;	][
;		vin "column-idx()"
;		v?? label
;		idx: result: if block? labels: get-bulk-property blk 'labels [
;			if labels: find labels label [
;				index? labels
;			]
;		]
;		
;		v?? idx
;		vout
;		
;		idx
;	]


	;-----------------
	;-     bulk-columns()
	;-----------------
	bulk-columns: func [
		blk [block!]
	][
		get-bulk-property blk 'columns
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
		
			
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- PROPERTY MANIPULATION
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;-----------------
	;-     get-bulk-property
	;-----------------
	get-bulk-property: func [
		blk [block!]
		prop [word! lit-word! set-word!]
		/index "return the index of the property set-word: instead of its value"
		/block "return the header at position of property instead of its value"
		/local hdr item
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
	set-bulk-property: func [
		blk [block!]
		prop [word! set-word! lit-word!]
		value
		/local hdr
	][
		prop: to-set-word prop
		if set-word? value [
			to-error "set-bulk-property(): cannot set property as set-word type"
		]
		; property exists, replace value
		either hdr: get-bulk-property/block blk prop [
			insert next hdr value
		][
			; new property
			append first blk reduce [to-set-word prop value]
		]
		value
	]
	
	
	;-----------------
	;-     set-bulk-properties()
	;-----------------
	set-bulk-properties: func [
		blk [block!]
		props [block!]
		/local property value
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
	;-         	select()
	;--------------------------
	; purpose:  takes a bulk, performs an sql like SELECT statement on it.
	;
	; inputs:   supports a results spec and a where clause .
	;
	; returns:  a bulk which is possibly a subset of the given bulk, it is always a copy
	;
	; notes:    
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	select: funcl [
		blk [block!]
		/where  where-clause  [block!] ; expects [column [integer! word! none!] filter [any!]]
		/select select-clause [word! block! integer!]
	][
		
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
		v?? mode
		v?? spec
		v?? blk
		
		
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
	sort-bulk: func [
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
					integer? sort-column: get-bulk-property sort-column
					sort-column
				]
			]
			
			; get the sort column from a property in the bulk.
			all [
				integer? sort-column: get-bulk-property 'sort-column
				sort-column
			]
			
			; default 
			1
		]
		sort/skip/compare blk (bulk-columns blk) sort-column
		blk
	]
	
	
	
	
	
	
	;-----------------
	;-     insert-bulk-records()
	;-----------------
	insert-bulk-records: func [
		blk [block!]
		records [block!]
		row [integer! none!]
		/local cols
	][
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
	]
	
	
	;-----------------
	;-     add-bulk-records()
	;-----------------
	add-bulk-records: func [
		blk [block!]
		records [block!]
	][
		insert-bulk-records blk records none
	]
	
	
	
	
	;-----------------
	;-     make-bulk()
	;-----------------
	make-bulk: func [
		columns
		/records data [block!]
		/properties props [block! none!]
		/local blk
	][
		vin "make-bulk()"
		blk: compose/deep [[columns: (columns)]]
		if records [
			insert-bulk-records blk data none
		]
		if props [
			set-bulk-properties blk props
		]
		vout
		blk
	]
	
	;-----------------
	;-     clear-bulk()
	;
	; removes all the records from a bulk, but doesn't change header.
	;-----------------
	clear-bulk: func [
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
			is-bulk? blk1
			is-bulk? blk2
			symmetric-bulks? blk1 blk2
		][
			accumulator: copy blk1
			append accumulator next blk2	
		][
			print "ERROR! (merge-bulks): The 2 provided bulks are incompatible or wrongly typed"
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

