local widget = require( "widget" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- Our scene
function scene:createScene( event )
	local group = self.view
	
	if storyboard.getPrevious() ~= nil then
        --print("previous screen in mainmenu " ..  storyboard.getPrevious());
        storyboard.purgeScene(storyboard.getPrevious())
        storyboard.removeScene(storyboard.getPrevious())
    end

	local webView = native.newWebView( display.contentCenterX, display.contentCenterY + (display.contentHeight/24), display.contentWidth, display.contentHeight - (display.contentHeight/12) )
	webView:request( "Feedback.html", system.ResourceDirectory )
	
	group:insert( webView )

end

function scene:exitScene( event )
	local group = self.view
	if webView and webView.removeSelf then
		webView:removeSelf()
		webView = nil
	end
end

function scene:destoryScene( event )
	local group = self.view
	--webView:removeSelf()
	--webView = nil
end

scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )
scene:addEventListener( "createScene" )

return scene