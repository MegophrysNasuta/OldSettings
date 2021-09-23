Megophrys.makeClassToolbars = function()
  setBorderRight(480)
  Megophrys.PartyChatConsole = Geyser.MiniConsole:new({
    name='PartyChatConsole',
    x='-470px', y='50%',
    autoWrap=true,
    color='black',
    scrollBar=false,
    fontSize=10,
    width=475, height='50%',
  })

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
  if not Megophrys.tgtAffTable then
    Megophrys.tgtAffTable = Geyser.Label:new({
      name='tgtAffTable',
      x='-1150px', y='120px',
      width='150px', height='350px',
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

  local tgtAffTable = '<b>Tgt Affs:</b><ul>'
  local targetAffs = affstrack.score

  local addToTgtAffTable = function(tgtAffTable, affList)
    local extraFmt = ''
    local strLen = 4
    for aff, pct in spairs(affList) do
      if aff:find('^unweave') == nil and aff ~= 'bled' then
        extraFmt = '%'
        strLen = 4
      else
        extraFmt = ''
        strLen = 5
      end
      tgtAffTable = (tgtAffTable ..'<li>'.. aff:gsub('nweave', ''):sub(1, strLen)
                     ..' ('.. (pct or '0') .. extraFmt ..')</li>')
    end
    tgtAffTable = (tgtAffTable ..'<li>&nbsp;</li>')
    return tgtAffTable
  end

  local trueLockAffs = {
    paralysis   = targetAffs.paralysis,
    anorexia    = targetAffs.anorexia,
    asthma      = targetAffs.asthma,
    impatience  = targetAffs.impatience,
    slickness   = targetAffs.slickness,
  }
  if Megophrys.class == 'Psion' then
    trueLockAffs.bfire = targetAffs.bloodfire
  end
  tgtAffTable = addToTgtAffTable(tgtAffTable, trueLockAffs)

  if Megophrys.class == 'Psion' then
    local psionAffs = {
      unweavemind = ak.psion.unweaving.mind,
      unweavebody = ak.psion.unweaving.body,
      unweavesoul = ak.psion.unweaving.spirit,
    }
    tgtAffTable = addToTgtAffTable(tgtAffTable, psionAffs)
  end

  local otherAffs = {
    bled        = ak.bleeding,
    haemophilia = targetAffs.haemophilia,
    epilepsy    = targetAffs.epilepsy,
    dizziness   = targetAffs.dizziness,
    nausea      = targetAffs.nausea,
    stupidity   = targetAffs.stupidity,
    clumsiness  = targetAffs.clumsiness,
    weariness   = targetAffs.weariness
  }
  tgtAffTable = addToTgtAffTable(tgtAffTable, otherAffs)

  tgtAffTable = tgtAffTable ..'</ul></center>'
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

