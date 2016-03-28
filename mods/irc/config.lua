-- This file is licensed under the terms of the BSD 2-clause license.
-- See LICENSE.txt for details.


irc.config = {}

local function setting(stype, name, default, required)
	local value
	if stype == "bool" then
		value = minetest.setting_getbool("irc."..name)
	elseif stype == "string" then
		value = minetest.setting_get("irc."..name)
	elseif stype == "number" then
		value = tonumber(minetest.setting_get("irc."..name))
	end
	if value == nil then
		if required then
			error("Required configuration option irc."..
				name.." missing.")
		end
		value = default
	end
	irc.config[name] = value
end

-------------------------
-- BASIC USER SETTINGS --
-------------------------

setting("string", "nick", nil, true) -- Nickname
setting("string", "server", nil, true) -- Server address to connect to
setting("number", "port", 6667) -- Server port to connect to
setting("string", "NSPass") -- NickServ password
setting("string", "sasl.user", irc.config.nick) -- SASL username
setting("string", "sasl.pass") -- SASL password
setting("string", "channel", nil, true) -- Channel to join
setting("string", "key") -- Key for the channel
setting("bool",   "send_join_part", true) -- Whether to send player join and part messages to the channel

-----------------------
-- ADVANCED SETTINGS --
-----------------------

setting("string", "password") -- Server password
setting("bool",   "secure", false) -- Enable a TLS connection, requires LuaSEC
setting("number", "timeout", 60) -- Underlying socket timeout in seconds.
setting("string", "command_prefix") -- Prefix to use for bot commands
setting("bool",   "debug", false) -- Enable debug output
setting("bool",   "enable_player_part", true) -- Whether to enable players joining and parting the channel
setting("bool",   "auto_join", true) -- Whether to automatically show players in the channel when they join
setting("bool",   "auto_connect", true) -- Whether to automatically connect to the server on mod load

