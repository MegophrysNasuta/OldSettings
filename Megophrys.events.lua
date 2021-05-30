Megophrys.onConnect = function()
  sendAll('health', 'mana')  -- reset power bars
  if Megophrys.class == 'Magi' then
    sendAll('simultaneity', 'bind all', 'fortify all')
  end
  Megophrys.setMode('denizen')
  Megophrys.resetCuringPrios()
  cecho('\n<cyan>Megophrys v1.1 initialised. Enjoy :)\n')
end

Megophrys.endSpeedwalk = function()
  Megophrys.inPursuit = false
  Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
  if Megophrys.class == 'Magi' then
    sendAll('land', 'golem return')
  end
  if Megophrys.killStrat == 'raid' and Megophrys.raidLeader then
    send('fol '.. Megophrys.raidLeader)
  elseif Megophrys.killStrat == 'pummel' then
    send('fol '.. target)
    Megophrys.autoAttack()
  end
end

Megophrys.flyingBlocked = function()
  if Megophrys.autoEscaping and Megophrys.class == 'Magi' then
    send('golem barrier')
    Megophrys.stopEscape('Can\'t fly -- trying barrier')
  end
end

Megophrys.flyingSuccess = function()
  if Megophrys.autoEscaping then
    Megophrys.stopEscape('Flying (safe)')
  end
end

Megophrys.getCharInfo = function(charName)
  local url = 'http://api.achaea.com/characters/'.. string.lower(charName) ..'.json'
  
  local onAPIReturn = function(_, rurl, body)
    local charData = yajl.to_value(body)
    local ans = string.format('%s is a level %s %s in %s.' ..
                              '\n\tDenizens killed: %s\t\tAdventurers killed: %s\n\n',
                              charData.fullname,
                              charData.level,
                              Megophrys.Util.titleCase(charData.class),
                              Megophrys.Util.titleCase(charData.city),
                              charData.mob_kills,
                              charData.player_kills)
    cecho('\n<cyan>'.. ans ..'\n')
  end
  
  registerAnonymousEventHandler('sysGetHttpDone',
                                onAPIReturn,
                                true)  -- true here means delete after firing once
  getHTTP(url)
end

Megophrys.hitIcewall = function()
  if Megophrys.autoEscaping then
    if #gmcp.Room.Info.exits < 3 and Megophrys.class == 'Magi' then
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
