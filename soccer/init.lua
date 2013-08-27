

local BALL_PUSH_CHECK_INTERVAL = 0.1

minetest.register_entity("soccer:ball", {
	physical = true,
	visual = "mesh",
	mesh = "soccer_ball.x",
	hp_max = 1000,
	groups = { immortal = true },
	textures = { "soccer_ball.png" },
	collisionbox = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 },
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer >= BALL_PUSH_CHECK_INTERVAL then
			self.object:setacceleration({x=0, y=-10, z=0})
			self.timer = 0
			local vel = self.object:getvelocity()
			local p = self.object:getpos();
			p.y = p.y - 0.5
			if minetest.registered_nodes[minetest.env:get_node(p).name].walkable then
				vel.x = vel.x * 0.85
				if vel.y < 0 then vel.y = vel.y * -0.65 end
				vel.z = vel.z * 0.90
			end
			if  (math.abs(vel.x) < 0.1)
			 and (math.abs(vel.z) < 0.1) then
				vel.x = 0
				vel.z = 0
			end
			self.object:setvelocity(vel)
			local pos = self.object:getpos()
			local objs = minetest.env:get_objects_inside_radius(pos, 1)
			local player_count = 0
			local final_dir = { x=0, y=0, z=0 }
			for _,obj in ipairs(objs) do
				if obj:is_player() then
					local objdir = obj:get_look_dir()
					local mul = 1
					if (obj:get_player_control().sneak) then
						mul = 3
					end
					final_dir.x = final_dir.x + (objdir.x * mul)
					final_dir.y = final_dir.y + (objdir.y * mul)
					final_dir.z = final_dir.z + (objdir.z * mul)
					player_count = player_count + 1
				end
			end
			if final_dir.x ~= 0 or final_dir.y ~= 0 or final_dir.z ~= 0 then
				final_dir.x = (final_dir.x * 5) / player_count
				final_dir.y = (final_dir.y * 5) / player_count
				final_dir.z = (final_dir.z * 5) / player_count
				self.object:setvelocity(final_dir)
			end
		end
	end,
	on_punch = function(self, puncher)
		if puncher and puncher:is_player() then
			local inv = puncher:get_inventory()
			inv:add_item("main", ItemStack("soccer:ball_item"))
			self.object:remove()
		end
	end,
	is_moving = function(self)
		local v = self.object:getvelocity()
		if  (math.abs(v.x) <= 0.1)
		 and (math.abs(v.z) <= 0.1) then
			v.x = 0
			v.z = 0
			self.object:setvelocity(v)
			return false
		end
		return true
	end,
	timer = 0,
})

minetest.register_craftitem("soccer:ball_item", {
	description = "Soccer Ball",
	inventory_image = "soccer_ball_inv.png",
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		--pos = { x=pos.x+0.5, y=pos.y, z=pos.z+0.5 }
		local ent = minetest.env:add_entity(pos, "soccer:ball")
		ent:setvelocity({x=0, y=-15, z=0})
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_node("soccer:goal", {
	description = "Soccer Goal",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = { "soccer_white.png" },
	sunlight_propagates = true,
	groups = { snappy=1, cracky=1, fleshy=1, oddly_breakable_by_hand=1 },
	node_box = {
		type = "fixed",
		fixed = {
			{ -2.5, -0.5, -0.1, -2.3, 1.5, 0.1 },
			{  2.3, -0.5, -0.1,  2.5, 1.5, 0.1 },
			{ -2.5,  1.5, -0.1,  2.5, 1.7, 0.1 },
		},
	},
})

local nb_decal = {
	type = "fixed",
	fixed = {{ -0.5, -0.5, -0.5, 0.5, -0.499, 0.5 }},
},

minetest.register_node("soccer:goal_mark", {
	description = "Soccer Goal Mark",
	drawtype = "nodebox",
	paramtype = "light",
	node_box = nb_decal,
	walkable = false,
	inventory_image = "soccer_goal_mark.png",
	tiles = { "soccer_goal_mark.png" },
	sunlight_propagates = true,
	groups = { snappy=1, cracky=1, fleshy=1, oddly_breakable_by_hand=1 },
})

local function reg_decal(name, desc)
	texture = "soccer_"..name..".png"
	minetest.register_node("soccer:"..name, {
		description = desc,
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = nb_decal,
		walkable = false,
		inventory_image = texture,
		wield_image = texture,
		tiles = { texture },
		sunlight_propagates = true,
		groups = { snappy=1, cracky=1, fleshy=1, oddly_breakable_by_hand=1 },
	})
end

reg_decal("line_i", "Straight Line")
reg_decal("line_l", "L line")
reg_decal("line_t", "T Line")
reg_decal("line_p", "+ Line")
reg_decal("line_d", "Diagonal Line")
reg_decal("line_point", "Point")
reg_decal("line_corner", "Corner")

minetest.register_craft({
	output = "soccer:ball_item",
	recipe = {
		{ "", "wool:white", "" },
		{ "wool:white", "default:coal_lump", "wool:white" },
		{ "", "wool:white", "" },
	},
})

minetest.register_alias("ball", "soccer:ball_item")


-- Green 

local GREEN_BALL_PUSH_CHECK_INTERVAL = 0.2

minetest.register_entity("soccer:green_ball", {
	physical = true,
	visual = "mesh",
	mesh = "soccer_ball.x",
	hp_max = 1000,
	groups = { immortal = true },
	textures = { "green_soccer_ball.png" },
	collisionbox = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 },
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer >= GREEN_BALL_PUSH_CHECK_INTERVAL then
			self.object:setacceleration({x=0, y=-math.random(0,150), z=0})
			self.timer = 0
			local vel = self.object:getvelocity()
			local p = self.object:getpos();
			p.y = p.y - 0.5
			if minetest.registered_nodes[minetest.env:get_node(p).name].walkable then
				vel.x = vel.x * math.random(0,2)
				if vel.y < 0 then vel.y = vel.y * -0.1 end
				vel.z = vel.z * math.random(0,2)
			end
			if  (math.abs(vel.x) < 0.9)
			 and (math.abs(vel.z) < 0.9) then
				vel.x = 0
				vel.z = 0
			end
			self.object:setvelocity(vel)
			local pos = self.object:getpos()
			local objs = minetest.env:get_objects_inside_radius(pos, 1)
			local player_count = 0
			local final_dir = { x=0, y=0, z=0 }
			for _,obj in ipairs(objs) do
				if obj:is_player() then
					local objdir = obj:get_look_dir()
					local mul = 1
					if (obj:get_player_control().sneak) then
						mul = 3
					end
					final_dir.x = final_dir.x + (objdir.x * mul)
					final_dir.y = final_dir.y + (objdir.y * mul)
					final_dir.z = final_dir.z + (objdir.z * mul)
					player_count = player_count + 1
				end
			end
			if final_dir.x ~= 0 or final_dir.y ~= 0 or final_dir.z ~= 0 then
				final_dir.x = (final_dir.x * 5) / player_count
				final_dir.y = (final_dir.y * 5) / player_count
				final_dir.z = (final_dir.z * 5) / player_count
				self.object:setvelocity(final_dir)
			end
		end
	end,
	on_punch = function(self, puncher)
		if puncher and puncher:is_player() then
			local inv = puncher:get_inventory()
			inv:add_item("main", ItemStack("soccer:green_ball_item"))
			self.object:remove()
		end
	end,
	is_moving = function(self)
		local v = self.object:getvelocity()
		if  (math.abs(v.x) <= 0.5)
		 and (math.abs(v.z) <= 0.5) then
			v.x = 0
			v.z = 0
			self.object:setvelocity(v)
			return false
		end
		return true
	end,
	timer = 0,
})

minetest.register_craftitem("soccer:green_ball_item", {
	description = "WTF Green Soccer Ball",
	inventory_image = "green_soccer_ball_inv.png",
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		--pos = { x=pos.x+0.5, y=pos.y, z=pos.z+0.5 }
		local ent = minetest.env:add_entity(pos, "soccer:green_ball")
		ent:setvelocity({x=0, y=-math.random(0,50), z=0})
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "soccer:green_ball_item",
	recipe = {
		{ "", "wool:green", "" },
		{ "wool:green", "default:coal_lump", "wool:green" },
		{ "", "wool:green", "" },
	},
})

minetest.register_alias("ball", "soccer:green_ball_item")


-- Red 

local RED_BALL_PUSH_CHECK_INTERVAL = 0.1

minetest.register_entity("soccer:red_ball", {
	physical = true,
	visual = "mesh",
	mesh = "soccer_ball.x",
	hp_max = 1000,
	groups = { immortal = true },
	textures = { "red_soccer_ball.png" },
	collisionbox = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 },
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer >= RED_BALL_PUSH_CHECK_INTERVAL then
			self.object:setacceleration({x=0, y=-200, z=0})
			self.timer = 0
			local vel = self.object:getvelocity()
			local p = self.object:getpos();
			p.y = p.y - 0.55
			if minetest.registered_nodes[minetest.env:get_node(p).name].walkable then
				vel.x = vel.x * 2
				if vel.y < 0 then vel.y = vel.y * -0.50 end
				vel.z = vel.z * 2
			end
			if  (math.abs(vel.x) < 0.8)
			 and (math.abs(vel.z) < 0.8) then
				vel.x = 0
				vel.z = 0
			end
			self.object:setvelocity(vel)
			local pos = self.object:getpos()
			local objs = minetest.env:get_objects_inside_radius(pos, 1)
			local player_count = 0
			local final_dir = { x=0, y=0, z=0 }
			for _,obj in ipairs(objs) do
				if obj:is_player() then
					local objdir = obj:get_look_dir()
					local mul = 1
					if (obj:get_player_control().sneak) then
						mul = 3
					end
					final_dir.x = final_dir.x + (objdir.x * mul)
					final_dir.y = final_dir.y + (objdir.y * mul)
					final_dir.z = final_dir.z + (objdir.z * mul)
					player_count = player_count + 1
				end
			end
			if final_dir.x ~= 0 or final_dir.y ~= 0 or final_dir.z ~= 0 then
				final_dir.x = (final_dir.x * 5) / player_count
				final_dir.y = (final_dir.y * 5) / player_count
				final_dir.z = (final_dir.z * 5) / player_count
				self.object:setvelocity(final_dir)
			end
		end
	end,
	on_punch = function(self, puncher)
		if puncher and puncher:is_player() then
			local inv = puncher:get_inventory()
			inv:add_item("main", ItemStack("soccer:red_ball_item"))
			self.object:remove()
		end
	end,
	is_moving = function(self)
		local v = self.object:getvelocity()
		if  (math.abs(v.x) <= 0.35)
		 and (math.abs(v.z) <= 0.35) then
			v.x = 0
			v.z = 0
			self.object:setvelocity(v)
			return false
		end
		return true
	end,
	timer = 0,
})

minetest.register_craftitem("soccer:red_ball_item", {
	description = "Powerade Red Soccer Ball",
	inventory_image = "red_soccer_ball_inv.png",
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		--pos = { x=pos.x+0.5, y=pos.y, z=pos.z+0.5 }
		local ent = minetest.env:add_entity(pos, "soccer:red_ball")
		ent:setvelocity({x=0, y=-math.random(0,50), z=0})
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "soccer:red_ball_item",
	recipe = {
		{ "", "wool:red", "" },
		{ "wool:red", "default:coal_lump", "wool:red" },
		{ "", "wool:red", "" },
	},
})

minetest.register_alias("ball", "soccer:red_ball_item")

-- Blue

local BLUE_BALL_PUSH_CHECK_INTERVAL = 0.3

minetest.register_entity("soccer:blue_ball", {
	physical = true,
	visual = "mesh",
	mesh = "soccer_ball.x",
	hp_max = 1000,
	groups = { immortal = true },
	textures = { "blue_soccer_ball.png" },
	collisionbox = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 },
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer >= BLUE_BALL_PUSH_CHECK_INTERVAL then
			self.object:setacceleration({x=0.2, y=-90, z=0.1})
			self.timer = 0
			local vel = self.object:getvelocity()
			local p = self.object:getpos();
			p.y = p.y - 0.55
			if minetest.registered_nodes[minetest.env:get_node(p).name].walkable then
				vel.x = vel.x * 0.90
				if vel.y < 0 then vel.y = vel.y * -0.60 end
				vel.z = vel.z * 0.90
			end
			if  (math.abs(vel.x) < 0.8)
			 and (math.abs(vel.z) < 0.8) then
				vel.x = 0
				vel.z = 0
			end
			self.object:setvelocity(vel)
			local pos = self.object:getpos()
			local objs = minetest.env:get_objects_inside_radius(pos, 1)
			local player_count = 0
			local final_dir = { x=0, y=0, z=0 }
			for _,obj in ipairs(objs) do
				if obj:is_player() then
					local objdir = obj:get_look_dir()
					local mul = 1
					if (obj:get_player_control().sneak) then
						mul = 3
					end
					final_dir.x = final_dir.x + (objdir.x * mul)
					final_dir.y = final_dir.y + (objdir.y * mul)
					final_dir.z = final_dir.z + (objdir.z * mul)
					player_count = player_count + 1
				end
			end
			if final_dir.x ~= 0 or final_dir.y ~= 0 or final_dir.z ~= 0 then
				final_dir.x = (final_dir.x * 5) / player_count
				final_dir.y = (final_dir.y * 5) / player_count
				final_dir.z = (final_dir.z * 5) / player_count
				self.object:setvelocity(final_dir)
			end
		end
	end,
	on_punch = function(self, puncher)
		if puncher and puncher:is_player() then
			local inv = puncher:get_inventory()
			inv:add_item("main", ItemStack("soccer:blue_ball_item"))
			self.object:remove()
		end
	end,
	is_moving = function(self)
		local v = self.object:getvelocity()
		if  (math.abs(v.x) <= 0.35)
		 and (math.abs(v.z) <= 0.35) then
			v.x = 0
			v.z = 0
			self.object:setvelocity(v)
			return false
		end
		return true
	end,
	timer = 0,
})

minetest.register_craftitem("soccer:blue_ball_item", {
	description = "Ice Blue Soccer Ball",
	inventory_image = "blue_soccer_ball_inv.png",
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		--pos = { x=pos.x+0.5, y=pos.y, z=pos.z+0.5 }
		local ent = minetest.env:add_entity(pos, "soccer:blue_ball")
		ent:setvelocity({x=0.1, y=-5, z=0.2})
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "soccer:blue_ball_item",
	recipe = {
		{ "", "wool:blue", "" },
		{ "wool:blue", "default:coal_lump", "wool:blue" },
		{ "", "wool:blue", "" },
	},
})

minetest.register_alias("ball", "soccer:blue_ball_item")

-- Yellow

local YELLOW_BALL_PUSH_CHECK_INTERVAL = 0.5

minetest.register_entity("soccer:yellow_ball", {
	physical = true,
	visual = "mesh",
	mesh = "soccer_ball.x",
	hp_max = 1000,
	groups = { immortal = true },
	textures = { "yellow_soccer_ball.png" },
	collisionbox = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 },
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer >= YELLOW_BALL_PUSH_CHECK_INTERVAL then
			self.object:setacceleration({x=0.2, y=-90, z=0.1})
			self.timer = 0
			local vel = self.object:getvelocity()
			local p = self.object:getpos();
			p.y = p.y - 0.55
			if minetest.registered_nodes[minetest.env:get_node(p).name].walkable then
				vel.x = vel.x * 2.5
				if vel.y < 2 then vel.y = vel.y * -0.55 end
				vel.z = vel.z * 2.5
			end
			if  (math.abs(vel.x) < 0.8)
			 and (math.abs(vel.z) < 0.8) then
				vel.x = 0
				vel.z = 0
			end
			self.object:setvelocity(vel)
			local pos = self.object:getpos()
			local objs = minetest.env:get_objects_inside_radius(pos, 1)
			local player_count = 0
			local final_dir = { x=0, y=0, z=0 }
			for _,obj in ipairs(objs) do
				if obj:is_player() then
					local objdir = obj:get_look_dir()
					local mul = 1
					if (obj:get_player_control().sneak) then
						mul = 3
					end
					final_dir.x = final_dir.x + (objdir.x * mul)
					final_dir.y = final_dir.y + (objdir.y * mul)
					final_dir.z = final_dir.z + (objdir.z * mul)
					player_count = player_count + 1
				end
			end
			if final_dir.x ~= 0 or final_dir.y ~= 0 or final_dir.z ~= 0 then
				final_dir.x = (final_dir.x * 5) / player_count
				final_dir.y = (final_dir.y * 5) / player_count
				final_dir.z = (final_dir.z * 5) / player_count
				self.object:setvelocity(final_dir)
			end
		end
	end,
	on_punch = function(self, puncher)
		if puncher and puncher:is_player() then
			local inv = puncher:get_inventory()
			inv:add_item("main", ItemStack("soccer:yellow_ball_item"))
			self.object:remove()
		end
	end,
	is_moving = function(self)
		local v = self.object:getvelocity()
		if  (math.abs(v.x) <= 0.35)
		 and (math.abs(v.z) <= 0.35) then
			v.x = 0
			v.z = 0
			self.object:setvelocity(v)
			return false
		end
		return true
	end,
	timer = 0,
})

minetest.register_craftitem("soccer:yellow_ball_item", {
	description = "Sun Yellow Soccer Ball",
	inventory_image = "yellow_soccer_ball_inv.png",
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		--pos = { x=pos.x+0.5, y=pos.y, z=pos.z+0.5 }
		local ent = minetest.env:add_entity(pos, "soccer:yellow_ball")
		ent:setvelocity({x=0.1, y=-5, z=0.2})
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craft({
	output = "soccer:yellow_ball_item",
	recipe = {
		{ "", "wool:yellow", "" },
		{ "wool:yellow", "default:coal_lump", "wool:yellow" },
		{ "", "wool:yellow", "" },
	},
})

minetest.register_alias("ball", "soccer:yellow_ball_item")


-- Purple 

local PURPLE_BALL_PUSH_CHECK_INTERVAL = 0.1

minetest.register_entity("soccer:purple_ball", {
	physical = true,
	visual = "mesh",
	mesh = "soccer_ball.x",
	hp_max = 1000,
	groups = { immortal = true },
	textures = { "purple_soccer_ball.png" },
	collisionbox = { -0.2, -0.2, -0.2, 0.2, 0.2, 0.2 },
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer >= PURPLE_BALL_PUSH_CHECK_INTERVAL then
			self.object:setacceleration({x=0, y=-20, z=0})
			self.timer = 0
			local vel = self.object:getvelocity()
			local p = self.object:getpos();
			p.y = p.y - 1
			if minetest.registered_nodes[minetest.env:get_node(p).name].walkable then
				vel.x = vel.x * 0.90
				if vel.y < 0 then vel.y = vel.y * -0.60 end
				vel.z = vel.z * 0.95
			end
			if  (math.abs(vel.x) < 0.2)
			 and (math.abs(vel.z) < 0.2) then
				vel.x = 0
				vel.z = 0
			end
			self.object:setvelocity(vel)
			local pos = self.object:getpos()
			local objs = minetest.env:get_objects_inside_radius(pos, 1)
			local player_count = 0
			local final_dir = { x=0, y=0, z=0 }
			for _,obj in ipairs(objs) do
				if obj:is_player() then
					local objdir = obj:get_look_dir()
					local mul = 1
					if (obj:get_player_control().sneak) then
						mul = 3
					end
					final_dir.x = final_dir.x + (objdir.x * mul)
					final_dir.y = final_dir.y + (objdir.y * mul)
					final_dir.z = final_dir.z + (objdir.z * mul)
					player_count = player_count + 1
				end
			end
			if final_dir.x ~= 0 or final_dir.y ~= 0 or final_dir.z ~= 0 then
				final_dir.x = (final_dir.x * 5) / player_count
				final_dir.y = (final_dir.y * 5) / player_count
				final_dir.z = (final_dir.z * 5) / player_count
				self.object:setvelocity(final_dir)
			end
		end
	end,
	on_punch = function(self, puncher)
		if puncher and puncher:is_player() then
			local inv = puncher:get_inventory()
			inv:add_item("main", ItemStack("soccer:purple_ball_item"))
			self.object:remove()
		end
	end,
	is_moving = function(self)
		local v = self.object:getvelocity()
		if  (math.abs(v.x) <= 0.3)
		 and (math.abs(v.z) <= 0.3) then
			v.x = 0
			v.z = 0
			self.object:setvelocity(v)
			return false
		end
		return true
	end,
	timer = 0,
})

minetest.register_craftitem("soccer:purple_ball_item", {
	description = "Girl Purple Soccer Ball",
	inventory_image = "purple_soccer_ball_inv.png",
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		--pos = { x=pos.x+0.5, y=pos.y, z=pos.z+0.5 }
		local ent = minetest.env:add_entity(pos, "soccer:purple_ball")
		ent:setvelocity({x=0, y=-45, z=0})
		itemstack:take_item()
		return itemstack
	end,
})


minetest.register_craft({
	output = "soccer:purple_ball_item",
	recipe = {
		{ "", "wool:magenta", "" },
		{ "wool:violet", "default:coal_lump", "wool:violet" },
		{ "", "wool:magenta", "" },
	},
})

minetest.register_alias("ball", "soccer:purple_ball_item")


