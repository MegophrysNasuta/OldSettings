Megophrys = (Megophrys or {})
Megophrys.class = gmcp.Char.Status.class
Megophrys.targetLimb = (Megophrys.targetLimb or 'left')
Megophrys.targetRebounding = (Megophrys.targetRebounding or false)
Megophrys.targetProne = (Megophrys.targetProne or false)

Megophrys.fgColors = {
  denizen = 'cyan',
  raid = 'orange',
  pummel = 'yellow',
  fiyah = 'yellow',
}

Megophrys.targetPriority = {
  anaconda = 1,
  aphid = 1,
  bass = 1,
  crocodile = 1,
  drunk = 1,
  eel = 1,
  flies = 1,
  lion = 1,
  man = 1,
  moccasin = 1,
  muskrat = 1,
  owl = 1,
  scorpion = 1,
  squid = 1,
  stingray = 1,
  vulture = 1,
  weasel = 1,
  zombie = 1,
  blacksmith = 2,
  buckawn = 2,
  cook = 2,
  firetender = 2,
  ghaser = 2,
  gour = 2,
  guard = 2,
  hydra = 2,
  lynx = 2,
  orc = 2,
  rakrr = 2,
  shark = 2,
  slugbeast = 2,
  snake = 2,
  trag = 2,
  weaponsmith = 2,
  xabat = 2,
  aldroga = 3,
  ghoul = 3,
  huntress = 3,
  mage = 3,
  noble = 3,
  ogre = 3,
  rurnog = 3,
  soldier = 4,
  warrior = 3,
  witchdoctor = 3,
  captain = 4,
  dynas = 4,
  knight = 4,
  lord = 4,
  sentry = 4,
  ulvna = 4,
  vewig = 4
}

Megophrys.targetPriority["tap'choa"] = 4
Megophrys.targetPriority["log'obi"] = 4
Megophrys.targetPriority["ver'osi"] = 4

Megophrys.autoSelectHuntingTarget = function()
  if Megophrys.killStrat == 'denizen' then
    enableTrigger('Megophrys_autotarget_IH')
    Megophrys.potentialTargets = {}
    send('info here')

    tempTimer(0.5, function()
      disableTrigger('Megophrys_autotarget_IH')
      local highestPrioSeen = 0
      local finalTarget = nil
      local potentialTargets = Megophrys.potentialTargets
      local targetPriority = Megophrys.targetPriority
      for _, tgt in pairs(potentialTargets) do
        local simpleTgt = tgt:gsub('%d', '')
        if (targetPriority[simpleTgt] or 0) > highestPrioSeen then
          highestPrioSeen = targetPriority[simpleTgt]
          finalTarget = simpleTgt
        end
      end
      if finalTarget then
        Megophrys.setTarget(finalTarget)
        Megophrys.autoAttack()
      end
    end)
  end
end

Megophrys.autoSelectHuntingTargetLine = function(matches)
  if matches[2] == 'hippogriff' and matches[3] == '552688' then
    -- mount, pass
  elseif matches[2] == 'golem' then
    -- golem, pass
  else
    if (gmcp.Room.Info.area == 'the village of Qurnok' or
        gmcp.Room.Info.area == 'Forest Watch' or
        gmcp.Room.Info.area == 'the Creville Asylum' or
        gmcp.Room.Info.area == 'the Barony of Dun Valley' or
        gmcp.Room.Info.area == 'Quartz Peak' or
        gmcp.Room.Info.area == 'the ruins of Phereklos' or
        gmcp.Room.Info.area == 'the Mhojave Desert' or
        gmcp.Room.Info.area == 'Tir Murann') then
      if (matches[2] ~= 'toad' and
          matches[4] ~= 'a buckawn youth' and
          matches[4] ~= 'a juvenile orc' and
          matches[4] ~= 'an adolescent ogre' and
          matches[4] ~= 'a phantom grizzly bear' and
          matches[4] ~= 'a miniature snowy owl') then
        Megophrys.potentialTargets[#Megophrys.potentialTargets + 1] = matches[2]..matches[3]
      end
    end
  end
end

Megophrys.assess = function(person)
  if person then
    send('assess '.. person ..' | contemplate '.. person)
  else
    send('assess '.. target ..' | contemplate '.. target)
  end
end

-- adapted from Romaen's original list
Megophrys.prioDefault = {
  -- 1
  {"latched", "sleeping", "prone"},
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
  {"kkractlebrand", "bound", "daeggerimpale", "impaled", "transfixation", "webbed"},
}

Megophrys.makeClassToolbars = function()
  Megophrys.modeToolbar = Geyser.Container:new({
    name='mode_switches',
    x=0, y=0, width=200, height=16
  })

  if Megophrys.magiToolbar then
    Megophrys.magiToolbar:hide()
  end

  if Megophrys.psionToolbar then
    Megophrys.psionToolbar:hide()
  end

  Megophrys.modeLabel = Geyser.Label:new({
    name='mode_label',
    x=0, y=0, width=70, height=20,
    bgColor='black',
    message='AI Mode:'
  }, Megophrys.modeToolbar)
  Megophrys.modeButton = Geyser.Label:new({
    name='current_mode',
    x=70, y=0, width=130, height=20,
    bgColor='black'
  }, Megophrys.modeToolbar)

  Megophrys.nextMoveLabel = Geyser.Label:new({
    name='next_move_label',
    x=0, y=20, width=70, height=20,
    bgColor='black',
    message='Next move:'
  }, Megophrys.modeToolbar)
  Megophrys.nextMoveButton = Geyser.Label:new({
    name='next_move',
    x=70, y=20, width=130, height=20,
    bgColor='black'
  }, Megophrys.modeToolbar)

  Megophrys.specialMoveLabel = Geyser.Label:new({
    name='special_label',
    x=0, y=40, width=70, height=20,
    bgColor='black',
    message='Special:'
  }, Megophrys.modeToolbar)
  Megophrys.specialMoveButton = Geyser.Label:new({
    name='special_move',
    x=70, y=40, width=130, height=20,
    bgColor='black'
  }, Megophrys.modeToolbar)

  if Megophrys.targetHpGauge then Megophrys.targetHpGauge:hide() end
  if Megophrys.targetMpGauge then Megophrys.targetMpGauge:hide() end
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

Megophrys.autoAttack = function()
  Megophrys.setGuidance('fight')
  cecho('\n<cyan>Commencing auto-attack with '.. Megophrys.class ..'...\n')
  Megophrys.priorityLabel:echo('<center>Priority: DAMAGE</center>')
  Megophrys.updateMissionCtrlBar()
  Megophrys[Megophrys.class].nextAttack()
end

Megophrys.autoEscape = function()
  Megophrys.setGuidance('flight')

  if Megophrys.class == 'Psion' then
    send('queue prepend eqbal enact wavesurge')
  else
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
end

Megophrys.autoResist = function()
  if not Megophrys.autoResisting then
    Megophrys.autoResisting = true
    Megophrys.setGuidance('DieWithHonor')
    Megophrys.priorityLabel:echo('<center>Priority: HEAL</center>')
    wsys.keepup('shield', true)
    wsys.keepup('reflections', true)
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

Megophrys.pursue = function()
  Megophrys.priorityLabel:echo('<center>Priority: PURSUIT</center>')
  if Megophrys.targetRoom then
    Megophrys.setGuidance('rushdown')
    gotoRoom(Megophrys.targetRoom)
    Megophrys.targetRoom = nil
  else
    if Megophrys.killStrat == 'raid' and Megophrys.raidLeader then
      send('cast scry at '.. Megophrys.raidLeader)
      Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
    elseif Megophrys.killStrat == 'denizen' and Megophrys.huntingGround then
      Megophrys.setGuidance('rushdown')
      send('walk to '.. Megophrys.huntingGround)
    else
      send('cast scry at '.. target)
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
    sendAll('unally '.. target, 'enemy '.. target)
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
  killTimer(Megophrys.autoAttackTimerId)
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
  wsys.unkeepup('reflections', true)
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
  cecho('\n<cyan>Targetting '.. Megophrys.targetLimb ..' '.. Megophrys.targetLimbSet ..'.\n')
  Megophrys.updatePrepGauges()
end

Megophrys.updateBars = function()
  if not Megophrys.hpGauge then
    Megophrys.hpGauge = Geyser.Gauge:new({
      name='hpGauge',
      x='-25%', y=0,
      width='25%', height='3.5%'
    })
  end
  if not Megophrys.mpGauge then
    Megophrys.mpGauge = Geyser.Gauge:new({
      name='mpGauge',
      x='-25%', y='3.5%',
      width='25%', height='3.5%'
    })
  end
  if not Megophrys.affTable then
    Megophrys.affTable = Geyser.Label:new({
      name='affTable',
      x='-450px', y='7%',
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

  local currHealth = tonumber(gmcp.Char.Vitals.hp)
  local currMana = tonumber(gmcp.Char.Vitals.mp)
  local maxhp = tonumber(gmcp.Char.Vitals.maxhp)
  local maxmp = tonumber(gmcp.Char.Vitals.maxmp)
  local healthPct = fmtPctLabel(currHealth, maxhp)
  local manaPct = fmtPctLabel(currMana, maxmp)
  Megophrys.hpGauge:setValue(currHealth, maxhp, healthPct)
  Megophrys.mpGauge:setValue(currMana, maxmp, manaPct)

  local affTable = '<center><b>Afflictions:</b><ul>'
  if Megophrys.opponentClass then
    affTable = '<center><b>Afflictions: ('.. Megophrys.opponentClass ..'):</b><ul>'
  end
  local anyAffs = false
  for aff, _ in pairs(wsysf.affs) do
    if (aff ~= 'blindness' and aff ~= 'deafness' and
        aff ~= 'insomnia') then
      anyAffs = true
      affTable = affTable ..'<li>'.. aff ..'</li>'
    end
  end
  if not anyAffs then affTable = affTable ..'<li>N/A</li>' end
  affTable = affTable ..'</ul></center>'
  Megophrys.affTable:echo(affTable)
end

Megophrys.updateMissionCtrlBar = function()
  Megophrys.atkBtn = nil
  Megophrys.fleeBtn = nil
  Megophrys.chaseBtn = nil
  Megophrys.stopBtn = nil

  local doin_stuff = false

  Megophrys.atkBtn = Geyser.Label:new({
    name="attackButton",
    x="35%", y="6%",
    width="7.5%", height="7.5%",
    fgColor="white",
    message="<center>ATTACK</center>"
  })
  Megophrys.atkBtn:setFontSize(18)
  if Megophrys.autoAttacking then
    doin_stuff = true
    Megophrys.atkBtn:setStyleSheet([[
      background-color: firebrick;
      border-radius: 12px;
      border: 4px inset crimson;
      font-weight: bold;
    ]])
  else
    Megophrys.atkBtn:setStyleSheet([[
      background-color: crimson;
      border-radius: 12px;
      border: 4px outset firebrick;
      font-weight: bold;
    ]])
  end
  Megophrys.atkBtn:setClickCallback("Megophrys.autoAttack")

  Megophrys.fleeBtn = Geyser.Label:new({
    name="fleeButton",
    x="42.5%", y="6%",
    width="7.5%", height="7.5%",
    fgColor="white",
    message="<center>FLEE</center>"
  })
  Megophrys.fleeBtn:setFontSize(18)
  if Megophrys.autoEscaping then
    doin_stuff = true
    Megophrys.fleeBtn:setStyleSheet([[
      background-color: darkorange;
      border-radius: 12px;
      border: 4px inset orange;
      font-weight: bold;
    ]])
  else
    Megophrys.fleeBtn:setStyleSheet([[
      background-color: goldenrod;
      border-radius: 12px;
      border: 4px outset darkgoldenrod;
      font-weight: bold;
    ]])
  end
  Megophrys.fleeBtn:setClickCallback("Megophrys.autoEscape", 1)

  Megophrys.chaseBtn = Geyser.Label:new({
    name="chaseButton",
    x="50%", y="6%",
    width="7.5%", height="7.5%",
    fgColor="white",
    message="<center>PURSUE</center>"
  })
  Megophrys.chaseBtn:setFontSize(18)
  if Megophrys.inPursuit then
    doin_stuff = true
    Megophrys.chaseBtn:setStyleSheet([[
      background-color: darkgreen;
      border-radius: 12px;
      border: 4px inset forestgreen;
      font-weight: bold;
    ]])
  else
    Megophrys.chaseBtn:setStyleSheet([[
      background-color: green;
      border-radius: 12px;
      border: 4px outset darkgreen;
      font-weight: bold;
    ]])
  end
  Megophrys.chaseBtn:setClickCallback("Megophrys.pursue")

  Megophrys.resistBtn = Geyser.Label:new({
    name="resistButton",
    x="57.5%", y="6%",
    width="7.5%", height="7.5%",
    fgColor="white",
    message="<center>RESIST</center>"
  })
  Megophrys.resistBtn:setFontSize(18)
  if Megophrys.autoResisting then
    doin_stuff = true
    Megophrys.resistBtn:setStyleSheet([[
      background-color: midnightblue;
      border-radius: 12px;
      border: 4px inset navy;
      font-weight: bold;
    ]])
  else
    Megophrys.resistBtn:setStyleSheet([[
      background-color: mediumblue;
      border-radius: 12px;
      border: 4px outset navy;
      font-weight: bold;
    ]])
  end
  Megophrys.resistBtn:setClickCallback("Megophrys.autoResist")

  Megophrys.stopBtn = Geyser.Label:new({
    name="stopButton",
    x="65%", y="6%",
    width="7.5%", height="7.5%",
    fgColor="white",
    message="<center>STOP</center>"
  })
  Megophrys.stopBtn:setFontSize(18)
  if doin_stuff then
    Megophrys.stopBtn:setStyleSheet([[
      background-color: #444;
      border-radius: 12px;
      border: 4px outset #333;
      font-weight: bold;
    ]])
  else
    Megophrys.stopBtn:setStyleSheet([[
      background-color: #222;
      border-radius: 12px;
      border: 4px inset #333;
      font-weight: bold;
    ]])
  end
  Megophrys.stopBtn:setClickCallback("Megophrys.eStopAuto")
end

Megophrys.updatePrepGauges = function()
  if not Megophrys.topGauge then
    Megophrys.topGauge = Geyser.Gauge:new({
      name='topGauge',
      x='-915px', y=0,
      width='150px', height='2%'
    })
  end
  if not Megophrys.middleGauge then
    Megophrys.middleGauge = Geyser.Gauge:new({
      name='middleGauge',
      x='-915px', y='2%',
      width='150px', height='2%'
    })
  end
  if not Megophrys.bottomGauge then
    Megophrys.bottomGauge = Geyser.Gauge:new({
      name='bottomGauge',
      x='-915px', y='4%',
      width='150px', height='2%'
    })
  end
  local targetLimb = (Megophrys.targetLimb or 'left')
  local targetLimbSet = (Megophrys.targetLimbSet or 'leg')
  local otherLimb = ''

  if targetLimb == 'right' then
    otherLimb = 'left'
  else
    otherLimb = 'right'
  end

  local topLabel = targetLimb:upper() ..' '.. targetLimbSet:upper()
  local middleLabel = 'NONE'
  local bottomLabel = ''
  local targetLimbWounds = 0
  local otherLimbWounds = 0
  local targetOtherWounds = 0

  if Megophrys.skipTorso then
    if Megophrys.class == 'Magi' then
      bottomLabel = 'TORSO*'
    else
      bottomLabel = 'HEAD'
    end
  else
    bottomLabel = 'TORSO'
  end

  if lb[target] then
    targetLimbWounds = lb[target].hits[targetLimb ..' '.. targetLimbSet]
    otherLimbWounds = lb[target].hits[otherLimb ..' '.. targetLimbSet]
    if Megophrys.class == 'Psion' then
      targetOtherWounds = lb[target].hits.head
    else
      targetOtherWounds = lb[target].hits.torso
    end
  end
  if Megophrys.dualPrep then
    middleLabel = otherLimb:upper() ..' '.. targetLimbSet:upper()
  end
  Megophrys.topGauge:setValue(targetLimbWounds, 100, '<center>'.. topLabel ..'</center>')
  Megophrys.middleGauge:setValue(otherLimbWounds, 100, '<center>'.. middleLabel ..'</center>')
  Megophrys.bottomGauge:setValue(targetOtherWounds, 100, '<center>'.. bottomLabel ..'</center>')
end

Megophrys.toggleOne = nil
Megophrys.toggleTwo = Megophrys.toggleDualPrep
Megophrys.toggleThree = Megophrys.toggleTargetLimb
Megophrys.toggleFour = Megophrys.toggleSkipTorso
Megophrys.toggleFive = Megophrys.toggleLimbsPrepped
