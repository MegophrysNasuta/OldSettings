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
    setButtonStyleSheet('Raid', 'QWidget { color: cyan; }')
    Magi.followUp = 'golem timeflux '.. target
    cecho('\n<cyan>Auto-attacks will be staffcasts'..
          '\nElement: '.. Magi.element ..
          '\nFollow up: '.. Magi.followUp ..
          '\nTarget is: '.. target ..'\n')
  elseif Megophrys.killStrat == 'pummel' then
    cecho('\n<cyan>Magi PvP (Ice) mode activated!')
    setButtonStyleSheet('PvP', 'QWidget { color: cyan; }')

    Magi.timefluxUp = false
    Megophrys.targetTorso = false
    Magi.targetFrozen = false
    Magi.targetMaybeFrozen = false
    Megophrys.targetRebounding = false
    Megophrys.resetTargetWounds()
    Magi.setElement('air')
    Magi.followUp = 'golem timeflux '.. target

    cecho('\n<cyan>Auto-attacks will be staffstrikes'..
          '\nElement: '.. Magi.element ..
          '\nFollow up: '.. Magi.followUp ..
          '\nTarget is: '.. target ..
          '\n  on limb: '.. Megophrys.targetLimb)
  elseif Megophrys.killStrat == 'fiyah' then
    cecho('\n<cyan>Magi PvP (Fire) mode activated!')
    setButtonStyleSheet('PvP', 'QWidget { color: cyan; }')

    Magi.timefluxUp = false
    Megophrys.targetTorso = false
    Megophrys.targetRebounding = false
    Megophrys.resetTargetWounds()
    Magi.setElement('air')
    Magi.followUp = 'golem timeflux '.. target

    cecho('\n<cyan>Auto-attacks will be staffstrikes'..
          '\nElement: '.. Magi.element ..
          '\nFollow up: '.. Magi.followUp ..
          '\nTarget is: '.. target ..
          '\n  on limb: '.. Megophrys.targetLimb)
    sendAll('setalias nextAction cast efreeti', 'queue add eqbal nextAction')
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
  local targetTransfixed = Magi.targetTransfixed

  if killStrat == 'denizen' then
    sendAll('setalias nextAttack staffcast '.. staffCasts[Magi.element] ..' at '.. 
            target ..'/ golem squeeze '.. target, 'queue add eqbal nextAttack')
  else
    Magi.golemSmashTarget = 'arms'
    if timefluxUp then
      if killStrat == 'fiyah' then
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

    if killStrat == 'raid' then
      if not Megophrys.Magi.targetTransfixed then
        sendAll('setalias nextAttack cast transfix at '.. target,
                'queue add eqbal nextAttack')
      elseif (Megophrys.targetHits or 0) % 4 == 0 then
        Megophrys.targetHits = 1
        Megophrys.Magi.targetTransfixed = false
        sendAll('setalias nextAttack cast transfix at '.. target,
                'queue add eqbal nextAttack')
      else
        sendAll('setalias nextAttack staffcast '.. staffCasts[Magi.element] ..' at '.. target,
                'queue add eqbal nextAttack')
      end
      Megophrys.targetHits = Megophrys.targetHits + 1
    else
      local targetTorso = false
      local limbIsPrepped = false
      local limbIsUnderPrepped = false      -- 86-91%
      local torsoIsPrepped = false
      local torsoIsUnderPrepped = false     -- 86-91%

      if targetLimb then
        local targetLimbDmg = targetWounds[targetLimb ..' leg']
        if targetLimbDmg.dmg >= 91 then
          limbIsPrepped = true
          cecho('\n<gold>LIMB IS PREPPED!\n')
        elseif targetLimbDmg.dmg >= 86 then
          limbIsUnderPrepped = true
        end
      end

      if not skipTorso then
        local targetTorsoDmg = targetWounds.torso
        if targetTorsoDmg.dmg >= 91 then
          torsoIsPrepped = true
          cecho('\n<gold>TORSO IS PREPPED!\n')
        elseif targetTorsoDmg.dmg >= 86 then
          torsoIsUnderPrepped = true
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
          if killStrat == 'pummel' then
            Megophrys.priorityLabel:echo('<center>Priority: FREEZE</center>')
          elseif killStrat == 'fiyah' then
            Megophrys.priorityLabel:echo('<center>Priority: DEHYDRATE</center>')
            Magi.followUp = 'golem dehydrate '.. target
            Megophrys.targetHits = 0
          end
          Magi.setElement('air')
          targetTorso = false
        end
      else
        Megophrys.priorityLabel:echo('<center>Priority: LIMB PREP</center>')
        if (targetRebounding or (not targetTorso and limbIsUnderPrepped) or
            (targetTorso and torsoIsUnderPrepped)) then
          Magi.setElement('air')
        else
          if (Megophrys.targetHits or 0) < 1 then
            Magi.setElement('air')
          else
            Magi.setElement('earth')
          end
        end
      end

      local cmd = 'staffstrike '.. target ..' with '.. Magi.element

      if killStrat == 'pummel' then
        local timeToFreeze = (limbIsPrepped and (skipTorso or torsoIsPrepped))
        if timeToFreeze and not Magi.targetMaybeFrozen then
          Magi.targetMaybeFrozen = true
          sendAll('clearqueue all',
                  ('setalias nextAttack staffstrike '.. target ..' with air '..
                   targetLimb ..' leg / golem smash '.. target ..' '.. Magi.golemSmashTarget),
                  'queue add eqbal nextAttack')
          return
        else
          if Magi.targetFrozen then
            -- kill condition met: pummel to death
            Megophrys.priorityLabel:echo('<center>Priority: PUMMEL</center>')
            Magi.setElement('water')
            cmd = 'staffstrike '.. target ..' with '.. Magi.element
            if (Megophrys.targetHits or 0) == 0 then
              Magi.followUp = 'golem hypothermia '.. target
            else
              Magi.followUp = 'golem pummel '.. target
            end
            targetTorso = true
          elseif targetMaybeFrozen then
            -- we've hopefully tripped our limb prep and proned, so now we
            -- either need to trip torso and deepfreeze or just deepfreeze
            -- if it sticks we hypothermia and make kill condition
            -- otherwise we're back to prepping limbs
            Magi.targetFrozen = true
            Magi.setElement('water')
            if skipTorso then
              sendAll('clearqueue all',
                      'setalias nextAttack cast deepfreeze',
                      'queue add eqbal nextAttack')
            else
              sendAll('clearqueue all',
                      ('setalias nextAttack staffstrike '.. target ..' with '..
                       Magi.element ..' torso / golem smash '..
                       target ..' '.. Magi.golemSmashTarget),
                      'queue add eqbal nextAttack',
                      'setalias nextAttack cast deepfreeze',
                      'queue add eqbal nextAttack')
              Magi.skipNextEq = true
            end
            Magi.targetMaybeFrozen = false
            Megophrys.targetHits = 0
            return
          end
        end
      elseif killStrat == 'fiyah' then
        if Magi.targetDehydrated then
          Megophrys.priorityLabel:echo('<center>Priority: DESTROY/center>')
          Magi.setElement('fire')
          cmd = 'staffstrike '.. target ..' with '.. Magi.element
          if (Megophrys.targetHits or 0) % 3 == 0 then
            Magi.followUp = 'golem destroy '.. target
          elseif (Megophrys.targetHits or 0) % 3 == 1 then
            Magi.followUp = 'golem conflagrate '.. target
          else
            Magi.followUp = 'golem destabilise heat / golem scorch '.. target
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
          'clearqueue all',
          'setalias nextAttack '.. cmd .. '/' .. Magi.followUp,
          'queue add eqbal nextAttack'
        )
        Megophrys.targetHits = Megophrys.targetHits + 1

        -- reset limb damage if we hit L2 break
        if targetLimbDmg.dmg >= 100 then
          targetLimbDmg.dmg = 0
        end

        if targetTorsoDmg.dmg >= 100 then
          targetTorsoDmg.dmg = 0
        end
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

Magi.toggleGolemSmashTarget = function()
  if Magi.golemSmashTarget == 'arms' then
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
