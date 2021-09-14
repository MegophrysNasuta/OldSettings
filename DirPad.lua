DirPad = Geyser.Container:new({
  name = 'DirPad', x=500, y=0, width=150, height=90
})

DirPadLabels = {
  N_Label = Geyser.Label:new({
    name = 'n', x=30, y=0, width=30, height=30,
    fgColor='black',
  }, DirPad),
  NE_Label = Geyser.Label:new({
    name = 'ne', x=60, y=0, width=30, height=30,
    fgColor='black',
  }, DirPad),
  NW_Label = Geyser.Label:new({
    name = 'nw', x=0, y=0, width=30, height=30,
    fgColor='black'
  }, DirPad),
  W_Label = Geyser.Label:new({
    name = 'w', x=0, y=30, width=30, height=30,
    fgColor='black'
  }, DirPad),
  IN_Label = Geyser.Label:new({
    name = 'in', x=30, y=30, width=30, height=30,
    fgColor='black'
  }, DirPad),
  E_Label = Geyser.Label:new({
    name = 'e', x=60, y=30, width=30, height=30,
    fgColor='black'
  }, DirPad),
  SW_Label = Geyser.Label:new({
    name = 'sw', x=0, y=60, width=30, height=30,
    fgColor='black'
  }, DirPad),
  S_Label = Geyser.Label:new({
    name = 's', x=30, y=60, width=30, height=30,
    fgColor='black'
  }, DirPad),
  SE_Label = Geyser.Label:new({
    name = 'se', x=60, y=60, width=30, height=30,
    fgColor='black'
  }, DirPad),
  U_Label = Geyser.Label:new({
    name = 'up', x=90, y=0, width=30, height=30,
    fgColor='black'
  }, DirPad),
  OUT_Label = Geyser.Label:new({
    name = 'out', x=90, y=30, width=30, height=30,
    fgColor='black'
  }, DirPad),
  D_Label = Geyser.Label:new({
    name = 'down', x=90, y=60, width=30, height=30,
    fgColor='black'
  }, DirPad)
}

HighlightDirPad = function()
  for _, dir in pairs({'n', 'ne', 'nw', 'e', 'w', 's', 'se', 'sw', 'in', 'out', 'u', 'd'}) do
    DirPadLabels[dir:upper() ..'_Label']:echo(dir:upper(), 'DimGrey', 'c')
  end
  
  for exit, _ in pairs(gmcp.Room.Info.exits) do
    DirPadLabels[exit:upper() ..'_Label']:echo(exit:upper(), 'white', 'c')
  end
end

registerAnonymousEventHandler('gmcp.Room.Info', HighlightDirPad)
DirPad:hide()
