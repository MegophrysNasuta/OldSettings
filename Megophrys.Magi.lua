Megophrys.Magi = (Megophrys.Magi or {})
local Magi = Megophrys.Magi
Magi.element = (Magi.element or 'air')
Magi.skipTorso = (Magi.skipTorso or false)
Magi.skipTransfix = (Magi.skipTransfix or false)
Magi.targetTransfixed = (Magi.targetTransfixed or false)
Magi.timefluxUp = (Magi.timefluxUp or false)

Magi.staffCasts = {
  earth = 'dissolution',
  fire = 'scintilla',
  air = 'lightning',
  water = 'horripilation',
}

Megophrys.Magi.setMode = function()
  local Magi = Megophrys.Magi
  Magi.resetModeButtonStyles()
  Megophrys.timeUntilNextAttack = 1.6
  if Megophrys.killStrat == 'denizen' then
    setButtonStyleSheet('Hunt', 'QWidget { color: cyan; }')
    Magi.followUp = 'golem squeeze &tar'
    cecho('\n<cyan>Auto-attacks will be staffcasts'..
          '\nElement: '.. Magi.element ..
          '\nFollow up: '.. Magi.followUp ..
          '\nTarget is: '.. target ..'\n')
  elseif Megophrys.killStrat == 'raid' then
    setButtonStyleSheet('Raid', 'QWidget { color: cyan; }')
    Magi.followUp = 'golem timeflux &tar'
    cecho('\n<cyan>Auto-attacks will be staffcasts'..
          '\nElement: '.. Magi.element ..
          '\nFollow up: '.. Magi.followUp ..
          '\nTarget is: '.. target ..'\n')
  elseif Megophrys.killStrat == 'pummel' then
    Megophrys.timeUntilNextAttack = 2.0
    cecho('\n<cyan>Magi PvP (Ice) mode activated!')
    setButtonStyleSheet('PvP', 'QWidget { color: cyan; }')

    Magi.timefluxUp = false
    Megophrys.targetTorso = false
    Magi.targetFrozen = false
    Magi.targetMaybeFrozen = false
    Megophrys.targetRebounding = false
    Megophrys.resetTargetWounds()
    Magi.setElement('air', 'first strike')
    Magi.followUp = 'golem timeflux &tar'

    cecho('\n<cyan>Auto-attacks will be staffstrikes'..
          '\nElement: '.. Magi.element ..
          '\nFollow up: '.. Magi.followUp ..
          '\nTarget is: '.. target ..
          '\n  on limb: '.. Megophrys.targetLimb)
  elseif Megophrys.killStrat == 'fiyah' then
    Megophrys.timeUntilNextAttack = 2.0
    cecho('\n<cyan>Magi PvP (Fire) mode activated!')
    setButtonStyleSheet('PvP', 'QWidget { color: cyan; }')

    Magi.timefluxUp = false
    Megophrys.targetTorso = false
    Megophrys.targetRebounding = false
    Megophrys.resetTargetWounds()
    Magi.setElement('air', 'first strike')
    Magi.followUp = 'golem timeflux '.. target

    cecho('\n<cyan>Auto-attacks will be staffstrikes'..
          '\nElement: '.. Magi.element ..
          '\nFollow up: '.. Magi.followUp ..
          '\nTarget is: '.. target ..
          '\n  on limb: '.. Megophrys.targetLimb)
    sendAll('setalias nextAction cast efreeti', 'queue addclear eqbal nextAction')
  end
end

Megophrys.Magi.nextAttack = function()
  local Magi = Megophrys.Magi
  local killStrat = Megophrys.killStrat
  local staffCasts = Magi.staffCasts
  local setNextAttack = 'setalias nextAttack stand / wield staff217211 / '

  local staffSpell = staffCasts[Magi.element]
  if killStrat == 'denizen' then
    sendAll(setNextAttack ..'staffcast '.. staffSpell ..' at &tar / golem squeeze &tar',
            'queue addclear eqbal nextAttack')
  else
    Magi.setGolemStrat()
    if killStrat == 'raid' then
      if not Megophrys.Magi.targetTransfixed then
        sendAll(setNextAttack ..'cast transfix at &tar',
                'queue addclear eqbal nextAttack')
      elseif (Megophrys.targetHits or 0) % 4 == 0 then
        Megophrys.targetHits = 1
        Megophrys.Magi.targetTransfixed = false
        sendAll(setNextAttack ..'cast transfix at &tar',
                'queue addclear eqbal nextAttack')
      else
        sendAll(setNextAttack ..'staffcast '.. staffSpell ..' at &tar',
                'queue addclear eqbal nextAttack')
      end
      Megophrys.targetHits = Megophrys.targetHits + 1
    else
      local prepStatus = Magi.nextLimbPrepAttack()
      local targetLimb = prepStatus.targetLimb
      local targetTorso = prepStatus.targetTorso
      local cmd = 'staffstrike &tar with '.. Magi.element

      if killStrat == 'pummel' then
        if Megophrys.killPreConditionsMet and not Magi.targetMaybeFrozen then
          sendAll('clearqueue all', 'cast deepfreeze')
          Magi.targetMaybeFrozen = true
          Megophrys.killPreConditionsMet = false
          return
        elseif Magi.targetMaybeFrozen then
          -- kill condition met: pummel to death
          Megophrys.priorityLabel:echo('<center>Priority: PUMMEL</center>')
          Magi.setElement('water', 'freezing')
          cmd = 'staffstrike &tar with '.. Magi.element
          if not Magi.targetFrozen then
            Magi.followUp = 'golem hypothermia &tar'
            Magi.targetFrozen = true
          else
            Magi.followUp = 'golem pummel &tar'
          end
          targetTorso = true
        end
      elseif killStrat == 'fiyah' then
        if Magi.targetDehydrated then
          Megophrys.priorityLabel:echo('<center>Priority: DESTROY/center>')
          Magi.setElement('fire', 'burning')
          cmd = 'staffstrike &tar with '.. Magi.element
          if (Megophrys.targetHits or 0) % 3 == 0 then
            Magi.followUp = 'golem destroy &tar'
          elseif (Megophrys.targetHits or 0) % 3 == 1 then
            Magi.followUp = 'golem conflagrate &tar'
          else
            Magi.followUp = 'golem destabilise heat / golem scorch &tar'
          end
          targetTorso = true
        end
      end

      if killStrat == 'pummel' or killStrat == 'fiyah' then
        if targetLimb and not targetTorso then
          cmd = cmd .. ' ' .. targetLimb .. ' leg'
        else
          cmd = cmd .. ' torso'
        end
        sendAll(
          setNextAttack .. cmd .. '/' .. Magi.followUp,
          'queue addclear eqbal nextAttack'
        )
        Megophrys.targetHits = Megophrys.targetHits + 1
      end
    end
  end

  Megophrys.autoAttackTimerId = tempTimer(Megophrys.timeUntilNextAttack,
                                          Magi.nextAttack)
end

Magi.nextLimbPrepAttack = function()
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
  local skipTorso = Megophrys.Magi.skipTorso
  local dualPrep = Megophrys.Magi.dualPrep

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
    if Megophrys.targetRebounding then
      Magi.setElement('air', 'rebounding')
    else
      Magi.setElement('earth', 'limb prep')
    end

    if dualPrep and not otherLimbIsPrepped then
      -- switch legs
      Megophrys.priorityLabel:echo('<center>Priority: LIMB 2 PREP</center>')
      targetLimb = otherLimb
    elseif not skipTorso and not torsoIsPrepped then
      -- work on prepping torso once limb is done
      Megophrys.priorityLabel:echo('<center>Priority: TORSO PREP</center>')
      targetTorso = true
    else
      -- otherwise go back to limb with air to prone them
      Megophrys.priorityLabel:echo('<center>Priority: L2 BREAKS</center>')
      if killStrat == 'fiyah' then
        Magi.followUp = 'golem dehydrate '.. target
        Megophrys.targetHits = 0
      end
      Magi.setElement('air', 'proning')
      targetTorso = false
    end
  elseif limbIsBroken or Megophrys.limbHasBroken then
    Megophrys.limbHasBroken = true
    Megophrys.killPreConditionsMet = true

    if Megophrys.targetProne then
      if killStrat == 'pummel' then
        Magi.setElement('water', 'freezing')
      elseif killStrat == 'fiyah' then
        Magi.setElement('fire', 'burning')
      end
    else
      Magi.setElement('air', 'proning')
    end

    if dualPrep and not otherLimbIsBroken then
      targetLimb = otherLimb
      Megophrys.killPreConditionsMet = false
    elseif not skipTorso and not torsoIsBroken then
      targetTorso = true
      Megophrys.killPreConditionsMet = false
    end
  else
    Megophrys.priorityLabel:echo('<center>Priority: LIMB PREP</center>')
    local airBendForRebound = (
        Megophrys.targetRebounding or
        (Megophrys.targetHits == 0)  -- first hit in case of rebounding
    )
    local airBendForUnderPrep = (
        (targetTorso and torsoIsUnderPrepped) or
        (not targetTorso and (limbIsUnderPrepped or otherLimbIsUnderPrepped))
    )
    if airBendForRebound then
      Magi.setElement('air', 'rebounding')
    elseif airBendForUnderPrep then
      Magi.setElement('air', 'underprep')
    else
      Magi.setElement('earth', 'limb prep')
    end
  end

  return {
    targetLimb = targetLimb,
    targetTorso = targetTorso
  }
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

Magi.setElement = function(element, reason)
  local elem = tostring(element):lower()
  if elem == 'fire' or elem == 'water' or elem == 'air' or elem == 'earth' then
    Magi.element = elem
    Magi.resetElementButtonStyles()
    setButtonStyleSheet(elem:title(), 'QWidget { color: cyan; }')
    if reason then
      cecho('\n<cyan>Element set to: '.. Magi.element ..' ('.. reason ..')\n')
    else
      cecho('\n<cyan>Element set to: '.. Magi.element ..'\n')
    end
  else
    cecho('\n<red>Unknown element: '.. elem ..' (ignored)\n')
  end
end

Magi.setGolemStrat = function()
  Magi.golemSmashTarget = 'arms'
  if Magi.timefluxUp then
    if Megophrys.killStrat == 'fiyah' then
      if Magi.infernoDown then
        Magi.followUp = 'golem inferno'
      else
        Magi.followUp = 'golem scorch '.. target
      end
    else
      Magi.followUp = 'golem smash '.. target .. ' '.. Magi.golemSmashTarget
    end
  else
    Magi.followUp = 'golem timeflux '.. target
  end
end

Magi.toggleDualLegPrep = function()
  Magi.dualPrep = not Magi.dualPrep

  if Magi.dualPrep then
    cecho('\n<cyan>Toggled to dual-leg prep!\n')
    setButtonStyleSheet('DualPrep', 'QWidget {color: cyan}')
  else
    cecho('\n<cyan>Toggled to single-leg prep!\n')
    setButtonStyleSheet('DualPrep', 'QWidget {color: grey}')
  end

  Magi.updatePrepGauges()
end

Magi.toggleGolemSmashTarget = function()
  if Magi.golemSmashTarget and Magi.golemSmashTarget == 'arms' then
    cecho('\n<cyan>Golem will smash legs!\n')
    setButtonStyleSheet('Arms', 'QWidget {color: grey}')
    Magi.golemSmashTarget = 'legs'
  else
    cecho('\n<cyan>Golem will smash arms!\n')
    setButtonStyleSheet('Arms', 'QWidget {color: cyan}')
    Magi.golemSmashTarget = 'arms'
  end
end

Magi.toggleSkipTorso = function()
  Magi.skipTorso = not Magi.skipTorso

  if Magi.skipTorso then
    cecho('\n<cyan>Skipping torso! (Only prepping leg(s).)\n')
    setButtonStyleSheet('Torso', 'QWidget {color: grey}')
  else
    cecho('\n<cyan>Prepping torso as well as leg(s).\n')
    setButtonStyleSheet('Torso', 'QWidget {color: cyan}')
  end

  Magi.updatePrepGauges()
end

Magi.toggleSkipTransfix = function()
  Magi.skipTransfix = not Magi.skipTransfix

  if Magi.skipTransfix then
    cecho('\n<cyan>Skipping transfix! (Only doing damage.)\n')
    setButtonStyleSheet('Transfix', 'QWidget {color: grey}')
  else
    cecho('\n<cyan>Adding transfix to raid rotation.\n')
    setButtonStyleSheet('Transfix', 'QWidget {color: cyan}')
  end
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

Magi.updatePrepGauges = function()
  if not Magi.limbGauge then
    Magi.limbGauge = Geyser.Gauge:new({
      name='limbGauge',
      x='-915px', y=0,
      width='150px', height='2%'
    })
  end
  if not Magi.otherLimbGauge then
    Magi.otherLimbGauge = Geyser.Gauge:new({
      name='otherLimbGauge',
      x='-915px', y='2%',
      width='150px', height='2%'
    })
  end
  if not Magi.torsoGauge then
    Magi.torsoGauge = Geyser.Gauge:new({
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
  local torsoLabel = '<center>TORSO</center>'
  if Magi.dualPrep then
    otherLimbLabel = '<center>'.. string.upper(otherLimb) ..' LEG</center>'
  end
  Magi.limbGauge:setValue(targetLimbWounds, 100, limbLabel)
  Magi.otherLimbGauge:setValue(otherLimbWounds, 100, otherLimbLabel)
  Magi.torsoGauge:setValue(targetTorsoWounds, 100, torsoLabel)
end
