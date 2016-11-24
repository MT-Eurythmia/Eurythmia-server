-- The backup is scheduled at 04:30, so request shutdown at 04:27
local shutdown_time = {year=2000, month=1, day=1, hour=4, min=27} -- don't care of the year, month and day

local CHECK_INTERVAL = 60
local check_timer = 0
minetest.register_globalstep(function(dtime)
	check_timer = check_timer + dtime
	if check_timer < CHECK_INTERVAL then
		return
	end
	check_timer = 0

	if os.date("%H:%M") == os.date("%H:%M", os.time(shutdown_time) - 10 * 60) then
		minetest.chat_send_all("Info: the server will shutdown for backup in 10 minutes.")
	elseif os.date("%H:%M") == os.date("%H:%M", os.time(shutdown_time) - 5 * 60) then
		minetest.chat_send_all("Info: the server will shutdown for backup in 5 minutes.")
	elseif os.date("%H:%M") == os.date("%H:%M", os.time(shutdown_time) - 60) then
		minetest.chat_send_all("Info: the server will shutdown for backup in a minute.")
	elseif os.date("%H:%M") == os.date("%H:%M", os.time(shutdown_time)) then
		minetest.request_shutdown("*** Shutting down for backup now ! ***", false)
	end
end)
