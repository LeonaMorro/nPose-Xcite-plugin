$import LSLScripts.constantsXcitePlugin.lslm ();

debug(list message) {
	llOwnerSay(llGetScriptName() + "\n#>" + llDumpList2String(message, "\n#>"));
}

default {
	state_entry() {
		llListen(0, "", llGetOwner(), "");
		llListen(3, "", NULL_KEY, "");
	}

	link_message(integer sender_num, integer num, string str, key id) {
		if(num==XCITE_COMMAND) {
			list params=llParseStringKeepNulls(str, [","], []);
			string cmd=llToLower(llStringTrim(llList2String(params, 0), STRING_TRIM));
			params=llDeleteSubList(params, 0, 0);
			debug(["XCITE_COMMAND", "cmd: " + cmd, "params:"] + params);
		}
		else if(num==XCITEQ_ADD_AROUSAL) {
			debug(["XCITEQ_ADD_AROUSAL", str]);
		}
		else if(num==XCITEQ_TILT_FORCE) {
			debug(["XCITEQ_TILT_FORCE", str]);
		}
		else if(num==XCITEQ_TILT_RESTORE) {
			debug(["XCITEQ_TILT_RESTORE", str]);
		}
		else if(num==DOMENU) {
			debug(["DOMENU", str, id]);
		}
		else if(num==DIALOG) {
			debug(["DIALOG", str, id]);
		}
		else if(num==DIALOG_RESPONSE) {
			debug(["DIALOG_RESPONSE", str, id]);
		}
		else if(num==MEM_USAGE) {
			debug(["MEM_USAGE"]);
		}
		else if(num==SEAT_UPDATE) {
			debug(["SEAT_UPDATE", str]);
		}
	}
	listen(integer channel, string name, key id, string message) {
		integer num;
		if(!channel || llGetOwnerKey(id)==llGetOwner()) {
			if(llGetSubString(message, 0, 0)=="x") {
				num=XCITE_DUMP_DEBUG_STRING;
			}
			if(num) {
				llMessageLinked(LINK_SET, num, llDeleteSubString(message, 0, 0), "");
			}
		}
	}
}
