Megophrys.Apostate = (Megophrys.Apostate or {})
local Apostate = Megophrys.Apostate

Apostate.doSpecial = function() send('demon corrupt &tar') end

Megophrys.Apostate.makeClassToolbars = function()
  Megophrys.aposToolbar = Geyser.Container:new({
    name='apos_toolbar',
    x=270, y=0, width=270, height=60
  })

  Apostate.summonLabel = Geyser.Label:new({
    name='summon_label',
    x=0, y=0, width=100, height=20,
    message='Summon:'
  }, Megophrys.aposToolbar)
  Apostate.summonLabel:setFontSize(11)
  Apostate.summonButton = Geyser.Label:new({
    name='summon',
    x=100, y=20, width=170, height=20,
  }, Megophrys.aposToolbar)
  Apostate.summonButton:setFontSize(11)

  Apostate.nextEyesLabel = Geyser.Label:new({
    name='next_eyes_label',
    x=0, y=20, width=100, height=20,
    message='Next stare: '
  }, Megophrys.aposToolbar)
  Apostate.nextEyesLabel:setFontSize(11)
  Apostate.nextEyesButton = Geyser.Label:new({
    name='next_eyes',
    x=100, y=20, width=170, height=20,
  }, Megophrys.aposToolbar)
  Apostate.nextEyesButton:setFontSize(11)

  Apostate.setMode('denizen')
  Megophrys.updatePrepGauges()
end

Megophrys.Apostate.onConnect = function()
  sendAll(
    'unwield all',
    'remove armour',
    'put armour in pack370332'
  )
  tempTimer(3, Megophrys.Apostate.gearUp)
end

Megophrys.Apostate.gearUp = function()
  send('wield shield268649 right')
end

Megophrys.Apostate.nextAttack = function()
  local Apostate = Megophrys.Apostate
  local chanceToMouthOff = 0
  local imSoClever = ''
  local killStrat = Megophrys.killStrat
  local targetAffs = affstrack.score
  local targetHits = Megophrys.targetHits or 0
  local uiColor = Megophrys.fgColors[killStrat]

  local tarAff = affstrack.score

  local setNextAttack = 'setalias nextAttack '
  if killStrat ~= 'denizen' then
    setNextAttack = setNextAttack .. 'order fiend attack &tar / contemplate &tar / '
  end
  if not wsys.aff.stupidity then
    setNextAttack = setNextAttack .. 'stand / '
  end

  local firstAff = nil
  local secondAff = nil
  if killStrat == 'denizen' then
    setNextAttack = (setNextAttack .. 'stare &tar convulsions / '..
                                      'daegger burrow &tar / '..
                                      'decay &tar / ')
    Megophrys.nextMoveButton:echo('IDK', Megophrys.fgColors[killStrat], 'c')
  else
    local chooseAff = function(ignoreAff)
      local affPrios = {
        paralysis = 'sicken',         -- eat bloodroot
        impatience = 'impatience',    -- eat goldenseal
        asthma = 'asthma',            -- eat kelp
        manaleech = 'sicken',         -- smoke valerian
        clumsiness = 'clumsy',        -- eat kelp
        sensitivity = 'sensitivity',  -- eat kelp
        slickness = 'sicken',         -- smoke valerian, eat bloodroot
        nausea = 'vomiting',          -- eat ginseng
        anorexia = 'anorexia',        -- apply epidermal
        haemophilia = 'bleed',        -- eat ginseng
        recklessness = 'reckless',    -- eat lobelia, focus
        stupidity = 'stupid',         -- eat goldenseal
        weariness = 'weariness',      -- eat kelp
      }
      for aff, humour in pairs(affPrios) do
        if ignoreAff ~= aff and tarAff[aff] < 80 then return aff end
      end
    end

    if ak.defs.curseward then
      firstAff = 'breach'
      secondAff = ''
    else
      firstAff = chooseAff()
      secondAff = chooseAff(firstAff)
    end

    imSoClever = 'warcry'
    chanceToMouthOff = 0.1
  end

  local targetIsLocked = (
    tarAff["paralysis"] > 80 and tarAff["anorexia"] > 80 and tarAff["asthma"] > 80 and
    tarAff["slickness"] > 80 and tarAff["impatience"] > 80
  )

  if targetIsLocked then
    firstAff = 'plague'
    secondAff = 'sicken'
  end

  local targetManaPct = (ak.currentmana or 0) / (ak.maxmana or 1)
  if targetManaPct <= 0.5 then
    setNextAttack = setNextAttack ..' / demon catharsis &tar'
    imSoClever = 'Liberated! Your soul is liberated!'
    chanceToMouthOff = 0.85
  else
    table.insert(Megophrys.givingAffs, firstAff)
    if firstAff then
      if not secondAff then
        setNextAttack = setNextAttack ..' / stare &tar '.. firstAff
      else
        setNextAttack = (setNextAttack ..' / deadeyes &tar '..
                         firstAff ..' '.. secondAff)
        table.insert(Megophrys.givingAffs, secondAff)
      end
      Apostate.nextEyesButton:echo(firstAff ..' '.. secondAff, uiColor, 'c')
    end
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

Megophrys.Apostate.setMode = function()
  local Apostate = Megophrys.Apostate
  local killStrat = Megophrys.killStrat

  Apostate.resetHumourButtonStyles()

  if killStrat == 'denizen' then
    Megophrys.nextMoveButton:echo('IDK', Megophrys.fgColors[killStrat], 'c')
  else
    Megophrys.nextMoveButton:echo('Deadeyes', Megophrys.fgColors[killStrat], 'c')
  end

  Megophrys.specialMoveButton:echo(
    'Demon Corrupt',
    Megophrys.fgColors[killStrat],
    'c'
  )
end
