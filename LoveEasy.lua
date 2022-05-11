gfx = love.graphics
mouse = love.mouse

function scrnWidth()
	return gfx.getWidth()
end

function scrnHeight()
	return gfx.getHeight()
end

function rgba(r,g,b,ap)
	-- take rgba and return it to support gfx.setColor
	local a,b,c = love.math.colorFromBytes(r,g,b)
	return {a,b,c,ap/100}
end

function rgb(r,g,b)
	return rgba(r,g,b,100)
end

function _if(a,ift,iff)
	if a then return ift else return iff end
end

function Object(prop)
	prop = _if(prop==nil,{},prop)
	prop.x = _if(prop.x==nil,0,prop.x)
	prop.y = _if(prop.y==nil,0,prop.y)
	local obj = {name=name,pos={x=prop.x,y=prop.y,w=prop.w,h=prop.h}}
	obj.click = prop.click~=nil and prop.click
	obj.hover = prop.hover~=nil and prop.hover
	obj.hidden = prop.hidden~=nil and prop.hidden
	
	function obj.update() print("update method called for object. "..obj.name) end
	function obj.draw() print("draw method called for object. "..obj.name) end
	function obj.onClick() print("onClick hookup for object. "..obj.name) end
	function obj.onHover() print("onHover hookup for object. "..obj.name) end

	return obj
end

function Text(text,o)
	local obj = Object(o)
	-- append specific properties
	obj.font = _if(o.font==nil,gfx.getFont(),o.font)
	obj.text = _if(text==nil,"",text)
	obj.col = _if(o.col==nil,rgba(255,255,255,100),o.col)

	obj.pos.w = o.font:getWidth(obj.text)
	obj.pos.h = o.font:getHeight(obj.text)
	
	-- override draw function
	function obj.draw()
		-- only update font if it is different from current font [saves memory]
		if obj.font~=gfx.getFont() then gfx.setFont(obj.font) end

		-- only draw if it is not hidden
		if obj.hidden~=true then
			gfx.setColor(obj.col)
			gfx.print(obj.text,obj.pos.x,obj.pos.y)
		end
		
		return nil
	end
	
	-- override update function
	function obj.update(o)
		if o == nil then return nil end

		obj.text = _if(o.text==nil,obj.text,o.text)
		obj.font = _if(o.font==nil,obj.font,o.font)
		o.x = _if(o.x==nil,obj.pos.x,o.x)
		o.y = _if(o.y==nil,obj.pos.y,o.y)
		obj.col = _if(o.col==nil,obj.col,o.col)
		obj.click = _if(o.click==nil,obj.click,o.click)
		obj.hover = _if(o.hover==nil,obj.hover,o.hover)
		obj.hidden = _if(o.hidden==nil,obj.hidden,o.hidden)

		obj.pos.x = o.x
		obj.pos.y = o.y
		obj.pos.w = obj.font:getWidth(obj.text)
		obj.pos.h = obj.font:getHeight(obj.text)
		
		return nil
	end

	function obj.centerX()
		obj.pos.x = scrnWidth()/2-(obj.pos.w/2)
	end

	function obj.centerY()
		obj.pos.y = scrnHeight()/2-(obj.pos.h/2)
	end

	function obj.center()
		obj.centerX()
		obj.centerY()
	end
	
	return obj
end

function Image(fname,o)
	if fname=="" or fname==nil then
		error("Filename can't be empty",2)
	end
	o = _if(o==nil,{pos={}},o)
	local r = _if(o.ratio==nil,{1,1},o.ratio)
	obj = {
		path=fname, image=gfx.newImage(fname), ratio=r, pos={x=o.x,y=o.y,w=nil,h=nil},
		rotation=0
	}

	function obj.size()
		return obj.image:getDimensions()
	end

	function obj.resize(x,y)
		local ix,iy = obj.size()
		local x = _if(x==nil,obj.ratio[1],x/ix)
		local y = _if(y==nil,obj.ratio[2],y/iy)
		obj.ratio = {x,y}
	end

	function obj.rotate(a)
		a = _if(a==nil,0,a)
		obj.rotation = a
	end

	function obj.draw()
		if not obj.hidden then
			gfx.setColor(1,1,1,1)
			gfx.draw(obj.image,obj.pos[1],obj.pos[2],obj.rotation,obj.ratio[1],obj.ratio[2])
			gfx.setColor(0,0,0,0)
		end
	end

	return obj
end

function Scene()
	scene = {hidden=false,obj={},ord={}}

	function scene.draw()
		if not scene.hidden then
			for k,v in pairs(scene.obj) do
				v.obj.draw()
				print(v.obj.pos.x)
			end
		end
	end

	function scene.update(name,prop)
		for k,v in pairs(scene.obj) do
			if v.name==name then
				v.obj.update(prop)
			end
		end
	end

	function scene.hide(tf)
		scene.hidden = tf==nil or tf
	end

	function scene.add(order,name,obj)
		if order==nil or name==nil or obj==nil then
			error("order name or obj can't be nil!",3)
		end
		scene.obj[order]={name=name,obj=obj}
	end

	function scene.remove(name)
		local i=1
		for k,v in pairs(scene.obj) do
			if v.name==name then
				scene.obj[k]=nil
				return true
			end
		end
		return false
	end

	function scene.removeByOrder(order)
		scene.obj[order]=nil
	end

	function scene.getObj(name)
		for k,v in pairs(scene.obj) do
			if v.name==name then
				return v.obj
			end
		end
	end

	function scene.runEvents()
		for k,v in pairs(scene.obj) do
			local px = mouse.getX()
			local py = mouse.getY()
			local x = v.obj.pos.x
			local y = v.obj.pos.y
			local w = v.obj.pos.w
			local h = v.obj.pos.h
			if x==nil then return nil end
			if (px>=x and px<=x+w and py>=y and py<=py+h) then
				v.hover = true
				if mouse.isDown(1) then
					v.click = true
					v.onClick()
				else
					v.onHover()
				end
			else
				print("LL")
				v.hover = false
			end
		end
	end

	return scene
end

function Shape(type,attribs)
	
end