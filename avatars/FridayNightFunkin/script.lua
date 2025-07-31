

local notes = {

}
local unspawnnedNotes = {}
local pressedSus = {}

local curTime = 0

models:setPos(0, 30, -10)

local inst = nil

local isSongStarted = false
local songMaxTime = 0 

local chartJS = {}

local time = 0
local prevTime = 0

local leftKey = keybinds:newKeybind("Left"):setKey("key.keyboard.left")
local downKey = keybinds:newKeybind("Down"):setKey("key.keyboard.down")
local upKey = keybinds:newKeybind("Up"):setKey("key.keyboard.up")
local rightKey = keybinds:newKeybind("Right"):setKey("key.keyboard.right")

local scoreText = nil
local ratingText = nil

local totalNotes = 0
local totalPressed = 0

local misses = 0

local score = 0

local combo = 0

local oldOpacity = 0

local animTimer = 0

function checkKey(keyDir)
    if keyDir == 0 then
      animations.fn.pressLeft:stop()
      animations.fn.pressEndLeft:stop()
      animations.fn.pressLeft:play()
    elseif keyDir == 1 then
      animations.fn.pressDown:stop()
      animations.fn.pressEndDown:stop()
      animations.fn.pressDown:play()
    elseif keyDir == 2 then
      animations.fn.pressUp:stop()
      animations.fn.pressEndUp:stop()
      animations.fn.pressUp:play()
    elseif keyDir == 3 then
      animations.fn.pressRight:stop()
      animations.fn.pressEndRight:stop()
      animations.fn.pressRight:play()
    end

    for i,v in ipairs(notes) do
      local distance = ( 0.15 * (v[2] - (curTime))) * 0.5

      if keyDir == v[3] and judgeNote(v[2] - (curTime)) ~= "none" then
        totalNotes = totalNotes + 1
        popUpScore(judgeNote(v[2] - (curTime)))
        combo = combo + 1
        score = score + 250
        updateScore()

        if v[4].hasSus == true then
          table.insert(pressedSus, v[4])
        end

        if v[3] == 0 then
          local strumTarget = models.fn.strums.leftST
          setStrumCode(strumTarget, 1, 0.5, 0.65)
        elseif v[3] == 1 then
          local strumTarget = models.fn.strums.downST
          setStrumCode(strumTarget, 0.65, 0.65, 1)
        elseif v[3] == 2 then
          local strumTarget = models.fn.strums.upST
          setStrumCode(strumTarget, 0.5, 1, 0.5)
        elseif v[3] == 3 then
          local strumTarget = models.fn.strums.rightST
          setStrumCode(strumTarget, 1, 0.5, 0.5)
        end
        if v[4].hasSus == false then
          animTimer = 15
        else
  
          animTimer = 5 + math.ceil(v[4].susLen / 1000 * 20)
        end
        playCharAnim(v[3])
        playStrumConfirmAnim(v[3])

        models.fn.notes:removeChild(v[1])
        table.remove(notes,i)
        break
      end
    end
end

function playCharAnim(dir)
    animations.bf_anims.idle:stop()
    animations.bf_anims.left:stop()
    animations.bf_anims.down:stop()
    animations.bf_anims.up:stop()
    animations.bf_anims.right:stop()

    if dir == 0 then
      animations.bf_anims.left:play()
    elseif dir == 1 then
      animations.bf_anims.down:play()
    elseif dir == 2 then
      animations.bf_anims.up:play()
    elseif dir == 3 then
      animations.bf_anims.right:play()
    end 
end

function setStrumCode(model,color1,color2,color3)
  local strumTarget = model

  strumTarget.cube1:setColor(color1, color2, color3)
  strumTarget.cube2:setColor(color1, color2, color3)
  strumTarget.cube3:setColor(color1, color2, color3)
  strumTarget.cube4:setColor(color1, color2, color3)
end

function playStrumConfirmAnim(dir)
  animations.fn.pressLeft:stop()
  animations.fn.pressEndLeft:stop()
  animations.fn.pressDown:stop()
  animations.fn.pressEndDown:stop()
  animations.fn.pressUp:stop()
  animations.fn.pressEndUp:stop()
  animations.fn.pressRight:stop()
  animations.fn.pressEndRight:stop()

  animations.fn.leftConfirm:stop()
  animations.fn.downConfirm:stop()
  animations.fn.upConfirm:stop()
  animations.fn.rightConfirm:stop()

  if dir == 0 then
    animations.fn.leftConfirm:play()
  elseif dir == 1 then
    animations.fn.downConfirm:play()
  elseif dir == 2 then
    animations.fn.upConfirm:play()
  elseif dir == 3 then
    animations.fn.rightConfirm:play()
  end
end

function pings.leftPress()
  local strumTarget = models.fn.strums.leftST

  setStrumCode(strumTarget, 0.5, 0.5, 0.5)

  checkKey(0)
end

function pings.downPress()
  local strumTarget = models.fn.strums.downST

  setStrumCode(strumTarget, 0.5, 0.5, 0.5)

  checkKey(1)
end

function pings.upPress()
  local strumTarget = models.fn.strums.upST

  setStrumCode(strumTarget, 0.5, 0.5, 0.5)

  checkKey(2)
end

function pings.rightPress()
  local strumTarget = models.fn.strums.rightST

  setStrumCode(strumTarget, 0.5, 0.5, 0.5)

  checkKey(3)
end

function pings.relLeft()
    animations.fn.pressLeft:stop()
    animations.fn.pressEndLeft:stop()
    animations.fn.leftConfirm:stop()
    animations.fn.pressEndLeft:play()
    
    local strumTarget = models.fn.strums.leftST

    setStrumCode(strumTarget, 1, 1, 1)
end

function pings.relDown()
    animations.fn.pressDown:stop()
    animations.fn.pressEndDown:stop()
    animations.fn.downConfirm:stop()
    animations.fn.pressEndDown:play()
    
    local strumTarget = models.fn.strums.downST
    
    setStrumCode(strumTarget, 1, 1, 1)
end

function pings.relUp()
    animations.fn.pressUp:stop()
    animations.fn.pressEndUp:stop()
    animations.fn.upConfirm:stop()
    animations.fn.pressEndUp:play()

    local strumTarget = models.fn.strums.upST
    
    setStrumCode(strumTarget, 1, 1, 1)
end

function pings.relRight()
    animations.fn.pressRight:stop()
    animations.fn.pressEndRight:stop()
    animations.fn.rightConfirm:stop()
    animations.fn.pressEndRight:play()

    local strumTarget = models.fn.strums.rightST
    
    setStrumCode(strumTarget, 1, 1, 1)
end

local mainPage = action_wheel:newPage("Main")
action_wheel:setPage(mainPage)

local exitSong = mainPage:newAction()
exitSong:setTitle("Stop Song")
exitSong:setItem("minecraft:barrier")
exitSong.leftClick = function (self)
  stopSong()
end

local mods = {}

for i,v in ipairs(file:list("FNF/")) do
  local modPageData = parseJson(file:readString("FNF/"..v.."/config.data"))
  local modPage = action_wheel:newPage(v)
  local pageSec = mainPage:newAction()
  pageSec:setItem(modPageData.icon)
  pageSec:setTitle(v)
  pageSec.leftClick = function (self)
    action_wheel:setPage(modPage)
  end

  local back = modPage:newAction()
  back:setItem("minecraft:barrier")
  back:setTitle("< Back")
  back.leftClick = function (self)
    action_wheel:setPage(mainPage)
  end

  table.insert(mods, {
    page = modPage,
    pageSec = pageSec
  })

  for is,vs in ipairs(file:list("FNF/"..v.."/")) do
    if string.find(vs, ".json") ~= nil then
      local sSong = parseJson(file:readString("FNF/"..v.."/"..vs))

      local arayData = {
        ["songDisplayName"] = sSong["song"],
        ["songDataName"] = string.gsub(vs, ".json", ""),
        ["songIcon"] = sSong["icon"],
        ["songOwner"] = sSong["artist"],
        ["songMaxDur"] = tonumber(sSong["totalSongTime"])
      }

      local song = modPage:newAction()
      song:title(arayData["songDisplayName"])
      song:item(arayData["songIcon"])
      song.leftClick = function (self)
        startSong(arayData["songDataName"], arayData, v)
      end
    end
  end
end


function events.entity_init()
  models.fn.notes:setPos(0,15,0)
  models.fn.sustains:setPos(0,15,0)

  models.fn.notes.left:setVisible(false):setPrimaryRenderType("TRANSLUCENT_CULL"):setOpacity(0.8)
  models.fn.notes.down:setVisible(false):setPrimaryRenderType("TRANSLUCENT_CULL"):setOpacity(0.8)
  models.fn.notes.up:setVisible(false):setPrimaryRenderType("TRANSLUCENT_CULL"):setOpacity(0.8)
  models.fn.notes.right:setVisible(false):setPrimaryRenderType("TRANSLUCENT_CULL"):setOpacity(0.8)

  models.fn.sustains.left:setPivot(0,-3,0) 
  models.fn.sustains.down:setPivot(0,-3,0) 
  models.fn.sustains.up:setPivot(0,-3,0) 
  models.fn.sustains.right:setPivot(0,-3,0) 

  models.fn.sustains.left:setVisible(false):setPrimaryRenderType("TRANSLUCENT_CULL"):setOpacity(0.65)
  models.fn.sustains.down:setVisible(false):setPrimaryRenderType("TRANSLUCENT_CULL"):setOpacity(0.65)
  models.fn.sustains.up:setVisible(false):setPrimaryRenderType("TRANSLUCENT_CULL"):setOpacity(0.65)
  models.fn.sustains.right:setVisible(false):setPrimaryRenderType("TRANSLUCENT_CULL"):setOpacity(0.65)

  leftKey.press = pings.leftPress
  downKey.press = pings.downPress
  upKey.press = pings.upPress
  rightKey.press = pings.rightPress

  leftKey.release = pings.relLeft
  downKey.release = pings.relDown
  upKey.release = pings.relUp
  rightKey.release = pings.relRight

  scoreText = models.fn.text:newText("scoreText")

  scoreText:setText("Select Song...")
        :setPos(0, -15, 0)
        :setScale(0.25)
        :setAlignment("CENTER")
        :setWidth(350)
        :setLight(15, 15)

  ratingText = models.fn.text:newText("ratingText")

  ratingText:setText('[{"text":"Sick\n","color":"yellow"},{"text":"0","color":"white"}]')
        :setPos(16, 0, 0)
        :setScale(0.25)
        :setAlignment("CENTER")
        :setWidth(100)
        :setLight(15, 15)
        :setScale(0.3)
        :setVisible(true)

  models.bf_anims.root:setPrimaryTexture("Skin")
  models.bf_anims.root.Bodyy.RightArmg.mike:setPrimaryTexture("CUSTOM", textures["mike"])
  models.bf_anims.root:setPos(0,-30,10)

  animations.bf_anims.idle:play()

  vanilla_model.PLAYER:setVisible(false)
end

function popUpScore(scoreType)
  oldOpacity = 1
  if scoreType == "sick" then
    totalPressed = totalPressed + 1
    ratingText:setText('[{"text":"SICK\n","color":"yellow"},{"text":"'..combo..'","color":"white"}]')
  elseif scoreType == "good" then
    totalPressed = totalPressed + 0.9
      ratingText:setText('[{"text":"GOOD\n","color":"blue"},{"text":"'..combo..'","color":"white"}]')
  elseif scoreType == "bad" then
    totalPressed = totalPressed + 0.6
    ratingText:setText('[{"text":"BAD\n","color":"gray"},{"text":"'..combo..'","color":"white"}]')
  end 
end

function updateScore()
    local acc = 0
    if totalNotes > 0 then
        acc = (totalPressed / totalNotes) * 100
    end
  scoreText:setText("Score: "..score.." | Misses: "..misses.." | Accuracy: ".. string.format('%.2f', acc) .."%")
end

function stopSong()
  if isSongStarted == true then
    isSongStarted = false

    for i,v in ipairs(notes) do
      models.fn.notes:removeChild(v[1])
      if v[4].hasSus == true then models.fn.sustains:removeChild(v[4].main) end
      table.remove(notes,i)
    end 

    unspawnnedNotes = {}

    time = 0
    prevTime = 0
    curTime = 0
    misses = 0
    score = 0
    totalNotes = 0
    totalPressed = 0
    combo = 0

    if inst then inst:stop() end

    for i,v in ipairs(notes) do
      models.fn.notes:removeChild(v[1])
      if v[4].hasSus == true then
        models.fn.sustains:removeChild(v[4].main)
      end
      table.remove(notes,i)
    end 
    scoreText:setText("Select Song...")
  end
end

function startSong(songName, songData, modData)
  stopSong()

  scoreText:setText("Loading...")
  chartJS = parseJson(file:readString("FNF/"..modData.."/"..songData["songDataName"]..".json"))
  for i,v in ipairs(chartJS.notes) do
    for secIndex,secValue in ipairs(v.sectionNotes) do
      if chartJS.format == "psych_v1_convert" then
        if secValue[2] < 4 then addNote(secValue[1], secValue[2],secValue[3]) end
      else
        if v.mustHitSection == true then
          if secValue[2] < 4 then addNote(secValue[1], secValue[2],secValue[3]) end
        else
          if secValue[2] > 3 then addNote(secValue[1], secValue[2] - 4,secValue[3]) end
        end
      end
    end
  end
  inst = sounds:playSound(songName, player:getPos(), 1, 1, false)
  isSongStarted = true

  updateScore()

  print("Song Name: ".. songData["songDisplayName"].. " | Song Author: ".. songData["songOwner"] .. " | Total Notes: " .. #unspawnnedNotes .. " | Song Time: ".. songData["songMaxDur"])
end

lerp = function(a, b, t)
	return a + (b - a) * t
end

function events.tick() 
if isSongStarted == true then prevTime = time time = time + (1 / 20) end

  if animTimer > 0 then
    animTimer = animTimer - 1
  else
    animTimer = 0
  end

  if animTimer == 0 then
    animations.bf_anims.idle:stop()
    animations.bf_anims.left:stop()
    animations.bf_anims.down:stop()
    animations.bf_anims.up:stop()
    animations.bf_anims.right:stop()
    animations.bf_anims.idle:play()
    animTimer = 15
  end
  
  if ratingText ~= nil then
    if oldOpacity > 0 then
      oldOpacity = oldOpacity - 1/10
    else
      oldOpacity = 0
    end
    if oldOpacity >= 0 then
      ratingText:setOpacity(oldOpacity)
    else
      ratingText:setOpacity(0)
    end 
    ratingText:setPos(16, 0 + (2.5 * (oldOpacity * -1)), 0)
  end 
end

function events.render(delta, context)

  
  if isSongStarted == true then
    curTime = (prevTime + (time - prevTime) * delta) * 1000

    for i,v in ipairs(unspawnnedNotes) do
      local distance =  (v[2] - (curTime))

      if distance < 800 then
        models.fn.notes:addChild(v[1])

        if v[4].hasSus == true then models.fn.sustains:addChild(v[4].main) v[4].main:setVisible(true) end

        table.insert(notes, v)

        pings.onSpawnNote(v)

        table.remove(unspawnnedNotes,i)
      end
    end

    for i,vs in ipairs(pressedSus) do
      local startTime = vs.strumTime
      local sustainLength = vs.susLen

      local distance2 = 0

      local distance3 = (0.15 * ((startTime + (sustainLength - 90)) - curTime)) * 0.5
      local targetScaleY = (distance2 * -1) - (distance3 * -1)

      vs.main:setPos(0, distance2 * -1, 0)
      vs.main:setScale(1, 1 + targetScaleY, 1)

      if distance3 < 0 then models.fn.sustains:removeChild(vs.main) table.remove(pressedSus, i) end
    end

    for i,v in ipairs(notes) do
      local distance =( 0.15 * (v[2] - (curTime))) * 0.5

      v[1]:setPos(0, distance * -1,0)

      if v[4].hasSus == true then
        local startTime = v[4].strumTime
        local sustainLength = v[4].susLen

        local distance2 = (0.15 * (startTime - curTime)) * 0.5

        local distance3 = (0.15 * ((startTime + (sustainLength - 90)) - curTime)) * 0.5
        local targetScaleY = (distance2 * -1) - (distance3 * -1)

        v[4].main:setPos(0, distance2 * -1, 0)
        v[4].main:setScale(1, 1 + targetScaleY, 1)

        if distance3 < 0 then pings.onSustainFinish(v) models.fn.sustains:removeChild(v[4].main) end
      end

      if distance < -10 then
        
        totalNotes = totalNotes + 1
        score = score - 100
        misses = misses + 1
        score = 0
        combo = 0

        updateScore()

        pings.onMissNote(v)

        if v[4].hasSus == true then models.fn.sustains:removeChild(v[4].main) end
        
        models.fn.notes:removeChild(v[1])
        table.remove(notes,i)
      end
    end
  end
end

function createSusNote(stTimee, susLenn, dir)
  local data = {
    main = nil,
    susLen = susLenn,
    strumTime = stTimee,
    hasSus = false
  }

  if susLenn > 0 then
    if dir == 0 then
      data.main = models.fn.sustains.left:copy("susNote"..#notes)
    elseif dir == 1 then
      data.main = models.fn.sustains.down:copy("susNote"..#notes)
    elseif dir == 2 then
      data.main = models.fn.sustains.up:copy("susNote"..#notes)
    elseif dir == 3 then
      data.main = models.fn.sustains.right:copy("susNote"..#notes)
    end
    data.hasSus = true
  end

  return data
end

function addNote(stTime,dir,susTime)
  local note = nil
  local connectedSus = nil

  if dir == 0 then
    note = models.fn.notes.left:copy("note"..#notes)
  elseif dir == 1 then
    note = models.fn.notes.down:copy("note"..#notes)
  elseif dir == 2 then
    note = models.fn.notes.up:copy("note"..#notes)
  elseif dir == 3 then
    note = models.fn.notes.right:copy("note"..#notes)
  end

  connectedSus = createSusNote(stTime, susTime, dir)

  note:setVisible(true)

  table.insert(unspawnnedNotes, {
    note,
    stTime,
    dir,
    connectedSus
  })

end

function judgeNote(judgeTime)
    local absTime = math.abs(judgeTime)

    if absTime >= -5 and absTime < 65 then
        return "sick"
    elseif absTime >= 65 and absTime < 90 then
        return "good"
    elseif absTime >= 150 and absTime < 195 then
        return "bad"
    else
        return "none"
    end
end