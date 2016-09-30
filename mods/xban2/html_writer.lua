local HTML_FILE = "/var/www/mynetest/hos/index.html"

local head = "<!DOCTYPE html>\n"..
             "<head>\n"..
             "    <title>Hall of shame</title>\n"..
             "    <meta charset=\"UTF-8\" />\n"..
             "</head>\n"..
             "<body>\n"..
             "    <h1>Hall of shame</h1>\n"..
             "    <ul>\n"
local foot = "    </ul>\n"..
             "</body>\n"..
             "\n"

function xban.write_hos(db)
	local file, err = io.open(HTML_FILE, "wt")
	if not file then
		minetest.log("warning", "Unable to open the Hall Of Shame HTML file: " .. err)
		return
	end

	local s = head
	for index, e in ipairs(db) do
		if e.banned then
			s = s .. "<li>"
			for name in pairs(e.names) do
				if not name:match("^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$") then -- Do not print IPs. TODO: IPv6 regex
					if next(e.names, name) then
						s = s .. name .. "/"
					else
						s = s .. name
					end
				end
			end
			local date = (e.expires and os.date("%c", e.expires)
			  or "the end of time")
			s = s .. ": banned for " .. e.reason .. " until " .. date .. ".</li>\n"
		end
	end

	s = s .. foot

	file:write(s)
	file:close()
end
