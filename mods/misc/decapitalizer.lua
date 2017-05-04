local DECAPITALIZE_RATIO = 2/3

function chars(str)
	local function it(str, i)
		i = i + 1
		if i <= str:len() then
			return i, str:sub(i, i)
		else
			return nil
		end
	end
	return it, str, 0
end

minetest.register_on_chat_message(function(name, message)
	-- Message has to be longer than 1/DECAPITALZE_RATIO chars
	if message:len() <= 1/DECAPITALIZE_RATIO then
		return false
	end

	-- Count capital letters
	local cap_count = 0
	for _, char in chars(message) do
		if char >= "A" and char <= "Z" or char == "!" then -- If char is a capital letter
			cap_count = cap_count + 1
		end
	end

	if cap_count < message:len() * DECAPITALIZE_RATIO then
		return false
	end

	-- Decapitalize
	local new_msg = "<" .. name .. "> " .. string.char(message:byte(1)) -- The first character can be a capital letter
	local i = 2
	while i <= message:len() do
		local char = message:sub(i, i)

		if (char == "." or char == "!" or char == "?") and message:sub(i+1, i+1) == " " then
			-- Accept a capital letter after a dot followed by a space
			new_msg = new_msg .. char .. " " .. message:sub(i+2, i+2)
			i = i + 3
		else
			if char >= "A" and char <= "Z" then -- If char is a capital letter
				new_msg = new_msg .. char:lower()
			else
				new_msg = new_msg .. char
			end
			i = i + 1
		end
	end

	minetest.chat_send_player(name, "You message has been decapitalized. / Votre message a été décapitalisé.")
	minetest.chat_send_all(new_msg)
	minetest.log("action", "CHAT: " .. new_msg .. " (decapitalized from: " .. message .. ")")

	return true
end)
