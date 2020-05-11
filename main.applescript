(* INPUT PROCESSOR *)
on alfred_script(q)
	try
		set query to q
		if q starts with (character id 128284) then
			if (count of q) > 2 then
				set query to text ((offset of " " in q) + 1) thru -1 of q
			end if
			quickAdd(query)
		else if q starts with (character id 128285) then
			if (count of q) > 2 then
				set query to text ((offset of " " in q) + 1) thru -1 of q
			end if
			topAdd(query)
		else if q starts with (character id 9202) then
			topAdd(q)
		else if q starts with (character id 9203) then
			addFiveMinutes()
		else if q starts with (character id 9989) then
			completeTask()
		else if q starts with (character id 9199) then
			pauseResumeTask()
		else if q starts with (character id 127786) then
			clearList()
		else if q is not "" then
			topAdd(q)
		end if
	on error errorMessage
		display notification "Error: " & errorMessage & q
	end try
end alfred_script

(*** ACTIONS ***)

-----------------------------
-- Action: Add Top Task
-----------------------------
on topAdd(query)
	set APPNAME to "Effortless"
	set newQuery to addTimeToQuery(query)
	launchApp(APPNAME)
	tell application "System Events"
		tell application process APPNAME
			try
				my openListHelper(APPNAME)
				key code 126 using command down
				delay 0.5
				set the clipboard to "
" & newQuery
				keystroke "v" using command down
				keystroke "w" using command down
				log "Start off the task and exit"
				my openMainMenuHelper(APPNAME)
				keystroke "1" using command down
			end try
		end tell
	end tell
end topAdd

--------------------------------
-- Action: Queue New Task
--------------------------------
on quickAdd(query)
	set APPNAME to "Effortless"
	set newQuery to addTimeToQuery(query)
	launchApp(APPNAME)
	tell application "System Events"
		tell application process APPNAME
			try
				my openListHelper(APPNAME)
				key code 125 using command down
				delay 0.5
				set the clipboard to "
" & newQuery
				keystroke "v" using command down
				keystroke "w" using command down
			end try
		end tell
	end tell
end quickAdd

------------------------------
-- Action: Clear All Tasks
------------------------------
on clearList()
	set APPNAME to "Effortless"
	launchApp(APPNAME)
	tell application "System Events"
		tell application process APPNAME
			try
				my openListHelper(APPNAME)
				log "Select and delete all tasks"
				keystroke "a" using command down
				delay 0.1
				key code 51
				delay 0.1
				keystroke "w" using command down
			end try
		end tell
	end tell
end clearList

------------------------------
-- Action: Complete Task
------------------------------
on completeTask()
	set APPNAME to "Effortless"
	launchApp(APPNAME)
	tell application "System Events"
		tell application process APPNAME
			try
				if (get title of menu bar item 1 of menu bar 2) is not "" then
					my openMainMenuHelper(APPNAME)
					tell application "System Events" to keystroke "s" using command down
					log "Task marked completed"
					delay 0.1
				end if
			on error errorMessage
				display notification errorMessage
			end try
		end tell
	end tell
end completeTask

-----------------------------------
-- Action: Pause/Resume Task
-----------------------------------
on pauseResumeTask()
	set APPNAME to "Effortless"
	launchApp(APPNAME)
	tell application "System Events"
		tell application process APPNAME
			try
				if (get title of menu bar item 1 of menu bar 2) is not "" then
					my openMainMenuHelper(APPNAME)
					set actionTitle to get item 1 of (get title of menu item 4 of menu of menu bar item 1 of menu bar 2)
					tell application "System Events" to keystroke "d" using command down
					log actionTitle & "d task"
					display notification "Task " & actionTitle & "d."
					delay 0.1
				end if
			on error errorMessage
				display notification errorMessage
			end try
		end tell
	end tell
end pauseResumeTask

------------------------------
-- Action: Add 5 minutes
------------------------------
on addFiveMinutes()
	set APPNAME to "Effortless"
	launchApp(APPNAME)
	tell application "System Events"
		tell application process APPNAME
			try
				if (get title of menu bar item 1 of menu bar 2) is not "" then
					my openMainMenuHelper(APPNAME)
					tell application "System Events" to keystroke "r" using command down
					log "Added 5 more minutes to task"
					delay 0.1
				else
					display notification "No active task found" with title "Effortless"
				end if
			on error errorMessage
				display notification errorMessage
			end try
		end tell
	end tell
end addFiveMinutes

(*** HELPER ***)

----------------------------------
-- Helper: Open Current List
----------------------------------
on openListHelper(context)
	openMainMenuHelper(context)
	log "Opening main window"
	tell application "System Events"
		keystroke "f" using command down
		repeat until (exists window 1 of context)
			delay 0.1
		end repeat
		log "Main window opened"
		delay 0.1
	end tell
end openListHelper

--------------------------------
-- Helper: Open the menu
--------------------------------
on openMainMenuHelper(context)
	log "Opening main menu"
	tell application "System Events"
		keystroke "e" using {control down, command down}
		repeat until (exists menu 1 of menu bar item 1 of menu bar 2 of context)
			delay 0.1
		end repeat
		log "Main menu opened"
		delay 0.1
	end tell
end openMainMenuHelper

-------------------------------
--- Helper: Launch the app
-------------------------------
on launchApp(myapp)
	log "Launching app if not opened"
	if application myapp is not running then
		launch application myapp
		repeat until (application myapp is running)
			delay 0.1
		end repeat
		log "App launched"
		delay 0.1
	end if
end launchApp

-------------------------------
-- Helper: Add time on query
-------------------------------
on addTimeToQuery(query)
	log "Checking need to add"
	try
		set giventime to get word -1 of query as integer
		log "Already has " & giventime & "mins"
		return query
	on error errorMessage
		set mytimer to "5"
		if query starts with (character id 9202) then
			set mytimer to "25"
		end if
		display notification "~ " & mytimer & "mins" with title "New Task:" subtitle query
		log "Added new task with " & mytimer & "mins"
		return query & " " & mytimer
	end try
end addTimeToQuery