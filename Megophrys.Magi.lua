Megophrys.Magi = (Megophrys.Magi or {})
local Magi = Megophrys.Magi
Magi.element = (Magi.element or 'air')
Magi.skipTransfix = (Magi.skipTransfix or false)
Magi.targetTransfixed = (Magi.targetTransfixed or false)
Magi.timefluxUp = (Magi.timefluxUp or false)

Magi.staffCasts = {
  earth = 'dissolution',
  fire = 'scintilla',
  air = 'lightning',
  water = 'horripilation',
}

Megophrys.Magi.onConnect = function()
  sendAll('simultaneity', 'bind all', 'fortify all')
end

Megophrys.Magi.makeClassToolbars = function()
  Megophrys.magiToolbar = Geyser.Container:new({
    name='magi_toolbar',
    x=200, y=0, width=150, height=16
  })

  Magi.elemLabel = Geyser.Label:new({
    name='elem_label',
    x=0, y=0, width=80, height=20,
    bgColor='black',
    message='Element:'
  }, Megophrys.magiToolbar)
  Magi.earthButton = Geyser.Label:new({
    name='earth_button',
    x=80, y=0, width=30, height=20,
    bgColor='black'
  }, Megophrys.magiToolbar)
  Magi.fireButton = Geyser.Label:new({
    name='fire_button',
    x=110, y=0, width=30, height=20,
    bgColor='black'
  }, Megophrys.magiToolbar)
  Magi.airButton = Geyser.Label:new({
    name='air_button',
    x=140, y=0, width=30, height=20,
    bgColor='black'
  }, Megophrys.magiToolbar)
  Magi.waterButton = Geyser.Label:new({
    name='water_button',
    x=170, y=0, width=30, height=20,
    bgColor='black'
  }, Megophrys.magiToolbar)

  Magi.nextGolemMoveLabel = Geyser.Label:new({
    name='next_golem_move_label',
    x=0, y=20, width=70, height=20,
    bgColor='black',
    message='Golem will:'
  }, Megophrys.magiToolbar)
  Magi.nextGolemMoveButton = Geyser.Label:new({
    name='next_golem_move',
    x=70, y=20, width=130, height=20,
    bgColor='black'
  }, Megophrys.magiToolbar)

  Magi.golemSmashLabel = Geyser.Label:new({
    name='golem_smash_label',
    x=0, y=40, width=70, height=20,
    bgColor='black',
    message='Smashing:'
  }, Megophrys.magiToolbar)
  Magi.golemSmashButton = Geyser.Label:new({
    name='golem_smash_move',
    x=70, y=40, width=130, height=20,
    bgColor='black'
  }, Megophrys.magiToolbar)
end

Megophrys.Magi.setMode = function()
  local Magi = Megophrys.Magi
  local killStrat = Megophrys.killStrat

  Megophrys.specialMoveButton:echo(
    'Embed Focus',
    Megophrys.fgColors[killStrat],
    'c'
  )

  Megophrys.timeUntilNextAttack = 3.03
  if killStrat == 'denizen' then
    Megophrys.nextMoveButton:echo('Staffcast', Megophrys.fgColors[killStrat], 'c')
    Magi.nextGolemMoveButton:echo('Squeeze', Megophrys.fgColors[killStrat], 'c')
    Magi.golemSmashButton:echo('N/A', 'grey', 'c')
    Magi.setElement('air')
    Magi.followUp = 'golem squeeze &tar'
    cecho('\n<cyan>Auto-attacks will be staffcasts'..
          '\nElement: '.. Magi.element ..
          '\nFollow up: '.. Magi.followUp ..
          '\nTarget is: '.. target ..'\n')
  elseif killStrat == 'raid' then
    Magi.setElement('earth')
    if Magi.skipTransfix then
      Megophrys.nextMoveButton:echo('Staffcast', Megophrys.fgColors[killStrat], 'c')
    else
      Megophrys.nextMoveButton:echo('Transfix', Megophrys.fgColors[killStrat], 'c')
    end
    Magi.nextGolemMoveButton:echo('Timeflux', Megophrys.fgColors[killStrat], 'c')
    Magi.followUp = 'golem timeflux &tar'
    cecho('\n<cyan>Auto-attacks will be staffcasts'..
          '\nElement: '.. Magi.element ..
          '\nFollow up: '.. Magi.followUp ..
          '\nTarget is: '.. target ..'\n')
  elseif killStrat == 'pummel' then
    Megophrys.nextMoveButton:echo('Staffstrike', Megophrys.fgColors[killStrat], 'c')
    Magi.nextGolemMoveButton:echo('Timeflux', Megophrys.fgColors[killStrat], 'c')
    Megophrys.timeUntilNextAttack = 2.33
    cecho('\n<cyan>Magi PvP (Ice) mode activated!')

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
  elseif killStrat == 'fiyah' then
    Megophrys.nextMoveButton:echo('Staffstrike', Megophrys.fgColors[killStrat], 'c')
    Magi.nextGolemMoveButton:echo('Timeflux', Megophrys.fgColors[killStrat], 'c')
    Megophrys.timeUntilNextAttack = 2.33
    cecho('\n<cyan>Magi PvP (Fire) mode activated!')

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

  if killStrat ~= 'denizen' then Magi.setGolemStrat() end
end

Megophrys.Magi.subMode = function(n)
  if n == 1 then
    Magi.setElement('earth')
  elseif n == 2 then
    Magi.setElement('fire')
  elseif n == 3 then
    Magi.setElement('air')
  elseif n == 4 then
    Magi.setElement('water')
  else
    error('Bad sub mode: '.. n ..'!')
  end
end

Megophrys.Magi.doSpecial = function() send('embed focus') end

Megophrys.Magi.toggleOne = Magi.toggleSkipTransfix
Megophrys.Magi.toggleTwo = Megophrys.toggleDualPrep
Megophrys.Magi.toggleThree = Megophrys.toggleTargetLimb
Megophrys.Magi.toggleFour = Megophrys.toggleSkipTorso
Megophrys.Magi.toggleFive = Magi.toggleGolemSmashTarget

Megophrys.Magi.nextAttack = function()
  local Magi = Megophrys.Magi
  local killStrat = Megophrys.killStrat
  local staffCasts = Magi.staffCasts
  local setNextAttack = 'setalias nextAttack stand / wield staff217211 / '

  local staffSpell = staffCasts[Magi.element]
  if killStrat == 'denizen' then
    Megophrys.nextMoveButton:echo('Staffcast', Megophrys.fgColors[killStrat], 'c')
    sendAll((setNextAttack ..'cast dilation at &tar / staffcast '.. staffSpell 
             ..' at &tar / golem squeeze &tar'),
            'queue addclear eqbal nextAttack')
  else
    Magi.setGolemStrat()
    if killStrat == 'raid' then
      if not Megophrys.Magi.targetTransfixed then
        Megophrys.nextMoveButton:echo('Transfix', Megophrys.fgColors[killStrat], 'c')
        sendAll(setNextAttack ..'cast transfix at &tar',
                'queue addclear eqbal nextAttack')
      elseif (Megophrys.targetHits or 0) % 4 == 0 then
        Megophrys.targetHits = 1
        Megophrys.Magi.targetTransfixed = false
        Megophrys.nextMoveButton:echo('Transfix', Megophrys.fgColors[killStrat], 'c')
        sendAll(setNextAttack ..'cast transfix at &tar',
                'queue addclear eqbal nextAttack')
      else
        Megophrys.nextMoveButton:echo('Staffcast', Megophrys.fgColors[killStrat], 'c')
        sendAll(setNextAttack ..'staffcast '.. staffSpell ..' at &tar',
                'queue addclear eqbal nextAttack')
      end
      Megophrys.targetHits = Megophrys.targetHits + 1
    else
      local prepStatus = Magi.nextLimbPrepAttack()
      local targetLimb = prepStatus.targetLimb
      local targetTorso = prepStatus.targetTorso
      local cmd = 'staffstrike &tar with '.. Magi.element
      Megophrys.nextMoveButton:echo('Staffstrike', Megophrys.fgColors[killStrat], 'c')

      if killStrat == 'pummel' then
        if Megophrys.killPreConditionsMet and not Magi.targetMaybeFrozen then
          sendAll('clearqueue all', 'cast deepfreeze')
          Magi.targetMaybeFrozen = true
          Megophrys.killPreConditionsMet = false
          Megophrys.nextMoveButton:echo('Hypothermia', Megophrys.fgColors[killStrat], 'c')
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
          Megophrys.nextMoveButton:echo('Pummel', Megophrys.fgColors[killStrat], 'c')
          targetTorso = true
        end
      elseif killStrat == 'fiyah' then
        if Magi.targetDehydrated then
          Megophrys.priorityLabel:echo('<center>Priority: DESTROY</center>')
          Magi.setElement('fire', 'burning')
          cmd = 'staffstrike &tar with '.. Magi.element
          if (Megophrys.targetHits or 0) % 3 == 0 then
            Megophrys.nextMoveButton:echo('Conflagrate', Megophrys.fgColors[killStrat], 'c')
            Magi.followUp = 'golem destroy &tar'
          elseif (Megophrys.targetHits or 0) % 3 == 1 then
            Megophrys.nextMoveButton:echo('Heat / Scorch', Megophrys.fgColors[killStrat], 'c')
            Magi.followUp = 'golem conflagrate &tar'
          else
            Megophrys.nextMoveButton:echo('Try Destroy', Megophrys.fgColors[killStrat], 'c')
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
        Megophrys.nextMoveButton:echo('Dehydrate', Megophrys.fgColors[killStrat], 'c')
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

    if Megophrys.killPreConditionsMet then
      Megophrys.nextMoveButton:echo('Deepfreeze', Megophrys.fgColors[killStrat], 'c')
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
  Magi.earthButton:echo('Ea', 'white', 'c')
  Magi.fireButton:echo('Fi', 'white', 'c')
  Magi.airButton:echo('Ai', 'white', 'c')
  Magi.waterButton:echo('Wa', 'white', 'c')
end

Magi.setElement = function(element, reason)
  local elem = tostring(element):lower()

  if elem == 'earth' then
    button = Magi.earthButton
  elseif elem == 'fire' then
    button = Magi.fireButton
  elseif elem == 'air' then
    button = Magi.airButton
  elseif elem == 'water' then
    button = Magi.waterButton
  else
    cecho('\n<red>Unknown element: '.. elem ..' (ignored)\n')
  end

  Magi.element = elem
  Magi.resetElementButtonStyles()
  button:echo(string.title(string.sub(elem, 1, 2)), Megophrys.fgColors[Megophrys.killStrat], 'c')

  if reason then
    cecho('\n<cyan>Element set to: '.. Magi.element ..' ('.. reason ..')\n')
  else
    cecho('\n<cyan>Element set to: '.. Magi.element ..'\n')
  end
end

Magi.setGolemStrat = function()
  Magi.golemSmashTarget = 'arms'
  Magi.golemSmashButton:echo('Arms', Megophrys.fgColors[Megophrys.killStrat], 'c')
  if Magi.timefluxUp then
    if Megophrys.killStrat == 'fiyah' then
      if Magi.infernoDown then
        Magi.followUp = 'golem inferno'
      else
        Magi.followUp = 'golem scorch '.. target
      end
      Magi.nextGolemMoveButton:echo('Scorch', Megophrys.fgColors[killStrat], 'c')
    else
      Magi.nextGolemMoveButton:echo('Smash', Megophrys.fgColors[killStrat], 'c')
      Magi.followUp = 'golem smash '.. target .. ' '.. Magi.golemSmashTarget
    end
  else
    Magi.nextGolemMoveButton:echo('Timeflux', Megophrys.fgColors[killStrat], 'c')
    Magi.followUp = 'golem timeflux '.. target
  end
end

Magi.lostInferno = function()
  Magi.infernoDown = true
  Magi.nextGolemMoveButton:echo('Inferno', Megophrys.fgColors[Megophrys.killStrat], 'c')
end

Magi.targetIsTransfixed = function()
  Magi.targetTransfixed = true
  Magi.nextMoveButton:echo('Staffcast', Megophrys.fgColors[Megophrys.killStrat], 'c')
end

Magi.targetLostTimeflux = function()
  Magi.timefluxUp = false
  Magi.nextGolemMoveButton:echo('Timeflux', Megophrys.fgColors[Megophrys.killStrat], 'c')
end

Magi.toggleGolemSmashTarget = function()
  local killStrat = Megophrys.killStrat
  if Magi.golemSmashTarget and Magi.golemSmashTarget == 'arms' then
    cecho('\n<cyan>Golem will smash legs!\n')
    Magi.golemSmashButton:echo('Legs', Megophrys.fgColors[killStrat], 'c')
    Magi.golemSmashTarget = 'legs'
  else
    cecho('\n<cyan>Golem will smash arms!\n')
    Magi.golemSmashButton:echo('Arms', Megophrys.fgColors[killStrat], 'c')
    Magi.golemSmashTarget = 'arms'
  end
end

Magi.toggleSkipTransfix = function()
  local killStrat = Megophrys.killStrat
  Magi.skipTransfix = not Magi.skipTransfix

  if Megophrys.killStrat == 'raid' then
    if Magi.skipTransfix then
      Megophrys.nextMoveButton:echo('Staffcast', Megophrys.fgColors[killStrat], 'c')
    else
      Megophrys.nextMoveButton:echo('Transfix', Megophrys.fgColors[killStrat], 'c')
    end
  end

  if Magi.skipTransfix then
    cecho('\n<cyan>Skipping transfix! (Only doing damage.)\n')
  else
    cecho('\n<cyan>Adding transfix to raid rotation.\n')
  end
end
