# Account source archive
property archiveAccount : "PROS"
# Mailbox target archive root
property archiveMailbox : "PROS Archive"
# Archive Months timewindow
property archiveMonthsTimeWindow : 12
# Prevent same-day archiving process
property preventSameDayArchiving : true
# Log file name
property logFile : "EmailArchiver.log"

set userLocale to user locale of (system info)
if userLocale is "fr_FR" then
	set notificationMsg to " messages archivés"
	set notificationTitle to "Emails Archiver"
	set notificationCompletedSubtitle to "Archivage terminé"
	set ignoreTheseMailboxes to {"Suivis", "Brouillons", "Messages envoyés", "Corbeille", "Spam", "Historique des conversations", "Journal", "Archive", "Tâches", "Notes", "Boîte d'envoi", "Éléments envoyés", "Éléments supprimés", "Courrier indésirable"}
else
	set notificationMsg to " messages archived"
	set notificationTitle to "Emails Archiver"
	set notificationCompletedSubtitle to "Processing is complete"
	set ignoreTheseMailboxes to {"all mail", "archive", "archived", "drafts", "junk", "junk e-mail", "sent", "sent items", "sent messages", "spam"}
end if

set archiveDateReference to addMonths onto (current date) by -archiveMonthsTimeWindow

property lastRunTime : missing value
if (preventSameDayArchiving is true and lastRunTime is not missing value) and (my dateFormatYYYYMMDD(current date) is equal to my dateFormatYYYYMMDD(lastRunTime)) then
	my logToFile("Emails archiving already executed today")
	error number -128
end if

display notification "Emails archiving started" with title notificationTitle
my logToFile("Emails archiving started")

#https://superuser.com/questions/33177/apple-mail-doesnt-apply-rules-unless-i-choose-apply-rules-manually
tell application "Mail"
	try
		set movedMsgCount to 0
		set theMailboxes to every mailbox of account archiveAccount
		
		repeat with eachMailbox in theMailboxes
			try
				if ignoreTheseMailboxes does not contain name of eachMailbox then
					my logToFile("Scanning Mailbox \"" & name of eachMailbox & "\"")
					set messagesToArchive to (every message of eachMailbox whose date received ≤ archiveDateReference)
					if (count of messagesToArchive) > 0 then
						set mailboxMovedMsgCount to 0
						# Map mailbox hierarchy
						set parentList to {}
						set nextContainer to eachMailbox
						repeat
							set the beginning of parentList to (name of nextContainer)
							set nextContainer to container of nextContainer
							if (class of nextContainer is not container) then
								exit repeat
							end if
						end repeat
						set sourceMailbox to my convertListToString(parentList, "/")
						set the beginning of parentList to (archiveMailbox)
						set targetMailbox to my convertListToString(parentList, "/")
						# Appends / to mailbox end -see https://discussions.apple.com/thread/7330780
						make new mailbox with properties {name:targetMailbox & "/"}
						
						repeat with messageToArchive in messagesToArchive
							move messageToArchive to mailbox targetMailbox
							#my logToFile("Message \"" & subject of messageToArchive & "\" moved to mailbox \"" & (name of mailbox of messageToArchive) & "\"")
							set mailboxMovedMsgCount to mailboxMovedMsgCount + 1
						end repeat
						my logToFile("Scanning Mailbox \"" & sourceMailbox & "\" completed. " & (mailboxMovedMsgCount as string) & " messages moved")
						set movedMsgCount to movedMsgCount + mailboxMovedMsgCount
					end if
				else
					my logToFile("Scanning Mailbox \"" & name of eachMailbox & "\" ignored")
				end if
			on error errStr number errorNumber
				display notification errStr & " " & errorNumber
				my logToFile(errStr & " " & errorNumber)
			end try
		end repeat
		
		set lastRunTime to (current date)
		display notification (movedMsgCount as string) & " " & notificationMsg with title notificationTitle subtitle notificationCompletedSubtitle
		my logToFile("Emails archiving completed: " & (movedMsgCount as string) & " messages archived")
	on error errStr number errorNumber
		display notification errStr & " " & errorNumber
		my logToFile(errStr & " " & errorNumber)
	end try
end tell

on logToFile(logData)
	#log (logData)
	set d to (get current date)
	set logData to d & " " & logData
	set the logPath to ((path to library folder from user domain) as string) & "Logs:" & logFile
	try
		set the openFile to open for access file logPath with write permission
		write (logData as string) & linefeed to the openFile starting at eof as «class utf8»
		close access the openFile
		return true
	on error
		try
			close access file logPath
		end try
		return false
	end try
end logToFile

on convertListToString(theList, theDelimiter)
	set AppleScript's text item delimiters to theDelimiter
	set theString to theList as string
	set AppleScript's text item delimiters to ""
	return theString
end convertListToString

# from https://macscripter.net/viewtopic.php?id=24737
on addMonths onto oldDate by m -- returns a date
	copy oldDate to newDate
	-- Convert the month-offset parameter to years and months
	set {y, m} to {m div 12, m mod 12}
	-- If the month offset is negative (-1 to -11), make it positive from a year previously
	if m < 0 then set {y, m} to {y - 1, m + 12}
	-- Add the year offset into the new date's year
	set newDate's year to (newDate's year) + y
	-- Add the odd months (at 32 days per month) and set the day
	if m is not 0 then tell newDate to set {day, day} to {32 * m, day}
	-- If the day's now wrong, it doesn't exist in the target month
	-- Subtract the overflow into the following month to return to the last day of the target month
	if newDate's day is not oldDate's day then set newDate to newDate - (newDate's day) * days
	return newDate
end addMonths

on dateFormatYYYYMMDD(old_date)
	set {year:y, month:m, day:d} to old_date
	set ymd to (y * 10000 + m * 100 + d) as string
	set new_date to (text items 1 thru 4 of ymd as string) & (text items 5 thru 6 of ymd as string) & (text items 7 thru 8 of ymd as string)
	return new_date
end dateFormatYYYYMMDD
