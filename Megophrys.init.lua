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

-- adapted from Romaen's original list
Megophrys.prioDefault = {
  -- 1
  {"latched"},
  -- 2
  {"aeon", "anorexia", "crushedthroat", 
   "calcifiedskull", "calcifiedtorso"},
  -- 3
  {"paralysis", "heartseed", "skullfractures", "retribution",
   "grievouswounds"},
  -- 4
  {"impatience", "torntendons", "hypothermia", "unweavingbody",
   "unweavingmind", "unweavingspirit", "mindravaged", "mycalium"},
  -- 5
  {"itching", "lovers", "pacified", "peace", "scytherus", "hypochondria",
   "hellsight", "guilt"},
  -- 6
  {"entangled", "asthma", "weariness", "clumsiness", "sensitivity", 
   "shadowmadness", "tension", "flushings", "rebbies", "timeloop"},
  -- 7
  {"damagedrightleg", "damagedleftleg", "mangledrightleg", 
   "mangledleftleg", "concussion", "darkshade", "depression", 
   "tonguetied"},
  -- 8
  {"brokenrightleg", "brokenleftleg", "confusion", "hallucinations", 
   "hypersomnia", "pyramides"},
  -- 9
  {"mangledhead", "stupidity", "voyria", "slickness", "spiritburn", "tenderskin",
   "disrupted", "parasite", "sandfever"},
  -- 10
  {"brokenrightarm", "brokenleftarm", "wristfractures"},
  -- 11
  {"nausea", "haemophilia", "addiction", "lethargy", "whisperingmadness", "crackedribs"},
  -- 12
  {"damagedhead", "recklessness", "pressure"}, 
  -- 13
  {"damagedrightarm", "damagedleftarm", "healthleech", "manaleech", "temperedmelancholic",
   "temperedcholeric", "temperedsanguine", "temperedphlegmatic", "justice"},
  -- 14
  {"mangledrightarm", "mangledleftarm", "shyness", "dizziness", "disloyalty",
   "dissonance"},
  -- 15
  {"generosity", "deadening", "agoraphobia", "loneliness", "claustrophobia",
   "vertigo", "shivering", "frozen"},
  -- 16
  {"mildtrauma", "serioustrauma"},
  -- 17
  {"epilepsy"},
  -- 18
  {"slashedthroat", "laceratedthroat", "stuttering", "burning"},
  -- 19
  {"selarnia"},
  -- 20
  {"kkractlebrand", "bound", "daeggerimpale", "impaled", "transfixation", "webbed", "prone", "sleeping"},
}

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

Megophrys.onConnect = function()
  sendAll('health', 'mana')  -- reset power bars
  if Megophrys.class == 'Magi' then
    sendAll('simultaneity', 'bind all', 'fortify all')
  end
  Megophrys.setMode('denizen')
  Megophrys.resetCuringPrios()
  cecho('\n<cyan>Megophrys v1.1 initialised. Enjoy :)\n')
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

  Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
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
  send('enemy '.. table.concat(Megophrys.enemies, ' / enemy '))
  tempTimer(0.25, function()
    enableTrigger('reject_forced_unenemy_all')
  end)
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
      Magi.setElement('earth')
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
      if (Megophrys.targetHits or 0) % 3 == 0 then
        send('cast transfix at '.. target)
      else
        send('staffcast '.. staffCasts[Magi.element] ..' at '.. target)
      end
      Megophrys.targetHits = Megophrys.targetHits + 1
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
        if targetRebounding then
          Magi.setElement('air')
        else
          Magi.setElement('earth')
        end
      end
      
      local cmd = 'staffstrike '.. target ..' with '.. Magi.element
      
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
  cecho('\n<cyan>Targetting '.. Megophrys.targetLimb ..' leg.\n')
  Magi.updatePrepGauges()
end

Megophrys.flyingBlocked = function()
  if Megophrys.autoEscaping then
    send('golem barrier')
    Megophrys.stopEscape('Can\'t fly -- trying barrier')
  end
end

Megophrys.flyingSuccess = function()
  if Megophrys.autoEscaping then
    Megophrys.stopEscape('Flying (safe)')
  end
end

Megophrys.hitIcewall = function()
  if Megophrys.autoEscaping then
    if #gmcp.Room.Info.exits < 3 then
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
  Megophrys.priorityLabel:echo('<center>Priority: PURSUIT</center>')
  if Megophrys.targetRoom then
    if Megophrys.autoAttacking then
      Megophrys.stopAttack('Engaging pursuit')
    end
    if Megophrys.autoEscaping then
      Megophrys.stopEscape('Engaging pursuit')
    end
    gotoRoom(Megophrys.targetRoom)
    Megophrys.targetRoom = nil
  else
    if Megophrys.killStrat == 'raid' and Megophrys.raidLeader then
      send('cast scry at '.. Megophrys.raidLeader)
      Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
    elseif Megophrys.killStrat == 'denizen' and Megophrys.huntingGround then
      send('walk to '.. huntingGround)
    else
      send('cast scry at '.. target)
      Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
    end
  end
end

Megophrys.endSpeedwalk = function()
  Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
  if Megophrys.killStrat == 'raid' and Megophrys.raidLeader then
    sendAll('land', 'call elementals', 'golem return', 'fol '.. Megophrys.raidLeader)
  elseif Megophrys.killStrat == 'pummel' then
    sendAll('land', 'call elementals', 'golem return', 'fol '.. target)
    Megophrys.autoAttack()
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

Megophrys.stopEscape = function(reason)
  cecho('\n<red>'.. reason ..'. Disabling auto-flight.\n')
  Megophrys.autoEscaping = false
  send('diag')
  Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
end

Megophrys.tryExit = function(exitDir)
  cecho('\n<red>Fleeing '.. exitDir ..'!\n')
  send(exitDir)
  Megophrys.lastExitTried = exitDir
  Megophrys.locationsFled = Megophrys.locationsFled + 1
  tempTimer(0.5, Megophrys.autoEscape)
end

Megophrys.autoEscape = function(reset)
  if Megophrys.autoAttacking then
    Megpohrys.autoAttacking = false
  end

  if not gmcp.Room or not gmcp.Room.Info or not gmcp.Room.Info.exits then
    Megophrys.stopEscape('No exits detected')
    return
  end

  if reset == true then
    cecho('\nResetting auto-flight...\n')
    Megophrys.fleeingFromRoom = gmcp.Room.Info.num
    Megophrys.locationsFled = 0
    Megophrys.lastExitTried = 'none'
  end

  if Megophrys.locationsFled > 3 then
    send('cast aerial')
    return
  end

  Megophrys.autoEscaping = true
  Megophrys.priorityLabel:echo('<center>Priority: FLEE</center>')

  local exitInverse = {
    n='s', ne='sw', e='w', se='nw', s='n', sw='ne', w='e', nw='se',
    out='in', up='down', down='up', none=nil
  }
  exitInverse['in'] = 'out'  -- reserved word (in)

  local moved = false
  for exitDir, roomID in pairs(gmcp.Room.Info.exits) do
    if roomID ~= Megophrys.fleeingFromRoom and exitDir ~= exitInverse[Megophrys.lastExitTried] then
      Megophrys.tryExit(exitDir)
      moved = true
      break
    end
  end
  if not moved then
    Megophrys.stopEscape('Cornered! Manual retry if desired')
  end
end

Megophrys.updateBars = function(currHealth, currMana)
  if not Megophrys.hpGauge then
    Megophrys.hpGauge = Geyser.Gauge:new({
      name='hpGauge',
      x='-25%', y='70%',
      width='25%', height='3.5%'
    })
  end
  if not Megophrys.mpGauge then
    Megophrys.mpGauge = Geyser.Gauge:new({
      name='mpGauge',
      x='-25%', y='73.5%',
      width='25%', height='3.5%'
    })
  end
  if not Megophrys.affTable then
    Megophrys.affTable = Geyser.Label:new({
      name='affTable',
      x='-26%', y='77.5%',
      width='25%', height='7.5%',
      fgColor='white', color='black'
    })
  end

  -- literally from https://wiki.mudlet.org/w/manual:geyser#Styling_a_gauge
  Megophrys.hpGauge.front:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #f04141, stop: 0.1 #ef2929, stop: 0.49 #cc0000, stop: 0.5 #a40000, stop: 1 #cc0000);
    border-top: 1px black solid;
    border-left: 1px black solid;
    border-bottom: 1px black solid;
    border-radius: 7;
    padding: 3px;]])
  Megophrys.hpGauge.back:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #bd3333, stop: 0.1 #bd2020, stop: 0.49 #990000, stop: 0.5 #700000, stop: 1 #990000);
    border-width: 1px;
    border-color: black;
    border-style: solid;
    border-radius: 7;
    padding: 3px;]])

  Megophrys.mpGauge.front:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #98f041, stop: 0.1 #8cf029, stop: 0.49 #66cc00, stop: 0.5 #52a300, stop: 1 #66cc00);
    border-top: 1px black solid;
    border-left: 1px black solid;
    border-bottom: 1px black solid;
    border-radius: 7;
    padding: 3px;]])
  Megophrys.mpGauge.back:setStyleSheet([[background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #78bd33, stop: 0.1 #6ebd20, stop: 0.49 #4c9900, stop: 0.5 #387000, stop: 1 #4c9900);
    border-width: 1px;
    border-color: black;
    border-style: solid;
    border-radius: 7;
    padding: 3px;]])

  local fmtPctLabel = function(portion, maxAmt)
    return ('<center>'..
            tostring(math.floor(((portion / maxAmt) * 100) + 0.5))..
            '%</center>')
  end

  local maxhp = tonumber(gmcp.Char.Vitals.maxhp)
  local maxmp = tonumber(gmcp.Char.Vitals.maxmp)
  local healthPct = fmtPctLabel(currHealth, maxhp)
  local manaPct = fmtPctLabel(currMana, maxmp)
  Megophrys.hpGauge:setValue(currHealth, maxhp, healthPct)
  Megophrys.mpGauge:setValue(currMana, maxmp, manaPct)

  local affTable = '<center><b>Afflictions:</b><ul>'
  local anyAffs = false
  for _, affName in pairs(wsys.aff) do
    anyAffs = true
    affTable = affTable ..'<li>'.. affName ..'</li>'
  end
  if not anyAffs then affTable = affTable ..'<li>N/A</li>' end
  affTable = affTable ..'</ul></center>'
  Megophrys.affTable:echo(affTable)
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
    if string.lower(foundPlayer) == string.lower(target) then
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
