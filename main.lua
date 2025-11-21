-- Pong Game for Love2D
-- Simple two-player Pong game with Steam integration

-- Steam integration
local steam = require("steam_integration")

-- Game constants
local PADDLE_WIDTH = 20
local PADDLE_HEIGHT = 100
local PADDLE_SPEED = 300
local BALL_SIZE = 15
local BALL_SPEED = 400

-- Game state
local player1 = {
    x = 50,
    y = 300,
    score = 0
}

local player2 = {
    x = 1150,
    y = 300,
    score = 0
}

local ball = {
    x = 600,
    y = 400,
    vx = BALL_SPEED,
    vy = BALL_SPEED
}

local gameState = "playing" -- "playing" or "paused"
local lastScoreTime = 0 -- Track time since last score for win detection

-- Initialize game
function love.load()
    love.window.setTitle("Pong")
    love.window.setMode(1200, 800)
    
    -- Initialize Steam (non-blocking - game works without Steam)
    steam.init()
    
    -- Set initial ball direction (random)
    local angle = math.random() * math.pi / 3 - math.pi / 6 -- -30 to 30 degrees
    ball.vx = BALL_SPEED * math.cos(angle)
    ball.vy = BALL_SPEED * math.sin(angle)
    
    -- Randomize initial direction
    if math.random() > 0.5 then
        ball.vx = -ball.vx
    end
    
    -- Update Steam rich presence
    steam.updateRichPresence(gameState, player1.score, player2.score)
end

-- Update game state
function love.update(dt)
    -- Update Steam callbacks (important - must be called regularly)
    steam.update()
    
    if gameState == "paused" then
        -- Update rich presence even when paused
        steam.updateRichPresence(gameState, player1.score, player2.score)
        return
    end
    
    lastScoreTime = lastScoreTime + dt
    
    -- Player 1 controls (W/S keys)
    if love.keyboard.isDown("w") then
        player1.y = math.max(0, player1.y - PADDLE_SPEED * dt)
    elseif love.keyboard.isDown("s") then
        player1.y = math.min(800 - PADDLE_HEIGHT, player1.y + PADDLE_SPEED * dt)
    end
    
    -- Player 2 controls (Up/Down arrow keys)
    if love.keyboard.isDown("up") then
        player2.y = math.max(0, player2.y - PADDLE_SPEED * dt)
    elseif love.keyboard.isDown("down") then
        player2.y = math.min(800 - PADDLE_HEIGHT, player2.y + PADDLE_SPEED * dt)
    end
    
    -- Update ball position
    ball.x = ball.x + ball.vx * dt
    ball.y = ball.y + ball.vy * dt
    
    -- Ball collision with top and bottom walls
    if ball.y <= 0 or ball.y >= 800 - BALL_SIZE then
        ball.vy = -ball.vy
        ball.y = math.max(0, math.min(800 - BALL_SIZE, ball.y))
    end
    
    -- Ball collision with paddles
    -- Player 1 paddle (left)
    if ball.x <= player1.x + PADDLE_WIDTH and
       ball.x >= player1.x and
       ball.y + BALL_SIZE >= player1.y and
       ball.y <= player1.y + PADDLE_HEIGHT then
        ball.vx = math.abs(ball.vx) -- Ensure ball goes right
        -- Add some spin based on where ball hits paddle
        local hitPos = (ball.y + BALL_SIZE / 2 - player1.y) / PADDLE_HEIGHT
        ball.vy = (hitPos - 0.5) * BALL_SPEED * 1.5
        ball.x = player1.x + PADDLE_WIDTH
        
        -- Track paddle hit for Steam stats
        steam.onPaddleHit()
    end
    
    -- Player 2 paddle (right)
    if ball.x + BALL_SIZE >= player2.x and
       ball.x <= player2.x + PADDLE_WIDTH and
       ball.y + BALL_SIZE >= player2.y and
       ball.y <= player2.y + PADDLE_HEIGHT then
        ball.vx = -math.abs(ball.vx) -- Ensure ball goes left
        -- Add some spin based on where ball hits paddle
        local hitPos = (ball.y + BALL_SIZE / 2 - player2.y) / PADDLE_HEIGHT
        ball.vy = (hitPos - 0.5) * BALL_SPEED * 1.5
        ball.x = player2.x - BALL_SIZE
        
        -- Track paddle hit for Steam stats
        steam.onPaddleHit()
    end
    
    -- Score points
    if ball.x < 0 then
        player2.score = player2.score + 1
        -- Track scoring for Steam
        steam.onScore(2, player2.score)
        lastScoreTime = 0
        resetBall()
        
        -- Check for game win (simple: first to 10 points)
        if player2.score >= 10 then
            steam.onGameWin(player2.score, player1.score)
        end
    elseif ball.x > 1200 then
        player1.score = player1.score + 1
        -- Track scoring for Steam
        steam.onScore(1, player1.score)
        lastScoreTime = 0
        resetBall()
        
        -- Check for game win (simple: first to 10 points)
        if player1.score >= 10 then
            steam.onGameWin(player1.score, player2.score)
        end
    end
    
    -- Update Steam rich presence with current scores
    steam.updateRichPresence(gameState, player1.score, player2.score)
end

-- Reset ball to center
function resetBall()
    ball.x = 600
    ball.y = 400
    local angle = math.random() * math.pi / 3 - math.pi / 6
    ball.vx = BALL_SPEED * math.cos(angle)
    ball.vy = BALL_SPEED * math.sin(angle)
    if math.random() > 0.5 then
        ball.vx = -ball.vx
    end
end

-- Draw game
function love.draw()
    -- Draw background
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, 1200, 800)
    
    -- Draw center line
    love.graphics.setColor(0.3, 0.3, 0.3)
    for i = 0, 800, 40 do
        love.graphics.rectangle("fill", 595, i, 10, 20)
    end
    
    -- Draw paddles
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", player1.x, player1.y, PADDLE_WIDTH, PADDLE_HEIGHT)
    love.graphics.rectangle("fill", player2.x, player2.y, PADDLE_WIDTH, PADDLE_HEIGHT)
    
    -- Draw ball
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", ball.x, ball.y, BALL_SIZE, BALL_SIZE)
    
    -- Draw scores
    love.graphics.setFont(love.graphics.newFont(48))
    love.graphics.print(player1.score, 400, 50)
    love.graphics.print(player2.score, 700, 50)
    
    -- Draw instructions
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print("Player 1: W/S", 50, 50)
    love.graphics.print("Player 2: Up/Down", 50, 70)
    love.graphics.print("Pause: Space", 50, 90)
    
    -- Draw Steam status indicator
    if steam.isInitialized() then
        love.graphics.setColor(0.2, 0.6, 1.0) -- Steam blue
        love.graphics.print("Steam", 1100, 10)
        
        -- Show Steam username if available
        local username = steam.getUsername()
        if username then
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.setFont(love.graphics.newFont(12))
            love.graphics.print(username, 1100, 30)
        end
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.print("Steam: Offline", 1100, 10)
    end
    
    -- Draw pause message
    if gameState == "paused" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(32))
        love.graphics.printf("PAUSED", 0, 350, 1200, "center")
    end
end

-- Handle keyboard input
function love.keypressed(key)
    if key == "space" then
        if gameState == "playing" then
            gameState = "paused"
        else
            gameState = "playing"
        end
        -- Update rich presence when pausing/unpausing
        steam.updateRichPresence(gameState, player1.score, player2.score)
    elseif key == "escape" then
        love.event.quit()
    end
end

-- Shutdown Steam when quitting
function love.quit()
    steam.shutdown()
end

