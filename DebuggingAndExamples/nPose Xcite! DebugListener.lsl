// LSL script generated - patched Render.hs (0.1.6.2): DebuggingAndExamples.nPose Xcite! DebugListener.lslp Mon Aug  3 18:44:26 Mitteleuropäische Sommerzeit 2015


debug(list message){
    llOwnerSay(llGetScriptName() + "\n#>" + llDumpList2String(message,"\n#>"));
}

default {

	state_entry() {
        llListen(0,"",llGetOwner(),"");
        llListen(3,"",NULL_KEY,"");
    }


	link_message(integer sender_num,integer num,string str,key id) {
        if (num == -8040) {
            list params = llParseStringKeepNulls(str,[","],[]);
            string cmd = llToLower(llStringTrim(llList2String(params,0),3));
            params = llDeleteSubList(params,0,0);
            debug(["XCITE_COMMAND","cmd: " + cmd,"params:"] + params);
        }
        else  if (num == 20001) {
            debug(["XCITEQ_ADD_AROUSAL",str]);
        }
        else  if (num == 20020) {
            debug(["XCITEQ_TILT_FORCE",str]);
        }
        else  if (num == 20014) {
            debug(["XCITEQ_TILT_RESTORE",str]);
        }
        else  if (num == -800) {
            debug(["DOMENU",str,id]);
        }
        else  if (num == -900) {
            debug(["DIALOG",str,id]);
        }
        else  if (num == -901) {
            debug(["DIALOG_RESPONSE",str,id]);
        }
        else  if (num == 34334) {
            debug(["MEM_USAGE"]);
        }
        else  if (num == 35353) {
            debug(["SEAT_UPDATE",str]);
        }
    }

	listen(integer channel,string name,key id,string message) {
        integer num;
        if (!channel || llGetOwnerKey(id) == llGetOwner()) {
            if (llGetSubString(message,0,0) == "x") {
                num = -8048;
            }
            if (num) {
                llMessageLinked(-1,num,llDeleteSubString(message,0,0),"");
            }
        }
    }
}
