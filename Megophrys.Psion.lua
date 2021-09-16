Megophrys.Psion = (Megophrys.Psion or {})
local Psion = Megophrys.Psion

Megophrys.Psion.onConnect = function()
  -- pass
end

Megophrys.Psion.setMode = function()
  local Psion = Megophrys.Psion
  local killStrat = Megophrys.killStrat

  if killStrat == 'denizen' then
    Megophrys.timeUntilNextAttack = 1.88
    Megophrys.Psion.setWeavePrep('clumsiness')
    Megophrys.nextMoveButton:echo('Overhand', Megophrys.fgColors[killStrat], 'c')
  else
    Megophrys.timeUntilNextAttack = 2.03
    Megophrys.Psion.setWeavePrep('paralysis')
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
  local imSoClever = ''
  local killStrat = Megophrys.killStrat
  local nextWeave = ''
  local nextPsi = ''
  local preAlias = 'setalias nextAttack stand / stand'
  local targetAffs = affstrack.score
  local targetHits = Megophrys.targetHits or 0
  local uiColor = Megophrys.fgColors[killStrat]

  if killStrat == 'denizen' then
    if ak.defs.shield then
      send('queue prepend eqbal weave pulverise &tar')
    end
    nextWeave = 'overhand'
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
      elseif ((ak.psion.unweaving.body > 3 and ak.psion.unweaving.mind > 3) or
              (ak.psion.unweaving.body > 3 and ak.psion.unweaving.spirit > 3) or
              (ak.psion.unweaving.mind > 3 and ak.psion.unweaving.spirit > 3)) then
        nextPsi = 'deconstruct'
        nextWeave = 'deathblow'
        imSoClever = 'say Another enemy unmade. Hah!'
      elseif targetHits == 0 then
        nextWeave = 'backhand'
        imSoClever = 'say SLAP!!'
      elseif targetAffs.clumsiness < 60 then
        nextWeave = 'sever'
        imSoClever = 'warcry'
      elseif targetAffs.asthma < 60 then
        nextWeave = 'deathblow'
        imSoClever = 'say *forcefully Die, heretic!'
      elseif targetAffs.unweavingBody <= 50 then
        nextWeave = 'unweave body'
      elseif targetAffs.unweavingmind <=50 then
        nextWeave = 'unweave mind'
      elseif targetHits % 2 == 1 then
        nextWeave = 'overhand'
        imSoClever = 'say BONK!!'
      else
        nextWeave = 'exsanguinate'
        imSoClever = 'warcry'
      end
    end
  end

  if tonumber(ak.psion.transcend or 0) > 99 then
    if killStrat == 'denizen' then
      nextPsi = 'shatter'
    else
      nextPsi = 'blast'
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

  Psion.nextPsiMoveButton:echo(nextPsi or '')

  --if imSoClever ~= '' then
  --  setNextAttack = setNextAttack ..' / '.. imSoClever
  --end

  sendAll(setNextAttack, 'queue addclear eqbal nextAttack')
  if not ak.defs.shield then
    Megophrys.targetHits = targetHits + 1
  end

  Megophrys.autoAttackTimerId = tempTimer(Megophrys.timeUntilNextAttack,
                                          Psion.nextAttack)
end
