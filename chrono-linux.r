rebol [
	; -- Core Header attributes --
	title: "Chrono - High-precision time measurement"
	file: %chrono-win32.r
	version: 1.0.0
	date: 2016-02-29
	author: "Maxim Olivier-Adlhoch"
	purpose: {Upgraded timing module for windows (which has fallbacks for most high-level functions, using the standard functions)}
	web: http://www.revault.org/modules/chrono.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'chrono-linux
	slim-version: 1.4.0
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/chrono.r

	; -- Licensing details  --
	copyright: "Copyright © 2016 Maxim Olivier-Adlhoch"
	license-type: "Apache License v2.0"
	license: {Copyright © 2016 Maxim Olivier-Adlhoch

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
		v1.0.3 - 2016-02-29
			-creation of this specific platorm port to linux
}
	;-  \ history

	;-  / documentation
	documentation: {
		This lib provides timing functions which are more precise on some systems, or reuse the builtins, when they are sufficient.
		
		This linux version uses the internal functions, cause linux usually provides relatively precise timers with sub millisecond precision.
	}
	;-  \ documentation
]


;------------------------------
; LINUX (32bit) systems
;------------------------------
slim/register [
	;------------------------------
	;--- All others platforms	
	;------------------------------

	get-tick: func [][now/precise]
	tick-lapse: func [tick][difference now/precise tick]

	chrono-time: :now
	time-lapse: :dt
]

;	
;=====================================================
;                     TESTS
;=====================================================
; un-comment to test library
;comment [
;	probe time-lapse [print "."]
;	probe time-lapse [prin "."]
;	probe time-lapse [sine 45]
;	probe time-lapse [wait 1.75] ; this highlights how imprecise the rebol timers really are on windows!
;	ask "!"
;]
