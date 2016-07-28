display.setStatusBar( display.HiddenStatusBar ) -- Hide the status bar

local halfW = display.contentCenterX
local halfH = display.contentCenterY

display.setDefault( "background", 1 )	-- white
local background = display.newImageRect( "assets/background.png", ((display.pixelWidth*.5)*(320/display.pixelWidth)), ((display.pixelWidth*.5)*(480/display.pixelHeight)) )
background.x = display.contentCenterX
background.y = display.contentCenterY

-- All the main set-up stuff and variable declarations...
local str = require("str")
local widget = require( "widget" )
local loadsave = require("loadsave")
local sqlite3 = require( "sqlite3" )
local json = require("json" )
local pushwoosh = require( "pushwoosh" )

local function onNotification( event )
	local encodedEvent = json.encode( event.data )
	if (event.data.alert ~= nil) then
		native.showAlert( "remote notification", event.data.alert, { "OK" } )
	else
		native.showAlert( "remote notification", encodedEvent, { "OK" } )
	end
end

local function onRegistrationSuccess( event )
	print( "Registered on Pushwoosh" )
end

local function onRegistrationFail( event )
	print("OnRegistrationFail called")
	native.showAlert( "Notification Registration Failed", "An Error Contacting the Server has Occurred. Please try again later from the application settings.", { "OK" } )                  
end

Runtime:addEventListener( "pushwoosh-notification", onNotification )
Runtime:addEventListener( "pushwoosh-registration-success", onRegistrationSuccess )
Runtime:addEventListener( "pushwoosh-registration-fail", onRegistrationFail )

local launchArgs = ...

--[[
if ( launchArgs and launchArgs.notification ) then
    onNotification( launchArgs.notification )
end
]]--

pushwoosh.registerForPushNotifications( "9DF13-11A95", launchArgs )

local rowTitlesDate = {}
local rowClassLengthDate = {}
local rowTitlesDateTime = {}
local rowTitlesTrack = {}
local rowTitlesFeedback = {}
local rowTitlesFavorite = {}

local isFriday = false
local classTitle = "Default Title"
local classInstructor = "Default Instructor"
local classTrack = "Default Track"
local classTime = "Default Time"
local classRoom = "Default Room"
local classDesc = "Default Description"
local feedbackURL = "Default FeedbackURL"
local filePath = system.pathForFile("SavedSettings.txt", system.DocumentsDirectory)	-- Set location for saved data
local phaseCur = "home"
local phasePrev = "home"
local dayIndex = 1
local timeSlot = 1
local classDB
local datePathE = system.pathForFile( "datefile.txt", system.TemporaryDirectory)

local classesScheduledTemplate = {
	{
		"",
		"",
		"",
		""
	},
	{
		"",
		"",
		"",
		"",
		""
	},
	{
		"",
		"",
		"",
		"",
		""
	},
	{
		"",
		"",
		""
	}
}

local scheduleTable = 
{
	{ 
	  times = { 
		"", 
		" 7:30 a.m.  ", 
		" 8:30 a.m.  ", 
		"10:00 a.m. ",
		"10:20 a.m. ", 
		"11:20 a.m. ", 
		"12:20 p.m. ", 
		" 1:20 p.m. ", 
		" 1:40 p.m. ", 
		" 2:40 p.m. ", 
		" 3:00 p.m. ", 
		" 4:00 p.m. ", 
		" 6:00 p.m. "
	  },
	  classes = { 
	  	{ name = "Tuesday Schedule", timeSlot = 0 },
	  	{ name = "Breakfast" , timeSlot = 0 },
	  	{ name = "Opening Session", timeSlot = 0 },
	  	{ name = "Break - Club Spillman", timeSlot = 0 },
	  	{ name = "", timeSlot = 1 },
	  	{ name = "Lunch", timeSlot = 0 },
	  	{ name = "", timeSlot = 2 },
	  	{ name = "Break - Club Spillman", timeSlot = 0 },
	  	{ name = "", timeSlot = 3 },
	  	{ name = "Break - Club Spillman", timeSlot = 0 },
	  	{ name = "", timeSlot = 4 },
	  	{ name = "Break - Club Spillman", timeSlot = 0 },
	  	{ name = "Evening - On Your Own", timeSlot = 0 }
	  } 
	},
	{ 
	  times = { 
	  	"", 
	  	"7:30am  ", 
	  	"9:00am  ", 
	  	"10:00am ", 
	  	"10:20am ", 
	  	"11:20am ", 
	  	"12:20am ", 
	  	"1:20pm ", 
	  	"1:40pm ", 
	  	"2:40pm ", 
	  	"3:00pm ", 
	  	"6:00pm "
	  },
	  classes = { 
	  	{ name = "Wednesday Schedule", timeSlot = 0 },
	  	{ name = "Breakfast" , timeSlot = 0 },
	  	{ name = "", timeSlot = 1 },
	  	{ name = "Break - Club Spillman", timeSlot = 0 },
	  	{ name = "", timeSlot = 2 },
	  	{ name = "Networking Luncheon", timeSlot = 0 },
	  	{ name = "", timeSlot = 3 },
	  	{ name = "Break - Club Spillman", timeSlot = 0 },
	  	{ name = "", timeSlot = 4 },
	  	{ name = "Break - Club Spillman", timeSlot = 0 },
	  	{ name = "", timeSlot = 5 },
	  	{ name = "Evening Event - World Classic Rockers", timeSlot = 0 }
	  }
	},
	{ 
	  times = { 
	  	"", 
	  	"7:30am  ", 
	  	"9:00am  ", 
	  	"10:00am ", 
	  	"10:20am ", 
	  	"11:20am ", 
	  	"12:20am ", 
	  	"1:20pm ", 
	  	"1:40pm ", 
	  	"2:40pm ", 
	  	"3:00pm ", 
	  	"4:00pm ",
	  	"6:00pm "
	  },
	  classes = { 
	  	{ name = "Thursday Schedule", timeSlot = 0 },
	  	{ name = "Breakfast" , timeSlot = 0 },
	  	{ name = "", timeSlot = 1 },
	  	{ name = "Break - Club Spillman", timeSlot = 0 },
	  	{ name = "", timeSlot = 2 },
	  	{ name = "Lunch", timeSlot = 0 },
	  	{ name = "", timeSlot = 3 },
	  	{ name = "Break - Club Spillman", timeSlot = 0 },
	  	{ name = "", timeSlot = 4 },
	  	{ name = "Break - Club Spillman", timeSlot = 0 },
	  	{ name = "", timeSlot = 5 },
	  	{ name = "Break - Club Spillman", timeSlot = 0 },
	  	{ name = "Closing Awards Banquet", timeSlot = 0 }
	  }
	},
	{ 
	  times = { 
	  	"", 
	  	"7:30am  ", 
	  	"9:00am  ", 
	  	"10:00am ", 
	  	"10:20am ", 
	  	"11:20am ", 
	  	"11:40am "
	  },
	  classes = { 
	  	{ name = "Friday Schedule", timeSlot = 0 },
	  	{ name = "Breakfast" , timeSlot = 0 },
	  	{ name = "", timeSlot = 1 },
	  	{ name = "Break - Club Spillman", timeSlot = 0 },
	  	{ name = "", timeSlot = 2 },
	  	{ name = "Break - Club Spillman", timeSlot = 0 },
	  	{ name = "", timeSlot = 3 },
	  }
	}
}

local ByDateData = {
	{ 
	  time = "Tuesday - 10:20 a.m.",
	  day = 1,
	  timeSlot = 1,
	  items = {} 
	},
	{ 
	  time = "Tuesday - 12:20 p.m.",
	  day = 1,
	  timeSlot = 2,
	  items = {} 
	 },
	{ 
	  time = "Tuesday - 1:40 p.m.",
	  day = 1,
	  timeSlot = 3, 
	  items = {} 
	},
	{ 
	  time = "Tuesday - 3:00 p.m.", 
	  day = 1,
	  timeSlot = 4, 
	  items = {} 
	},
	{ 
	  time = "Wednesday - 9:00 a.m.", 
	  day = 2,
	  timeSlot = 1, 
	  items = {} 
	},
	{ 
	  time = "Wednesday - 10:20 a.m.", 
	  day = 2,
	  timeSlot = 2, 
	  items = {} 
	},
	{ 
	  time = "Wednesday - 12:20 p.m.", 
	  day = 2,
	  timeSlot = 3, 
	  items = {} 
	},
	{ 
	  time = "Wednesday - 1:40 p.m.", 
	  day = 2,
	  timeSlot = 4, 
	  items = {} 
	},
	{ 
	  time = "Wednesday - 3:00 p.m.", 
	  day = 2,
	  timeSlot = 5, 
	  items = {} 
	},
	{ 
	  time = "Thursday - 9:00 a.m.", 
	  day = 3,
	  timeSlot = 1, 
	  items = {} 
	},
	{ 
	  time = "Thursday - 10:20 a.m.", 
	  day = 3,
	  timeSlot = 2, 
	  items = {} 
	},
	{ 
	  time = "Thursday - 12:20 p.m.", 
	  day = 3,
	  timeSlot = 3, 
	  items = {} 
	},
	{ 
	  time = "Thursday - 1:40 p.m.", 
	  day = 3,
	  timeSlot = 4, 
	  items = {} 
	},
	{ 
	  time = "Thursday - 3:00 p.m.", 
	  day = 3,
	  timeSlot = 5, 
	  items = {} 
	},
	{ 
	  time = "Friday - 9:00 a.m.", 
	  day = 4,
	  timeSlot = 1, 
	  items = {} 
	},
	{ 
	  time = "Friday - 10:20 a.m.", 
	  day = 4,
	  timeSlot = 2, 
	  items = {} 
	},
	{ 
	  time = "Friday - 11:20 a.m.", 
	  day = 4,
	  timeSlot = 3, 
	  items = {} 
	},
}

local ByTrackData = {}

--[[
local ByTrackData = {
	{ 
		title = "Sys Admin Track 1",
		items = {} 
	},
	{ 
		title = "Sys Admin Track 2",
		items = {} 
	},
	{ 
		title = "Research and Design Track", 
		items = {} 
	},
	{ 
		title = "Analytics Track", 
		items = {} 
	},
	{ 
		title = "Records and Analyst Track", 
		items = {} 
	},
	{ 
		title = "Dispatch Track", 
		items = {} 
	},
	{ 
		title = "GIS Track", 
		items = {} 
	},
	{ 
		title = "Mobile Track", 
		items = {} 
	},
	{ 
		title = "Executive Track", 
		items = {} 
	},
	{ 
		title = "Corrections Track", 
		items = {} 
	},
	{ 
		title = "Nova Track", 
		items = {} 
	},
	{ 
		title = "Cert Class 1", 
		items = {} 
	},
	{ 
		title = "Cert Class 2", 
		items = {} 
	},
	{ 
		title = "Cert Class 3", 
		items = {} 
	},
}
--]]

-- Not fully implemented yet, will be used to track more than just the previous screen, 
-- so we can back up to multiple screens when needed.  Like when clicking the map button
-- from within the details screen mostly.
local phaseStack = {}

function saveSettings()
	file = io.open( filePath, "w" )
	for k,v in pairs( appData ) do
		file:write( k .. "=" .. v .. "," )
	end	
	io.close( file )
	loadsave.saveTable(classesScheduled, "classes.json")
	loadsave.saveTable(ByDateData, "bydatedata.json")
end

function loadSettings()	
	local index
	local file = io.open( filePath, "r" )
	if file then
		local dataStr = file:read( "*a" )		-- Read file contents into a string
		local datavars = str.split(dataStr, ",")	-- Break string into separate variables and construct new table from resulting data
		appData = {}
		for index = 1, #datavars do			-- split each name/value pair
			local onevalue = str.split(datavars[index], "=")
			appData[onevalue[1]] = onevalue[2]
		end
		io.close( file )

		appData["unlocked"] = tonumber(appData["unlocked"])
	else
		appData = {}
		appData.unlocked = 0
		appData.surveyPrompt = 1
	end

	classesScheduled = loadsave.loadTable("classes.json") 
	if classesScheduled == nil then
		classesScheduled = classesScheduledTemplate
		loadsave.saveTable(classesScheduled, "classes.json")
	end
end

local function myUnhandledErrorListener( event )

    print("Houston, we have a problem " .. event.errorMessage)
	--classDB:close()   
    return true
end


----------------------------------------------------------------------------------
-- doesFileExist
--
-- Checks to see if a file exists in the path.
--
-- Enter:   name = file name
--  path = path to file (directory)
--  defaults to ResourceDirectory if "path" is missing.
--
-- Returns: true = file exists, false = file not found
----------------------------------------------------------------------------------
--
function doesFileExist( fname, path )

    local results = false

    local filePath = system.pathForFile( fname, path )
	local fileHandle

    -- filePath will be nil if file doesn't exist and the path is ResourceDirectory
    --
    if filePath then
        fileHandle = io.open( filePath, "r" )
    end

    if  fileHandle then
        print( "File found -> " .. filePath )
        -- Clean up our file handles
        fileHandle:close()
        results = true
    else
        print( "File does not exist -> " .. fname )
    end

    print()

    return results
end

----------------------------------------------------------------------------------
-- copyFile( src_name, src_path, dst_name, dst_path, overwrite )
--
-- Copies the source name/path to destination name/path
--
-- Enter:   src_name = source file name
--      src_path = source path to file (directory), nil for ResourceDirectory
--      dst_name = destination file name
--      overwrite = true to overwrite file, false to not overwrite
--
-- Returns: false = error creating/copying file
--      nil = source file not found
--      1 = file already exists (not copied)
--      2 = file copied successfully
----------------------------------------------------------------------------------
--
function copyFile( srcName, srcPath, dstName, dstPath, overwrite )

    local results = false

    local srcPath = doesFileExist( srcName, srcPath )

    if srcPath == false then
        -- Source file doesn't exist
		print("Source file for copy does not exist: " .. srcName)
        return nil
    end

    -- Check to see if destination file already exists
    if not overwrite then
        if fileLib.doesFileExist( dstName, dstPath ) then
            -- Don't overwrite the file
            return 1
        end
    end

    -- Copy the source file to the destination file
    --
    local rfilePath = system.pathForFile( srcName, srcPath )
    local wfilePath = system.pathForFile( dstName, dstPath )

    local rfh = io.open( rfilePath, "rb" )

    local wfh = io.open( wfilePath, "wb" )

    if  not wfh then
        print( "writeFileName open error!" )
        return false            -- error
    else
        -- Read the file from the Resource directory and write it to the destination directory
        local data = rfh:read( "*a" )
        if not data then
            print( "read error!" )
            return false    -- error
        else
            if not wfh:write( data ) then
                print( "write error!" )
                return false    -- error
            end
        end
    end

    results = 2     -- file copied

    -- Clean up our file handles
    rfh:close()
    wfh:close()

    return results
end

-- remove trailing and leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(8programming)
function trim(s)
  -- from PiL2 20.4
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function loadDB()

	-- Checking for SpillmanUC.db in Documents directory
print("Loading the Spillman UC db")
	local results = doesFileExist( "SpillmanUC.db", system.DocumentsDirectory )
	if (results == false) then
		copyFile( "SpillmanUC.db", nil, "SpillmanUC.db", system.DocumentsDirectory, true )
	end
	
	-- Open "SpillmanUC.db" with sqlite
	local path = system.pathForFile( "SpillmanUC.db", system.DocumentsDirectory )
	classDB = sqlite3.open( path )

	-- Load the table contents
	local time1
	local time2
	local index = 1
	for row in classDB:nrows("SELECT * FROM conference_survey") do
		conferenceSurveyUrl = row.url
		print("Conference Survey: " .. conferenceSurveyUrl)
		if conferenceSurveyUrl == "Not Set" then
			appData.surveyPrompt = 0
			print("Turning off conference survey prompt")
		end
	end
	for row in classDB:nrows("SELECT * FROM tuesday") do
		time1 = trim(row.date1) .. " - " .. trim(row.time1)
		time2 = trim(row.date2) .. " - " .. trim(row.time2)
		for index = 1, #ByDateData do
			if ByDateData[index].time == time1 then
				ByDateData[index].items[#ByDateData[index].items + 1] = {
					track = row.track,
					presenter = row.presenter_name,
					name = row.class_title,
					description = row.description,
					classRoom = row.room,
					length = tonumber(row.hours),
					time1 = time1,
					time2 = time2,
					feedbackURL = row.url,
				}
			elseif ByDateData[index].time == time2 then
				ByDateData[index].items[#ByDateData[index].items + 1] = {
					track = row.track,
					presenter = row.presenter_name,
					name = row.class_title,
					description = row.description,
					classRoom = row.room,
					length = tonumber(row.hours),
					time1 = time1,
					time2 = time2,
					feedbackURL = row.url,
				}
			end
		end
	end

	-- Load the table contents
	for row in classDB:nrows("SELECT * FROM wednesday") do
		time1 = trim(row.date1) .. " - " .. trim(row.time1)
		time2 = trim(row.date2) .. " - " .. trim(row.time2)
		for index = 1, #ByDateData do
			if ByDateData[index].time == time1 then
				ByDateData[index].items[#ByDateData[index].items + 1] = {
					track = row.track,
					presenter = row.presenter_name,
					name = row.class_title,
					description = row.description,
					classRoom = row.room,
					length = tonumber(row.hours),
					time1 = time1,
					time2 = time2,
					feedbackURL = row.url,
				}
			elseif ByDateData[index].time == time2 then
				ByDateData[index].items[#ByDateData[index].items + 1] = {
					track = row.track,
					presenter = row.presenter_name,
					name = row.class_title,
					description = row.description,
					classRoom = row.room,
					length = tonumber(row.hours),
					time1 = time1,
					time2 = time2,
					feedbackURL = row.url,
				}
			end
		end
	end
	
	for row in classDB:nrows("SELECT * FROM thursday") do
		time1 = trim(row.date1) .. " - " .. trim(row.time1)
		time2 = trim(row.date2) .. " - " .. trim(row.time2)
		for index = 1, #ByDateData do
			if ByDateData[index].time == time1 then
				ByDateData[index].items[#ByDateData[index].items + 1] = {
					track = row.track,
					presenter = row.presenter_name,
					name = row.class_title,
					description = row.description,
					classRoom = row.room,
					length = tonumber(row.hours),
					time1 = time1,
					time2 = time2,
					feedbackURL = row.url,
				}
			elseif ByDateData[index].time == time2 then
				ByDateData[index].items[#ByDateData[index].items + 1] = {
					track = row.track,
					presenter = row.presenter_name,
					name = row.class_title,
					description = row.description,
					classRoom = row.room,
					length = tonumber(row.hours),
					time1 = time1,
					time2 = time2,
					feedbackURL = row.url,
				}
			end
		end
	end
	
	-- Load the table contents
	for row in classDB:nrows("SELECT * FROM friday") do
		time1 = trim(row.date1) .. " - " .. trim(row.time1)
		time2 = trim(row.date2) .. " - " .. trim(row.time2)
		for index = 1, #ByDateData do
			if ByDateData[index].time == time1 then
				ByDateData[index].items[#ByDateData[index].items + 1] = {
					track = row.track,
					presenter = row.presenter_name,
					name = row.class_title,
					description = row.description,
					classRoom = row.room,
					length = tonumber(row.hours),
					time1 = time1,
					time2 = time2,
					feedbackURL = row.url,
				}
			elseif ByDateData[index].time == time2 then
				ByDateData[index].items[#ByDateData[index].items + 1] = {
					track = row.track,
					presenter = row.presenter_name,
					name = row.class_title,
					description = row.description,
					classRoom = row.room,
					length = tonumber(row.hours),
					time1 = time1,
					time2 = time2,
					feedbackURL = row.url,
				}
			end
		end
	end
	
	for row in classDB:nrows("SELECT * FROM track") do
		local found = 0
		for index = 1, #ByTrackData do
			local day, timeSlot
			if ByTrackData[index].title == row.track then
				found = 1
				break
			end
		end
		if (found == 0) then
			local nextEntry = #ByTrackData + 1
			ByTrackData[nextEntry] = {}
			ByTrackData[nextEntry].title = row.track
			ByTrackData[nextEntry].items = {}
		end
	end

	for row in classDB:nrows("SELECT * FROM track") do
		for index = 1, #ByTrackData do
			local day, timeSlot
			time1 = trim(row.date1) .. " - " .. trim(row.time1)
			time2 = trim(row.date2) .. " - " .. trim(row.time2)
			if ByTrackData[index].title == row.track then
				found = 1
				ByTrackData[index].items[#ByTrackData[index].items + 1] = {
					presenter = row.presenter_name,
					name = row.class_title,
					description = row.description,
					classRoom = row.room,
					length = tonumber(row.hours),
					track = row.track,
					time1 = time1,
					time2 = time2,
					feedbackURL = row.url,
				}
			end
		end
	end
	classDB:close()
	--saveSettings()
	print("Spillman UC db load complete")
end

function phaseChange(curPhase)
	phasePrev = phaseCur
	phaseCur = curPhase
	--print("phaseChange: phaseCur", phaseCur, "phasePrev", phasePrev)
end

local function phasePush(curPhase)
	--phaseStack[#phaseStack + 1] = curPhase
	--local message = "after phase push "
	--for i = 1, #phaseStack do
	--	message = message .. " " .. phaseStack[i]
	--end
	--print(message)
end

local function phasePop()
	--local index
	--phaseStack[#phaseStack] = nil
	--local message = "after phase pop"
	--for index = 1, #phaseStack do
	--	message = message .. " " .. phaseStack[index]
	--end
end

-- function loadingSpinner()
-- 	spinner = display.newImage("assets/Loader.png")
-- 	spinner.anchorX = 0.5
-- 	spinner.anchorY = 0.5
-- 	spinner.x=display.contentCenterX
-- 	spinner.y=display.contentCenterY
-- 	tranion.to(spinner, {tsitime=3000, rotation=1080})
-- 	timer.performWithDelay( 3000, loadingSpinnerOff)
-- end

-- function loadingSpinnerOff()
-- 	spinner:removeSelf()
-- 	spinner = nil
-- end

local conferenceMapPage = native.newWebView( display.contentCenterX, display.contentCenterY + ((display.contentHeight/24)+(display.contentHeight/30)), display.contentWidth, display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)))
conferenceMapPage:request( "conferenceMap.jpg", system.ResourceDirectory )
conferenceMapPage.isVisible = false

local cityMapPage = native.newWebView( display.contentCenterX, display.contentCenterY + ((display.contentHeight/24)+(display.contentHeight/30)), display.contentWidth, display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)))
cityMapPage:request( "cityMap.html", system.ResourceDirectory )
cityMapPage.isVisible = false

local ideaWallPage = native.newWebView( display.contentCenterX, display.contentCenterY + ((display.contentHeight/24)+(display.contentHeight/30)), display.contentWidth, display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)))
ideaWallPage.isVisible = false

local classFeedbackPage = native.newWebView( display.contentCenterX, display.contentCenterY + ((display.contentHeight/24)+(display.contentHeight/30)), display.contentWidth, display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)))
classFeedbackPage.isVisible = false

local conferenceFeedbackPage = native.newWebView( display.contentCenterX, display.contentCenterY + ((display.contentHeight/24)+(display.contentHeight/30)), display.contentWidth, display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)))
conferenceFeedbackPage.isVisible = false

local trendingPage = native.newWebView( display.contentCenterX, display.contentCenterY + ((display.contentHeight/24)+(display.contentHeight/30)), display.contentWidth, display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)))
trendingPage.isVisible = false

local likePage = native.newWebView( display.contentCenterX, display.contentCenterY + ((display.contentHeight/24)+(display.contentHeight/30)), display.contentWidth, display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)))
likePage.isVisible = false

local function MakeInvisibleAll()
	conferenceMapPage.isVisible = false
	cityMapPage.isVisible = false
	ideaWallPage.isVisible = false
	classFeedbackPage.isVisible = false
	conferenceFeedbackPage.isVisible = false
	trendingPage.isVisible = false
	likePage.isVisible = false
	classListSchedule.isVisible = false
	classListDate.isVisible = false
	classListScreen.isVisible = false
	classListTrack.isVisible = false
	detailsScreen.isVisible = false
	classListFeedback.isVisible = false
	ScheduleSubTab.isVisible = false
	background.isVisible = false
	if surveyPage ~= nil then
		surveyPage.isVisible = false
	end	
	native.setKeyboardFocus( nil )
end

local function MapButton ()
	local function proceed (event)
		if "clicked" == event.action then
	        if 1 == event.index then
				ideaWallPage:stop()
				classFeedbackPage:stop()
				conferenceFeedbackPage:stop()
				trendingPage:stop()
				likePage:stop()
				MakeInvisibleAll()
				phaseChange("MapButton")
				phasePush("MapButton")
				transition.to( detailsScreen, { time=500, x=display.contentWidth } )
				transition.to( ClassSubTab, { time=250, y=0 } )
				transition.to( SocialSubTab, { time=250, y=0 } )
				transition.to( FeedbackSubTab, { time=250, y=0 } )
				transition.to( MapSubTab, { time=250, y=(display.contentHeight / 12) + (display.contentHeight / 30) } )
				MapSubTab:setSelected(0, false)
	        elseif 2 == event.index then
	            mainTabBar:setSelected(3, false)
	        end
	    end
	end

	if phaseCur == "IdeaWallButton" or phaseCur == "ClassSurvey" or phaseCur == "ConferenceFeedbackButton" then
		local alert = native.showAlert( "Warning", "If you leave this page any information you have entered will be lost, are you sure you want to leave?", { "Yes", "Cancel" }, proceed )
	else
		ideaWallPage:stop()
		classFeedbackPage:stop()
		conferenceFeedbackPage:stop()
		trendingPage:stop()
		likePage:stop()
		MakeInvisibleAll()
		phaseChange("MapButton")
		phasePush("MapButton")
		transition.to( detailsScreen, { time=500, x=(display.contentWidth) } )
		transition.to( ClassSubTab, { time=250, y=0 } )
		transition.to( SocialSubTab, { time=250, y=0 } )
		transition.to( FeedbackSubTab, { time=250, y=0 } )
		transition.to( MapSubTab, { time=250, y=(display.contentHeight / 12) + ((display.contentHeight / 15)/2) } )
		MapSubTab:setSelected(0, false)
	end
end

local function ClassButton ()
	local function proceed (event)
		if "clicked" == event.action then
	        if 1 == event.index then
				ideaWallPage:stop()
				classFeedbackPage:stop()
				conferenceFeedbackPage:stop()
				trendingPage:stop()
				likePage:stop()	
				MakeInvisibleAll()
				phaseChange("ClassButton")
				phasePush("ClassButton")
				transition.to( detailsScreen, { time=500, x=display.contentWidth } )
				transition.to( SocialSubTab, { time=250, y=0 } )
				transition.to( MapSubTab, { time=250, y=0 } )
				transition.to( FeedbackSubTab, { time=250, y=0 } )
				transition.to( ClassSubTab, { time=250, y=(display.contentHeight / 12) + (display.contentHeight / 30) } )
				ClassSubTab:setSelected(0, false)
			elseif 2 == event.index then
				mainTabBar:setSelected(3, false)
			end
		end
	end
	
	if phaseCur == "IdeaWallButton" or phaseCur == "ClassSurvey" or phaseCur == "ConferenceFeedbackButton" then
		local alert = native.showAlert( "Warning", "If you leave this page any information you have entered will be lost, are you sure you want to leave?", { "Yes", "Cancel" }, proceed )
	else
		ideaWallPage:stop()
		classFeedbackPage:stop()
		conferenceFeedbackPage:stop()
		trendingPage:stop()
		likePage:stop()	
		MakeInvisibleAll()
		phaseChange("ClassButton")
		phasePush("ClassButton")
		transition.to( detailsScreen, { time=500, x=(display.contentWidth) } )
		transition.to( SocialSubTab, { time=250, y=0 } )
		transition.to( MapSubTab, { time=250, y=0 } )
		transition.to( FeedbackSubTab, { time=250, y=0 } )
		transition.to( ClassSubTab, { time=250, y=(display.contentHeight / 12) + ((display.contentHeight / 15)/2) } )
		ClassSubTab:setSelected(0, false)
	end	
end

local function FeedbackButton ()
	trendingPage:stop()
	likePage:stop()
	conferenceFeedbackPage:request( "https://www.allegiancetech.com/v7/App/ActiveSurvey/Open/Take.aspx?cid=7KI758627p41G952&ESurveyId=7KI7534K766K025")
	ideaWallPage:request( "http://ideas.spillman.com" )
	MakeInvisibleAll()
	phaseChange("FeedbackButton")
	phasePush("FeedbackButton")
	transition.to( detailsScreen, { time=500, x=(display.contentWidth) } )
	transition.to( ClassSubTab, { time=250, y=0 } )
	transition.to( SocialSubTab, { time=250, y=0 } )
	transition.to( MapSubTab, { time=250, y=0 } )
	transition.to( FeedbackSubTab, { time=250, y=(display.contentHeight / 12) + ((display.contentHeight / 15)/2) } )
	FeedbackSubTab:setSelected(0, false)
end

local function SocialButton ()
	local function proceed (event)
		if "clicked" == event.action then
	        if 1 == event.index then	
				ideaWallPage:stop()
				classFeedbackPage:stop()
				conferenceFeedbackPage:stop()
				trendingPage:request( "https://tagboard.com/SpillmanUC16/303485" )	
				likePage:request( "https://www.facebook.com/spillmantechnologies" )
				MakeInvisibleAll()
				phaseChange("SocialButton")
				phasePush("SocialButton")
				transition.to( detailsScreen, { time=500, x=(display.contentWidth) } )
				transition.to( ClassSubTab, { time=250, y=0 } )
				transition.to( FeedbackSubTab, { time=250, y=0 } )
				transition.to( MapSubTab, { time=250, y=0 } )
				transition.to( SocialSubTab, { time=250, y=(display.contentHeight / 12) + ((display.contentHeight / 15)/2) } )
				SocialSubTab:setSelected(0, false)
			elseif 2 == event.index then
				mainTabBar:setSelected(3, false)
			end
		end
	end

	if phaseCur == "IdeaWallButton" or phaseCur == "ClassSurvey" or phaseCur == "ConferenceFeedbackButton" then
		local alert = native.showAlert( "Warning", "If you leave this page any information you have entered will be lost, are you sure you want to leave?", { "Yes", "Cancel" }, proceed )
	else
		ideaWallPage:stop()
		classFeedbackPage:stop()
		conferenceFeedbackPage:stop()
		trendingPage:request( "https://tagboard.com/SpillmanUC16/303485" )
		likePage:request( "https://www.facebook.com/spillmantechnologies" )
		MakeInvisibleAll()
		phaseChange("SocialButton")
		phasePush("SocialButton")
		transition.to( detailsScreen, { time=500, x=(display.contentWidth) } )
		transition.to( ClassSubTab, { time=250, y=0 } )
		transition.to( FeedbackSubTab, { time=250, y=0 } )
		transition.to( MapSubTab, { time=250, y=0 } )
		transition.to( SocialSubTab, { time=250, y=(display.contentHeight / 12) + ((display.contentHeight / 15)/2) } )
		SocialSubTab:setSelected(0, false)
	end					
end

local function DayTimeButton ()
	phaseChange("DayTimeButton")
	phasePush("DayTimeButton")
	MakeInvisibleAll()
	classListDate.isVisible = true
	detailsScreen.isVisible = true
    transition.to( detailsScreen, { time=250, x=display.contentWidth } )
    transition.to( classListDate, { time=250, x=(display.contentWidth/2) } )
    transition.to( classListTrack, { time=250, x=-(display.contentWidth/2) } )
    transition.to( classListSchedule, { time=250, x=-(display.contentWidth/2) } )	
end

local function MyScheduleButton ()
	phaseChange("MyScheduleButton")
	phasePush("MyScheduleButton")
	MakeInvisibleAll()
    classListSchedule.isVisible = true
	ScheduleSubTab.isVisible = true
	detailsScreen.isVisible = true
    transition.to( detailsScreen, { time=250, x=display.contentWidth } )
    transition.to( classListDate, { time=250, x=-(display.contentWidth/2) } )
    transition.to( classListTrack, { time=250, x=-(display.contentWidth/2) } )
    transition.to( classListSchedule, { time=250, x=(display.contentWidth/2) } )	
    transition.to( ClassSubTab, { time=250, x=(display.contentWidth/2) } )
end

local function TrackButton ()
	phaseChange("TrackButton")
	phasePush("TrackButton")
	MakeInvisibleAll()
	classListTrack.isVisible = true
	detailsScreen.isVisible = true
	transition.to( detailsScreen, { time=250, x=display.contentWidth } )
    transition.to( classListTrack, { time=250, x=(display.contentWidth/2) } )
    transition.to( classListDate, { time=250, x=-(display.contentWidth/2) } )
    transition.to( classListSchedule, { time=250, x=-(display.contentWidth/2) } )	
end

-- Insert rows
local function insertRows(index)
	for row = 1, #scheduleTable[index].times do

		local isCategory = false
		local rowHeight = 36
		local rowColor = { default={ 1, 1, 1 }, over={ 1, 0.5, 0, 0.2 } }
		local lineColor = { 0.5, 0.5, 0.5 }

		-- Make the first row a category
		if ( row == 1 ) then
			isCategory = true
			rowHeight = 40
			rowColor = { default={ 0.8, 0.8, 0.8, 0.8 } }
			lineColor = { 1, 0, 0 }
		end

		-- Insert a row into the tableView

		classListSchedule:insertRow(
			{
				isCategory = isCategory,
				rowHeight = rowHeight,
				rowColor = rowColor,
				lineColor = lineColor
			}
		)
	end
end

local function MyTueScheduleButton ()
	dayIndex = 1
	classListSchedule.isVisible = true
	classListSchedule:deleteAllRows()
	insertRows(dayIndex)
end

local function MyWedScheduleButton ()
	dayIndex = 2
	classListSchedule.isVisible = true
	classListSchedule:deleteAllRows()
	insertRows(dayIndex)
end

local function MyThuScheduleButton ()
	dayIndex = 3
	classListSchedule.isVisible = true
	classListSchedule:deleteAllRows()
	insertRows(dayIndex)
end

local function MyFriScheduleButton ()
	dayIndex = 4
	classListSchedule.isVisible = true
	classListSchedule:deleteAllRows()
	insertRows(dayIndex)
end

local function CityButton ()
	phaseChange("CityButton")
	phasePush("CityButton")
	cityMapPage.isVisible = true
	conferenceMapPage.isVisible = false
end

local function ConferenceButton ()
	phaseChange("ConferenceButton")
	phasePush("ConferenceButton")
	conferenceMapPage.isVisible = true
	cityMapPage.isVisible = false
end

local function IdeaWallButton ()
	local function proceed (event)
		if "clicked" == event.action then
	        if 1 == event.index then	
				phaseChange("IdeaWallButton")
				phasePush("IdeaWallButton")
				ideaWallPage.isVisible = true
				classFeedbackPage.isVisible = false
				classListFeedback.isVisible = true
				conferenceFeedbackPage.isVisible = false
				--loadingSpinner()
			elseif 2 == event.index then
				FeedbackSubTab:setSelected(2, false)
			end
		end
	end

	if phaseCur == "ClassSurvey" then
		local alert = native.showAlert( "Warning", "If you leave this page any information you have entered will be lost, are you sure you want to leave?", { "Yes", "Cancel" }, proceed )
	else
		phaseChange("IdeaWallButton")
		phasePush("IdeaWallButton")
		ideaWallPage.isVisible = true
		classFeedbackPage.isVisible = false
		classListFeedback.isVisible = true
		conferenceFeedbackPage.isVisible = false
		--loadingSpinner()
	end		
end

local function ClassFeedbackButton ()
	phaseChange("ClassFeedbackButton")
	phasePush("ClassFeedbackButton")
	ideaWallPage.isVisible = false
	classFeedbackPage.isVisible = false
	classListFeedback.isVisible = true
	conferenceFeedbackPage.isVisible = false
end

local function ConferenceFeedbackButton ()
	local function proceed (event)
		if "clicked" == event.action then
	        if 1 == event.index then	
				phaseChange("ConferenceFeedbackButton")
				phasePush("ConferenceFeedbackButton")
				ideaWallPage.isVisible = false
				classFeedbackPage.isVisible = false
				classListFeedback.isVisible = true
				conferenceFeedbackPage.isVisible = true
			elseif 2 == event.index then
				FeedbackSubTab:setSelected(2, false)
			end
		end
	end

	local function okClicked ( event )
		if "clicked" == event.action then
		end
	end

	if phaseCur == "ClassSurvey" then
		local alert = native.showAlert( "Warning", "If you leave this page any information you have entered will be lost, are you sure you want to leave?", { "Yes", "Cancel" }, proceed )
	else
		if (isFriday == false) then
			native.showAlert( "Information", "The Spillman Users' Conference satisfaction survey will be available Friday", { "OK" }, okClicked )
		else
			phaseChange("ConferenceFeedbackButton")
			phasePush("ConferenceFeedbackButton")
			ideaWallPage.isVisible = false
			classFeedbackPage.isVisible = false
			classListFeedback.isVisible = true
			conferenceFeedbackPage.isVisible = true
		end
	end		
end

local function TrendingButton ()
	phaseChange("TrendingButton")
	phasePush("TrendingButton")
	trendingPage.isVisible = true
	likePage.isVisible = false
end

local function LikeButton ()
	phaseChange("LikeButton")
	phasePush("LikeButton")
	trendingPage.isVisible = false
	likePage.isVisible = true
end

--native.setActivityIndicator(true)

function fileExist( fname, path )
		local savedDate = nil 
		local filePath = system.pathForFile ( fname, path )
		local file = nil

		if ( filePath ) then
			file = io.open( filePath, "r" )
		end

		if ( file ) then
			savedDate = file:read( "*a" )
			file:close()
		end

		return savedDate

end

local function listener( event )
		if (event.isError) then
			print ("Network error - download failed" )
			--native.setActivityIndicator( false )
		elseif (event.phase == "ended")then 
		-- 	function for debugging connection
			--loadDB()
			--native.setActivityIndicator( false )
		end
end

local function getDateFileData()
	
	local datePathE = fileExist("datefile.txt", system.TemporaryDirectory)

	local date = fileExist("writedate.txt", system.DocumentsDirectory)
	date = tonumber( date )

	if ( date == nil ) then
		date = 0
	end
	datePathE = tonumber( datePathE )

	if ( datePathE ~= nil ) then
		if ( date ~= datePathE ) then 

			local params = {}
			params.progress = "download"
			params.response = {
				filename = "SpillmanUC.db",
				baseDirectory = system.DocumentsDirectory
			}

			print ("Making network request for SpillmanUC.db")
			network.request(
			"https://www.spillman.com/collab/uc2015/SpillmanUC.db",
			"GET",
			listener,
			params
			)

			local fileWritePath = system.pathForFile( "writedate.txt", system.DocumentsDirectory )
			local writefile = io.open(fileWritePath , "w")
			writefile:write( datePathE )
			writefile:close()

		else 
			--native.setActivityIndicator( false )
		end
	
	end
		
end

local function networkListener( event )
	if (event.isError) then
		print ("Network error - download failed" )
		native.setActivityIndicator( false )
	elseif (event.phase == "ended")then 
		getDateFileData()
	end
end

		
local params = {}
params.progress = "download" 
params.response = {
	filename = "datefile.txt",
	baseDirectory = system.TemporaryDirectory
} 
 
print("making network request for datefile.txt")
network.request(
		"https://www.spillman.com/collab/uc2015/datefile.txt",
		"GET",
		networkListener,
		params
)
	
local MapButtons = 
{
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Map_City.png",
		overFile = "assets/Map_City-s.png",
		label = "Salt Lake City",
		size = 10,
		--size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = CityButton
	},
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Map_Conference.png",
		overFile = "assets/Map_Conference-s.png",
		label = "Users' Conference",
		size = 10,
		--size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = ConferenceButton
	}
}

MapSubTab = widget.newTabBar
{
	top = 0,
	left = 0,
	width = display.contentWidth,
	height = display.contentHeight / 15,
	backgroundFile = "assets/SubTabBar.png",
    tabSelectedLeftFile = "assets/SubTabBar.png",
    tabSelectedRightFile = "assets/SubTabBar.png",
    tabSelectedMiddleFile = "assets/SubTabBar.png",
    tabSelectedFrameWidth = 0,
    tabSelectedFrameHeight = display.contentHeight / 12,
	buttons = MapButtons
}

MapSubTab.isVisible = true
MapSubTab:setSelected(0, false)

local ClassButtons = 
{
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Classes_DateTime.png",
		overFile = "assets/Classes_DateTime-s.png",
		label = "My Schedule",
		size = 10,
		--size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = MyScheduleButton
	},
{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Classes_DateTime.png",
		overFile = "assets/Classes_DateTime-s.png",
		label = "By Day/Time",
		size = 10,
		--size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = DayTimeButton
	},	
{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Classes_Track.png",
		overFile = "assets/Classes_Track-s.png",
		label = "By Track",
		size = 10,
		--size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = TrackButton
	}
}

ClassSubTab = widget.newTabBar
{
	top = 0,
	left = 0,
	width = display.contentWidth,
	height = display.contentHeight / 15,
	backgroundFile = "assets/SubTabBar.png",
    tabSelectedLeftFile = "assets/SubTabBar.png",
    tabSelectedRightFile = "assets/SubTabBar.png",
    tabSelectedMiddleFile = "assets/SubTabBar.png",
    tabSelectedFrameWidth = 0,
    tabSelectedFrameHeight = display.contentHeight / 12,
	buttons = ClassButtons
}

ClassSubTab.isVisible = true
ClassSubTab:setSelected(0, false)

local ScheduleDaysButtons = 
{
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Classes_DateTime.png",
		overFile = "assets/Classes_DateTime-s.png",
		label = "Tuesday",
		size = 10,
		id = "tuesday",
		--size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = MyTueScheduleButton
	},
{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Classes_DateTime.png",
		overFile = "assets/Classes_DateTime-s.png",
		label = "Wednesday",
		id = "wednesday",
		size = 10,
		--size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = MyWedScheduleButton
	},	
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Classes_DateTime.png",
		overFile = "assets/Classes_DateTime-s.png",
		label = "Thursday",
		id = "thursday",
		size = 10,
		--size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = MyThuScheduleButton
	},
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Classes_DateTime.png",
		overFile = "assets/Classes_DateTime-s.png",
		label = "Friday",
		id = "friday",
		size = 10,
		--size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = MyFriScheduleButton
	}
}


ScheduleSubTab = widget.newTabBar
{
	top = display.contentHeight-32,
	left = 0,
	width = display.contentWidth,
	height = display.contentHeight / 15,
	backgroundFile = "assets/SubTabBar2.png",
    tabSelectedLeftFile = "assets/SubTabBar2.png",
    tabSelectedRightFile = "assets/SubTabBar2.png",
    tabSelectedMiddleFile = "assets/SubTabBar2.png",
    tabSelectedFrameWidth = 0,
    tabSelectedFrameHeight = display.contentHeight / 12,
	buttons = ScheduleDaysButtons
}

ScheduleSubTab.isVisible = false
ScheduleSubTab:setSelected(dayIndex, false)

local SocialButtons = 
{
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Social_Trending.png",
		overFile = "assets/Social_Trending-s.png",
		label = "#SpillmanUC2016",
		size = 10,
		--size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = TrendingButton
	},
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Social_Like.png",
		overFile = "assets/Social_Like-s.png",
		label = "Like/Follow Spillman",
		size = 10,
		--size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = LikeButton
	}
}

SocialSubTab = widget.newTabBar
{
	top = 0,
	left = 0,
	width = display.contentWidth,
	height = display.contentHeight / 15,
	backgroundFile = "assets/SubTabBar.png",
    tabSelectedLeftFile = "assets/SubTabBar.png",
    tabSelectedRightFile = "assets/SubTabBar.png",
    tabSelectedMiddleFile = "assets/SubTabBar.png",
    tabSelectedFrameWidth = 0,
    tabSelectedFrameHeight = display.contentHeight / 12,
	buttons = SocialButtons
}

SocialSubTab.isVisible = true
SocialSubTab:setSelected(0, false)

local FeedbackButtons = 
{
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Feedback_IdeaWall.png",
		overFile = "assets/Feedback_IdeaWall-s.png",
		label = "R&D Idea Wall",
		size = 10,
		--size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = IdeaWallButton
	},
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Feedback_Class.png",
		overFile = "assets/Feedback_Class-s.png",
		label = "Class Surveys",
		size = 10,
		--size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = ClassFeedbackButton
	},
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Feedback_Help.png",
		overFile = "assets/Feedback_Help-s.png",
		label = "Conference Feedback",
		size = 10,
		--size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = ConferenceFeedbackButton
	}
}

FeedbackSubTab = widget.newTabBar
{
	top = 0,
	left = 0,
	width = display.contentWidth,
	height = display.contentHeight / 15,
	backgroundFile = "assets/SubTabBar.png",
    tabSelectedLeftFile = "assets/SubTabBar.png",
    tabSelectedRightFile = "assets/SubTabBar.png",
    tabSelectedMiddleFile = "assets/SubTabBar.png",
    tabSelectedFrameWidth = 0,
    tabSelectedFrameHeight = display.contentHeight / 12,
	buttons = FeedbackButtons
}

FeedbackSubTab.isVisible = true
FeedbackSubTab:setSelected(0, false)


local mainTabButtons = -- Create buttons table for the tab bar
{
	{
		width = (display.contentHeight / 12) / 2, 
		height = (display.contentHeight / 12) / 2,
		defaultFile = "assets/Map.png",
		overFile = "assets/Map-s.png",
		label = "Maps",
		size = 10,
		--		size = (display.contentHeight / 60),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = MapButton
	},
	{
		width = (display.contentHeight / 12) / 2, 
		height = (display.contentHeight / 12) / 2,
		defaultFile = "assets/Classes.png",
		overFile = "assets/Classes-s.png",
		label = "Classes",
		size = 10,
		--		size = (display.contentHeight / 60),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = ClassButton
	},
	{
		width = (display.contentHeight / 12) / 2, 
		height = (display.contentHeight / 12) / 2,
		defaultFile = "assets/Feedback.png",
		overFile = "assets/Feedback-s.png",
		label = "Feedback",
		size = 10,
		--		size = (display.contentHeight / 60),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = FeedbackButton
	},
	{
		width = (display.contentHeight / 12) / 2, 
		height = (display.contentHeight / 12) / 2,
		defaultFile = "assets/Social.png",
		overFile = "assets/Social-s.png",
		label = "Social",
		size = 10,
		--		size = (display.contentHeight / 60),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = SocialButton
	}
}

mainTabBar = widget.newTabBar -- Create a tab-bar and place it at the top of the screen
{
	top = 0,
	left = 0,
	width = display.contentWidth,
	height = display.contentHeight / 12,
	backgroundFile = "assets/TabBar.png",
    tabSelectedLeftFile = "assets/TabBar.png",
    tabSelectedRightFile = "assets/TabBar.png",
    tabSelectedMiddleFile = "assets/TabBar.png",
    tabSelectedFrameWidth = 0,
    tabSelectedFrameHeight = display.contentHeight / 12,
	buttons = mainTabButtons
}


function included(hash, value) -- Function for checking if a value is included
        local foundInTable = false
        for k,v in pairs(hash) do
                if v == value then
                        foundInTable = true
                        break
                end
        end
        return foundInTable
end

loadSettings()

-- Figure out which day of the conference we're on
local function getDateInfo()
	local dateToday = os.date( "*t" )

	if (dateToday.month == 9) then
		if (dateToday.day == 29) then
			dayIndex = 1
		elseif (dateToday.day == 30) then
			dayIndex = 2
		end
	elseif (dateToday.month == 10) then
		if (dateToday.day == 1) then
			dayIndex = 3
		elseif (dateToday.day == 2) then
			dayIndex = 4
			isFriday = true
		end
	end
end

getDateInfo()

local function onRowTouchDate( event )
	local phase = event.phase
	local row = event.target
	
	if "release" == phase then
		classTitle = rowTitlesDate[row.index].title
		dayIndex = rowTitlesDate[row.index].dayIndex
		timeSlot = rowTitlesDate[row.index].timeSlot
		feedbackURL = rowTitlesDate[row.index].feedbackURL
		detailsTitle.text = classTitle
		detailsPresenter.text = "Presenter: "..rowTitlesDate[row.index].classInstructor
		local hourDisplay = "hr"
		if rowTitlesDate[row.index].classLength > 1 then
			hourDisplay = "hrs"
		end
		detailsTime.text = rowTitlesDate[row.index].time1.." ("..rowTitlesDate[row.index].classLength.." "..hourDisplay..")"
		if string.len(rowTitlesDate[row.index].time2) > 4 then
			detailsTime.text = detailsTime.text.."\n"..rowTitlesDate[row.index].time2.." ("..rowTitlesDate[row.index].classLength.." "..hourDisplay..")"
		end
		detailsRoom.text = "Room: " .. rowTitlesDate[row.index].classRoom
		detailsTrack.text = rowTitlesDate[row.index].classTrack
		detailsDesc.text = rowTitlesDate[row.index].classDesc

		if included(classesScheduled[dayIndex], classTitle)==true then
			detailsFaveOff.isVisible = false
    		detailsFaveOn.isVisible = true
    	else
    		detailsFaveOff.isVisible = true
    		detailsFaveOn.isVisible = false
		end		
		phaseChange("DetailsScreen")
		phasePush("DetailsScreen")
		transition.to( detailsScreen, { time=250, x=0 } )
		transition.to( classListDate, { time=250, x=-(display.contentWidth*.5) } )
	end
end

local function findIndex( classTitle )
	local index
	for index = 1, #rowTitlesDate do
		if rowTitlesDate[index].title == classTitle then
			return index
		end
	end
	return 0
end

local function findNumTimesForClass( title )
	local index
	local totalTimes = 0
	for index = 1, #rowTitlesDate do
		if rowTitlesDate[index].title == title then
			totalTimes = totalTimes + 1
		end
	end
	return totalTimes
end

local function createTrackTimeDetails( className )
	local index
	local j
	rowTitlesDateTime = {}
	classListDateTime:deleteAllRows()
	for index = 1, #ByDateData do
		for j = 1, #ByDateData[index].items do
			if ByDateData[index].items[j].name == className then
				rowTitlesDateTime[ #rowTitlesDateTime + 1 ] = { 
					title = ByDateData[index].time,
					dayIndex = ByDateData[index].day,
					timeSlot = ByDateData[index].timeSlot,
					classLength = 0
				}

				--Insert the category
				classListDateTime:insertRow{
					rowHeight = 20,
					rowColor =
					{ 
						default = { 150/255, 160/255, 180/255, 200/255 },
					},
					isCategory = true,
				}

				--Add the rows item title
				rowTitlesDateTime[ #rowTitlesDateTime + 1 ] = {
					title = ByDateData[index].items[j].name,
					dayIndex = ByDateData[index].day,
					timeSlot = ByDateData[index].timeSlot,
					classLength = ByDateData[index].items[j].length,
					time = ByDateData[index].time,
					classTitleFull = title,
					classInstructor = ByDateData[index].items[j].presenter,
					classTrack = ByDateData[index].items[j].track,
					classDesc = ByDateData[index].items[j].description,
					classRoom = ByDateData[index].items[j].classRoom,
					feedbackURL = ByDateData[index].items[j].feedbackURL,
				}

				--Insert the item
				classListDateTime:insertRow{
					rowHeight = 20,
					isCategory = false,
					listener = onRowTouchDate
				}
			end
		end
	end
end

local function onRowTouchTrack( event )
	local phase = event.phase
	local row = event.target
	
	if "release" == phase then
		classTitle = rowTitlesTrack[row.index].title
    	local numClassTimes = 1
		if string.len(rowTitlesTrack[row.index].time2) > 4 then
			numClassTimes = 2
		end
		
    	if numClassTimes > 1 then
			createTrackTimeDetails(classTitle, classTrack)
			MakeInvisibleAll()
			detailsScreen.isVisible = true
			classListScreen.isVisible = true
			transition.to( classListTrack, { time=250, x=-display.contentWidth/2 })
			transition.to( classListScreen, { time=250, x=0 } )
			phaseChange("TrackTimeList")
   		else
			local index = findIndex(classTitle)
			if index == 0 then
				print("findIndex Failed for class", classTitle)
				return
			end
			dayIndex = rowTitlesDate[index].dayIndex
			timeSlot = rowTitlesDate[index].timeSlot

			classTitle = rowTitlesTrack[row.index].title
			feedbackURL = rowTitlesTrack[row.index].feedbackURL
			detailsTitle.text = classTitle
			detailsPresenter.text = "Presenter: "..rowTitlesTrack[row.index].classInstructor
			local hourDisplay = "hr"
			if rowTitlesTrack[row.index].classLength > 1 then
				hourDisplay = "hrs"
			end
			detailsTime.text = rowTitlesTrack[row.index].time1.." ("..rowTitlesTrack[row.index].classLength.." "..hourDisplay..")"
			detailsRoom.text = rowTitlesTrack[row.index].classRoom
			detailsTrack.text = rowTitlesTrack[row.index].classTrack
			detailsDesc.text = rowTitlesTrack[row.index].classDesc

			if (included(classesScheduled[dayIndex], classTitle)==true) then
				detailsFaveOff.isVisible = false
				detailsFaveOn.isVisible = true
			else
				detailsFaveOff.isVisible = true
				detailsFaveOn.isVisible = false
			end
			phaseChange("DetailsScreen")
			phasePush("DetailsScreen")
			-- move the details screen to visible area, and move the class list by track screen off
			transition.to( detailsScreen, { time=250, x=0 } )
			transition.to( classListTrack, { time=250, x=-(display.contentWidth*.5) } )
		end
	end
end

local function onRowTouchDateTime( event )
	local phase = event.phase
	local row = event.target
	
	if "release" == phase then
		classTitle = rowTitlesDateTime[row.index].title
		dayIndex = rowTitlesDateTime[row.index].dayIndex
		timeSlot = rowTitlesDateTime[row.index].timeSlot
		feedbackURL = rowTitlesDateTime[row.index].feedbackURL
		detailsTitle.text = classTitle
		detailsPresenter.text = "Presenter: "..rowTitlesDateTime[row.index].classInstructor
		local hourDisplay = "hr"
		if rowTitlesDateTime[row.index].classLength > 1 then
			hourDisplay = "hrs"
		end
		detailsTime.text = rowTitlesDateTime[row.index].time.." ("..rowTitlesDateTime[row.index].classLength.." "..hourDisplay..")"
		detailsRoom.text = rowTitlesDateTime[row.index].classRoom
		detailsTrack.text = rowTitlesDateTime[row.index].classTrack
		detailsDesc.text = rowTitlesDateTime[row.index].classDesc

		if included(classesScheduled[dayIndex], classTitle)==true then
			detailsFaveOff.isVisible = false
    		detailsFaveOn.isVisible = true
    	else
    		detailsFaveOff.isVisible = true
    		detailsFaveOn.isVisible = false
		end		
		phaseChange("DetailsScreen")
		phasePush("DetailsScreen")
		detailsScreen.isVisible = true
		transition.to( detailsScreen, { time=250, x=0 } )
		transition.to( classListScreen, { time=250, x=-display.contentWidth/2 } )
	end
end

local function createDateTimeDetails(day, slot)
	local index
	local j
	for index = 1, #ByDateData do
		if (ByDateData[index].day == day and ByDateData[index].timeSlot == slot) then
			--Add the rows category title
			rowTitlesDateTime = {}
			classListDateTime:deleteAllRows()
			rowTitlesDateTime[ #rowTitlesDateTime + 1 ] = {
				title = ByDateData[index].time,
				dayIndex = ByDateData[index].day,
				timeSlot = ByDateData[index].timeSlot,
				classLength = 0
			}
			
			--Insert the category
			classListDateTime:insertRow{
				rowHeight = 20,
				rowColor =
				{
					default = { 150/255, 160/255, 180/255, 200/255 },
				},
				isCategory = true,
			}

			--Insert the item
			for j = 1, #ByDateData[index].items do
				--Add the rows item title
				rowTitlesDateTime[ #rowTitlesDateTime + 1 ] = {
					title = ByDateData[index].items[j].name,
					dayIndex = ByDateData[index].day,
					timeSlot = ByDateData[index].timeSlot,
					classLength = ByDateData[index].items[j].length,
					time = ByDateData[index].time,
					classTitleFull = title,
					classInstructor = ByDateData[index].items[j].presenter,
					classTrack = ByDateData[index].items[j].track,
					classDesc = ByDateData[index].items[j].description,
					classRoom = ByDateData[index].items[j].classRoom,
					feedbackURL = ByDateData[index].items[j].feedbackURL,
				}

				--Insert the item
				classListDateTime:insertRow{
					rowHeight = 20,
					isCategory = false,
					listener = onRowTouchDate
				}
			end
		end
	end
end

local function onRowTouchSchedule( event )
	local row = event.target
	
	if "release" == event.phase then
		if (scheduleTable[dayIndex].classes[row.index].timeSlot > 0) then
			timeSlot = scheduleTable[dayIndex].classes[row.index].timeSlot

			if (classesScheduled[dayIndex][timeSlot] == "") then
				createDateTimeDetails(dayIndex, timeSlot)
				MakeInvisibleAll()
				detailsScreen.isVisible = true
				classListScreen.isVisible = true
				transition.to( classListSchedule, { time=250, x=-display.contentWidth/2 } )
				transition.to( classListScreen, { time=250, x=0 } )
				phaseChange("DateTimeList")
				phasePush("DateTimeList")
			else
				classTitle = classesScheduled[dayIndex][timeSlot]
				local index = findIndex(classTitle)
				classTitle = rowTitlesDate[index].title
				dayIndex = rowTitlesDate[index].dayIndex
				timeSlot = rowTitlesDate[index].timeSlot
				feedbackURL = rowTitlesDate[index].feedbackURL
				detailsTitle.text = classTitle
				detailsPresenter.text = "Presenter: "..rowTitlesDate[index].classInstructor
				local hourDisplay = "hr"
				if rowTitlesDate[row.index].classLength > 1 then
					hourDisplay = "hrs"
				end
				detailsTime.text = rowTitlesDate[index].time1.." ("..rowTitlesDate[index].classLength.." "..hourDisplay..")"
				if string.len(rowTitlesDate[index].time2) > 4 then
					detailsTime.text = detailsTime.text.."\n"..rowTitlesDate[index].time2.." ("..rowTitlesDate[index].classLength.." "..hourDisplay..")"
				end		
				detailsRoom.text = rowTitlesDate[index].classRoom
				detailsTrack.text = rowTitlesDate[index].classTrack
				detailsDesc.text = rowTitlesDate[index].classDesc

				detailsFaveOff.isVisible = false
				detailsFaveOn.isVisible = true
				transition.to( detailsScreen, { time=250, x=0 } )
				transition.to( classListSchedule, { time=250, x=-(display.contentWidth*.5) } )
				phaseChange("DetailsScreen")
				phasePush("DetailsScreen")
			end
		end
	end
end

local function onRowTouchFeedback( event )
	local phase = event.phase
	local row = event.target
	
	if "release" == phase then
		classTitle = rowTitlesFeedback[row.index].name

		--getClassDetails()

		print("Requesting page: " .. rowTitlesFeedback[row.index].feedbackURL)

		classFeedbackPage:request( rowTitlesFeedback[row.index].feedbackURL )
		classFeedbackPage.isVisible = true
		phaseChange("ClassSurvey")
		phasePush("ClassSurvey")
		classListFeedback.isVisible = false
	end
end

-- Row Render Methods

local function onRowRenderDate( event )
	local phase = event.phase
	local row = event.row
	local isCategory = row.isCategory
	local groupContentHeight = row.contentHeight
	if (rowTitlesDate[row.index].title == nil) then
		rowTitle = display.newText( row, "BOGUS" .. row.index, 0, 0, native.systemFontBold, 12 )
	else
		rowTitle = display.newText( row, rowTitlesDate[row.index].title, 0, 0, native.systemFontBold, 12 )
	end
	rowTitle.x = 10
	rowTitle.anchorX = 0
	rowTitle.y = groupContentHeight / 2
	rowTitle:setFillColor( 0, 0, 0 )

	if not isCategory then
		local rowArrow = display.newImage( row, "assets/rowArrow.png", false )
		rowArrow.x = row.contentWidth - 10
		rowArrow.anchorX = 1 -- we set the image anchorX to 1, so the object is x-anchored at the right
		rowArrow.y = groupContentHeight / 2
	end
end

local function onRowRenderDateTime( event )
	local phase = event.phase
	local row = event.row
	local isCategory = row.isCategory
	local groupContentHeight = row.contentHeight
	rowTitle = display.newText( row, rowTitlesDateTime[row.index].title, 0, 0, native.systemFontBold, 12 )
	rowTitle.x = 10
	rowTitle.anchorX = 0
	rowTitle.y = groupContentHeight / 2
	rowTitle:setFillColor( 0, 0, 0 )
	
	if not isCategory then
		local rowArrow = display.newImage( row, "assets/rowArrow.png", false )
		rowArrow.x = row.contentWidth - 10
		rowArrow.anchorX = 1 -- we set the image anchorX to 1, so the object is x-anchored at the right
		rowArrow.y = groupContentHeight / 2
	end
end

local function onRowRenderTrack( event )
	local phase = event.phase
	local row = event.row
	local isCategory = row.isCategory
	local groupContentHeight = row.contentHeight
	if rowTitlesTrack[row.index].title ~= nil then
		rowTitle = display.newText( row, rowTitlesTrack[row.index].title, 0, 0, native.systemFontBold, 12 )
	else
		rowTitle = display.newText( row, "Bogus" .. row.index, 0, 0, native.systemFontBold, 12 )
	end
	rowTitle.x = 10
	rowTitle.anchorX = 0
	rowTitle.y = groupContentHeight / 2
	rowTitle:setFillColor( 0, 0, 0 )
	
	if not isCategory then
		local rowArrow = display.newImage( row, "assets/rowArrow.png", false )
		rowArrow.x = row.contentWidth - 10
		rowArrow.anchorX = 1 -- we set the image anchorX to 1, so the object is x-anchored at the right
		rowArrow.y = groupContentHeight / 2
	end
end

local function onRowRenderFeedback( event )
	local phase = event.phase
	local row = event.row
	local params = event.params
	local isCategory = row.isCategory
	local groupContentHeight = row.contentHeight
	if (rowTitlesFeedback[row.index] == nil) then
		rowTitle = display.newText( row, "BOGUS" .. row.index, 0, 0, native.systemFontBold, 12 )
	else
		rowTitle = display.newText( row, rowTitlesFeedback[row.index].name, 0, 0, native.systemFontBold, 12 )
	end
	rowTitle.x = 10
	rowTitle.anchorX = 0
	rowTitle.y = groupContentHeight / 2
	rowTitle:setFillColor( 0, 0, 0 )
	
	if not isCategory then
		local rowArrow = display.newImage( row, "assets/rowArrow.png", false )
		rowArrow.x = row.contentWidth - 10
		rowArrow.anchorX = 1 -- we set the image anchorX to 1, so the object is x-anchored at the right
		rowArrow.y = groupContentHeight / 2
	end
end

local function onRowRenderDailySchedule( event )

    -- Get reference to the row group
    local row = event.row
 
    -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
	
    if (row.index == 1) then
        local rowHeader = display.newText( row, scheduleTable[dayIndex].classes[row.index].name, 20, 10, native.systemFont, 20 )
        rowHeader:setFillColor( 0 )
    	-- Align the label left and vertically centered
        rowHeader.anchorX = 0
        rowHeader.x = 80
        rowHeader.y = rowHeight / 2
   else
   		local className
   		local rowTime

   		if (scheduleTable[dayIndex].classes[row.index].timeSlot == 0) then
   			className = scheduleTable[dayIndex].classes[row.index].name
        	rowTime = display.newText( row, scheduleTable[dayIndex].times[row.index] .. className, 20, 10, native.systemFont, 15 )
			rowTime:setFillColor( 0 )
  		else
   			className = classesScheduled[dayIndex][scheduleTable[dayIndex].classes[row.index].timeSlot]
   			if className == "" then
   				className = "Touch to schedule class"
				rowTime = display.newText( row, scheduleTable[dayIndex].times[row.index] .. className, 20, 10, native.systemFontBold, 15 )
				rowTime:setFillColor( 0.25, 0.5, 0.95 )
  			else
				rowTime = display.newText( row, scheduleTable[dayIndex].times[row.index] .. className, 20, 10, native.systemFontBold, 15 )
				rowTime:setFillColor( 0 )
			end
  		end
    	-- Align the label left and vertically centered
        --rowTime:setFillColor( 0 )
        rowTime.anchorX = 0
        rowTime.x = 0
        rowTime.y = rowHeight / 2
    end
end

classListDateTime = widget.newTableView
{
	top = (display.contentHeight/12)+(display.contentHeight/15),
	width = display.contentWidth, 
	height = display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)) - 60,
	maskFile = "mask-320x448.png",
	onRowRender = onRowRenderDateTime,
	onRowTouch = onRowTouchDateTime,
	rowTouchDelay = .25,
}

classListBack = display.newImageRect ("assets/detailsArrow.png", 50, 50)
classListBack.x = display.contentWidth / 2
classListBack.y = display.contentHeight - 50

classListScreen = display.newGroup()
classListScreen:insert( classListDateTime )
classListScreen:insert( classListBack )
classListScreen.isVisible = false
transition.to( classListScreen, { time=250, x=display.contentWidth } )

classListDate = widget.newTableView
{
	top = (display.contentHeight/12)+(display.contentHeight/15),
	width = display.contentWidth, 
	height = display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)),
	maskFile = "mask-320x448.png",
	onRowRender = onRowRenderDate,
	onRowTouch = onRowTouchDate,
	rowTouchDelay = .25,
}

classListDate.isVisible = false
transition.to( classListDate, { time=250, x=-(display.contentWidth*.5) } )

function classListBack:touch( event )
    if event.phase == "began" then
    	if (phaseCur == "TrackTimeList") then
    		transition.to( classListTrack, { time=250, x=display.contentWidth/2 } )
    		classListTrack.isVisible = true
	        transition.to( classListScreen, { time=250, x=display.contentWidth } )
    		phaseCur = "TrackButton"
    		phasePrev = "ClassButton"
    	else
			classListSchedule:deleteAllRows()
			insertRows(dayIndex)
	        classListSchedule.isVisible = true
	        ScheduleSubTab.isVisible = true
	        transition.to( classListSchedule, { time=250, x=display.contentWidth/2 } )
	        transition.to( classListScreen, { time=250, x=display.contentWidth } )
	        phaseCur = "MyScheduleButton"
	        phasePrev = "ClassButton"
	    end
        return true
    end
end

classListBack:addEventListener( "touch", classListBack )

classListTrack = widget.newTableView
{
	top = (display.contentHeight/12)+(display.contentHeight/15),
	width = display.contentWidth,
	height = display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)),
	maskFile = "mask-320x448.png",
	onRowRender = onRowRenderTrack,
	onRowTouch = onRowTouchTrack,
	rowTouchDelay = .25,
}

classListTrack.isVisible=false
transition.to( classListTrack, { time=250, x=-(display.contentWidth*.5) } )

classListFeedback = widget.newTableView
{
	top = (display.contentHeight/12)+(display.contentHeight/15),
	width = display.contentWidth,
	height = display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)),
	maskFile = "mask-320x448.png",
	onRowRender = onRowRenderFeedback,
	onRowTouch = onRowTouchFeedback,
	rowTouchDelay = .25,
}

classListFeedback.isVisible=false

-- Create the widget
classListSchedule = widget.newTableView
{
	top = (display.contentHeight/12)+(display.contentHeight/15),
	width = display.contentWidth,
	height = display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)) - 30,
	maskFile = "mask-320x448.png",
    onRowRender = onRowRenderDailySchedule,
    onRowTouch = onRowTouchSchedule,
    listener = scrollListener,
    rowTouchDelay = .25,
}

classListSchedule.isVisible = false
transition.to( classListSchedule, { time=250, x=-(display.contentWidth / 2) } )

Runtime:addEventListener("unhandledError", myUnhandledErrorListener)

loadDB()

dayIndex = 1
insertRows(dayIndex)

local function setupClassListDate()
	local index
	local j
	for index = 1, #ByDateData do
		--Add the rows category title
		rowTitlesDate[ #rowTitlesDate + 1 ] = {
			title = ByDateData[index].time,
			dayIndex = ByDateData[index].day,
			timeSlot = ByDateData[index].timeSlot,
			classLength = 0
		}
		
		--Insert the category
		classListDate:insertRow{
			rowHeight = 20,
			rowColor =
			{ 
				default = { 150/255, 160/255, 180/255, 200/255 },
			},
			isCategory = true,
		}
		
		--Insert the item
		for j = 1, #ByDateData[index].items do
			--Add the rows item title
			rowTitlesDate[ #rowTitlesDate + 1 ] = { 
				title = ByDateData[index].items[j].name,
				dayIndex = ByDateData[index].day,
				timeSlot = ByDateData[index].timeSlot,
				classLength = ByDateData[index].items[j].length,
				classTitleFull = title,
				classInstructor = ByDateData[index].items[j].presenter,
				classRoom = ByDateData[index].items[j].classRoom,
				classTrack = ByDateData[index].items[j].track,
				classDesc = ByDateData[index].items[j].description,
				feedbackURL = ByDateData[index].items[j].feedbackURL,
				time1 = ByDateData[index].items[j].time1,
				time2 = ByDateData[index].items[j].time2,
			}
			
			--Insert the item
			classListDate:insertRow{
				rowHeight = 20,
				isCategory = false,
				listener = onRowTouchDate
			}
		end
	end
end

local function setupTrackList()
	local index
	local j
	for index = 1, #ByTrackData do
		--Add the rows category title
		rowTitlesTrack[ #rowTitlesTrack + 1 ] = {
			title = ByTrackData[index].title
		}
		
		--Insert the category
		classListTrack:insertRow{
			rowHeight = 20,
			rowColor = 
			{ 
				default = { 150/255, 160/255, 180/255, 200/255 },
			},
			isCategory = true,
		}

		--Insert the item
		for j = 1, #ByTrackData[index].items do
			--Add the rows item title
			rowTitlesTrack[ #rowTitlesTrack + 1 ] = {
				title = ByTrackData[index].items[j].name,
				classLength = ByTrackData[index].items[j].length,
				classTitleFull = title,
				classInstructor = ByTrackData[index].items[j].presenter,
				classTrack = ByTrackData[index].items[j].track,
				classDesc = ByTrackData[index].items[j].description,
				time1 = ByTrackData[index].items[j].time1,
				time2 = ByTrackData[index].items[j].time2,
			}
			
			--Insert the item
			classListTrack:insertRow{
				rowHeight = 20,
				isCategory = false,
				listener = onRowTouchTrack
			}
		end
	end
end

local function setupFeedbackList()
	local index
	local j
	for index = 1, #ByDateData do
		--Add the rows category title
		rowTitlesFeedback[ #rowTitlesFeedback + 1 ] = {
			name = ByDateData[index].time,
			feedbackURL = nil,
		}
		
		--Insert the category
		classListFeedback:insertRow{
			rowHeight = 20,
			rowColor =
			{ 
				default = { 150/255, 160/255, 180/255, 200/255 },
			},
			isCategory = true,
		}

		--Insert the item
		for j = 1, #ByDateData[index].items do
			--Add the rows item title
			rowTitlesFeedback[ #rowTitlesFeedback + 1 ] = {
				name = ByDateData[index].items[j].name,
				feedbackURL = ByDateData[index].items[j].feedbackURL,
			}

			--Insert the item
			classListFeedback:insertRow{
				rowHeight = 20,
				isCategory = false,
				listener = onRowTouchFeedback
			}
		end
	end
end

setupClassListDate()
setupTrackList()
setupFeedbackList()

print("done with setup stuff")
detailsBacking = display.newImageRect("assets/WhiteBacking.png", display.contentWidth, display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)))
detailsBacking.x = display.contentWidth*.5
detailsBacking.y = (display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)))/2 + ((display.contentHeight/12)+(display.contentHeight/15))

local titleOptions = 
{
    text = classTitle,     
    x = display.contentWidth*.5,
    y = display.contentHeight*.25,
    width = display.contentWidth-25,     --required for multi-line and alignment
    height = 75, 
    font = native.systemFontBold,   
    fontSize = 12,
    align = "center"  --new alignment parameter
}

detailsTitle = display.newText( titleOptions )
detailsTitle:setFillColor( (252/255), (181/255), (45/255) )

detailsPresenter = display.newText( "Presenter:"..classInstructor, display.contentWidth*.5, display.contentHeight*.25, native.systemFont, 12 )
detailsPresenter:setFillColor( (96/255), (103/255), (105/255) )

detailsRoom = display.newText( classRoom, display.contentWidth / 2, display.contentHeight*.30, native.systemFont, 12 )
detailsRoom:setFillColor( (96/255), (103/255), (105/255) )

detailsMap = display.newImageRect("assets/Map_Conference-s.png", 16, 16)
detailsMap.x = display.contentWidth*.3
detailsMap.y = display.contentHeight*.3

detailsTrack = display.newText( classTrack, display.contentWidth / 2, display.contentHeight*.35, native.systemFont, 12 )
detailsTrack:setFillColor( (96/255), (103/255), (105/255) )

local timeOptions = 
{
    text = classTime,     
    x = display.contentWidth / 2,
    y = display.contentHeight*.475,
    width = display.contentWidth-25,     --required for multi-line and alignment
    height = 75, 
    font = native.systemFont,   
    fontSize = 12,
    align = "center"  --new alignment parameter
}

detailsTime = display.newText( timeOptions )
detailsTime:setFillColor( (96/255), (103/255), (105/255) )

detailsDesc = display.newText( classDesc, display.contentWidth / 2, display.contentHeight*.7, display.contentWidth-25, 200, native.systemFont, 10, "center" )
detailsDesc:setFillColor( (96/255), (103/255), (105/255) )

detailsFeedback = display.newImageRect ("assets/Details_Feedback.png", 30, 38)
detailsFeedback.x = display.contentWidth*.15
detailsFeedback.y = display.contentHeight*.85

detailsFaveOff = display.newImageRect ("assets/add_class.png", 35, 32)
detailsFaveOff.x = display.contentWidth*.85
detailsFaveOff.y = display.contentHeight*.85
detailsFaveOn = display.newImageRect ("assets/remove_class.png", 35, 32)
detailsFaveOn.x = display.contentWidth*.85
detailsFaveOn.y = display.contentHeight*.85

detailsBack = display.newImageRect ("assets/detailsArrow.png", 50, 50)
detailsBack.x = display.contentWidth/2
detailsBack.y = display.contentHeight*.925

function detailsBack:touch( event )
    if event.phase == "began" then
        transition.to( detailsScreen, { time=250, x=display.contentWidth } )
        classListSchedule:deleteAllRows()
		insertRows(dayIndex)
		if (phasePrev == "MyScheduleButton") then
			phaseCur = phasePrev
			transition.to( classListSchedule, { time=250, x=(display.contentWidth*.5) } )
			classListSchedule.isVisible = true
		elseif phasePrev == "DayTimeButton" then
			phaseCur = phasePrev
			transition.to( classListDate, { time=250, x=(display.contentWidth*.5) } )
			classListDate.isVisible = true
		elseif phasePrev == "TrackButton" then
			phaseCur = phasePrev
			transition.to( classListTrack, { time=250, x=(display.contentWidth*.5) } )
			classListTrack.isVisible = true
		elseif phasePrev == "DateTimeList" then
			phaseCur = phasePrev
			transition.to( classListScreen, { time=250, x=0 } )
			classListDateTime.isVisible = true
			classListScreen.isVisible = true
		elseif phasePrev == "TrackTimeList" then
    		transition.to( classListScreen, { time=250, x=0 } )
    		classListScreen.isVisible = true
    		phaseCur = "TrackTimeList"
    		phasePrev = "TrackButton"
		end
        phasePrev = "ClassButton"
        return true
    end
end

function detailsMap:touch( event )
    if event.phase == "began" then
		conferenceMapPage.isVisible = true
		phaseChange("DetailsMap")
		phasePush("DetailsMap")

    	if (system.getInfo("model") == "iPad" or system.getInfo("model") == "iPhone" or system.getInfo("model") == "iPod") then
     		ClassSubTab:setSelected(0, false)
     	end
        return true
    end
end

function detailsRoom:touch( event )
    if event.phase == "began" then
		conferenceMapPage.isVisible = true
		phaseChange("DetailsMap")
		phasePush("DetailsMap")
    	if (system.getInfo("model") == "iPad" or system.getInfo("model") == "iPhone" or system.getInfo("model") == "iPod") then
     		ClassSubTab:setSelected(0, false)
     	end		
        return true
    end
end

local function findClassDetails( title, day )
	local index
	for index = 1, #rowTitlesDate do
		if rowTitlesDate[index].title == title then
			if rowTitlesDate[index].dayIndex == day then
				return rowTitlesDate[index]
			end
		end
	end
end

local function printClassDetails( count )
	local index
	for index = 1, count do
		local message = "title: " .. rowTitlesDate[index].title .. " dayIndex: " .. rowTitlesDate[index].dayIndex .. " slot: " .. rowTitlesDate[index].timeSlot .. " length: " .. rowTitlesDate[index].classLength
		print(message)
	end
end

local rowInfo = {}

local function unscheduleMultiHourClass( event )
	local idx
	local index = rowInfo.dayIndex
	local slot = rowInfo.timeSlot
	if event.action == "clicked" then
		-- User clicked "OK"
        if event.index == 1 then
        	for idx = 1, rowInfo.classLength do
        		if (classesScheduled[rowInfo.dayIndex][slot] == nil) then
        			slot = 1
        			index= index + 1
        		end
	    		classesScheduled[index][slot] = ""
	    		slot = slot+ 1
			end
			detailsFaveOff.isVisible = true
			detailsFaveOn.isVisible = false
       end
    end
end

local function removeClass( title )
	local idx
	for index = 1, 4 do
		for slot = 1, 5 do
			if classesScheduled[index][slot] == nil then
				break
			elseif classesScheduled[index][slot] == title then
				classesScheduled[index][slot] = ""
			end
		end
	end
end

local function addMultiHourClass( event )
	local idx
	local index = rowInfo.dayIndex
	local slot = rowInfo.timeSlot
	if event.action == "clicked" then
		-- User clicked "OK"
        if event.index == 1 then
        	for idx = 1, rowInfo.classLength do
        		if (classesScheduled[index][slot] == nil) then
        			slot = 1
        			index = index + 1
        		end
        		if classesScheduled[index][slot] ~= "" then
        			removeClass(classesScheduled[index][slot])
        		end
	    		classesScheduled[index][slot] = classTitle
	    		slot = slot + 1
			end
			detailsFaveOff.isVisible = false
			detailsFaveOn.isVisible = true
    		ScheduleSubTab:setSelected(dayIndex, false)
 	   		saveSettings()
       end
    end
end

-- Function called when scheduling a class
function detailsFaveOff:touch( event )

	local function replaceClass( event )
		if event.action == "clicked" then
	        if event.index == 1 then
	        	-- if overwriting a multi-hour class, need to clear all the slots first
				removeClass(classesScheduled[dayIndex][timeSlot])
    			classesScheduled[dayIndex][timeSlot] = classTitle
    			ScheduleSubTab:setSelected(dayIndex, false)
				detailsFaveOff.isVisible = false
				detailsFaveOn.isVisible = true
	   			saveSettings()
	        end
	    end
	end

    if event.phase == "began" then
    	rowInfo = findClassDetails(classTitle, dayIndex)
		-- Is this a multi-hour class?
    	if rowInfo.classLength > 1 then
			-- check for a multi-hour class to be replaced
  			local alert = native.showAlert("Multi-hour Class", "This class spans multiple hours. If it overlaps another scheduled class, that class will be removed. Do you want to continue?", { "Yes", "Cancel" }, addMultiHourClass )
  		else
	    	if classesScheduled[dayIndex][timeSlot] == "" then
	    		classesScheduled[dayIndex][timeSlot] = classTitle
				detailsFaveOff.isVisible = false
				detailsFaveOn.isVisible = true
				ScheduleSubTab:setSelected(dayIndex, false)
	    	else
				-- check for a multi-hour class to be replaced
				local message = "You already have the class \"" .. classesScheduled[dayIndex][timeSlot] .. "\" scheduled for this time, do you want to replace it with this class?"
				local alert = native.showAlert("Class Scheduled", message, { "Yes", "Cancel" }, replaceClass )
	     	end
	    end
	   	saveSettings()
        return true
    end
end

-- Function called when un-scheduling a class
function detailsFaveOn:touch( event )
   if event.phase == "began" then
    	rowInfo = findClassDetails(classTitle, dayIndex)
    	if rowInfo.classLength > 1 then
  			local alert = native.showAlert("Multi-hour Class", "This class spans multiple hours. This will remove the class from all scheduled slots. Do you want to continue?", { "Yes", "Cancel" }, unscheduleMultiHourClass )
  		else
	    	classesScheduled[dayIndex][timeSlot] = ""
	   		detailsFaveOff.isVisible = true
	    	detailsFaveOn.isVisible = false
    	end
    	saveSettings()
		return true
    end
end

function detailsFeedback:touch( event )
   if event.phase == "began" then

   		print("Requesting feedback url page " .. feedbackURL)
    	classFeedbackPage:request( feedbackURL)
    	classFeedbackPage.isVisible = true
		phaseCur = "DetailsFeedback"
    	if (system.getInfo("model") == "iPad" or system.getInfo("model") == "iPhone" or system.getInfo("model") == "iPod") then
     		ClassSubTab:setSelected(0, false)
     	end		
        return true
    end
end

detailsMap:addEventListener( "touch", detailsMap )
detailsRoom:addEventListener( "touch", detailsRoom )
detailsFaveOff:addEventListener( "touch", detailsFaveOff )
detailsFaveOn:addEventListener( "touch", detailsFaveOn )
detailsFeedback:addEventListener( "touch", detailsFeedback )
detailsBack:addEventListener( "touch", detailsBack )

detailsScreen = display.newGroup()
detailsScreen:insert( detailsBacking )
detailsScreen:insert( detailsTitle )
detailsScreen:insert( detailsPresenter )
detailsScreen:insert( detailsTime )
detailsScreen:insert( detailsRoom )
detailsScreen:insert( detailsTrack )
detailsScreen:insert( detailsDesc )
detailsScreen:insert( detailsBack )
detailsScreen:insert( detailsMap )
detailsScreen:insert( detailsFeedback )
detailsScreen:insert( detailsFaveOff )
detailsScreen:insert( detailsFaveOn )
local db = nil

-- Handle the "applicationExit" event to close the database
local function onSystemEvent( event )
    if ( event.type == "applicationExit" ) then
        --db:close()
    elseif event.type == "applicationResume" then
    	print("Received a resume event")
    	getDateInfo()
    	if isFriday == true then
    	end
    end
end

local function onKeyEvent( event )	-- Android Key Press event handler
	local returnValue = true
	local keyName = event.keyName
	local keyPhase = event.phase

	if ((keyName == "back") and (keyPhase == "down"))  or ("b" == keyName and keyPhase == "down" and system.getInfo("environment") == "simulator") then	--BACK KEY (BACK PAGES)		
		if phaseCur == "home" then
			native.requestExit()
		elseif phaseCur == "DateTimeList" then
	        classListSchedule:deleteAllRows()
			insertRows(dayIndex)
			mainTabBar:setSelected(2, true)
			ClassSubTab:setSelected(1, true)
			phasePrev = "ClassButton"
		elseif phaseCur == "DetailsScreen" then
       			transition.to( detailsScreen, { time=250, x=display.contentWidth } )
			if (phasePrev == "DateTimeList") then
        		classListSchedule:deleteAllRows()
				insertRows(dayIndex)
				transition.to( classListScreen, { time=250, x=0 } )
				classListDateTime.isVisible = true
				classListScreen.isVisible = true
				phaseCur = phasePrev
				phasePrev = "MyScheduleButton"
			elseif phasePrev == "DayTimeButton" then
 				transition.to( classListDate, { time=250, x=display.contentWidth/2 } )
				classListDate.isVisible = true
				phaseCur = phasePrev
				phasePrev = "ClassButton"
			elseif phasePrev == "TrackButton" then
  				transition.to( classListTrack, { time=250, x=display.contentWidth/2 } )
				classListTrack.isVisible = true
				phaseCur = phasePrev
				phasePrev = "ClassButton"
			elseif phasePrev == "MyScheduleButton" then
				transition.to( classListSchedule, { time=250, x=display.contentWidth/2 } )
    			classListSchedule.isVisible = true
				ScheduleSubTab.isVisible = true
				phaseCur = phasePrev
				phasePrev = "ClassButton"
			elseif phasePrev == "TrackTimeList" then
 				transition.to( classListScreen, { time=250, x=0 } )
    			classListScreen.isVisible = true
				phaseCur = phasePrev
				phasePrev = "TrackButton"
			end
		elseif phaseCur == "TrackTimeList" then
			transition.to( classListScreen, { time=250, x=display.contentWidth } )
			transition.to( classListTrack, { time=250, x=display.contentWidth/2 } )
			classListTrack.isVisible = true
			phaseCur = phasePrev
			phasePrev = "ClassButton"
		elseif phasePrev == "ClassButton" then
			mainTabBar:setSelected(2, true)
			phasePrev = "home"
			phaseCur = "ClassButton"
		elseif phasePrev == "FeedbackButton" then
			mainTabBar:setSelected(3, true)
			phasePrev = "home"
			phaseCur = "FeedbackButton"		
		elseif phaseCur == "ClassSurvey" then
			classFeedbackPage.isVisible = false
			classListFeedback.isVisible = true			
			phasePrev = "FeedbackButton"
			phaseCur = "ClassFeedbackButton"
		elseif phaseCur == "DetailsMap" then
			conferenceMapPage.isVisible = false
			phaseCur = "ClassDetails"
		elseif phaseCur == "DetailsFeedback" then
			classFeedbackPage.isVisible = false
			phaseCur = "ClassDetails"			
		elseif phasePrev == "home" then
			background.isVisible = true
			mainTabBar:setSelected(0, false)
			MapSubTab:setSelected(0, false)
			ClassSubTab:setSelected(0, false)
			FeedbackSubTab:setSelected(0, false)
			SocialSubTab:setSelected(0, false)
			transition.to( ClassSubTab, { time=250, y=0 } )
			transition.to( SocialSubTab, { time=250, y=0 } )
			transition.to( FeedbackSubTab, { time=250, y=0 } )
			transition.to( MapSubTab, { time=250, y=0 } )
			phaseCur = "home"
			MakeInvisibleAll()
		elseif phasePrev == "MapButton" then
			mainTabBar:setSelected(1, true)
			phasePrev = "home"
		elseif phasePrev == "SocialButton" then
			mainTabBar:setSelected(4, true)
			phasePrev = "home"
		elseif phasePrev == "LikeButton" then
			mainTabBar:setSelected(4, true)
			SocialSubTab:setSelected(2, true)
			phasePrev = "SocialButton"
		elseif phasePrev == "TrendingButton" then
			mainTabBar:setSelected(4, true)
			SocialSubTab:setSelected(1, true)
			phasePrev = "SocialButton"
		elseif phasePrev == "ConferenceFeedbackButton" then
			mainTabBar:setSelected(3, true)
			FeedbackSubTab:setSelected(3, true)
			phasePrev = "FeedbackButton"									
		elseif phasePrev == "ClassFeedbackButton" then
			mainTabBar:setSelected(3, true)
			FeedbackSubTab:setSelected(2, true)
			phasePrev = "FeedbackButton"
		elseif phasePrev == "IdeaWallButton" then
			mainTabBar:setSelected(3, true)
			FeedbackSubTab:setSelected(1, true)
			phasePrev = "FeedbackButton"
		elseif phasePrev == "ConferenceButton" then
			mainTabBar:setSelected(1, true)
			MapSubTab:setSelected(2, true)
			phasePrev = "MapButton"	
		elseif phasePrev == "CityButton" then
			mainTabBar:setSelected(1, true)
			MapSubTab:setSelected(1, true)
			phasePrev = "MapButton"
		elseif phasePrev == "TrackButton" then
			mainTabBar:setSelected(2, true)
			ClassSubTab:setSelected(3, true)
			phasePrev = "ClassButton"
		elseif phaseCur == "satisfactionSurvey" then
			surveyPage:stop()
			surveyPage.isVisible = false
			phaseCur = "home"
			phasePrev = "home"
		end
	elseif ("c" == keyName and keyPhase == "down" and system.getInfo("environment") == "simulator") then -- Clear key, for testing	
		for index = 1, #classesScheduled do
			for row = 1, 5 do
				if classesScheduled[index][row] ~= nil then
					classesScheduled[index][row] = ""
				end
			end
		end
		saveSettings()
	elseif ("d" == keyName and keyPhase == "down" and system.getInfo("environment") == "simulator") then -- show db key, for testing
		loadDB()
	elseif ("p" == keyName and keyPhase == "down" and system.getInfo("environment") == "simulator") then	--BACK KEY (BACK PAGES)		
		printClassDetails(30)
 	end

	if "menu" == keyName then	-- Use default action for all the rest of the keys...
		returnValue = false
	end

	if "volumeUp" == keyName then	--  Use default action for all the rest of the keys...
		returnValue = false
	end
	if "volumeDown" == keyName then	--  Use default action for all the rest of the keys...
		returnValue = false
	end
	if "search" == keyName then	--  Use default action for all the rest of the keys...
		returnValue = false
	end
	return returnValue  -- we handled the event, so return true... for default behavior, return false (above).
end
 
-- This chunk is all the "do right at first" things... The Password Dialog needed to go below 
mainTabBar:setSelected(0, false)
MakeInvisibleAll()
background.isVisible = true
Runtime:addEventListener( "key", onKeyEvent )

-- Setup the event listener to catch "applicationExit"
Runtime:addEventListener( "system", onSystemEvent )-- =-=-=-=-=-= BELOW HERE IS THE PASSWORD/SATISFACTION SURVEY DIALOG =-=-=-=-=-=-=

if system.getInfo("environment") == "simulator" then
	appData.unlocked = 1
end

if appData.unlocked == 0 then
	local function unlockAlert( event )
	    if "clicked" == event.action then
	        if 1 == event.index then
	            killPassword()
	        elseif 2 == event.index then
	            --Do this if there were actually another button....
	        end
	    end
	end

	local function handleButtonEvent( event )
		if string.lower(passwordBox.text) == "uc2016" then
			native.setKeyboardFocus( nil )
			appData.unlocked = 1
			saveSettings()
			native.showAlert( "Enjoy the Conference!", "Thank you for downloading the Spillman Users's Conference App.", { "OK" }, unlockAlert )

		else
			native.setKeyboardFocus( nil )
			native.showAlert( "Invalid Password!", "Please contact a Spillman employee to obtain the password for unlocking this App", { "OK" } )
		end	
	end

	local passwordBacking = display.newImageRect( "assets/ScreenBacking.png", display.contentWidth, display.contentHeight )
	passwordBacking.x = display.contentCenterX
	passwordBacking.y = display.contentCenterY

	local passwordLogo = display.newImageRect( "assets/background.png", display.contentWidth*.30, display.contentWidth*.30 )
	passwordLogo.x = display.contentCenterX
	passwordLogo.y = display.contentHeight*.15

	local passwordText = display.newText( "Enter Password:", halfW, display.contentHeight*.3, native.systemFont, 24 )
	passwordText:setFillColor( (252/255), (181/255), (45/255) )

	passwordBox = native.newTextField( halfW, display.contentHeight*.42, display.contentWidth*.5, display.contentHeight*.08 )
	passwordBox.align = "center"
	passwordBox.isSecure = "true"
	passwordBox.font = native.newFont(native.systemFont, (display.pixelHeight / 50))

	local passwordButton = widget.newButton
	{
	    width = display.contentWidth*.40,
	    height = display.contentHeight*.08,
	    defaultFile = "assets/Button.png",
	    overFile = "assets/Button.png",
	    label = "Unlock",
	    labelColor = { default={ (255/255), (255/255), (255/255) }, over={ (255/255), (255/255), (255/255), 1 } },
	    labelXOffset = 15,
	    onEvent = handleButtonEvent
	}

	-- Center the button
	passwordButton.x = display.contentCenterX
	passwordButton.y = display.contentHeight*.55


	function passwordBacking:touch( event )
	    if event.phase == "began" then
	        native.setKeyboardFocus( nil )
	        return true
	    end
	end
	passwordBacking:addEventListener( "touch", passwordBacking )

	function killPassword ()
		passwordBacking:removeSelf()
		passwordBacking = nil
		passwordLogo:removeSelf()
		passwordLogo = nil
		passwordText:removeSelf()
		passwordText = nil
		passwordBox:removeSelf()
		passwordBox = nil
		passwordButton:removeSelf()
		passwordButton = nil
	end
elseif appData.unlocked == 1 then
	print("app is already unlocked")
	local function surveyAlert( event )
	    if "clicked" == event.action then
	        if 1 == event.index then
	        	appData.surveyPrompt = 0
	            surveyPage = native.newWebView( display.contentCenterX, display.contentCenterY + (display.contentHeight/24), display.contentWidth, display.contentHeight - (display.contentHeight/12))
				surveyPage:request(conferenceSurveyUrl)
				surveyPage.isVisible = true
				phaseCur = "satisfactionSurvey"
				phasePrev = "home"
	        elseif 2 == event.index then
	            --Do this if there were actually another button....
	        end
	    end
	end

	if isFriday == true and appData.surveyPrompt == 1 then
		native.showAlert("Satisfaction Survey", "Would you like to complete you Spillman Users' Conference Satisfaction Survey at this time?", {"Yes", "Not Now"}, surveyAlert)
	end
end
