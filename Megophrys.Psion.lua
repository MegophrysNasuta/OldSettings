Megophrys.Psion = (Megophrys.Psion or {})
local Psion = Megophrys.Psion

Megophrys.Psion.onConnect = function()
  -- pass
end

Megophrys.Psion.setMode = function()
  local Psion = Megophrys.Psion
  local killStrat = Megophrys.killStrat

  Megophrys.timeUntilNextAttack = 2.23
  Megophrys.Psion.setWeavePrep('paralysis')
  if killStrat == 'denizen' then
    Megophrys.nextMoveButton:echo('Overhand', Megophrys.fgColors[killStrat], 'c')
  end

  Megophrys.specialMoveButton:echo(
    'Psi Transcend',
    Megophrys.fgColors[killStrat],
    'c'
  )
end

Megophrys.Psion.doSpecial = function() send('psi transcend') end

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
  local setNextAttack = 'setalias nextAttack stand / stand / '
  local targetAffs = affstrack.score
  local targetHits = Megophrys.targetHits or 0
  local uiColor = Megophrys.fgColors[killStrat]

  if killStrat == 'denizen' then
    if ak.defs.shield then
      send('weave pulverise '.. target)
    end
    setNextAttack = setNextAttack ..'weave overhand &tar'
  else
    if ak.defs.shield then
      Megophrys.nextMoveButton:echo('Cleave Shield', Megophrys.fgColors[killStrat], 'c')
      setNextAttack = setNextAttack ..'weave cleave &tar'
    else
      if targetAffs.paralysis < 100 then
        Megophrys.Psion.setWeavePrep('paralysis')
      elseif targetAffs.asthma < 60 then
        Megophrys.Psion.setWeavePrep('asthma')
      else
        Megophrys.Psion.setWeavePrep('haemophilia')
      end
      setNextAttack = 'weave prepare '.. Psion.weavePrep ..' / '.. setNextAttack

      if targetManaPct <= 30 then
        setNextAttack = setNextAttack ..'psi excise &tar'
        imSoClever = 'say You cannot resist my power!'
      elseif targetHits == 0 then
        setNextAttack = setNextAttack ..'weave backhand &tar'
        imSoClever = 'say SLAP!!'
      elseif targetAffs.asthma < 60 then
        setNextAttack = setNextAttack ..'weave deathblow &tar'
        imSoClever = 'say *forcefully Die, heretic!'
      elseif targetAffs.unweavingmind <=50 then
        setNextAttack = setNextAttack .. 'weave unweave &tar mind'
      elseif targetAffs.unweavingBody <= 50 then
        setNextAttack = setNextAttack .. 'weave unweave &tar body'
      elseif targetHits % 2 == 1 then
        setNextAttack = setNextAttack ..'weave overhand &tar'
        imSoClever = 'say BONK!!'
      else
        setNextAttack = setNextAttack ..'weave exsanguinate &tar'
        imSoClever = 'warcry'
      end
    end
  end

  if killStrat ~= 'denizen' then
    setNextAttack = setNextAttack ..' / contemplate &tar'
    if not Psion.lightBindUp then
      setNextAttack = setNextAttack ..' / enact lightbind &tar'
    end
  end

  if ak.psion.transcend == 100 then
    if killStrat == 'denizen' then
      Psion.nextPsiMoveButton:echo('Shatter', uiColor, 'c')
      setNextAttack = setNextAttack ..' / psi shatter & tar'
    else
      Psion.nextPsiMoveButton:echo('Combustion', uiColor, 'c')
      setNextAttack = setNextAttack ..' / psi combustion & tar'
    end
  else
    Psion.nextPsiMoveButton:echo('')
  end

  if imSoClever ~= '' then
    setNextAttack = setNextAttack ..' / '.. imSoClever
  end

  sendAll(setNextAttack, 'queue addclear eqbal nextAttack')
  if not ak.defs.shield then
    Megophrys.targetHits = targetHits + 1
  end

  Megophrys.autoAttackTimerId = tempTimer(Megophrys.timeUntilNextAttack,
                                          Psion.nextAttack)
end
