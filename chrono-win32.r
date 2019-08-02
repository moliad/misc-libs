rebol [
	; -- Core Header attributes --
	title: "Chrono - High-precision time measurement"
	file: %chrono-win32.r
	version: 1.0.4
	date: 2013-9-12
	author: "Maxim Olivier-Adlhoch"
	purpose: {Upgraded timing module for windows (which has fallbacks for most high-level functions, using the standard functions)}
	web: http://www.revault.org/modules/chrono.rmrk
	source-encoding: "Windows-1252"
	note: {slim Library Manager is Required to use this module.}

	; -- slim - Library Manager --
	slim-name: 'chrono-win32
	slim-version: 1.4.0
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
			
		v1.0.4 - 2019-06-23		
			- now requires slim v1.4.0 which improves binding of set-words
			- integrated library to slut and little cleanup of the code.
}
	;-  \ history

	;-  / documentation
	documentation: {
		;------------------------------
		; this version of the lib only works under
		;
		; MICROSOFT WINDOWS(r) systems
		;------------------------------

		This lib provides routines & utility functions for VERY precise counters on MS Windows 2000 and up.
		
		On other platforms we just give normal REBOL precision equivalents.  If you have equivalent functions
		for other platforms, please inform me and I'll add them here.
		
		note the library has not been updated to use the slut engine for its tests.
	
		REQUIRES rebol v2.7.8 on non windows platforms.
	}
	;-  \ documentation
]




;--------------------------------------
; unit testing setup
;--------------------------------------
;
; test-enter-slim 'chrono-win32
;
;--------------------------------------
slim/register [
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- LIBS
	;
	;-----------------------------------------------------------------------------------------------------------
	k32-lib: load/library join to-rebol-file get-env "systemroot" %"/system32/Kernel32.dll"
	


	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- STRUCTS
	;
	;-----------------------------------------------------------------------------------------------------------
	; MSDN docs here: http://msdn.microsoft.com/en-us/library/aa383713%28VS.85%29.aspx
	i64-struct: make struct! [
		low [integer!]
		hi [integer!]
	] [ 0 0 ]
	
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- ROUTINES
	;
	;-----------------------------------------------------------------------------------------------------------
	QueryPerformanceCounter: make routine! compose/deep [
		; MSDN docs here: http://msdn.microsoft.com/en-us/library/ms644904%28v=VS.85%29.aspx
		time-ptr [struct* [(first i64-struct)]]
		return: [integer!]
	] k32-lib "QueryPerformanceCounter"
	
	QueryPerformanceFrequency: make routine! compose/deep [
		time-ptr [struct* [(first i64-struct)]]
		return: [integer!]
	] k32-lib "QueryPerformanceFrequency"
	
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- FUNCTIONS
	;
	;-----------------------------------------------------------------------------------------------------------

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
	; this is an internal routine and its return value should not be inspected, 
	; it may be implemented in various ways (using various types) accross platform.
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
	; clock for the same CPU), but some multi-CPU motherboards might have issues.
	;
	; tests:
	;		test-group [] [
	;			[time? time-lapse [print "."]]
	;			[time? time-lapse [prin "."]]
	;			[time? time-lapse [sine 45]]
	;			[time? time-lapse [wait 1.75]] ; this highlights how imprecise the rebol timers really are on windows!
	;		]
	;-----------------
	time-lapse: funcl [
		blk [block!]
	][
		start: get-tick
		do blk
		; return diff in seconds
		to-time ((get-tick - start) / GLOBAL_TICK-RESOLUTION)
	]
	
	
	
	
	;--------------------------
	;-    tick-lapse()
	;--------------------------
	; purpose:  returns time since given tick
	;
	; inputs:   
	;
	; returns:  
	;
	; notes:    we don't yet handle counter wrap-around
	;
	; to do:    
	;
	; tests:    
	;--------------------------
	tick-lapse: funcl [
		tick [decimal!]
	][
		to-time ((get-tick - tick) / GLOBAL_TICK-RESOLUTION)
	]
	
	
	;--------------------------
	;-    chrono-time()
	;--------------------------
	; purpose:  returns a precise current time based on cpu frequency counter.
	;
	; notes:    we don't yet handle frequency counter wrap-around (when/if it gets past 64 bits, it starts again at 0)
	;--------------------------
	chrono-time: funcl [
	][
		GLOBAL_CHRONO-TIMED + to-time ((get-tick - GLOBAL_CHRONO-INITIAL-TICK) / GLOBAL_TICK-RESOLUTION)
	]
	
	;--------------------------
	;-    start-laps()
	;--------------------------
	; purpose:  reset lap time counter global start
	;
	; notes:    also resets last lap time (obviously)
	;--------------------------
	start-laps: funcl [
		/extern GLOBAL_LAST-LAP-TIME  GLOBAL_LAP-START-TIME
	][
		GLOBAL_LAP-START-TIME: chrono-time
		GLOBAL_LAST-LAP-TIME: GLOBAL_LAP-START-TIME
	]
	
	;--------------------------
	;-    lap()
	;--------------------------
	; purpose:  time since last call to lap or START-LAPS
	;
	; notes:    this is useful to time each part of a process, just call lap between them.
	;--------------------------
	lap: funcl [
		/extern GLOBAL_LAST-LAP-TIME  
	][
		now: chrono-time
		;?? now
		;?? GLOBAL_LAST-LAP-TIME
		rval: difference now GLOBAL_LAST-LAP-TIME  ; ((now - GLOBAL_LAST-LAP-TIME) / GLOBAL_TICK-RESOLUTION)
		GLOBAL_LAST-LAP-TIME: now
		rval
	]
	
	;--------------------------
	;-    laps-time()
	;--------------------------
	; purpose:  get total time elapsed from START-LAPS to last call to LAP
	;--------------------------
	laps-time: funcl [][
		rval: difference  GLOBAL_LAST-LAP-TIME GLOBAL_LAP-START-TIME ; to-time (( GLOBAL_LAST-LAP-TIME - GLOBAL_LAP-START-TIME ) / GLOBAL_TICK-RESOLUTION)
	]
	
	
	
	;-                                                                                                       .
	;-----------------------------------------------------------------------------------------------------------
	;
	;- GLOBALS
	;
	; globals at the end cause we need the functions to be defined to setup default and reference values
	;-----------------------------------------------------------------------------------------------------------

	; used for converting to time 
	GLOBAL_TICK-RESOLUTION: second get-tick-resolution
	
	; used to provide more precise time via chrono-time
	GLOBAL_CHRONO-TIMED: now/precise
	GLOBAL_CHRONO-INITIAL-TICK: get-tick

	GLOBAL_LAP-START-TIME: chrono-time
	GLOBAL_LAST-LAP-TIME: chrono-time
	


]


;------------------------------------
; We are done testing this library.
;------------------------------------
;
; test-exit-slim
;
;------------------------------------

