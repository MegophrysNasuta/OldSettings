Megophrys.Apostate = (Megophrys.Apostate or {})
local Apostate = Megophrys.Apostate

Apostate.doSpecial = function() send('educe tin') end

Megophrys.Apostate.makeClassToolbars = function()
  Megophrys.alchToolbar = Geyser.Container:new({
    name='apos_toolbar',
    x=270, y=0, width=270, height=60
  })

  Apostate.humourLabel = Geyser.Label:new({
    name='humour_label',
    x=0, y=0, width=100, height=20,
    message='Humour:'
  }, Megophrys.alchToolbar)
  Apostate.humourLabel:setFontSize(11)
  Apostate.melancholicButton = Geyser.Label:new({
    name='melancholic_button',
    x=100, y=0, width=42, height=20,
  }, Megophrys.alchToolbar)
  Apostate.melancholicButton:setFontSize(11)
  Apostate.cholericButton = Geyser.Label:new({
    name='choleric_button',
    x=142, y=0, width=42, height=20,
  }, Megophrys.alchToolbar)
  Apostate.cholericButton:setFontSize(11)
  Apostate.sanguineButton = Geyser.Label:new({
    name='sanguine_button',
    x=184, y=0, width=42, height=20,
  }, Megophrys.alchToolbar)
  Apostate.sanguineButton:setFontSize(11)
  Apostate.phlegmaticButton = Geyser.Label:new({
    name='phlegmatic_button',
    x=226, y=0, width=42, height=20,
  }, Megophrys.alchToolbar)
  Apostate.phlegmaticButton:setFontSize(11)

  Apostate.nextWrackLabel = Geyser.Label:new({
    name='next_wrack_label',
    x=0, y=20, width=100, height=20,
    message='Next wrack: '
  }, Megophrys.alchToolbar)
  Apostate.nextWrackLabel:setFontSize(11)
  Apostate.nextWrackButton = Geyser.Label:new({
    name='next_wrack',
    x=100, y=20, width=170, height=20,
  }, Megophrys.alchToolbar)
  Apostate.nextWrackButton:setFontSize(11)

  Apostate.setMode('denizen')
  Megophrys.updatePrepGauges()
end

Megophrys.Apostate.onConnect = function()
  sendAll(
    'unwield all',
    'remove armour',
    'put armour in pack370332',
  )
  tempTimer(0.2, Megophrys.Apostate.gearUp)
end

Megophrys.Apostate.gearUp = function()
  sendAll(
    'wield shield268649 right',
  )
end

Megophrys.Apostate.nextAttack = function()
  local Apostate = Megophrys.Apostate
  local chanceToMouthOff = 0
  local imSoClever = ''
  local killStrat = Megophrys.killStrat
  local nextEduce = ''
  local nextTemper = ''
  local nextWrack = ''
  local targetAffs = affstrack.score
  local targetHits = Megophrys.targetHits or 0
  local uiColor = Megophrys.fgColors[killStrat]

  local tarAff = affstrack.score
  local targetHumour = {}
  targetHumour.sanguine = (ak.alchemist.humour.sanguine or 0)
  targetHumour.melancholic = (ak.alchemist.humour.melancholic or 0)
  targetHumour.choleric = (ak.alchemist.humour.choleric or 0)
  targetHumour.phlegmatic = (ak.alchemist.humour.phlegmatic or 0)

  local preAlias = 'setalias nextAttack '
  if killStrat ~= 'denizen' then
    preAlias = preAlias .. 'homunculus attack &tar / evaluate &tar / '
  end
  if not wsys.aff.stupidity then
    preAlias = preAlias .. 'stand / '
  end

  local firstAff = nil
  local secondAff = nil
  if killStrat == 'denizen' then
    preAlias = preAlias .. 'throw miasma at &tar / educe magnesium &tar / '
    nextEduce = 'iron'
  elseif killStrat == 'los' then
    local LOSCommand = 'throw'
    if Megophrys.targetHits % 3 == 0 then
      LOSCommand = LOSCommand ..' devitalisation '
    elseif Megophrys.targetHits % 2 == 0 then
      LOSCommand = LOSCommand ..' incendiary '
    else
      LOSCommand = LOSCommand ..' intoxicant '
    end
    send(LOSCommand .. Megophrys.LOSDirection)
  else
    if ak.defs.shield then
      Megophrys.nextMoveButton:echo('Educe Copper', Megophrys.fgColors[killStrat], 'c')
      nextEduce = 'copper'
    else
      local targetManaPct = (ak.currentmana or 0) / (ak.maxmana or 1)
      local targetHealthPct = (ak.currenthealth or 0) / (ak.maxhealth or 1)
      if targetManaPct <= 0.6 and (targetHealthPct <= 0.6 or 
                                   (targetHealthPct <= 0.66 and targetHumour.choleric > 2) or
                                   (targetHealthPct <= 0.72 and targetHumour.choleric > 4)) then
        nextTemper = 'inundate &tar choleric'
        nextWrack = 'aurify &tar'
      else
        if targetHumour.sanguine < 1 then
          Apostate.setHumour('sanguine')
        elseif targetHumour.melancholic < 1 then
          Apostate.setHumour('melancholic')
        elseif targetHumour.phlegmatic < 1 then
          Apostate.setHumour('phlegmatic')
        elseif targetHumour.choleric < 1 then
          Apostate.setHumour('choleric')
        elseif targetHumour.melancholic < 2 then
          Apostate.setHumour('melancholic')
        else
          Apostate.setHumour('choleric')
        end

        local chooseAff = function(ignoreAff)
          local affPrios = {
            paralysis = 'sanguine',       -- eat bloodroot
            impatience = 'melancholic',   -- eat goldenseal
            asthma = 'phlegmatic',        -- eat kelp
            clumsiness = 'phlegmatic',    -- eat kelp
            sensitivity = 'choleric',     -- eat kelp
            slickness = 'choleric',       -- smoke valerian, eat bloodroot
            nausea = 'choleric',          -- eat ginseng
            anorexia = 'melancholic',     -- apply epidermal
            haemophilia = 'sanguine',     -- eat ginseng
            recklessness = 'sanguine',    -- eat lobelia, focus
            stupidity = 'melancholic',    -- eat goldenseal
            weariness = 'phlegmatic',     -- eat kelp
          }
          for aff, humour in pairs(affPrios) do
            if (ignoreAff ~= aff and
                targetHumour[humour] > 0 and tarAff[aff] < 80) then
              return aff
            end
          end
        end

        firstAff = chooseAff()
        secondAff = chooseAff(firstAff)

        imSoClever = 'warcry'
        chanceToMouthOff = 0.1
      end
    end
  end

  local setNextAttack = preAlias
  if nextEduce then
    setNextAttack = setNextAttack ..'educe '.. nextEduce .. ' &tar / '
    secondAff = ''
  end

  local targetIsLocked = (
    tarAff["paralysis"] > 80 and tarAff["anorexia"] > 80 and tarAff["asthma"] > 80 and
    tarAff["slickness"] > 80 and tarAff["impatience"] > 80
  )

  if targetIsLocked then
    sendAll('wield toxin', 'throw toxin at ground')
  else
    setNextAttack = setNextAttack .. (nextTemper or
                                      'temper &tar '.. Apostate.humour)
    table.insert(Megophrys.givingAffs, firstAff)
    if firstAff then
      if not secondAff then
        setNextAttack = setNextAttack ..' / wrack &tar '.. firstAff
      else
        setNextAttack = (setNextAttack ..' / truewrack &tar '..
                         firstAff ..' '.. secondAff)
        table.insert(Megophrys.givingAffs, secondAff)
      end
      Apostate.nextWrackButton:echo(firstAff ..' '.. secondAff, uiColor, 'c')
    end

    if wsys.aff.prone then
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

Apostate.resetHumourButtonStyles = function()
  Apostate.melancholicButton:echo('Me', 'white', 'c')
  Apostate.cholericButton:echo('Ch', 'white', 'c')
  Apostate.sanguineButton:echo('Sa', 'white', 'c')
  Apostate.phlegmaticButton:echo('Ph', 'white', 'c')
end

Apostate.setHumour = function(humour, reason)
  local elem = tostring(humour):lower()

  if elem == 'melancholic' then
    button = Apostate.melancholicButton
  elseif elem == 'choleric' then
    button = Apostate.cholericButton
  elseif elem == 'sanguine' then
    button = Apostate.sanguineButton
  elseif elem == 'phlegmatic' then
    button = Apostate.phlegmaticButton
  else
    cecho('\n<red>Unknown humour: '.. elem ..' (ignored)\n')
  end

  Apostate.humour = elem
  Apostate.resetHumourButtonStyles()
  button:echo(string.title(string.sub(elem, 1, 2)), Megophrys.fgColors[Megophrys.killStrat], 'c')

  if reason then
    cecho('\n<cyan>Humour set to: '.. Apostate.humour ..' ('.. reason ..')\n')
  else
    cecho('\n<cyan>Humour set to: '.. Apostate.humour ..'\n')
  end
end

Megophrys.Apostate.setMode = function()
  local Apostate = Megophrys.Apostate
  local killStrat = Megophrys.killStrat

  Apostate.resetHumourButtonStyles()

  if killStrat == 'denizen' then
    Megophrys.nextMoveButton:echo('Educe Iron', Megophrys.fgColors[killStrat], 'c')
  elseif killStrat == 'los' then
    Megophrys.nextMoveButton:echo('Nocturne', Megophrys.fgColors[killStrat], 'c')
  else
    Megophrys.Apostate.setHumour('sanguine')
    Megophrys.nextMoveButton:echo('Wrack', Megophrys.fgColors[killStrat], 'c')
  end

  if killStrat == 'los' then
    Megophrys.alchToolbar:hide()
  else
    Megophrys.alchToolbar:show()
  end

  Megophrys.specialMoveButton:echo(
    'Educe Tin',
    Megophrys.fgColors[killStrat],
    'c'
  )
end

Megophrys.Apostate.subMode = function(n)
  if n == 1 then
    Apostate.setElement('melancholic')
  elseif n == 2 then
    Apostate.setElement('choleric')
  elseif n == 3 then
    Apostate.setElement('sanguine')
  elseif n == 4 then
    Apostate.setElement('phlegmatic')
  else
    error('Bad sub mode: '.. n ..'!')
  end
end

Megophrys.Apostate.toggleOne = function(altMode)
  if Apostate.overdraw then
    Apostate.overdraw = false
    cecho('\n<cyan>No longer overdrawing.\n')
  else
    Apostate.overdraw = true
    cecho('\n<cyan>Overdrawing enabled!\n')
  end
end
