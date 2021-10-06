Megophrys.targetPriority = {
  anaconda = 1,
  aphid = 1,
  bass = 1,
  bat = 1,
  crocodile = 1,
  drunk = 1,
  eel = 1,
  flies = 1,
  lion = 1,
  man = 1,
  moccasin = 1,
  mistress = 1,
  muskrat = 1,
  ohmut = 1,
  owl = 1,
  oyster = 1,
  scorpion = 1,
  selkie = 1,
  squid = 1,
  stingray = 1,
  vulture = 1,
  weasel = 1,
  zombie = 1,
  blacksmith = 2,
  buckawn = 2,
  cook = 2,
  fairy = 2,
  firetender = 2,
  ghaser = 2,
  gour = 2,
  guard = 2,
  hydra = 2,
  kelpie = 2,
  lynx = 2,
  orc = 2,
  rakrr = 2,
  shark = 2,
  slugbeast = 2,
  snake = 2,
  trag = 2,
  weaponsmith = 2,
  xabat = 2,
  aldroga = 3,
  ghoul = 3,
  hobgoblin = 3,
  huntress = 3,
  mage = 3,
  noble = 3,
  ogre = 3,
  rurnog = 3,
  soldier = 3,
  warrior = 3,
  witchdoctor = 3,
  captain = 4,
  dynas = 4,
  knight = 4,
  lady = 4,
  lord = 4,
  sentry = 4,
  sergeant = 4,
  ulvna = 4,
  vampire = 4,
  vewig = 4
}

Megophrys.targetPriority["tap'choa"] = 4
Megophrys.targetPriority["log'obi"] = 4
Megophrys.targetPriority["ver'osi"] = 4

Megophrys.autoSelectHuntingTarget = function()
  if Megophrys.killStrat == 'denizen' then
    enableTrigger('Megophrys_autotarget_IH')
    Megophrys.potentialTargets = {}
    send('info here')

    tempTimer(0.5, function()
      disableTrigger('Megophrys_autotarget_IH')
      local highestPrioSeen = 0
      local finalTarget = nil
      local potentialTargets = Megophrys.potentialTargets
      local targetPriority = Megophrys.targetPriority
      for _, tgt in pairs(potentialTargets) do
        local simpleTgt = tgt:gsub('%d', '')
        if (targetPriority[simpleTgt] or 0) > highestPrioSeen then
          highestPrioSeen = targetPriority[simpleTgt]
          finalTarget = simpleTgt
        end
      end
      if finalTarget then
        Megophrys.setTarget(finalTarget)
        Megophrys.autoAttack()
      end
    end)
  end
end

Megophrys.autoSelectHuntingTargetLine = function(matches)
  if matches[2] == 'hippogriff' and matches[3] == '552688' then
    -- mount, pass
  elseif matches[2] == 'golem' then
    -- golem, pass
  else
    if (gmcp.Room.Info.area == 'the village of Qurnok' or
        gmcp.Room.Info.area == 'Forest Watch' or
        gmcp.Room.Info.area == 'the Azdun Dungeon' or
        gmcp.Room.Info.area == 'the Creville Asylum' or
        gmcp.Room.Info.area == 'the Barony of Dun Valley' or
        gmcp.Room.Info.area == 'Quartz Peak' or
        gmcp.Room.Info.area == 'the ruins of Phereklos' or
        gmcp.Room.Info.area == 'the Mhojave Desert' or
        gmcp.Room.Info.area == 'Tir Murann' or
        gmcp.Room.Info.area == 'the Peshwar Delta' or
        gmcp.Room.Info.area == 'the village of Tasur\'ke' or
        gmcp.Room.Info.area == 'the Isle of New Hope' or
        gmcp.Room.Info.area == 'Annwyn') then
      if (matches[2] ~= 'toad' and
          matches[4] ~= 'a buckawn youth' and
          matches[4] ~= 'a juvenile orc' and
          matches[4] ~= 'an adolescent ogre' and
          matches[4] ~= 'a phantom grizzly bear' and
          matches[4] ~= 'a miniature snowy owl') then
        Megophrys.potentialTargets[#Megophrys.potentialTargets + 1] = matches[2]..matches[3]
      end
    end
  end
end

