rebol [
	; -- Core Header attributes --
	title: "Chrono - High-precision time measurement"
	file: %chrono.r
	version: 1.0.3
	date: 2013-9-12
	author: "Maxim Olivier-Adlhoch"
	purpose: {Upgraded timing module for windows (which has fallbacks for most high-level functions, using the standard functions)}
	web: http://www.revault.org/modules/chrono.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'chrono
	slim-version: 1.2.1
	slim-prefix: none
	slim-update: http://www.revault.org/downloads/modules/chrono.r

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
		v1.0.3 - 2013-09-12
			-license changed to Apache v2
}
	;-  \ history

	;-  / documentation
	documentation: {
		This lib provides routines & utility functions for VERY precise counters on MS Windows 2000 and up.
		
		On other platforms we just give normal REBOL precision equivalents.  If you have equivalent functions
		for other platforms, please inform me and I'll add them here.
		
		note the library has not been updated to use the slut engine for its tests.
	
		REQUIRES rebol v2.7.8 on non windows platforms.
	}
	;-  \ documentation
]


;------------------------------
; MICROSOFT WINDOWS(r) systems
;------------------------------
either system/version/4 = 3 [

	slim/register [
		;=====================================================
		;                     libs
		;=====================================================
		k32-lib: load/library join to-rebol-file get-env "systemroot" %"/system32/Kernel32.dll"
		
		
		
		;=====================================================
		;                     structs
		;=====================================================
		; MSDN docs here: http://msdn.microsoft.com/en-us/library/aa383713%28VS.85%29.aspx
		i64-struct: make struct! [
			low [integer!]
			hi [integer!]
		] [ 0 0]
		
		
		
		;=====================================================
		;                     routines
		;=====================================================
		QueryPerformanceCounter: make routine! compose/deep [
			; MSDN docs here: http://msdn.microsoft.com/en-us/library/ms644904%28v=VS.85%29.aspx
			time-ptr [struct* [(first i64-struct)]]
			return: [integer!]
		] k32-lib "QueryPerformanceCounter"
		
		QueryPerformanceFrequency: make routine! compose/deep [
			time-ptr [struct* [(first i64-struct)]]
			return: [integer!]
		] k32-lib "QueryPerformanceFrequency"
		
		
		;=====================================================
		;                     functions
		;=====================================================
		;-----------------
		;-    i64-to-float()
		;	
		; this is an internal routine and should not be called directly.
		;-----------------
		i64-to-float: func [
			i64 [struct!]
		][
			either negative? i64/low [
				(i64/hi * 4294967296.0) + 2147483648.0 + (i64/low AND 2147483647 ) ; {}
			][
				(i64/hi * 4294967296.0) + (i64/low)
			]
		]
		
		
		;-----------------
		;-    get-tick()
		;
		; this is an internal routine and should not be called directly.
		;-----------------
		;
		; CAUTION! no error checking done for speed reasons. 
		;
		; QueryPerformanceCounter actually returns 0 when an error occurs or non-zero otherwise. 
		; if there is no performanceCounter, the lib will fail anyways, when GLOBAL_TICK-RESOLUTION is 
		; set.
		;
		; so its pretty safe even if we don't do any check on the return value of the routine.
		;-----------------
		get-tick: func [/local s][
			s: make struct! first i64-struct [0 0]
			QueryPerformanceCounter s
			i64-to-float s
		]
		
		
		;-----------------
		;-    get-tick-resolution()
		;
		; this is an internal routine and should not be called directly.
		;-----------------
		get-tick-resolution: func [/local s][
			s: make struct! first i64-struct [0 0]
			if 0 = QueryPerformanceFrequency s [
				to-error "NO performance counter on this system"
			]
			reduce [ s/hi s/low]
		]
		
		;-----------------
		;-    time-lapse()
		;
		; note that we do not set the processor/thread affinity and this COULD lead to 
		; different CPUS returning different counter values
		;
		; multi-core CPUS  use the same clock for all cores, so for the vast 
		; majority of cases, this simple func is ok.
		;
		; AFAIK, the BIOS or HAL should synchronise both clocks (or always return the 
		; clock for the same CPU), but some multi-processor motherboards might have issues.
		;-----------------
		time-lapse: funcl [
			blk [block!]
		][
			start: get-tick
			do blk
			; return diff in seconds
			to-time ((get-tick - start) / GLOBAL_TICK-RESOLUTION)
		]
		
		
		;-----------------
		;-    chrono-time()
		;-----------------
		chrono-time: func [
		][
			GLOBAL_CHRONO-TIMED + to-time ((get-tick - GLOBAL_CHRONO-INITIAL-TICK) / GLOBAL_TICK-RESOLUTION)
		]
		
		
		
		
		;=====================================================
		;                     GLOBALS
		;=====================================================
		; used for converting to time 
		GLOBAL_TICK-RESOLUTION: second get-tick-resolution
		
		; used to provide more precise time via chrono-time
		GLOBAL_CHRONO-TIMED: now/precise
		GLOBAL_CHRONO-INITIAL-TICK: get-tick
	
	]
][
	slim/register [
		;------------------------------
		;--- All others platforms	
		;------------------------------
	
	
		chrono-time: :now
		time-lapse: :dt
	]
]	
	
;=====================================================
;                     TESTS
;=====================================================
; un-comment to test library
comment [
	probe time-lapse [print "."]
	probe time-lapse [prin "."]
	probe time-lapse [sine 45]
	probe time-lapse [wait 1.75] ; this highlights how imprecise the rebol timers really are on windows!
	ask "!"
]
