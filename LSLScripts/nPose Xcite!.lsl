// LSLScripts.nPose Xcite!.lslp 
// 2017-11-12 16:50:27 - LSLForge (0.1.9.3) generated

string XCITE_UDP_NAME = "xcite";
string XCITE_COMMAND_ADD_AROUSAL = "addarousal";
string XCITE_COMMAND_TILT_COCK = "tiltcock";
string XCITE_COMMAND_CLEAR_RULES = "clearrules";
string XCITE_COMMAND_ADD_RULES = "addrules";

list RulesList;

list SlotsList;

list ArousalUpdatesList;
string MESSAGE_MINOR_SEPARATOR = "/";
string RULE_AND = "&";
string XCITE_SEPARATOR = "|";

integer PluginDisabled;

// NO pragma inline
debug(list message){
  llOwnerSay((((llGetScriptName() + "\n##########\n#>") + llDumpList2String(message,"\n#>")) + "\n##########"));
}


key getAvatarUuidFromSlotNumber(integer slotNumber){
  return ((key)llList2String(SlotsList,((slotNumber * 8) + 4)));
}
integer getNumberOfSeatedAvatars(){
  integer returnValue;
  integer lengthSlotsList = llGetListLength(SlotsList);
  integer indexSlotsList;
  for (; (indexSlotsList < lengthSlotsList); (indexSlotsList += 8)) {
    if (((key)llList2String(SlotsList,(indexSlotsList + 4)))) {
      (returnValue++);
    }
  }
  return returnValue;
}

key avatarUuidFromAvatarUuidOrSeatnumber(string uuidOrSeatNumber){
  (uuidOrSeatNumber = llStringTrim(uuidOrSeatNumber,3));
  if (((key)uuidOrSeatNumber)) {
    return uuidOrSeatNumber;
  }
  if ((((integer)uuidOrSeatNumber) > 0)) {
    return getAvatarUuidFromSlotNumber((((integer)uuidOrSeatNumber) - 1));
  }
  return NULL_KEY;
}

sendToXcite(integer num,list params){
  if ((!PluginDisabled)) {
    llMessageLinked(-1,num,llDumpList2String(params,XCITE_SEPARATOR),NULL_KEY);
  }
}

default {

	state_entry() {
  }

	link_message(integer sender_num,integer num,string str,key id) {
    if ((num == -8040)) {
      list params = llParseStringKeepNulls(str,[","],[]);
      string cmd = llToLower(llStringTrim(llList2String(params,0),3));
      (params = llDeleteSubList(params,0,0));
      if ((cmd == XCITE_COMMAND_ADD_AROUSAL)) {
        string avatarName = llKey2Name(avatarUuidFromAvatarUuidOrSeatnumber(llList2String(params,0)));
        if (avatarName) {
          sendToXcite(20001,[avatarName,llList2String(params,1),llList2String(params,2),llList2String(params,3),llList2String(params,4)]);
        }
      }
      else  if ((cmd == XCITE_COMMAND_CLEAR_RULES)) {
        (RulesList = []);
        (ArousalUpdatesList = []);
      }
      else  if ((cmd == XCITE_COMMAND_ADD_RULES)) {
        integer incommingRulesListLength = llGetListLength(params);
        integer incommingRulesListIndex;
        for (; (incommingRulesListIndex < incommingRulesListLength); (incommingRulesListIndex++)) {
          list incommingRulePart = llParseStringKeepNulls(llList2String(params,incommingRulesListIndex),[MESSAGE_MINOR_SEPARATOR],[]);
          integer targetSeat = ((integer)llList2String(incommingRulePart,0));
          string rule = llList2String(incommingRulePart,1);
          float arousalIncrement = ((float)llList2String(incommingRulePart,2));
          if ((arousalIncrement == 0.0)) {
            return;
          }
          integer maxArousal = 100;
          if (llStringLength(llList2String(incommingRulePart,3))) {
            (maxArousal = ((integer)llList2String(incommingRulePart,3)));
          }
          string kink = llList2String(incommingRulePart,4);
          (RulesList += [targetSeat,rule,arousalIncrement,maxArousal,kink]);
        }
      }
      else  if ((cmd == XCITE_COMMAND_TILT_COCK)) {
        string avatarName = llKey2Name(avatarUuidFromAvatarUuidOrSeatnumber(llList2String(params,0)));
        if (avatarName) {
          if (((integer)llList2String(params,1))) {
            sendToXcite(20020,[avatarName,llList2String(params,2)]);
          }
          else  {
            sendToXcite(20014,[avatarName]);
          }
        }
      }
    }
    else  if ((num == -804)) {
      list optionsToSet = llParseStringKeepNulls(str,["~","|"],[]);
      integer length = llGetListLength(optionsToSet);
      integer index;
      for (; (index < length); (++index)) {
        list optionsItems = llParseString2List(llList2String(optionsToSet,index),["="],[]);
        string optionItem = llToLower(llStringTrim(llList2String(optionsItems,0),3));
        if ((optionItem == XCITE_UDP_NAME)) {
          string optionString = llList2String(optionsItems,1);
          string optionSetting = llToLower(llStringTrim(optionString,3));
          integer optionSettingFlag = ((optionSetting == "on") || ((integer)optionSetting));
          (PluginDisabled = (!optionSettingFlag));
        }
      }
    }
    else  if ((num == 35353)) {
      integer oldNumberOfSeatedAvatars = getNumberOfSeatedAvatars();
      (SlotsList = llParseStringKeepNulls(str,["^"],[]));
      if ((!getNumberOfSeatedAvatars())) {
        llSetTimerEvent(0.0);
      }
      else  if ((!oldNumberOfSeatedAvatars)) {
        llSetTimerEvent(5.0);
      }
    }
    else  if ((num == 34334)) {
      llSay(0,(((((((("Memory Used by " + llGetScriptName()) + ": ") + ((string)llGetUsedMemory())) + " of ") + ((string)llGetMemoryLimit())) + ", Leaving ") + ((string)llGetFreeMemory())) + " memory free."));
    }
    else  if ((num == -8048)) {
      debug((((((["RulesList"] + RulesList) + ["####","SlotsList"]) + SlotsList) + ["####","ArousalUpdatesList"]) + ArousalUpdatesList));
    }
  }

	timer() {
    integer lenghtRulesList = llGetListLength(RulesList);
    integer indexRulesList;
    for (; (indexRulesList < lenghtRulesList); (indexRulesList += 5)) {
      integer targetSlot = (llList2Integer(RulesList,indexRulesList) - 1);
      key avatarWorkingOn = getAvatarUuidFromSlotNumber(targetSlot);
      if (avatarWorkingOn) {
        list ruleParts = llParseString2List(llList2String(RulesList,(indexRulesList + 1)),[RULE_AND],[]);
        integer lengthRuleParts = llGetListLength(ruleParts);
        integer indexRuleParts;
        integer ruleMatch = 1;
        for (; ((indexRuleParts < lengthRuleParts) && ruleMatch); (indexRuleParts++)) {
          string seatToCheckString = llList2String(ruleParts,indexRuleParts);
          integer seatToCheck = ((integer)seatToCheckString);
          integer invert;
          if ((!llSubStringIndex(seatToCheckString,"!"))) {
            (seatToCheck = ((integer)llDeleteSubString(seatToCheckString,0,0)));
            (invert = 1);
          }
          if ((invert ^ (llStringLength(llKey2Name(getAvatarUuidFromSlotNumber((seatToCheck - 1)))) == 0))) {
            (ruleMatch = 0);
          }
        }
        if (ruleMatch) {
          if ((!(~llListFindList(ArousalUpdatesList,[avatarWorkingOn,indexRulesList])))) {
            (ArousalUpdatesList += [avatarWorkingOn,indexRulesList,0.0]);
          }
          integer indexArousalUpdatesList = llListFindList(ArousalUpdatesList,[avatarWorkingOn,indexRulesList]);
          float arousalToIncrementModulo = (((llList2Float(RulesList,(indexRulesList + 2)) / 60.0) * 5.0) + llList2Float(ArousalUpdatesList,(indexArousalUpdatesList + 2)));
          (ArousalUpdatesList = llListReplaceList(ArousalUpdatesList,[arousalToIncrementModulo],(indexArousalUpdatesList + 2),(indexArousalUpdatesList + 2)));
        }
        else  {
          integer indexArousalUpdatesList = llListFindList(ArousalUpdatesList,[avatarWorkingOn,indexRulesList]);
          if ((~indexArousalUpdatesList)) {
            (ArousalUpdatesList = llDeleteSubList(ArousalUpdatesList,indexArousalUpdatesList,((indexArousalUpdatesList + 3) - 1)));
          }
        }
      }
    }
    integer lengthArousalUpdatesList = llGetListLength(ArousalUpdatesList);
    integer indexArousalUpdatesList;
    for (; (indexArousalUpdatesList < lengthArousalUpdatesList); (indexArousalUpdatesList += 3)) {
      key avatarWorkingOn = llList2Key(ArousalUpdatesList,indexArousalUpdatesList);
      if ((!(~llListFindList(SlotsList,[((string)avatarWorkingOn)])))) {
        (ArousalUpdatesList = llDeleteSubList(ArousalUpdatesList,indexArousalUpdatesList,((indexArousalUpdatesList + 3) - 1)));
        (indexArousalUpdatesList -= 3);
        (lengthArousalUpdatesList -= 3);
      }
      else  {
        float arousalIncrementFloat = llList2Float(ArousalUpdatesList,(indexArousalUpdatesList + 2));
        integer arousalIncrementInteger = ((integer)arousalIncrementFloat);
        (arousalIncrementFloat -= ((float)arousalIncrementInteger));
        if (arousalIncrementInteger) {
          (ArousalUpdatesList = llListReplaceList(ArousalUpdatesList,[arousalIncrementFloat],(indexArousalUpdatesList + 2),(indexArousalUpdatesList + 2)));
          (indexRulesList = llList2Integer(ArousalUpdatesList,(indexArousalUpdatesList + 1)));
          sendToXcite(20001,[llKey2Name(avatarWorkingOn),((string)arousalIncrementInteger),((string)llList2String(RulesList,(indexRulesList + 3))),"",((string)llList2String(RulesList,(indexRulesList + 4)))]);
        }
      }
    }
  }
}
