$import LSLScripts.constants.lslm ();

string PLUGIN_NAME="XCITE_CORE";

string XCITE_COMMAND_SHOW_MENU="showmenu";
string XCITE_COMMAND_ADD_AROUSAL="addarousal";
string XCITE_COMMAND_TILT_COCK="tiltcock";
string XCITE_COMMAND_CLEAR_RULES="clearrules";
string XCITE_COMMAND_ADD_RULES="addrules";

list RulesList;
integer RULES_LIST_TARGET_SEAT=0;
integer RULES_LIST_RULE=1;
integer RULES_LIST_AROUSAL_INCREMENT=2;
integer RULES_LIST_AROUSAL_MAX=3;
integer RULES_LIST_KINK=4;
integer RULES_LIST_STRIDE=5;

list SlotsList;
integer SLOT_LIST_AVATAR_UUID=4;
integer SLOT_LIST_STRIDE=8;

list ArousalUpdatesList;
integer AROUSAL_UPDATES_AVATAR_UUID=0;
integer AROUSAL_UPDATES_RULES_LIST_INDEX=1;
integer AROUSAL_UPDATES_AROUSAL_TO_ADD=2;
integer AROUSAL_UPDATES_STRIDE=3;

string SLOT_LIST_SEPARATOR="^";
string MESSAGE_MINOR_SEPARATOR="/";
string RULE_NOT="!";
string RULE_AND="~";
string XCITE_SEPARATOR="|";

float XCITE_UPDATE_INTERVALL=5.0;

string MENU_MAIN="XciteMain";

key	MyUniqueId;

integer PLUGIN_IS_DISABLED;

string STRING_MENU_MAIN_PROMPT="Xcite! is currently ";
string STRING_ON="ON";
string STRING_OFF="OFF";

string MENU_BUTTON_SWITCH_ON="activate";
string MENU_BUTTON_SWITCH_OFF="deactivate";


// using the NPosePath and NPoseButtonName as a global string instead of storing it for every user, means
// that there can only be one RLV button in the menu tree. That seems to be OK for me.
string NPosePath;
string NPoseButtonName;


// NO pragma inline
debug(list message) {
	llOwnerSay(llGetScriptName() + "\n##########\n#>" + llDumpList2String(message, "\n#>") + "\n##########");
}


key getAvatarUuidFromSlotNumber(integer slotNumber) {
	return (key)llList2String(SlotsList, slotNumber * SLOT_LIST_STRIDE + SLOT_LIST_AVATAR_UUID);
}

// pragma inline
string getAvatarNameFromSlotNumber(integer slotNumber) {
	return llKey2Name(getAvatarUuidFromSlotNumber(slotNumber));
}
integer getNumberOfSeatedAvatars() {
	integer returnValue;
	integer lengthSlotsList=llGetListLength(SlotsList);
	integer indexSlotsList;
	for(; indexSlotsList<lengthSlotsList; indexSlotsList+=SLOT_LIST_STRIDE) {
		if((key)llList2String(SlotsList, indexSlotsList + SLOT_LIST_AVATAR_UUID)) {
			returnValue++;
		}
	}
	return returnValue;
}

key avatarUuidFromAvatarUuidOrSeatnumber(string uuidOrSeatNumber) {
	uuidOrSeatNumber=llStringTrim(uuidOrSeatNumber, STRING_TRIM);
	if((key)uuidOrSeatNumber) {
		return uuidOrSeatNumber;
	}
	if((integer)uuidOrSeatNumber>0) {
		return getAvatarUuidFromSlotNumber((integer)uuidOrSeatNumber-1);
	}
	return NULL_KEY;
}

showMenu(key menuTarget, string menuName) {
	if(menuName=="" || menuName==MENU_MAIN) {
		renderMenu(
			menuTarget,
			STRING_MENU_MAIN_PROMPT + conditionalString(PLUGIN_IS_DISABLED, STRING_OFF, STRING_ON),
			[conditionalString(PLUGIN_IS_DISABLED, MENU_BUTTON_SWITCH_ON, MENU_BUTTON_SWITCH_OFF)],
			MENU_MAIN
		);
	}
}

// NO pragma inline
renderMenu(key targetKey, string prompt, list buttons, string menuPath) {
	if(targetKey) {
		//make the path global
		menuPath=NPosePath + PATH_SEPARATOR + NPoseButtonName + llDeleteSubString(menuPath, 0, llStringLength(MENU_MAIN)-1);
		llMessageLinked( LINK_SET, DIALOG,
			(string)targetKey
			+ "|" +
			prompt + STRING_NEW_LINE + menuPath + STRING_NEW_LINE
			+ "|" +
			(string)0
			+ "|" +
			llDumpList2String(buttons, "`")
			+ "|" +
			MENU_BUTTON_BACK
			+ "|" +
			menuPath
			, MyUniqueId
		);
	}
}

sendToXcite(integer num, list params) {
	if(!PLUGIN_IS_DISABLED) {
		llMessageLinked(LINK_SET, num, llDumpList2String(params, XCITE_SEPARATOR), NULL_KEY);
	}
}

// NO pragma inline
string conditionalString(integer conditon, string valueIfTrue, string valueIfFalse) {
	string ret=valueIfFalse;
	if(conditon) {
		ret=valueIfTrue;
	}
	return ret;
}


default {
	state_entry() {
		MyUniqueId=llGenerateKey();
	}
	link_message(integer sender_num, integer num, string str, key id) {
		if( num == -802) {
			NPosePath=str;
			NPoseButtonName=MENU_MAIN;
		}
		else if(num==DIALOG_RESPONSE) {
			if(id==MyUniqueId) {
				//its for me
				list params = llParseString2List(str, ["|"], []);
				string selection = llList2String(params, 1);
				key toucher=(key)llList2String(params, 2);
				string path=llList2String(params, 3);
				//make the path local
				if(!llSubStringIndex(path, NPosePath + PATH_SEPARATOR)) {
					path=llDeleteSubString(path, 0, llStringLength(NPosePath + PATH_SEPARATOR) - 1);
				}
				if(!llSubStringIndex(path, NPoseButtonName)) {
					path=MENU_MAIN + llDeleteSubString(path, 0, llStringLength(NPoseButtonName) - 1);
				}
				list pathParts = llParseString2List( path, [PATH_SEPARATOR], [] );
				if(selection == MENU_BUTTON_BACK) {
					// back button hit
					selection=llList2String(pathParts, -2);
					if(path==MENU_MAIN) {
						//Path is at root menu, remenu nPose
						llMessageLinked( LINK_SET, DOMENU, NPosePath, toucher);
						return;
					}
					else if(selection==MENU_MAIN) {
						//the menu changed to the Main/Root Menu, show it
						showMenu(toucher, MENU_MAIN);
						return;
					}
					else {
						//the menu changed to a menu below the Main Menu, correct the path and selection and continue in this event
						pathParts=llDeleteSubList(pathParts, -2, -1);
						path = llDumpList2String(pathParts, PATH_SEPARATOR);
					}
				}
debug([path, selection]);
				if(selection==MENU_MAIN) {
					showMenu(toucher, MENU_MAIN);
				}
				else if(path==MENU_MAIN) {
					if(selection==MENU_BUTTON_SWITCH_OFF) {
						PLUGIN_IS_DISABLED=TRUE;
					}
					else if(selection==MENU_BUTTON_SWITCH_ON) {
						PLUGIN_IS_DISABLED=FALSE;
					}
					showMenu(toucher, MENU_MAIN);
				}
			}
		}
		else if(num==XCITE_COMMAND) {
			list params=llParseStringKeepNulls(str, [","], []);
			string cmd=llToLower(llStringTrim(llList2String(params, 0), STRING_TRIM));
			params=llDeleteSubList(params, 0, 0);
			if(cmd==XCITE_COMMAND_ADD_AROUSAL) {
				string avatarName=llKey2Name(avatarUuidFromAvatarUuidOrSeatnumber(llList2String(params, 0)));
				if(avatarName) {
					sendToXcite(XCITEQ_ADD_AROUSAL, [
						avatarName, 
						llList2String(params, 1),
						llList2String(params, 2),
						llList2String(params, 3),
						llList2String(params, 4)
					]);
				}
			}
			
			else if(cmd==XCITE_COMMAND_CLEAR_RULES) {
				RulesList=[];
				ArousalUpdatesList=[];
			}
			
			else if(cmd==XCITE_COMMAND_ADD_RULES) {
				integer incommingRulesListLength=llGetListLength(params);
				integer incommingRulesListIndex;
				for(; incommingRulesListIndex<incommingRulesListLength; incommingRulesListIndex++) {
					list incommingRulePart=llParseStringKeepNulls(llList2String(params, incommingRulesListIndex), [MESSAGE_MINOR_SEPARATOR], []);
					integer targetSeat=(integer)llList2String(incommingRulePart, RULES_LIST_TARGET_SEAT);
					string rule=llList2String(incommingRulePart, RULES_LIST_RULE);
					float arousalIncrement=(float)llList2String(incommingRulePart, RULES_LIST_AROUSAL_INCREMENT);
					if(arousalIncrement==0.0) {
						return;
					}
					integer maxArousal=100;
					if(llStringLength(llList2String(incommingRulePart, RULES_LIST_AROUSAL_MAX))) {
						maxArousal=(integer)llList2String(incommingRulePart, RULES_LIST_AROUSAL_MAX);
					}
					string kink=llList2String(incommingRulePart, RULES_LIST_KINK);
					RulesList+=[targetSeat, rule, arousalIncrement, maxArousal, kink];
				}
			}
			
			else if(cmd==XCITE_COMMAND_TILT_COCK) {
				string avatarName=llKey2Name(avatarUuidFromAvatarUuidOrSeatnumber(llList2String(params, 0)));
				if(avatarName) {
					if((integer)llList2String(params, 1)) {
						sendToXcite(XCITEQ_TILT_FORCE, [avatarName, llList2String(params, 2)]);
					}
					else {
						sendToXcite(XCITEQ_TILT_RESTORE, [avatarName]);
					}
				}
			}
			
			else if(cmd==XCITE_COMMAND_SHOW_MENU) {
				showMenu(avatarUuidFromAvatarUuidOrSeatnumber(llList2String(params, 0)), llList2String(params, 1));
			}
		}
		else if(num==SEAT_UPDATE) {
			integer oldNumberOfSeatedAvatars=getNumberOfSeatedAvatars();
			SlotsList=llParseStringKeepNulls(str,["^"],[]);
			if(!getNumberOfSeatedAvatars()) {
				llSetTimerEvent(0.0);
			}
			else if(!oldNumberOfSeatedAvatars) {
				llSetTimerEvent(XCITE_UPDATE_INTERVALL);
			}
		}
		else if( num == MEM_USAGE ) {
			llSay( 0, "Memory Used by " + llGetScriptName() + ": "
				+ (string)llGetUsedMemory() + " of " + (string)llGetMemoryLimit()
				+ ", Leaving " + (string)llGetFreeMemory() + " memory free." );
		}
		else if(num==XCITE_DUMP_DEBUG_STRING) {
			debug(
				  ["RulesList"] + RulesList
				+ ["####", "SlotsList"] + SlotsList
				+ ["####", "ArousalUpdatesList"] + ArousalUpdatesList
			);

		}
	}
	timer() {
		integer lenghtRulesList=llGetListLength(RulesList);
		integer indexRulesList;
		for(; indexRulesList<lenghtRulesList; indexRulesList+=RULES_LIST_STRIDE) {
			integer targetSlot=llList2Integer(RulesList, indexRulesList)-1;
			key avatarWorkingOn=getAvatarUuidFromSlotNumber(targetSlot);
			if(avatarWorkingOn) {
				list ruleParts=llParseString2List(llList2String(RulesList, indexRulesList + RULES_LIST_RULE), [RULE_AND], []);
				integer lengthRuleParts=llGetListLength(ruleParts);
				integer indexRuleParts;
				integer ruleMatch=TRUE;
				for(; indexRuleParts<lengthRuleParts && ruleMatch; indexRuleParts++) {
					string seatToCheckString=llList2String(ruleParts, indexRuleParts);
					integer seatToCheck=(integer)seatToCheckString;
					integer invert;
					if(!llSubStringIndex(seatToCheckString, "!")) {
						seatToCheck=(integer)llDeleteSubString(seatToCheckString, 0, 0);
						invert=TRUE;
					}
					if(invert ^ (llStringLength(getAvatarNameFromSlotNumber(seatToCheck-1))==0)) {
						ruleMatch=FALSE;
					}
				}
				if(ruleMatch) {
					if(!~llListFindList(ArousalUpdatesList, [avatarWorkingOn, indexRulesList])) {
						ArousalUpdatesList+=[avatarWorkingOn, indexRulesList, 0.0];
					}
					integer indexArousalUpdatesList=llListFindList(ArousalUpdatesList, [avatarWorkingOn, indexRulesList]);
					float arousalToIncrementModulo=llList2Float(RulesList, indexRulesList + RULES_LIST_AROUSAL_INCREMENT) / 60.0 * XCITE_UPDATE_INTERVALL + llList2Float(ArousalUpdatesList, indexArousalUpdatesList + AROUSAL_UPDATES_AROUSAL_TO_ADD);
					ArousalUpdatesList=llListReplaceList(ArousalUpdatesList, [arousalToIncrementModulo], indexArousalUpdatesList + AROUSAL_UPDATES_AROUSAL_TO_ADD, indexArousalUpdatesList + AROUSAL_UPDATES_AROUSAL_TO_ADD);
				}
				else {
					integer indexArousalUpdatesList=llListFindList(ArousalUpdatesList, [avatarWorkingOn, indexRulesList]);
					if(~indexArousalUpdatesList) {
						ArousalUpdatesList=llDeleteSubList(ArousalUpdatesList, indexArousalUpdatesList, indexArousalUpdatesList + AROUSAL_UPDATES_STRIDE-1);
					}
				}
			}
		}
		integer lengthArousalUpdatesList=llGetListLength(ArousalUpdatesList);
		integer indexArousalUpdatesList;
		for(; indexArousalUpdatesList<lengthArousalUpdatesList; indexArousalUpdatesList+=AROUSAL_UPDATES_STRIDE) {
			key avatarWorkingOn=llList2Key(ArousalUpdatesList, indexArousalUpdatesList);
			if(!~llListFindList(SlotsList, [(string)avatarWorkingOn])) {
				ArousalUpdatesList=llDeleteSubList(ArousalUpdatesList, indexArousalUpdatesList, indexArousalUpdatesList + AROUSAL_UPDATES_STRIDE - 1);
				indexArousalUpdatesList-=AROUSAL_UPDATES_STRIDE;
				lengthArousalUpdatesList-=AROUSAL_UPDATES_STRIDE;
			}
			else {
				float arousalIncrementFloat=llList2Float(ArousalUpdatesList, indexArousalUpdatesList + AROUSAL_UPDATES_AROUSAL_TO_ADD);
				integer arousalIncrementInteger=(integer)arousalIncrementFloat;
				arousalIncrementFloat-=(float)arousalIncrementInteger;
				if(arousalIncrementInteger) {
					ArousalUpdatesList=llListReplaceList(ArousalUpdatesList, [arousalIncrementFloat], indexArousalUpdatesList + AROUSAL_UPDATES_AROUSAL_TO_ADD, indexArousalUpdatesList + AROUSAL_UPDATES_AROUSAL_TO_ADD);
					indexRulesList=llList2Integer(ArousalUpdatesList, indexArousalUpdatesList + AROUSAL_UPDATES_RULES_LIST_INDEX);
					sendToXcite(XCITEQ_ADD_AROUSAL, [
						llKey2Name(avatarWorkingOn),
						(string)arousalIncrementInteger,
						(string)llList2String(RulesList, indexRulesList + RULES_LIST_AROUSAL_MAX),
						"",
						(string)llList2String(RulesList, indexRulesList + RULES_LIST_KINK)
					]);
				}
			}
		}
	}
}
