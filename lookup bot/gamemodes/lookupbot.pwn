#include <a_samp>
#include <a_http>
#include <irc>

main()
{
	print("----------------------------------");
	print("Simple lookup bot by Revo");
	print("https://github.com/Zarthus/samp-lookupbot");
	print("----------------------------------");
}

#define IRC_SERVER  "irc.change-my-name.please"
#define IRC_PORT    (6667)

#define IRC_USER 	"SA-MP"
#define IRC_PWD  	""
#define IRC_RLN 	"SA-MP Bot"
#define IRC_MAIN	"#lookupbot"
#define IRC_JOIN 	"#lookupbot"

#define IRC_PREFIX  "@" // Make sure to change it in irc.inc as well
#define BOT_VERS    "0.2"
#define MAX_BOTS 	(1)

#define Say IRC_Say
new gGroupID, bot;
new HTTPChannelUsed[33], HTTPUser[40], bool:awaitingResponse;

IsBotOwner(user[]) {
	if (IRC_IsOp(bot, IRC_MAIN, user))
		return true;
		
	return false;
}

IRCCMD:restart(botid, channel[], user[], host[], params[]) {
	if (!IsBotOwner(user))
		return IRC_Say(bot, channel, "You do not have permission to use this command.");

	IRC_Say(bot, channel, "Restarting now..");
	SendRconCommand("gmx");
	return 1;
}

IRCCMD:say(botid, channel[], user[], host[], params[]) {
	if (!IsBotOwner(user))
		return IRC_Say(bot, channel, "You do not have permission to use this command.");

	if (isnull(params))
		return Say(bot, channel, "Usage: say <message to send>");

	IRC_Say(bot, channel, params);
	return 1;
}

IRCCMD:raw(botid, channel[], user[], host[], params[]) {
	if (!IsBotOwner(user))
		return IRC_Say(bot, channel, "You do not have permission to use this command.");

	if (isnull(params))
		return Say(bot, channel, "Usage: raw <raw irc>");

	IRC_SendRaw(bot, params);
	Say(bot, channel, "RAW Message has been sent.");
	return 1;
}

IRCCMD:version(botid, channel[], user[], host[], params[]) {
	IRC_Say(bot, channel, "PAWN IRC Bot by Revo Version "#BOT_VERS);

	return 1;
}

IRCCMD:commands(botid, channel[], user[], host[], params[]) return irccmd_cmds(botid, channel, user, host, params);
IRCCMD:cmds(botid, channel[], user[], host[], params[]) {
	IRC_Say(bot, channel, "Prefix: \""#IRC_PREFIX"\", Commands: 04restart, 04say, 04raw, version, cmds, commands, cmdhelp, commandhelp, pawn, wiki");

	return 1;
}

IRCCMD:commandhelp(botid, channel[], user[], host[], params[]) return irccmd_cmdhelp(botid, channel, user, host, params);
IRCCMD:cmdhelp(botid, channel[], user[], host[], params[]) {
	if (isnull(params))
		return Say(bot, channel, "Usage: cmdhelp <command lookup>");

	if (!strcmp(params, "restart", true))			IRC_Say(bot, channel, "RESTART - Restart the bot - Requires op in "#IRC_MAIN);
	else if (!strcmp(params, "say", true)) 			IRC_Say(bot, channel, "SAY <message> - Message channel with message - Requires op in "#IRC_MAIN);
	else if (!strcmp(params, "raw", true)) 			IRC_Say(bot, channel, "Send a raw IRC command - "#IRC_MAIN);
	else if (!strcmp(params, "version", true)) 		IRC_Say(bot, channel, "VERSION - Version Info");
	else if (!strcmp(params, "cmds", true)) 		IRC_Say(bot, channel, "CMDS - Displays a list of commands");
	else if (!strcmp(params, "commands", true)) 	{ IRC_Say(bot, channel, "COMMANDS - Alias of CMDS"); irccmd_cmdhelp(botid, channel, user, host, "cmds"); }
	else if (!strcmp(params, "pawn", true)) 		IRC_Say(bot, channel, "PAWN <function> - Look up a pawn function from SA:MP Wiki and return information, case sensitive");
	else if (!strcmp(params, "wiki", true)) 		IRC_Say(bot, channel, "WIKI <function> - Look up a pawn function from SA:MP Wiki and return the URL, case sensitive");
	else if (!strcmp(params, "cmdhelp", true)) 		IRC_Say(bot, channel, "CMDHELP <command> - Look up help information of a specific bot command");
	else if (!strcmp(params, "commandhelp", true)) 	{ IRC_Say(bot, channel, "COMMANDHELP - Alias of CMDHELP"); irccmd_cmdhelp(botid, channel, user, host, "cmdhelp"); }
	else IRC_Say(bot, channel, "Your specified command was not found in the help database.");
	
	return 1;
}

IRCCMD:wiki(botid, channel[], user[], host[], params[]) {
	new success;
	if (awaitingResponse)
		return Say(bot, channel, "Busy.. please wait");
	if (isnull(params))
		return Say(bot, channel, "Usage: wiki <function lookup> - Keep in mind this is case sensitive!");

	awaitingResponse = true;

	new data[ 128 ];

	format(data, sizeof(data), "zarthus.nl/samp/wiki.php?lookup=%s&return=url", params);

	success = HTTP(0, HTTP_GET, data, "", "ParseWikiData");

	if (!success) return Say(bot, channel, "Unfortunately, something went wrong.");

	format(HTTPChannelUsed, 32, "%s", channel);
	format(HTTPUser, 39, "%s", user);
	return 1;
}

IRCCMD:pawn(botid, channel[], user[], host[], params[]) {
	new success;
	if (awaitingResponse)
		return Say(bot, channel, "Busy.. please wait");
	if (isnull(params))
		return Say(bot, channel, "Usage: pawn <function lookup> - Keep in mind this is case sensitive!");

	awaitingResponse = true;

	new data[ 128 ];
	
	format(data, sizeof(data), "zarthus.nl/samp/wiki.php?lookup=%s", params);

	success = HTTP(0, HTTP_GET, data, "", "ParseWikiData");

	if (!success) return Say(bot, channel, "Unfortunately, something went wrong.");

	format(HTTPChannelUsed, 32, "%s", channel);
	format(HTTPUser, 39, "%s", user);
	return 1;
}

// HTTP Response
forward ParseWikiData(index, response_code, data[]);
public ParseWikiData(index, response_code, data[])
{
    new
        buffer[ 256 ];

    if(response_code == 200) //Did the request succeed?
    {
        format(buffer, sizeof(buffer), "%s: %s", HTTPUser, data);
        if (index == 0) Say(bot, HTTPChannelUsed, buffer);
        else IRC_Notice(bot, HTTPUser, buffer);
    }
    else
    {
        format(buffer, sizeof(buffer), "%s: The request failed! The response code was: %d", HTTPUser, response_code);
        Say(bot, HTTPChannelUsed, buffer);
    }
    
   	HTTPChannelUsed = "";
   	HTTPUser = "";
   	awaitingResponse = false;
}

// IRC Callbacks

public IRC_OnDisconnect(botid, ip[], port, reason[]) {
	printf("*** IRC_OnDisconnect: Bot ID %d disconnected from %s:%d (%s)", botid, ip, port, reason);
	IRC_RemoveFromGroup(gGroupID, botid);
	return 1;
}

public IRC_OnConnect(botid, ip[], port)
{
	printf("*** IRC_OnConnect: Bot ID %d connected to %s:%d", botid, ip, port);
	IRC_SendRaw(botid, "PRIVMSG NickServ :IDENTIFY "#IRC_PWD);
	IRC_JoinChannel(botid, IRC_JOIN);
	IRC_AddToGroup(gGroupID, botid);
	return 1;
}

public IRC_OnConnectAttempt(botid, ip[], port)
{
	printf("*** IRC_OnConnectAttempt: Bot ID %d attempting to connect to %s:%d...", botid, ip, port);
	return 1;
}

public IRC_OnConnectAttemptFail(botid, ip[], port, reason[])
{
	printf("*** IRC_OnConnectAttemptFail: Bot ID %d failed to connect to %s:%d (%s)", botid, ip, port, reason);
	return 1;
}

public IRC_OnJoinChannel(botid, channel[])
{
	printf("*** IRC_OnJoinChannel: Bot ID %d joined channel %s", botid, channel);
	return 1;
}

public IRC_OnLeaveChannel(botid, channel[], message[])
{
	printf("*** IRC_OnLeaveChannel: Bot ID %d left channel %s (%s)", botid, channel, message);
	return 1;
}

public IRC_OnInvitedToChannel(botid, channel[], invitinguser[], invitinghost[])
{
	printf("*** IRC_OnInvitedToChannel: Bot ID %d invited to channel %s by %s (%s)", botid, channel, invitinguser, invitinghost);
	IRC_JoinChannel(botid, channel);
	return 1;
}

public IRC_OnKickedFromChannel(botid, channel[], oppeduser[], oppedhost[], message[])
{
	printf("*** IRC_OnKickedFromChannel: Bot ID %d kicked by %s (%s) from channel %s (%s)", botid, oppeduser, oppedhost, channel, message);
	IRC_JoinChannel(botid, channel);
	return 1;
}

public IRC_OnUserDisconnect(botid, user[], host[], message[])
{
	printf("*** IRC_OnUserDisconnect (Bot ID %d): User %s (%s) disconnected (%s)", botid, user, host, message);
	return 1;
}

public IRC_OnUserJoinChannel(botid, channel[], user[], host[])
{
	printf("*** IRC_OnUserJoinChannel (Bot ID %d): User %s (%s) joined channel %s", botid, user, host, channel);
	return 1;
}

public IRC_OnUserLeaveChannel(botid, channel[], user[], host[], message[])
{
	printf("*** IRC_OnUserLeaveChannel (Bot ID %d): User %s (%s) left channel %s (%s)", botid, user, host, channel, message);
	return 1;
}

public IRC_OnUserKickedFromChannel(botid, channel[], kickeduser[], oppeduser[], oppedhost[], message[])
{
	printf("*** IRC_OnUserKickedFromChannel (Bot ID %d): User %s kicked by %s (%s) from channel %s (%s)", botid, kickeduser, oppeduser, oppedhost, channel, message);
}

public IRC_OnUserNickChange(botid, oldnick[], newnick[], host[])
{
	printf("*** IRC_OnUserNickChange (Bot ID %d): User %s (%s) changed his/her nick to %s", botid, oldnick, host, newnick);
	return 1;
}

public IRC_OnUserSetChannelMode(botid, channel[], user[], host[], mode[])
{
	printf("*** IRC_OnUserSetChannelMode (Bot ID %d): User %s (%s) on %s set mode: %s", botid, user, host, channel, mode);
	return 1;
}

public IRC_OnUserSetChannelTopic(botid, channel[], user[], host[], topic[])
{
	printf("*** IRC_OnUserSetChannelTopic (Bot ID %d): User %s (%s) on %s set topic: %s", botid, user, host, channel, topic);
	return 1;
}

public IRC_OnUserSay(botid, recipient[], user[], host[], message[])
{
	printf("*** IRC_OnUserSay (Bot ID %d): User %s (%s) sent message to %s: %s", botid, user, host, recipient, message);

	if (strlen(message) <= 30 && (strfind(message, IRC_USER":", true) != -1 || strfind(message, IRC_USER",", true) != -1)) {
		new msg[100];

		if (strfind(message, "help", true) != -1) {
			format(msg, sizeof(msg), "%s: May I recommend "#IRC_PREFIX"cmds or "#IRC_PREFIX"cmdhelp <command>?", user);
		    Say(bot, recipient, msg);
	    }
	    
		else if (strfind(message, "hi", true) != -1 || strfind(message, "hello", true) != -1) {
			format(msg, sizeof(msg), "%s: Hello.", user);
		    Say(bot, recipient, msg);
	    }
	}
	return 1;
}

public IRC_OnUserNotice(botid, recipient[], user[], host[], message[])
{
	printf("*** IRC_OnUserNotice (Bot ID %d): User %s (%s) sent notice to %s: %s", botid, user, host, recipient, message);
	return 1;
}

public IRC_OnUserRequestCTCP(botid, user[], host[], message[])
{
	printf("*** IRC_OnUserRequestCTCP (Bot ID %d): User %s (%s) sent CTCP request: %s", botid, user, host, message);
	// Someone sent a CTCP VERSION request
	if (!strcmp(message, "VERSION"))
	{
		IRC_ReplyCTCP(botid, user, "VERSION SA-MP IRC Plugin v" #PLUGIN_VERSION ", Bot Version "#BOT_VERS);
	}
	return 1;
}

public IRC_OnUserReplyCTCP(botid, user[], host[], message[])
{
	printf("*** IRC_OnUserReplyCTCP (Bot ID %d): User %s (%s) sent CTCP reply: %s", botid, user, host, message);
	return 1;
}

public IRC_OnReceiveNumeric(botid, numeric, message[])
{
	// Check if the numeric is an error defined by RFC 1459/2812
	if (numeric >= 400 && numeric <= 599)
	{
		printf("*** IRC_OnReceiveNumeric (Bot ID %d): %d (%s)", botid, numeric, message);
	}
	return 1;
}

/*
	This callback is useful for logging, debugging, or catching error messages
	sent by the IRC server.
*/

public IRC_OnReceiveRaw(botid, message[])
{
	new File:file;
	if (!fexist("irc_log.txt"))
	{
		file = fopen("irc_log.txt", io_write);
	}
	else
	{
		file = fopen("irc_log.txt", io_append);
	}
	if (file)
	{
		fwrite(file, message);
		fwrite(file, "\r\n");
		fclose(file);
	}
	return 1;
}
// Irrelevant stuff

public OnPlayerConnect(playerid)
{
	GameTextForPlayer(playerid,"~w~SA-MP: ~r~Bare Script",5000,5);
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerInterior(playerid,0);
	TogglePlayerClock(playerid,0);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
   	return 1;
}

SetupPlayerForClassSelection(playerid)
{
 	SetPlayerInterior(playerid,14);
	SetPlayerPos(playerid,258.4893,-41.4008,1002.0234);
	SetPlayerFacingAngle(playerid, 270.0);
	SetPlayerCameraPos(playerid,256.0815,-43.0475,1004.0234);
	SetPlayerCameraLookAt(playerid,258.4893,-41.4008,1002.0234);
}

public OnPlayerRequestClass(playerid, classid)
{
	SetupPlayerForClassSelection(playerid);
	return 1;
}

public OnGameModeInit()
{
	bot = IRC_Connect(IRC_SERVER, IRC_PORT, IRC_USER, IRC_RLN, IRC_USER);

	SetGameModeText("Bare Script");
	ShowPlayerMarkers(1);
	ShowNameTags(1);
	AllowAdminTeleport(1);

	AddPlayerClass(10, 0.0, 0.0, 0.0, 0.0, 1, 2, 3, 4, 5, 6);
	return 1;
}


public OnGameModeExit()
{

	IRC_Quit(bot, "SA:MP Bot exiting");
	IRC_DestroyGroup(gGroupID);

	return 1;
}

