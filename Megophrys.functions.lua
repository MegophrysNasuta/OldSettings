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
  send('lose '.. target)
  gotoRoom(Megophrys.fleeingToRoom)
end

Megophrys.autoResist = function()
  Megophrys.autoResisting = true
  Megophrys.setGuidance('DieWithHonor')
  Megophrys.priorityLabel:echo('<center>Priority: HEAL</center>')
  wsys.keepup('shield', true)
  if Megophrys.class == 'Magi' then
    wsys.keepup('reflections', true)
  end
  if Megophrys.class == 'Alchemist' then
    send('educe tin')
  end
end

Megophrys.dgradient = function(text, fgColorTable, bgColorTable)
  if type(fgColorTable) ~= "table" then
    error("Argument #2 expects a table not ".. type(fgColorTable))
  end
  if type(bgColorTable) ~= "table" then
    error("Argument #3 expects a table not ".. type(bgColorTable))
  end

  if #fgColorTable > 1 and #bgColorTable > 1 and #fgColorTable ~= #bgColorTable then
    error("Please use the same number of colors for both foreground "..
          "and background gradients.")
  end

  if #fgColorTable == 1 and #bgColorTable > 1 then
    for i=2, #bgColorTable do
      fgColorTable[i] = fgColorTable[1]
    end
  elseif #bgColorTable == 1 and #fgColorTable > 1 then
    for i=2, #fgColorTable do
      bgColorTable[i] = bgColorTable[1]
    end
  end

  local lenGradient = #fgColorTable
  if lenGradient > #text then
    error("Text provided is too short for this gradient!")
  end

  local _dgradient = Megophrys.Util._dgradient

  if lenGradient > 1 then
    -- switch colors every nth character (rounded to integer b/c no half characters)
    local interval = math.floor((#text / (lenGradient - 1)) + 0.5)
    local resultStr = ''
    for i=1, lenGradient - 1 do
      local chunk = string.sub(text, (interval * (i - 1)) + 1, interval * i)
      resultStr = resultStr .. _dgradient(chunk,
                                          fgColorTable[i],
                                          fgColorTable[i + 1],
                                          bgColorTable[i],
                                          bgColorTable[i + 1])
    end
    return resultStr
  else
    return fgColorTable[1] ..','.. bgColorTable[1].gsub('#', '') .. text
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
        if (name ~= target and line:match('\b'.. name ..'\b') and
                _.city ~= gmcp.Char.Status.city:lower():split(' ')[1]) then
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

Megophrys.goDir = function(direction)
  Megophrys.lastDirTried = direction
  sendAll('clearqueue all', direction)
end

Megophrys.nextLimbPrepAttack = function(onKillConditionAttack,
                                        limbPrepThreshold,
                                        limbUnderPrepThreshold)
  if Megophrys.killPreConditionsMet then
    return {
      targetLimb = Megophrys.targetLimb,
      targetTorso = true
    }
  end

  local otherLimb = ''
  local targetTorso = false
  local limbIsBroken = false
  local limbIsPrepped = false
  local limbIsUnderPrepped = false
  local otherLimbIsBroken = false
  local otherLimbIsPrepped = false
  local otherLlimbIsUnderPrepped = false
  local torsoIsBroken = false
  local torsoIsPrepped = false
  local torsoIsUnderPrepped = false
  local targetWounds = lb[target].hits
  local targetLimb = Megophrys.targetLimb
  local skipTorso = Megophrys.skipTorso
  local dualPrep = Megophrys.dualPrep
  local prepConditionsMet = false

  if limbPrepThreshold then
    limbPrepThreshold = tonumber(limbPrepThreshold)
  else
    limbPrepThreshold = 91
  end

  if limbUnderPrepThreshold then
    limbUnderPrepThreshold = tonumber(limbUnderPrepThreshold)
  else
    limbUnderPrepThreshold = 99   -- disable feature
  end

  if targetLimb then
    local targetLimbDmg = (targetWounds[targetLimb ..' leg'] or 0)
    if targetLimbDmg >= 100 then
      limbIsBroken = true
      cecho('\n<gold>LIMB IS BROKEN!\n')
    elseif targetLimbDmg >= limbPrepThreshold then
      limbIsPrepped = true
      cecho('\n<gold>LIMB IS PREPPED!\n')
    elseif targetLimbDmg >= limbUnderPrepThreshold then
      limbIsUnderPrepped = true
    end

    if targetLimb == 'right' then
      otherLimb = 'left'
    else
      otherLimb = 'right'
    end

    local otherLimbDmg = (targetWounds[otherLimb ..' leg'] or 0)
    if otherLimbDmg >= 100 then
      otherLimbIsBroken = true
      cecho('\n<gold>OTHER LIMB IS BROKEN!\n')
    elseif otherLimbDmg >= limbPrepThreshold then
      otherLimbIsPrepped = true
      cecho('\n<gold>OTHER LIMB IS PREPPED!\n')
    elseif otherLimbDmg >= limbUnderPrepThreshold then
      otherLimbIsUnderPrepped = true
    end
  end

  if not skipTorso then
    local targetTorsoDmg = (targetWounds.torso or 0)
    if targetTorsoDmg >= 100 then
      torsoIsBroken = true
      cecho('\n<gold>TORSO IS BROKEN!\n')
    elseif targetTorsoDmg >= limbPrepThreshold then
      torsoIsPrepped = true
      cecho('\n<gold>TORSO IS PREPPED!\n')
    elseif targetTorsoDmg >= limbUnderPrepThreshold then
      torsoIsUnderPrepped = true
    end
  end

  if limbIsPrepped then
    if dualPrep and not otherLimbIsPrepped then
      -- switch legs
      Megophrys.priorityLabel:echo('<center>Priority: LIMB 2 PREP</center>')
      targetLimb = otherLimb
    elseif not skipTorso and not torsoIsPrepped then
      -- work on prepping torso once limb is done
      Megophrys.priorityLabel:echo('<center>Priority: TORSO PREP</center>')
      targetTorso = true
    else
      -- otherwise start breaks / proning
      Megophrys.priorityLabel:echo('<center>Priority: L2 BREAKS</center>')
      prepConditionsMet = true
      targetTorso = false
    end
  elseif limbIsBroken or Megophrys.limbHasBroken then
    Megophrys.limbHasBroken = true
    Megophrys.killPreConditionsMet = true

    if dualPrep and not otherLimbIsBroken then
      targetLimb = otherLimb
      Megophrys.killPreConditionsMet = false
    elseif not skipTorso and not torsoIsBroken then
      targetTorso = true
      Megophrys.killPreConditionsMet = false
    end

    if Megophrys.killPreConditionsMet and onKillConditionAttack then
      Megophrys.nextMoveButton:echo(tostring(onKillConditionAttack):title(),
                                    Megophrys.fgColors[killStrat], 'c')
    end
  else
    Megophrys.priorityLabel:echo('<center>Priority: LIMB PREP</center>')
  end

  return {
    targetLimb = targetLimb,
    targetTorso = targetTorso,
    limbIsPrepped = limbIsPrepped,
    limbIsUnderPrepped = limbIsUnderPrepped,
    otherLimbIsPrepped = otherLimbIsPrepped,
    otherLimbIsUnderPrepped = otherLimbIsUnderPrepped,
    torsoIsPrepped = torsoIsPrepped,
    torsoIsUnderPrepped = torsoIsUnderPrepped,
    prepConditionsMet = prepConditionsMet
  }
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
  elseif Megophrys.killStrat == 'los' then
    cecho('\n<cyan>LoS mode activated as '.. Megophrys.class ..'!')

    if Megophrys.LOSDirection then
      cecho('\n<cyan>LoS direction set to: '.. Megophrys.LOSDirection ..'\n')
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
    x='36%', y=0,
    width='14%', height='2%',
    fgColor=Megophrys.fgColors[Megophrys.killStrat], color='black',
    message='<center>Priority: IDLE</center>'
  })
  Megophrys.priorityLabel:setFontSize(11)
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

  if target ~= 'none' then
    hilite_trigger_id = tempTrigger(target:lower(), function()
        hilite_target_func(target:lower())
    end)
    hilite_trigger_id2 = tempTrigger(target, function()
        hilite_target_func(target)
    end)
    send('tunnelvision on '.. target)
  else
    send('tunnelvision off')
  end

  Megophrys.targetLabel = nil
  Megophrys.targetLabel = Geyser.Label:new({
    name='targetLabel',
    x='36%', y='2%',
    width='14%', height='2%',
    fgColor=Megophrys.fgColors[Megophrys.killStrat], color='black',
    message='<center>Target: '.. target ..'</center>'
  })
  Megophrys.targetLabel:setFontSize(11)
end

Megophrys.shout = function(message, color)
  if not color then color = 'red' end
  local remaining_len = (78 - message:len()) / 2
  local top_line = '╔'.. string.rep('═', 78) ..'╗'
  local bottom_line = '╚'.. string.rep('═', 78) ..'╝'
  local left_side = '║'.. string.rep(' ', remaining_len)
  local right_side = string.rep(' ', remaining_len) ..'║'
  if message:len() % 2 == 1 then
    right_side = ' '.. right_side
  end

  cecho('\n<'.. color ..'>'.. top_line)
  cecho('\n<'.. color ..'>'.. left_side .. message:upper() .. right_side)
  cecho('\n<'.. color ..'>'.. left_side .. message:upper() .. right_side)
  cecho('\n<'.. color ..'>'.. left_side .. message:upper() .. right_side)
  cecho('\n<'.. color ..'>'.. bottom_line)
end

Megophrys.stopAttack = function(reason)
  if type(reason) == 'table' then reason = 'Clicked STOP' end
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
  if type(reason) == 'table' then reason = 'Clicked STOP' end
  cecho('\n<red>'.. reason ..'. Disabling auto-flight.\n')
  Megophrys.autoEscaping = false
  send('diag')
  Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
  Megophrys.updateMissionCtrlBar()
end

Megophrys.stopResist = function(reason)
  if type(reason) == 'table' then reason = 'Clicked STOP' end
  cecho('\n<red>'.. tostring(reason) ..'. Disabling auto-resist.\n')
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

Megophrys.tumbleRandom = function()
  local stopTrying = false
  local lastDir = nil
  for dir, roomID in pairs(gmcp.Room.Info.exits) do
    if math.random(1, 2) % 2 == 0 then
      send('tumble '.. dir)
      stopTrying = true
      break
    end
    lastDir = dir
  end
  if not stopTrying then send('tumble '.. lastDir) end
end
