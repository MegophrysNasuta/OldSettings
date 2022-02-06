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
  sendAll(
    'unwield all',
    'remove armour',
    'put armour in pack370332',
    'get ringmail from pack370332'
  )
  tempTimer(0.2, Megophrys.Alchemist.gearUp)
end

Megophrys.Alchemist.gearUp = function()
  sendAll(
    'wield shield268649 right',
    'wear ringmail'
  )
end

Megophrys.Alchemist.nextAttack = function()
  local Alchemist = Megophrys.Alchemist
  local chanceToMouthOff = 0
  local imSoClever = ''
  local killStrat = Megophrys.killStrat
  local nextEduce = ''
  local nextTemper = ''
  local nextWrack = ''
  local targetAffs = affstrack.score
  local targetHits = Megophrys.targetHits or 0
  local uiColor = Megophrys.fgColors[killStrat]

  local sanguineHumour = (ak.alchemist.humour.sanguine or 0)
  local melancholicHumour = (ak.alchemist.humour.melancholic or 0)
  local cholericHumour = (ak.alchemist.humour.choleric or 0)
  local phlegmaticHumour = (ak.alchemist.humour.phlegmatic or 0)

  local preAlias = 'setalias nextAttack evaluate &tar / homunculus attack &tar / '
  if not wsysf.affs.stupidity then
    preAlias = preAlias .. 'stand / '
  end

  if killStrat == 'denizen' then
    if ak.defs.shield then
      send('queue prepend eqbal throw caustic at &tar')
    end
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
                                   (targetHealthPct <= 0.66 and cholericHumour > 2) or
                                   (targetHealthPct <= 0.72 and cholericHumour > 4)) then
        nextTemper = 'inundate &tar choleric'
        nextWrack = 'aurify &tar'
      else
        if sanguineHumour < 3 then
          Alchemist.setHumour('sanguine')
        elseif melancholicHumour < 3 then
          Alchemist.setHumour('melancholic')
        elseif cholericHumour < 2 then
          Alchemist.setHumour('choleric')
        elseif phlegmaticHumour < 2 then
          Alchemist.setHumour('phlegmatic')
        else
          Alchemist.setHumour('choleric')
        end

        local chooseAff = function(ignoreAff)
          if melancholicHumour > 0 then
            if not tarAff("stupidity") and ignoreAff ~= "stupidity" then
              return "stupidity"
            elseif not tarAff("impatience") and ignoreAff ~= "impatience" then
              return "impatience"
            elseif not tarAff("anorexia") and ignoreAff ~= "anorexia" then
              return "anorexia"
            end
          end
          if not firstAff and cholericHumour > 0 then
            if not tarAff("slickness") and ignoreAff ~= "slickness" then
              return "slickness"
            elseif not tarAff("nausea") and ignoreAff ~= "nausea" then
              return "nausea"
            end
          end
          if not firstAff and phlegmaticHumour > 0 then
            if not tarAff("asthma") and ignoreAff ~= "asthma" then
              return "asthma"
            elseif not tarAff("clumsiness") and ignoreAff ~= "clumsiness" then
              return "clumsiness"
            elseif not tarAff("weariness") and ignoreAff ~= "weariness" then
              return "weariness"
            end
          end
          if not firstAff and not tarAff("recklessness") and ignoreAff ~= "recklessness" then
            return "recklessness"
          else
            return "haemophilia"
          end
        end

        local firstAff = ''
        local secondAff = ''
        if sanguineHumour > 2 and not tarAff("paralysis") then
          firstAff = "paralysis"
        else
          firstAff = chooseAff()
        end

        secondAff = chooseAff(firstAff)

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

  local targetIsLocked = (
    tarAff("paralysis") and tarAff("anorexia") and tarAff("asthma") and
    tarAff("slickness") and tarAff("impatience")
  )

  if targetIsLocked then
    sendAll('wield toxin', 'throw toxin at ground')
  else
    setNextAttack = setNextAttack .. (nextTemper or
                                      'temper &tar '.. Alchemist.humour)
    table.insert(Megophrys.givingAffs, firstAff)
    if not secondAff then
      setNextAttack = setNextAttack ..' / wrack &tar '.. firstAff
    else
      setNextAttack = (setNextAttack ..' / truewrack &tar '..
                       firstAff ..' '.. secondAff)
      table.insert(Megophrys.givingAffs, secondAff)
    end

    Alchemist.nextWrackButton:echo(firstAff ..' '.. secondAff, uiColor, 'c')

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
