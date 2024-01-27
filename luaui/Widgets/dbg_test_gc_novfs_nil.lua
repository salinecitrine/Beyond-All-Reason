function widget:GetInfo()
	return {
		name = "Test GC (no VFS/nil)",
		desc = "-",
	}
end

local mygarbage = {}

function widget:Initialize()
	for i = 1, 1000000 do
		mygarbage[i] = i
	end
end

function widget:Shutdown()
	mygarbage = nil
end
