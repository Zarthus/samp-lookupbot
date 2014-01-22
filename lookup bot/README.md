SA-MP Lookup Bot
==========

This lookup bot is a simple IRC bot using Incognitos IRC plugin, it can perform SA-MP wiki lookups.  
It uses an API I run on my website to get its information.

By default, the IRC prefix is "@", you can change it in pawno/includes/irc.inc, make sure to change the script define as well  

You will need to get the remainder includes yourself, only the irc plugin by incognito, server.cfg and the .pwn file are included in this release

Commands: restart (op only), say (op only), raw (op only), version, cmds, commands, cmdhelp, commandhelp, pawn, wiki

Example output  
<@Revo> @pawn GetPlayerVehicleID  
<%SA-MP> Revo: GetPlayerVehicleID(playerid) - Returns ID of the vehicle or 0 if not in a vehicle  
<@Revo> @wiki GetPlayerVehicleID  
<%SA-MP> Revo: http://wiki.sa-mp.com/wiki/GetPlayerVehicleID  
