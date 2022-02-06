Megophrys.Psion = (Megophrys.Psion or {})
local Psion = Megophrys.Psion

Megophrys.Psion.onConnect = function()
  sendAll(
    'unwield all',
    'remove armour',
    'put armour in pack370332',
    'wield shield268649 right'
  )
end

Megophrys.Psion.setMode = function()
  local Psion = Megophrys.Psion
  local killStrat = Megophrys.killStrat

  if killStrat == 'denizen' then
    Megophrys.Psion.setWeavePrep('clumsiness')
    Megophrys.nextMoveButton:echo('BONK!', Megophrys.fgColors[killStrat], 'c')
  elseif killStrat == 'los' then
    Megophrys.nextMoveButton:echo('Destruction', Megophrys.fgColors[killStrat], 'c')
  else
    Megophrys.Psion.setWeavePrep('paralysis')
    Megophrys.nextMoveButton:echo('<i>*SLAP*</i>', Megophrys.fgColors[killStrat], 'c')
  end

  if killStrat == 'los' then
    Megophrys.psionToolbar:hide()
  else
    Megophrys.psionToolbar:show()
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
    x=270, y=0, width=270, height=60
  })

  Psion.wpLabel = Geyser.Label:new({
    name='wp_label',
    x=0, y=0, width=100, height=20,
    message='Prepared:'
  }, Megophrys.psionToolbar)
  Psion.wpLabel:setFontSize(11)
  Psion.weavePrepButton = Geyser.Label:new({
    name='weave_prep_button',
    x=100, y=0, width=170, height=20,
  }, Megophrys.psionToolbar)
  Psion.weavePrepButton:setFontSize(11)

  Psion.nextPsiMoveLabel = Geyser.Label:new({
    name='next_psi_move_label',
    x=0, y=20, width=100, height=20,
    message='Bonus atk:'
  }, Megophrys.psionToolbar)
  Psion.nextPsiMoveLabel:setFontSize(11)
  Psion.nextPsiMoveButton = Geyser.Label:new({
    name='next_psi_move',
    x=100, y=20, width=170, height=20,
  }, Megophrys.psionToolbar)
  Psion.nextPsiMoveButton:setFontSize(11)

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
    Megophrys.givingAffs = {prep}
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
  local nextWeave = 'overhand &tar'
  local nextPsi = ''
  local preAlias = 'setalias nextAttack '
  local targetAffs = affstrack.score
  local targetHits = Megophrys.targetHits or 0
  local uiColor = Megophrys.fgColors[killStrat]

  local unweavingBody = (ak.psion.unweaving.body or 0)
  local unweavingMind = (ak.psion.unweaving.mind or 0)
  local unweavingSpirit = (ak.psion.unweaving.spirit or 0)

  if not wsysf.affs.stupidity then
    setNextAttack = setNextAttack .. 'stand / '
  end

  if killStrat == 'denizen' then
    if ak.defs.shield then
      send('queue prepend eqbal weave pulverise &tar')
    end
  elseif killStrat == 'los' then
    if Psion.clarityUp then
      send('enact clarity')
    else
      send('enact destruction '.. target ..' '.. Megophrys.LOSDirection)
    end
  else
    if ak.defs.shield then
      Megophrys.nextMoveButton:echo('Cleave Shield', Megophrys.fgColors[killStrat], 'c')
      nextWeave = 'cleave &tar'
    else
      if not tarAff("paralysis") then
        Megophrys.Psion.setWeavePrep('paralysis')
      elseif not tarAff("clumsiness") then
        Megophrys.Psion.setWeavePrep('clumsiness')
      elseif not tarAff("asthma") then
        Megophrys.Psion.setWeavePrep('asthma')
      else
        Megophrys.Psion.setWeavePrep('haemophilia')
      end

      local targetManaPct = (ak.currentmana or 0) / (ak.maxmana or 1)
      if targetManaPct <= 0.3 then
        nextPsi = 'excise'
        nextWeave = 'deathblow &tar'
        imSoClever = 'say You cannot resist!'
        chanceToMouthOff = 1
      elseif ((unweavingBody > 3 and unweavingMind > 3) or
              (unweavingBody > 3 and unweavingSpirit > 3) or
              (unweavingMind > 3 and unweavingSpirit > 3)) then
        nextPsi = 'deconstruct'
        nextWeave = 'deathblow &tar'
        imSoClever = 'say Another enemy unmade. Hah!'
        chanceToMouthOff = 1
      elseif unweavingBody > 4 and unweavingMind < 1 then
        nextWeave = 'invert &tar body spirit'
        imSoClever = ''
        chanceToMouthOff = 0
      elseif unweavingMind > 4 and unweavingBody < 1 then
        nextWeave = 'invert &tar mind spirit'
        imSoClever = ''
        chanceToMouthOff = 0
      elseif unweavingSpirit > 4 then
        nextWeave = 'flurry &tar'
        imSoClever = 'say *forcefully Die, heretic!'
        chanceToMouthOff = 0.2
      elseif targetHits % 2 == 0 then
        if not tarAff("unweavingbody") then
          nextWeave = 'unweave &tar body'
          table.insert(Megophrys.givingAffs, 'unweavingbody')
        elseif not tarAff("unweavingmind") then
          nextWeave = 'unweave &tar mind'
          table.insert(Megophrys.givingAffs, 'unweavingmind')
        else
          nextWeave = 'sever &tar'
          imSoClever = 'warcry'
          chanceToMouthOff = 0.1
          table.insert(Megophrys.givingAffs, 'clumsiness')
        end
      elseif not tarAff("stupidity") then
        chanceToMouthOff = 0.4
        if math.random() < 0.5 then
          nextWeave = 'backhand &tar'
          imSoClever = 'say SLAP!!'
          table.insert(Megophrys.givingAffs, 'stupidity')
          table.insert(Megophrys.givingAffs, 'dizziness')
        else
          nextWeave = 'overhand &tar'
          imSoClever = 'say BONK!!'
          if tarAff('prone') or lb[target].hits.head > 100 then
            table.insert(Megophrys.givingAffs, 'impatience')
          else
            table.insert(Megophrys.givingAffs, 'stupidity')
          end
        end
      elseif tarAff("impatience") and tarAff("bloodfire") then
        nextWeave = 'exsanguinate &tar'
        imSoClever = 'say *forcefully Die, heretic!'
        chanceToMouthOff = 0.2
        table.insert(Megophrys.givingAffs, 'nausea')
        if (ak.bleeding or 0) > 150 then
          table.insert(Megophrys.givingAffs, 'anorexia')
        end
      elseif tarAff("impatience") and tarAff("bloodfire") and tarAff("anorexia") then
        if not tarAff("unweavingbody") then
          nextWeave = 'unweave &tar body'
          table.insert(Megophrys.givingAffs, 'unweavingbody')
        elseif not tarAff("unweavingmind") then
          nextWeave = 'unweave &tar mind'
          table.insert(Megophrys.givingAffs, 'unweavingmind')
        else
          nextWeave = 'deathblow &tar'
          if not Megophrys.givingAffs:contains('asthma') then
            table.insert(Megophrys.givingAffs, 'asthma')
          end
        end
        imSoClever = ''
        chanceToMouthOff = 0
      else
        nextWeave = 'deathblow &tar'
        imSoClever = 'warcry'
        chanceToMouthOff = 0.1
        if not Megophrys.givingAffs:contains('asthma') then
          table.insert(Megophrys.givingAffs, 'asthma')
        end
      end
    end
  end

  if tonumber(ak.psion.transcend or 0) > 99 then
    if killStrat == 'denizen' then
      nextPsi = 'shatter'
    else
      if (ak.bleeding or 0) > 150 then
        nextPsi = 'combustion'
        table.insert(Megophrys.givingAffs, 'bloodfire')
      elseif not tarAff("mindravaged") and (
            tarAff("impatience") and tarAff("stupidity") and (
                tarAff("dizziness") or tarAff("unweavingmind")
            )) then
        nextPsi = 'blast'
        table.insert(Megophrys.givingAffs, 'mindravaged')
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

  setNextAttack = setNextAttack ..'/ weave '.. nextWeave

  if killStrat ~= 'denizen' then
    setNextAttack = setNextAttack ..' / contemplate &tar'
    if not Psion.lightBindUp then
      setNextAttack = setNextAttack ..' / enact lightbind &tar'
    end
  end

  Psion.nextPsiMoveButton:echo(nextPsi or '', uiColor, 'c')

  if wsysf.affs.prone then
    send('stand')
  else
    if imSoClever ~= '' and math.random() < chanceToMouthOff then
      setNextAttack = setNextAttack ..' / '.. imSoClever
    end
  end

  sendAll(setNextAttack, 'queue addclear eqbal nextAttack')
  if not ak.defs.shield then
    Megophrys.targetHits = targetHits + 1
  end

  if killStrat ~= 'denizen' then
    if #Megophrys.givingAffs == 1 then
      send('pt '.. Megophrys.givingAffs[1] ..' on '.. target)
    elseif #Megophrys.givingAffs == 2 then
      send('pt '.. Megophrys.givingAffs[1] ..' and '.. Megophrys.givingAffs[2] ..
           ' on '.. target)
    elseif #Megophrys.givingAffs == 3 then
      send('pt '.. Megophrys.givingAffs[1] ..', '.. Megophrys.givingAffs[2] ..
           ' and '.. Megophrys.givingAffs[3] ..' on '.. target)
    end
  end
end
