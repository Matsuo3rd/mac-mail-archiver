# mac-mail-archiver
AppleScript to automate archiving email from server IMAP folders to local folders while preserving folder structure from server

## Description
This Apple Script automates MacOS Mail emails archiving to a local mailbox (i.e. "On my Mac").

My personal use case is to archive emails older than 12 months from my corporate Exchange mailbox.
My corporate retention policy is 15-months, after which email are silently deleted.
Having been through the dreadful experience of loosing a critical email I had to prevent that to happen again.

## Prerequisites

* MacOS computer (not compatible with Windows / Linux)
* Mail app configured with an Account (whatever type: Gmail, Exchange, Yahoo, etc.)

## Installation

1. Download Apple Script MailArchiver.scpt
2. Edit MailArchiver.scpt to define parameters accordingly (see Configuration section)
3. Schedule the execution of the Apple Script on a recurrent basis.
I personally setup a Mac Mail rule to execute the script so that:
* Archiving gets executed once a day. As rule/script gets triggered upon every new email received, there is an optional mechanism - `preventSameDayArchivingto` setting to prevent the script from being executed multiple times a day. 
* Archiving gets executed when I am actually running Mac Mail. Executing the script in a standalone mode will open the Mail app, which I am not happy with (too naggy).
* Script must be placed into ~/Library/Application Scripts/com.apple.mail folder to be assigned to a Mac Mail rule

## Configuration

MailArchiver.scpt must be edited to match your configuration:

| Key | Default | Description |
| --- | --- | --- |
| `archiveAccount` | N/A | Account name to be archived. i.e. your Gmail/Exchange account name you defined in Mac Mail|
| `archiveMailbox` | N/A | Target archiving mailbox name. i.e. the name of the automatically created local (On my Mac) mailbox |
| `archiveMonthsTimeWindow` | N/A |The archiving time period in months. i.e. every email older than those n months will be moved to `archiveMailbox` |
| `preventSameDayArchiving` | N/A | Prevent archiving process to be executed more than once per day. I recommend to set this to true. true of false|
| `logFile` | N/A | Script will log information into that file accessible from the Console app|
