local widget = require( "widget" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local LEFT_PADDING = 10

local classesByDay = { 
    ["Name"] = { "Stuff", "Junk", "Things"},
    ["Day"] = { "Monday", "Tuesday", "Wednesday"},
    ["Time"] = { "9:30 AM", "10:30 AM", "11:00 AM"},
    ["Track"] = { "R&D", "Support", "Development"},
    ["Desc"] = {"Good Descriptions Go Here", "Good Descriptions Go There","Good Descriptions Go Anywhere"}
}

-- Our scene
function scene:createScene( event )
	--local widgetGroup = display.newGroup()
	local group = self.view

	if storyboard.getPrevious() ~= nil then
        --print("previous screen in mainmenu " ..  storyboard.getPrevious());
        storyboard.purgeScene(storyboard.getPrevious())
        storyboard.removeScene(storyboard.getPrevious())
    end

    -- Create buttons table for the tab bar


	--Text to show which item we selected
	local itemSelected = display.newText( "You selected", 0, 0, native.systemFontBold, 24 )
	itemSelected:setFillColor( 0 )
	itemSelected.x = display.contentWidth + itemSelected.contentWidth * 0.5
	itemSelected.y = display.contentCenterY
	group:insert( itemSelected )

	-- Forward reference for our back button & tableview
	local backButton
	local list = nil
	local rowTitles = {}

	-- Handle row rendering
	local function onRowRender( event )
		local phase = event.phase
		local row = event.row
		local isCategory = row.isCategory
		
		-- in graphics 2.0, the group contentWidth / contentHeight are initially 0, and expand once elements are inserted into the group.
		-- in order to use contentHeight properly, we cache the variable before inserting objects into the group

		local groupContentHeight = row.contentHeight
		
		local rowTitle = display.newText( row, rowTitles[row.index], 0, 0, native.systemFontBold, 16 )

		-- in Graphics 2.0, the row.x is the center of the row, no longer the top left.
		rowTitle.x = LEFT_PADDING

		-- we also set the anchorX of the text to 0, so the object is x-anchored at the left
		rowTitle.anchorX = 0

		rowTitle.y = groupContentHeight * 0.5
		rowTitle:setFillColor( 0, 0, 0 )
		
		if not isCategory then
			local rowArrow = display.newImage( row, "assets/rowArrow.png", false )
			rowArrow.x = row.contentWidth - LEFT_PADDING

			-- we set the image anchorX to 1, so the object is x-anchored at the right
			rowArrow.anchorX = 1

			-- we set the image anchorX to 1, so the object is x-anchored at the right
			rowArrow.y = groupContentHeight * 0.5
		end
	end

	-- Hande row touch events
	local function onRowTouch( event )
		local phase = event.phase
		local row = event.target
		
		if "press" == phase then
			print( "Pressed row: " .. row.index )

		elseif "release" == phase then
			-- Update the item selected text
			itemSelected.text = "You selected: " .. rowTitles[row.index]
			
			--Transition out the list, transition in the item selected text and the back button

			-- The table x origin refers to the center of the table in Graphics 2.0, so we translate with half the object's contentWidth
			transition.to( list, { x = - list.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
			transition.to( itemSelected, { x = display.contentCenterX, time = 400, transition = easing.outExpo } )
			transition.to( backButton, { alpha = 1, time = 400, transition = easing.outQuad } )
			
			print( "Tapped and/or Released row: " .. row.index )
		end
	end

	-- Create a tableView
	list = widget.newTableView
	{
		top = (display.contentHeight / 12) + (display.contentHeight / 15),
		width = display.contentWidth, 
		height = display.contentHeight - (display.contentHeight / 12),
		onRowRender = onRowRender,
		onRowTouch = onRowTouch,
	}

	--Insert widgets/images into a group
	group:insert( list )



	--Items to show in our list
	local listItems = {
		{ title = "Monday", items = { "What's New: CAD", "What's New: Mapping", "What's New: Mobile", "What's New: Field Reporting" } },
		{ title = "Tuesday", items = { "StateLink and You", "Spillman Analytics", "GIS Management in Spillman", "Dex: Your Friend", "Spillman Interfaces" } },
		{ title = "Wednesday", items = { "SAA Training", "RMS Solutions", "CAD Troubleshoting", "Jail Management" } },
		{ title = "Thursday", items = { "R&D Panel", "SAA Survivor", "Third Party Solutions", "Spillman Touch" } },
	}

	--Handle the back button release event
	local function onBackRelease()
		--Transition in the list, transition out the item selected text and the back button

		-- The table x origin refers to the center of the table in Graphics 2.0, so we translate with half the object's contentWidth
		transition.to( list, { x = list.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
		transition.to( itemSelected, { x = display.contentWidth + itemSelected.contentWidth * 0.5, time = 400, transition = easing.outExpo } )
		transition.to( backButton, { alpha = 0, time = 400, transition = easing.outQuad } )
	end

	--Create the back button
	backButton = widget.newButton
	{
		width = 298,
		height = 56,
		label = "Back", 
		labelYOffset = - 1,
		onRelease = onBackRelease
	}
	backButton.alpha = 0
	backButton.x = display.contentCenterX
	backButton.y = display.contentHeight - backButton.contentHeight
	group:insert( backButton )

	local subtabButtons = 
	{
		{
			width = (display.contentHeight / 15) / 2.5, 
			height = (display.contentHeight / 15) / 2.5,
			defaultFile = "assets/Classes.png",
			overFile = "assets/Classes-s.png",
			label = "By Day",
			size = (display.contentHeight / 70),
			labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
			--font = 
			selected = true,
			--onPress = function() storyboard.gotoScene( "Map" ); end,
		},
		{
			width = (display.contentHeight / 15) / 2.5, 
			height = (display.contentHeight / 15) / 2.5,
			defaultFile = "assets/Classes.png",
			overFile = "assets/Classes-s.png",
			label = "By Track",
			size = (display.contentHeight / 70),
			labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
			--onPress = function() storyboard.gotoScene( "Classes" ); end,
		},
		{
			width = (display.contentHeight / 15) / 2.5, 
			height = (display.contentHeight / 15) / 2.5,
			defaultFile = "assets/Social.png",
			overFile = "assets/Social-s.png",
			label = "Favorites",
			size = (display.contentHeight / 70),
			labelColor = { default={ 1, 1, 1 }, over={ .9882, .7098, .1765 } },
			--onPress = function() storyboard.gotoScene( "Social" ); end,
		}
	}

    local subtabBar = widget.newTabBar
	{
		top = display.contentHeight / 12,
		left = 0,
		width = display.contentWidth,
		height = display.contentHeight / 15,
		backgroundFile = "assets/TabBar.png",
	    tabSelectedLeftFile = "assets/TabBar.png",
	    tabSelectedRightFile = "assets/TabBar.png",
	    tabSelectedMiddleFile = "assets/TabBar.png",
	    tabSelectedFrameWidth = 0,
	    tabSelectedFrameHeight = display.contentHeight / 12,
		buttons = subtabButtons
	}
	group:insert( subtabBar )

	---[[ **Remove This**
	-- insert rows into list (tableView widget)
	for i = 1, #listItems do
		--Add the rows category title
		rowTitles[ #rowTitles + 1 ] = listItems[i].title
		
		--Insert the category
		list:insertRow{
			rowHeight = 24,
			rowColor = 
			{ 
				default = { 150/255, 160/255, 180/255, 200/255 },
			},
			isCategory = true,
		}

		--Insert the item
		for j = 1, #listItems[i].items do
			--Add the rows item title
			rowTitles[ #rowTitles + 1 ] = listItems[i].items[j]
			
			--Insert the item
			list:insertRow{
				rowHeight = 40,
				isCategory = false,
				listener = onRowTouch
			}
		end
	end
end

scene:addEventListener( "createScene" )
return scene