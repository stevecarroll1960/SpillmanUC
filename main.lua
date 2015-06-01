display.setStatusBar( display.HiddenStatusBar ) -- Hide the status bar

local halfW = display.contentCenterX
local halfH = display.contentCenterY

display.setDefault( "background", 1 )	-- white
local background = display.newImageRect( "assets/background.png", ((display.pixelWidth*.5)*(320/display.pixelWidth)), ((display.pixelWidth*.5)*(480/display.pixelHeight)) )
background.x = display.contentCenterX
background.y = display.contentCenterY

-- All the main set-up stuff and variable declaration...
local str = require("str")
local widget = require( "widget" )
local loadsave = require("loadsave")

local rowTitlesDate = {}
local rowTitlesTrack = {}
local rowTitlesFeedback = {}
local rowTitlesFavorite = {}
local classTitle = "Default Title"
local classInstructor = "Default Instructor"
local classTrack = "Default Track"
local classTime = "Default Time"
local classRoom = "Default Room"
local classDesc= "Default Description"
local filePath = system.pathForFile("SavedSettings.txt", system.DocumentsDirectory)	-- Set location for saved data
local phaseCur = "home"
local phasePrev = "home"

function saveSettings()
	file = io.open( filePath, "w" )
	for k,v in pairs( appData ) do
		file:write( k .. "=" .. v .. "," )
	end
	io.close( file )
	loadsave.saveTable(ByFavorites, "favorites.json")
end

function loadSettings()	
	local file = io.open( filePath, "r" )
	if file then
		local dataStr = file:read( "*a" )		-- Read file contents into a string
		local datavars = str.split(dataStr, ",")	-- Break string into separate variables and construct new table from resulting data
		appData = {}
		for i = 1, #datavars do			-- split each name/value pair
			local onevalue = str.split(datavars[i], "=")
			appData[onevalue[1]] = onevalue[2]
		end
		io.close( file )

		appData["unlocked"] = tonumber(appData["unlocked"])
	else
		appData = {}
		appData.unlocked = 0
	end

	ByFavorites = loadsave.loadTable("favorites.json") 
	if ByFavorites == nil then
		ByFavorites = {}
		loadsave.saveTable(ByFavorites, "favorites.json")
	end
end

function phaseChange()
	phasePrev = phaseCur
end

-- function loadingSpinner()
-- 	spinner = display.newImage("assets/Loader.png")
-- 	spinner.anchorX = 0.5
-- 	spinner.anchorY = 0.5
-- 	spinner.x=display.contentCenterX
-- 	spinner.y=display.contentCenterY
-- 	transition.to(spinner, {time=3000, rotation=1080})
-- 	timer.performWithDelay( 3000, loadingSpinnerOff)
-- end

-- function loadingSpinnerOff()
-- 	spinner:removeSelf()
-- 	spinner = nil
-- end

local conferenceMapPage = native.newWebView( display.contentCenterX, display.contentCenterY + ((display.contentHeight/24)+(display.contentHeight/30)), display.contentWidth, display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)))
conferenceMapPage:request( "conferenceMap.html", system.ResourceDirectory )
conferenceMapPage.isVisible = false

local cityMapPage = native.newWebView( display.contentCenterX, display.contentCenterY + ((display.contentHeight/24)+(display.contentHeight/30)), display.contentWidth, display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)))
cityMapPage:request( "cityMap.html", system.ResourceDirectory )
cityMapPage.isVisible = false

local ideaWallPage = native.newWebView( display.contentCenterX, display.contentCenterY + ((display.contentHeight/24)+(display.contentHeight/30)), display.contentWidth, display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)))
ideaWallPage.isVisible = false

local classFeedbackPage = native.newWebView( display.contentCenterX, display.contentCenterY + ((display.contentHeight/24)+(display.contentHeight/30)), display.contentWidth, display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)))
classFeedbackPage.isVisible = false

local contactPage = native.newWebView( display.contentCenterX, display.contentCenterY + ((display.contentHeight/24)+(display.contentHeight/30)), display.contentWidth, display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)))
contactPage.isVisible = false

local trendingPage = native.newWebView( display.contentCenterX, display.contentCenterY + ((display.contentHeight/24)+(display.contentHeight/30)), display.contentWidth, display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)))
trendingPage.isVisible = false

local likePage = native.newWebView( display.contentCenterX, display.contentCenterY + ((display.contentHeight/24)+(display.contentHeight/30)), display.contentWidth, display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)))
likePage.isVisible = false

local function MakeInvisibleAll()
	conferenceMapPage.isVisible = false
	cityMapPage.isVisible = false
	ideaWallPage.isVisible = false
	classFeedbackPage.isVisible = false
	contactPage.isVisible = false
	trendingPage.isVisible = false
	likePage.isVisible = false
	classListDate.isVisible = false
	classListTrack.isVisible = false
	classListFavorite.isVisible = false
	detailsScreen.isVisible = false
	classListFeedback.isVisible = false
	background.isVisible = false
	if surveyPage ~= nil then
		surveyPage.isVisible = false
	end	
	native.setKeyboardFocus( nil )
end

local function MapButton ()
	local function proceed (event)
		if "clicked" == event.action then
	        local i = event.index
	        if 1 == i then
				ideaWallPage:stop()
				classFeedbackPage:stop()
				contactPage:stop()
				trendingPage:stop()
				likePage:stop()
				MakeInvisibleAll()
				phaseChange()
				phaseCur = "MapButton"
				transition.to( detailsScreen, { time=500, x=(display.contentWidth) } )
				transition.to( ClassSubTab, { time=250, y=0 } )
				transition.to( SocialSubTab, { time=250, y=0 } )
				transition.to( FeedbackSubTab, { time=250, y=0 } )
				transition.to( MapSubTab, { time=250, y=(display.contentHeight / 12) + ((display.contentHeight / 15)/2) } )
				MapSubTab:setSelected(0, false)
	        elseif 2 == i then
	            tabBar:setSelected(3, false)
	        end
	    end
	end

	if phaseCur == "IdeaWallButton" or phaseCur == "ClassSurvey" or phaseCur == "ContactButton" then
		local alert = native.showAlert( "Warning", "If you leave this page any information you have entered will be lost, are you sure you want to leave?", { "Yes", "Cancel" }, proceed )
	else
		ideaWallPage:stop()
		classFeedbackPage:stop()
		contactPage:stop()
		trendingPage:stop()
		likePage:stop()
		MakeInvisibleAll()
		phaseChange()
		phaseCur = "MapButton"
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
	        local i = event.index
	        if 1 == i then
				ideaWallPage:stop()
				classFeedbackPage:stop()
				contactPage:stop()
				trendingPage:stop()
				likePage:stop()	
				MakeInvisibleAll()
				phaseChange()
				phaseCur = "ClassButton"
				transition.to( detailsScreen, { time=500, x=(display.contentWidth) } )
				transition.to( SocialSubTab, { time=250, y=0 } )
				transition.to( MapSubTab, { time=250, y=0 } )
				transition.to( FeedbackSubTab, { time=250, y=0 } )
				transition.to( ClassSubTab, { time=250, y=(display.contentHeight / 12) + ((display.contentHeight / 15)/2) } )
				ClassSubTab:setSelected(0, false)
			elseif 2 == i then
				tabBar:setSelected(3, false)
			end
		end
	end
	
	if phaseCur == "IdeaWallButton" or phaseCur == "ClassSurvey" or phaseCur == "ContactButton" then
		local alert = native.showAlert( "Warning", "If you leave this page any information you have entered will be lost, are you sure you want to leave?", { "Yes", "Cancel" }, proceed )
	else
		ideaWallPage:stop()
		classFeedbackPage:stop()
		contactPage:stop()
		trendingPage:stop()
		likePage:stop()	
		MakeInvisibleAll()
		phaseChange()
		phaseCur = "ClassButton"
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
	contactPage:request( "http://www2.spillman.com/l/12482/2014-07-17/msmr3" )
	ideaWallPage:request( "http://ideas.spillman.com" )
	MakeInvisibleAll()
	phaseChange()
	phaseCur = "FeedbackButton"
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
	        local i = event.index
	        if 1 == i then	
				ideaWallPage:stop()
				classFeedbackPage:stop()
				contactPage:stop()
				--trendingPage:request( "https://tagboard.com/SpillmanUC14/179986" ) --Old tagboard
				trendingPage:request( "https://tagboard.com/SpillmanUC14/189423" )				
				likePage:request( "https://www.facebook.com/spillmantechnologies" )
				MakeInvisibleAll()
				phaseChange()
				phaseCur = "SocialButton"
				transition.to( detailsScreen, { time=500, x=(display.contentWidth) } )
				transition.to( ClassSubTab, { time=250, y=0 } )
				transition.to( FeedbackSubTab, { time=250, y=0 } )
				transition.to( MapSubTab, { time=250, y=0 } )
				transition.to( SocialSubTab, { time=250, y=(display.contentHeight / 12) + ((display.contentHeight / 15)/2) } )
				SocialSubTab:setSelected(0, false)
			elseif 2 == i then
				tabBar:setSelected(3, false)
			end
		end
	end

	if phaseCur == "IdeaWallButton" or phaseCur == "ClassSurvey" or phaseCur == "ContactButton" then
		local alert = native.showAlert( "Warning", "If you leave this page any information you have entered will be lost, are you sure you want to leave?", { "Yes", "Cancel" }, proceed )
	else
		ideaWallPage:stop()
		classFeedbackPage:stop()
		contactPage:stop()
		trendingPage:request( "https://tagboard.com/SpillmanUC14/189423" )
		likePage:request( "https://www.facebook.com/spillmantechnologies" )
		MakeInvisibleAll()
		phaseChange()
		phaseCur = "SocialButton"
		transition.to( detailsScreen, { time=500, x=(display.contentWidth) } )
		transition.to( ClassSubTab, { time=250, y=0 } )
		transition.to( FeedbackSubTab, { time=250, y=0 } )
		transition.to( MapSubTab, { time=250, y=0 } )
		transition.to( SocialSubTab, { time=250, y=(display.contentHeight / 12) + ((display.contentHeight / 15)/2) } )
		SocialSubTab:setSelected(0, false)
	end					
end

local function DayTimeButton ()
	phaseChange()
	phaseCur = "DayTimeButton"
    transition.to( detailsScreen, { time=250, x=display.contentWidth } )
    transition.to( classListDate, { time=250, x=(display.contentWidth*.5) } )
    transition.to( classListTrack, { time=250, x=(display.contentWidth*.5) } )
    transition.to( classListFavorite, { time=250, x=(display.contentWidth*.5) } )
	classListDate.isVisible = true
	classListTrack.isVisible = false
	classListFavorite.isVisible = false
	detailsScreen.isVisible = true
	classFeedbackPage.isVisible = false
	conferenceMapPage.isVisible = false
end

local function TrackButton ()
	phaseChange()
	phaseCur = "TrackButton"
	transition.to( detailsScreen, { time=250, x=display.contentWidth } )
    transition.to( classListDate, { time=250, x=(display.contentWidth*.5) } )
    transition.to( classListTrack, { time=250, x=(display.contentWidth*.5) } )
    transition.to( classListFavorite, { time=250, x=(display.contentWidth*.5) } )
	classListDate.isVisible = false
	classListTrack.isVisible = true
	classListFavorite.isVisible = false
	detailsScreen.isVisible = true
	classFeedbackPage.isVisible = false
	conferenceMapPage.isVisible = false
end

local function FavoritesButton ()
	phaseChange()
	phaseCur = "FavoritesButton"
	transition.to( detailsScreen, { time=250, x=display.contentWidth } )
   	transition.to( classListDate, { time=250, x=(display.contentWidth*.5) } )
    transition.to( classListTrack, { time=250, x=(display.contentWidth*.5) } )
    transition.to( classListFavorite, { time=250, x=(display.contentWidth*.5) } )
	classListDate.isVisible = false
	classListTrack.isVisible = false
	classListFavorite.isVisible = true
	detailsScreen.isVisible = true
	classFeedbackPage.isVisible = false
	conferenceMapPage.isVisible = false
end

local function CityButton ()
	phaseChange()
	phaseCur = "CityButton"
	cityMapPage.isVisible = true
	conferenceMapPage.isVisible = false
end

local function ConferenceButton ()
	phaseChange()
	phaseCur = "ConferenceButton"
	conferenceMapPage.isVisible = true
	cityMapPage.isVisible = false
end

local function IdeaWallButton ()
	local function proceed (event)
		if "clicked" == event.action then
	        local i = event.index
	        if 1 == i then	
				phaseChange()
				phaseCur = "IdeaWallButton"
				ideaWallPage.isVisible = true
				classFeedbackPage.isVisible = false
				classListFeedback.isVisible = true
				contactPage.isVisible = false
				--loadingSpinner()
			elseif 2 == i then
				FeedbackSubTab:setSelected(2, false)
			end
		end
	end

	if phaseCur == "ClassSurvey" then
		local alert = native.showAlert( "Warning", "If you leave this page any information you have entered will be lost, are you sure you want to leave?", { "Yes", "Cancel" }, proceed )
	else
		phaseChange()
		phaseCur = "IdeaWallButton"
		ideaWallPage.isVisible = true
		classFeedbackPage.isVisible = false
		classListFeedback.isVisible = true
		contactPage.isVisible = false
		--loadingSpinner()
	end		
end

local function ClassFeedbackButton ()
	phaseChange()
	phaseCur = "ClassFeedbackButton"
	ideaWallPage.isVisible = false
	classFeedbackPage.isVisible = false
	classListFeedback.isVisible = true
	contactPage.isVisible = false
end

local function ContactButton ()
	local function proceed (event)
		if "clicked" == event.action then
	        local i = event.index
	        if 1 == i then	
				phaseChange()
				phaseCur = "ContactButton"
				ideaWallPage.isVisible = false
				classFeedbackPage.isVisible = false
				classListFeedback.isVisible = true
				contactPage.isVisible = true
			elseif 2 == i then
				FeedbackSubTab:setSelected(2, false)
			end
		end
	end

	if phaseCur == "ClassSurvey" then
		local alert = native.showAlert( "Warning", "If you leave this page any information you have entered will be lost, are you sure you want to leave?", { "Yes", "Cancel" }, proceed )
	else
		phaseChange()
		phaseCur = "ContactButton"
		ideaWallPage.isVisible = false
		classFeedbackPage.isVisible = false
		classListFeedback.isVisible = true
		contactPage.isVisible = true
	end		
end

local function TrendingButton ()
	phaseChange()
	phaseCur = "TrendingButton"
	trendingPage.isVisible = true
	likePage.isVisible = false
end

local function LikeButton ()
	phaseChange()
	phaseCur = "LikeButton"
	trendingPage.isVisible = false
	likePage.isVisible = true
end

local MapButtons = 
{
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Map_City.png",
		overFile = "assets/Map_City-s.png",
		label = "Salt Lake City",
		size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = CityButton
	},
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Map_Conference.png",
		overFile = "assets/Map_Conference-s.png",
		label = "Users' Conference",
		size = (display.contentHeight / 70),
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
		label = "By Day/Time",
		size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = DayTimeButton
	},
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Classes_Track.png",
		overFile = "assets/Classes_Track-s.png",
		label = "By Track",
		size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = TrackButton
	},
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Classes_Favorite.png",
		overFile = "assets/Classes_Favorite-s.png",
		label = "Favorites",
		size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = FavoritesButton
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

local SocialButtons = 
{
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Social_Trending.png",
		overFile = "assets/Social_Trending-s.png",
		label = "#SpillmanUC2014",
		size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = TrendingButton
	},
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Social_Like.png",
		overFile = "assets/Social_Like-s.png",
		label = "Like/Follow Spillman",
		size = (display.contentHeight / 70),
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
		size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = IdeaWallButton
	},
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Feedback_Class.png",
		overFile = "assets/Feedback_Class-s.png",
		label = "Class Surveys",
		size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = ClassFeedbackButton
	},
	{
		width = (display.contentHeight / 15) / 2.5, 
		height = (display.contentHeight / 15) / 2.5,
		defaultFile = "assets/Feedback_Help.png",
		overFile = "assets/Feedback_Help-s.png",
		label = "Conference Help",
		size = (display.contentHeight / 70),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = ContactButton
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


local tabButtons = -- Create buttons table for the tab bar
{
	{
		width = (display.contentHeight / 12) / 2, 
		height = (display.contentHeight / 12) / 2,
		defaultFile = "assets/Map.png",
		overFile = "assets/Map-s.png",
		label = "Maps",
		size = (display.contentHeight / 60),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = MapButton
	},
	{
		width = (display.contentHeight / 12) / 2, 
		height = (display.contentHeight / 12) / 2,
		defaultFile = "assets/Classes.png",
		overFile = "assets/Classes-s.png",
		label = "Classes",
		size = (display.contentHeight / 60),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = ClassButton
	},
	{
		width = (display.contentHeight / 12) / 2, 
		height = (display.contentHeight / 12) / 2,
		defaultFile = "assets/Feedback.png",
		overFile = "assets/Feedback-s.png",
		label = "Feedback",
		size = (display.contentHeight / 60),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = FeedbackButton
	},
	{
		width = (display.contentHeight / 12) / 2, 
		height = (display.contentHeight / 12) / 2,
		defaultFile = "assets/Social.png",
		overFile = "assets/Social-s.png",
		label = "Social",
		size = (display.contentHeight / 60),
		labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
		onPress = SocialButton
	}
}

tabBar = widget.newTabBar -- Create a tab-bar and place it at the top of the screen
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
	buttons = tabButtons
}


function included(hash, value) -- Function for checking if a value is included
        local included = false
        for k,v in pairs(hash) do
                if v == value then
                        included = true
                        break
                end
        end
        return included
end


loadSettings() -- To make Favorites work properly, the Favorites needs to load here or the TableView cannot be created...

local ByDateData = {
	{ title = "Monday - 10:15-11:15", items = { "(NEW) Garbage In, Garbage Out - Ensuring Clean Data (UNIX)", "(NEW) Preparing for Your Upgrade or Migration (Windows)", "(NEW) Migrating to Linux Soon & Want to Learn More", "Records - What’s New?", "(NEW) Sex Offender Tracking", "Best Practices: A Day in the Life of a Dispatch Supervisor", "(NEW) Extracting Geobase Information Using Crystal Reports (4 hrs)", "(NEW) How to Lead an Effective CompStat Meeting", "(NEW) Advanced Searching & List Reports in Sentryx", "Basic Crystal Reports Session A (6 hrs)", "DAC Certification Training (6 hrs)", "CSAC Certification Training (6 hrs)", "SAA Certification Review for UNIX (3 hrs)"} },
	{ title = "Monday - 12:30-1:30", items = { "(NEW) Common User Mistakes and How to Avoid Them (UNIX)", "(NEW) Best Practices: Challenges of an SAA", "(NEW) How Administering Linux is Different than UNIX", "(NEW) Engaging R&D", "(NEW) Using Advanced Searches & Join Tables", "(NEW) Practical Applications for the CAD Dashboard Module", "(NEW) Leveraging Technology In a Disaster", "(NEW) Best Practices: Migrating from Classic Jail to Sentryx"} },
	{ title = "Monday - 1:45-2:45", items = { "Best Practices: A Day in the Life of a Crime Analyst", "(NEW) Garbage In, Garbage Out - Ensuring Clean Data (Windows)", "(NEW) How Administering Linux is Different than Windows", "Predictive Policing - Setting the Right Expectations", "Managing Workflow & Approvals (2 hrs)", "Response Plans Using Recommended Units (2 hrs)", "(NEW) How to Effectively Supervise a Multi-Generational Team", "Sentryx Booking Checklist (2 hrs)"} },
	{ title = "Monday - 3:00-4:00", items = { "(NEW) Preparing for Your Upgrade or Migration (UNIX)", "(NEW) Common User Mistakes and How to Avoid Them (Windows)", "Maximizing Agency Effectiveness with Spillman Analytics", "(NEW) Transformational Leadership", "SAA Certification Review for Windows (3 hrs)"} },
	{ title = "Tuesday - 9:00-10:00", items = { "System Maintenance for Maximum Performance (UNIX) (2 hrs)", "(NEW) Customizing Screens on a Windows Server (2 hrs)", "(NEW) Migrating to Linux Soon & Want to Learn More", "Predictive Policing - Setting the Right Expectations", "(NEW) Using Advanced Searches & Join Tables", "Best Practices: A Day in the Life of a Dispatch Supervisor", "Advanced Techniques & Validations for Sentryx Geobase (3 hrs)", "(NEW) What is Intelligence-Led Policing?"} },
	{ title = "Tuesday - 10:15-11:15", items = { "(NEW) How Administering Linux is Different than UNIX", "Maximizing Agency Effectiveness with Spillman Analytics", "Best Practices: A Day in the Life of a Records Supervisor", "ProQA Police, Fire, and Medical", "(NEW) How to Effectively Supervise a Multi-Generational Team", "(NEW) Sentryx Jail Troubleshooting"} },
	{ title = "Tuesday - 12:30-1:30", items = { "Best Practices: A Day in the Life of a Crime Analyst", "(NEW) Solutions II Windows – HA/DR Options and Data Protections", "(NEW) How Administering Linux is Different than Windows", "CAD/GIS: What’s New?", "Managing Workflow & Approvals (2 hrs)", "(NEW) Practical Applications for the CAD Dashboard Module", "(NEW) Leveraging Technology In a Disaster", "Sentryx Jail Tips & Tricks (2 hrs)", "Basic Crystal Reports Session B (6 hrs)", "DAC Certification Testing (2 hrs)", "SAA Certification Test for UNIX (3 hrs)"} },
	{ title = "Tuesday - 1:45-2:45", items = { "(NEW) Common User Mistakes and How to Avoid Them (UNIX)", "(NEW) Solutions II Open Forum - Ask the Expert (UNIX)", "Mobile: What’s New?", "Top Shortcuts for Dispatchers", "(NEW) Leveraging GIS Showcase (2 hrs)", "(NEW) How to Lead an Effective CompStat Meeting"} },
	{ title = "Tuesday - 3:00-4:00", items = { "(NEW) Partnering with Spillman Support (UNIX)", "Field Reporting: What’s New?", "(NEW) Introducing Sentryx IBR & Common Errors for NIBRS", "Paging Functionality with HipLink", "(NEW) Grants: How to Get Started & What are the Guidelines", "(NEW) Moving Beyond the Booking Checklist", "(NEW) Spillman Paint Workshop"} },
	{ title = "Wednesday - 9:00-10:00", items = { "(NEW) Customizing Screens on a UNIX Server (2 hrs)", "System Maintenance for Maximum Performance (Windows) (2 hrs)", "(NEW) Solutions II Linux - HA/DR Options, Data & Virtualization", "Mobile: What’s New?", "Best Practices: A Day in the Life of a Records Supervisor", "(NEW) Dispatching Basics", "Enhancing Your Classic Maps", "(NEW) What Mobile Can Provide in the Vehicle that Spillman Can’t", "(NEW) Sentryx Jail Troubleshooting", "RAC Certification Training (6 hrs)", "CSAC Certification Testing (2 hrs)"} },
	{ title = "Wednesday - 10:15-11:15", items = { "(NEW) Solutions II Open Forum - Ask the Expert (Linux)","Field Reporting: What’s New?", "Maximize System Functionality", "Top Shortcuts for Dispatchers", "(NEW) GIS Analysis (4 hrs)", "(NEW) Best Practices: Utilizing Mobile for Intelligence-Led Policing", "(NEW) Best Practices: Migrating from Classic Jail to Sentryx"} },
	{ title = "Wednesday - 12:30-1:30", items = { "SAAs Got Talent Game Show", "(NEW) Solutions II Linux - HA/DR Options, Data & Virtualization", "(NEW) To Be Announced at Opening General Session", "(NEW) Unlocking the Potential of the Personnel Module", "Paging Functionality with HipLink", "(NEW) Mobile Basics Plus Sex Offender Tracking & Other New Features", "Sentryx Corrections Administration Setup (2 hrs)", "SAA Certification Test for Windows (3 hrs)"} },
	{ title = "Wednesday - 1:45-2:45", items = { "Introduction to Sypriv (UNIX)", "(NEW) Partnering with Spillman Support (Windows)", "(NEW) Solutions II Linux - HA/DR Options, Data & Virtualization", "Jail: What’s New?", "Crime Analysis Tools: Pin Mapping, InSight & Reporting (2 hrs)", "CAD Set Up & Administration (2 hrs)", "Mobile Set Up & Administration (2 hrs)", "Advanced Crystal Reports 2011 (5 hrs)"} },
	{ title = "Wednesday - 3:00-4:00", items = { "Advanced Sypriv (UNIX)", "(NEW) Best Practices: Challenges of an SAA", "(NEW) Solutions II Open Forum - Ask the Expert (Linux)", "(NEW) Moving Beyond the Booking Checklist"} },
	{ title = "Thursday - 9:00-10:00", items = { "(NEW) Solutions II AIX – Monitoring, Managing and Troubleshooting", "Introduction to Sypriv (Windows)", "(NEW) Migrating to Linux Soon & Want to Learn More", "Spillman DEx & StateLink: What’s New?", "Maximize System Functionality", "CAD Set Up & Administration (2 hrs)", "Classic Geobase Refresher (2 hrs)", "(NEW) Best Practices: Utilizing Mobile for Intelligence-Led Policing", "(NEW) Advanced Searching & List Reports in Sentryx", "(NEW) Open Discussion Workshop"} },
	{ title = "Thursday - 10:15-11:15", items = { "(NEW) Solutions II AIX – AIX HA/DR & Virtualization", "(NEW) Common User Mistakes and How to Avoid Them (UNIX)", "(NEW) How Administering Linux is Different than UNIX", "R&D Panel", "Crime Analysis Tools: Pin Mapping, InSight & Reporting (2 hrs)", "(NEW) Mobile Basics Plus Sex Offender Tracking & Other New Features", "Sentryx Jail Tips & Tricks (2 hrs)", "RAC Certification Testing (2 hrs)", "Sentryx Jail Workshop"} },
	{ title = "Thursday - 11:30-12:30", items = { "(NEW) Solutions II Open Forum - Ask the Expert (UNIX)", "Advanced Sypriv (Windows)", "(NEW) How Administering Linux is Different than Windows", "Maximizing CAD System Reports", "Migrating to Sentryx Geobase for Administrators", "Fire Mobile Premises & HazMat, CAD & AVL Mapping", "(NEW) Spillman Paint Workshop"} },
}

local ByTrackData = {
	{ title = "System Administration - UNIX", items = { "(NEW) Garbage In, Garbage Out - Ensuring Clean Data (UNIX)", "(NEW) Common User Mistakes and How to Avoid Them (UNIX)", "Best Practices: A Day in the Life of a Crime Analyst", "(NEW) Preparing for Your Upgrade or Migration (UNIX)", "System Maintenance for Maximum Performance (UNIX) (2 hrs)", "(NEW) Partnering with Spillman Support (UNIX)", "(NEW) Customizing Screens on a UNIX Server (2 hrs)", "SAAs Got Talent Game Show", "Introduction to Sypriv (UNIX)", "Advanced Sypriv (UNIX)", "(NEW) Solutions II AIX – Monitoring, Managing and Troubleshooting", "(NEW) Solutions II AIX – AIX HA/DR & Virtualization", "(NEW) Solutions II Open Forum - Ask the Expert (UNIX)"} },
	{ title = "System Administration - Windows", items = { "(NEW) Preparing for Your Upgrade or Migration (Windows)", "(NEW) Best Practices: Challenges of an SAA", "(NEW) Garbage In, Garbage Out - Ensuring Clean Data (Windows)", "(NEW) Common User Mistakes and How to Avoid Them (Windows)", "(NEW) Customizing Screens on a Windows Server (2 hrs)", "(NEW) Solutions II Windows – HA/DR Options and Data Protections", "(NEW) Solutions II Open Forum - Ask the Expert (Windows) (2 hrs)", "System Maintenance for Maximum Performance (Windows) (2 hrs)", "(NEW) Partnering with Spillman Support (Windows)", "Introduction to Sypriv (Windows)", "Advanced Sypriv (Windows)"} },
	{ title = "System Administration - Linux", items = { "(NEW) Migrating to Linux Soon & Want to Learn More", "(NEW) How Administering Linux is Different than UNIX", "(NEW) How Administering Linux is Different than Windows", "(NEW) Solutions II Linux - HA/DR Options, Data & Virtualization", "(NEW) Solutions II Open Forum - Ask the Expert (Linux)"} },
	{ title = "Research & Design", items = { "(NEW) To Be Announced at Opening General Session", "(NEW) Engaging R&D", "Predictive Policing - Setting the Right Expectations", "Maximizing Agency Effectiveness with Spillman Analytics", "CAD/GIS: What’s New?", "Mobile: What’s New?", "Field Reporting: What’s New?", "Jail: What’s New?", "Spillman DEx & StateLink: What’s New?", "Records - What’s New?", "R&D Panel"} },
	{ title = "Records", items = { "(NEW) Sex Offender Tracking", "(NEW) Using Advanced Searches & Join Tables", "Managing Workflow & Approvals (2 hrs)", "Best Practices: A Day in the Life of a Records Supervisor", "(NEW) Introducing Sentryx IBR & Common Errors for NIBRS", "Maximize System Functionality", "(NEW) Unlocking the Potential of the Personnel Module", "Crime Analysis Tools: Pin Mapping, InSight & Reporting (2 hrs)"} },
	{ title = "Dispatch", items = { "Best Practices: A Day in the Life of a Dispatch Supervisor", "(NEW) Practical Applications for the CAD Dashboard Module", "Response Plans Using Recommended Units (2 hrs)", "ProQA Police, Fire, and Medical", "Top Shortcuts for Dispatchers", "Paging Functionality with HipLink", "(NEW) Dispatching Basics", "CAD Set Up & Administration (2 hrs)", "Maximizing CAD System Reports"} },
	{ title = "GIS", items = { "(NEW) Extracting Geobase Information Using Crystal Reports (4 hrs)", "Advanced Techniques & Validations for Sentryx Geobase (3 hrs)", "(NEW) Leveraging GIS Showcase (2 hrs)", "Enhancing Your Classic Maps", "(NEW) GIS Analysis (4 hrs)", "Classic Geobase Refresher (2 hrs)", "Migrating to Sentryx Geobase for Administrators"} },
	{ title = "Executive", items = { "(NEW) How to Lead an Effective CompStat Meeting", "(NEW) Leveraging Technology In a Disaster", "(NEW) How to Effectively Supervise a Multi-Generational Team", "(NEW) Transformational Leadership", "(NEW) What is Intelligence-Led Policing?", "(NEW) Grants: How to Get Started & What are the Guidelines"} },
	{ title = "Mobile", items = { "(NEW) What Mobile Can Provide in the Vehicle that Spillman Can’t", "(NEW) Best Practices: Utilizing Mobile for Intelligence-Led Policing", "(NEW) Mobile Basics Plus Sex Offender Tracking & Other New Features", "Mobile Set Up & Administration (2 hrs)", "Fire Mobile Premises & HazMat, CAD & AVL Mapping"} },
	{ title = "Corrections", items = { "(NEW) Advanced Searching & List Reports in Sentryx", "(NEW) Best Practices: Migrating from Classic Jail to Sentryx", "Sentryx Booking Checklist (2 hrs)", "(NEW) Sentryx Jail Troubleshooting", "Sentryx Jail Tips & Tricks (2 hrs)", "(NEW) Moving Beyond the Booking Checklist", "Sentryx Corrections Administration Setup (2 hrs)" } },
	{ title = "Training and Certification", items = { "Basic Crystal Reports Session A (6 hrs)", "Basic Crystal Reports Session B (6 hrs)", "Advanced Crystal Reports 2011 (5 hrs)", "DAC Certification Training (6 hrs)", "DAC Certification Testing (2 hrs)", "(NEW) Spillman Paint Workshop", "RAC Certification Training (6 hrs)", "RAC Certification Testing (2 hrs)", "CSAC Certification Training (6 hrs)", "CSAC Certification Testing (2 hrs)", "(NEW) Open Discussion Workshop", "Sentryx Jail Workshop", "SAA Certification Review for UNIX (3 hrs)", "SAA Certification Test for UNIX (3 hrs)", "SAA Certification Review for Windows (3 hrs)", "SAA Certification Test for Windows (3 hrs)" } },
}

local function onRowTouchDate( event )
	local phase = event.phase
	local row = event.target
	
	if "press" == phase then
		
	elseif "release" == phase then
		classTitle = rowTitlesDate[row.index]
		getClassDetails()
		if included(ByFavorites, classTitle)==true then
			detailsFaveOff.isVisible = false
    		detailsFaveOn.isVisible = true
    	elseif included(ByFavorites, classTitle)==false then
    		detailsFaveOff.isVisible = true
    		detailsFaveOn.isVisible = false
		end		
		detailsTitle.text = classTitleFull
		detailsPresenter.text = "Presenter: "..classInstructor
		detailsTime.text = classTime
		detailsRoom.text = classRoom
		detailsTrack.text = classTrack
		detailsDesc.text = classDesc

		transition.to( detailsScreen, { time=250, x=0 } )
		transition.to( classListTrack, { time=250, x=-(display.contentWidth*.5) } )
		transition.to( classListDate, { time=250, x=-(display.contentWidth*.5) } )
		transition.to( classListFavorite, { time=250, x=-(display.contentWidth*.5) } )
		phaseChange()
		phaseCur = "ClassDetails"
	end
end

local function onRowTouchTrack( event )
	local phase = event.phase
	local row = event.target
	
	if "press" == phase then
		
	elseif "release" == phase then
		classTitle = rowTitlesTrack[row.index]
		getClassDetails()
		if included(ByFavorites, classTitle)==true then
			detailsFaveOff.isVisible = false
    		detailsFaveOn.isVisible = true
    	elseif included(ByFavorites, classTitle)==false then
    		detailsFaveOff.isVisible = true
    		detailsFaveOn.isVisible = false
		end
		detailsTitle.text = classTitleFull
		detailsPresenter.text = "Presenter: "..classInstructor
		detailsTime.text = classTime
		detailsRoom.text = classRoom
		detailsTrack.text = classTrack
		detailsDesc.text = classDesc

		transition.to( detailsScreen, { time=250, x=0 } )
		transition.to( classListTrack, { time=250, x=-(display.contentWidth*.5) } )
		transition.to( classListDate, { time=250, x=-(display.contentWidth*.5) } )
		transition.to( classListFavorite, { time=250, x=-(display.contentWidth*.5) } )
		phaseChange()
		phaseCur = "ClassDetails"
	end
end

local function onRowTouchFavorite( event )
	local phase = event.phase
	local row = event.target
	
	if "press" == phase then
		
	elseif "release" == phase then
		classTitle = rowTitlesFavorite[row.index]
		getClassDetails()
		if included(ByFavorites, classTitle)==true then
			detailsFaveOff.isVisible = false
    		detailsFaveOn.isVisible = true
    	elseif included(ByFavorites, classTitle)==false then
    		detailsFaveOff.isVisible = true
    		detailsFaveOn.isVisible = false
		end		
		detailsTitle.text = classTitleFull
		detailsPresenter.text = "Presenter: "..classInstructor
		detailsTime.text = classTime
		detailsRoom.text = classRoom
		detailsTrack.text = classTrack
		detailsDesc.text = classDesc

		transition.to( detailsScreen, { time=250, x=0 } )
		transition.to( classListTrack, { time=250, x=-(display.contentWidth*.5) } )
		transition.to( classListDate, { time=250, x=-(display.contentWidth*.5) } )
		transition.to( classListFavorite, { time=250, x=-(display.contentWidth*.5) } )
		phaseChange()
		phaseCur = "ClassDetails"
	end
end

local function onRowTouchFeedback( event )
	local phase = event.phase
	local row = event.target
	
	if "press" == phase then
		
	elseif "release" == phase then
		classTitle = rowTitlesFeedback[row.index]
		getClassDetails()
		classFeedbackPage:request( "https://www.spillman.com/uc/2014/"..classURL )
		classFeedbackPage.isVisible = true
		phaseChange()
		phaseCur = "ClassSurvey"
		classListFeedback.isVisible = false
	end
end

local function onRowRenderDate( event )
	local phase = event.phase
	local row = event.row
	local isCategory = row.isCategory
	local groupContentHeight = row.contentHeight
	rowTitle = display.newText( row, rowTitlesDate[row.index], 0, 0, native.systemFontBold, 8 )
	rowTitle.x = 10
	rowTitle.anchorX = 0
	rowTitle.y = groupContentHeight * 0.5
	rowTitle:setFillColor( 0, 0, 0 )
	
	if not isCategory then
		local rowArrow = display.newImage( row, "assets/rowArrow.png", false )
		rowArrow.x = row.contentWidth - 10
		rowArrow.anchorX = 1 -- we set the image anchorX to 1, so the object is x-anchored at the right
		rowArrow.y = groupContentHeight * 0.5
	end
end

local function onRowRenderTrack( event )
	local phase = event.phase
	local row = event.row
	local isCategory = row.isCategory
	local groupContentHeight = row.contentHeight
	rowTitle = display.newText( row, rowTitlesTrack[row.index], 0, 0, native.systemFontBold, 8 )
	rowTitle.x = 10
	rowTitle.anchorX = 0
	rowTitle.y = groupContentHeight * 0.5
	rowTitle:setFillColor( 0, 0, 0 )
	
	if not isCategory then
		local rowArrow = display.newImage( row, "assets/rowArrow.png", false )
		rowArrow.x = row.contentWidth - 10
		rowArrow.anchorX = 1 -- we set the image anchorX to 1, so the object is x-anchored at the right
		rowArrow.y = groupContentHeight * 0.5
	end
end

local function onRowRenderFavorite( event )
	local phase = event.phase
	local row = event.row
	local groupContentHeight = row.contentHeight
	rowTitle = display.newText( row, rowTitlesFavorite[row.index], 0, 0, native.systemFontBold, 8 )
	rowTitle.x = 10
	rowTitle.anchorX = 0
	rowTitle.y = groupContentHeight * 0.5
	rowTitle:setFillColor( 0, 0, 0 )
	
		local rowArrow = display.newImage( row, "assets/rowArrow.png", false )
		rowArrow.x = row.contentWidth - 10
		rowArrow.anchorX = 1 -- we set the image anchorX to 1, so the object is x-anchored at the right
		rowArrow.y = groupContentHeight * 0.5
end

local function onRowRenderFeedback( event )
	local phase = event.phase
	local row = event.row
	local isCategory = row.isCategory
	local groupContentHeight = row.contentHeight
	rowTitle = display.newText( row, rowTitlesFeedback[row.index], 0, 0, native.systemFontBold, 8 )
	rowTitle.x = 10
	rowTitle.anchorX = 0
	rowTitle.y = groupContentHeight * 0.5
	rowTitle:setFillColor( 0, 0, 0 )
	
	if not isCategory then
		local rowArrow = display.newImage( row, "assets/rowArrow.png", false )
		rowArrow.x = row.contentWidth - 10
		rowArrow.anchorX = 1 -- we set the image anchorX to 1, so the object is x-anchored at the right
		rowArrow.y = groupContentHeight * 0.5
	end
end

classListDate = widget.newTableView
{
	top = (display.contentHeight/12)+(display.contentHeight/15),
	width = display.contentWidth, 
	height = display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)),
	maskFile = "mask-320x448.png",
	onRowRender = onRowRenderDate,
	onRowTouch = onRowTouchDate,
	--isBounceEnabled = false,
	rowTouchDelay = .25,
}
classListDate.isVisible=false

classListTrack = widget.newTableView
{
	top = (display.contentHeight/12)+(display.contentHeight/15),
	width = display.contentWidth, 
	height = display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)),
	maskFile = "mask-320x448.png",
	onRowRender = onRowRenderTrack,
	onRowTouch = onRowTouchTrack,
	--isBounceEnabled = false,
	rowTouchDelay = .25,
}
classListTrack.isVisible=false

classListFavorite = widget.newTableView
{
	top = (display.contentHeight/12)+(display.contentHeight/15),
	width = display.contentWidth, 
	height = display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)),
	maskFile = "mask-320x448.png",
	onRowRender = onRowRenderFavorite,
	onRowTouch = onRowTouchFavorite,
	--isBounceEnabled = false,
	rowTouchDelay = .25,
}
classListFavorite.isVisible=false

classListFeedback = widget.newTableView
{
	top = (display.contentHeight/12)+(display.contentHeight/15),
	width = display.contentWidth, 
	height = display.contentHeight - ((display.contentHeight/12)+(display.contentHeight/15)),
	maskFile = "mask-320x448.png",
	onRowRender = onRowRenderFeedback,
	onRowTouch = onRowTouchFeedback,
	--isBounceEnabled = false,
	rowTouchDelay = .25,
}
classListDate.isVisible=false

for i = 1, #ByDateData do
	--Add the rows category title
	rowTitlesDate[ #rowTitlesDate + 1 ] = ByDateData[i].title
	
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
	for j = 1, #ByDateData[i].items do
		--Add the rows item title
		rowTitlesDate[ #rowTitlesDate + 1 ] = ByDateData[i].items[j]
		
		--Insert the item
		classListDate:insertRow{
			rowHeight = 20,
			isCategory = false,
			listener = onRowTouchDate
		}
	end
end

for i = 1, #ByTrackData do
	--Add the rows category title
	rowTitlesTrack[ #rowTitlesTrack + 1 ] = ByTrackData[i].title
	
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
	for j = 1, #ByTrackData[i].items do
		--Add the rows item title
		rowTitlesTrack[ #rowTitlesTrack + 1 ] = ByTrackData[i].items[j]
		
		--Insert the item
		classListTrack:insertRow{
			rowHeight = 20,
			isCategory = false,
			listener = onRowTouchTrack
		}
	end
end

function updateFavorites()
	for i = 1, #rowTitlesFavorite do
		table.remove(rowTitlesFavorite, i)
	end	

	for i = 1, #ByFavorites do
		rowTitlesFavorite[i] = ByFavorites[i]
		classListFavorite:insertRow{
			rowHeight = 20,
			listener = onRowTouchFavorite
		}
	end

end
updateFavorites()

for i = 1, #ByDateData do
	--Add the rows category title
	rowTitlesFeedback[ #rowTitlesFeedback + 1 ] = ByDateData[i].title
	
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
	for j = 1, #ByDateData[i].items do
		--Add the rows item title
		rowTitlesFeedback[ #rowTitlesFeedback + 1 ] = ByDateData[i].items[j]
		
		--Insert the item
		classListFeedback:insertRow{
			rowHeight = 20,
			isCategory = false,
			listener = onRowTouchFeedback
		}
	end
end

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

detailsPresenter = display.newText( "Presenter:"..classInstructor, display.contentWidth*.5, display.contentHeight*.25, native.systemFont, 10 )
detailsPresenter:setFillColor( (96/255), (103/255), (105/255) )

detailsRoom = display.newText( classRoom, display.contentWidth*.5, display.contentHeight*.30, native.systemFont, 10 )
detailsRoom:setFillColor( (96/255), (103/255), (105/255) )

detailsMap = display.newImageRect("assets/Map_Conference-s.png", 16, 16)
detailsMap.x = display.contentWidth*.3
detailsMap.y = display.contentHeight*.3

detailsTrack = display.newText( classTrack, display.contentWidth*.5, display.contentHeight*.35, native.systemFont, 10 )
detailsTrack:setFillColor( (96/255), (103/255), (105/255) )

local timeOptions = 
{
    text = classTime,     
    x = display.contentWidth*.5,
    y = display.contentHeight*.475,
    width = display.contentWidth-25,     --required for multi-line and alignment
    height = 75, 
    font = native.systemFont,   
    fontSize = 10,
    align = "center"  --new alignment parameter
}

detailsTime = display.newText( timeOptions )
detailsTime:setFillColor( (96/255), (103/255), (105/255) )

detailsDesc = display.newText( classDesc, display.contentWidth*.5, display.contentHeight*.70, display.contentWidth-25, 200, native.systemFont, 8, "center" )
detailsDesc:setFillColor( (96/255), (103/255), (105/255) )

detailsBack = display.newImageRect ("assets/detailsArrow.png", 50, 50)
detailsBack.x = display.contentWidth*.5
detailsBack.y = display.contentHeight*.925

detailsFeedback = display.newImageRect ("assets/Details_Feedback.png", 30, 38)
detailsFeedback.x = display.contentWidth*.15
detailsFeedback.y = display.contentHeight*.80

detailsFaveOff = display.newImageRect ("assets/StarOff.png", 35, 32)
detailsFaveOff.x = display.contentWidth*.85
detailsFaveOff.y = display.contentHeight*.80
detailsFaveOn = display.newImageRect ("assets/StarOn.png", 35, 32)
detailsFaveOn.x = display.contentWidth*.85
detailsFaveOn.y = display.contentHeight*.80

function detailsBack:touch( event )
    if event.phase == "began" then
        transition.to( detailsScreen, { time=250, x=display.contentWidth } )
        transition.to( classListDate, { time=250, x=(display.contentWidth*.5) } )
        transition.to( classListTrack, { time=250, x=(display.contentWidth*.5) } )
        transition.to( classListFavorite, { time=250, x=(display.contentWidth*.5) } )
        phaseCur = phasePrev
        phasePrev = "ClassButton"
        return true
    end
end

function detailsMap:touch( event )
    if event.phase == "began" then
		conferenceMapPage.isVisible = true
		phaseCur = "DetailsMap"

    	if (system.getInfo("model") == "iPad" or system.getInfo("model") == "iPhone" or system.getInfo("model") == "iPod") then
     			ClassSubTab:setSelected(0, false)
     	else
     	end
        return true
    end
end

function detailsRoom:touch( event )
    if event.phase == "began" then
		conferenceMapPage.isVisible = true
		phaseCur = "DetailsMap"
    	if (system.getInfo("model") == "iPad" or system.getInfo("model") == "iPhone" or system.getInfo("model") == "iPod") then
     			ClassSubTab:setSelected(0, false)
     	else
     	end		
        return true
    end
end

function detailsFaveOff:touch( event )
    if event.phase == "began" then
    	detailsFaveOff.isVisible = false
    	detailsFaveOn.isVisible = true

    	table.insert(ByFavorites, classTitle)
    	saveSettings()
    	classListFavorite:deleteAllRows()
    	updateFavorites()
    	for i = 1,#ByFavorites do
    	end	

        return true
    end
end

function detailsFaveOn:touch( event )
    if event.phase == "began" then
    	detailsFaveOff.isVisible = true
    	detailsFaveOn.isVisible = false

    	local i = table.indexOf(ByFavorites, classTitle)
    	table.remove(ByFavorites, i)
    	saveSettings()
		classListFavorite:deleteAllRows()
	   	updateFavorites()
    	for i = 1,#ByFavorites do
    	end
		return true
    end
end

function detailsFeedback:touch( event )
    if event.phase == "began" then
    	classFeedbackPage:request( "https://www.spillman.com/uc/2014/"..classURL )
    	classFeedbackPage.isVisible = true
		phaseCur = "DetailsFeedback"
    	if (system.getInfo("model") == "iPad" or system.getInfo("model") == "iPhone" or system.getInfo("model") == "iPod") then
     			ClassSubTab:setSelected(0, false)
     	else
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

function getClassDetails ()
	if classTitle == "(NEW) Garbage In, Garbage Out - Ensuring Clean Data (UNIX)" then
		classTitleFull = "Garbage In, Garbage Out - Ensuring Clean Data and Maintaining Standards (UNIX)"
		classInstructor = "Frank DeMarzo"
		classTrack = "System Administration Track - UNIX"
		classTime = "Monday 10:15-11:15"
		classRoom = "Ballroom A"
		classDesc= "This course will include a look at data standards from different agencies and some examples of what bad data looks like and how it could skew the results of searches. Class discussion will include input from the group on your worst data nightmares and your solutions on how you made corrections. This class will be for all levels of experience."
		classURL= "1"
	elseif classTitle == "(NEW) Common User Mistakes and How to Avoid Them (UNIX)" then
		classTitleFull = classTitle
		classInstructor = "Dustin Harrah"
		classTrack = "System Administration Track - UNIX"
		classTime = "Monday 12:30–1:30\nTuesday 1:45–2:45"
		classRoom = "Ballroom A"
		classDesc= "This class will attempt to uncover some common mistakes made by end users of the Spillman Software which can cause issues overall. The class will provide insight into various scenarios and/or tasks that can cause problems as well as provide a “best practice” solution to these issues to help administrators. This class will be for all levels of experience."
		classURL= "6"
	elseif classTitle == "Best Practices: A Day in the Life of a Crime Analyst" then
		classTitleFull = classTitle
		classInstructor = "Allan Seebaran (Covington Police Department, GA)"
		classTrack = "System Administration Track - UNIX"
		classTime = "Monday 1:45-2:45\nTuesday 12:30-1:30"
		classRoom = "Ballroom A"
		classDesc= "Receive best practices tips on the life of a crime analyst through the eyes of Allan Seebaran as his shares his experiences from Covington PD, Georgia. Mr. Seebaran will discuss how Spillman Software is an intricate part of the crime analysis process. Discussion will include using Spillman to gather information about people, places, and crime, how the software is used for producing crime statistics for staff meetings, and other agencies and how Mr. Seebaran uses the software to aid other department’s with information they need to get ‘the big picture’ of incidents occurring in their jurisdictions."
		classURL= "5"
	elseif classTitle == "(NEW) Preparing for Your Upgrade or Migration (UNIX)" then
		classTitleFull = classTitle
		classInstructor = "Nick Barber & Nick Bishop"
		classTrack = "System Administration Track - UNIX"
		classTime = "Monday 3:00–4:00"
		classRoom = "Ballroom A"
		classDesc= "Learn how to prepare your agency/organization for a pending Spillman Upgrade or Server Migration. This class will be an all-levels class that offers system administrators an in-depth look at how to prepare for either an Upgrade or a Server Migration, and sometimes both! This class will provide a clear, concise plan to help manage your agency resources during either process, including how to manage potential downtime associated with these projects. The class will cover what your agency has to do to prepare for the actual project, for example, what is the best time to run a backup prior to my Migration? Presenters will offer a Q&A session to answer any questions administrators may have. This class is intended for administrators of any level of expertise, but attendees should have a basic understanding of the way your agency functions and what your plans are for extended downtime. This class will be taught from a UNIX-based perspective."
		classURL= "3"
	elseif classTitle == "System Maintenance for Maximum Performance (UNIX) (2 hrs)" then
		classTitleFull = "System Maintenance for Maximum Performance (UNIX)"
		classInstructor = "Brady Walton"
		classTrack = "System Administration Track - UNIX"
		classTime = "Tuesday 9:00–11:15"
		classRoom = "Ballroom A"
		classDesc= "Learn about the settings and recommendations to enhance your systems performance, including little tweaks that will make your job easier. We will be covering the details on available tools for hardware, network, and PC set-up; backups, redundancy, OS support, maintenance tasks; software maintenance for checking logs, cleaning up your data, implementing patches, and maintaining performance settings. This class is geared for intermediate-level Spillman Administrators on a UNIX server."
		classURL= "4"
	elseif classTitle == "(NEW) Partnering with Spillman Support (UNIX)" then
		classTitleFull = classTitle
		classInstructor = "Mike Phan"
		classTrack = "System Administration Track - UNIX"
		classTime = "Tuesday 3:00–4:00"
		classRoom = "Ballroom A"
		classDesc= "Tired of playing phone tag with the Support Department? Ever wonder how to get your problems solved with only one phone call? Learn what Support needs to solve your problems on the very first phone call. This class will take you through how to get the best “bang for your buck.” It’s important to us that when you call Support we can help you solve the problem in just one phone call. You don’t want to miss this informative class on how you can build a strong partnership with Support. This class is taught platform independent."
		classURL= "2"
	elseif classTitle == "(NEW) Customizing Screens on a UNIX Server (2 hrs)" then
		classTitleFull = "(NEW) Customizing Screens on a UNIX Server"
		classInstructor = "Derik Christensen"
		classTrack = "System Administration Track - UNIX"
		classTime = "Wednesday 9:00–11:15"
		classRoom = "Ballroom A"
		classDesc= "This session will discuss and answer questions that you may have regarding Screen painting and other customizations to both classic and Sentryx screens. This class will be based on the UNIX server (there is also a class based on the Windows server at a different time on the schedule). This is a perfect class for New SAAs and agencies that would like to customize the screens in their Spillman software. Some of the topics covered will be changing field descriptors, changing the order of fields on your screen, and putting secondary fields onto screens. This class is an advanced level class."
		classURL= "10"
	elseif classTitle == "SAAs Got Talent Game Show" then
		classTitleFull = classTitle
		classInstructor = "NA"
		classTrack = "System Administration Track - All"
		classTime = "Wednesday 12:30–1:30"
		classRoom = "Ballroom A"
		classDesc= "Come show off your amazing talents and volunteer to be a contestant on the first annual SAAs Got Talent game show. In fact, you don’t even need a talent because we will provide you with a pre-selected one. Each contestant will share their talent and answer an SAA-relate d question in front of 4 famous celebrity judges. Don’t miss this exciting game show to see who will be the first SAAs Got Talent winner."
		classURL= "7"
	elseif classTitle == "Introduction to Sypriv (UNIX)" then
		classTitleFull = classTitle
		classInstructor = "Frank DeMarzo"
		classTrack = "System Administration Track - UNIX"
		classTime = "Wednesday 1:45–2:45"
		classRoom = "Ballroom A"
		classDesc= "This course will show you how to use the tool that sets up access to the Spillman software. Sypriv controls what your staff is allowed to access and what functions they can perform. This class will be for both the beginner and intermediate users, but anyone can attend."
		classURL= "8"
	elseif classTitle == "Advanced Sypriv (UNIX)" then
		classTitleFull = classTitle
		classInstructor = "Angie Phelps"
		classTrack = "System Administration Track - UNIX"
		classTime = "Wednesday 3:00–4:00"
		classRoom = "Ballroom A"
		classDesc= "Learn to use advanced sypriv techniques to better secure and protect your data. This course will cover both Agency and Non-Agency partitioning, as well as field security. The privilege entries will be addressed using both classic sypriv and the Sentryx Admin Manager. We will also discuss any parameter settings and additional information needed to make partitioning and field security work for your agencies. This is an advanced level course and is being taught in both the UNIX and Windows Administration tracks (although it is technically not platform specific)."
		classURL= "9"
	elseif classTitle == "(NEW) Solutions II AIX – Monitoring, Managing and Troubleshooting" then
		classTitleFull = "(NEW) Solutions II AIX Training – Monitoring, Managing and Troubleshooting"
		classInstructor = "Solutions II"
		classTrack = "System Administration Track - UNIX"
		classTime = "Thursday 9:00–10:00"
		classRoom = "Ballroom A"
		classDesc= "Basic resource and performance monitoring, Upgrades (TL and Patches), Diagnosing faults on the server, Navigating IBM Support, Managing RAID arrays, Logical Volume Manager (LVM), Managing and Monitoring Images and Attachments (Capacity Management), Disk performance monitoring"
		classURL= "11"
	elseif classTitle == "(NEW) Solutions II AIX – AIX HA/DR & Virtualization" then
		classTitleFull = "(NEW) Solutions II AIX – AIX HA/DR & Virtualization"
		classInstructor = "Solutions II"
		classTrack = "System Administration Track - UNIX"
		classTime = "Thursday 10:15–11:15"
		classRoom = "Ballroom A"
		classDesc= "HMC Management, LPAR Management including resource management (CPU and Memory pooling and shares), VIOs, AIX HA/DR Options, Infrastructure considerations for HA/DR options, RSYNC, Global Logical Volume Manager (GLVM), PowerHA"
		classURL= "95"
	elseif classTitle == "(NEW) Solutions II Open Forum - Ask the Expert (UNIX)" then
		classTitleFull = classTitle
		classInstructor = "Solutions II"
		classTrack = "System Administration Track - UNIX"
		classTime = "Thursday 11:30–12:30"
		classRoom = "Ballroom A"
		classDesc= "Informal question and answer based on HA/DR, Data Protection and Virtualization"
		classURL= "96"
	elseif classTitle == "(NEW) Preparing for Your Upgrade or Migration (Windows)" then
		classTitleFull = classTitle
		classInstructor = "Nick Barber & Nick Bishop"
		classTrack = "System Administration Track - Windows"
		classTime = "Monday 10:15–11:15"
		classRoom = "Ballroom B"
		classDesc= "Learn how to prepare your agency/organization for a pending Spillman Upgrade or Server Migration. This class will be an all-levels class that offers system administrators an in-depth look at how to prepare for either an Upgrade or a Server Migration, and sometimes both! This class will provide a clear, concise plan to help manage your agency resources during either process, including how to manage potential downtime associated with these projects. The class will cover what your agency has to do to prepare for the actual project, for example, what is the best time to run a backup prior to my Migration? Presenters will offer a Q&A session to answer any questions administrators may have. This class is intended for administrators of any level of expertise, but attendees should have a basic understanding of the way your agency functions and what your plans are for extended downtime. This class will be taught from a Windows-based perspective."
		classURL= "14"
	elseif classTitle == "(NEW) Best Practices: Challenges of an SAA" then
		classTitleFull = classTitle
		classInstructor = "David R. Myers (Tavares Police Department, FL)"
		classTrack = "System Administration Track - Windows"
		classTime = "Monday 12:30–1:30\nWednesday 3:00–4:00"
		classRoom = "Ballroom B"
		classDesc= "Congratulations you are now a Spillman System Administrator (SAA). What challenges might you face in the coming years? Setting up new modules? Ensuring data quality? Training and retraining of staff? How about bringing on a shared agency to your existing Spillman system? What about having to move your existing system over to a new host as your area begins to consolidate resources. Learn from an SAA who over the last 7 years has had to face all these challenges and more. This class is taught from the perspective of a 25 year law enforcement veteran who had very little IT experience when he started this journey."
		classURL= "16"
	elseif classTitle == "(NEW) Garbage In, Garbage Out - Ensuring Clean Data (Windows)" then
		classTitleFull = "(NEW) Garbage In, Garbage Out - Ensuring Clean Data and Maintaining Standards (Win)"
		classInstructor = "Frank DeMarzo"
		classTrack = "System Administration Track - Windows"
		classTime = "Monday 1:45–2:45"
		classRoom = "Ballroom B"
		classDesc= "This course will include a look at data standards from different agencies and some examples of what bad data looks like and how it could skew the results of searches. Class discussion will include input from the group on your worst data nightmares and your solutions on how you made corrections. This class will be for all levels of experience."
		classURL= "12"
	elseif classTitle == "(NEW) Common User Mistakes and How to Avoid Them (Windows)" then
		classTitleFull = classTitle
		classInstructor = "Dustin Harrah"
		classTrack = "System Administration Track - Windows"
		classTime = "Monday 3:00–4:00\nThursday 10:15–11:15"
		classRoom = "Ballroom B"
		classDesc= "This class will attempt to uncover some common mistakes made by end users of the Spillman Software which can cause issues overall. The class will provide insight into various scenarios and/or tasks that can cause problems as well as provide a “best practice” solution to these issues to help administrators. This class will be for all levels of experience."
		classURL= "17"
	elseif classTitle == "(NEW) Customizing Screens on a Windows Server (2 hrs)" then
		classTitleFull = "(NEW) Customizing Screens on a Windows Server"
		classInstructor = "Derik Christensen"
		classTrack = "System Administration Track - Windows"
		classTime = "Tuesday 9:00–11:15"
		classRoom = "Ballroom B"
		classDesc= "This session will be class to discuss and answer questions that you may have regarding Screen painting and other customizations to both classic and Sentryx screens. This class will be based on the Windows server (there is also a class based on the UNIX server at a different time on the schedule). This is a perfect class for New SAAs and agencies that would like to customize the screens in their Spillman Software. Some of the topics covered will be changing field descriptors, changing the order of fields on your screen, and putting secondary fields onto screens. This class is an advanced level class."
		classURL= "20"
	elseif classTitle == "(NEW) Solutions II Windows – HA/DR Options and Data Protections" then
		classTitleFull = "(NEW) Solutions II Windows Training – HA/DR Options and Data Protections"
		classInstructor = "Solutions II"
		classTrack = "System Administration Track - Windows"
		classTime = "Tuesday 12:30–1:30"
		classRoom = "Ballroom B"
		classDesc= "This course will cover Windows HA/DR options, infrastructure considerations for HA/DR options, Local and Offsite Data Protection and Recovery"
		classURL= "21"
	elseif classTitle == "(NEW) Solutions II Open Forum - Ask the Expert (Windows) (2 hrs)" then
		classTitleFull = "(NEW) Solutions II Open Forum - Ask the Expert (Windows)"
		classInstructor = "Solutions II"
		classTrack = "System Administration Track - Windows"
		classTime = "Tuesday 1:45–4:00"
		classRoom = "Ballroom B"
		classDesc= "Informal question and answer. Topics may include HA/DR, Data Protection and Virtualization"
		classURL= "89"
	elseif classTitle == "System Maintenance for Maximum Performance (Windows) (2 hrs)" then
		classTitleFull = "System Maintenance for Maximum Performance (Windows)"
		classInstructor = "Brady Walton"
		classTrack = "System Administration Track - Windows"
		classTime = "Wednesday, 9:00 a.m. – 11:15 a.m. "
		classRoom = "Ballroom B"
		classDesc= "Learn about the settings and recommendations to enhance your systems performance, including little tweaks that will make your job easier. We will be covering the details on available tools for hardware, network, and PC set-up; backups, redundancy, OS support, maintenance tasks; software maintenance for checking logs, cleaning up your data, implementing patches, and maintaining performance settings. This class is geared for intermediate-level Spillman Administrators on a Windows server."
		classURL= "15"
	elseif classTitle == "(NEW) Partnering with Spillman Support (Windows)" then
		classTitleFull = classTitle
		classInstructor = "Sam Claybrook"
		classTrack = "System Administration Track - Windows"
		classTime = "Wednesday 1:45–2:45"
		classRoom = "Ballroom B"
		classDesc= "Tired of playing phone tag with the Support Department? Ever wonder how to get your problems solved with only one phone call? Learn what Support needs to solve your problems on the very first phone call. This class will take you through how to get the best “bang for your buck.” It’s important to us that when you call Support we can help you solve the problem in just one phone call. You don’t want to miss this informative class on how you can build a strong partnership with Support. This class is taught platform independent."
		classURL= "13"
	elseif classTitle == "Introduction to Sypriv (Windows)" then
		classTitleFull = classTitle
		classInstructor = "Frank DeMarzo"
		classTrack = "System Administration Track - Windows"
		classTime = "Thursday 9:00–10:00"
		classRoom = "Ballroom B"
		classDesc= "This course will show you how to use the tool that sets up access to the Spillman software. Sypriv controls what your staff is allowed to access and what functions they can perform. This class will be for both the beginner and intermediate users, but anyone can attend."
		classURL= "18"
	elseif classTitle == "Advanced Sypriv (Windows)" then
		classTitleFull = classTitle
		classInstructor = "Angie Phelps"
		classTrack = "System Administration Track - Windows"
		classTime = "Thursday 11:30–12:30"
		classRoom = "Ballroom B"
		classDesc= "Learn to use advanced sypriv techniques to better secure and protect your data. This course will cover both Agency and Non-Agency partitioning, as well as field security. The privilege entries will be addressed using both classic syrpiv and the Sentryx Admin Manager. We will also discuss any parameter settings and additional information needed to make partitioning and field security work for your agencies. This is an advanced level course and is being taught in both the UNIX and Windows Administration tracks (although it is technically not platform specific.)"
		classURL= "19"
	elseif classTitle == "(NEW) Migrating to Linux Soon & Want to Learn More" then
		classTitleFull = classTitle
		classInstructor = " Evan Rothwell & Austen Willes"
		classTrack = "System Administration Track - Linux"
		classTime = "Monday 10:15–11:15\nTuesday 9:00-10:00\nThursday 9:00–10:00"
		classRoom = "Room 251 A & B"
		classDesc= "If you are unfamiliar with Linux, or just want to learn more about it, this class is for you. In this class we will be explaining to you why Linux is a good choice of platform for Spillman software. For those who want to know what to expect when migrating to Linux, or those who are already planning a migration, this class will help give you some information on what you can expect during the process. We will also cover some comparisons on how it differs from your current Operating System for some basic administrative tasks."
		classURL= "22"
	elseif classTitle == "(NEW) How Administering Linux is Different than UNIX" then
		classTitleFull = classTitle
		classInstructor = " Erik Falor & Brian Sedgwick"
		classTrack = "System Administration Track - Linux"
		classTime = "Monday 12:30–1:30\nTuesday 10:15–11:15\nThursday 10:15–11:15"
		classRoom = "Room 251 A & B"
		classDesc= "Discover how the Linux Operating System makes administration easier than ever. Administrators with a UNIX background will find themselves at home in a familiar environment. This class explores some of the syntactical differences between common UNIX utilities available on the Linux platform. You will also learn exclusive Linux features and tools that make an administrator’s job a breeze. Topics include: general system maintenance; centralized package management and updates; advanced security with SELinux; user account and password policy management; logical volume management; printer and device management; performance, troubleshooting and logging; backups; and more! Learn why Linux has become the platform of choice for serious data systems."
		classURL= "23"
	elseif classTitle == "(NEW) How Administering Linux is Different than Windows" then
		classTitleFull = classTitle
		classInstructor = "Erik Falor & Brian Sedgwick"
		classTrack = "System Administration Track - Linux"
		classTime = "Monday 1:45–2:45\nTuesday 12:30–1:30\nThursday 11:30–12:30"
		classRoom = "Room 251 A & B"
		classDesc= "Discover how the Linux Operating System makes administration easier than ever. Administrators with a Windows background may greet the idea of using Linux with trepidation. This class will dispel the myths and fears surrounding Linux and show how the most important administration tasks can be performed from a simple and familiar GUI interface. You will also learn exclusive Linux features and tools that make an administrator’s job a breeze. Topics include: installing and updating software; advanced system security; user account and password policy management; printer and device management; performance, troubleshooting and logging; backups; and more! Learn why Linux has become the platform of choice for serious data systems."
		classURL= "24"
	elseif classTitle == "(NEW) Solutions II Linux - HA/DR Options, Data & Virtualization" then
		classTitleFull = "(NEW) Solutions II Linux Training – HA/DR Options, Data Protection and Virtualization"
		classInstructor = "Solutions II"
		classTrack = "System Administration Track - Linux"
		classTime = "Wednesday 9:00–10:00\nWednesday 12:30-1:30\nWednesday 1:45–2:45"
		classRoom = "Room 251 A & B"
		classDesc= "Linux HA/DR Options, Infrastructure considerations for HA/DR options, RSYNC, Commercial Products, Local and Offsite Backup and Recovery, Virtualization Infrastructure Considerations"
		classURL= "25"
	elseif classTitle == "(NEW) Solutions II Open Forum - Ask the Expert (Linux)" then
		classTitleFull = classTitle
		classInstructor = "Solutions II"
		classTrack = "System Administration Track - Linux"
		classTime = "Wednesday 10:15-11:15\nWednesday 3:00–4:00"
		classRoom = "Room 251 A & B"
		classDesc= "Informal question and answer. Topics may include HA/DR, Data Protection and Virtualization"
		classURL= "90"
	elseif classTitle == "(NEW) To Be Announced at Opening General Session" then
		classTitleFull = classTitle
		classInstructor = "Matt Jolly & Brandon Banz"
		classTrack = "Research & Design Track"
		classTime = "Wednesday 12:30–1:30" 
		classRoom = "Ballroom C"
		classDesc= "Come learn more about some of the new products unveiled in the Opening General Session."
		classURL= "97"
	elseif classTitle == "(NEW) Engaging R&D" then
		classTitleFull = classTitle
		classInstructor = "Alan Harker"
		classTrack = "Research & Design Track"
		classTime = "Monday 12:30–1:30"
		classRoom = "Ballroom C"
		classDesc= "Come learn about the new Product Idea community in MySpillman and how your users’ vote can make a difference. Also, become familiar with other methods for engaging R&D and giving product feedback."
		classURL= "32"
	elseif classTitle == "Predictive Policing - Setting the Right Expectations" then
		classTitleFull = classTitle
		classInstructor = "Matt Jolly & BAIR Analytics"
		classTrack = "Research & Design Track"
		classTime = "Monday 1:45–2:45\nTuesday 9:00–10:00"
		classRoom = "Ballroom C"
		classDesc= "This class will be a high level presentation designed for command staff, officers, and analysts to help plan the roll out of Spillman Analytics as a Predictive Policing tool. Presenters will provide information on what to expect and what not to expect while implementing this strategy.\n\n   - What is Predictive Policing and what it is not?\n   - What are the elements of predictive policing and how does “it” work?\n   - How effective is predictive policing?\n   - What are the practical applications?\n   - Can Predictive Policing be incorporated and utilized by any size agency?\n   - What is involved for any agency to implement predictive policing?"
		classURL= "28"
	elseif classTitle == "Maximizing Agency Effectiveness with Spillman Analytics" then
		classTitleFull = classTitle
		classInstructor = " Matt Jolly & BAIR Analytics"
		classTrack = "Research & Design Track"
		classTime = "Tuesday 10:15–11:15"
		classRoom = "Ballroom C"
		classDesc= "Learn about the features available with Spillman Analytics and how this product can help you predict where crime and calls for service will occur over the near and long term and how to create time comparisons and animated hotspots over time to indicate increases and decreases in crime, crime type, and calls for service. Discussion will also include how to create and automate real time ad-hoc reports for crimes and calls for service, and how to customize meaningful and visual dashboards that can be accessed securely anywhere anytime by your department. This class is for all levels of law enforcement that are responsible for crime analysis and reporting for your agency."
		classURL= "29"
	elseif classTitle == "CAD/GIS: What’s New?" then
		classTitleFull = classTitle
		classInstructor = "Alan Harker"
		classTrack = "Research & Design Track"
		classTime = "Tuesday 12:30–1:30"
		classRoom = "Ballroom C"
		classDesc= "Learn about the recent enhancements Spillman has been working on for CAD, Geobase, and Mapping. Come see the latest improvements, get answers to your questions, and provide your input on where these products should be headed next. This class is for anyone interested in recent and upcoming changes to CAD, Geobase, and Mapping."
		classURL= "27"
	elseif classTitle == "Mobile: What’s New?" then
		classTitleFull = classTitle
		classInstructor = "Brian Pugh"
		classTrack = "Research & Design Track"
		classTime = "Tuesday 1:45–2:45\nWednesday 9:00–10:00"
		classRoom = "Ballroom C"
		classDesc= "In this class the Research and Design department will be showcasing some of the new features added to the Spillman Mobile product over the last year. You can expect to learn about when these new features will be available, as well as how to utilize them at your agency. This class is for any level of experience and is platform independent."
		classURL= "30"
	elseif classTitle == "Field Reporting: What’s New?" then
		classTitleFull = classTitle
		classInstructor = "Brian Pugh"
		classTrack = "Research & Design Track"
		classTime = "Tuesday 3:00-4:00\nWednesday 10:15–11:15"
		classRoom = "Ballroom C"
		classDesc= "In this class, the Research and Design department will be showcasing some of the new features added to the Mobile Field Reporting product over the last year. You can expect to learn about when these new features will be available as well as how to utilize them at your agency. This class is for any level of experience and is platform independent."
		classURL= "31"
	elseif classTitle == "Jail: What’s New?" then
		classTitleFull = classTitle
		classInstructor = "Brandon Banz"
		classTrack = "Research & Design Track"
		classTime = "Wednesday 1:45–2:45"
		classRoom = "Ballroom C"
		classDesc= "Learn about the new features for Sentryx Jail. The class will focus on features that have recently been released, and those that will be released soon. There will also be a discussion on the future of Spillman’s Jail product."
		classURL= "33"
	elseif classTitle == "Spillman DEx & StateLink: What’s New?" then
		classTitleFull = classTitle
		classInstructor = "Doug Leffler & Jeremy Balls"
		classTrack = "Research & Design Track"
		classTime = "Thursday 9:00–10:00"
		classRoom = "Ballroom C"
		classDesc= "In this session, attendees will learn about Spillman DEx (Data Exchange), its features and functionalities, and how it can benefit your agency. Attendees will also learn about recent developments now available in Spillman DEx as well as new interfaces developed in the past year that are now available for purchase by Spillman customers."
		classURL= "34"	
	elseif classTitle == "Records - What’s New?" then
		classTitleFull = classTitle
		classInstructor = "Matt Jolly"
		classTrack = "Research & Design"
		classTime = "Monday 10:15–11:15"
		classRoom = "Ballroom C"
		classDesc= "Learn about the new features for RMS. The class will focus on features that have recently been released, and those that will be released soon. There will also be a discussion on the future of Spillman’s RMS product." --?????????????
		classURL= "26"
	elseif classTitle == "R&D Panel" then
		classTitleFull = classTitle
		classInstructor = "R&D Department Track"
		classTrack = "Research & Design"
		classTime = "Thursday 10:15–11:15"
		classRoom = "Ballroom C"
		classDesc= "During this panel, you will have the opportunity to chat with members of the Research & Design department. This will be an open discussion for you to ask questions and relay your ideas and feedback. The forum will be open to items customers would like to discuss."
		classURL= "35"
	elseif classTitle == "(NEW) Sex Offender Tracking" then
		classTitleFull = classTitle
		classInstructor = "Kurt Bean"
		classTrack = "Records Track"
		classTime = "Monday 10:15–11:15"
		classRoom = "Ballroom D"
		classDesc= "This presentation and product demonstration will cover some of the latest product offerings from Spillman Technologies to include the new Sex Offender Tracking. The Sex Offender module demo will illustrate how your agency can track and report sex offender information assuring compliance with the Sex Offenders Registration and Notification Act (SORNA). You will be able to see several new Spillman reports specific to Sex Offender Tracking."
		classURL= "36"
	elseif classTitle == "(NEW) Using Advanced Searches & Join Tables" then
		classTitleFull = classTitle
		classInstructor = "Jake Tolman"
		classTrack = "Records Track"
		classTime = "Monday 12:30–1:30\nTuesday 9:00–10:00"
		classRoom = "Ballroom D"
		classDesc= "Learn how to find the data you are looking for. Join-table, add, and restrict searches will be discussed. Tricks for searching the system log will also be covered. This class will be presented at an intermediate level and will be largely platform independent."
		classURL= "37"
	elseif classTitle == "Managing Workflow & Approvals (2 hrs)" then
		classTitleFull = "Managing Workflow & Approvals"
		classInstructor = " Dustin Hunter"
		classTrack = "Records Track"
		classTime = "Monday 1:45–4:00\nTuesday 12:30–2:45"
		classRoom = "Ballroom D"
		classDesc= "Learn about Managing Workflow and Approvals so that you can effectively keep track of your record management system. We will discuss the most common misconceptions about workflow and how to present this to your staff so they better understand how the process works. This class will also cover codetable setup, management topics and questions. This class is for any level of user."
		classURL= "38"
	elseif classTitle == "Best Practices: A Day in the Life of a Records Supervisor" then
		classTitleFull = classTitle
		classInstructor = "Tammy Patterson (Weatchee Police Department, WA)"
		classTrack = "Records Track"
		classTime = "Tuesday 10:15–11:15\nWednesday 9:00–10:00"
		classRoom = "Ballroom D"
		classDesc= "This course will discuss a variety of tasks that fall into the day-to-day business of a records supervisor. Some of the items will include; Data standards, quality control, advanced searching, who add/when mod screens, reports, finding a report and name merging. The goal of this class is to give you some options for quality control to ensure that you have excellent data. At the end of class we will have an open forum for any questions you may have about your records data."
		classURL= "39"
	elseif classTitle == "(NEW) Introducing Sentryx IBR & Common Errors for NIBRS" then
		classTitleFull = classTitle
		classInstructor = "Lila Nealand"
		classTrack = "Records Track"
		classTime = "Tuesday 3:00–4:00"
		classRoom = "Ballroom D"
		classDesc= "This class will allow you to look into the new Sentryx Incident Based Reporting. It will show you the new functions and features of this module. It will show you the ease of using a singular database to collectand store victim, suspect, and property information. The class will demonstrate the ease of validation and understanding errors. This class will take you from entry to submission of the new state reporting module. This class is intended for beginner users of the Sentryx IBR and attendees should have basic understanding of the fundamentals of IBR."
		classURL= "40"
	elseif classTitle == "Maximize System Functionality" then
		classTitleFull = "Maximize System Functionality using HUB, File Attachments & Visual Involvements"
		classInstructor = "Dave Snyder"
		classTrack = "Records Track"
		classTime = "Wednesday 10:15–11:15\nThursday 9:00–10:00"
		classRoom = "Ballroom D"
		classDesc= "Learn advanced search features that allow better utilization of system data, including searches on multiple data fields within a single table and searches on multiple tables for the purpose of crime analysis, departmental statistics, suspect identification, etc. This presentation will explain how to track information disseminated by your agency, search Geobase addresses, and manage on-call personnel by job title or special skills."
		classURL= "41"
	elseif classTitle == "(NEW) Unlocking the Potential of the Personnel Module" then
		classTitleFull = classTitle
		classInstructor = "Frank DeMarzo"
		classTrack = "Records Track"
		classTime = "Wednesday 12:30–1:30"
		classRoom = "Ballroom D"
		classDesc= "In this session we will look at the power of the Personnel module, its features, and how it works. Content will also cover the advantages this module has for tracking training, positions, and information about your staff. The instructor will demonstrate in the Spillman software how to create records and how to search and update those records. You will also learn how to block certain fields from being viewed. This class is for any level of experience and is platform independent."
		classURL= "43"
	elseif classTitle == "Crime Analysis Tools: Pin Mapping, InSight & Reporting (2 hrs)" then
		classTitleFull = "Crime Analysis Tools: Pin Mapping, InSight & Reporting"
		classInstructor = "Kurt Bean & Dave Snyder"
		classTrack = "Records Track"
		classTime = "Wednesday 1:45–4:00\nThursday 10:15–12:30"
		classRoom = "Ballroom D"
		classDesc= "Learn effective methods for gathering accurate, timely, comprehensive crime statistical data to quickly identify crime trends by date, time, location and suspect. This presentation will offer the necessary crime analysis tools to identify crime trends and allocate appropriate resources. After compiling, analyzing, and mapping crime statistics, users will be able to more effectively direct law enforcement activities toward crime prevention, criminal apprehension, and threats to public safety."
		classURL= "42"
	elseif classTitle == "Best Practices: A Day in the Life of a Dispatch Supervisor" then
		classTitleFull = classTitle
		classInstructor = "Tammy Shiers (Sagadahoc County RCC, ME)"
		classTrack = "Dispatch Track"
		classTime = "Monday 10:15–11:15\nTuesday 9:00–10:00"
		classRoom = "Room 150 A,B,C,G"
		classDesc= "The challenge of a dispatch supervisor is to balance effective functions of the center with the very human employees who are its foundation. So how do we keep our center efficient while keeping morale high? Join us as we discuss the issues that affect performance and morale such as social media in the center, complete data entry and everyday issues that pop up in the day to day life of a dispatch supervisor."
		classURL= "45"
	elseif classTitle == "(NEW) Practical Applications for the CAD Dashboard Module" then
		classTitleFull = classTitle
		classInstructor = "Rich Hendricks"
		classTrack = "Dispatch Track"
		classTime = "Monday 12:30–1:30\nTuesday 12:30–1:30"
		classRoom = "Room 150 A,B,C,G"
		classDesc= "This class will focus on the functionality of the dashboard screens along with the intent of the overall design. Examples will be given on how an environment of accountability and achievement can be developed within the organization. Class time will also include ideas and discussion on inter-agency and multi-agency workload and 911-center volume management."
		classURL= "46"	
	elseif classTitle == "Response Plans Using Recommended Units (2 hrs)" then
		classTitleFull = "Response Plans Using Recommended Units"
		classInstructor = "Steve Angell"
		classTrack = "Dispatch Track"
		classTime = "Monday 1:45–4:00"
		classRoom = "Room 150 A,B,C,G"
		classDesc= "This class is intended for immediate skill level users. It will go through the setup and use of Recommended Units within CAD. Specifically, what the apparams will do, how to setup the recommended units table and how to use recommended units for daily dispatching. It will also go through and show how to setup and use Response Plans incorporating Recommended Units into the use of Response Plans, as well as covering additional information to help get the most out of Response Plans."
		classURL= "44"	
	elseif classTitle == "ProQA Police, Fire, and Medical" then
		classTitleFull = classTitle
		classInstructor = "Cody Christensen"
		classTrack = "Dispatch Track"
		classTime = "Tuesday 10:15–11:15"
		classRoom = "Room 150 A,B,C,G"
		classDesc= "The focus of this class is to show how the Spillman software interfaces with Priority Dispatch ProQA. The Spillman Paramount ProQA Interface is an extremely robust interface allowing two way communications between Spillman and ProQA. This class will demonstrate the functionality and ease of use of the Spillman/ ProQA interoperability."
		classURL= "49"	
	elseif classTitle == "Top Shortcuts for Dispatchers" then
		classTitleFull = classTitle
		classInstructor = "Frank DeMarzo"
		classTrack = "Dispatch Track"
		classTime = "Tuesday 1:45–2:45\nWednesday 10:15–11:15"
		classRoom = "Room 150 A,B,C,G"
		classDesc= "During this session, we will look at new dispatchers or supervisors and discuss some of the CAD commands that dispatchers use and how they function. We will also provide any help, workarounds or experiences you have had. This class is for beginners but anyone who is interested may attend. A PowerPoint demo will be used, as well as the Spillman software."
		classURL= "47"	
	elseif classTitle == "Paging Functionality with HipLink" then
		classTitleFull = classTitle
		classInstructor = "Kurt Bean"
		classTrack = "Dispatch Track"
		classTime = "Tuesday 12:30–1:30\nWednesday 3:00–4:00"
		classRoom = "Room 150 A,B,C,G"
		classDesc= "See a demonstration of Spillman’s paging interface with HipLink. Learn how to customize the Paging tables to be used with manual paging and with the CAD command line. Learn how automatic paging based upon a call nature will reduce dispatch input time. See what information will send to smartphones and email addresses. Learn how to manage personnel pagers and paging groups."
		classURL= "50"	
	elseif classTitle == "(NEW) Dispatching Basics" then
		classTitleFull = classTitle
		classInstructor = "Angie Phelps"
		classTrack = "Dispatch Track"
		classTime = "Wednesday 9:00–10:00"
		classRoom = "Room 150 A,B,C,G"
		classDesc= "Learn about basic dispatching functions. This course will contain information about adding calls, dispatching units to calls, updating unit statuses, completing calls, modifying existing calls, etc. Time permitting, this course may also include information on some updates and new features that will enhance dispatching basics you may already know. This is a beginning level course, and is not platform specific."
		classURL= "52"	
	elseif classTitle == "CAD Set Up & Administration (2 hrs)" then
		classTitleFull = "CAD Set Up & Administration"
		classInstructor = "Angie Phelps"
		classTrack = "Dispatch Track"
		classTime = "Wednesday 1:45–4:00\nThursday 9:00–11:15"
		classRoom = "Room 150 A,B,C,G"
		classDesc= "This is an intermediate level course designed to cover the setup and maintenance of CAD related tables, parameters, and other settings. Learn about code tables for call natures, units, dispatch positions, status codes, etc. Parameters that control incident creation and other important CAD settings will also be discussed. Recommended Units or Response Plans during will NOT be covered. This course is not platform specific."
		classURL= "48"	
	elseif classTitle == "Maximizing CAD System Reports" then
		classTitleFull = classTitle
		classInstructor = "Chase Robinson"
		classTrack = "Dispatch Track"
		classTime = "Thursday 11:30–12:30"
		classRoom = "Room 150 A,B,C,G"
		classDesc= "Learn how to best utilize the CAD reports available to you as well as create your own. Receive tips on standardizing data entry so that reports pull the most accurate information possible and make post-entry reporting invaluable. Content will also cover several of the built-in reports and how to use them best to your advantage as well as creating custom table entries to pull data that a stock report might be neglecting. Understanding basic functionality, searching, and data entry can make even the most daunting report relatively simple! This class will be taught with any experience level in mind and will be operating system independent."
		classURL= "51"	
	elseif classTitle == "(NEW) Extracting Geobase Information Using Crystal Reports (4 hrs)" then
		classTitleFull = "(NEW) Extracting and Displaying Geobase Information Using Crystal Reports"
		classInstructor = " Doug Ashmore (Nevada Dept. of Public Safety, NV)"
		classTrack = "GIS Track"
		classTime = "Monday 10:15–4:00"
		classRoom = "Room 151 A,B,C,G"
		classDesc= "The objective of this class is to demonstrate how to use the power of Crystal Reports to extract and use Geobase information from Spillman tables that store address information. This data then can be exported and used in third-party applications. The instructor will show you examples on how to filter data and create formulas to format XY data from different Spillman tables, create PDFs with embedded hyperlinks to Google Maps, create KML files to be used in Google Earth, and format and export data to be used in other applications. Prior knowledge of basic Crystal Reports and basic understanding of Crystal Reports formula building is a prerequisite."
		classURL= "53"	
	elseif classTitle == "Advanced Techniques & Validations for Sentryx Geobase (3 hrs)" then
		classTitleFull = "Advanced Techniques & Validations for Sentryx Geobase"
		classInstructor = "Josse Allen,"
		classTrack = "GIS Track"
		classTime = "Tuesday 9:00–1:30"
		classRoom = "Room 151 A,B,C,G"
		classDesc= "Sentryx Geobase features a flexible database model that can be customized to fit your specific agency needs. So what do you do with your newly found freedom? This class presents various strategies for creating less traditional feature inputs -- like street blocks, railroad crossings, trails – as well as little tweaks to get more information from your data. Or, maybe you’re looking to optimize your Sentryx Geobase for better performance. Are you plagued with database errors? Even though there are no forced validation routines, there still remain a few requirements as well as guidelines that when applied, will eliminate common data related errors. These techniques and validations will help you capitalize on the open data design while ensuring database integrity and performance. This class is for GIS professionals and the moderately advanced to advanced GIS user."
		classURL= "54"
	elseif classTitle == "(NEW) Leveraging GIS Showcase (2 hrs)" then
		classTitleFull = "(NEW) Leveraging GIS Showcase"
		classInstructor = "Josse Allen & Trey Crane"
		classTrack = "GIS Track"
		classTime = "Tuesday 1:45–4:00"
		classRoom = "Room 151 A,B,C,G"
		classDesc= "This is a showcase class where various customers will demonstrate how they are leveraging GIS to create extended solutions for the Spillman system. Presentations include: automating workflows with Python; creating web based map applications from Spillman data; creating real-time mobile map applications. This class is for GIS professionals and system administrators looking for ideas on how to extend GIS functionality for the end users and optimize workflows."
		classURL= "57"
	elseif classTitle == "Enhancing Your Classic Maps" then
		classTitleFull = classTitle
		classInstructor = "Trey Crane"
		classTrack = "GIS Track"
		classTime = "Wednesday 9:00–10:00"
		classRoom = "Room 151 A,B,C,G"
		classDesc= "This class is intended for those who are looking to visually enhance their CAD and Pin Maps to communicate the map data to the end user more effectively and present a clear picture of what is going on in your agency’s response area. This class covers map symbology including label and color pallet tips and tricks. The class will also cover unique ways to represent the different data layers on your map. All this and more will be covered during this exploration of your CAD/Pin Map."
		classURL= "55"
	elseif classTitle == "(NEW) GIS Analysis (4 hrs)" then
		classTitleFull = "(NEW) GIS Analysis"
		classInstructor = "Josse Allen & Chris Klaube (Monmouth Co. Sheriff, NJ)"
		classTrack = "GIS Track"
		classTime = "Wednesday 10:15–4:00"
		classRoom = "Room 151 A,B,C,G"
		classDesc= "This class presents methods for leveraging GIS to analyze your Spillman RMS data. Key topics include: extracting data from the Spillman RMS; data processing and manipulation; creating comprehensive spatial analysis and statistics. The results will enable decision makers to visualize patterns, identify correlations, assess resource efficiency, and ultimately facilitate informed decision making. This class is for GIS professionals and the advanced GIS users. The student should be well adept to GIS principles and concepts."
		classURL= "56"
	elseif classTitle == "Classic Geobase Refresher (2 hrs)" then
		classTitleFull = "Classic Geobase Refresher"
		classInstructor = "Trey Crane"
		classTrack = "GIS Track"
		classTime = "Thursday 9:00–11:15"
		classRoom = "Room 151 A,B,C,G"
		classDesc= "This class is intended for those thinking about these two questions: Has it been a while since you have updated your Spillman Classic Geobase? And, do you remember what the difference between gbload and gbload -l is? If you answered “yes” and “I don’t know,” then this class is for you. We will be covering the ins and outs of the Classic Geobase load process, from working with the input GIS data, to solving why that intersection won’t validate. The class will also cover how to use the gbload logs to correct your source GIS data so your next gbload will be a breeze. This class is recommended for intermediate Geobase users."
		classURL= "59"
	elseif classTitle == "Migrating to Sentryx Geobase for Administrators" then
		classTitleFull = classTitle
		classInstructor = "Trey Crane"
		classTrack = "GIS Track"
		classTime = "Thursday 11:30–12:30"
		classRoom = "Room 151 A,B,C,G"
		classDesc= "This class is intended for those who are thinking about upgrading their classic Geobase to Sentryx. This session reviews the process of migrating to Sentryx Geobase, and how that impacts you as an Administrator so that you can make an informed decision and begin to prepare for a successful Geobase migration. Key topics of discussion include: Existing Geobase assessment, GIS data structure requirements, what happens to existing Geobase data, overview of the hardware and software requirements, and a demonstration of the Sentryx Geobase development process."
		classURL= "58"
	elseif classTitle == "(NEW) How to Lead an Effective CompStat Meeting" then
		classTitleFull = classTitle
		classInstructor = "Rich Hendricks & Chief Mitch Little (Toms River PD, NJ)"
		classTrack = "Executive Track"
		classTime = "Monday 10:15–11:15\nTuesday 1:45–2:45"
		classRoom = "Room 250 A,B"
		classDesc= "Class material will be centered on the different applications of the CompStat principles within the management structure of a public safety agency. Ideas and examples of a CompStat meeting agenda will be presented along with success stories from across the country. The latest enhancements of the CompStat dashboard will be displayed and a conversation about future enhancements will also be included."
		classURL= "61"	
	elseif classTitle == "(NEW) Leveraging Technology In a Disaster" then
		classTitleFull = "(NEW) Leveraging Technology In a Disaster"
		classInstructor = "Tim Watkins & Captain Jeff Hartley (Tuscaloosa PD, AL)"
		classTrack = "Executive Track"
		classTime = "Monday 12:30–1:30\nTuesday 12:30–1:30"
		classRoom = "Room 250 A,B"
		classDesc= "Representatives from the Tuscaloosa Police Department in Alabama will provide a first-hand account of the tornado that swept thru Tuscaloosa in 2011. Mr. Watkins and Captain Hartley will highlight the needs and challenges the department had, how they leveraged technology, and the major role their Spillman system had during the agencies response during this natural disaster. Class discussion will also include the importance of the recovery/redundancy features within Spillman and how this feature helps Tuscaloosa."
		classURL= "60"
	elseif classTitle == "(NEW) How to Effectively Supervise a Multi-Generational Team" then
		classTitleFull = classTitle
		classInstructor = "Rich Hendricks"
		classTrack = "Executive Track"
		classTime = "Monday 1:45–2:45\nTuesday 10:15–11:15"
		classRoom = "Room 250 A,B"
		classDesc= "This class is driven by the evolution of today’s workforce. Managing a multi-generational team is a complex undertaking. One size does not fit all any longer. The material will offer new leadership and managerial tactics that will strengthen the supervisor’s ability to move from basic activity to a culture of responsibility and achievement. The class will include audience participation and experiences to highlight the presentation."
		classURL= "64"
	elseif classTitle == "(NEW) Transformational Leadership" then
		classTitleFull = classTitle
		classInstructor = "Rich Hendricks"
		classTrack = "Executive Track"
		classTime = "Monday 3:00–4:00"
		classRoom = "Room 250 A,B"
		classDesc= "This scenario-based leadership class will examine a style of leadership proven by history and studied for decades. Transformational leadership has been used to change organizations and create the desired atmosphere and work environment that will focus on the leader’s desired strategy. Understanding the principles of Transformational Leadership will create a culture of accountability and achievement."
		classURL= "63"
	elseif classTitle == "(NEW) What is Intelligence-Led Policing?" then
		classTitleFull = classTitle
		classInstructor = "Rich Hendricks"
		classTrack = "Executive Track"
		classTime = "Tuesday, 9:00–10:00"
		classRoom = "Room 250 A,B"
		classDesc= "The class will present the basic concepts of Intelligence-Led Policing along with the leadership style necessary to incorporate this style of policing. The principles involve many software and technology implications both within and outside of the agency. The concept of Predictive Policing is also being promoted as the new future of Police management. The class will describe the differences between the two concepts and demonstrate how Spillman Technologies is providing state-of-the-art software to support both theories."
		classURL= "65"
	elseif classTitle == "(NEW) Grants: How to Get Started & What are the Guidelines" then
		classTitleFull = classTitle
		classInstructor = "Rich Hendricks & Cathy Thompson"
		classTrack = "Executive Track"
		classTime = "Tuesday 3:00–4:00"
		classRoom = "Room 250 A,B"
		classDesc= "This presentation will be center on the federal government grant environment. The playing field has changed and federal money is being redirected through many different kinds of departments with specialized activities. Websites and agency experiences will all be examined to assist in successfully locating, applying, and managing the grant opportunities that are available."
		classURL= "62"
	elseif classTitle == "(NEW) What Mobile Can Provide in the Vehicle that Spillman Can’t" then
		classTitleFull = classTitle
		classInstructor = "Dave Snyder"
		classTrack = "Mobile Track"
		classTime = "Wednesday 9:00–10:00"
		classRoom = "Room 250 A,B"
		classDesc= "This presentation and product demonstration will highlight some of the capabilities Mobile provides to users in the field that Spillman’s desktop application doesn’t, including: allowing field personnel heightened communication capabilities with CAD, enabling access to accurate, real-time call information thereby increasing situational awareness for enhanced officer safety, and the ability to quickly update unit statuses and add radio log entries without requiring direct communication with dispatch. This presentation will also demonstrate new features available in Mobile such as the ability to add Name, Vehicle, and Property records in Mobile and the capability to import Name & Vehicle information from State Returns as well as the ability to add file attachments in Mobile."
		classURL= "66"
	elseif classTitle == "(NEW) Best Practices: Utilizing Mobile for Intelligence-Led Policing" then
		classTitleFull = classTitle
		classInstructor = "Lt. Mike Fisher (Osceola County Sheriff, FL)"
		classTrack = "Mobile Track"
		classTime = "Wednesday 10:15–11:15\nThursday 9:00–10:00"
		classRoom = "Room 250 A,B"
		classDesc= "Find out how Osceola County Sheriff’s Office in Florida utilizes Spillman Mobile as an intelligence-led policing tool for officers in the field. In this session attendees will learn how patrol officers can track gang members, sex offenders and repeat and habitual offenders in their work areas, which creates a common operating picture of all of these subjects, for officers when they are responding to calls from their vehicle. Attendees will discover useful tips as Lt. Fisher demonstrates real life experiences on how Osceola patrol officers can data mine information to find leads and identify suspects using features such as custom mapping, alerts and other functions using Spillman Mobile."
		classURL= "68"
	elseif classTitle == "(NEW) Mobile Basics Plus Sex Offender Tracking & Other New Features" then
		classTitleFull = classTitle
		classInstructor = "Rob Hall"
		classTrack = "Mobile Track"
		classTime = "Wednesday 12:30–1:30\nThursday 10:15–11:15"
		classRoom = "Room 250 A,B"
		classDesc= "This class will provide a demonstration of the basics for Workflow, Message Center, and Mobile Search Screens. Content will also cover the newly released Sex Offender Tracking module and the ability to update and manage through Mobile. Presenter will also cover adding and modifying Names, Vehicles, and Property within Mobile."
		classURL= "69"	
	elseif classTitle == "Mobile Set Up & Administration (2 hrs)" then
		classTitleFull = "Mobile Set Up & Administration"
		classInstructor = "Jeff Griffin"
		classTrack = "Mobile Track"
		classTime = "Wednesday 1:45–4:00"
		classRoom = "Room 250 A,B"
		classDesc= "Learn how to successfully set up and maintain the Spillman Mobile software. The course will teach participants how to install and update the Mobile Client and work with settings on the server. The instructor will also cover how to set up Spillman modules including AVL, mapping, and Voiceless CAD. Additionally, participants will be taught how to set up and maintain users, groups, and logs within the system. This class is taught at an intermediate level and is intended for agency SAAs or anyone at your agency who maintains Spillman Mobile. Attendees should have prior knowledge of setting up and using the mobile application."
		classURL= "70"	
	elseif classTitle == "Fire Mobile Premises & HazMat, CAD & AVL Mapping" then
		classTitleFull = classTitle
		classInstructor = "Rob Hall"
		classTrack = "Mobile Track"
		classTime = "Thursday 11:30–12:30"
		classRoom = "Room 250 A,B"
		classDesc= "Come see an overview of Spillman’s Mobile Premises and HazMat Modules, as well as CAD and AVL mapping. These modules provide a vast amount of information to responders as they access and plan for incidents. You’ll see how AVL, Mapping, and Premises and HazMat will enhance your agency and provide valuable information to your personnel. Class material will cover entering and managing information, searching functionality, common map usages in the Mobile environment, and the features and benefits of AVL and CAD Mapping."
		classURL= "67"	
	elseif classTitle == "(NEW) Advanced Searching & List Reports in Sentryx" then
		classTitleFull = classTitle
		classInstructor = "Dustin Hunter"
		classTrack = "Corrections Track"
		classTime = "Monday 10:15–11:15\nThursday 9:00–10:00"
		classRoom = "Room 250 D,E"
		classDesc= "This session will discuss and answer questions that you may have regarding performing advanced search functions within the Spillman system. The main topics formally discussed will include using the JADD, JRES, and JTBL search functions. We will also discuss searching addresses using Geobase, Pin Mapping, and the reports screen. The class is designed for any level of user to help them maximize their search results from the Spillman records management system. This class is the same whether you are operating off of a UNIX or a Windows server."
		classURL= "71"
	elseif classTitle == "(NEW) Best Practices: Migrating from Classic Jail to Sentryx" then
		classTitleFull = "(NEW) Best Practices: Migrating from Classic Jail to Sentryx: From an Agency View"
		classInstructor = "Lt. Mark Freeman (Spartanburg County Sheriff, SC)"
		classTrack = "Corrections Track"
		classTime = "Monday 12:30–1:30\nWednesday 10:15–11:15"
		classRoom = "Room 250 D,E"
		classDesc= "Attend this class for an insiders look at the process Spartanburg County, SC went thru to migrate from Classic Jail to Sentryx. Learn about the real life experiences of this agency as Lt. Freeman shares his guideline of tips for a successful migration."
		classURL= "76"	
	elseif classTitle == "Sentryx Booking Checklist (2 hrs)" then
		classTitleFull = "Sentryx Booking Checklist"
		classInstructor = "Bryan Hawkins"
		classTrack = "Corrections Track"
		classTime = "Monday 1:45–4:00"
		classRoom = "Room 250 D,E"
		classDesc= "Discover the tools available to you in the Sentryx Booking Checklist. Class material will cover the major differences between Classic Jail 4.6 and the new Sentryx Jail. The instructor will also show how the system makes booking in an inmate simple and painless from a single location within the software. Each section of the checklist will be covered with details given on the data fields and the necessities for the data in the booking process. This class is a beginner level session and is designed for the new Spillman user of Sentryx Jail."
		classURL= "74"	
	elseif classTitle == "(NEW) Sentryx Jail Troubleshooting" then
		classTitleFull = classTitle
		classInstructor = "Jared Moulding"
		classTrack = "Corrections Track"
		classTime = "Tuesday 10:15–11:15\nWednesday 9:00–10:00"
		classRoom = "Room 250 D,E"
		classDesc= "Learn how to diagnose and troubleshoot problems encountered while working with Sentryx Jail. Topics covered in this class will include common setup and configuration issues, privileges, code table administration, and methods to investigate and troubleshoot problems found within your Sentryx Jail system. The instructor will also cover precautionary measures to mitigate and avoid common issues and errors. New features and how they can be incorporated to assist with maintenance and troubleshooting will also be discussed. To get the most benefit from this class, attendees should be familiar with Sentryx Jail and Administration Manager."
		classURL= "77"	
	elseif classTitle == "Sentryx Jail Tips & Tricks (2 hrs)" then
		classTitleFull = "Sentryx Jail Tips & Tricks"
		classInstructor = "Mike Hopkins"
		classTrack = "Corrections Track"
		classTime = "Tuesday 12:30–2:45\nThursday 10:15-12:30"
		classRoom = "Room 250 D,E"
		classDesc= "This class will help the intermediate Sentryx user learn tips on getting the most out of their new Sentryx jail software. Class content will cover ways to ensure your system settings are properly customized for your facility along with tips for streamlining your bookings, logs, reports, locations, and incidents. To get the most out of this class, attendees should have a basic understanding of the Sentryx Administrator manager and the Sentryx admin mode. This class will be taught on a UNIX platform; however the material is still applicable to the Windows platform as well."
		classURL= "75"	
	elseif classTitle == "(NEW) Moving Beyond the Booking Checklist" then
		classTitleFull = classTitle
		classInstructor = "Tony Christensen"
		classTrack = "Corrections Track"
		classTime = "Tuesday 3:00–4:00\nWednesday 3:00–4:00"
		classRoom = "Room 250 D,E"
		classDesc= "This course will introduce you to features available in Sentryx Jail beyond the Booking Checklist. This will include how to use the Accounting Module, how to use Billing, some tips and tricks for using the Movement Screen, and customizing the Inmate List. Students will also learn some more advanced searching techniques in Sentryx, as well as how to use the Visitation Module. Students attending this course should be familiar with the Booking Checklist."
		classURL= "73"	
	elseif classTitle == "Sentryx Corrections Administration Setup (2 hrs)" then
		classTitleFull = "Sentryx Corrections Administration Setup"
		classInstructor = "Dustin Hunter"
		classTrack = "Corrections Track"
		classTime = "Wednesday 12:30–2:45"
		classRoom = "Room 250 D,E"
		classDesc= "This session will be class to discuss and answer any questions that you may have regarding the administrative setup of the Sentryx Jail software. The class will cover the schedule of events that will take place during a typical Jail Admin Week with your assigned Spillman Trainer as well as a brief overview of the setup process. The basic setup screens will be shown and discussed and ideas will be given on how to make your Jails setup go smoothly. This is a perfect class for SAAs and other users that will be involved with the setup. This class is for Advanced level users and the operation is the same whether you are operating off of a Unix or a Windows server."
		classURL= "72"	
	elseif classTitle == "Basic Crystal Reports Session A (6 hrs)" then
		classTitleFull = "Basic Crystal Reports Session A"
		classInstructor = "Mike Kilgore"
		classTrack = "Crystal Reports Track"
		classTime = "(Must attend both sessions)\nMonday 10:15–4:00\nTuesday 9:00–11:15"
		classRoom = "Room 150 D,E,F"
		classDesc= "PRE-REGISTRATION IS REQUIRED FOR THIS CLASS.\n\nThis is a hands-on class with equipment provided for eash attendee.\n\nLearn how to create custom reports quickly and easily. Students will learn how to create presentation quality reports for agency heads, city and county councils, boards of supervisors, mayors, commissioners, and the like. Students will learn how to export reports to Adobe PDF or HTML for use in external sources such an email, social networking, or departmental websites. While this course is updated for the 2011 version, it is intended for people who are new to Crystal Reports. No prior knowledge of Crystal is required, although basic Spillman knowledge if helpful."
		classURL= "83"	
	elseif classTitle == "Basic Crystal Reports Session B (6 hrs)" then
		classTitleFull = "Basic Crystal Reports Session B"
		classInstructor = " Doug Ashmore (Neveda Dept. of Public Safety, NV)"
		classTrack = "Crystal Reports Track"
		classTime = "(Must attend both sessions)\nTuesday 12:30–4:00\nWednesday 9:00–1:30"
		classRoom = "Room 150 D,E,F"
		classDesc= "PRE-REGISTRATION IS REQUIRED FOR THIS CLASS.\n\nThis is a hands-on class with equipment provided for eash attendee.\n\nLearn how to create custom reports quickly and easily. Students will learn how to create presentation quality reports for agency heads, city and county councils, boards of supervisors, mayors, commissioners, and the like. Students will learn how to export reports to Adobe PDF or HTML for use in external sources such an email, social networking, or departmental websites. While this course is updated for the 2011 version, it is intended for people who are new to Crystal Reports. No prior knowledge of Crystal is required, although basic Spillman knowledge if helpful."
		classURL= "84"
	elseif classTitle == "Advanced Crystal Reports 2011 (5 hrs)" then
		classTitleFull = "Advanced Crystal Reports 2011" 
		classInstructor = "Mike Kilgore & Doug Ashmore"
		classTrack = "Crystal Reports Track"
		classTime = "(Must attend both sessions)\nWednesday 1:45–4:00Thursday 9:00–12:30"
		classRoom = "Room 150 D,E,F"
		classDesc= "PRE-REGISTRATION IS REQUIRED FOR THIS CLASS.\n\nThis is a hands-on class with equipment provided for eash attendee.\n\nA portion of this class will be an overview of Crystal Reports. The remainder of the session will be focused on the new material. Topics covered will be basic formulas, parameters, templates, cross-tab reports, and most especially data from multiple Spillman tables at the same time up to and including drawing data from the Spillman Involvements table. New to the class this year you will also be shown how to extract and display Geobase data as hyperlinks on a PDF to Google maps and export data to be used in Google Earth. This course is intended for students that have prior basic Crystal Reporting experience. Knowledge of how Spillman database table relate to one another is very helpful in this class."
		classURL= "85"	
	elseif classTitle == "DAC Certification Training (6 hrs)" or classTitle == "DAC Certification Testing (2 hrs)" then
		classTitleFull = "DAC Certification Training & Testing"
		classInstructor = "Elly Dice & Jeff Griffin"
		classTrack = "Training and Certification Track"
		classTime = "Training: Monday 10:15–4:00 & Tuesday 9:00–11:15\nTest: Tuesday 12:30–2:45"
		classRoom = "Room 151 D,E,F"
		classDesc= "PRE-REGISTRATION IS REQUIRED FOR THIS CLASS.\n\nThis is a hands-on class with equipment provided for eash attendee.\n\nThis certification course is designed for Spillman Administrators and/or Communications Supervisors. During this certification students will learn about CAD code tables and application parameters that affect the function of the Spillman CAD system. Students will also be given an in-depth review of various CAD commands and functions. Students will be administered a certification exam at the end of the course. The exam will have questions ranging from setting up your CAD system to the basic functions of your Spillman CAD system."
		classURL= "82"
	elseif classTitle == "RAC Certification Training (6 hrs)" or classTitle == "RAC Certification Testing (2 hrs)" then
		classTitleFull = "RAC Certification Training & Testing"
		classInstructor = "Lila Nealand & Bryan Hawkins"
		classTrack = "Training and Certification Track"
		classTime = "Training: Wednesday 9:00–4:00 & Thursday 9:00–10:00\nTest: Thursday 10:15–12:30"
		classRoom = "Room 151 D,E,F"
		classDesc= "PRE-REGISTRATION IS REQUIRED FOR THIS CLASS.\n\nThis is a hands-on class with equipment provided for eash attendee.\n\nIn the certification class, the Instructor will go over the Hub Module and the Law Enforcement Records Module, pointing out features that will allow better utilization of the software’s functionality. It will also cover the operation of certain system administration that pertains to and manipulate the tables in both modules. This class will cover and explain the fundamentals which will give you the tools necessary to become certified Records Administrators."
		classURL= "81"	
	elseif classTitle == "(NEW) Spillman Paint Workshop" then
		classTitleFull = classTitle
		classInstructor = "Derik Christensen"
		classTrack = "Training and Certification Track"
		classTime = "Tuesday 3:00–4:00 (Room 151 D,E,F)\nThursday 11:30–12:30 (Room 250 C & F)"
		classRoom = "Rooms Listed Below"
		classDesc= "The Spillman Paint workshop will offer a hands-on opportunity to learn about the Spillman paint utility. This utility provides you with the functionality to customize your agencies Spillman screens. Customization option includes changing field labels, making fields required, hiding fields, changing the tab order, and in some cases displaying fields from one screen onto another. This workshop is and advanced level class and is best suited for technical users and SAA’s. Limited seats are available for this workshop."
		classURL= "88"
	elseif classTitle == "CSAC Certification Training (6 hrs)" or classTitle == "CSAC Certification Testing (2 hrs)" then
		classTitleFull = "CSAC Certification Training & Testing"
		classInstructor = "Tony Christensen & Mike Hopkins"
		classTrack = "Training and Certification Track"
		classTime = "Training: Monday 9:00–4:00 & Tuesday 9:00–11:15\nTest: Wednesday 9:00–11:15"
		classRoom = "Room 250 C & F"
		classDesc= "PRE-REGISTRATION IS REQUIRED FOR THIS CLASS.\n\nThis is a hands-on class with equipment provided for eash attendee.\n\nThis course will teach the skills you need to successfully set up and manage your Spillman Sentryx Jail installation. Attendees will learn how to administer users and agencies and learn about jail code tables and system privileges. You will also discover important information about jail settings and details about each of the jail modules. A 90 minute practical test may be taken for those who wish to become certified. Before the testing a review class will also be available during the conference."
		classURL= "80"
	elseif classTitle == "(NEW) Open Discussion Workshop" then
		classTitleFull = classTitle
		classInstructor = "Jeff Griffin"
		classTrack = "Training and Certification Track"
		classTime = "Thursday, 9:00 a.m. – 10:00 a.m."
		classRoom = "Room 250 C & F"
		classDesc= "This lab session will provide an atmosphere to work one on with a trainer in regards to any modules. Hands on problem solving, data retrieval methods and suggestions to help you attempt to solve issues your agency may be having. This will also allow the users to look at and practice with any modules that the agency may be considering purchasing. This session will exclude information on Sentryx Jail, GEOBASE, and any interfaces. Limited seats are available for this workshop. This is a hands-on class with equipment provided for each attendee."
		classURL= "87"
	elseif classTitle == "Sentryx Jail Workshop" then
		classTitleFull = classTitle
		classInstructor = "Dustin Hunter"
		classTrack = "Training and Certification Track"
		classTime = "Thursday 10:15–11:15"
		classRoom = "Room 250 C & F"
		classDesc= "This session will be an open forum Sentryx Jail Workshop to discuss and answer any questions that you may have regarding Sentryx Jail. The class will be a hands-on class geared around topics and questions asked by you, the user, that you would like to know more about. This is a perfect class for New SAAs and agencies preparing to start using Spillman’s Sentryx Jail Software. This class is open to any level of user and the operation is the same whether you are operating off of a UNIX or a Windows server. Limited seats are available for this workshop. This is a hands-on class with equipment provided for each attendee."
		classURL= "86"
	elseif classTitle == "SAA Certification Review for UNIX (3 hrs)" or classTitle == "SAA Certification Test for UNIX (3 hrs)" then
		classTitleFull = "SAA Certification Review & Test (UNIX)"
		classInstructor = "Devin Larsen & David R. Myers"
		classTrack = "Training and Certification Track"
		classTime = "Review: Monday 10:15–2:45(Room 250 F)\nTest: Tuesday 12:30–4:00 (Room 250 C)"
		classRoom = "Rooms Listed Below"
		classDesc= "PRE-REGISTRATION IS REQUIRED FOR THIS CLASS.\n\nThis class is designed to teach SAAs the basic level of application administration. This class is designed for UNIX users. Prior to attending the Users’ Conference, attendees will be offered an online course that will cover the course material that will be tested upon. At Users’ Conference we will be offering a review session prior to the testing. This review session will be based upon the testing material and will cover as much of the material as possible in the allotted time. The review session should be viewed as extra time spent on this class and should not be the only time you have reviewed the material."
		classURL= "78"
	elseif classTitle == "SAA Certification Review for Windows (3 hrs)" or classTitle == "SAA Certification Test for Windows (3 hrs)" then
		classTitleFull = "SAA Certification Review & Test (Windows)"
		classInstructor = "Devin Larsen & Scott Mattson"
		classTrack = "Training and Certification Track"
		classTime = "Review: Monday 3:00–4:00 &\nTuesday 9:00-11:15 (Room 250 F)\nTest: Wednesday 12:30–4:00 (Room 250 C)"
		classRoom = "Rooms Listed Below"
		classDesc= "PRE-REGISTRATION IS REQUIRED FOR THIS CLASS.\n\nThis class is designed to teach SAAs the basic level of application administration. This class is designed for Windows users. Prior to attending the Users’ Conference, attendees will be offered an online course that will cover the course material that will be tested upon. At Users Conference we will be offering a review session prior to the testing. This review session will be based upon the testing material and will cover as much of the material as possible in the allotted time. The review session should be viewed as extra time spent on this class and should not be the only time you have reviewed the material."
		classURL= "79"																											
	else
		classTitleFull = classTitle
		classInstructor = "NOT FOUND"
		classTrack = "NOT FOUND"
		classTime = "NOT FOUND"
		classRoom = "NOT FOUND"
		classDesc= "NOT FOUND"	
	end		
end

local function onKeyEvent( event )	-- Android Key Press event handler
	local returnValue = true
	local keyName = event.keyName
	local keyPhase = event.phase

	if( (keyName == "back") and (keyPhase == "down") ) then	--BACK KEY (BACK PAGES)
		if phaseCur == "home" then
			native.requestExit()
		elseif phasePrev == "ClassButton" then
			tabBar:setSelected(2, true)
			phasePrev = "home"
			phaseCur = "ClassButton"
		elseif phasePrev == "FeedbackButton" then
			tabBar:setSelected(3, true)
			phasePrev = "home"
			phaseCur = "FeedbackButton"		
		elseif phaseCur == "ClassSurvey" then
			classFeedbackPage.isVisible = false
			classListFeedback.isVisible = true			
			phasePrev = "FeedbackButton"
			phaseCur = "ClassFeedbackButton"	
		elseif phaseCur == "ClassDetails" then
			transition.to( detailsScreen, { time=250, x=display.contentWidth } )
        	transition.to( classListDate, { time=250, x=(display.contentWidth*.5) } )
        	transition.to( classListTrack, { time=250, x=(display.contentWidth*.5) } )
        	transition.to( classListFavorite, { time=250, x=(display.contentWidth*.5) } )
			phasePrev = "ClassButton"
		elseif phaseCur == "DetailsMap" then
			conferenceMapPage.isVisible = false
			phaseCur = "ClassDetails"
		elseif phaseCur == "DetailsFeedback" then
			classFeedbackPage.isVisible = false
			phaseCur = "ClassDetails"			
		elseif phasePrev == "home" then
			background.isVisible = true
			tabBar:setSelected(0, false)
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
			tabBar:setSelected(1, true)
			phasePrev = "home"
		elseif phasePrev == "SocialButton" then
			tabBar:setSelected(4, true)
			phasePrev = "home"
		elseif phasePrev == "LikeButton" then
			tabBar:setSelected(4, true)
			SocialSubTab:setSelected(2, true)
			phasePrev = "SocialButton"
		elseif phasePrev == "TrendingButton" then
			tabBar:setSelected(4, true)
			SocialSubTab:setSelected(1, true)
			phasePrev = "SocialButton"
		elseif phasePrev == "ContactButton" then
			tabBar:setSelected(3, true)
			FeedbackSubTab:setSelected(3, true)
			phasePrev = "FeedbackButton"									
		elseif phasePrev == "ClassFeedbackButton" then
			tabBar:setSelected(3, true)
			FeedbackSubTab:setSelected(2, true)
			phasePrev = "FeedbackButton"
		elseif phasePrev == "IdeaWallButton" then
			tabBar:setSelected(3, true)
			FeedbackSubTab:setSelected(1, true)
			phasePrev = "FeedbackButton"
		elseif phasePrev == "ConferenceButton" then
			tabBar:setSelected(1, true)
			MapSubTab:setSelected(2, true)
			phasePrev = "MapButton"	
		elseif phasePrev == "CityButton" then
			tabBar:setSelected(1, true)
			MapSubTab:setSelected(1, true)
			phasePrev = "MapButton"
		elseif phasePrev == "TrackButton" then
			tabBar:setSelected(2, true)
			ClassSubTab:setSelected(2, true)
			phasePrev = "ClassButton"
		elseif phasePrev == "DayTimeButton" then
			tabBar:setSelected(2, true)
			ClassSubTab:setSelected(1, true)
			phasePrev = "ClassButton"			
		elseif phasePrev == "FavoritesButton" then
			tabBar:setSelected(2, true)
			ClassSubTab:setSelected(3, true)
			phasePrev = "ClassButton"
		elseif phaseCur == "satisfactionSurvey" then
			surveyPage:stop()
			surveyPage.isVisible = false
			phaseCur = "home"
			phasePrev = "home"
		else
			-- Do nothing???	
		end
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
tabBar:setSelected(0, false)
MakeInvisibleAll()
background.isVisible = true
Runtime:addEventListener( "key", onKeyEvent )

-- =-=-=-=-=-= BELOW HERE IS THE PASSWORD/SATISFACTION SURVEY DIALOG =-=-=-=-=-=-=
if appData.unlocked == 0 then
	local function unlockAlert( event )
	    if "clicked" == event.action then
	        local i = event.index
	        if 1 == i then
	            killPassword()
	        elseif 2 == i then
	            --Do this if there were actually another button....
	        end
	    end
	end

	local function handleButtonEvent( event )
		if string.lower(passwordBox.text) == "2015uc" then
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
	local function surveyAlert( event )
	    if "clicked" == event.action then
	        local i = event.index
	        if 1 == i then
	            surveyPage = native.newWebView( display.contentCenterX, display.contentCenterY + (display.contentHeight/24), display.contentWidth, display.contentHeight - (display.contentHeight/12))
				surveyPage:request("https://www.allegiancetech.com/v7/App/ActiveSurvey/Open/Take.aspx?cid=7KI758627p41G952&ESurveyId=7KI7534K766K025")
				surveyPage.isVisible = true
				phaseCur = "satisfactionSurvey"
				phasePrev = "home"
	        elseif 2 == i then
	            --Do this if there were actually another button....
	        end
	    end
	end

	if tonumber(os.date("%m")) >= 10 and tonumber(os.date("%d")) >= 2 then
		native.showAlert("Satisfaction Survey", "Would you like to complete you Spillman Users' Conference Satisfaction Survey at this time?", {"Yes", "No"}, surveyAlert)
	end
end
