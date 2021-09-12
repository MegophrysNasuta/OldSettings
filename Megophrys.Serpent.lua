Megophrys.Serpent = (Megophrys.Serpent or {})

Megophrys.Serpent.onConnect = function()
  -- pass
end

Megophrys.Serpent.setMode = function()
  local Serpent = Megophrys.Serpent
  local killStrat = Megophrys.killStrat

  Megophrys.timeUntilNextAttack = 4.33
  if killStrat == 'denizen' then
    Megophrys.nextMoveButton:echo('Garrote', Megophrys.fgColors[killStrat], 'c')
  end
end

Megophrys.Serpent.nextAttack = function()
  local Serpent = Megophrys.Serpent
  local killStrat = Megophrys.killStrat
  local setNextAttack = 'setalias nextAttack stand / wield whip / thrash &tar / '

  if killStrat == 'denizen' then
    Megophrys.nextMoveButton:echo('Garrote', Megophrys.fgColors[killStrat], 'c')
    sendAll(setNextAttack ..'garrote &tar',
            'queue addclear eqbal nextAttack')
  end

  Megophrys.autoAttackTimerId = tempTimer(Megophrys.timeUntilNextAttack,
                                          Serpent.nextAttack)
end
