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
  Megophrys.PanicRoomLabel:setFontSize(11)

  if not Megophrys.fleeingToRoom then return end
  local roomID = Megophrys.fleeingToRoom

  unHighlightRoom((Megophrys.highlightedPanicRoom or 0))
  Megophrys.highlightedPanicRoom = tonumber(roomID)
  local foundRoomName = getRoomName(Megophrys.highlightedPanicRoom)
  Megophrys.panicRoomLabel:echo('<center>Panic Room: '.. foundRoomName)
  cecho('\n<cyan>Highlighting '.. foundRoomName .. ' ('.. roomID ..')\n')
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

Megophrys.Util = {}
Megophrys.Util.gagLine = function()
  moveCursor(0, getLineCount()) deleteLine()
  tempLineTrigger(1,1,[[if isPrompt() then
    deleteLine()
  end]])
end

Megophrys.hoard = function()
  sendAll(
    'g gold',
    'put sovereigns in pack',
    'inr all'
  )
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
