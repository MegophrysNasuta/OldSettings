Megophrys.doWhileSelfish = function(func)
  cmd = func()
  send('generosity | '.. cmd ..' | selfishness')
end

Megophrys.dropWhileSelfish = function(item)
  Megophrys.doWhileSelfish(function() return 'drop '.. item end)
end

Megophrys.giveWhileSelfish = function(amt, item, tgt)
  Megophrys.doWhileSelfish(function()
    if item == 'sovereigns' then
      return 'get'.. amt ..' sovereigns from pack'
    end
    if amt then
      return 'give'.. amt ..' '.. item .. ' to ' .. tgt
    else
      return 'give '.. item .. ' to ' .. tgt
    end
  end)
end

Megophrys.offerWhileSelfish = function(corpse)
  Megophrys.doWhileSelfish(function() return 'offer '.. (corpse or 'corpses') end)
end

Megophrys.sellWhileSelfish = function(item, merchant)
  Megophrys.doWhileSelfish(function() return 'sell '.. item ..' to '.. merchant end)
end

Megophrys.highlightPanicRoom = function()
  Megophrys.panicRoomLabel = nil
  local message = '<center>Panic Room: None'
  Megophrys.panicRoomLabel = Geyser.Label:new({
    name='panicRoomLabel',
    x='57.5%', y='2%',
    height='2%', width='15%',
    fgColor=Megophrys.fgColors[Megophrys.killStrat], color='black',
    message=message
  })
  Megophrys.panicRoomLabel:setFontSize(11)

  if not Megophrys.fleeingToRoom then return end
  local roomID = Megophrys.fleeingToRoom

  unHighlightRoom((Megophrys.highlightedPanicRoom or 0))
  Megophrys.highlightedPanicRoom = tonumber(roomID)
  local foundRoomName = getRoomName(Megophrys.highlightedPanicRoom)
  Megophrys.panicRoomLabel:echo('<center>Panic Room: '.. foundRoomName)
  highlightRoom(Megophrys.highlightedPanicRoom, 225, 0, 125, 225, 0, 225, 1, 125, 125)
end

Megophrys.highlightTargetRoom = function(roomName, foundPlayer)
  Megophrys.targetRoomLabel = nil
  local message = '<center>Target Room: None'
  if Megophrys.killStrat == 'denizen' and Megophrys.huntingGround then
    message = '<center>Target Room: '.. Megophrys.huntingGround
  end
  Megophrys.targetRoomLabel = Geyser.Label:new({
    name='targetRoomLabel',
    x='57.5%', y=0,
    height='2%', width='15%',
    fgColor=Megophrys.fgColors[Megophrys.killStrat], color='black',
    message=message
  })
  Megophrys.targetRoomLabel:setFontSize(11)

  if not roomName or not foundPlayer then return end

  for roomID, foundRoomName in pairs(searchRoom(roomName, true, true)) do
    unHighlightRoom((Megophrys.highlightedTargetRoom or 0))
    Megophrys.highlightedTargetRoom = tonumber(roomID)
    local foundTarget = (string.lower(foundPlayer or '') == string.lower(target))
    if foundTarget then
      Megophrys.targetRoom = Megophrys.highlightedTargetRoom
      Megophrys.targetRoomLabel:echo('<center>Target Room: '.. foundRoomName)
    end
    cecho('\n<cyan>Highlighting '.. foundRoomName .. ' ('.. roomID ..')\n')
    highlightRoom(Megophrys.highlightedTargetRoom, 225, 125, 0, 225, 225, 0, 1, 125, 125)
  end
end

Megophrys.hoard = function()
  sendAll(
    'g gold',
    'put sovereigns in pack',
    'inr all'
  )
end

Megophrys.Util = {}
Megophrys.Util.gagLine = function()
  moveCursor(0, getLineCount()) deleteLine()
  tempLineTrigger(1,1,[[if isPrompt() then
    deleteLine()
  end]])
end

Megophrys.Util.hexToRgb = function(hex)
  if not hex:starts('#') then hex = '#'.. hex end
  return {
    r = math.floor(tonumber(string.sub(hex, 2, 3), 16) + 0.5),
    g = math.floor(tonumber(string.sub(hex, 4, 5), 16) + 0.5),
    b = math.floor(tonumber(string.sub(hex, 6, 7), 16) + 0.5),
  }
end

Megophrys.Util.rgbToHex = function(r, g, b)
  local rgbValue = (r * 0x10000) + (g * 0x100) + b
  local hexValue = string.format("%x", rgbValue)
  if #hexValue == 6 then
    return hexValue
  else
    return string.rep('0', 6 - #hexValue) .. hexValue
  end
end

Megophrys.Util._dgradient = function(text, fgColor1, fgColor2, bgColor1, bgColor2)
  if not fgColor1 or not fgColor2 or not bgColor1 or not bgColor2 then
    error("Missing arguments for gradient for text: ".. text)
  end

  local hexToRgb = Megophrys.Util.hexToRgb
  local fgColor1, fgColor2 = hexToRgb(fgColor1), hexToRgb(fgColor2)
  local bgColor1, bgColor2 = hexToRgb(bgColor1), hexToRgb(bgColor2)

  local function smoothGradient(color1, color2, numSteps)
    local gradient = {color1}
    local colorStep = math.floor(((color2 - color1) / numSteps) + 0.5)
    for i=1, numSteps do
      local nextColor = gradient[#gradient] + colorStep
      if nextColor > 255 then nextColor = 255 end
      if nextColor < 0 then nextColor = 0 end
      gradient[#gradient + 1] = nextColor
    end
    return gradient
  end

  local fgReds = smoothGradient(fgColor1.r, fgColor2.r, #text)
  local fgGreens = smoothGradient(fgColor1.g, fgColor2.g, #text)
  local fgBlues = smoothGradient(fgColor1.b, fgColor2.b, #text)

  local bgReds = smoothGradient(bgColor1.r, bgColor2.r, #text)
  local bgGreens = smoothGradient(bgColor1.g, bgColor2.g, #text)
  local bgBlues = smoothGradient(bgColor1.b, bgColor2.g, #text)

  local resultStr = ''
  for i=1, #text do
    resultStr = (resultStr ..'<'.. fgReds[i] ..','.. fgGreens[i] ..','.. fgBlues[i]
                           ..':'.. bgReds[i] ..','.. bgGreens[i] ..','.. bgBlues[i]
                           ..'>'.. string.sub(text, i, i))
  end
  return resultStr
end

Megophrys.Util.hiliteSelection = function(fg_color)
  fg(fg_color)
  deselect()
  resetFormat()
end

Megophrys.Util.randomChoice = function(tbl)
  -- https://stackoverflow.com/a/37468712
  local keyset = {}
  for _ in pairs(tbl) do
    table.insert(keyset, _)
  end
  return tbl[keyset[math.random(#keyset)]]
end
