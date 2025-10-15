local Terminus = {}

function Terminus.clamp(x, min, max)
	return math.min(math.max(x, min), max)
end

function Terminus.fixColor(color)
	local r, g, b =  Terminus.clamp(math.floor(color[1] + 0.5), 0, 255),
					 Terminus.clamp(math.floor(color[2]), 0, 255),
					 Terminus.clamp(math.floor(color[3]), 0, 255)

	return {r, g, b}
end

function Terminus.rgbToStandard(oColor)
	local color = Terminus.fixColor(oColor)
	local r, g, b =  Terminus.clamp(color[1], 0, 255), Terminus.clamp(color[2], 0, 255), Terminus.clamp(color[3], 0, 255)
	local nr, ng, nb = math.floor(r/51 + 0.5), math.floor(g/51 + 0.5), math.floor(b/51 + 0.5)

	return 16 + 36*nr + 6*ng + nb
end


function Terminus.fgColor(color, mode)
	local s = '\x1b[38;'
	local r, g, b = color[1], color[2], color[3]

	if mode == 'Standard' then
		s = s .. '5;' .. tostring(Terminus.rgbToStandard(color))
	end

	if mode == 'TrueColor' then
		s = s .. '2;' .. tostring(r) .. ';' .. tostring(g) .. ';' .. tostring(b)
	end

	return s .. 'm'
end

function Terminus.bgColor(color, mode)
	local s = '\x1b[48;'
	local r, g, b = color[1], color[2], color[3]

	if mode == 'Standard' then
		s = s .. '5;' .. tostring(Terminus.rgbToStandard(color))
	end

	if mode == 'TrueColor' then
		s = s .. '2;' .. tostring(r) .. ';' .. tostring(g) .. ';' .. tostring(b)
	end

	return s .. 'm'
end

function Terminus.reset()
	return '\x1b[0m'
end

function Terminus.hideCursor()
	print('\x1b[?25l')
end


Terminus.BaseChar = '▄'

---@alias pixel {[1]: integer[], [2]: string}

---@class Screen
---@field width integer
---@field height integer
---@field pixels pixel[][]
---@field mode 'Standard'|'TrueColor'
Terminus.Screen = {}
Terminus.Screen.__index = Terminus.Screen

function Terminus.Screen:new(width, height, mode, baseChar)
	local pixels = {}
	for x = 1, width do
		pixels[x] = {}
		for y = 1, height do
			pixels[x][y] = {{0, 0, 0}, baseChar or Terminus.BaseChar}
		end
	end
	return setmetatable({width = width, height = height, pixels = pixels, mode = mode or 'Standard'}, self)
end

function Terminus.Screen:isInBounds(x, y)
	return (x >= 1) and (y >= 1) and (x <= self.width) and (y <= self.height)
end

function Terminus.Screen:setPixel(x, y, r, g, b, char)
	if self:isInBounds(x, y) then
		self.pixels[x][y] = {Terminus.fixColor({r, g, b}), char or self.pixels[x][y][2]}
	end
end

function Terminus.Screen:Clear(color, char)
	for x = 1, self.width do
		for y = 1, self.height do
			self:setPixel(x, y, color, char or Terminus.BaseChar)
		end
	end
end

function Terminus.Screen:toPrintTable()
	local t = {}

	for x = 1, self.width do
		t[x] = {}
		for y = 1, self.height do
			local idx = math.ceil(y/2)

			if t[x][idx] then
				t[x][idx][2] = self.pixels[x][y][1]
			else
				t[x][idx] = {self.pixels[x][y][1]}
				t[x][idx][3] = self.pixels[x][y][2]
			end
		end
	end

	return t
end

function Terminus.Screen:Print()
	local pTable = self:toPrintTable()
	local pixel

	local outTable = {}

	for y = 1, math.ceil(self.height/2) do
		for x = 1, self.width do
			pixel = pTable[x][y]
			outTable[#outTable+1] = Terminus.bgColor(pixel[1], self.mode)
			outTable[#outTable+1] = Terminus.fgColor(pixel[2], self.mode)
			outTable[#outTable+1] = pixel[3]
		end
		outTable[#outTable+1] = Terminus.reset() .. '\n'
	end

	io.write(table.concat(outTable))
end

return Terminus