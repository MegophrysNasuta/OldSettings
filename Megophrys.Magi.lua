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
  if Megophrys.killStrat == 'denizen' then
    setButtonStyleSheet('Hunt', 'QWidget { color: cyan; }')
    Magi.followUp = 'golem squeeze '.. target
    cecho('\n<cyan>Auto-attacks will be staffcasts'..
          '\nElement: '.. Magi.element ..
          '\nFollow up: '.. Magi.followUp ..
          '\nTarget is: '.. target ..'\n')
  elseif Megophrys.killStrat == 'raid' then
    setButtonStyleSheet('PvP', 'QWidget { color: cyan; }')
    Magi.followUp = 'golem timeflux '.. target
    cecho('\n<cyan>Auto-attacks will be staffcasts'..
          '\nElement: '.. Magi.element ..
          '\nFollow up: '.. Magi.followUp ..
          '\nTarget is: '.. target ..'\n')
  elseif Megophrys.killStrat == 'pummel' then
    cecho('\n<cyan>Magi PvP (Ice) mode activated!')
    setButtonStyleSheet('Raid', 'QWidget { color: cyan; }')

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
      if not Megophrys.Magi.targetTransfixed then
        send('cast transfix at '.. target)
      elseif (Megophrys.targetHits or 0) % 3 == 0 then
        Megophrys.targetHits = 1
        Megophrys.Magi.targetTransfixed = false
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
  if not Magi.torsoGauge then
    Magi.torsoGauge = Geyser.Gauge:new({
      name='torsoGauge',
      x='-915px', y='2%',
      width='150px', height='2%'
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
