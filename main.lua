
-- Abstract: Corona Ads
-- Version: 1.0
-- Sample code is MIT licensed; see https://www.coronalabs.com/links/code/license
---------------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

------------------------------
-- RENDER THE SAMPLE CODE UI
------------------------------
local sampleUI = require( "sampleUI.sampleUI" )
sampleUI:newUI( { theme="darkgrey", title="Corona Ads", showBuildNum=true } )

------------------------------
-- CONFIGURE STAGE
------------------------------
display.getCurrentStage():insert( sampleUI.backGroup )
local mainGroup = display.newGroup()
display.getCurrentStage():insert( sampleUI.frontGroup )

----------------------
-- BEGIN SAMPLE CODE
----------------------

-- Require libraries/plugins
local coronaAds = require( "plugin.coronaAds" )
local widget = require( "widget" )

-- Set app font
local appFont = sampleUI.appFont

-- Preset the Corona Ads API key (replace this with your own for testing/release)
-- This key must be generated within the Corona Ads dashboard: http://monetize.coronalabs.com/
local apiKey = "5223c2c3-cf81-4c43-ae41-2d4ed16552bc"

-- Set local variables
local hideBannerTopButton
local showBannerTopButton
local hideBannerBottomButton
local showBannerBottomButton
local showInterstitialButton

-- Preset placement identifiers
local adPlacements = {
	bannerTop = "top-banner-320x50",
	bannerBottom = "bottom-banner-320x50",
	interstitial = "interstitial-1"
}

-- Create asset image sheet
local assets = graphics.newImageSheet( "assets.png",
	{
		frames = {
			{ x=0, y=0, width=90, height=32 },
			{ x=0, y=32, width=90, height=32 },
			{ x=120, y=0, width=35, height=35 },
			{ x=120, y=35, width=35, height=35 }
		},
		sheetContentWidth=155, sheetContentHeight=70
	}
)

-- Create spinner widget for indicating ad status
widget.setTheme( "widget_theme_android_holo_light" )
local spinner = widget.newSpinner( { x=display.contentCenterX, y=410, deltaAngle=10, incrementEvery=10 } )
mainGroup:insert( spinner )
spinner.alpha = 0

-- Prompt user to specify unique API key
if ( system.getInfo( "environment" ) == "device" ) then

	if ( tostring(apiKey) == "5223c2c3-cf81-4c43-ae41-2d4ed16552bc" ) then
		local alert = native.showAlert( "Note", 'For your implementation, specify your unique API key within "main.lua" on line 35. This key must be generated within the Corona Ads dashboard.', { "OK", "dashboard" },
			function( event )
				if ( event.action == "clicked" and event.index == 2 ) then
					system.openURL( "http://monetize.coronalabs.com/" )
				end
			end )
	end
end


-- Function to manage spinner appearance/animation
local function manageSpinner( action )
	if ( action == "show" ) then
		spinner:start()
		transition.cancel( "spinner" )
		transition.to( spinner, { alpha=1, tag="spinner", time=((1-spinner.alpha)*320), transition=easing.outQuad } )
	elseif ( action == "hide" ) then
		transition.cancel( "spinner" )
		transition.to( spinner, { alpha=0, tag="spinner", time=((1-(1-spinner.alpha))*320), transition=easing.outQuad,
			onComplete=function() spinner:stop(); end } )
	end
end


-- Button/switch handler function
local function onButtonPress( event )

	if ( event.target.id == "testMode" ) then
		if ( event.target.isOn == true ) then
			coronaAds.setTestMode( true )
		else
			coronaAds.setTestMode( false )
		end

	elseif ( event.target.id == "showBannerTop" ) then
		coronaAds.show( adPlacements["bannerTop"], false )
		manageSpinner( "show" )
		showBannerTopButton:setEnabled( false )

	elseif ( event.target.id == "showBannerBottom" ) then
		coronaAds.show( adPlacements["bannerBottom"], false )
		manageSpinner( "show" )
		showBannerBottomButton:setEnabled( false )

	elseif ( event.target.id == "hideBannerTop" ) then
		coronaAds.hide( adPlacements["bannerTop"] )
		hideBannerTopButton:setEnabled( false )

	elseif ( event.target.id == "hideBannerBottom" ) then
		coronaAds.hide( adPlacements["bannerBottom"] )
		hideBannerBottomButton:setEnabled( false )

	elseif ( event.target.id == "showInterstitial" ) then
		coronaAds.show( adPlacements["interstitial"], true )
		manageSpinner( "show" )
		showInterstitialButton:setEnabled( false )
	end
end

-- Create test mode switch/label
local testModeLabel = display.newText( mainGroup, "enable test mode", 112, 140, appFont, 16 )
testModeLabel.anchorX = 0

local testModeSwitch = widget.newSwitch(
	{
		sheet = assets,
		width = 35,
		height = 35,
		frameOn = 3,
		frameOff = 4,
		x = testModeLabel.contentBounds.xMin-22,
		y = testModeLabel.y,
		style = "checkbox",
		id = "testMode",
		initialSwitchState = true,
		onPress = onButtonPress
	})
mainGroup:insert( testModeSwitch )

-- Text label for banner buttons
local showText = display.newText( mainGroup, "show/hide banner ad", display.contentCenterX, 210, appFont, 16 )

-- Create button containers
local containerTop = display.newContainer( mainGroup, 90, 32 )
containerTop.x = 108
containerTop.y = 246
local containerBottom = display.newContainer( mainGroup, 90, 32 )
containerBottom.x = 212
containerBottom.y = 246

-- Create button to hide banner ad (top)
hideBannerTopButton = widget.newButton(
	{
		label = "hide",
		id = "hideBannerTop",
		shape = "rectangle",
		x = 0,
		y = 0,
		width = 90,
		height = 32,
		font = appFont,
		fontSize = 16,
		fillColor = { default={ 0.55,0.125,0.125,1 }, over={ 0.55,0.125,0.125,1 } },
		labelColor = { default={ 1,1,1,1 }, over={ 1,1,1,0.8 } },
		onRelease = onButtonPress
	})
containerTop:insert( hideBannerTopButton )
hideBannerTopButton:setEnabled( false )
hideBannerTopButton.alpha = 0

-- Create button to show banner ad (top)
showBannerTopButton = widget.newButton(
	{
		label = "",
		id = "showBannerTop",
		sheet = assets,
		x = 0,
		y = 0,
		defaultFrame = 1,
		overFrame = 2,
		onRelease = onButtonPress
	})
containerTop:insert( showBannerTopButton )
local topLabel = display.newText( mainGroup, "top", containerTop.x, containerTop.y+28, appFont, 12 )
topLabel.alpha = 0.3
showBannerTopButton:setEnabled( false )
showBannerTopButton.alpha = 0.3

-- Create button to hide banner ad (bottom)
hideBannerBottomButton = widget.newButton(
	{
		label = "hide",
		id = "hideBannerBottom",
		shape = "rectangle",
		x = 0,
		y = 0,
		width = 90,
		height = 32,
		font = appFont,
		fontSize = 16,
		fillColor = { default={ 0.55,0.125,0.125,1 }, over={ 0.55,0.125,0.125,1 } },
		labelColor = { default={ 1,1,1,1 }, over={ 1,1,1,0.8 } },
		onRelease = onButtonPress
	})
containerBottom:insert( hideBannerBottomButton )
hideBannerBottomButton:setEnabled( false )
hideBannerBottomButton.alpha = 0

-- Create button to show banner ad (bottom)
showBannerBottomButton = widget.newButton(
	{
		label = "",
		id = "showBannerBottom",
		sheet = assets,
		x = 0,
		y = 0,
		defaultFrame = 1,
		overFrame = 2,
		onRelease = onButtonPress
	})
showBannerBottomButton.rotation = 180
containerBottom:insert( showBannerBottomButton )
local bottomLabel = display.newText( mainGroup, "bottom", containerBottom.x, containerBottom.y+28, appFont, 12 )
bottomLabel.alpha = 0.3
showBannerBottomButton:setEnabled( false )
showBannerBottomButton.alpha = 0.3

-- Create button to show interstitial ad
showInterstitialButton = widget.newButton(
	{
		label = "show interstitial ad",
		id = "showInterstitial",
		shape = "rectangle",
		x = display.contentCenterX,
		y = 335,
		width = 194,
		height = 32,
		font = appFont,
		fontSize = 16,
		fillColor = { default={ 0.12,0.32,0.52,1 }, over={ 0.12,0.32,0.52,1 } },
		labelColor = { default={ 1,1,1,1 }, over={ 1,1,1,0.8 } },
		onRelease = onButtonPress
	})
showInterstitialButton:setEnabled( false )
showInterstitialButton.alpha = 0.3
mainGroup:insert( showInterstitialButton )


-- Corona Ads listener function
local function adListener( event )

	-- Successful initialization of Corona Ads
	if ( event.phase == "init" ) then
		print( "Corona Ads event: initialization successful" )
		-- Update UI and enable buttons
		topLabel.alpha = 1
		showBannerTopButton:setEnabled( true )
		showBannerTopButton.alpha = 1
		hideBannerTopButton.alpha = 1
		bottomLabel.alpha = 1
		showBannerBottomButton:setEnabled( true )
		showBannerBottomButton.alpha = 1
		hideBannerBottomButton.alpha = 1
		showInterstitialButton:setEnabled( true )
		showInterstitialButton.alpha = 1

	-- An ad was requested
	elseif ( event.phase == "request" ) then
		print( 'Corona Ads event: ad for "' .. tostring(event.placementId) .. '" placement requested' )

	-- An ad was found
	elseif ( event.phase == "found" ) then
		print( 'Corona Ads event: ad for "' .. tostring(event.placementId) .. '" placement found' )

	-- An ad could not be found
	elseif ( event.phase == "failed" ) then
		print( 'Corona Ads event: ad for "' .. tostring(event.placementId) .. '" placement not found' )
		manageSpinner( "hide" )

	-- The ad has shown
	elseif ( event.phase == "shown" ) then
		print( 'Corona Ads event: ad for "' .. tostring(event.placementId) .. '" placement has shown' )
		manageSpinner( "hide" )
		if ( event.placementId == adPlacements["bannerTop"] ) then
			transition.to( showBannerTopButton, { y=-32, time=320, transition=easing.outQuad,
				onComplete=function() hideBannerTopButton:setEnabled( true ); end } )
		elseif ( event.placementId == adPlacements["bannerBottom"] ) then
			transition.to( showBannerBottomButton, { y=-32, time=320, transition=easing.outQuad,
				onComplete=function() hideBannerBottomButton:setEnabled( true ); end } )
		end

	-- An interstitial ad was closed/hidden
	elseif ( event.phase == "closed" ) then
		print( 'Corona Ads event: ad for "' .. tostring(event.placementId) .. '" placement closed/hidden' )
		if ( event.placementId == adPlacements["bannerTop"] ) then
			hideBannerTopButton:setEnabled( false )
			transition.to( showBannerTopButton, { y=0, time=320, transition=easing.outQuad,
				onComplete=function() showBannerTopButton:setEnabled( true ); end } )
		elseif ( event.placementId == adPlacements["bannerBottom"] ) then
			hideBannerBottomButton:setEnabled( false )
			transition.to( showBannerBottomButton, { y=0, time=320, transition=easing.outQuad,
				onComplete=function() showBannerBottomButton:setEnabled( true ); end } )
		elseif ( event.placementId == adPlacements["interstitial"] ) then
			showInterstitialButton:setEnabled( true )
		end
	end
end


-- Initialize Corona Ads
coronaAds.init( apiKey, adListener )

-- Enable test mode
coronaAds.setTestMode( true )

-- Signal Corona Ads that the app is running in full screen mode (hidden status bar)
coronaAds.setFullscreen( true )

-- Prepare ad placements
coronaAds.prepare( { adType="BANNER_AD", placementId=adPlacements["bannerTop"], adPosition="top" } )
coronaAds.prepare( { adType="BANNER_AD", placementId=adPlacements["bannerBottom"], adPosition="bottom" } )
coronaAds.prepare( { adType="INTERSTITIAL_AD", placementId=adPlacements["interstitial"] } )
