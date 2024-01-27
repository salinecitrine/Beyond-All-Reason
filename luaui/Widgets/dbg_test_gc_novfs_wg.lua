function widget:GetInfo()
	return {
		name = "Test GC (no VFS/WG)",
		desc = "-",
	}
end

local mygarbage = {}

function widget:Initialize()
	for i = 1, 1000000 do
		mygarbage[i] = i
	end
	mygarbage[69] = os.clock()
end

function WG.make_garbo_an_upvalue()
	return mygarbage
end
