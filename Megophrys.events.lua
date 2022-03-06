Megophrys.onDisconnect = function()
  disableTrigger('Update Power Bars')
end

Megophrys.onConnect = function()
  sendGMCP([[Core.Supports.Add ["IRE.Time 1"] ]])
  registerAnonymousEventHandler('gmcp.Char.Items.List', 'Megophrys.updateWhatHere')
  registerAnonymousEventHandler('gmcp.Char.Items.Add', 'Megophrys.updateWhatHere')
  registerAnonymousEventHandler('gmcp.Char.Items.Remove', 'Megophrys.updateWhatHere')
  registerAnonymousEventHandler('gmcp.Char.Items.Update', 'Megophrys.updateWhatHere')
  registerAnonymousEventHandler('gmcp.Room.Players', 'Megophrys.updateWhoHere')
  registerAnonymousEventHandler('gmcp.Room.AddPlayer', 'Megophrys.updateWhoHere')
  registerAnonymousEventHandler('gmcp.Room.RemovePlayer', 'Megophrys.updateWhoHere')
  registerAnonymousEventHandler('gmcp.IRE.Time.Update', 'Megophrys.showTime')
  registerAnonymousEventHandler('sysGetHttpDone', 'Megophrys.updateWhosOnline')
  wsys.unkeepup('shield')
  wsys.unkeepup('reflections')
  wsys.setSettings('automount', 'on')
  mmp.settings:setOption('gallop', true)
  mmp.settings:setOption('dash', false)
  Megophrys.class = gmcp.Char.Status.class
  Megophrys.makeClassToolbars()
  supportedClass = Megophrys[Megophrys.class]
  if supportedClass then
    supportedClass.onConnect()
    supportedClass.makeClassToolbars()
  end
  Megophrys.setMode('denizen')
  Megophrys.resetCuringPrios()
  enableTrigger('Update Power Bars')
  cecho('\n<cyan>Megophrys v1.1 initialised. Enjoy :)\n')
end

Megophrys.endSpeedwalk = function()
  local endingPursuit = Megophrys.inPursuit
  Megophrys.inPursuit = false
  Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
  if Megophrys.class == 'Magi' then
    sendAll('land', 'golem return')
  end
  if Megophrys.killStrat == 'raid' and Megophrys.raidLeader then
    send('fol '.. Megophrys.raidLeader)
  elseif Megophrys.killStrat == 'bonk' then
    if endingPursuit then send('psi transcend') end
  elseif Megophrys.killStrat == 'pummel' then
    if endingPursuit then send('embed focus') end
    if Megophrys.autoEscaping then
      if Megophrys.opponentClass and Megophrys.opponentClass == 'airlord' then
        Megophrys.autoResist()
      else
        send('cast aerial')
      end
    else
      send('fol '.. target)
      Megophrys.autoAttack()
    end
  end
  if Megophrys.autoEscaping then
    Megophrys.stopEscape('Safe')
  end
end
registerAnonymousEventHandler('mmapper arrived', 'Megophrys.endSpeedwalk')

Megophrys.flyingBlocked = function()
  if Megophrys.autoEscaping and Megophrys.class == 'Magi' then
    Megophrys.stopEscape('Can\'t fly -- trying barrier')
    Megophrys.autoResist()
  end
end

Megophrys.flyingSuccess = function()
  if Megophrys.autoEscaping then
    Megophrys.stopEscape('Flying (done)')
    Megophrys.autoResist()
  end
end

Megophrys.gainedBalance = function()
  if gmcp.Char.Vitals.bal ~= "1" then return end
  if Megophrys.autoAttacking then
    Megophrys[Megophrys.class].nextAttack()
  end
end

Megophrys.gainedEQ = function()
  if gmcp.Char.Vitals.eq ~= "1" then return end
  if Megophrys.autoAttacking then
    Megophrys[Megophrys.class].nextAttack()
  end
end

Megophrys.hitWall = function()
  if speedWalkDir[1] then
    sendAll('mj '.. speedWalkDir[1], 'leap '.. speedWalkDir[1])
  elseif Megophrys.lastDirTried then
    sendAll('mj '.. Megophrys.lastDirTried, 'leap '.. Megophrys.lastDirTried)
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
    Megophrys.Magi.element = 'air'
    cecho('\n<cyan>Switching to air for rebounding\n')
  end
  cecho('\n<cyan>STOP HITTING YOURSELF STOP HITTING YOURSELF\n')
end

Megophrys.hitShield = function()
  if not Megophrys.autoAttacking or Megophrys.killStrat ~= 'denizen' then
    return
  end

  brage_dshield = {
    Alchemist='throw caustic at ',
    Blademaster='shin shatter ',
    Magi='cast disintegrate on ',
    Psion='weave pulverise ',
  }

  if brage_dshield[Megophrys.class] then
    send(brage_dshield[Megophrys.class] .. target)
  end
end

Megophrys.underPressure = function()
  if Megophrys.autoEscaping then
    Megophrys.stopEscape('Blocked by pressure')
    Megophrys.autoResist()
  end
end
