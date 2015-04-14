// LSL script generated - patched Render.hs (0.1.6.2): DebuggingAndExamples.nPose Xcite! DebugListener.lslp Tue Apr 14 18:54:56 Mitteleuropäische Sommerzeit 2015


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
            debug(["20001",str]);
        }
    }

	listen(integer channel,string name,key id,string message) {
        integer num;
        if (!channel || llGetOwnerKey(id) == llGetOwner()) {
            if (llGetSubString(message,0,0) == "x") {
                num = -8048;
            }
            if (num) {
                llMessageLinked(-1,num,llGetSubString(message,1,-1),"");
            }
        }
    }
}
