Megophrys.Psion = (Megophrys.Psion or {})
local Psion = Megophrys.Psion

Megophrys.Psion.onConnect = function()
  -- pass
end

Megophrys.Psion.setMode = function()
  local Psion = Megophrys.Psion
  local killStrat = Megophrys.killStrat

  if killStrat == 'denizen' then
    Megophrys.Psion.setWeavePrep('clumsiness')
    Megophrys.nextMoveButton:echo('BONK!', Megophrys.fgColors[killStrat], 'c')
  else
    Megophrys.Psion.setWeavePrep('paralysis')
    Megophrys.nextMoveButton:echo('<i>*SLAP*</i>', Megophrys.fgColors[killStrat], 'c')
  end

  Megophrys.specialMoveButton:echo(
    'Wavesurge (ESC)',
    Megophrys.fgColors[killStrat],
    'c'
  )
end

Megophrys.Psion.doSpecial = function() send('enact wavesurge') end

Megophrys.Psion.makeClassToolbars = function()
  Megophrys.psionToolbar = Geyser.Container:new({
    name='psion_toolbar',
    x=200, y=0, width=210, height=16
  })

  Psion.wpLabel = Geyser.Label:new({
    name='wp_label',
    x=0, y=0, width=80, height=20,
    bgColor='black',
    message='Preparation:'
  }, Megophrys.psionToolbar)
  Psion.weavePrepButton = Geyser.Label:new({
    name='weave_prep_button',
    x=70, y=0, width=130, height=20,
    bgColor='black'
  }, Megophrys.psionToolbar)

  Psion.nextPsiMoveLabel = Geyser.Label:new({
    name='next_psi_move_label',
    x=0, y=20, width=70, height=20,
    bgColor='black',
    message='Bonus atk:'
  }, Megophrys.psionToolbar)
  Psion.nextPsiMoveButton = Geyser.Label:new({
    name='next_psi_move',
    x=70, y=20, width=130, height=20,
    bgColor='black'
  }, Megophrys.psionToolbar)

  Psion.setMode('denizen')
  Megophrys.updatePrepGauges()
end

Megophrys.Psion.setWeavePrep = function(prep)
  local weavePrepMap = {
    paralysis = 'disruption',
    haemophilia = 'laceration',
    clumsiness = 'dazzle',
    epilepsy = 'rattle',
    asthma = 'vapours'
  }

  Megophrys.Psion.weavePrep = weavePrepMap[prep:lower()]
  if Megophrys.Psion.weavePrep then
    cecho(('\n<cyan>Set weave prep to '.. Megophrys.Psion.weavePrep
           ..' ('.. prep ..')\n'))
    Megophrys.Psion.weavePrepButton:echo(prep:lower():title(),
                                   Megophrys.fgColors[Megophrys.killStrat],
                                   'c')
  end
end

Megophrys.Psion.nextAttack = function()
  local Psion = Megophrys.Psion
  local chanceToMouthOff = 0
  local imSoClever = ''
  local killStrat = Megophrys.killStrat
  local nextWeave = ''
  local nextPsi = ''
  local preAlias = 'setalias nextAttack stand / stand'
  local targetAffs = affstrack.score
  local targetHits = Megophrys.targetHits or 0
  local uiColor = Megophrys.fgColors[killStrat]

  local unweavingBody = (ak.psion.unweaving.body or 0)
  local unweavingMind = (ak.psion.unweaving.mind or 0)
  local unweavingSpirit = (ak.psion.unweaving.spirit or 0)

  if killStrat == 'denizen' then
    if ak.defs.shield then
      send('queue prepend eqbal weave pulverise &tar')
    end
    nextWeave = 'overhand'
    imSoClever = ''
    chanceToMouthOff = 0
  else
    if ak.defs.shield then
      Megophrys.nextMoveButton:echo('Cleave Shield', Megophrys.fgColors[killStrat], 'c')
      nextWeave = 'cleave'
    else
      if targetAffs.paralysis < 100 then
        Megophrys.Psion.setWeavePrep('paralysis')
      elseif targetAffs.clumsiness < 60 then
        Megophrys.Psion.setWeavePrep('clumsiness')
      elseif targetAffs.asthma < 60 then
        Megophrys.Psion.setWeavePrep('asthma')
      else
        Megophrys.Psion.setWeavePrep('haemophilia')
      end

      local targetManaPct = (Megophrys.targetManaPct or 0)
      if targetManaPct <= 30 then
        nextPsi = 'excise'
        nextWeave = 'deathblow'
        imSoClever = 'say You cannot resist!'
        chanceToMouthOff = 1
      elseif ((unweavingBody > 3 and unweavingMind > 3) or
              (unweavingBody > 3 and unweavingSpirit > 3) or
              (unweavingMind > 3 and unweavingSpirit > 3)) then
        nextPsi = 'deconstruct'
        nextWeave = 'deathblow'
        imSoClever = 'say Another enemy unmade. Hah!'
        chanceToMouthOff = 1
      elseif targetHits == 0 then
        nextWeave = 'backhand'
        imSoClever = 'say SLAP!!'
        chanceToMouthOff = 0.8
      elseif targetAffs.clumsiness < 60 then
        nextWeave = 'sever'
        imSoClever = 'warcry'
        chanceToMouthOff = 0.1
      elseif targetAffs.asthma < 60 then
        nextWeave = 'deathblow'
        imSoClever = 'warcry'
        chanceToMouthOff = 0.1
      elseif (targetAffs.impatience > 90 and
              targetAffs.bloodfire > 90) then
        nextWeave = 'exsanguinate'
        imSoClever = 'say *forcefully Die, heretic!'
        chanceToMouthOff = 0.2
      elseif (targetAffs.impatience > 90 and
              targetAffs.bloodfire > 90 and
              targetAffs.anorexia > 90) then
        if unweavingBody < 50 then
          nextWeave = 'unweave body'
        elseif unweavingMind < 50 then
          nextWeave = 'unweave mind'
        else
          nextWeave = 'deathblow'
        end
        imSoClever = ''
        chanceToMouthOff = 0
      elseif targetHits % 2 == 1 then
        nextWeave = 'overhand'
        imSoClever = 'say BONK!!'
        chanceToMouthOff = 0.4
      else
        nextWeave = 'deathblow'
        imSoClever = 'warcry'
        chanceToMouthOff = 0.1
      end
    end
  end

  if tonumber(ak.psion.transcend or 0) > 99 then
    if killStrat == 'denizen' then
      nextPsi = 'shatter'
    else
      if (ak.bleeding or 0) > 150 then
        nextPsi = 'combustion'
      elseif (targetAffs.mindravaged or 0) < 50 then
        nextPsi = 'blast'
      else
        if targetHits % 2 == 1 then
          nextPsi = 'muddle'
        else
          nextPsi = 'shatter'
        end
      end
    end
  end

  local setNextAttack = preAlias
  if nextPsi ~= '' then
    setNextAttack = setNextAttack ..'/ psi '.. nextPsi ..' &tar'
  end
  if Psion.weavePrep ~= '' then
    setNextAttack = setNextAttack ..' / weave prepare '.. Psion.weavePrep
  end

  setNextAttack = setNextAttack ..'/ weave '.. nextWeave ..' &tar'

  if killStrat ~= 'denizen' then
    setNextAttack = setNextAttack ..' / contemplate &tar'
    if not Psion.lightBindUp then
      setNextAttack = setNextAttack ..' / enact lightbind &tar'
    end
  end

  Psion.nextPsiMoveButton:echo(nextPsi or '', uiColor, 'c')

  if imSoClever ~= '' and math.random() < chanceToMouthOff then
    setNextAttack = setNextAttack ..' / '.. imSoClever
  end

  sendAll(setNextAttack, 'queue addclear eqbal nextAttack')
  if not ak.defs.shield then
    Megophrys.targetHits = targetHits + 1
  end
end
