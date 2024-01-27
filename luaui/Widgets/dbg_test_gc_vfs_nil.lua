function widget:GetInfo()
	return {
		name = "Test GC (VFS/nil)",
		desc = "-",
	}
end

local mygarbage = {}

function widget:Initialize()
	mygarbage = VFS.Include("LuaUI/Widgets/dbg_test_gc_vfs_include.lua")
end


function widget:Shutdown()
	mygarbage = nil
end
