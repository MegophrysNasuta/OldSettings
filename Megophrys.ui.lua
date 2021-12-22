Megophrys.makeClassToolbars = function()
  setBorderRight(768)
  setBorderTop(120)
  setBorderBottom(520)

  Megophrys.modeToolbar = Geyser.Container:new({
    name='mode_switches',
    x=0, y=0, width=270, height=60
  })

  if Megophrys.magiToolbar then
    Megophrys.magiToolbar:hide()
  end

  if Megophrys.psionToolbar then
    Megophrys.psionToolbar:hide()
  end

  Megophrys.modeLabel = Geyser.Label:new({
    name='mode_label',
    x=0, y=0, width=100, height=20,
    message='AI Mode:'
  }, Megophrys.modeToolbar)
  Megophrys.modeLabel:setFontSize(11)
  Megophrys.modeButton = Geyser.Label:new({
    name='current_mode',
    x=100, y=0, width=170, height=20,
  }, Megophrys.modeToolbar)
  Megophrys.modeButton:setFontSize(11)

  Megophrys.nextMoveLabel = Geyser.Label:new({
    name='next_move_label',
    x=0, y=20, width=100, height=20,
    message='Next move:'
  }, Megophrys.modeToolbar)
  Megophrys.nextMoveLabel:setFontSize(11)
  Megophrys.nextMoveButton = Geyser.Label:new({
    name='next_move',
    x=100, y=20, width=170, height=20,
  }, Megophrys.modeToolbar)
  Megophrys.nextMoveButton:setFontSize(11)

  Megophrys.specialMoveLabel = Geyser.Label:new({
    name='special_label',
    x=0, y=40, width=100, height=20,
    message='Special:'
  }, Megophrys.modeToolbar)
  Megophrys.specialMoveLabel:setFontSize(11)
  Megophrys.specialMoveButton = Geyser.Label:new({
    name='special_move',
    x=100, y=40, width=170, height=20,
  }, Megophrys.modeToolbar)
  Megophrys.specialMoveButton:setFontSize(11)

  Megophrys.calendarLabel = Geyser.Label:new({
    name='calendar_label',
    x=0, y=60, width=540, height=40,
    fgColor='CornflowerBlue',
    message='Loading...'
  })
  Megophrys.calendarLabel:setFontSize(11)

  if Megophrys.targetHpGauge then Megophrys.targetHpGauge:hide() end
  if Megophrys.targetMpGauge then Megophrys.targetMpGauge:hide() end
end

Megophrys.showTime = function()
  if not Megophrys.calendarLabel then return end
  local tl = gmcp.IRE.Time.List
  if not tl then return end

  for key, _ in pairs(tl) do
    local updated = gmcp.IRE.Time.Update[key]
    if updated then tl[key] = updated end
  end

  local d = ''
  if tl.day == "1" then
    d = "1st"
  elseif tl.day == "2" then
    d = "2nd"
  elseif tl.day == "3" then
    d = "3rd"
  else
    d = tl.day .."th"
  end

  local seasons = {
    "mid-winter",
    "late winter",
    "early spring",
    "mid-spring",
    "late spring",
    "early summer",
    "mid-summer",
    "late summer",
    "early autumn",
    "mid-autumn",
    "late autumn",
    "early winter",
  }

  local timeStr = (d ..' '.. tl.month ..', '.. tl.year ..
                   ' ('.. seasons[tonumber(tl.mon)] ..', '.. tl.moonphase ..
                   ')<br>'.. tl.time)
  Megophrys.calendarLabel:echo(timeStr)
end

Megophrys.updateBars = function()
  if not Megophrys.hpGauge then
    Megophrys.hpGauge = Geyser.Gauge:new({
      name='hpGauge',
      x='-520px', y=0,
      width='520px', height='3.25%'
    })
  end
  Megophrys.hpGauge:setFontSize(12)
  if not Megophrys.mpGauge then
    Megophrys.mpGauge = Geyser.Gauge:new({
      name='mpGauge',
      x='-520px', y='3.25%',
      width='520px', height='3.25%'
    })
  end
  Megophrys.mpGauge:setFontSize(12)
  if not Megophrys.tgtAffTable then
    Megophrys.tgtAffTable = Geyser.Label:new({
      name='tgtAffTable',
      x='-765px', y='13.5%',
      width='150px', height='420px',
      fgColor='white', color='black'
    })
    Megophrys.tgtAffTable:setFontSize(12)
  end
  if not Megophrys.whoHereTable then
    Megophrys.whoHereTable = Geyser.Label:new({
      name='whoHereTable',
      x='-760px', y='800px',
      width='752px', height='72px',
      fgColor='white', color='black'
    })
    Megophrys.whoHereTable:setFontSize(12)
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

  local whoHereTable = '<b>Players Here:</b> '
  for _, player in spairs(gmcp.Room.Players) do
    whoHereTable = whoHereTable .. player.name
    if _ ~= #gmcp.Room.Players then
      whoHereTable = whoHereTable ..', '
    end
    if _ % 7 == 0 then
      whoHereTable = whoHereTable ..'<br>'
    end
  end
  whoHereTable = whoHereTable ..'</ul>'
  Megophrys.whoHereTable:echo(whoHereTable)

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

  local tgtAffTable = '<b>Tgt Affs:</b><ul>'
  local addToTgtAffTable = function(tgtAffTable, affList)
    for _, aff in pairs(affList) do
      local entry = ''
      if tarAff(aff) then
        entry = '<b>'.. aff ..'</b>'
      else
        entry = '<i><s>'.. aff ..'</s></i>'
      end
      tgtAffTable = (tgtAffTable ..'<li>'.. entry ..'</li>')
    end
    tgtAffTable = (tgtAffTable ..'<li>&nbsp;</li>')
    return tgtAffTable
  end

  local trueLockAffs = {
    "paralysis",
    "anorexia",
    "asthma",
    "impatience",
    "slickness",
  }
  if Megophrys.class == 'Psion' then
    trueLockAffs[#trueLockAffs + 1] = "bloodfire"
  end
  tgtAffTable = addToTgtAffTable(tgtAffTable, trueLockAffs)

  if Megophrys.class == 'Psion' then
    local psionAffs = {
      "unweavingmind",
      "unweavingbody",
      "unweavingspirit",
    }
    tgtAffTable = addToTgtAffTable(tgtAffTable, psionAffs)
  end

  local otherAffs = {
    "haemophilia",
    "epilepsy",
    "dizziness",
    "nausea",
    "stupidity",
    "clumsiness",
    "weariness",
  }
  tgtAffTable = addToTgtAffTable(tgtAffTable, otherAffs)

  tgtAffTable = tgtAffTable ..'<li>bleed: '.. (ak.bleeding or 0) ..'</li></ul></center>'
  Megophrys.tgtAffTable:echo(tgtAffTable)
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

  Megophrys.highlightPanicRoom()
end

Megophrys.updatePrepGauges = function()
  if not Megophrys.topGauge then
    Megophrys.topGauge = Geyser.Gauge:new({
      name='topGauge',
      x='50%', y=0,
      width='7.5%', height='2%'
    })
  end
  Megophrys.topGauge:setFontSize(11)
  if not Megophrys.middleGauge then
    Megophrys.middleGauge = Geyser.Gauge:new({
      name='middleGauge',
      x='50%', y='2%',
      width='7.5%', height='2%'
    })
  end
  Megophrys.middleGauge:setFontSize(11)
  if not Megophrys.bottomGauge then
    Megophrys.bottomGauge = Geyser.Gauge:new({
      name='bottomGauge',
      x='50%', y='4%',
      width='7.5%', height='2%'
    })
  end
  Megophrys.bottomGauge:setFontSize(11)
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
