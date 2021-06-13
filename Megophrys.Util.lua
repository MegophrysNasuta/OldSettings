Megophrys.doWhileSelfish = function(func)
  sendAll('curing defences off', 'generosity')
  tempTimer(.75, function()
    func()
    sendAll('selfishness', 'curing defences on')
  end)
end

Megophrys.dropWhileSelfish = function(item)
  Megophrys.doWhileSelfish(function() send('drop '.. item) end)
end

Megophrys.giveWhileSelfish = function(amt, item, tgt)
  Megophrys.doWhileSelfish(function()
    if item == 'sovereigns' then
      send('get'.. amt ..' sovereigns from pack')
    end
    if amt then
      send('give'.. amt ..' '.. item .. ' to ' .. tgt)
    else
      send('give '.. item .. ' to ' .. tgt)
    end
  end)
end

Megophrys.offerWhileSelfish = function(corpse)
  Megophrys.doWhileSelfish(function() send('offer '.. (corpse or 'corpses')) end)
end

Megophrys.sellWhileSelfish = function(item, merchant)
  Megophrys.doWhileSelfish(function() send('sell '.. item ..' to '.. merchant) end)
end

Megophrys.highlightPanicRoom = function()
  Megophrys.panicRoomLabel = nil
  local message = 'Panic Room: None'
  Megophrys.panicRoomLabel = Geyser.Label:new({
    name='panicRoomLabel',
    x='-750px', y='15px',
    height='14px', width='250px',
    fgColor=Megophrys.fgColors[Megophrys.killStrat], color='black',
    message=message
  })

  if not Megophrys.fleeingToRoom then return end
  local roomID = Megophrys.fleeingToRoom

  unHighlightRoom((Megophrys.highlightedPanicRoom or 0))
  Megophrys.highlightedPanicRoom = tonumber(roomID)
  local foundRoomName = getRoomName(Megophrys.highlightedPanicRoom)
  Megophrys.panicRoomLabel:echo('Panic Room: '.. foundRoomName)
  cecho('\n<cyan>Highlighting '.. foundRoomName .. ' ('.. roomID ..')\n')
  highlightRoom(Megophrys.highlightedPanicRoom, 225, 0, 125, 225, 0, 225, 1, 125, 125)
end

Megophrys.highlightTargetRoom = function(roomName, foundPlayer)
  Megophrys.targetRoomLabel = nil
  local message = 'Target Room: None'
  if Megophrys.killStrat == 'denizen' and Megophrys.huntingGround then
    message = 'Target Room: '.. Megophrys.huntingGround
  end
  Megophrys.targetRoomLabel = Geyser.Label:new({
    name='targetRoomLabel',
    x='-750px', y=0,
    height='14px', width='250px',
    fgColor=Megophrys.fgColors[Megophrys.killStrat], color='black',
    message=message
  })

  if not roomName or not foundPlayer then return end

  for roomID, foundRoomName in pairs(searchRoom(roomName, true, true)) do
    unHighlightRoom((Megophrys.highlightedTargetRoom or 0))
    Megophrys.highlightedTargetRoom = tonumber(roomID)
    local foundTarget = (string.lower(foundPlayer or '') == string.lower(target))
    if foundTarget then
      Megophrys.targetRoom = Megophrys.highlightedTargetRoom
      Megophrys.targetRoomLabel:echo('Target Room: '.. foundRoomName)
    end
    cecho('\n<cyan>Highlighting '.. foundRoomName .. ' ('.. roomID ..')\n')
    highlightRoom(Megophrys.highlightedTargetRoom, 225, 125, 0, 225, 225, 0, 1, 125, 125)
  end
end

Megophrys.Util = {}
Megophrys.Util.gagLine = function()
  moveCursor(0, getLineCount()) deleteLine()
end

Megophrys.hoard = function()
  sendAll(
    'g gold',
    'put sovereigns in pack',
    'inr all'
  )
end

Megophrys.Util.titleCase = function(str)
  return string.upper(string.sub(str, 1, 1)) .. string.lower(string.sub(str, 2, -1))
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
