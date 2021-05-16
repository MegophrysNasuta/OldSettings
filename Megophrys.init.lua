Megophrys = (Megophrys or {})
Megophrys.class = (Megophrys.class or 'Magi')
Megophrys.locationsFled = (Megophrys.locationsFled or 0)
Megophrys.targetLimb = (Megophrys.targetLimb or 'left')
Megophrys.targetRebounding = (Megophrys.targetRebounding or false)
Megophrys.targetProne = (Megophrys.targetProne or false)

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
      send('walk to '.. Megophrys.huntingGround)
    else
      send('cast scry at '.. target)
      Megophrys.priorityLabel:echo('<center>Priority: IDLE</center>')
    end
  end
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
  Megophrys.targetWounds = (Megophrys.targetWounds or {})
  Megophrys.targetWounds['right leg'] = {dmg=0, trackedHits=0}
  Megophrys.targetWounds['left leg'] = {dmg=0, trackedHits=0}
  Megophrys.targetWounds['right arm'] = {dmg=0, trackedHits=0}
  Megophrys.targetWounds['left arm'] = {dmg=0, trackedHits=0}
  Megophrys.targetWounds.torso = {dmg=0, trackedHits=0}
  Megophrys.targetWounds.head = {dmg=0, trackedHits=0}
  Megophrys.Magi.updatePrepGauges()
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
  if Megophrys.killStrat == 'denizen' then
    cecho('\n<cyan>Hunt mode activated as '.. Megophrys.class ..'!')

    wsys.unkeepup('mass', true)
    wsys.unkeepup('rebounding', true)

    Megophrys[Megophrys.class].setMode()
  elseif Megophrys.killStrat == 'pummel' then
    wsys.keepup('mass', true)
    wsys.keepup('rebounding', true)

    Megophrys.Magi.setMode()
    if Megophrys.class == 'Magi' then
    end
  elseif Megophrys.killStrat == 'raid' then
    cecho('\n<cyan>Raid mode activated as '.. Megophrys.class ..'!')

    if Megophrys.raidLeader then
      cecho('\n<cyan>Raid leader set to: '.. Megophrys.raidLeader ..'\n')
    end

    wsys.keepup('mass', true)
    wsys.keepup('rebounding', true)

    Megophrys[Megophrys.class].setMode()
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
  Megophrys.highlightTargetRoom()
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

Megophrys.updateBars = function()
  if not Megophrys.hpGauge then
    Megophrys.hpGauge = Geyser.Gauge:new({
      name='hpGauge',
      x='-25%', y='64.5%',
      width='25%', height='3.5%'
    })
  end
  if not Megophrys.mpGauge then
    Megophrys.mpGauge = Geyser.Gauge:new({
      name='mpGauge',
      x='-25%', y='68%',
      width='25%', height='3.5%'
    })
  end
  if not Megophrys.affTable then
    Megophrys.affTable = Geyser.Label:new({
      name='affTable',
      x='-26%', y='71.5%',
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
