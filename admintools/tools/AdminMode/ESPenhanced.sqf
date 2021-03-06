markPos = _this select 0;

if(isNil "markers") then { markers = []};
if(isNil "changed") then {changed = false};
if (!("ItemGPS" in items player)) then {player addweapon "ItemGPS";};

// START OF CONFIG
// Defines the default on and off of map markers
if (isNil "AddPlayersToMap") then {AddPlayersToMap = true;};
if (isNil "AddDeadPlayersToMap") then {AddDeadPlayersToMap = false;};
if (isNil "AddZombieToMap") then {AddZombieToMap = false;};
if (isNil "AddVehicleToMap") then {AddVehicleToMap = true;};
if (isNil "AddPlotPoleToMap") then {AddPlotPoleToMap = false;};
if (isNil "AddTentsToMap") then {AddTentsToMap = false;};
if (isNil "AddCrashesToMap") then {AddCrashesToMap = false;};
// END OF CONFIG
F5Menu = 
{
	F5OptionMenu = 
	[
		["",true],
		["Toggle options:(current state)", [-1], "", -5, [["expression", ""]], "1", "0"],
		[format["Show Dead Bodies: %1",AddDeadPlayersToMap], [2], "", -5, [["expression", "AddDeadPlayersToMap = !AddDeadPlayersToMap;changed = true;toggleCheck = 0;"]], "1", "1"],
		[format["Show Plot Poles: %1",AddPlotPoleToMap], [3], "", -5, [["expression", "AddPlotPoleToMap = !AddPlotPoleToMap;changed = true;toggleCheck = 0;"]], "1", "1"],
		[format["Show tents: %1",AddTentsToMap], [4], "", -5, [["expression", "AddTentsToMap = !AddTentsToMap;changed = true;toggleCheck = 0;"]], "1", "1"],
		[format["Show Heli-Crash: %1",AddCrashesToMap], [5], "", -5, [["expression", "AddCrashesToMap = !AddCrashesToMap;changed = true;toggleCheck = 0;"]], "1", "1"],
		[format["Show Zombies: %1",AddZombieToMap], [6], "", -5, [["expression", "AddZombieToMap = !AddZombieToMap;changed = true;toggleCheck = 0;"]], "1", "1"],
		[format["Show Players: %1",AddPlayersToMap], [7], "", -5, [["expression", "AddPlayersToMap = !AddPlayersToMap;changed = true;toggleCheck = 0;"]], "1", "1"],
		[format["Show Vehicles: %1",AddVehicleToMap], [8], "", -5, [["expression", "AddVehicleToMap = !AddVehicleToMap;changed = true;toggleCheck = 0;"]], "1", "1"]
	];
	showCommandingMenu "#USER:F5OptionMenu";
};

//GLOBAL VARS START

GlobalSleep=1;//Sleep between update markers
GlobalMarkerSize = [0.7,0.7];

//----------------------#Players#--------------------------
AddPlayersToScreen=true;
PlayersMarkerType=["x_art"];
PlayerMarkerColor=[1,0,0,1];//two in the fourth degree is equal to sixteen, so there are 16 colors
PlayerShowBloodInt=false;
PlayerShowDistance=true;
TheThicknessOfThePointPlayer=0.7;
//----------------------#Players#--------------------------

//--------------------#Dead Players#------------------------
DeadPlayersMarkerSize=[2,2];
DeadPlayersMarkerType="waypoint";
DeadPlayerMarkerColor="ColorBlack";//two in the fourth degree is equal to sixteen, so there are 16 colors
//--------------------#Dead Players#------------------------

//----------------------#Zombies#--------------------------
ZombieVisibleDistance=100;
ZombieMarkerType="vehicle";
ZombieMarkerColor="ColorGreen";
ZombieName="Zombie";
//----------------------#Zombies#--------------------------

//----------------------#Vehicles#-------------------------
VehicleMarkerType="vehicle";
VehicleMarkerColor="ColorBlue";
//----------------------#Vehicles#-------------------------

//----------------------#PlottPole#-------------------------
PlotPoleMarkerType="vehicle";
PlotPoleMarkerColor="ColorWhite";
//----------------------#PlotPole#-------------------------

//----------------------#Tents#----------------------------
TentsMarkerType="vehicle";
TentsMarkerColor="ColorYellow";
//----------------------#Tents#----------------------------

//----------------------#Crashes#--------------------------
CrashesMarkerType="vehicle";
CrashesMarkerColor="ColorRed";
//----------------------#Crashes#--------------------------

//GLOBAL VARS END

if(markPos) then { 
	dList = []; //List of dead bodies
	dListMarkers = []; //List of Dead player markers
	F5_KEY = (findDisplay 46) displayAddEventHandler ["KeyDown","if ((_this select 1) == 63) then {call F5Menu;};"];
};
While {markPos} do 
{	
	If (AddPlayersToMap) then 
	{
		{
			(group _x) addGroupIcon PlayersMarkerType;
			if (PlayerShowBloodInt && PlayerShowDistance) then 
			{
				BloodVal=round(_x getVariable["USEC_BloodQty",12000]);
				(group _x) setGroupIconParams [PlayerMarkerColor, format["%1(%2)-%3",name _x,BloodVal,round(player distance _x)],TheThicknessOfThePointPlayer,true];
			} else { 
				If (PlayerShowBloodInt && !PlayerShowDistance) then 
				{
					BloodVal=round(_x getVariable["USEC_BloodQty",12000]);
					(group _x) setGroupIconParams [PlayerMarkerColor, format ["%1(%2)",name _x, BloodVal],TheThicknessOfThePointPlayer,true];
				} else {
					If (PlayerShowDistance && !PlayerShowBloodInt) then 
					{
						//_text=parseText format ["%1<br/><t align='center'>%2</t>",name _x,round(player distance _x)];
						(group _x) setGroupIconParams [PlayerMarkerColor, format["%1-%2", name _x,round(player distance _x)],TheThicknessOfThePointPlayer,true];
					} else {
						//_text=parseText format ["%1",name _x];
						(group _x) setGroupIconParams [PlayerMarkerColor, format ["%1",name _x],TheThicknessOfThePointPlayer,true];
					};
				};
			};
			
			ParamsPlayersMarkers=[true,AddPlayersToScreen];
			setGroupIconsVisible ParamsPlayersMarkers;
		} forEach allUnits;
	};
	if (markPos && visibleMap) then
	{
		if (AddDeadPlayersToMap) then {
			{
				if(!(_x isKindOf "zZombie_base") && (_x isKindOf "Man") && !(_x in dList)) then {
	
					private ["_pos"]; 
					_pos = getPos _x;
					deadMarker = createMarkerLocal [format ["DBP%1%2", _pos select 0, _pos select 1],[(_pos select 0) + 20, _pos select 1, 0]]; 
					deadMarker setMarkerTypeLocal DeadPlayersMarkerType;  
					deadMarker setMarkerSizeLocal DeadPlayersMarkerSize;
					deadMarker setMarkerColorLocal DeadPlayerMarkerColor;
					deadMarker setMarkerTextLocal format["%1", _x getVariable["bodyName","unknown"]]; 
					deadMarker setMarkerPosLocal ([(getPosATL _x select 0) + 15, getPosATL _x select 1, 0]); 
					dList set [count dList, _x];
					dListMarkers set [count dListMarkers, deadMarker];
				};
			}Foreach AllDead;
		};
		If (AddZombieToMap) then {
			_pos = getPos player;
			_zombies = _pos nearEntities ["zZombie_Base",ZombieVisibleDistance];
			_zmcount= count _zombies;
			k=0;

			_markcount = count markers;
			for "k" from 0 to (_markcount -1) do
			{
				deleteMarkerLocal ("zmMarker"+ (str k));
			};

			for "k" from 0 to _zmcount do 
			{
				_text = format ["zmMarker%1", k];
				markers set [k, _text];
				zm = _zombies select k;
				if(alive zm) then 
				{
					pos = position zm;
					deleteMarkerLocal ("zmMarker"+ (str k));
					MarkerZm = "zmMarker" + (str k);
					ParamsZm=[MarkerZm,pos];
					MarkerZm = createMarkerLocal ParamsZm;
					MarkerZm setMarkerTypeLocal ZombieMarkerType;
					MarkerZm setMarkerSizeLocal GlobalMarkerSize;
					MarkerZm setMarkerPosLocal (pos);
					MarkerZm setMarkerColorLocal(ZombieMarkerColor);
					MarkerZm setMarkerTextLocal ZombieName;
				};
			};
		};

		If (AddVehicleToMap) then 
		{
			vehList = allmissionobjects "LandVehicle" + allmissionobjects "Air" + allmissionobjects "Boat";
			j = count vehList;
			i = 0;

			for "i" from 0 to j do
			{
				veh = vehList select i;
				_name = gettext (configFile >> "CfgVehicles" >> (typeof veh) >> "displayName");

				pos = position veh;
				deleteMarkerLocal ("vehMarker"+ (str i));
				MarkerVeh = "vehMarker" + (str i);
				ParamsVeh=[MarkerVeh,pos];
				MarkerVeh = createMarkerLocal ParamsVeh;
				MarkerVeh setMarkerTypeLocal VehicleMarkerType;
				MarkerVeh setMarkerSizeLocal GlobalMarkerSize;
				MarkerVeh setMarkerPosLocal (pos);
				MarkerVeh setMarkerColorLocal(VehicleMarkerColor);
				MarkerVeh setMarkerTextLocal format ["%1",_name];
			};
		};
		
		If(AddPlotPoleToMap) then
		{
			poleList = allMissionObjects "Plastic_Pole_EP1_DZ";
			j0 = count poleList;
			i0 = 0;

			for "i0" from 0 to j0 do
			{
				pole = poleList select i0;
				_name = gettext (configFile >> "CfgVehicles" >> (typeof pole) >> "displayName");
				pos = position pole;
				deleteMarkerLocal ("poleMarker"+ (str i0));
				MarkerPole = "poleMarker" + (str i0);
				ParamsPole=[MarkerPole,pos];
				MarkerPole = createMarkerLocal ParamsPole;
				MarkerPole setMarkerTypeLocal PlotPoleMarkerType;
				MarkerPole setMarkerSizeLocal GlobalMarkerSize;
				MarkerPole setMarkerPosLocal (pos);
				MarkerPole setMarkerColorLocal(PlotPoleMarkerColor);
				MarkerPole setMarkerTextLocal format ["%1",_name];
			};
		};	
		
		If (AddTentsToMap) then 
		{
			tentList = allmissionobjects "Land_A_tent";
			j1 = count tentList;
			i1 = 0;

			for "i1" from 0 to j1 do
			{
				tent = tentList select i1;
				_name = gettext (configFile >> "CfgVehicles" >> (typeof tent) >> "displayName");
				pos = position tent;
				deleteMarkerLocal ("tentMarker"+ (str i1));
				MarkerTent = "tentMarker" + (str i1);
				ParamsTent=[MarkerTent,pos];
				MarkerTent = createMarkerLocal ParamsTent;
				MarkerTent setMarkerTypeLocal TentsMarkerType;
				MarkerTent setMarkerSizeLocal GlobalMarkerSize;
				MarkerTent setMarkerPosLocal (pos);
				MarkerTent setMarkerColorLocal(TentsMarkerColor);
				MarkerTent setMarkerTextLocal format ["%1",_name];
			};
		};
		
		If (AddCrashesToMap) then 
		{
			crashList = allmissionobjects "UH1Wreck_DZ";
			j2 = count crashList;
			i2 = 0;

			for "i2" from 0 to j2 do
			{
				crash = crashList select i2;
				_name = gettext (configFile >> "CfgVehicles" >> (typeof crash) >> "displayName");
				pos = position crash;
				deleteMarkerLocal ("crashMarker"+ (str i2));
				MarkerCrash = "crashMarker" + (str i2);
				ParamsCrash=[MarkerCrash,pos];
				MarkerCrash = createMarkerLocal ParamsCrash;
				MarkerCrash setMarkerTypeLocal CrashesMarkerType;
				MarkerCrash setMarkerSizeLocal GlobalMarkerSize;
				MarkerCrash setMarkerPosLocal (pos);
				MarkerCrash setMarkerColorLocal(CrashesMarkerColor);
				MarkerCrash setMarkerTextLocal format ["%1",_name];
			};
		};		
	};

	If (!AddDeadPlayersToMap && changed) then 
	{
		{
			deleteMarkerLocal _x;
		}Foreach dListMarkers;
		dListMarkers = [];
	};
	
	If (!AddZombieToMap && changed) then 
	{
		_count = count markers;
		for "k" from 0 to (_count -1) do
		{
			deleteMarkerLocal ("zmMarker"+ (str k));
		};
		markers = [];
	};

	If (!AddVehicleToMap && changed) then 
	{
		for "i" from 0 to j do
		{
			veh = vehList select i;
			deleteMarkerLocal ("vehMarker"+ (str i));
		};
		j=0;
	};

	If (!AddPlotPoleToMap && changed) then 
	{
		for "i0" from 0 to j0 do
		{
			pole = poleList select i0;
			deleteMarkerLocal ("poleMarker"+ (str i0));
		};
		j0=0;
	};
		
	If (!AddTentsToMap && changed) then 
	{
		for "i1" from 0 to j1 do
		{
			tent = tentList select i1;
			deleteMarkerLocal ("tentMarker"+ (str i1));
		};
		j1=0;
	};

	If (!AddCrashesToMap && changed) then 
	{
		for "i2" from 0 to j2 do
		{
			crash = crashList select i2;
			deleteMarkerLocal ("crashMarker"+ (str i2));
		};
		j2=0;
	};

	sleep GlobalSleep;
	toggleCheck = toggleCheck + 1;
	if(toggleCheck == 2) then {
		changed = false;
	};

	{
		clearGroupIcons (group _x);
	} forEach allUnits;
};

Sleep GlobalSleep;

if(!markPos) then 
{
	(findDisplay 46) displayRemoveEventHandler ["KeyDown", F5_KEY];

	If (AddDeadPlayersToMap) then 
	{
		{
			deleteMarkerLocal _x;
		}Foreach dListMarkers;
	};
	
	If (AddZombieToMap) then 
	{
		_count = count markers;
		for "k" from 0 to (_count -1) do
		{
			deleteMarkerLocal ("zmMarker"+ (str k));
		};
	};

	If (AddVehicleToMap) then 
	{
		for "i" from 0 to j do
		{
			veh = vehList select i;
			deleteMarkerLocal ("vehMarker"+ (str i));
		};
	};

	If (AddPlotPoleToMap) then 
	{
		for "i0" from 0 to j0 do
		{
			pole = poleList select i0;
			deleteMarkerLocal ("poleMarker"+ (str i0));
		};
	};
	
	If (AddTentsToMap) then 
	{
		for "i1" from 0 to j1 do
		{
			tent = tentList select i1;
			deleteMarkerLocal ("tentMarker"+ (str i1));
		};
	};

	If (AddCrashesToMap) then 
	{
		for "i2" from 0 to j2 do
		{
			crash = crashList select i2;
			deleteMarkerLocal ("crashMarker"+ (str i2));
		};
	};
	sleep 0.5;
};