-- pokemon.lua
-- Version 1 "Carol"
require 'pkmn_g1_data'

memory.usememorydomain("System Bus")

game_offset = 0
yellow = false
pikachu = 0xd46f
pikachu_happy = 0

drawSpace = gui.createcanvas(32*6,32*5)
controls = forms.newform(160,144, "Pokemon Support Controls")

function cleanLog()
	console.clear()
end

function discernGame()
	gameflag = memory.read_u8(0x13c)
	if gameflag == 0x59 then
		console.log("Pokemon Yellow detected, using Yellow addresses.")
		game_offset = 1
		yellow = true
	else
		console.log("Pokemon Yellow not detected, using Red/Blue addresses.")
	end
end

discernGame()

function drawArray(array)
	width = 32
	height = 32
	row = 0
	column = 0
	drawSpace.Clear(0xff000000)
	if array[1].sprite then 
		for k, v in pairs(array) do
			console.log(v.sprite)
			if column > 5 then
				column = 0
				row = row + 1
				console.log("Row "..row..", Column", column)
			end
			--drawSpace.drawImage(v.sprite,width*column,height*row)
			column = column + 1
		end
	else
		console.log(debug.traceback())
		error("Error in drawArray - target array does not define sprites")
	end
end

function generateArray(address)
	array = { }
	i = memory.read_u8(address)
	for j=1,i do
		array[j] = getPokemonByIndex(memory.read_u8(address + j))
	end
	console.log("Array generated from address ".. address)
	return array
end

function updateParty()
	partyArray = generateArray(0xD163 - game_offset)
	console.log("Party array populated")
	
	if yellow then
		pikachu_happy = memory.read_u8(pikachu)
		console.log("Pikachu's happiness is ".. pikachu_happy)
	end
	drawArray(partyArray)
	drawSpace.SetTitle("Party Mode")
end

function updateBox()
	box_total = 0xDA80
	boxArray = generateArray(box_total - game_offset)
	box_total = memory.read_u8(box_total)
	message = "There are ".. box_total .." pokemon in the active box."
	console.log(message)
	if box_total > 17 then
		gui.addmessage(message)
	end
	drawArray(boxArray)
	drawSpace.SetTitle("Box Mode")
end

manualPartyUpdate = forms.button(controls, "Party", updateParty, 5, 5)
manualBoxUpdate = forms.button(controls, "Box", updateBox, 5, 40)
manualLogClear = forms.button(controls, "Clear Log", cleanLog, 5, 75)
console.log("Controls dialog has been assigned handle "..controls)
