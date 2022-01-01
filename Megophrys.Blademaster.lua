Megophrys.Blademaster = (Megophrys.Blademaster or {})
local Blademaster = Megophrys.Blademaster

Blademaster.stances = {
  earth = 'Doya',
  fire = 'Arash',
  air = 'Thyr',
  water = 'Mir',
  void = 'Sanya',
}

Megophrys.Blademaster.makeClassToolbars = function()
  Megophrys.bmToolbar = Geyser.Container:new({
    name='bm_toolbar',
    x=270, y=0, width=270, height=60
  })

  Blademaster.stanceLabel = Geyser.Label:new({
    name='stance_label',
    x=0, y=0, width=100, height=20,
    message='Stance:'
  }, Megophrys.bmToolbar)
  Blademaster.stanceLabel:setFontSize(11)
  Blademaster.earthButton = Geyser.Label:new({
    name='earth_button',
    x=100, y=0, width=34, height=20,
  }, Megophrys.bmToolbar)
  Blademaster.earthButton:setFontSize(11)
  Blademaster.fireButton = Geyser.Label:new({
    name='fire_button',
    x=134, y=0, width=34, height=20,
  }, Megophrys.bmToolbar)
  Blademaster.fireButton:setFontSize(11)
  Blademaster.airButton = Geyser.Label:new({
    name='air_button',
    x=168, y=0, width=34, height=20,
  }, Megophrys.bmToolbar)
  Blademaster.airButton:setFontSize(11)
  Blademaster.waterButton = Geyser.Label:new({
    name='water_button',
    x=202, y=0, width=34, height=20,
  }, Megophrys.bmToolbar)
  Blademaster.waterButton:setFontSize(11)
  Blademaster.voidButton = Geyser.Label:new({
    name='void_button',
    x=236, y=0, width=34, height=20,
  }, Megophrys.bmToolbar)
  Blademaster.voidButton:setFontSize(11)

  Blademaster.nextStrikeLabel = Geyser.Label:new({
    name='next_strike_label',
    x=0, y=20, width=100, height=20,
    message='Strike:'
  }, Megophrys.bmToolbar)
  Blademaster.nextStrikeLabel:setFontSize(11)
  Blademaster.nextStrikeButton = Geyser.Label:new({
    name='next_strike_',
    x=100, y=20, width=170, height=20,
  }, Megophrys.bmToolbar)
  Blademaster.nextStrikeButton:setFontSize(11)

  Blademaster.infuseElemLabel = Geyser.Label:new({
    name='infuse_elem_label',
    x=0, y=40, width=100, height=20,
    message='Infuse:'
  }, Megophrys.bmToolbar)
  Blademaster.infuseElemLabel:setFontSize(11)
  Blademaster.infuseEarthButton = Geyser.Label:new({
    name='infuse_earth_button',
    x=100, y=40, width=34, height=20,
  }, Megophrys.bmToolbar)
  Blademaster.infuseEarthButton:setFontSize(11)
  Blademaster.infuseFireButton = Geyser.Label:new({
    name='infuse_fire_button',
    x=134, y=40, width=34, height=20,
  }, Megophrys.bmToolbar)
  Blademaster.infuseFireButton:setFontSize(11)
  Blademaster.infuseAirButton = Geyser.Label:new({
    name='infuse_air_button',
    x=168, y=40, width=34, height=20,
  }, Megophrys.bmToolbar)
  Blademaster.infuseAirButton:setFontSize(11)
  Blademaster.infuseWaterButton = Geyser.Label:new({
    name='infuse_water_button',
    x=202, y=40, width=34, height=20,
  }, Megophrys.bmToolbar)
  Blademaster.infuseWaterButton:setFontSize(11)
  Blademaster.infuseVoidButton = Geyser.Label:new({
    name='infuse_void_button',
    x=236, y=40, width=34, height=20,
  }, Megophrys.bmToolbar)
  Blademaster.infuseVoidButton:setFontSize(11)
end

Megophrys.Blademaster.onConnect = function()
  -- pass
end

Megophrys.Blademaster.setNextStrike = function(strikeTarget)
  Blademaster.nextStrike = tostring(strikeTarget):lower()
  Blademaster.nextStrikeButton:echo(' '.. Blademaster.nextStrike:title())
end

Megophrys.Blademaster.nextAttack = function()
  local killStrat = Megophrys.killStrat
  local setNextAttack = 'setalias nextAttack stand / stand / '
  local infuseElem = Blademaster.infuseElem
  local nextSlash = nil

  if infuseElem == 'water' then
    infuseElem = 'ice'
  elseif infuseElem == 'air' then
    infuseElem = 'lightning'
  end

  if infuseElem then
    setNextAttack = setNextAttack ..'infuse '.. infuseElem .. ' / '
  end

  if killStrat == 'denizen' then
    nextSlash = 'drawslash'
  elseif killStrat == 'raid' then
    nextSlash = 'balanceslash'
  else
    local prepStatus = Blademaster.nextLimbPrepAttack()
    local targetLimb = prepStatus.targetLimb
    local targetTorso = prepStatus.targetTorso
    local targetSide = nil
    Megophrys.nextMoveButton:echo('Staffstrike', Megophrys.fgColors[killStrat], 'c')

    if Megophrys.killPreConditionsMet and not Blademaster.targetImpaled then
      sendAll('clearqueue all', 'impale '.. target)
      Megophrys.killPreConditionsMet = false
      Megophrys.nextMoveButton:echo('Impslash', Megophrys.fgColors[killStrat], 'c')
      Megophrys.targetHits = 0
      return
    elseif Blademaster.targetImpaled then
      -- kill condition met: twist until brokenstar
      Megophrys.priorityLabel:echo('<center>Priority: BLADETWIST</center>')
      Megophrys.nextMoveButton:echo('Bladetwist', Megophrys.fgColors[killStrat], 'c')
      if (ak.bleeding or 0) > 699 then
        sendAll('clearqueue all', 'brokenstar '.. target)
      elseif Megophrys.targetHits == 0 then
        sendAll('clearqueue all', 'impaleslash')
      else
        sendAll('clearqueue all', 'bladetwist')
      end
    else
      nextSlash = (Megophrys.targetLimbSet or 'leg'):lower() ..'slash'
      targetSide = targetLimb
    end

    Megophrys.targetHits = Megophrys.targetHits + 1
  end

  if killStrat ~= 'denizen' then
    Blademaster.setNextStrike('sternum')
  end

  if nextSlash then
    Megophrys.nextMoveButton:echo(nextSlash:title(), Megophrys.fgColors[killStrat], 'c')
    setNextAttack = setNextAttack .. nextSlash ..' &tar'
    if targetSide then
      setNextAttack = setNextAttack .. targetSide
    end
  end

  if Blademaster.nextStrike then
    setNextAttack = setNextAttack ..' / strike &tar '.. Blademaster.nextStrike
  end

  sendAll(setNextAttack, 'queue addclear eqbal nextAttack')
end

Blademaster.nextLimbPrepAttack = function()
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
  local limbIsUnderPrepped = false          -- 84-91%
  local otherLimbIsBroken = false
  local otherLimbIsPrepped = false
  local otherLlimbIsUnderPrepped = false    -- 84-91%
  local torsoIsBroken = false
  local torsoIsPrepped = false
  local torsoIsUnderPrepped = false         -- 84-91%
  local targetWounds = lb[target].hits
  local targetLimb = Megophrys.targetLimb
  local skipTorso = Megophrys.skipTorso
  local dualPrep = Megophrys.dualPrep

  if targetLimb then
    local targetLimbDmg = (targetWounds[targetLimb ..' leg'] or 0)
    if targetLimbDmg >= 100 then
      limbIsBroken = true
      cecho('\n<gold>LIMB IS BROKEN!\n')
    elseif targetLimbDmg >= 91 then
      limbIsPrepped = true
      cecho('\n<gold>LIMB IS PREPPED!\n')
    elseif targetLimbDmg >= 84 then
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
    elseif otherLimbDmg >= 91 then
      otherLimbIsPrepped = true
      cecho('\n<gold>OTHER LIMB IS PREPPED!\n')
    elseif otherLimbDmg >= 84 then
      otherLimbIsUnderPrepped = true
    end
  end

  if not skipTorso then
    local targetTorsoDmg = (targetWounds.torso or 0)
    if targetTorsoDmg >= 100 then
      torsoIsBroken = true
      cecho('\n<gold>TORSO IS BROKEN!\n')
    elseif targetTorsoDmg >= 91 then
      torsoIsPrepped = true
      cecho('\n<gold>TORSO IS PREPPED!\n')
    elseif targetTorsoDmg >= 84 then
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
      -- otherwise go back to limb to break
      Megophrys.priorityLabel:echo('<center>Priority: L2 BREAKS</center>')
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

    if Megophrys.killPreConditionsMet then
      Megophrys.nextMoveButton:echo('Impale', Megophrys.fgColors[killStrat], 'c')
    end
  else
    Megophrys.priorityLabel:echo('<center>Priority: LIMB PREP</center>')
  end

  return {
    targetLimb = targetLimb,
    targetTorso = targetTorso
  }
end

Blademaster.resetElementButtonStyles = function()
  Blademaster.earthButton:echo('Ea', 'white', 'c')
  Blademaster.fireButton:echo('Fi', 'white', 'c')
  Blademaster.airButton:echo('Ai', 'white', 'c')
  Blademaster.waterButton:echo('Wa', 'white', 'c')
  Blademaster.voidButton:echo('Vo', 'white', 'c')
end

Blademaster.resetInfuseElementButtonStyles = function()
  Blademaster.infuseEarthButton:echo('Ea', 'white', 'c')
  Blademaster.infuseFireButton:echo('Fi', 'white', 'c')
  Blademaster.infuseAirButton:echo('Ai', 'white', 'c')
  Blademaster.infuseWaterButton:echo('Wa', 'white', 'c')
  Blademaster.infuseVoidButton:echo('Vo', 'white', 'c')
end

Blademaster.setElement = function(element, reason, infuse)
  local elem = tostring(element):lower()
  if not elem then return end
  local elem_for = nil

  local getButtonByElement = function(elem, infuseVersion)
    if not elem then return end
    local button = nil
    local ibutton = nil
    if elem == 'earth' then
      button = Blademaster.earthButton
      ibutton = Blademaster.infuseEarthButton
    elseif elem == 'fire' then
      button = Blademaster.fireButton
      ibutton = Blademaster.infuseFireButton
    elseif elem == 'air' then
      button = Blademaster.airButton
      ibutton = Blademaster.infuseAirButton
    elseif elem == 'water' then
      button = Blademaster.waterButton
      ibutton = Blademaster.infuseWaterButton
    elseif elem == 'void' then
      button = Blademaster.voidButton
      ibutton = Blademaster.infuseVoidButton
    else
      cecho('\n<red>Unknown element: '.. elem ..' (ignored)\n')
    end

    if infuseVersion then
      return ibutton
    else
      return button
    end
  end

  if infuse then
    Blademaster.infuseElem = elem
    elem_for = 'infuse'
  else
    Blademaster.element = elem
    elem_for = 'stance'
    send(Blademaster.stances[Blademaster.element])
  end

  local button = getButtonByElement(Blademaster.element, false)
  local ibutton = getButtonByElement(Blademaster.infuseElem, true)
  Blademaster.resetElementButtonStyles()
  Blademaster.resetInfuseElementButtonStyles()
  if ibutton then
    ibutton:echo(string.title(string.sub(Blademaster.infuseElem, 1, 2)),
                 Megophrys.fgColors[Megophrys.killStrat], 'c')
  end
  if button then
    button:echo(string.title(string.sub(Blademaster.element, 1, 2)),
                Megophrys.fgColors[Megophrys.killStrat], 'c')
  end

  if reason then
    cecho('\n<cyan>Element for '.. elem_for ..' set to: '.. elem ..' ('.. reason ..')\n')
  else
    cecho('\n<cyan>Element for '.. elem_for ..' set to: '.. elem ..'\n')
  end
end

Megophrys.Blademaster.setMode = function()
  local killStrat = Megophrys.killStrat

  --Megophrys.specialMoveButton:echo(
  --  'Embed Focus',
  --  Megophrys.fgColors[killStrat],
  --  'c'
  --)

  if killStrat == 'denizen' then
    Megophrys.nextMoveButton:echo('Drawslash', Megophrys.fgColors[killStrat], 'c')
    Blademaster.setElement('fire')
    Blademaster.setElement('fire', nil, true)
    cecho('\n<cyan>Auto-attacks will be drawslashes'..
          '\nElement: '.. Blademaster.element ..
          '\nInfusing: '.. Blademaster.infuseElem ..
          '\nTarget is: '.. target ..'\n')
  elseif killStrat == 'raid' then
    Megophrys.nextMoveButton:echo('Balanceslash', Megophrys.fgColors[killStrat], 'c')
    Blademaster.setElement('fire')
    Blademaster.setElement('water', nil, true)
    cecho('\n<cyan>Auto-attacks will be balanceslashes'..
          '\nElement: '.. Blademaster.element ..
          '\nInfusing: '.. Blademaster.infuseElem ..
          '\nTarget is: '.. target ..'\n')
  elseif killStrat == 'bstar' then
    Megophrys.nextMoveButton:echo('Limbslash', Megophrys.fgColors[killStrat], 'c')
    cecho('\n<cyan>BM PvP (Brokenstar) mode activated!')

    Megophrys.targetTorso = false
    Megophrys.targetRebounding = false
    Megophrys.resetTargetWounds()
    Blademaster.setElement('fire')
    Blademaster.setElement('fire', nil, true)

    cecho('\n<cyan>Auto-attacks will be limbslashes'..
          '\nElement: '.. Blademaster.element ..
          '\nInfusing: '.. Blademaster.infuseElem ..
          '\nTarget is: '.. target ..
          '\n  on limb: '.. Megophrys.targetLimb)
  end
end

Megophrys.Blademaster.subMode = function(n, altMode)
  if n == 1 then
    Blademaster.setElement('earth', nil, altMode)
  elseif n == 2 then
    Blademaster.setElement('fire', nil, altMode)
  elseif n == 3 then
    Blademaster.setElement('air', nil, altMode)
  elseif n == 4 then
    Blademaster.setElement('water', nil, altMode)
  else
    error('Bad sub mode: '.. n ..'!')
  end
end

Megophrys.Blademaster.toggleOne = function(altMode)
  Blademaster.setElement('void', nil, altMode)
end
