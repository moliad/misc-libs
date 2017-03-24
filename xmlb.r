REBOL [
	; -- Core Header attributes --
	title: "REBOL XML i/o toolset"
	file: %xmlb.r
	version: 2.0.1
	date: 2013-9-12
	author: "Maxim Olivier-Adlhoch"
	purpose: {Convert XML file to Rebol browsable block structure and back.}
	web: http://www.revault.org/modules/xmlb.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'xmlb
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/xmlb.r

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
		part of this library is Based on xml2rebxml, Copyright ©2005, John Niclasen, NicomSoft.

		ABOUT
		
			
			This file has evolved over many years and has been and is still being used in XML heavy environments with a lot of success.
			
			The structure of the output is extremely easy to use within rebol and can be navigated using standard rebol path notation 
			making it effortless for load > edit > save type scenarios.
	
	
	
		USAGE:
			basically open the lib using slim normally.
			
			all you really need are the LOAD-XML and MOLD-XML functions.
			
			note that you can use /tags to keep the loaded elements as tags, but this cannot be used by mold-xml() right-now.
	
			In most cases, if you don't touch the content, it will generate an EXACT replica of the original file on MOLD-XML().
			Extra line-feeds are always ignored outside of content.
			namespaces or comments may be retained if you use the /qualified or /comments refinements respectively on LOAD-XML()
	
		
		LOAD-XML()
			just provide a string of text to the function and it will return a block of loaded xml for you.
			
			each element follows one of three forms:
			
			1) Attribute only, Closed tag:  in xml it would be  <tag attribute="data"\>
			---
				[tag [.attribute "data"]]  
			
			Note that it has no '.  content attribute.
				
			
			
			2) Element group tag:  in xml it would be  <tag attribute="data"><tag\>
			---
				[tag [.attribute "data" . #[none]] ] 
				
			Note that it has a '. content attribute set to none. this  means it has no text content and may contain 
			any number of sub elements (including none).
			this form still generates tag pairs even if it has no subtags. 
				
			
			
			3) A content tag:  in xml it would be  <tag attribute="data">some content<tag\>
			---
				[tag [.attribute "data" . "some content"]] 

			Note that it has a '.  content attribute set to a string. this means it directly contains 
			a string of text between its tags.  The string may be empty.
				
			when the string is empty, element and content tags are roughly equivalent.
			
			
			Once loaded:
			---
			once you have a block of XML, just probe it and its use will be immediately obvious.
			
			any tag stores ALL of its data within the block which follows it, including any attributes, content or sub elements.
			
			this allows native path access to any part of the xml block.
			
			ex:
			
				Given XML:   
					xml: {<A><B attr1="tadam"><C>I like xmlb!></C><C>Really I do</C></B></A> }                      {}
				
				you can:
					rxml: xmlb/load-xml xml
					>> rxml/a/b/.attr1
					== "tadam"
					
					>> rxml/a/b/c/.
					== "I like xmlb!"
					
					>> foreach [tag data] rxml/a/b [probe tag print data/.]
					'C
					"I like xmlb!"
					'C
					"Really I do"
					
				similarly, editing the rxml is trivial:
				
					>> rxml/a/new-attr: "this is new!"
					>> clear rxml/a/b
					>> mold-xml
					== 
				
			
		MOLD-XML()
			takes a loaded xml block structure and returns a string of text representing it.
			
			if /comment and/or /qualified where used on load-xml, these will find their way back into the
			output file by magic!
			
			Actually, its simple... comments are left as any other tag and namespaces are added as extra issue!
			data in the block which define the namespace of any tag or attribute.  basically the tag name is the same
			but in issue! form and the value is the namespace to use on output.
			
			
			
			
		Important DETAILS:
		--------------
			NO MIXED MODE SUPPORT.  if you try to MOLD-XML data which has both content and sub-elements, one of them will be
			ignored silently.  It will officially never be supported and extremly bad form in any case.
			
			its possible the loader will already complain about such XML on entry, or that it will be added
			later if its not in the version you have received.
			
			There is more cleanup of this file to come.
			

			XML file loading is currently a bit messy since I'm using a two step process, which uses more RAM and CPU than it should.
			
			This allowed me to use a working XML loader written by John Niclasen but simply reformat its structure.
			
			A later version will embed the structure change directly within the XML parser.
			
			The file output on the other hand was completely rebuilt and is VERY fast, but lacks the UTF-8 support which the load provides.
			
			Mold will also be enhanced in a later version.  But this won't be done until I either really need it or
			I get a bit of user feedback and genuine end-user requests.
		
	}
	;-  \ documentation
]



;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'xmlb
;
;--------------------------------------

slim/register [
	xml-error-base: "xml-"

	;- load-xml-callback:
	; if this is set to a function, it will be called at regular intervals, so that you can 
	; track progress of xml-data parsing
	load-xml-callback: none
		
	
	;- xml-length-callback:
	; if this is set to a function, it will be called when xml data processing starts, so that you can 
	; track progress of xml-data parsing
	xml-length-callback: none
	
	
	;- element-load-count:
	;
	; used by the callbacks when converting xml2rebxml data into loaded format.
	;
	element-load-count: 0
	
	
	
	;- xmlxml-items:
	; used by the second step of xml loading, to remember how many items are in the xml.
	xml-items: none
	
	

	;----------------------
	;- rxml
	;----------------------
	rxml: context [
		output:	make block! 10000 ; MOA
		
		xml-header: make string! 1000 ; MOA
		
		; save a pointer to the system load word ; MOA
		*load:  get in system/words 'load ; MOA
		
		preserve-comments: false
		
		namespaces-as-dot: false
		
		lit-slash: to-lit-word "/" 
		empty-tag-end: ## ;MOA
		
		block-begin: to word! "[^/"
		block-end: to word! "^/]"
		attrs:	make block! 20
		;output:	make block! 1000
		input-str: none
		att-data: data: temp: tag-name: att-name: enc-name: c: none
		
		;-- Character Sets
		joinset: func [cset chars] [insert copy cset chars]
		diffset: func [cset chars] [remove/part copy cset chars]
		
		space:	charset [#"^(09)" #"^(0A)" #"^(0D)" #" "]
		char:	charset [#"^(09)" #"^(0A)" #"^(0D)" #" " - #"^(FF)"]
		Letter: charset [
			#"A" - #"Z" #"a" - #"z"
			#"^(C0)" - #"^(D6)" #"^(D8)" - #"^(F6)" #"^(F8)" - #"^(FF)"
		]
		;Digit:	charset [#"0" - #"9"]
		alpha-num:	joinset Letter "0123456789"		; need to allow: Digit
		name-first:	joinset Letter "_:"
		
		NameChar:	joinset alpha-num ".-_:"
		data-chars:	diffset char "<"	; "&<"
		Name:		[name-first any NameChar]
		S:			[some space]
		
		;---------------------------
		;-- XML Rules
		;---------------------------
		document:		[
			(xml-items: 0)
			prolog 
			element 
			; XML LOADING CALLBACK
			to end 			
			clbk-here: (load-xml-callback index? clbk-here)
		]
		
		AttValue:		[
			; we now normalize empty attributes to an empty att-data string
			"'" copy att-data to "'" skip  (att-data: any [att-data copy ""])
			| {"} copy att-data to {"} skip (att-data: any [att-data copy ""])
		]
		
		Comment:		["<!--" copy data to "-->" thru "-->" (
			if preserve-comments [
				insert tail output to-tag rejoin ["!--" data "--"]
				;either empty? output [
					;insert output join "<!--" data
				;][
					;either string? last output [
						;append first back tail output join "<!--" data
					;][
						;insert tail output join "<!--" data
					;]
				;]
			]
			)
		]
		
		PI:				["<?" thru "?>"]
		
		CDSect:			["<![CDATA[" copy data to "]]>" "]]>" (
				if not empty? data [
	;				either string? data [ MOA
	;					insert tail output first parse/all data "^/" MOA
	;				][ MOA
						insert tail output data
	;				] MOA
				]
			)
		]
		
		prolog:			[opt S copy xml-header opt XMLDecl any [Misc | "<!" thru ">"]]
		XMLDecl:		["<?xml" VersionInfo opt EncodingDecl thru "?>"]
		VersionInfo:	[S "version" Eq ["'" VersionNum "'" | {"} VersionNum {"}]]
		Eq:				[opt S #"=" opt S]
		;VersionNum:		[copy temp some NameChar (print ["XML Version:" temp])]
		VersionNum:		[copy temp some NameChar]
		Misc:			[Comment | PI | S]
		
		element:		[
			; XML LOADING CALLBACK
			clbk-here: (
				load-xml-callback index? clbk-here
			)
			Comment
			| 
			
			s-tag 
			
			[
					(
						xml-items: xml-items + 1
					)
				
				"/>" (
					insert tail output to-tag to-url tag-name 
					insert tail output block-begin
					head insert tail output copy/deep attrs
					clear attrs
					insert tail output reduce [ '.  none ] ; just makes the complete data structure consistent. empty tag values are none
					;insert tail output to-url join "etag:" tag-name ; MOA
					insert tail output block-end
					
				)
				| #">" (
					insert tail output to-tag to-url tag-name ; MOA
					insert tail output block-begin
					unless empty? attrs [
						insert tail output attrs
						;append testval attrs
					]
					clear attrs

				)
				
				any content ETag (
					;if empty? data [
						insert tail output block-end
					;]
					;clear data
				)
			]
		]
		
		s-tag:			[
			here: 
			"<" 
			copy tag-name Name 
			any [S Attribute] 
			opt S
		]
		Attribute:		[copy att-name Name Eq AttValue (
				;probe att-data
				replace/all att-data "&quot;" #"^""
				replace/all att-data "&apos;" #"'"
				replace/all att-data "&gt;" #">"
				replace/all att-data "&lt;" #"<"
				replace/all att-data "&amp;" #"&"
				append attrs reduce [to-url att-name copy att-data]
			)
		]
		
		ETag:			["</" copy tag-name Name opt S ">"]
		
		content:		[CDSect | element
			| copy data some data-chars (
				if not empty? data [
					replace/all data "&gt;" #">"
					replace/all data "&lt;" #"<"
					replace/all data "&amp;" #"&"
						insert tail output data
	;				either string? last output [
	;					v?? data
	;					append back tail output data
	;				][
	;				]
				]
			)
		]
		
		Latin-first: charset [#"A" - #"Z" #"a" - #"z"]
		Latin:		joinset Latin-first "0123456789._-"
		
		EncodingDecl:	[S "encoding" Eq [{"} Encname {"} | "'" Encname "'"]]
		Encname:		[copy enc-name [Latin-first any Latin]]
		
		hichar:	charset [#"^(80)" - #"^(FF)"]
		unicode:		[any [
			#"^(00)" copy c char (append input-str c)
			| #"^(C2)" copy c hichar (append input-str c)
			| #"^(C3)" copy c hichar (append input-str (to-char c) + #"^(40)")
			| copy c char (append input-str c)
		]]
		
		;---------------------------
		;-     xml2rebxml
		;---------------------------
		xml2rebxml: func [
			"Parses XML code and returns as block structure"
			code [string!] "XML code to parse"
			/keep-header "loaded xml includes simily header as the first item of schema"
			/preserve "Preserve comments"
			/dot.ns [logic! none!]
			/local data
		][
			vin "xmlb/xml2rebxml()"
			preserve-comments: either preserve [true] [false]
		
			xml-length-callback length? code
		
			self/namespaces-as-dot: not not dot.ns
		
		
			clear output
			clear xml-header
			enc-name: none
		
			parse/all/case code [prolog to end]
		
			either any [
				enc-name = "ISO-8859-1" 
				enc-name = "Windows-1252"
			][
				input-str: code
			][
				input-str: make string! 16384
				clear input-str
				parse/all/case code unicode
			]
			
			clear output
			data: either parse/all/case input-str document [
				;vprobe "xml parsed successfully"
				if all [
					xml-header
					keep-header
				][
					insert head output reduce [<xml2rebxml:doc-header> reduce ['. xml-header]]
				]
					
				*load mold/all output
			][
				none
			]
			vout
			data
		]
		
		
		;--------------------
		;-     strip-ns()
		;--------------------
		strip-ns: func [
			"removes the namespace prefix part of an element name"
			tag [tag! string!]
			/local nse
		][
			
			if nse: find/tail tag ":" [
				either namespaces-as-dot [
					nschar: "."
				][
					nschar: ""
				]
				change/part tag nschar nse
				nse: none
			]
			tag
		]
		
		
		
		
		
	
		;-     missing?
		missing?: func [
			series
			value
		][
			none? find series value
		]
	
	
		
		;-----------------
		;-     append-attribute()
		;-----------------
		append-attribute: func [
			attr [word! url!]
			opt [block!] "options block"
			rblk [block!] "return block"
		][
			vin [{append-attribute()}]
			either attr <> '. [
				
				if all [
					url? attr
					find opt 'qualified
				][
					;probe to-string attr
					insert-qualifier attr tail rblk
				]
				
				attr: to-string attr
				
				strip-ns attr
				
				either find opt 'issue-attr [
					append rblk to-issue attr
				][
					append rblk to-word join "." attr
				]
			][
				append rblk attr
			]
				
							
			vout
		]
		
		
		
	
		;-    
		;- INPUT
		
		
		;-----------------
		;-     qualified?()
		;-----------------
		qualified?: func [
			data [string! tag! issue!]
			/local result
		][
			vin [{xmlb/qualified?()}]
			result: found? find data ":"
			vprobe data
			vout
			result
		]
		
		
		;-----------------
		;-     insert-qualifier()
		;-----------------
		insert-qualifier: func [
			data [string! tag! issue! url!]
			rblk
			/local namespace 
		][
			vin [{xmlb/insert-qualifier()}]
			
			; a name-spaced attribute
			either url? data [
				vprint ["Will add namespaced attribute: " data]
				namespace: copy/part data find data ":"
				insert rblk to-string namespace
				insert rblk to-issue join "." copy find/tail data ":"
			][
				; some other possibly qualified element.
				vprint ["Will add namespaced element: " data]
				namespace: copy/part data find data ":"
				insert rblk to-string namespace
				insert rblk to-issue copy find/tail data ":"
			]
			
			
			vout
		]
		
		
		
		
		;-----------------------------------
		;-     load
		;-----------------------------------
		;
		; options:
		;      tags:       returns elements as tags
		;      issue-attr: attributes are returned as issues instead of .attribute words
		;      comments:   preserves comments as :   [ *** "comment follows tripple star char" ]
		;      qualified:  keep name-spaces (automatically switches on and overides issue-attr and tags)
		;      header:     keeps the header element in the returned xml (if any was provided)
		;
		;-----------------------------------
		load: func [
			xml [string! block!]
			/tags
			/options opt [block!] " [tags header qualified comments] This is the new appropriate way to specify load options.  easier to propagate."
			/keep-header
			/comments
			/qualified
			/dot.ns
			/local xblk rblk item tag attr datatag? 
		][
		vin "xmlb/load()"
			rblk: copy []
			
			
			
			opt: any [opt copy []]


			
			unless options [
				; backwards-compatible refinement handling
				if tags [append opt 'tags]
				if comments [append opt 'comments]
				if keep-header [append opt 'header]
				if qualified [append opt 'qualified]
				if dot.ns [append opt 'dot.ns]
			]

			
			
			
			; makes sure output rebxml format is compatible with namespaces (qualification)
			;if find opt 'qualified [
				;append opt 'tags
				;append opt 'issue-attr
			;]
			
			
			vprint "LOADING XML WITH OPTIONS:"
			vprobe opt
			either string? xml [
				vprobe "xml string to parse"
				xblk: any [
					all [
						find opt 'header
						find opt 'comments
						xml2rebxml/keep-header/preserve/dot.ns xml dot.ns
					]
					all [
						find opt 'header
						xml2rebxml/keep-header/dot.ns xml dot.ns
					]
					all [
						find opt 'comments
						xml2rebxml/preserve/dot.ns xml dot.ns
					]
					
					xml2rebxml xml
				]
				load-xml-callback 0
				xml-length-callback xml-items
				
				element-load-count: 0
			][
				xblk: xml
			]
			
			;vprobe xml
			
			
			vprobe "loaded xml from string"
		;v?? xblk
			
			either none? xblk [
				rblk: "XML ERROR: received data has failed core XML tidyness test.  Possible tag pair mismatch, XML syntax error, or premature EOF."
			][
				
				datatag?: missing? xblk block!
				
				; preset callback stuff
				
				
				foreach item xblk [
					switch/default type?/word item [
						; tags are element names (converted to words by default)
						; tags can only preserve namespace if in tag datatype output
						tag! [
							;---
							; is this a comment?
							either (copy/part item 3) = <!--> [
								;vprint "COMMENT!!!"
								; do we ignore them?
								unless find opt 'comments [
									item: none
								]
								;v?? item
							][
								;-----
								; this is a real element name (not a comment)
								vprobe ["tag: " item]
								element-load-count: element-load-count + 1
								load-xml-callback element-load-count
								
								;vprint "---------------------------------------------"
								;prin rejoin [item  " " element-load-count "/" xml-items]
								; if we find a namespaced item, we cannot convert it to word, so it stays a tag, unless qualified is used in which case namespaces are always removed.
								
								;---------------------------------------
								; v2 -- new qualification method,
								;---
								; if we find a qualified name, we add an issue of the same name as the element
								; to the block, and then put the qualifer as its data.
								; this effectively REPLACES the previous qualification handling, you must still
								; use the 'qualified option
								; 
								
								if all [
									find opt 'qualified
									qualified? item
								][
									vprint [item " is qualified and we want to keep these"]
									insert-qualifier item tail rblk
									
								]
								
								; the item name itself never keeps the namespace. The namespace is stored in an issue
								; of equivalent label
								strip-ns item
								
								; 'qualified opt always triggers tag output, otherwise namespace is always removed
								;unless find opt 'tags [
								item: to-word to-string item
								;]
							]
							
							;---
							; item could be none if it was cancelled via comment ignore
							if item [
								append rblk item
							]
						]
						
						; blocks are groups of elements.
						block! [
							append/only rblk load/options item opt
							
							tag: none ; reset tag name since at this point, the previous tag is done.
						]
						
						; urls are name-spaced attributes.
						url! [
							vprint [" url attribute: " item]
							attr: item
							append-attribute item opt rblk
							
						]
						
						; attributes
						word! [
							vprint [" attribute: " item]
							; remember that we are setting an attribute, for element/attribute data
							
							attr: item
							;append rblk either attr <> '. [ 
							;	 to-issue attr
							;][attr]
							append-attribute item opt rblk
						]
						
						; element/attribute data
						string! [
							if all [none? attr datatag? ][
								append rblk '. 
							]
							if any [attr datatag?][
								append rblk item
							]
		;						any text not after an attribute name is garbage (we only support content in content tags)
		;						[
		;							vprint ["garbage!: {" item "}"]
		;						]
							attr: none
						]
					][
						append rblk item
					]	
				]
		
				if all [
					not find xblk tag!
					not find rblk '.
				][
					append rblk [. ""]
				]
		
				
				new-line/skip rblk on 2
			]
			vout 
			rblk
		]
		
		
		
		
		;------------------------
		;-     load-xml
		;------------------------
		; shortcut to load xml using default setup (unqualified .attribute noheader comments)
		;
		; Note that not all options in LOAD() are usable directly by MOLD-XML().
		; the reason is that MOLD-XML() was rewritten to be much more effective and solve some latent bugs
		; in the older function.
		;
		; at some point the LOAD() will be completely rebuilt and MOLD-XML() will be sync with whatever 
		; features will be available to LOAD() at that point
		;------------------------
		load-xml: func [
			xml-data [string!]
			/options opt [block!] "[tags header qualified str-err issue-attr] newer option specification reduces code and improves speed"
			/keep-header
			/tags
			/comments
			/local data
		][
			vin "xmlb/load-xml()"
			opt: any [opt copy []]
			unless options [
				; backwards-compatible refinement handling
				if tags [append opt 'tags]
				if keep-header [append opt 'header]
				if comments [append opt 'comments]
			]
			
			either block? data: load/options xml-data opt [
				data
			][
				either find opt 'str-err [
					; just a safegard
					to-string data
				][
					data
				]
			]
			vout
			data
		]
	
	
		;------------------------------
		;-     dup-str
		;---
		dup-str: func [value [string!] amount][
			head insert/dup copy "" value amount
		]
	
		;-    
		;- OUPUT
		
		
		
		
		
		
		;--------------------
		;-     get-attributes()
		;--------------------
		get-attributes: func [
			""
			spec
			/local rxml namespace attr
		][
			;print "--->"
			rxml: copy ""
			
			foreach [property value] spec [
				if all [
					word? property
					property <> '. 
					property: to-string property
					#"." = first property
				][
					; check to see if this attribute was qualified!

					either (pick spec -2) = (to-issue property) [
						namespace: pick spec -1
						attr: rejoin ["" namespace ":" to-string next property]
						;v?? attr
					][
						attr: to-string next property
					]
					
					append rxml rejoin [" " attr {="} encode-xml-attr form value {"} ]
				]
			]
			;print "<---"
			rxml
		]
		
		
		;-----------------
		;-     is-group?()
		;
		;
		; is given data an element which includes other data or just has attributes.
		;-----------------
		is-group?: func [
			xml 
			/local item data
		][
			vin [{is-group?()}]
			;v?? xml
			if block? xml [
				foreach [item data] xml [
				;until [
					if any [
						is-element? item
	;					all [
	;						item = '. ; this tag has content.
	;						none? data
	;						probe "!!!!"
	;					]
					][ 
						vout return true
					]
				;	tail? xml: next xml
				]
			]
			
			vout
			false
		]
		
		;-----------------
		;-     is-element?()
		; 
		;  is given data an element <tag> name 
		;-----------------
		is-element?: func [
			w
			/local result
		][
			vin [{is-element?()}]
			result: all [
				#"." <> first to-string w ; this is an attibute or content
				any [
					word? w
					all [
						string? w
						find w ":"
					]
				url? w ; added without testing.
				]
			]
			;v?? w
			vprobe result
			vout
			result
		]
		
		
		;--------------------------
		;-     is-cdata-element?()
		;--------------------------
		; purpose:  
		;
		; inputs:   
		;
		; returns:  
		;
		; notes:    
		;
		; tests:    
		;--------------------------
		is-cdata-element?: funcl [
			w
		][
			vin "is-cdata-element?()"
			result: (#"!" = first to-string w)
			vout
			result
		]
		
		output-string: ""
		
		indents: 0
		
		;-----------------
		;-     has-content?()
		;-----------------
		has-content?: func [
			blk ;[block!]
			/local content
		][
			if all [
				block? blk
				content: select blk '.
				string? content
				;(probe type? content probe ">")
				;not empty? trim/head/tail content
			][
				content
			]
		]
		
		
		
		;-----------------
		;-     emit()
		;-----------------
		emit: func [
			str [string!]
			/only "no newline"
		][
			vin [{emit()}]
			either only [
				append output-string str
			][
				append output-string str: rejoin [
					
					dup-str "^-" indents ; add line indents
					str
					newline
				]
			]
			vout
			str
		]
		
		;-----------------
		;-     indent()
		;-----------------
		indent: func [
		][
			vin [{indent()}]
			indents: indents + 1
			vout
		]
		
		
		
		;-----------------
		;-     outdent()
		;-----------------
		outdent: func [
		][
			vin [{outdent()}]
			indents: indents - 1
			vout
		]
		
		
		
		
		;-----------------
		;-     escape-xml-content()
		;
		; we silently remove Form Feeds from 
		;-----------------
		escape-xml-content: func [
			data [string!]
		][
			vin [{escape-xml-content()}]
			foreach [from to] content-escape-char [
				replace/all data from to
			]
			
			vout
			data
		]
		
		
		
	
		;--------------------------
		;-     encode-xml-content()
		;--------------------------
		; purpose:  
		;
		; inputs:   
		;
		; returns:  
		;
		; notes:    
		;
		; tests:    
		;--------------------------
		encode-xml-content: funcl [
			data [string!]
		][
			vin "encode-xml-content()"
			v?? data
			parse/all data [
				some [
					"<![CDATA["  thru  "]]>" (vprint "skipping cdata")
					|
					content-escape-rules (vprint "escaping cdata")
					|
					copy ltr skip (vprin ltr)
				]
			]
			;v?? data
;			ask "!"
			vout
			data
		]
	
	
	
	
	
		;-----------------
		;-     encode-xml-attr()
		;
		; we silently remove Form Feeds from 
		;-----------------
		encode-xml-attr: func [
			data [string!]
		][
			vin [{encode-xml-attr()}]
			foreach [from to] attr-escape-chars [
				replace/all data from to
			]
			
			vout
			data
		]
		
		
		
		
		
		
		;-----------------
		;-     mold-xml()
		;
		; note that if you use /dot.ns on load-xml, it will preset the mold, to use the same format
		;-----------------
		mold-xml: func [
			xml [block!]
			/sub
			/header hdr [string! tag! none!] "use this header as the output root, none forces no header on output"
			/local attrs mode namespace end-tag tag data content tagname cdata?
		][
			vin [{mold-xml()}]
			
			; Are we in a sub block or at the root of the document?
			either not sub [
				output-string: copy ""
				indents: 0
				
				; document root
				if find xml '. [
					to-error "error! xml may not contain content directly... content must be within a tag!"
				]
				if hdr: any [
					all [
						header
						any [
							hdr
							""
						]
					]
					; default header
					{<?xml version="1.0" encoding="Windows-1252"?>}
					;{<?xml version="1.0" encoding="ANSI"?>}
				][
					unless empty? hdr [
						emit form hdr
					]
				]
				
				mold-xml/sub xml
			][
				; sub element
				until [
					either issue? pick xml 1 [
						; tagname is a a bogus value, just to align the data to an even number (always [ tag data ... ])
						set [tagname namespace tag data] xml
						;end-tag: tag
						;tag: rejoin ["" namespace ":" to-string tag]
					][
						set [tag data] xml
						namespace: none
						tagname: none
					]

					;----
					; remove "!" from tag name (which is used to automatically wrap all data within a CDATA)
					if cdata?: is-cdata-element? tag [
						tag: to-word next to-string tag
					]
					
					if namespaces-as-dot [
						namespace: any [
							namespace ; user may want to replace namesplaces so he put them manually.
							all [
								tagname: find to-string tag "."
								namespace: copy/part tag tagname
								tag: tagname
								namespace
							]
						]
					]
				
					end-tag: tag
				
					; add namespace to the tag part of the element (not end-tag)
					if namespace [
						tag: rejoin ["" namespace ":" to-string tag]
					]
				
				
					;v?? tag
					;v?? end-tag
					;v?? data
					;v?? namespace
					
					;ask "#"

					if is-element? tag [
						;---------------
						; ELEMENT
						attrs: get-attributes data
						;v?? attrs
						;ask "next tag"
						;---
						; write tag
						;prin type? data
					
					
					
						case [
							;---------------
							; GROUP TAG
							; this PREEMPTS CONTENT.  we explicitely do not support mixed-mode XML (content AND sub-elements).
							(is-group? data) [
								;v?? tag
								vprint "is a group element"
;								end-tag: tag
;								probe pick xml -2
;								probe pick xml 1
;								ask "!"
;								if (pick xml -2) = (to-issue tag) [
;									namespace: pick xml -1
;									tag: rejoin ["" namespace ":" to-string tag]
;								]
								
								emit rejoin ["<" tag attrs ">"]
								
								indent
	
								; if our data doesn't have attributes, it will end up in CONTENT block above.
								mold-xml/sub data
								outdent
								
								emit rejoin ["</" end-tag">"]
							]
							
							;---------------
							; CONTENT TAG
							;
							(content: has-content? data) [
;								end-tag: tag
;								
;								if (pick xml -2) = (to-issue tag) [
;									namespace: pick xml -1
;									tag: rejoin ["" namespace ":" to-string tag]
;								]
								
								;empty? trim
								if cdata? [
									content: rejoin [ "<![CDATA[" content "]]>" ]
								]
								either empty? content [
									emit rejoin ["<" tag attrs "></" end-tag">"]
								][
									emit rejoin ["<" tag attrs ">"encode-xml-content content"</" end-tag">"]
								]
							]
						
							;---------------
							; ATTR ONLY TAG
							true [
								vprobe "is an attribute element"
								any [
									all [
										content: select data '.
										not empty? trim content
										emit rejoin ["<" tag attrs ">""</" tag">"]
									]
									emit rejoin ["<" tag attrs " />"]
								]
							]
						]
					]
					tail? xml: skip xml either namespace [4][2]
				]
			]
			vout
			
			output-string
		]
		
	]	; rxml context
	
	
	;- SETUP
	;-     attr-escape-chars:
	attr-escape-chars: [
		#"&" "&amp;"
		#">" "&gt;"
		#"<" "&lt;"
		#"^"" "&quot;" 
		#"'" "&apos;" 
	]
	
	
	;-     content-escape-char:
	content-escape-char: [
		#"&" "&amp;"
		#">" "&gt;"
		#"<" "&lt;"
		#"^L" ""    ; form feed chars often found in PDF and word docs.
		#"^]" ""	; Group separator
		#"^\" ""	; File separator
	]
	
	content-escape-rules: [
		.xml-char-here: 
		[
			#"&"    ( .xml-char-here: change/part .xml-char-here "&amp;" 1 )
			| #"<"  ( .xml-char-here: change/part .xml-char-here "&lt;" 1 )
			| #">"  ( .xml-char-here: change/part .xml-char-here "&gt;" 1 )
			
			; these are ILLEGAL chars in XML and we silently remove them
			| #"^L" (remove .xml-char-here ) ; form feed chars often found in PDF and word docs.
			| #"^]" (remove .xml-char-here ) ; Group separator
			| #"^\" (remove .xml-char-here ) ; File separator
		]
		:.xml-char-here

;		#">" "&gt;"
;		#"<" "&lt;"
;		#"^L" ""    ; form feed chars often found in PDF and word docs.
;		#"^]" ""	; Group separator
;		#"^\" ""	; File separator
	]
	
	
	

	; make values bound to lib.
	to-xml: mold-xml: load-xml: mold-xml-v2: none
	
	;- --INIT--
	--init--: func [][
		to-xml:   get in rxml 'to-xml
		mold-xml: mold-xml-v2: get in rxml 'mold-xml ;  v2 is for backward compatibility in some tools.
		load-xml: get in rxml 'load 
		true
	]
]

;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

