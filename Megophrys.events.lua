Megophrys.onConnect = function()
  sendAll('health', 'mana')  -- reset power bars
  Megophrys.class = gmcp.Char.Status.class
  Megophrys.makeClassToolbars()
  supportedClass = Megophrys[Megophrys.class]
  if supportedClass then
    supportedClass.onConnect()
    supportedClass.makeClassToolbars()
  end
  Megophrys.setMode('denizen')
  Megophrys.resetCuringPrios()
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
  elseif Megophrys.killStrat == 'pummel' then
    if endingPursuit then
      send('embed focus')
    end
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

Megophrys.hitIcewall = function()
  if Megophrys.autoEscaping then
    if #gmcp.Room.Info.exits < 3 and Megophrys.class == 'Magi' then
      send('cast firelash '.. Megophrys.lastExitTried)
    end
    Megophrys.locationsFled = Megophrys.locationsFled - 1
    Megophrys.escapeBlocked = true
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
      send('cast disintegrate on '.. target)
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

Megophrys.shieldsUp = function()
  Megophrys.shieldIsUp = true
end

Megophrys.shieldsDown = function()
  Megophrys.shieldIsUp = false
end

Megophrys.underPressure = function()
  if Megophrys.autoEscaping then
    Megophrys.stopEscape('Blocked by pressure')
    Megophrys.autoResist()
  end
end
