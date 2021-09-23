Megophrys.autoAttack = function()
  Megophrys.setGuidance('fight')
  cecho('\n<cyan>Commencing auto-attack with '.. Megophrys.class ..'...\n')
  Megophrys.priorityLabel:echo('<center>Priority: DAMAGE</center>')
  Megophrys.updateMissionCtrlBar()
  Megophrys[Megophrys.class].nextAttack()
end

Megophrys.autoEscape = function()
  Megophrys.setGuidance('flight')

  if not gmcp.Room or not gmcp.Room.Info or not gmcp.Room.Info.exits then
    Megophrys.stopEscape('No exits detected')
    return
  end

  cecho('\nCommencing auto-flight...\n')
  Megophrys.fleeingToRoom = Megophrys.Util.randomChoice(getAreaRooms(
                              getRoomArea(gmcp.Room.Info.num)
                            ))
  Megophrys.escapeBlocked = false
  Megophrys.escapeDelayed = false

  Megophrys.priorityLabel:echo('<center>Priority: FLEE</center>')
  Megophrys.updateMissionCtrlBar()
  Megophrys.highlightPanicRoom()
  send('lose '.. target)
  gotoRoom(Megophrys.fleeingToRoom)
end

Megophrys.autoResist = function()
  if not Megophrys.autoResisting then
    Megophrys.autoResisting = true
    Megophrys.setGuidance('DieWithHonor')
    Megophrys.priorityLabel:echo('<center>Priority: HEAL</center>')
    wsys.keepup('shield', true)
    if Megophrys.class == 'Magi' then
      wsys.keepup('reflections', true)
    end
  end
end

Megophrys.eStopAuto = function(message)
  if Megophrys.autoAttacking then
    cecho('\n<red>Emergency stop: No more auto-attacks.\n')
    Megophrys.stopAttack(message or 'Emergency stop lever')
  end
  if Megophrys.autoEscaping then
    Megophrys.stopEscape(message or 'Emergency stop lever')
  end
  if Megophrys.autoResisting then
    Megophrys.stopResist(message or 'Emergency stop lever')
  end
  send('clearqueue all')
  mmp.stop()

  Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
  Megophrys.updateMissionCtrlBar()
end

Megophrys.findTargetsInLine = function(match)
  if Megophrys.killStrat ~= 'raid' then return end
  local firstMatch = true
  if match then
    local line = getCurrentLine()
      for name, _ in pairs(cdb.db) do
        if name ~= target and line:match(name) then
          if firstMatch then
            cecho('\n<cyan>Click2Target: ')
            firstMatch = false
          end
          cechoPopup('<cyan>'.. name ..'  ',
            {
                function() Megophrys.setTarget(name) end,
                function() send('enemy '.. name) end
            }, {
                'Target '.. name,
                'Enemy '.. name
            })
        end
      end
  end
end

Megophrys.pursue = function()
  Megophrys.priorityLabel:echo('<center>Priority: PURSUIT</center>')
  if Megophrys.targetRoom then
    Megophrys.setGuidance('rushdown')
    gotoRoom(Megophrys.targetRoom)
    Megophrys.targetRoom = nil
  else
    local findCmd = ''
    if Megophrys.class == 'Magi' then
      findCmd = 'cast scry at '
    else
      findCmd = 'farsee '
    end
    if Megophrys.killStrat == 'raid' and Megophrys.raidLeader then
      send(findCmd .. Megophrys.raidLeader)
      Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
    elseif Megophrys.killStrat == 'denizen' and Megophrys.huntingGround then
      Megophrys.setGuidance('rushdown')
      send('walk to '.. Megophrys.huntingGround)
    else
      send(findCmd .. target)
      Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
    end
  end
  Megophrys.updateMissionCtrlBar()
end

Megophrys.resetCuringPrios = function(theseAffs)
  local cmd = 'curing priority'
  for priority, affList in spairs(Megophrys.prioDefault) do
    for _, aff in spairs(affList) do
      local addAff = true
      if theseAffs and type(theseAffs) == 'table' then
        addAff = false
        for _, selectedAff in pairs(theseAffs) do
          if selectedAff == aff then
            addAff = true
            break
          end
        end
      end
      if addAff then cmd = table.concat({cmd, aff, priority}, ' ') end
    end
    if priority % 10 == 0 and cmd ~= 'curing priority' then
      send(cmd)
      cmd = 'curing priority'
    end
  end
  if cmd ~= 'curing priority' then
    send(cmd)
  end
end

Megophrys.resetTargetWounds = function()
  cecho('\t<cyan>Resetting target wounds...\n')
  Megophrys.targetHits = 0
  lb.resetAll(target)
  Megophrys.limbHasBroken = false
  Megophrys.updatePrepGauges()
end

Megophrys.setEnemies = function(enemyList)
  Megophrys.enemies = {}
  disableTrigger('reject_forced_unenemy_all')
  send('unenemy all')
  for enemy in string.gmatch(enemyList, '[^, ]+') do
    if enemy ~= 'and' then
      Megophrys.enemies[#Megophrys.enemies + 1] = string.lower(enemy)
    end
  end
  send('enemy '.. table.concat(Megophrys.enemies, ' | enemy '))
  tempTimer(0.25, function()
    enableTrigger('reject_forced_unenemy_all')
  end)
end

Megophrys.setMode = function(mode)
  Megophrys.killStrat = string.lower(mode)
  Megophrys.modeButton:echo(string.title(Megophrys.killStrat),
                            Megophrys.fgColors[Megophrys.killStrat], 'c')
  if Megophrys.killStrat == 'denizen' then
    cecho('\n<cyan>Hunt mode activated as '.. Megophrys.class ..'!')

    wsys.unkeepup('mass', true)
    wsys.unkeepup('rebounding', true)
  elseif Megophrys.killStrat == 'raid' then
    cecho('\n<cyan>Raid mode activated as '.. Megophrys.class ..'!')

    if Megophrys.raidLeader then
      cecho('\n<cyan>Raid leader set to: '.. Megophrys.raidLeader ..'\n')
    end

    wsys.keepup('mass', true)
    wsys.keepup('rebounding', true)
  else  -- some pvp mode
    wsys.keepup('mass', true)
    wsys.keepup('rebounding', true)
  end

  Megophrys.priorityLabel = nil
  Megophrys.priorityLabel = Geyser.Label:new({
    name='priorityLabel',
    x='-1070px', y=0,
    width='150px', height='2%',
    fgColor=Megophrys.fgColors[Megophrys.killStrat], color='black',
    message='<center>Priority: IDLE</center>'
  })
  Megophrys.setTarget('none')
  Megophrys.highlightTargetRoom()
  Megophrys[Megophrys.class].setMode()
end

Megophrys.setGuidance = function(mode)
  Megophrys.eStopAuto('Mode switch')

  mode = string.lower(mode or '')
  if mode == 'fight' then
    Megophrys.autoAttacking = true
  elseif mode == 'flight' then
    Megophrys.autoEscaping = true
  elseif mode == 'diewithhonor' then
    Megophrys.autoResisting = true
  elseif mode == 'rushdown' then
    Megophrys.inPursuit = true
  elseif mode ~= 'idle' then
    cecho('\n<orange>Unknown mode: "'.. mode ..'"\n')
  end
end

Megophrys.setOpponentClass = function(cls)
  if Megophrys.killStrat == 'raid' or Megophrys.riposteUp then return end
  Megophrys.opponentClass = string.lower(tostring(cls))
end

Megophrys.setTarget = function(t)
  if t == 'none' then target = 'none' else
    target = string.title(string.lower(tostring(t)))
  end
  send('st '.. target)
  cecho('\n<cyan>Target changed to '.. target ..'.')
  Megophrys.resetTargetWounds()

  if target ~= 'none' and Megophrys.killStrat ~= 'raid' then
    send('curing priority reset')
  end

  if Megophrys.killStrat ~= 'denizen' and target ~= 'none' then
    ak.oresetparse()
    hideWindow('aff_display')
    if Megophrys.class == 'Magi' then
      sendAll('unally '.. target, 'enemy '.. target)
    end
  end

  -- set temp trigger to highlight the target string
  if hilite_trigger_id then killTrigger(hilite_trigger_id) end
  if hilite_trigger_id2 then killTrigger(hilite_trigger_id2) end

  hilite_target_func = function(needle)
    idx = 1
    done = false
    while not done do
      done = true
      lpos = selectString(needle, idx)
      if lpos ~= -1 then 
        Megophrys.Util.hiliteSelection('OrangeRed')
        done = false
      end
      idx = idx + 1
    end
  end
  hilite_trigger_id = tempTrigger(target:lower(), function() hilite_target_func(target:lower()) end)
  hilite_trigger_id2 = tempTrigger(target, function() hilite_target_func(target) end)

  Megophrys.targetLabel = nil
  Megophrys.targetLabel = Geyser.Label:new({
    name='targetLabel',
    x='-1070px', y='2%',
    width='150px', height='2%',
    fgColor=Megophrys.fgColors[Megophrys.killStrat], color='black',
    message='<center>Target: '.. target ..'</center>'
  })
end

Megophrys.setTargetHealth = function(hp, maxHp)
  if not Megophrys.targetHpGauge then
    Megophrys.targetHpGauge = Geyser.Gauge:new({
      name='targetHpGauge',
      x='-25%', y='43%',
      width='25%', height='3.5%'
    })
  end

  -- literally from https://wiki.mudlet.org/w/manual:geyser#Styling_a_gauge
  Megophrys.targetHpGauge.front:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #f04141, stop: 0.1 #ef2929, stop: 0.49 #cc0000, stop: 0.5 #a40000, stop: 1 #cc0000);
    border-top: 1px black solid;
    border-left: 1px black solid;
    border-bottom: 1px black solid;
    border-radius: 7;
    padding: 3px;]])
  Megophrys.targetHpGauge.back:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #bd3333, stop: 0.1 #bd2020, stop: 0.49 #990000, stop: 0.5 #700000, stop: 1 #990000);
    border-width: 1px;
    border-color: black;
    border-style: solid;
    border-radius: 7;
    padding: 3px;]])

  hp = tonumber(hp)
  maxHp = tonumber(maxHp)
  Megophrys.targetHealthPct = math.floor((hp / maxHp) * 100)

  Megophrys.targetHpGauge:setValue(hp, maxHp, '<center>'.. Megophrys.targetHealthPct ..'%')
end

Megophrys.setTargetMana = function(mp, maxMp)
  if not Megophrys.targetMpGauge then
    Megophrys.targetMpGauge = Geyser.Gauge:new({
      name='targetMpGauge',
      x='-25%', y='46.5%',
      width='25%', height='3.5%'
    })
  end

  -- literally from https://wiki.mudlet.org/w/manual:geyser#Styling_a_gauge
  Megophrys.targetMpGauge.front:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #98f041, stop: 0.1 #8cf029, stop: 0.49 #66cc00, stop: 0.5 #52a300, stop: 1 #66cc00);
    border-top: 1px black solid;
    border-left: 1px black solid;
    border-bottom: 1px black solid;
    border-radius: 7;
    padding: 3px;]])
  Megophrys.targetMpGauge.back:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #78bd33, stop: 0.1 #6ebd20, stop: 0.49 #4c9900, stop: 0.5 #387000, stop: 1 #4c9900);
    border-width: 1px;
    border-color: black;
    border-style: solid;
    border-radius: 7;
    padding: 3px;]])

  mp = tonumber(mp)
  maxMp = tonumber(maxMp)
  Megophrys.targetManaPct = math.floor((mp / maxMp) * 100)

  Megophrys.targetMpGauge:setValue(mp, maxMp, '<center>'.. Megophrys.targetManaPct ..'%')
end

Megophrys.stopAttack = function(reason)
  cecho('\n<cyan>'.. reason ..'. Disabling auto-attack.\n')
  if Megophrys.autoAttackTimerId then
    killTimer(Megophrys.autoAttackTimerId)
  end
  Megophrys.autoAttacking = false
  send('diag')
  Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
  Megophrys.updateMissionCtrlBar()
end

Megophrys.stopEscape = function(reason)
  cecho('\n<red>'.. reason ..'. Disabling auto-flight.\n')
  Megophrys.autoEscaping = false
  send('diag')
  Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
  Megophrys.updateMissionCtrlBar()
end

Megophrys.stopResist = function(reason)
  cecho('\n<red>'.. reason ..'. Disabling auto-resist.\n')
  Megophrys.autoResisting = false
  wsys.unkeepup('shield', true)
  if Megophrys.class == 'Magi' then
    wsys.unkeepup('reflections', true)
  end
  send('diag')
  Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
  Megophrys.updateMissionCtrlBar()
end

Megophrys.toggleDualPrep = function()
  Megophrys.dualPrep = not Megophrys.dualPrep

  if Megophrys.dualPrep then
    cecho('\n<cyan>Toggled to dual-limb prep!\n')
  else
    cecho('\n<cyan>Toggled to single-limb prep!\n')
  end

  Megophrys.updatePrepGauges()
end

Megophrys.toggleLimbsPrepped = function()
  local targetLimbSet = (Megophrys.targetLimbSet or 'leg')

  if targetLimbSet == 'leg' then
    targetLimbSet = 'arm'
    cecho('\n<cyan>Toggled to prepping arms!\n')
  else
    targetLimbSet = 'leg'
    cecho('\n<cyan>Toggled to prepping legs!\n')
  end

  Megophrys.targetLimbSet = targetLimbSet
  Megophrys.updatePrepGauges()
end

Megophrys.toggleSkipTorso = function()
  Megophrys.skipTorso = not Megophrys.skipTorso

  if Megophrys.class == 'Magi' then
    if Megophrys.skipTorso then
      cecho('\n<cyan>Skipping torso! (Only prepping leg(s).)\n')
    else
      cecho('\n<cyan>Prepping torso as well as leg(s).\n')
    end
  else
    if Megophrys.skipTorso then
      cecho('\n<cyan>Swapping gauge TORSO to HEAD.\n')
    else
      cecho('\n<cyan>Swapping gauge HEAD to TORSO.\n')
    end
  end

  Megophrys.updatePrepGauges()
end

Megophrys.toggleTargetLimb = function()
  if Megophrys.targetLimb == 'right' then
    Megophrys.targetLimb = 'left'
  else
    Megophrys.targetLimb = 'right'
  end
  Megophrys.targetLimbSet = Megophrys.targetLimbSet or 'leg'
  cecho('\n<cyan>Targetting '.. Megophrys.targetLimb ..' '.. Megophrys.targetLimbSet ..'.\n')
  Megophrys.updatePrepGauges()
end

Megophrys.toggleOne = nil
Megophrys.toggleTwo = Megophrys.toggleDualPrep
Megophrys.toggleThree = Megophrys.toggleTargetLimb
Megophrys.toggleFour = Megophrys.toggleSkipTorso
Megophrys.toggleFive = Megophrys.toggleLimbsPrepped
