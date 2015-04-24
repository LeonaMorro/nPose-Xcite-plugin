$import LSLScripts.constantsXcitePlugin.lslm ();

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

list CARD_NAMES=["DEFAULT", "SET", "BTN", "SEQ"];

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

showMenu(key menuTarget, string basePath, string localPath) {
	string menuName=llList2String(llParseStringKeepNulls(localPath, [PATH_SEPARATOR], []), -1);
	if(menuName=="") {
		renderMenu(
			menuTarget,
			basePath,
			localPath,
			STRING_MENU_MAIN_PROMPT + conditionalString(PLUGIN_IS_DISABLED, STRING_OFF, STRING_ON),
			[conditionalString(PLUGIN_IS_DISABLED, MENU_BUTTON_SWITCH_ON, MENU_BUTTON_SWITCH_OFF)]
		);
	}
}

// NO pragma inline
renderMenu(key targetKey, string basePath, string localPath, string prompt, list buttons) {
	if(targetKey) {
		llMessageLinked( LINK_SET, DIALOG,
			(string)targetKey
			+ "|"
			+ prompt + STRING_NEW_LINE + STRING_NEW_LINE + basePath + localPath + STRING_NEW_LINE
			+ "|0|"
			+ llDumpList2String(buttons, "`")
			+ "|"
			+ conditionalString(basePath!="" || localPath!="", MENU_BUTTON_BACK, "")
			+ "|"
			+ basePath + "," + localPath
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

// pragma inline
string getPathFromCardName(string cardName) {
	list pathParts=llParseStringKeepNulls(cardName, [PATH_SEPARATOR], []);
	if(~llListFindList(CARD_NAMES, [llList2String(pathParts, 0)])) {
		pathParts="Main" + llDeleteSubList(pathParts, 0, 0);
	}
	integer index=llSubStringIndex(llList2String(pathParts, -1), "{");
	if(~index) {
		pathParts=llDeleteSubList(pathParts, -1, -1) + llDeleteSubString(llList2String(pathParts, -1), index, -1);
	}
	return llDumpList2String(pathParts, PATH_SEPARATOR);
}



default {
	state_entry() {
		MyUniqueId=llGenerateKey();
	}
	link_message(integer sender_num, integer num, string str, key id) {
		if(num==DIALOG_RESPONSE) {
			if(id==MyUniqueId) {
				//its for me
				list params = llParseString2List(str, ["|"], []);
				string selection = llList2String(params, 1);
				key toucher=(key)llList2String(params, 2);
				list tempPath=llParseStringKeepNulls(llList2String(params, 3), [","], []);
				string basePath=llList2String(tempPath, 0);
				string localPath=llList2String(tempPath, 1);
				list localPathParts=llParseStringKeepNulls(localPath, [PATH_SEPARATOR], []);
				if(selection == MENU_BUTTON_BACK) {
					// back button hit
					if(localPath=="") {
						//localPath is at root menu, remenu nPose
						basePath=llDumpList2String(llDeleteSubList(llParseStringKeepNulls(basePath, [PATH_SEPARATOR], []), -1, -1), PATH_SEPARATOR);
						if(basePath) {
							llMessageLinked( LINK_SET, DOMENU, basePath, toucher);
						}
					}
					else {
						//the menu changed to a menu within our plugin
						showMenu(toucher, basePath, llDumpList2String(llDeleteSubList(localPathParts, -1, -1), PATH_SEPARATOR));
					}
				}
				else if(localPath=="") {
					if(selection==MENU_BUTTON_SWITCH_OFF) {
						PLUGIN_IS_DISABLED=TRUE;
					}
					else if(selection==MENU_BUTTON_SWITCH_ON) {
						PLUGIN_IS_DISABLED=FALSE;
					}
					showMenu(toucher, basePath, localPath);
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
				showMenu(avatarUuidFromAvatarUuidOrSeatnumber(llList2String(params, 0)), getPathFromCardName(llList2String(params, 1)), llList2String(params, 2));
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
