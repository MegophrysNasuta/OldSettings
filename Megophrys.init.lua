Megophrys = (Megophrys or {})
Megophrys.class = nil
Megophrys.shieldIsUp = (Megophrys.shieldIsUp or false)
Megophrys.targetLimb = (Megophrys.targetLimb or 'left')
Megophrys.targetRebounding = (Megophrys.targetRebounding or false)
Megophrys.targetProne = (Megophrys.targetProne or false)

Megophrys.fgColors = {
  denizen = 'cyan',
  raid = 'orange',
  pummel = 'yellow',
  fiyah = 'yellow',
}

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
end

Megophrys.setGuidance = function(mode)
  Megophrys.autoAttacking = false
  Megophrys.autoEscaping = false
  Megophrys.autoResisting = false
  Megophrys.inPursuit = false

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
  Megophrys.setGuidance('DieWithHonor')
  Megophrys.priorityLabel:echo('<center>Priority: HEAL</center>')
  
  wsys.keepup('shield', true)
  wsys.keepup('reflections', true)
end

Megophrys.eStopAuto = function()
  if Megophrys.autoAttacking then
    cecho('\n<red>Emergency stop: No more auto-attacks.\n')
    Megophrys.stopAttack('Emergency stop lever')
  end
  if Megophrys.autoEscaping then
    Megophrys.stopEscape('Emergency stop lever')
  end
  if Megophrys.autoResisting then
    Megophrys.stopResist('Emergency stop lever')
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
  send('enemy '.. table.concat(Megophrys.enemies, ' / enemy '))
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
    sendAll('unally '.. target, 'enemy '.. target)
  end

  -- set temp trigger to highlight the target string
  if hilite_trigger_id then killTrigger(hilite_trigger_id) end
  hilite_trigger_id = tempTrigger(target, function() 
    idx = 1
    done = false
    while not done do
      done = true
      lpos = selectString(string.lower(t), idx)
      if lpos ~= -1 then 
        Megophrys.Util.hiliteSelection('red')
        done = false
      end
      lpos = selectString(target, idx)
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
    x='-1070px', y='2%',
    width='150px', height='2%',
    fgColor=Megophrys.fgColors[Megophrys.killStrat], color='black',
    message='<center>Target: '.. target ..'</center>'
  })
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

Megophrys.toggleSkipTorso = function()
  Megophrys.skipTorso = not Megophrys.skipTorso

  if Megophrys.skipTorso then
    cecho('\n<cyan>Skipping torso! (Only prepping leg(s).)\n')
  else
    cecho('\n<cyan>Prepping torso as well as leg(s).\n')
  end

  Megophrys.updatePrepGauges()
end

Megophrys.toggleTargetLimb = function()
  if Megophrys.targetLimb == 'right' then
    Megophrys.targetLimb = 'left'
  else
    Megophrys.targetLimb = 'right'
  end
  cecho('\n<cyan>Targetting '.. Megophrys.targetLimb ..' leg.\n')
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
  if not Megophrys.limbGauge then
    Megophrys.limbGauge = Geyser.Gauge:new({
      name='limbGauge',
      x='-915px', y=0,
      width='150px', height='2%'
    })
  end
  if not Megophrys.otherLimbGauge then
    Megophrys.otherLimbGauge = Geyser.Gauge:new({
      name='otherLimbGauge',
      x='-915px', y='2%',
      width='150px', height='2%'
    })
  end
  if not Megophrys.torsoGauge then
    Megophrys.torsoGauge = Geyser.Gauge:new({
      name='torsoGauge',
      x='-915px', y='4%',
      width='150px', height='2%'
    })
  end
  local targetLimb = Megophrys.targetLimb
  local otherLimb = ''

  if targetLimb == 'right' then
    otherLimb = 'left'
  else
    otherLimb = 'right'
  end

  local targetLimbWounds = 0
  local otherLimbWounds = 0
  local targetTorsoWounds = 0
  if lb[target] then
    targetLimbWounds = lb[target].hits[targetLimb ..' leg']
    otherLimbWounds = lb[target].hits[otherLimb ..' leg']
    targetTorsoWounds = lb[target].hits.torso
  end
  local limbLabel = '<center>'.. string.upper(targetLimb) ..' LEG</center>'
  local otherLimbLabel = '<center>NONE</center>'
  local torsoLabel = ''
  if Megophrys.skipTorso then
    torsoLabel = '<center>TORSO</center>'
  else
    torsoLabel = '<center>TORSO*</center>'
  end
  if Megophrys.dualPrep then
    otherLimbLabel = '<center>'.. string.upper(otherLimb) ..' LEG</center>'
  end
  Megophrys.limbGauge:setValue(targetLimbWounds, 100, limbLabel)
  Megophrys.otherLimbGauge:setValue(otherLimbWounds, 100, otherLimbLabel)
  Megophrys.torsoGauge:setValue(targetTorsoWounds, 100, torsoLabel)
end
