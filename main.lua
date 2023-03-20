local data = {}
function love.load()
  data.screen = {}
  data.screen.width = love.graphics.getWidth()
  data.screen.height = love.graphics.getHeight()
  data.screen.halfW, data.screen.halfH = data.screen.width/2, data.screen.height/2
  --
  data.render = {}
  data.render.delay = 30 -- delay time for render loop 30 ms
  --
  data.player = {
    fov = 60,
    x = 2,
    y = 2,
    angle = 90,
    speed = {
      movement = 2.0,
      rotation = 100.0
    },
  }
  data.player.halfFov = data.player.fov/2
  --
  data.raycast = {}
  data.raycast.incrementAngle = data.player.fov/data.screen.width
  data.raycast.precision = 64
  --
  data.map = {
        {1,1,1,1,1,1,1,1,1,1},
        {1,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,1},
        {1,0,0,1,1,0,1,0,0,1},
        {1,0,0,1,0,0,1,0,0,1},
        {1,0,0,1,0,0,1,0,0,1},
        {1,0,0,1,0,1,1,0,0,1},
        {1,0,0,0,0,0,0,0,0,1},
        {1,0,0,0,0,0,0,0,0,1},
        {1,1,1,1,1,1,1,1,1,1},
  }
 --
 data.prevMouseX = love.mouse.getX()
end

-- function to convert degree to radians
local function degreeToRadians(degree)
  local pi = math.pi
  return degree * pi/180
end

-- raycasting function
local function rayCasting()
  local rayAngle = data.player.angle - data.player.halfFov
  for rayCount = 1, data.screen.width, 1 do
    -- ray data
    local ray = {
      x = data.player.x,
      y = data.player.y
    }
    -- ray path incrementor
    local rayCos = math.cos(degreeToRadians(rayAngle))/data.raycast.precision
    local raySin = math.sin(degreeToRadians(rayAngle))/data.raycast.precision
    -- wall finder
    local wall = 0
    while wall == 0 do
      ray.x = ray.x + rayCos
      ray.y = ray.y + raySin
      wall = data.map[math.floor(ray.y)][math.floor(ray.x)]
    end
    -- pythogoras theorem
    local distance = math.sqrt(math.pow(data.player.x - ray.x, 2) + math.pow(data.player.y - ray.y, 2))

    -- fish eye effect fix
    distance = distance * math.cos(degreeToRadians(rayAngle - data.player.angle))

    -- wall height
    local wallHeight = math.floor(data.screen.halfH/distance)

    -- draw
    love.graphics.setColor(125, 249/255, 1)
    love.graphics.line(rayCount, 0, rayCount, data.screen.halfH - wallHeight) -- sky
    love.graphics.setColor(1, 0, 0)
    love.graphics.line(rayCount, data.screen.halfH - wallHeight, rayCount, data.screen.halfH + wallHeight) -- walls
    love.graphics.setColor(0, 1, 0)
    love.graphics.line(rayCount, data.screen.halfH + wallHeight, rayCount, data.screen.height) -- ground
    love.graphics.setColor(0, 0, 0)

    -- increment
    rayAngle = rayAngle + data.raycast.incrementAngle
  end
end

-- update function
function love.update(dt)
  -- forward movement
  if love.keyboard.isDown("w") then
    local playerCos = math.cos(degreeToRadians(data.player.angle)) * data.player.speed.movement
    local playerSin = math.sin(degreeToRadians(data.player.angle)) * data.player.speed.movement
    --
    local newX = data.player.x + playerCos * dt
    local newY = data.player.y + playerSin * dt
    -- collision test
    if data.map[math.floor(newY)][math.floor(newX)] == 0 then
      data.player.x = newX
      data.player.y = newY
    end
  elseif love.keyboard.isDown("s") then
    local playerCos = math.cos(degreeToRadians(data.player.angle)) * data.player.speed.movement
    local playerSin = math.sin(degreeToRadians(data.player.angle)) * data.player.speed.movement
    --
    local newX = data.player.x - playerCos * dt
    local newY = data.player.y - playerSin * dt
    -- collision test
    if data.map[math.floor(newY)][math.floor(newX)] == 0 then
      data.player.x = newX
      data.player.y = newY
    end
  end
  -- left and right movement
  local mouseX = love.mouse.getX()
  if love.keyboard.isDown("a") or mouseX < data.prevMouseX then
    data.player.angle = data.player.angle - data.player.speed.rotation * dt
  elseif love.keyboard.isDown("d") or mouseX > data.prevMouseX then
    data.player.angle = data.player.angle + data.player.speed.rotation * dt
  end
  data.prevMouseX = mouseX
end

-- draw function
function love.draw()
  love.graphics.clear()
  rayCasting()
end


