Megophrys.Alchemist = (Megophrys.Alchemist or {})
local Alchemist = Megophrys.Alchemist
Alchemist.overdraw = false

Alchemist.doSpecial = function() send('educe tin') end

Megophrys.Alchemist.makeClassToolbars = function()
  Megophrys.alchToolbar = Geyser.Container:new({
    name='alch_toolbar',
    x=270, y=0, width=270, height=60
  })

  Alchemist.humourLabel = Geyser.Label:new({
    name='humour_label',
    x=0, y=0, width=100, height=20,
    message='Humour:'
  }, Megophrys.alchToolbar)
  Alchemist.humourLabel:setFontSize(11)
  Alchemist.melancholicButton = Geyser.Label:new({
    name='melancholic_button',
    x=100, y=0, width=42, height=20,
  }, Megophrys.alchToolbar)
  Alchemist.melancholicButton:setFontSize(11)
  Alchemist.cholericButton = Geyser.Label:new({
    name='choleric_button',
    x=142, y=0, width=42, height=20,
  }, Megophrys.alchToolbar)
  Alchemist.cholericButton:setFontSize(11)
  Alchemist.sanguineButton = Geyser.Label:new({
    name='sanguine_button',
    x=184, y=0, width=42, height=20,
  }, Megophrys.alchToolbar)
  Alchemist.sanguineButton:setFontSize(11)
  Alchemist.phlegmaticButton = Geyser.Label:new({
    name='phlegmatic_button',
    x=226, y=0, width=42, height=20,
  }, Megophrys.alchToolbar)
  Alchemist.phlegmaticButton:setFontSize(11)

  Alchemist.nextWrackLabel = Geyser.Label:new({
    name='next_wrack_label',
    x=0, y=20, width=100, height=20,
    message='Next wrack: '
  }, Megophrys.alchToolbar)
  Alchemist.nextWrackLabel:setFontSize(11)
  Alchemist.nextWrackButton = Geyser.Label:new({
    name='next_wrack',
    x=100, y=20, width=170, height=20,
  }, Megophrys.alchToolbar)
  Alchemist.nextWrackButton:setFontSize(11)

  Alchemist.setMode('denizen')
  Megophrys.updatePrepGauges()
end

Megophrys.Alchemist.onConnect = function()
  -- pass
end

Megophrys.Alchemist.nextAttack = function()
  local Alchemist = Megophrys.Alchemist
  local chanceToMouthOff = 0
  local imSoClever = ''
  local killStrat = Megophrys.killStrat
  local nextEduce = ''
  local nextTemper = ''
  local nextWrack = ''
  local preAlias = ('setalias nextAttack stand / stand / '..
                    'unwield staff217211 left / wield shield268649 right / '..
                    'homunculus attack &tar / ')
  local targetAffs = affstrack.score
  local targetHits = Megophrys.targetHits or 0
  local uiColor = Megophrys.fgColors[killStrat]

  local sanguineHumour = (ak.alchemist.humour.sanguine or 0)
  local melancholicHumour = (ak.alchemist.humour.melancholic or 0)
  local cholericHumour = (ak.alchemist.humour.choleric or 0)
  local phlegmaticHumour = (ak.alchemist.humour.phlegmatic or 0)

  if killStrat == 'denizen' then
    if ak.defs.shield then
      send('queue prepend eqbal throw caustic at &tar')
    end
  elseif killStrat == 'los' then
    local LOSCommand = 'enact destruction '.. target
    if target2 then LOSCommand = LOSCommand ..' '.. target2 end
    if target3 then LOSCommand = LOSCommand ..' '.. target3 end
    send(LOSCommand)
  else
    if ak.defs.shield then
      Megophrys.nextMoveButton:echo('Educe Copper', Megophrys.fgColors[killStrat], 'c')
      nextEduce = 'copper'
    else
      local targetManaPct = (ak.currentmana or 0) / (ak.maxmana or 1)
      local targetHealthPct = (ak.currenthealth or 0) / (ak.maxhealth or 1)
      if targetManaPct <= 0.6 and (targetHealthPct <= 0.6 or 
                                   (targetHealthPct <= 0.66 and cholericHumour > 2) or
                                   (targetHealthPct <= 0.72 and cholericHumour > 4)) then
        nextTemper = 'inundate choleric'
        nextWrack = 'aurify &tar'
      else
        if sanguineHumour < 3 then
          Alchemist.setHumour('sanguine')
        elseif cholericHumour < 5 then
          Alchemist.setHumour('choleric')
        elseif targetManaPct > 0.85 then
          Alchemist.setHumour('melancholic')
        elseif targetHealthPct > 0.8 then
          Alchemist.setHumour('sanguine')
        else
          Alchemist.setHumour('choleric')
        end

        local firstAff = ''
        local secondAff = ''
        if not tarAff("paralysis") then
          firstAff = "paralysis"
        else
          if melancholicHumour > 0 then
            if not tarAff("stupidity") then
              firstAff = "stupidity"
            elseif not tarAff("anorexia") then
              firstAff = "anorexia"
            elseif not tarAff("impatience") then
              firstAff = "impatience"
            end
          end
          if not firstAff and cholericHumour > 0 then
            if not tarAff("slickness") then
              firstAff = "slickness"
            elseif not tarAff("nausea") then
              firstAff = "nausea"
            end
          end
        end

        local remainingAffs = {
          'clumsiness', 'stupidity', 'slickness', 'impatience',
          'asthma', 'anorexia'
        }
        for _, aff in pairs(remainingAffs) do
          if not tarAff(aff) and firstAff ~= aff then
            secondAff = aff
          end
        end

        imSoClever = 'warcry'
        chanceToMouthOff = 0.1
      end
    end
  end

  local setNextAttack = preAlias
  if nextEduce then
    setNextAttack = setNextAttack .. nextEduce .. ' / '
    secondAff = ''
  end

  setNextAttack = setNextAttack .. (nextTemper or
                                    'temper &tar '.. Alchemist.humour)
  if not secondAff then
    setNextAttack = setNextAttack ..' / wrack &tar '.. firstAff
  else
    setNextAttack = (setNextAttack ..' / truewrack &tar '..
                     firstAff ..' '.. secondAff)
  end


  if killStrat ~= 'denizen' then
    setNextAttack = setNextAttack ..' / evaluate &tar humours'
  end

  Alchemist.nextWrackButton:echo(firstAff ..' '.. secondAff, uiColor, 'c')

  if imSoClever ~= '' and math.random() < chanceToMouthOff then
    setNextAttack = setNextAttack ..' / '.. imSoClever
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

Alchemist.resetHumourButtonStyles = function()
  Alchemist.melancholicButton:echo('Me', 'white', 'c')
  Alchemist.cholericButton:echo('Ch', 'white', 'c')
  Alchemist.sanguineButton:echo('Sa', 'white', 'c')
  Alchemist.phlegmaticButton:echo('Ph', 'white', 'c')
end

Alchemist.setHumour = function(humour, reason)
  local elem = tostring(humour):lower()

  if elem == 'melancholic' then
    button = Alchemist.melancholicButton
  elseif elem == 'choleric' then
    button = Alchemist.cholericButton
  elseif elem == 'sanguine' then
    button = Alchemist.sanguineButton
  elseif elem == 'phlegmatic' then
    button = Alchemist.phlegmaticButton
  else
    cecho('\n<red>Unknown humour: '.. elem ..' (ignored)\n')
  end

  Alchemist.humour = elem
  Alchemist.resetHumourButtonStyles()
  button:echo(string.title(string.sub(elem, 1, 2)), Megophrys.fgColors[Megophrys.killStrat], 'c')

  if reason then
    cecho('\n<cyan>Humour set to: '.. Alchemist.humour ..' ('.. reason ..')\n')
  else
    cecho('\n<cyan>Humour set to: '.. Alchemist.humour ..'\n')
  end
end

Megophrys.Alchemist.setMode = function()
  local Alchemist = Megophrys.Alchemist
  local killStrat = Megophrys.killStrat

  Alchemist.resetHumourButtonStyles()

  if killStrat == 'denizen' then
    Megophrys.nextMoveButton:echo('Educe Iron', Megophrys.fgColors[killStrat], 'c')
  elseif killStrat == 'los' then
    Megophrys.nextMoveButton:echo('Nocturne', Megophrys.fgColors[killStrat], 'c')
  else
    Megophrys.Alchemist.setHumour('sanguine')
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

Megophrys.Alchemist.subMode = function(n)
  if n == 1 then
    Alchemist.setElement('melancholic')
  elseif n == 2 then
    Alchemist.setElement('choleric')
  elseif n == 3 then
    Alchemist.setElement('sanguine')
  elseif n == 4 then
    Alchemist.setElement('phlegmatic')
  else
    error('Bad sub mode: '.. n ..'!')
  end
end

Megophrys.Alchemist.toggleOne = function(altMode)
  if Alchemist.overdraw then
    Alchemist.overdraw = false
    cecho('\n<cyan>No longer overdrawing.\n')
  else
    Alchemist.overdraw = true
    cecho('\n<cyan>Overdrawing enabled!\n')
  end
end
