local scene = storyboard.newScene();
local physics = require("physics");
local bridge = {};

local groupBackground = display.newGroup();
local groupWorld = display.newGroup();

local config = {
	ball = {
		x = 150,
		y = 530,
		tol = 100,
	},
	target = {
		{
			partType = 'rect',
			width = 20,
			height = 200,
			x = 800,
			y = 768 - 30,
			r = 0,
		},
		{
			partType = 'rect',
			width = 20,
			height = 200,
			x = 980,
			y = 768 - 30,
			r = 0,
		},
		{
			partType = 'rect',
			width = 200,
			height = 20,
			x = 980 - 180,
			y = 768 - 250,
			r = 0,
		},

		{
			partType = 'rect',
			width = 20,
			height = 200,
			x = 800,
			y = 768 - 30 - 250,
			r = 0,
		},
		{
			partType = 'rect',
			width = 20,
			height = 200,
			x = 980,
			y = 768 - 30 - 250,
			r = 0,
		},
		{
			partType = 'rect',
			width = 200,
			height = 20,
			x = 980 - 180,
			y = 768 - 250 - 250,
			r = 0,
		},
		{
			partType = 'rect',
			width = 130,
			height = 20,
			x = 980 - 200,
			y = 768 - 260 - 50 -260,
			r = -70,
		},
		{
			partType = 'rect',
			width = 130,
			height = 20,
			x = 980 - 100,
			y = 768 - 260 - 50 -260,
			r = 70,
		},
		{
			partType = 'ball',
			radius = 20,
			x = 940,
			y = 400,
		},
		{
			partType = 'ball',
			radius = 20,
			x = 880,
			y = 360,
		},

		{
			partType = 'ball',
			radius = 20,
			x = 880,
			y = 600,
		},
		{
			partType = 'ball',
			radius = 20,
			x = 880,
			y = 200,
		},
	}
}

function scene:createScene( event )
	local group = self.view

	function createSceneInit(data)
		setupGroups();
		setupPhysics();
		createWorld();
	end

	function setupGroups()
		group:insert(groupBackground);
		group:insert(groupWorld);
	end

	function setupBackground()
		display.newRect(groupBackground,0,0,1024,768);
	end

	function setupPhysics()
		physics.start()
		physics.setGravity(0, 10)
	end

	function createWorld()
		
		createFloor();
		createWall()
		createTarget();
		createBall();

		
	end

	function createFloor()

		bridge.floor = display.newRect(0,0,1024, 20);
		bridge.floor:setFillColor(104, 61, 17);
		bridge.floor.y = display.contentHeight - 10;
		groupWorld:insert(bridge.floor);
		physics.addBody(bridge.floor, 'static', { friction=0.5, bounce=0.3 });

	end

	function createWall()

		bridge.wall = display.newRect(1024, 0, 20, 768);
		bridge.wall:setFillColor(255,255,255);
		groupWorld:insert(bridge.wall);
		physics.addBody(bridge.wall, 'static', { friction=0.5, bounce=0.3 });

	end

	function createBall()

		display.newText('+', config.ball.x-5, config.ball.y-8, native.systemFont, 12);

		bridge.ball = display.newCircle( config.ball.x, config.ball.y, 30);
		bridge.ball:setFillColor(255,0,0);
		bridge.ball.dataName = 'ball';



		--physics.addBody(bridge.ball, { friction=1, bounce=0 });		
		--bridge.ball:applyForce( 30, -10, bridge.ball.width/2,  bridge.ball.height/2)
	end

	function createTarget()

		bridge.target = {};

		for part in list_iter(config.target) do

			local obj;

			if part.partType == 'rect' then
				obj = display.newRect(part.x - 100, part.y - part.height, part.width, part.height);
				obj:setFillColor(0,0,255);
				obj.rotation = part.r;
			else
				obj = display.newCircle(part.x - 100, part.y, part.radius);
				obj:setFillColor(0,255,0);
			end
			
			obj.alpha = 1;
			obj.dataCollionCount = 0;

			physics.addBody(obj, {density=0.05, friction=1, bounce=0 });

			groupWorld:insert(obj);
			table.insert(bridge.target, obj);
		end
	end

	createSceneInit(event.params);
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view;
	
	function enterSceneInit(data)
		Runtime:addEventListener("touch", touchHandle)

		for part in list_iter(bridge.target) do

			part.collision = onCollision;
			part:addEventListener( "collision", part)

		end
	end

	function onCollision( self, event )

		if event.other.dataName == 'ball' then
			print('Collision detected '..self.dataCollionCount);
			self.dataCollionCount = self.dataCollionCount + 1;

			self.alpha = 1 - (self.dataCollionCount/5);

			if self.alpha == 0 then
				self:removeSelf()
			end
	
		end
	end

	function touchHandle( event )
	    
	    if event.phase == 'began' then
				physics.removeBody(bridge.ball);
			end

			bridge.ball.x = event.x;
	    bridge.ball.y = event.y;

	    if bridge.ball.x < config.ball.x - config.ball.tol then
	    	bridge.ball.x = config.ball.x - config.ball.tol;
	    elseif bridge.ball.x > config.ball.x + config.ball.tol then
	    	bridge.ball.x = config.ball.x + config.ball.tol;
	    end

	    if bridge.ball.y < config.ball.y - config.ball.tol then
	    	bridge.ball.y = config.ball.y - config.ball.tol;
	    elseif bridge.ball.y > config.ball.y + config.ball.tol then
	    	bridge.ball.y = config.ball.y + config.ball.tol;
	    end

	    if event.phase == 'ended' then

	    	physics.addBody(bridge.ball, {density=0.05, friction=1, bounce=0 });

	    	xForce = -(bridge.ball.x - config.ball.x) *2;
	    	yForce = -(bridge.ball.y - config.ball.y) *2;

	    	bridge.ball:applyForce(xForce, yForce, bridge.ball.contentWidth/2,bridge.ball.contentHeight/2)

	    	local dist = math.sqrt(math.pow(event.x-config.ball.x,2)+math.pow(event.y-config.ball.y,2));
		    print(dist);
		  end
	end

	enterSceneInit(event.params);
end


-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	
	function exitSceneInit()
		-- body
	end	
	
	exitSceneInit();
end


-- Called prior to the removal of scene's "view" (display group)
function scene:destroyScene( event )
	local group = self.view

	function destroySceneInit()
		-- body
	end	
	
	destroySceneInit();
	
end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

return scene;