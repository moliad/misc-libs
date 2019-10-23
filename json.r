REBOL [
	; -- Core Header attributes --
	title: "REBOL JSON i/o toolset"
	file: %json.r
	version: 2.0.1
	date: 2013-9-12
	author: "Maxim Olivier-Adlhoch"
	purpose: {Convert XML file to Rebol browsable block structure and back.}
	web: http://www.revault.org/modules/json.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'json
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/json.r

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
		history lost while versions and tools are merged.

		v2.0.1 - 2013-09-12
			-License changed to Apache v2
}
	;-  \ history

	;-  / documentation
	documentation: {
	}
]


;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'json
;
;--------------------------------------

slim/register [
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- LIBS
	;
	;-----------------------------------------------------------------------------------------------------------
	slim/open/expose 'utils-strings none [mold-decimal]


	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- GLOBALS
	;
	; these are needed by the functions within this library
	;-----------------------------------------------------------------------------------------------------------


	;--------------------------
	;-     json-indents:
	;
	;--------------------------
	json-indents: 0
	
	;--------------------------
	;-     .json-value:
	;--------------------------
	.json-value: none
	




	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- PARSE CHARSETS
	;
	;-----------------------------------------------------------------------------------------------------------
	
	;--------------------------
	;-     - character charsets: -
	;--------------------------
	;--------------------------
	;-     =whitespaces=:
	;
	;--------------------------
	=digit=: charset "0123456789"
	=space=: charset [ #" " #"^(A0)" #"^(8D)"   #"^(8F)"   #"^(90)" ]
	=whitespace=: union charset "^-^/" =space=  
	=whitespaces=:  [ some =whitespace= ] ; at least one whitespace
	=whitespaces?=: [ any  =whitespace= ] ; at least one whitespace

	=alphabet=: charset [#"a" - #"z"  #"A" - #"Z"]

	
	
	
	;--------------------------
	;-     - json charsets: -
	;--------------------------
	=field-letter=: union =alphabet= charset "_-!?&*=+|"

	;--------------------------
	;-     =json-string-char=:
	;--------------------------
	=json-string-char=: complement charset {"\}
	
	;--------------------------
	;-     =json-hex=:
	;--------------------------
	=json-hex=: charset "0123456789abcdefABCDEF"

	;--------------------------
	;-     =json-digit-19=:
	;--------------------------
	=json-digit-19=: charset "123456789"



	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- PARSE RULES
	;
	;-----------------------------------------------------------------------------------------------------------




	;--------------------------
	;-     =json-string=:
	;
	;--------------------------
	=json-string=: [
		=whitespaces?=
		{"}
		(.json-string: clear "" ) ; remember to COPY this value within any rule using it.
		any [
			"\" [
				; quotation mark
				  {"} (append .json-string {"})
				; solidus
				| "/" (append .json-string "/")
				
				; reverse solidus
				| "\" (append .json-string "\")

				; backspace
				| "b" (append .json-string #"^H")
				
				; formfeed
				| "f" (append .json-string #"^L")
				
				; newline
				| "n" (append .json-string "^/")
				
				; carriage return
				| "r" (append .json-string #"^M")
				
				; horizontal tab
				| "t" (append .json-string "^-")
				
				; 4 digit hex
				;
				; we keep the escape, since we don't manage it. another layer may do conversion.
				| "u" copy .json-hex 4 =json-hex= (append .json-string join "\u" .json-hex )
				
				; invalid escaped charater.
				| (to-error "invalid JSON data")
			]
		
			; normal text (including literal unicode multipoint characters.
			| copy .json-chars some =json-string-char= (append .json-string .json-chars)
		]
		{"}
		=whitespaces?=
	]


	;--------------------------
	;-     =json-number=:
	;
	;--------------------------
	=json-number=: [
		copy .json-number [
			opt "-"
			[
				[ "0" | [ =json-digit-19= any =digit= ]	]
				opt ["." some =digit= ]
				opt ["e" opt ["+"  | "-"] some =digit= ] ; scientific notation (implies floating point in rebol)
			]
		]
		(
			.json-number: load .json-number
		)
	]


	;--------------------------
	;-     =json-true=:
	;
	;--------------------------
	=json-true=: "true"


	;--------------------------
	;-     =json-false=:
	;
	;--------------------------
	=json-false=: "false"


	;--------------------------
	;-     =json-null=:
	;
	;--------------------------
	=json-null=: "null"


	;--------------------------
	;-     =json-array=:
	;
	;--------------------------
	=json-array=: [
		"[" 
	;	(vprint "")
	;	(vprint "array?")
		(.json-array: json-push copy [])
	;	(vprobe .json-stack)
		opt [
			=json-value=
			(append/only json-top .json-value)
			any [
				"," 
				[
					=json-value=	
					(append/only json-top .json-value)
					
					| 
					.err-here:
					(to-error rejoin ["Invalid JSON here: >" .err-here])
				]
			]
		]
		=whitespaces?= ; this allows empty arrays with spaces in literal
		"]"
	;	(vprint "array!")
	;	(vprobe .json-stack)
		(.json-array: json-pop)
	]


	;--------------------------
	;-     =json-field-name=:
	;
	;--------------------------
	=json-field-name=: [
		=json-string= ( .json-field: copy .json-string ) ":" ( append json-top json-field-name .json-field )
	]
	

	;--------------------------
	;-     =json-field-value=:
	;
	;--------------------------
	=json-field-value=: [
		 =json-field-name=  =json-value= 
		( append/only json-top  .json-value  )
	]
	

	;--------------------------
	;-     =json-object=:
	;
	;--------------------------
	=json-object=: [
		"{"
		(.json-obj-spec: json-push copy [])
	;	(
	;		vprint "object?" 
	;		v?? .json-stack
	;	)
		opt [
			=json-field-value=
			any [
				"," [
					=json-field-value=
					|
					.err-here:
					(to-error rejoin ["Invalid JSON here: >" .err-here])
				]
			]
		]
		=whitespaces?= ; allows empty objects with spaces in literal
		"}"
	;	(
	;		vprint "object!" 
	;		v?? .json-stack
	;	)
		(.json-object: context json-pop )
	]


	;--------------------------
	;-     =json-value=:
	;
	;--------------------------
	=json-value=: [
		=whitespaces?= 
		[
			  =json-string= ( .json-value: copy .json-string)
			| =json-number= ( .json-value: .json-number)
			| =json-object= ( .json-value: .json-object)
			| =json-array=  ( .json-value: .json-array)
			| =json-true=   ( .json-value: #[true])
			| =json-false=  ( .json-value: #[false])
			| =json-null=   ( .json-value: #[none])
		]
		=whitespaces?=
	]


	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------

	;--------------------------
	;-     from-json()
	;--------------------------
	; purpose:  de-serialize from json format to Rebol
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    will eventually support /format mode of to-json
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	from-json: funcl [
		json [string!]
		/extern .json-value
	][
		vin "from-json()"
		
		; make sure there is no left over from previous (errored?) json load
		clear .json-stack
		.json-value: none

		parse/all json =json-value=
		result: .json-value
		vout
		result
	]



	;--------------------------
	;-     escape-json-string()
	;--------------------------
	; purpose:  encode various characters into proper json escape codes
	;--------------------------
	escape-json-string: funct [
		data [string!]
	][
		;vin "escape-json-string()"
		output: copy data
		
		replace/all output "\"  "\\"
		replace/all output "^/" "\n"
		replace/all output "^-" "\t"
		replace/all output "^M" "\r"	;vout
		replace/all output {"} {\"}	;vout
	;	replace/all output {') {\'}	;vout

		output
	]


	;--------------------------
	;-     indent-json()
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
	indent-json: funcl [
	][
		;vin "indent-json()"
		
		copy head insert/dup clear "" "    " json-indents
		;vout
	]


	;--------------------------
	;-     to-json()
	;--------------------------
	; purpose:  
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    
	;
	; to do:   - support the /format 
	;
	; tests:    
	;--------------------------
	to-json: funcl [
		data 
		/recurse "is called from within json library... do not clear json-indents."
		;/format "prefix any Rebol data "
		/extern json-indents
	][
	;	vin "to-json()"
		output: copy ""
		
		unless recurse [
			json-indents: 0
		]
		
		switch/default type?/word data [
			object! [
				not-first?: false
				append output rejoin [ "{^/" (++ json-indents "") indent-json] 
				
				foreach word words-of data [
					if not-first? [
						append output rejoin [",^/" indent-json]
					]
					append output rejoin [
						 {"} word {":} (to-json/recurse get in data word)
					]
					not-first?: true
				]
				-- json-indents
				append output rejoin [ {^/} indent-json "}"  ] 
			]
			
			block! [
				;----
				; outputs a JSON array
				not-first?: false
				
				append output rejoin [ {[} ]
				++ json-indents
				foreach item data [
					if not-first? [
						append output ", "
					]
					append output rejoin [ to-json/recurse item]
					not-first?: true
				]
				-- json-indents
				append output rejoin ["]" ]
			]
			
			string! [
				; escape any string.
				output: rejoin [{"} escape-json-string data {"}]
			]
			integer![
				output: mold data
			] 
			decimal! [
				output: mold-decimal data
			]
		][
			;--
			; form any other value
			output: rejoin [{"} escape-json-string form data {"}]
		]
	;	vout
		output
	]


	;---
	; note we currently do not support unicode conversion directly. 
	; this should be done using an external encoding api
	;---
	.json-stack: []


	;--------------------------
	;-     json-push()
	;--------------------------
	json-push: funcl [
		data 
	][
	;	vin "json-push()"
		append/only .json-stack data
	;	vout
		data
	]


	;--------------------------
	;-     json-top()
	;
	; get top of stack (current item to insert into)
	;--------------------------
	json-top: funcl [
	][
		last .json-stack
	]


	;--------------------------
	;-     json-pop()
	;--------------------------
	json-pop: funcl [
	][
	;	vin "json-pop()"
	;	vout
		take/last .json-stack
	]


	;--------------------------
	;-     json-field-name()
	;--------------------------
	; purpose:  makes sure a string is a valid rebol field name, and fixes it other wise.
	;--------------------------
	json-field-name: funcl [
		field [string!]
	][
		prefix?: false
		
		parse/all field [
			;fix fields starting with a digit
			opt [here: =digit= (insert here "!") ]
			any [
				[=field-letter= | =digit=]
				| here: skip (change here "-")
			]
		]
		to-set-word field
	]


]





;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

