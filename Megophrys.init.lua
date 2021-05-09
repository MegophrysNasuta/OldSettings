Megophrys = (Megophrys or {})
Megophrys.Magi = (Megophrys.Magi or {})
Megophrys.class = (Megophrys.class or 'Magi')
Megophrys.locationsFled = (Megophrys.locationsFled or 0)
Megophrys.targetLimb = (Megophrys.targetLimb or 'left')
Megophrys.targetRebounding = (Megophrys.targetRebounding or false)
Megophrys.targetProne = (Megophrys.targetProne or false)

local Magi = Megophrys.Magi
Magi.element = (Magi.element or 'air')
Magi.skipTorso = (Magi.skipTorso or false)
Magi.targetTransfixed = (Magi.targetTransfixed or false)
Magi.timefluxUp = (Magi.timefluxUp or false)

Magi.staffCasts = {
  earth = 'dissolution',
  fire = 'scintilla',
  air = 'lightning',
  water = 'horripilation',
}

Megophrys.fgColors = {
  denizen = 'cyan',
  raid = 'orange',
  pummel = 'yellow',
}

Megophrys.onConnect = function()
  if Megophrys.class == 'Magi' then
    sendAll('simultaneity', 'bind all', 'fortify all')
  end
end

Megophrys.eStopAuto = function()
  if Megophrys.autoAttacking then
    cecho('\n<red>Emergency stop: No more auto-attacks.\n')
    Megophrys.autoAttacking = false
  end
  if Megophrys.autoEscaping then
    cecho('\n<red>Emergency stop: No more auto-flight.\n')
    Megophrys.autoEscaping = false
  end
  send('clearqueue all')
end

Megophrys.setMode = function(mode)
  Megophrys.killStrat = string.lower(mode)
  if Megophrys.class == 'Magi' then
    Magi.resetModeButtonStyles()
  end
  if Megophrys.killStrat == 'denizen' then
    cecho('\n<cyan>Hunt mode activated as '.. Megophrys.class ..'!')
    setButtonStyleSheet('Hunt', 'QWidget { color: cyan; }')

    wsys.unkeepup('mass', true)
    wsys.unkeepup('rebounding', true)

    if Megophrys.class == 'Magi' then
      local Magi = Megophrys.Magi
      Magi.followUp = 'golem squeeze '.. target
      cecho('\n<cyan>Auto-attacks will be staffcasts'..
            '\nElement: '.. Magi.element ..
            '\nFollow up: '.. Magi.followUp ..
            '\nTarget is: '.. target ..'\n')
    end
  elseif Megophrys.killStrat == 'pummel' then
    if Megophrys.class == 'Magi' then
      cecho('\n<cyan>Magi PvP (Ice) mode activated!')
      setButtonStyleSheet('PvP', 'QWidget { color: cyan; }')
          
      wsys.keepup('mass', true)
      wsys.keepup('rebounding', true)
      
      local Magi = Megophrys.Magi
      Magi.timefluxUp = false
      Megophrys.targetTorso = false
      Magi.targetFrozen = false
      Magi.targetMaybeFrozen = false
      Megophrys.targetRebounding = false
      Megophrys.resetTargetWounds()
      Magi.followUp = 'golem timeflux '.. target
      
      cecho('\n<cyan>Auto-attacks will be staffstrikes'..
            '\nElement: '.. Magi.element ..
            '\nFollow up: '.. Magi.followUp ..
            '\nTarget is: '.. target ..
            '\n  on limb: '.. Megophrys.targetLimb)
    end
  elseif Megophrys.killStrat == 'raid' then
    cecho('\n<cyan>Raid mode activated as '.. Megophrys.class ..'!')
    setButtonStyleSheet('Raid', 'QWidget { color: cyan; }')
    
    if Megophrys.raidLeader then
      cecho('\n<cyan>Raid leader set to: '.. Megophrys.raidLeader ..'\n')
    end
    
    wsys.keepup('mass', true)
    wsys.keepup('rebounding', true)
    
    if Megophrys.class == 'Magi' then
      Magi.followUp = 'golem timeflux '.. target
      cecho('\n<cyan>Auto-attacks will be staffcasts'..
            '\nElement: '.. Magi.element ..
            '\nFollow up: '.. Magi.followUp ..
            '\nTarget is: '.. target ..'\n')
    end
  end
  
  Megophrys.priorityLabel = nil
  Megophrys.priorityLabel = Geyser.Label:new({
    name='priorityLabel',
    x='40%', y=0,
    width='7.5%', height='2%',
    fgColor=Megophrys.fgColors[Megophrys.killStrat], color='black',
    message='<center>Priority: IDLE</center>'
  })
  Megophrys.setTarget('none')
end

Megophrys.Magi.nextAttack = function()
  local Magi = Megophrys.Magi
  local killStrat = Megophrys.killStrat
  local staffCasts = Magi.staffCasts
  local skipTorso = Magi.skipTorso
  local timefluxUp = Magi.timefluxUp
  local targetLimb = Megophrys.targetLimb
  local targetWounds = Megophrys.targetWounds
  local targetRebounding = Megophrys.targetRebounding
  local targetProne = Megophrys.targetProne
  local targetTransfixed = Magi.targetTransfixed
  local targetHits = Megophrys.targetHits
  
  if killStrat == 'denizen' then
    send('staffcast '.. staffCasts[Magi.element] ..' at '.. target ..
         '/ golem squeeze '.. target)
  else
    if timefluxUp then
      Magi.followUp = 'golem smash '.. target .. ' legs'
    else
      Magi.followUp = 'golem timeflux '.. target
    end
    
    if killStrat == 'raid' then
      if (targetHits or 0) % 3 == 0 then
        send('cast transfix at '.. target)
      else
        send('staffcast '.. staffCasts[Magi.element] ..' at '.. target)
      end
      targetHits = targetHits + 1
    else
      local targetTorso = false
      local limbIsPrepped = false
      local torsoIsPrepped = false
      
      if targetLimb then
        local targetLimbDmg = targetWounds[targetLimb ..' leg']
        local avgLimbDmg = (targetLimbDmg.dmg / targetLimbDmg.trackedHits)
        if (100 - targetLimbDmg.dmg) <= avgLimbDmg then
          limbIsPrepped = true
          cecho('\n<gold>LIMB IS PREPPED!\n')
        end
      end
      
      if not skipTorso then
        local targetTorsoDmg = targetWounds.torso
        local avgTorsoDmg = (targetTorsoDmg.dmg / targetTorsoDmg.trackedHits)
        if (100 - targetTorsoDmg.dmg) <= avgTorsoDmg then
          torsoIsPrepped = true
          cecho('\n<gold>TORSO IS PREPPED!\n')
        end
      end
      
      if limbIsPrepped then
        if not torsoIsPrepped and not skipTorso then
          -- work on prepping torso once limb is done
          Megophrys.priorityLabel:echo('<center>Priority: TORSO PREP</center>')
          Magi.setElement('earth')
          targetTorso = true
        else
          -- otherwise go back to limb with air to prone them
          -- staying prone unlocks next step of attack sequence (targetProne)
          Megophrys.priorityLabel:echo('<center>Priority: FREEZE</center>')
          Magi.setElement('air')
          targetTorso = false
        end
      else
        Megophrys.priorityLabel:echo('<center>Priority: LIMB PREP</center>')
        if not targetRebounding then
          Magi.setElement('air')
        else
          Magi.setElement('earth')
        end
      end
      
      local cmd = 'staffstrike '.. target ..' with '.. element
      
      if targetProne and not Magi.targetMaybeFrozen then   -- spring freezing trap
        Magi.targetMaybeFrozen = true
        sendAll('clearqueue all', 'cast deepfreeze')
      else
        if Magi.targetFrozen then
          -- kill condition met: pummel to death
          Megophrys.priorityLabel:echo('<center>Priority: PUMMEL</center>')
          Magi.setElement('water')
          cmd = 'staffstrike '.. target ..' with '.. Magi.element ..' torso'
          Magi.followUp = 'golem pummel '.. target
        elseif targetMaybeFrozen then
          -- we've just done deepfreeze so we're going to hypothermia and see if it sticks
          -- if it sticks we make kill condition
          -- otherwise we're back to prepping limbs
          Magi.targetFrozen = true
          Magi.setElement('water')
          cmd = 'staffstrike '.. target ..' with '.. Magi.element ..' torso'
          Magi.followUp = 'golem hypothermia '.. target
          Magi.targetMaybeFrozen = false
        else
          if targetLimb and not targetTorso then
            cmd = cmd .. ' ' .. targetLimb .. ' leg'
          else
            cmd = cmd .. ' torso'
          end
        end
    
        sendAll(
          'clearqueue all',
          cmd .. '/' .. Magi.followUp
        )
      end
    end
  end
end

Magi.toggleSkipTorso = function()
  Magi.skipTorso = not Magi.skipTorso
  
  if Magi.skipTorso then
    cecho('\n<cyan>Skipping torso! (Only prepping limb.)\n')
    setButtonStyleSheet('Torso', 'QWidget {color: grey}')
  else
    cecho('\n<cyan>Prepping torso as well as '.. Megophrys.targetLimb ..' leg.\n')
    setButtonStyleSheet('Torso', 'QWidget {color: cyan}')
  end
  
  Magi.updatePrepGauges()
end

Megophrys.toggleTargetLimb = function()
  if Megophrys.targetLimb == 'right' then
    Megophrys.targetLimb = 'left'
  else
    Megophrys.targetLimb = 'right'
  end
  Magi.updatePrepGauges()
end

Megophrys.hitIcewall = function()
  if Megophrys.autoEscaping then
    if #gmcp.Room.Info.exits < 3 then
      Megophrys.escapingBlocked = true
      send('cast firelash '.. Megophrys.lastExitTried)
    end
    Megophrys.locationsFled = Megophrys.locationsFled - 1
  end
end

Megophrys.hitParry = function()
  cecho('\n<cyan>TARGETED STRIKE PARRIED!\n')
  if matches[2] == target and Megophrys.autoAttacking and not Megophrys.targetTorso then
    Megophrys.toggleTargetLimb()
    cecho('\n<cyan>Switching to '.. Megophrys.targetLimb ..' leg due to parry.')
  end
end

Megophrys.hitRebounding = function()
  if Megophrys.class == 'Magi' then
    if (Megophrys.autoAttacking and 
          Megophrys.killStrat == 'denizen') then
      send('cast erode at '.. target)
    else
      Megophrys.Magi.element = 'air'
      cecho('\n<cyan>Switching to air for rebounding\n')
    end
  end
  cecho('\n<cyan>STOP HITTING YOURSELF STOP HITTING YOURSELF\n')
end

Megophrys.shieldOnTarget = function()
  if Megophrys.killStrat == 'denizen' then
    if Megophrys.class == 'Magi' then
      send('cast disintegrate at '.. target)
    end
  end
end

Megophrys.pursue = function()
  if (Megophrys.targetRoom and not 
      Megophrys.autoAttacking and not 
      Megophrys.autoEscaping) then
    gotoRoom(Megophrys.targetRoom)
    Megophrys.targetRoom = nil
  else
    if Megophrys.killStrat == 'raid' and Megophrys.raidLeader then
      send('cast scry at '.. Megophrys.raidLeader)
    elseif Megophrys.killStrat == 'denizen' and Megophrys.huntingGround then
      send('walk to '.. huntingGround)
    else
      send('cast scry at '.. target)
    end
  end
end

Megophrys.autoAttack = function()
  if not Megophrys.autoAttacking then
    Megophrys.autoAttacking = true
    cecho('\n<cyan>Commencing auto-attack with '.. Megophrys.class ..'...\n')
    Megophrys[Megophrys.class].nextAttack()
    Megophrys.priorityLabel:echo('<center>Priority: DAMAGE</center>')
  else
    cecho('\n<cyan>You\'re already attacking as fast as you can!\n')
  end
end

Megophrys.stopAttack = function(reason)
  cecho('\n<cyan>'.. reason ..'. Disabling auto-attack.\n')
  Megophrys.autoAttacking = false
  send('diag')
  Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
end

Megophrys.tryExit = function(exitDir)
  send(exitDir)
  Megophrys.locationsFled = Megophrys.locationsFled + 1
  Megophrys.lastExitTried = exitDir
end

Megophrys.autoEscape = function()
  if Megophrys.autoAttacking then
    Megpohrys.autoAttacking = false
  end

  Megophrys.autoEscaping = true
  Megophrys.escapingBlocked = false
  Megophrys.priorityLabel:echo('<center>Priority: FLEE</center>')

  while Megophrys.locationsFled <= 3 and not Megophrys.escapingBlocked do
    local tries = 1
    for exitDir, roomID in pairs(gmcp.Room.Info.exits) do
      if tries == #gmcp.Room.Info.exits then
        Megophrys.tryExit(exitDir)
      elseif exitDir ~= Megophrys.lastExitTried then
        if math.random(10) < 8 then
          Megophrys.tryExit(exitDir)
        end
      end
      tries = tries + 1
    end
  end
  
  if Megophrys.locationsFled == 3 then
    sendAll('cast aerial', 'diag')
    Megophrys.locationsFled = 0
    Megophrys.autoEscaping = false
    Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
  end
end

Magi.updatePrepGauges = function()
  if not Magi.limbGauge then
    Magi.limbGauge = Geyser.Gauge:new({
      name='limbGauge',
      x='47.5%', y=0,
      width='7.5%', height='2%'
    })
  end
  if not Magi.torsoGauge then
    Magi.torsoGauge = Geyser.Gauge:new({
      name='torsoGauge',
      x='47.5%', y='2%',
      width='7.5%', height='2%'
    })
  end
  local targetLimb = Megophrys.targetLimb
  local targetLimbWounds = Megophrys.targetWounds[targetLimb ..' leg']
  local targetTorsoWounds = Megophrys.targetWounds.torso
  local limbLabel = '<center>'.. string.upper(targetLimb) ..' LEG</center>'
  local torsoLabel = '<center>NONE</center>'
  if not Magi.skipTorso then
    torsoLabel = '<center>TORSO</center>'
  end
  Magi.limbGauge:setValue(targetLimbWounds.dmg, 100, limbLabel)
  Magi.torsoGauge:setValue(targetTorsoWounds.dmg, 100, torsoLabel)
end

Magi.resetElementButtonStyles = function()
  setButtonStyleSheet('Earth', 'QWidget { color: white; }')
  setButtonStyleSheet('Air', 'QWidget { color: white; }')
  setButtonStyleSheet('Fire', 'QWidget { color: white; }')
  setButtonStyleSheet('Water', 'QWidget { color: white; }')
end

Magi.resetModeButtonStyles = function()
  setButtonStyleSheet('Hunt', 'QWidget { color: white; }')
  setButtonStyleSheet('PvP', 'QWidget { color: white; }')
  setButtonStyleSheet('Raid', 'QWidget { color: white; }')
end

Magi.setElement = function(element)
  local elem = string.lower(tostring(element))
  if elem == 'fire' or elem == 'water' or elem == 'air' or elem == 'earth' then
    Magi.element = elem
    Magi.resetElementButtonStyles()
    setButtonStyleSheet(Megophrys.Util.titleCase(elem), 'QWidget { color: cyan; }')
    cecho('\n<cyan>Element set to: '.. Magi.element ..'\n')
  else
    cecho('\n<red>Unknown element: '.. element ..' (ignored)\n')
  end
end

Megophrys.highlightTargetRoom = function(roomName, foundPlayer)
  for roomID, roomName in pairs(searchRoom(roomName, true, true)) do
    unHighlightRoom((Megophrys.highlightRoom or 0))
    Megophrys.highlightRoom = tonumber(roomID)
    if foundPlayer == target then
      Megophrys.targetRoom = tonumber(roomID)
    end
    cecho('\n<cyan>Highlighting '.. roomName .. ' ('.. roomID ..')\n')
    highlightRoom(Megophrys.highlightRoom, 225, 125, 0, 225, 225, 0, 1, 125, 125)
  end
end

Megophrys.Util = {}
Megophrys.Util.gagLine = function()
  moveCursor(0, getLineCount()) deleteLine()
end

Megophrys.Util.titleCase = function(str)
  return string.upper(string.sub(str, 1, 1)) .. string.lower(string.sub(str, 2, -1))
end

Megophrys.Util.hiliteSelection = function(fg_color)
  fg(fg_color)
  deselect()
  resetFormat()
end

Megophrys.resetTargetWounds = function()
  cecho('\t<cyan>Resetting target wounds...\n')
  Megophrys.targetHits = 0
  Megophrys.targetWounds = (Megophrys.targetWounds or {})
  Megophrys.targetWounds['right leg'] = {dmg=0, trackedHits=0}
  Megophrys.targetWounds['left leg'] = {dmg=0, trackedHits=0}
  Megophrys.targetWounds['right arm'] = {dmg=0, trackedHits=0}
  Megophrys.targetWounds['left arm'] = {dmg=0, trackedHits=0}
  Megophrys.targetWounds.torso = {dmg=0, trackedHits=0}
  Megophrys.targetWounds.head = {dmg=0, trackedHits=0}
  Megophrys.Magi.updatePrepGauges()
end

Megophrys.setTarget = function(t)
  target = t
  send('st '.. t)
  cecho('\n<cyan>Target changed to '.. t ..'.')
  Megophrys.resetTargetWounds()
  
  -- set temp trigger to highlight the target string
  if hilite_trigger_id then killTrigger(hilite_trigger_id) end
  hilite_trigger_id = tempTrigger(t, function() 
    idx = 1
    done = false
    while not done do
      done = true
      lpos = selectString(string.lower(t), idx)
      if lpos ~= -1 then 
        Megophrys.Util.hiliteSelection('red')
        done = false
      end
      lpos = selectString(Megophrys.Util.titleCase(t), idx)
      if lpos ~= -1 then
        Megophrys.Util.hiliteSelection('red')
        done = false
      end
      idx = idx + 1
    end
  end)
  
  Megophrys.targetLabel = nil
  Megophrys.targetLabel = Geyser.Label:new({
    name='targetLabel',
    x='40%', y='2%',
    width='7.5%', height='2%',
    fgColor=Megophrys.fgColors[Megophrys.killStrat], color='black',
    message='<center>Target: '.. target ..'</center>'
  })
end

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

Megophrys.hoard = function()
  sendAll(
    'g gold',
    'put sovereigns in pack',
    'inr all'
  )
end


cecho('\n<cyan>Megophrys v1.1 initialised. Enjoy :)\n')
Megophrys.setMode('denizen')
Megophrys.setTarget('none')
