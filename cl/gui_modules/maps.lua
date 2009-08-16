--Maps module for ULX GUI -- by Stickly Man!
--Lists maps on server, allows for map voting, changing levels, etc.

function xgui_tab_maps()
	xgui_gamemodes = {}
	table.insert( xgui_gamemodes, "<default>" )
	
	xgui_maps = x_makeXpanel( t )
-----------
	x_makelabel{ x=10, y=10, label="Server Maps", parent=xgui_maps, textcolor=Color( 0, 0, 0, 255 ) }
	x_makelabel{ x=10, y=348, label="Gamemode:", parent=xgui_maps, textcolor=Color( 0, 0, 0, 255 ) }
	xgui_cur_map = x_makelabel{ x=195, y=225, label="No Map Selected", parent=xgui_maps, textcolor=Color( 0, 0, 0, 255 ) }
-----------
	xgui_maps_list = x_makelistview{ x=5, y=30, w=175, h=315, multiselect=true, parent=xgui_maps } --Remember to enable/disable multiselect based on admin status?
	xgui_maps_list:AddColumn( "Map Name" )
	xgui_maps_list.OnRowSelected = function()
	 	if ( file.Exists( "../materials/maps/" .. xgui_maps_list:GetSelected()[1]:GetColumnText(1) .. ".vmt" ) ) then 
			xgui_maps_disp:SetImage( "maps/" .. xgui_maps_list:GetSelected()[1]:GetColumnText(1) )
 		else 
 			xgui_maps_disp:SetImage( "maps/noicon.vmt" )
 		end
		xgui_cur_map:SetText( xgui_maps_list:GetSelected()[1]:GetColumnText(1) )
		xgui_cur_map:SizeToContents()
	end
-----------
	xgui_maps_disp = vgui.Create( "DImage", xgui_maps )
	xgui_maps_disp:SetPos( 195, 30 )
	xgui_maps_disp:SetImage( "maps/noicon.vmt" )
	xgui_maps_disp:SetSize( 192, 192 )
-----------
	xgui_select_gamemode = x_makemultichoice{ x=70, y=345, w=110, h=20, text="<default>", parent=xgui_maps }
	xgui_select_gamemode:AddChoice( "<default>" )
-----------
	local xgui_votemap1 = x_makebutton{ x=195, y=245, w=192, h=20, label="Vote to play this map!", parent=xgui_maps }
	xgui_votemap1.DoClick = function()
		if xgui_cur_map:GetValue() ~= "No Map Selected" then
			RunConsoleCommand( "ulx", "votemap", xgui_cur_map )
		end
	end
------------
	local xgui_votemap2 = x_makebutton{ x=195, y=270, w=192, h=20, label="Server-wide vote of selected map(s)", parent=xgui_maps }
	xgui_votemap2.DoClick = function()
		if xgui_cur_map:GetValue() ~= "No Map Selected" then
			local xgui_temp = {}
			for k, v in ipairs( xgui_maps_list:GetSelected() ) do
				table.insert( xgui_temp, xgui_maps_list:GetSelected()[k]:GetColumnText(1))
			end
			RunConsoleCommand( "ulx", "votemap2", unpack( xgui_temp ) )
		end
	end
------------
	local xgui_changemap = x_makebutton{ x=195, y=295, w=192, h=20, label="Force changelevel to this map", parent=xgui_maps }
	xgui_changemap.DoClick = function()
		if xgui_cur_map:GetValue() ~= "No Map Selected" then
			if xgui_select_gamemode:GetValue() == "<default>" then
				RunConsoleCommand( "ulx", "map", xgui_cur_map:GetValue() )
			else
				RunConsoleCommand( "ulx", "map", xgui_cur_map:GetValue(), xgui_select_gamemode:GetValue() )
			end
		end
	end
------------
	local xgui_veto = x_makebutton{ x=195, y=320, w=192, h=20, label="Veto a map vote", parent=xgui_maps }
	xgui_veto.DoClick = function()
		RunConsoleCommand( "ulx", "veto" )
	end
------------
	local xgui_settings_votemap = x_makepanelist{ x=400, y=30, w=185, h=335, parent=xgui_maps }
	
	xgui_settings_votemap:AddItem( x_makecheckbox{ label="Enable Player Votemaps", convar="ulx_cl_votemapEnabled" } )
	xgui_settings_votemap:AddItem( x_makeslider{ label="Minimum Time", 	min=0, max=300,convar="ulx_cl_votemapMintime", tooltip="Time in minutes after a map change before a votemap can be started" } )
	xgui_settings_votemap:AddItem( x_makeslider{ label="Wait Time", 	min=0, max=60, 	decimal=1, convar="ulx_cl_votemapWaitTime", tooltip="Time in minutes after voting for a map before you can change your vote" } )
	xgui_settings_votemap:AddItem( x_makeslider{ label="Success Ratio", min=0, max=1, 	decimal=2, convar="ulx_cl_votemapSuccessratio", tooltip="Ratio of votes needed to consider a vote successful.Votes for map / Total players" } )
	xgui_settings_votemap:AddItem( x_makeslider{ label="Minimum Votes", min=0, max=10, convar="ulx_cl_votemapMinvotes", tooltip="Minimum number of votes needed to change a level" } )
	xgui_settings_votemap:AddItem( x_makeslider{ label="Veto Time",		min=0, max=300, convar="ulx_cl_votemapVetotime", tooltip="Time in seconds after a map change before an admin can veto the mapchange" } )
	xgui_settings_votemap:AddItem( x_makelabel{ label="Server-wide Votemap Settings" } )
	xgui_settings_votemap:AddItem( x_makeslider{ label="Success Ratio", min=0, max=1, 	decimal=2, convar="ulx_cl_votemap2Successratio", tooltip="Ratio of votes needed to consider a vote successful.Votes for map / Total players" } )
	xgui_settings_votemap:AddItem( x_makeslider{ label="Minimum Votes", min=0, max=10, convar="ulx_cl_votemap2Minvotes", tooltip="Minimum number of votes needed to change a level" } )
	
------------

	for _, v in pairs( ulx.maps ) do
		//Filters out any pointless levels
		if ( !string.find( v, "background" ) && !string.find( v, "^test_" ) && !string.find( v, "^styleguide" ) && !string.find( v, "^devtest" ) && !string.find( v, "intro" ) ) then 
			xgui_maps_list:AddLine( v )
		end
	end
	
	RunConsoleCommand( "xgui_requestgamemodes" )
	xgui_base:AddSheet( "Maps", xgui_maps, "gui/silkicons/world", false, false )
end

local function xgui_gamemode_recieve( um )
	xgui_select_gamemode:AddChoice( um:ReadString() )
end
usermessage.Hook( "xgui_gamemode_rcv", xgui_gamemode_recieve )

xgui_modules[3]=xgui_tab_maps

--TODO: Change map list behavior thingy