// LSL script generated - patched Render.hs (0.1.6.2): LSLScripts.nPose Xcite!.lslp Fri Apr 24 19:19:47 Mitteleuropäische Sommerzeit 2015

string STRING_NEW_LINE = "\n";
string PATH_SEPARATOR = ":";
string MENU_BUTTON_BACK = "^";

string XCITE_COMMAND_SHOW_MENU = "showmenu";
string XCITE_COMMAND_ADD_AROUSAL = "addarousal";
string XCITE_COMMAND_TILT_COCK = "tiltcock";
string XCITE_COMMAND_CLEAR_RULES = "clearrules";
string XCITE_COMMAND_ADD_RULES = "addrules";

list RulesList;

list SlotsList;

list ArousalUpdatesList;
string MESSAGE_MINOR_SEPARATOR = "/";
string RULE_AND = "~";
string XCITE_SEPARATOR = "|";

key MyUniqueId;

integer PLUGIN_IS_DISABLED;

string STRING_MENU_MAIN_PROMPT = "Xcite! is currently ";
string STRING_ON = "ON";
string STRING_OFF = "OFF";

string MENU_BUTTON_SWITCH_ON = "activate";
string MENU_BUTTON_SWITCH_OFF = "deactivate";

list CARD_NAMES = ["DEFAULT","SET","BTN","SEQ"];

// NO pragma inline
debug(list message){
    llOwnerSay(llGetScriptName() + "\n##########\n#>" + llDumpList2String(message,"\n#>") + "\n##########");
}


key getAvatarUuidFromSlotNumber(integer slotNumber){
    return (key)llList2String(SlotsList,slotNumber * 8 + 4);
}
integer getNumberOfSeatedAvatars(){
    integer returnValue;
    integer lengthSlotsList = llGetListLength(SlotsList);
    integer indexSlotsList;
    for (; indexSlotsList < lengthSlotsList; indexSlotsList += 8) {
        if ((key)llList2String(SlotsList,indexSlotsList + 4)) {
            returnValue++;
        }
    }
    return returnValue;
}

key avatarUuidFromAvatarUuidOrSeatnumber(string uuidOrSeatNumber){
    uuidOrSeatNumber = llStringTrim(uuidOrSeatNumber,3);
    if ((key)uuidOrSeatNumber) {
        return uuidOrSeatNumber;
    }
    if ((integer)uuidOrSeatNumber > 0) {
        return getAvatarUuidFromSlotNumber((integer)uuidOrSeatNumber - 1);
    }
    return NULL_KEY;
}

showMenu(key menuTarget,string basePath,string localPath){
    string menuName = llList2String(llParseStringKeepNulls(localPath,[PATH_SEPARATOR],[]),-1);
    if (menuName == "") {
        renderMenu(menuTarget,basePath,localPath,STRING_MENU_MAIN_PROMPT + conditionalString(PLUGIN_IS_DISABLED,STRING_OFF,STRING_ON),[conditionalString(PLUGIN_IS_DISABLED,MENU_BUTTON_SWITCH_ON,MENU_BUTTON_SWITCH_OFF)]);
    }
}

// NO pragma inline
renderMenu(key targetKey,string basePath,string localPath,string prompt,list buttons){
    if (targetKey) {
        llMessageLinked(-1,-900,(string)targetKey + "|" + prompt + STRING_NEW_LINE + STRING_NEW_LINE + basePath + localPath + STRING_NEW_LINE + "|0|" + llDumpList2String(buttons,"`") + "|" + conditionalString(basePath != "" || localPath != "",MENU_BUTTON_BACK,"") + "|" + basePath + "," + localPath,MyUniqueId);
    }
}

sendToXcite(integer num,list params){
    if (!PLUGIN_IS_DISABLED) {
        llMessageLinked(-1,num,llDumpList2String(params,XCITE_SEPARATOR),NULL_KEY);
    }
}

// NO pragma inline
string conditionalString(integer conditon,string valueIfTrue,string valueIfFalse){
    string ret = valueIfFalse;
    if (conditon) {
        ret = valueIfTrue;
    }
    return ret;
}



default {

	state_entry() {
        MyUniqueId = llGenerateKey();
    }

	link_message(integer sender_num,integer num,string str,key id) {
        if (num == -901) {
            if (id == MyUniqueId) {
                list params = llParseString2List(str,["|"],[]);
                string selection = llList2String(params,1);
                key toucher = (key)llList2String(params,2);
                list tempPath = llParseStringKeepNulls(llList2String(params,3),[","],[]);
                string basePath = llList2String(tempPath,0);
                string localPath = llList2String(tempPath,1);
                list localPathParts = llParseStringKeepNulls(localPath,[PATH_SEPARATOR],[]);
                if (selection == MENU_BUTTON_BACK) {
                    if (localPath == "") {
                        basePath = llDumpList2String(llDeleteSubList(llParseStringKeepNulls(basePath,[PATH_SEPARATOR],[]),-1,-1),PATH_SEPARATOR);
                        if (basePath) {
                            llMessageLinked(-1,-800,basePath,toucher);
                        }
                    }
                    else  {
                        showMenu(toucher,basePath,llDumpList2String(llDeleteSubList(localPathParts,-1,-1),PATH_SEPARATOR));
                    }
                }
                else  if (localPath == "") {
                    if (selection == MENU_BUTTON_SWITCH_OFF) {
                        PLUGIN_IS_DISABLED = 1;
                    }
                    else  if (selection == MENU_BUTTON_SWITCH_ON) {
                        PLUGIN_IS_DISABLED = 0;
                    }
                    showMenu(toucher,basePath,localPath);
                }
            }
        }
        else  if (num == -8040) {
            list params = llParseStringKeepNulls(str,[","],[]);
            string cmd = llToLower(llStringTrim(llList2String(params,0),3));
            params = llDeleteSubList(params,0,0);
            if (cmd == XCITE_COMMAND_ADD_AROUSAL) {
                string avatarName = llKey2Name(avatarUuidFromAvatarUuidOrSeatnumber(llList2String(params,0)));
                if (avatarName) {
                    sendToXcite(20001,[avatarName,llList2String(params,1),llList2String(params,2),llList2String(params,3),llList2String(params,4)]);
                }
            }
            else  if (cmd == XCITE_COMMAND_CLEAR_RULES) {
                RulesList = [];
                ArousalUpdatesList = [];
            }
            else  if (cmd == XCITE_COMMAND_ADD_RULES) {
                integer incommingRulesListLength = llGetListLength(params);
                integer incommingRulesListIndex;
                for (; incommingRulesListIndex < incommingRulesListLength; incommingRulesListIndex++) {
                    list incommingRulePart = llParseStringKeepNulls(llList2String(params,incommingRulesListIndex),[MESSAGE_MINOR_SEPARATOR],[]);
                    integer targetSeat = (integer)llList2String(incommingRulePart,0);
                    string rule = llList2String(incommingRulePart,1);
                    float arousalIncrement = (float)llList2String(incommingRulePart,2);
                    if (arousalIncrement == 0.0) {
                        return;
                    }
                    integer maxArousal = 100;
                    if (llStringLength(llList2String(incommingRulePart,3))) {
                        maxArousal = (integer)llList2String(incommingRulePart,3);
                    }
                    string kink = llList2String(incommingRulePart,4);
                    RulesList += [targetSeat,rule,arousalIncrement,maxArousal,kink];
                }
            }
            else  if (cmd == XCITE_COMMAND_TILT_COCK) {
                string avatarName = llKey2Name(avatarUuidFromAvatarUuidOrSeatnumber(llList2String(params,0)));
                if (avatarName) {
                    if ((integer)llList2String(params,1)) {
                        sendToXcite(20020,[avatarName,llList2String(params,2)]);
                    }
                    else  {
                        sendToXcite(20014,[avatarName]);
                    }
                }
            }
            else  if (cmd == XCITE_COMMAND_SHOW_MENU) {
                list pathParts = llParseStringKeepNulls(llList2String(params,1),[PATH_SEPARATOR],[]);
                if (~llListFindList(CARD_NAMES,[llList2String(pathParts,0)])) {
                    pathParts = "Main" + llDeleteSubList(pathParts,0,0);
                }
                integer index = llSubStringIndex(llList2String(pathParts,-1),"{");
                if (~index) {
                    pathParts = llDeleteSubList(pathParts,-1,-1) + llDeleteSubString(llList2String(pathParts,-1),index,-1);
                }
                showMenu(avatarUuidFromAvatarUuidOrSeatnumber(llList2String(params,0)),llDumpList2String(pathParts,PATH_SEPARATOR),llList2String(params,2));
            }
        }
        else  if (num == 35353) {
            integer oldNumberOfSeatedAvatars = getNumberOfSeatedAvatars();
            SlotsList = llParseStringKeepNulls(str,["^"],[]);
            if (!getNumberOfSeatedAvatars()) {
                llSetTimerEvent(0.0);
            }
            else  if (!oldNumberOfSeatedAvatars) {
                llSetTimerEvent(5.0);
            }
        }
        else  if (num == 34334) {
            llSay(0,"Memory Used by " + llGetScriptName() + ": " + (string)llGetUsedMemory() + " of " + (string)llGetMemoryLimit() + ", Leaving " + (string)llGetFreeMemory() + " memory free.");
        }
        else  if (num == -8048) {
            debug(["RulesList"] + RulesList + ["####","SlotsList"] + SlotsList + ["####","ArousalUpdatesList"] + ArousalUpdatesList);
        }
    }

	timer() {
        integer lenghtRulesList = llGetListLength(RulesList);
        integer indexRulesList;
        for (; indexRulesList < lenghtRulesList; indexRulesList += 5) {
            integer targetSlot = llList2Integer(RulesList,indexRulesList) - 1;
            key avatarWorkingOn = getAvatarUuidFromSlotNumber(targetSlot);
            if (avatarWorkingOn) {
                list ruleParts = llParseString2List(llList2String(RulesList,indexRulesList + 1),[RULE_AND],[]);
                integer lengthRuleParts = llGetListLength(ruleParts);
                integer indexRuleParts;
                integer ruleMatch = 1;
                for (; indexRuleParts < lengthRuleParts && ruleMatch; indexRuleParts++) {
                    string seatToCheckString = llList2String(ruleParts,indexRuleParts);
                    integer seatToCheck = (integer)seatToCheckString;
                    integer invert;
                    if (!llSubStringIndex(seatToCheckString,"!")) {
                        seatToCheck = (integer)llDeleteSubString(seatToCheckString,0,0);
                        invert = 1;
                    }
                    if (invert ^ llStringLength(llKey2Name(getAvatarUuidFromSlotNumber(seatToCheck - 1))) == 0) {
                        ruleMatch = 0;
                    }
                }
                if (ruleMatch) {
                    if (!~llListFindList(ArousalUpdatesList,[avatarWorkingOn,indexRulesList])) {
                        ArousalUpdatesList += [avatarWorkingOn,indexRulesList,0.0];
                    }
                    integer indexArousalUpdatesList = llListFindList(ArousalUpdatesList,[avatarWorkingOn,indexRulesList]);
                    float arousalToIncrementModulo = llList2Float(RulesList,indexRulesList + 2) / 60.0 * 5.0 + llList2Float(ArousalUpdatesList,indexArousalUpdatesList + 2);
                    ArousalUpdatesList = llListReplaceList(ArousalUpdatesList,[arousalToIncrementModulo],indexArousalUpdatesList + 2,indexArousalUpdatesList + 2);
                }
                else  {
                    integer indexArousalUpdatesList = llListFindList(ArousalUpdatesList,[avatarWorkingOn,indexRulesList]);
                    if (~indexArousalUpdatesList) {
                        ArousalUpdatesList = llDeleteSubList(ArousalUpdatesList,indexArousalUpdatesList,indexArousalUpdatesList + 3 - 1);
                    }
                }
            }
        }
        integer lengthArousalUpdatesList = llGetListLength(ArousalUpdatesList);
        integer indexArousalUpdatesList;
        for (; indexArousalUpdatesList < lengthArousalUpdatesList; indexArousalUpdatesList += 3) {
            key avatarWorkingOn = llList2Key(ArousalUpdatesList,indexArousalUpdatesList);
            if (!~llListFindList(SlotsList,[(string)avatarWorkingOn])) {
                ArousalUpdatesList = llDeleteSubList(ArousalUpdatesList,indexArousalUpdatesList,indexArousalUpdatesList + 3 - 1);
                indexArousalUpdatesList -= 3;
                lengthArousalUpdatesList -= 3;
            }
            else  {
                float arousalIncrementFloat = llList2Float(ArousalUpdatesList,indexArousalUpdatesList + 2);
                integer arousalIncrementInteger = (integer)arousalIncrementFloat;
                arousalIncrementFloat -= (float)arousalIncrementInteger;
                if (arousalIncrementInteger) {
                    ArousalUpdatesList = llListReplaceList(ArousalUpdatesList,[arousalIncrementFloat],indexArousalUpdatesList + 2,indexArousalUpdatesList + 2);
                    indexRulesList = llList2Integer(ArousalUpdatesList,indexArousalUpdatesList + 1);
                    sendToXcite(20001,[llKey2Name(avatarWorkingOn),(string)arousalIncrementInteger,(string)llList2String(RulesList,indexRulesList + 3),"",(string)llList2String(RulesList,indexRulesList + 4)]);
                }
            }
        }
    }
}
