require "LoveEasy"

function love.load()
	scene1 = Scene()

	tmp = Image("bg.jpg")
	tmp.resize(scrnWidth(),scrnHeight())
	scene1.add(1,"bg",tmp)

	tmp = Text("Flappy Bird",{font=gfx.newFont(60),col=rgba(100,150,255,98)})
	tmp.update({x=scrnWidth()/2-(tmp.pos.w/2),y=50})

	function tmp.onHover()
		tmp.update({col=rgba(255,255,255,100)})
	end

	scene1.add(2,"text",tmp)
end

function love.update()
	scene1.runEvents()
end

function love.draw()
	scene1.draw()
end
