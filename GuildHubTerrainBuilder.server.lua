-- Stylized Roblox guild hub generator based on the provided concept image.
-- Drop this script into ServerScriptService, run the place in Studio once,
-- then keep editing the generated map in Workspace.GeneratedGuildHub.

local Workspace = game:GetService("Workspace")
local Terrain = Workspace.Terrain

local GENERATED_MODEL_NAME = "GeneratedGuildHub"
local MAP_CLEAR_SIZE = Vector3.new(1500, 500, 1500)
local RANDOM_SEED = 481516

local rng = Random.new(RANDOM_SEED)

local colors = {
	Stone = Color3.fromRGB(197, 185, 162),
	WarmStone = Color3.fromRGB(214, 204, 176),
	Path = Color3.fromRGB(202, 186, 146),
	Wood = Color3.fromRGB(118, 81, 45),
	DarkWood = Color3.fromRGB(74, 52, 33),
	Canvas = Color3.fromRGB(231, 220, 184),
	BlueRoof = Color3.fromRGB(54, 94, 163),
	RedRoof = Color3.fromRGB(173, 77, 50),
	OrangeRoof = Color3.fromRGB(194, 126, 56),
	Gold = Color3.fromRGB(210, 170, 72),
	LeafDark = Color3.fromRGB(52, 100, 57),
	LeafMid = Color3.fromRGB(80, 123, 61),
	LeafLight = Color3.fromRGB(127, 155, 70),
	Rock = Color3.fromRGB(118, 118, 118),
	Water = Color3.fromRGB(74, 160, 212),
	Crystal = Color3.fromRGB(93, 190, 255),
	Shadow = Color3.fromRGB(70, 65, 60),
	Plot = Color3.fromRGB(116, 100, 106),
}

local districtCenters = {
	Fountain = Vector3.new(0, 0, 0),
	SpawnPlaza = Vector3.new(0, 0, -92),
	CentralGuildHall = Vector3.new(0, 0, 156),
	BuilderGuild = Vector3.new(-238, 0, -92),
	AnimatorGuild = Vector3.new(238, 0, -86),
	ArtistGuild = Vector3.new(-332, 0, 135),
	MusicianGuild = Vector3.new(318, 0, 165),
	Marketplace = Vector3.new(-246, 0, 320),
	VFXArea = Vector3.new(238, 0, 322),
	FutureSouth = Vector3.new(-20, 0, 344),
	FutureNorth = Vector3.new(0, 0, -326),
}

local exclusionZones = {
	{ center = districtCenters.Fountain, radius = 105 },
	{ center = districtCenters.SpawnPlaza, radius = 92 },
	{ center = districtCenters.CentralGuildHall, radius = 100 },
	{ center = districtCenters.BuilderGuild, radius = 88 },
	{ center = districtCenters.AnimatorGuild, radius = 88 },
	{ center = districtCenters.ArtistGuild, radius = 88 },
	{ center = districtCenters.MusicianGuild, radius = 88 },
	{ center = districtCenters.Marketplace, radius = 90 },
	{ center = districtCenters.VFXArea, radius = 90 },
	{ center = districtCenters.FutureSouth, radius = 110 },
	{ center = districtCenters.FutureNorth, radius = 120 },
}

local rootModel = Workspace:FindFirstChild(GENERATED_MODEL_NAME)
if rootModel then
	rootModel:Destroy()
end

Terrain:FillBlock(CFrame.new(0, 110, 0), MAP_CLEAR_SIZE, Enum.Material.Air)

rootModel = Instance.new("Model")
rootModel.Name = GENERATED_MODEL_NAME
rootModel.Parent = Workspace

local folders = {}
for _, name in ipairs({ "TerrainHelpers", "Paths", "Structures", "Props", "Labels", "Nature" }) do
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = rootModel
	folders[name] = folder
end

Terrain.WaterColor = colors.Water
Terrain.WaterReflectance = 0.12
Terrain.WaterTransparency = 0.2
Terrain.WaterWaveSize = 0.2
Terrain.WaterWaveSpeed = 12

local function newPart(parent, name, size, cframe, color, material, className)
	local part
	if className == "SpawnLocation" then
		part = Instance.new("SpawnLocation")
		part.Neutral = true
		part.AllowTeamChangeOnTouch = false
	else
		part = Instance.new(className or "Part")
	end

	part.Name = name
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.Parent = parent

	return part
end

local function newBall(parent, name, diameter, position, color, material)
	local ball = newPart(parent, name, Vector3.new(diameter, diameter, diameter), CFrame.new(position), color, material)
	ball.Shape = Enum.PartType.Ball
	return ball
end

local function invisibleAnchor(parent, name, position)
	local anchor = newPart(parent, name, Vector3.new(1, 1, 1), CFrame.new(position), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic)
	anchor.Transparency = 1
	anchor.CanCollide = false
	return anchor
end

local function addLabel(parent, headline, subtitle, position)
	local anchor = invisibleAnchor(parent, headline:gsub("%s+", "") .. "Label", position)
	local gui = Instance.new("BillboardGui")
	gui.Name = "LabelGui"
	gui.Size = UDim2.fromOffset(300, 110)
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.StudsOffsetWorldSpace = Vector3.new(0, 22, 0)
	gui.Parent = anchor

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = colors.Canvas
	frame.BackgroundTransparency = 0.06
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = colors.Wood
	stroke.Thickness = 3
	stroke.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -24, 0.6, 0)
	title.Position = UDim2.new(0, 12, 0, 6)
	title.BackgroundTransparency = 1
	title.Text = headline
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.TextColor3 = colors.DarkWood
	title.Parent = frame

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(1, -24, 0.34, 0)
	sub.Position = UDim2.new(0, 12, 0.6, -4)
	sub.BackgroundTransparency = 1
	sub.Text = subtitle
	sub.TextScaled = true
	sub.Font = Enum.Font.GothamSemibold
	sub.TextColor3 = colors.Wood
	sub.Parent = frame

	return anchor
end

local function addPointLight(parent, color, brightness, range)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = brightness
	light.Range = range
	light.Parent = parent
	return light
end

local function addStonePad(parent, name, center, size, color)
	return newPart(parent, name, size, CFrame.new(center + Vector3.new(0, size.Y * 0.5, 0)), color or colors.Stone, Enum.Material.Slate)
end

local function addPathSegment(parent, startPos, endPos, width)
	local delta = endPos - startPos
	local length = delta.Magnitude
	local mid = (startPos + endPos) * 0.5 + Vector3.new(0, 0.45, 0)
	local part = newPart(parent, "PathSegment", Vector3.new(width, 1, length + 4), CFrame.lookAt(mid, endPos), colors.Path, Enum.Material.Slate)
	part.CanCollide = true
	return part
end

local function addPath(parent, points, width)
	for index = 1, #points - 1 do
		addPathSegment(parent, points[index], points[index + 1], width)
	end
end

local function addTerrainStrip(points, width, height, material, yOffset)
	for index = 1, #points - 1 do
		local startPos = points[index] + Vector3.new(0, yOffset, 0)
		local endPos = points[index + 1] + Vector3.new(0, yOffset, 0)
		local delta = endPos - startPos
		local length = delta.Magnitude
		local mid = (startPos + endPos) * 0.5
		Terrain:FillBlock(CFrame.lookAt(mid, endPos), Vector3.new(width, height, length + width), material)
	end
end

local function scatterCrates(parent, center, count, spread)
	for _ = 1, count do
		local sizeX = rng:NextInteger(5, 9)
		local sizeY = rng:NextInteger(4, 7)
		local sizeZ = rng:NextInteger(5, 9)
		local offset = Vector3.new(rng:NextNumber(-spread, spread), sizeY * 0.5, rng:NextNumber(-spread, spread))
		local part = newPart(parent, "Crate", Vector3.new(sizeX, sizeY, sizeZ), CFrame.new(center + offset) * CFrame.Angles(0, math.rad(rng:NextInteger(0, 180)), 0), colors.Wood, Enum.Material.WoodPlanks)
		part.Color = rng:NextNumber() > 0.6 and colors.DarkWood or colors.Wood
	end
end

local function scatterRocks(parent, center, count, spread)
	for _ = 1, count do
		local size = Vector3.new(rng:NextInteger(7, 18), rng:NextInteger(5, 14), rng:NextInteger(8, 20))
		local offset = Vector3.new(rng:NextNumber(-spread, spread), size.Y * 0.5, rng:NextNumber(-spread, spread))
		newPart(parent, "Rock", size, CFrame.new(center + offset) * CFrame.Angles(math.rad(rng:NextInteger(-15, 20)), math.rad(rng:NextInteger(0, 180)), math.rad(rng:NextInteger(-20, 20))), colors.Rock, Enum.Material.Rock)
	end
end

local function addTree(parent, position, scale, broadleaf)
	local trunkHeight = 9 * scale
	newPart(parent, "Trunk", Vector3.new(2.2 * scale, trunkHeight, 2.2 * scale), CFrame.new(position + Vector3.new(0, trunkHeight * 0.5, 0)), colors.DarkWood, Enum.Material.Wood)

	if broadleaf then
		newBall(parent, "Canopy", 11 * scale, position + Vector3.new(-2 * scale, trunkHeight + 1, -1 * scale), colors.LeafMid, Enum.Material.Grass)
		newBall(parent, "Canopy", 12 * scale, position + Vector3.new(2 * scale, trunkHeight + 2, 1 * scale), colors.LeafLight, Enum.Material.Grass)
		newBall(parent, "Canopy", 10 * scale, position + Vector3.new(0, trunkHeight + 5, 0), colors.LeafDark, Enum.Material.Grass)
	else
		newBall(parent, "Needles", 11 * scale, position + Vector3.new(0, trunkHeight + 1, 0), colors.LeafDark, Enum.Material.Grass)
		newBall(parent, "Needles", 9 * scale, position + Vector3.new(0, trunkHeight + 5, 0), colors.LeafMid, Enum.Material.Grass)
		newBall(parent, "Needles", 7 * scale, position + Vector3.new(0, trunkHeight + 9, 0), colors.LeafLight, Enum.Material.Grass)
	end
end

local function insideExclusion(pos)
	local flat = Vector3.new(pos.X, 0, pos.Z)
	for _, zone in ipairs(exclusionZones) do
		local centerFlat = Vector3.new(zone.center.X, 0, zone.center.Z)
		if (flat - centerFlat).Magnitude < zone.radius then
			return true
		end
	end
	return false
end

local function scatterForest(count, minRadius, maxRadius)
	local placed = 0
	local attempts = 0
	while placed < count and attempts < count * 12 do
		attempts += 1
		local angle = rng:NextNumber(0, math.pi * 2)
		local radius = rng:NextNumber(minRadius, maxRadius)
		local pos = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		if not insideExclusion(pos) then
			addTree(folders.Nature, pos, rng:NextNumber(0.85, 1.3), rng:NextNumber() > 0.55)
			placed += 1
		end
	end
end

local function scatterCluster(center, radius, count, mostlyBroadleaf)
	for _ = 1, count do
		local angle = rng:NextNumber(0, math.pi * 2)
		local dist = rng:NextNumber(0, radius)
		local pos = center + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
		if not insideExclusion(pos) then
			local broadleaf = mostlyBroadleaf and rng:NextNumber() > 0.3 or rng:NextNumber() > 0.7
			addTree(folders.Nature, pos, rng:NextNumber(0.8, 1.15), broadleaf)
		end
	end
end

local function addBanner(parent, center, color)
	local pole = newPart(parent, "BannerPole", Vector3.new(0.7, 10, 0.7), CFrame.new(center + Vector3.new(0, 5, 0)), colors.DarkWood, Enum.Material.Wood)
	local cloth = newPart(parent, "Banner", Vector3.new(0.3, 6, 4), CFrame.new(center + Vector3.new(1.1, 7, 0)), color, Enum.Material.Fabric)
	cloth.CanCollide = false
	return pole, cloth
end

local function addEasel(parent, position)
	newPart(parent, "EaselLeg", Vector3.new(0.6, 7, 0.6), CFrame.new(position + Vector3.new(-1.4, 3.5, 0)) * CFrame.Angles(math.rad(8), 0, math.rad(8)), colors.Wood, Enum.Material.Wood)
	newPart(parent, "EaselLeg", Vector3.new(0.6, 7, 0.6), CFrame.new(position + Vector3.new(1.4, 3.5, 0)) * CFrame.Angles(math.rad(8), 0, math.rad(-8)), colors.Wood, Enum.Material.Wood)
	newPart(parent, "Canvas", Vector3.new(5.5, 5.5, 0.3), CFrame.new(position + Vector3.new(0, 5.5, -0.4)), colors.Canvas, Enum.Material.Fabric)
	local paint = newPart(parent, "PaintStroke", Vector3.new(3.6, 1.2, 0.1), CFrame.new(position + Vector3.new(0.2, 5.7, -0.55)) * CFrame.Angles(0, 0, math.rad(15)), colors.OrangeRoof, Enum.Material.Neon)
	paint.Transparency = 0.2
	paint.CanCollide = false
end

local function addSimpleBuilding(parent, name, center, footprint, height, wallColor, roofColor)
	local model = Instance.new("Model")
	model.Name = name
	model.Parent = parent

	addStonePad(model, "Floor", center, Vector3.new(footprint.X + 6, 1.2, footprint.Z + 6), colors.Stone)
	newPart(model, "Body", Vector3.new(footprint.X, height, footprint.Z), CFrame.new(center + Vector3.new(0, height * 0.5 + 1.2, 0)), wallColor, Enum.Material.Plaster)
	newPart(model, "Roof", Vector3.new(footprint.X + 8, 2.4, footprint.Z + 8), CFrame.new(center + Vector3.new(0, height + 3, 0)), roofColor, Enum.Material.WoodPlanks)
	newPart(model, "Door", Vector3.new(5, 9, 1.1), CFrame.new(center + Vector3.new(0, 5.4, -footprint.Z * 0.5 - 0.1)), colors.DarkWood, Enum.Material.WoodPlanks)

	return model
end

local function addWorkshopDistrict(center)
	local model = Instance.new("Model")
	model.Name = "BuilderGuild"
	model.Parent = folders.Structures

	addStonePad(model, "Yard", center, Vector3.new(96, 1, 74), colors.Path)
	addSimpleBuilding(model, "MainWorkshop", center + Vector3.new(-18, 0, 0), Vector3.new(28, 16, 20), 16, colors.WarmStone, colors.OrangeRoof)
	addSimpleBuilding(model, "StoreRoom", center + Vector3.new(22, 0, 10), Vector3.new(18, 12, 14), 12, colors.WarmStone, colors.BlueRoof)

	newPart(model, "Workbench", Vector3.new(16, 2.4, 6), CFrame.new(center + Vector3.new(16, 1.2, -18)), colors.Wood, Enum.Material.WoodPlanks)
	newPart(model, "Workbench", Vector3.new(12, 2.4, 5), CFrame.new(center + Vector3.new(-6, 1.2, 18)), colors.Wood, Enum.Material.WoodPlanks)
	newPart(model, "BeamStack", Vector3.new(20, 4, 4), CFrame.new(center + Vector3.new(28, 2, -12)) * CFrame.Angles(0, math.rad(18), 0), colors.DarkWood, Enum.Material.WoodPlanks)
	scatterCrates(model, center + Vector3.new(18, 0, 10), 10, 26)
	addLabel(folders.Labels, "Builder Guild", "Workshop District", center + Vector3.new(0, 4, 0))
end

local function addAnimatorDistrict(center)
	local model = Instance.new("Model")
	model.Name = "AnimatorGuild"
	model.Parent = folders.Structures

	addStonePad(model, "Plaza", center, Vector3.new(94, 1, 70), colors.Path)
	addSimpleBuilding(model, "Theater", center + Vector3.new(8, 0, -6), Vector3.new(44, 18, 26), 18, colors.WarmStone, colors.RedRoof)
	local stage = addStonePad(model, "Stage", center + Vector3.new(-18, 0, 18), Vector3.new(24, 2, 18), colors.Stone)
	stage.Material = Enum.Material.WoodPlanks
	for seatIndex = 1, 4 do
		newPart(model, "Seat", Vector3.new(9, 2, 3), CFrame.new(center + Vector3.new(-30 + seatIndex * 8, 1, 30 + seatIndex * 2)), colors.Wood, Enum.Material.WoodPlanks)
	end
	newPart(model, "ArchLeft", Vector3.new(2, 12, 2), CFrame.new(center + Vector3.new(-28, 6, 18)), colors.DarkWood, Enum.Material.Wood)
	newPart(model, "ArchRight", Vector3.new(2, 12, 2), CFrame.new(center + Vector3.new(-8, 6, 18)), colors.DarkWood, Enum.Material.Wood)
	newPart(model, "ArchTop", Vector3.new(24, 2, 2), CFrame.new(center + Vector3.new(-18, 12, 18)), colors.DarkWood, Enum.Material.Wood)
	addLabel(folders.Labels, "Animator Guild", "Theater District", center + Vector3.new(0, 4, 0))
end

local function addArtistDistrict(center)
	local model = Instance.new("Model")
	model.Name = "ArtistGuild"
	model.Parent = folders.Structures

	addStonePad(model, "StudioYard", center, Vector3.new(92, 1, 72), colors.Path)
	addSimpleBuilding(model, "ArtStudio", center + Vector3.new(-12, 0, -6), Vector3.new(26, 15, 20), 15, colors.WarmStone, colors.Canvas)
	newPart(model, "Awning", Vector3.new(14, 1, 10), CFrame.new(center + Vector3.new(-12, 13, -19)) * CFrame.Angles(math.rad(-15), 0, 0), colors.BlueRoof, Enum.Material.Fabric)
	addEasel(model, center + Vector3.new(18, 0, 12))
	addEasel(model, center + Vector3.new(31, 0, 8))
	newPart(model, "PaletteTable", Vector3.new(10, 2.4, 6), CFrame.new(center + Vector3.new(8, 1.2, -20)), colors.Wood, Enum.Material.WoodPlanks)
	scatterCrates(model, center + Vector3.new(-24, 0, 18), 6, 18)
	addLabel(folders.Labels, "Artist Guild", "Art Studio", center + Vector3.new(0, 4, 0))
end

local function addMusicianDistrict(center)
	local model = Instance.new("Model")
	model.Name = "MusicianGuild"
	model.Parent = folders.Structures

	addStonePad(model, "Courtyard", center, Vector3.new(94, 1, 72), colors.Path)
	addSimpleBuilding(model, "BardTavern", center + Vector3.new(18, 0, 6), Vector3.new(34, 16, 22), 16, colors.WarmStone, colors.RedRoof)
	addStonePad(model, "Bandstand", center + Vector3.new(-26, 0, -8), Vector3.new(22, 2, 22), colors.Stone)
	newPart(model, "Canopy", Vector3.new(26, 2.2, 26), CFrame.new(center + Vector3.new(-26, 15, -8)), colors.OrangeRoof, Enum.Material.Fabric)
	for beamIndex = 0, 3 do
		local angle = math.rad(beamIndex * 90)
		local beamOffset = Vector3.new(math.cos(angle) * 8, 0, math.sin(angle) * 8)
		newPart(model, "BandstandPost", Vector3.new(1.1, 14, 1.1), CFrame.new(center + Vector3.new(-26, 7, -8) + beamOffset), colors.DarkWood, Enum.Material.Wood)
	end
	newPart(model, "Lute", Vector3.new(4, 7, 1.2), CFrame.new(center + Vector3.new(2, 3.5, 16)) * CFrame.Angles(0, 0, math.rad(20)), colors.OrangeRoof, Enum.Material.WoodPlanks)
	newPart(model, "Drum", Vector3.new(5, 4, 5), CFrame.new(center + Vector3.new(-8, 2, 17)), colors.BlueRoof, Enum.Material.WoodPlanks)
	addLabel(folders.Labels, "Musician Guild", "Bard Tavern", center + Vector3.new(0, 4, 0))
end

local function addMarketplace(center)
	local model = Instance.new("Model")
	model.Name = "Marketplace"
	model.Parent = folders.Structures

	addStonePad(model, "BazaarPad", center, Vector3.new(108, 1, 76), colors.Path)
	for stallIndex = 1, 6 do
		local row = stallIndex <= 3 and -1 or 1
		local localIndex = ((stallIndex - 1) % 3) - 1
		local stallCenter = center + Vector3.new(localIndex * 26, 0, row * 18)
		newPart(model, "StallCounter", Vector3.new(14, 4, 8), CFrame.new(stallCenter + Vector3.new(0, 2, 0)), colors.Wood, Enum.Material.WoodPlanks)
		newPart(model, "StallRoof", Vector3.new(18, 1.2, 12), CFrame.new(stallCenter + Vector3.new(0, 10, 0)) * CFrame.Angles(math.rad(-10), 0, 0), stallIndex % 2 == 0 and colors.RedRoof or colors.OrangeRoof, Enum.Material.Fabric)
		newPart(model, "StallPole", Vector3.new(0.8, 9, 0.8), CFrame.new(stallCenter + Vector3.new(-6, 4.5, -3)), colors.DarkWood, Enum.Material.Wood)
		newPart(model, "StallPole", Vector3.new(0.8, 9, 0.8), CFrame.new(stallCenter + Vector3.new(6, 4.5, -3)), colors.DarkWood, Enum.Material.Wood)
		newPart(model, "StallPole", Vector3.new(0.8, 9, 0.8), CFrame.new(stallCenter + Vector3.new(-6, 4.5, 3)), colors.DarkWood, Enum.Material.Wood)
		newPart(model, "StallPole", Vector3.new(0.8, 9, 0.8), CFrame.new(stallCenter + Vector3.new(6, 4.5, 3)), colors.DarkWood, Enum.Material.Wood)
	end
	addLabel(folders.Labels, "Marketplace", "Trade District", center + Vector3.new(0, 4, 0))
end

local function addVFXArea(center)
	local model = Instance.new("Model")
	model.Name = "VFXArea"
	model.Parent = folders.Structures

	addStonePad(model, "PlotPad", center, Vector3.new(104, 1, 72), colors.Plot)
	newPart(model, "WorkBench", Vector3.new(18, 2.5, 8), CFrame.new(center + Vector3.new(-18, 1.25, -12)), colors.Wood, Enum.Material.WoodPlanks)
	newPart(model, "WorkBench", Vector3.new(16, 2.5, 8), CFrame.new(center + Vector3.new(18, 1.25, 10)), colors.Wood, Enum.Material.WoodPlanks)
	for crystalIndex = 1, 3 do
		local crystalPos = center + Vector3.new(-20 + crystalIndex * 20, 7, 16 - crystalIndex * 6)
		local crystal = newPart(model, "Crystal", Vector3.new(3, 14, 3), CFrame.new(crystalPos) * CFrame.Angles(0, math.rad(crystalIndex * 24), math.rad(18)), colors.Crystal, Enum.Material.Neon)
		addPointLight(crystal, colors.Crystal, 1.2, 12)
	end
	addLabel(folders.Labels, "VFX & UI Area", "Prototype Zone", center + Vector3.new(0, 4, 0))
end

local function addFutureSouth(center)
	local model = Instance.new("Model")
	model.Name = "FutureExpansionSouth"
	model.Parent = folders.Structures

	newPart(model, "FuturePlotA", Vector3.new(70, 1.1, 54), CFrame.new(center + Vector3.new(-38, 0.55, 0)), colors.Plot, Enum.Material.Slate)
	newPart(model, "FuturePlotB", Vector3.new(70, 1.1, 54), CFrame.new(center + Vector3.new(38, 0.55, 0)), colors.Plot, Enum.Material.Slate)
	addLabel(folders.Labels, "Future Expansion", "VFX / UI / More Guilds", center + Vector3.new(0, 4, 0))
end

local function addFutureNorth(center)
	local model = Instance.new("Model")
	model.Name = "FutureExpansionNorth"
	model.Parent = folders.Structures

	addStonePad(model, "Plateau", center, Vector3.new(170, 1, 84), colors.Path)
	addLabel(folders.Labels, "Future Guild Expansion", "Open Build Space", center + Vector3.new(0, 4, 0))
end

local function addGuildHall(center)
	local model = Instance.new("Model")
	model.Name = "CentralGuildHall"
	model.Parent = folders.Structures

	addStonePad(model, "HallPad", center, Vector3.new(110, 1.2, 64), colors.Path)
	newPart(model, "HallBody", Vector3.new(84, 22, 34), CFrame.new(center + Vector3.new(0, 12.2, 0)), colors.WarmStone, Enum.Material.Plaster)
	newPart(model, "HallRoof", Vector3.new(92, 3, 42), CFrame.new(center + Vector3.new(0, 24.8, 0)), colors.RedRoof, Enum.Material.WoodPlanks)
	newPart(model, "Entrance", Vector3.new(12, 11, 3), CFrame.new(center + Vector3.new(0, 6.5, -18.5)), colors.DarkWood, Enum.Material.WoodPlanks)

	for columnIndex = -3, 3 do
		if columnIndex ~= 0 then
			newPart(model, "Column", Vector3.new(3, 13, 3), CFrame.new(center + Vector3.new(columnIndex * 9, 7.5, -12)), colors.Stone, Enum.Material.Marble)
		end
	end

	addBanner(model, center + Vector3.new(-24, 0, -12), colors.RedRoof)
	addBanner(model, center + Vector3.new(-8, 0, -12), colors.Gold)
	addBanner(model, center + Vector3.new(8, 0, -12), colors.BlueRoof)
	addBanner(model, center + Vector3.new(24, 0, -12), colors.OrangeRoof)
	addLabel(folders.Labels, "Central Guild Hall", "Main Operations", center + Vector3.new(0, 4, 0))
end

local function addSpawnPlaza(center)
	local model = Instance.new("Model")
	model.Name = "SpawnPlaza"
	model.Parent = folders.Structures

	addStonePad(model, "CastlePad", center, Vector3.new(96, 1.2, 62), colors.Path)
	newPart(model, "MainTower", Vector3.new(34, 24, 34), CFrame.new(center + Vector3.new(0, 13, 0)), colors.WarmStone, Enum.Material.Plaster)
	newBall(model, "Dome", 28, center + Vector3.new(0, 31, 0), colors.BlueRoof, Enum.Material.SmoothPlastic)
	for _, offset in ipairs({
		Vector3.new(-24, 0, -18),
		Vector3.new(24, 0, -18),
		Vector3.new(-24, 0, 18),
		Vector3.new(24, 0, 18),
	}) do
		newPart(model, "SideTower", Vector3.new(12, 18, 12), CFrame.new(center + offset + Vector3.new(0, 10, 0)), colors.WarmStone, Enum.Material.Plaster)
		newBall(model, "SideRoof", 10, center + offset + Vector3.new(0, 22, 0), colors.BlueRoof, Enum.Material.SmoothPlastic)
	end

	local entry = newPart(model, "SpawnDoor", Vector3.new(10, 12, 3), CFrame.new(center + Vector3.new(0, 7, -18.5)), colors.Gold, Enum.Material.Metal)
	addPointLight(entry, colors.Gold, 1.6, 18)

	local spawn = newPart(model, "SpawnLocation", Vector3.new(12, 1, 12), CFrame.new(center + Vector3.new(0, 3, 26)), colors.Water, Enum.Material.Neon, "SpawnLocation")
	spawn.Transparency = 0.4
	spawn.CanCollide = false
	addLabel(folders.Labels, "Spawn Plaza", "Arrival Court", center + Vector3.new(0, 4, 0))
end

local function addFountain(center)
	local model = Instance.new("Model")
	model.Name = "Fountain"
	model.Parent = folders.Props

	addStonePad(model, "FountainPad", center, Vector3.new(60, 1.1, 60), colors.Path)
	for segment = 0, 7 do
		local angle = math.rad(segment * 45)
		local ringPos = center + Vector3.new(math.cos(angle) * 16, 1.5, math.sin(angle) * 16)
		newPart(model, "FountainRing", Vector3.new(8, 3, 4), CFrame.new(ringPos) * CFrame.Angles(0, angle, 0), colors.Stone, Enum.Material.Marble)
	end

	newPart(model, "Pool", Vector3.new(26, 3, 26), CFrame.new(center + Vector3.new(0, 1.5, 0)), colors.Water, Enum.Material.Glass)
	local column = newPart(model, "CenterColumn", Vector3.new(6, 16, 6), CFrame.new(center + Vector3.new(0, 8, 0)), colors.Stone, Enum.Material.Marble)
	local gem = newBall(model, "TopGem", 6, center + Vector3.new(0, 18, 0), colors.Crystal, Enum.Material.Neon)
	addPointLight(gem, colors.Crystal, 2, 20)
	local spray = newPart(model, "WaterSpout", Vector3.new(2, 8, 2), CFrame.new(center + Vector3.new(0, 10, 0)), colors.Water, Enum.Material.Glass)
	spray.Transparency = 0.3
	addPointLight(column, colors.Water, 0.5, 8)
end

local function buildTerrainShell()
	Terrain:FillBlock(CFrame.new(0, -24, 0), Vector3.new(1350, 48, 1350), Enum.Material.Rock)
	Terrain:FillBlock(CFrame.new(0, -8, 0), Vector3.new(1180, 16, 1180), Enum.Material.Grass)

	for step = 1, 26 do
		local angle = (step / 26) * math.pi * 2
		local radius = rng:NextNumber(520, 620)
		local center = Vector3.new(math.cos(angle) * radius, rng:NextNumber(22, 58), math.sin(angle) * radius)
		local rockRadius = rng:NextNumber(70, 110)
		Terrain:FillBall(center, rockRadius, Enum.Material.Rock)
		Terrain:FillBall(center + Vector3.new(0, 18, 0), rockRadius * 0.72, Enum.Material.Grass)
	end

	Terrain:FillBlock(CFrame.new(446, 48, -270), Vector3.new(210, 126, 170), Enum.Material.Rock)
	Terrain:FillBlock(CFrame.new(-530, 28, 312), Vector3.new(220, 88, 180), Enum.Material.Rock)
	Terrain:FillBlock(CFrame.new(0, -4, -328), Vector3.new(216, 8, 100), Enum.Material.Grass)
	Terrain:FillBlock(CFrame.new(-20, -4, 346), Vector3.new(220, 8, 86), Enum.Material.Ground)

	Terrain:FillBlock(CFrame.new(-530, -8, 112), Vector3.new(240, 10, 186), Enum.Material.Sand)
	Terrain:FillBlock(CFrame.new(-530, -7, 112), Vector3.new(220, 10, 166), Enum.Material.Water)

	addTerrainStrip({
		Vector3.new(448, 6, -210),
		Vector3.new(376, 4, -178),
		Vector3.new(308, 4, -144),
		Vector3.new(190, 3, -132),
		Vector3.new(66, 3, -160),
		Vector3.new(-52, 2, -166),
	}, 26, 12, Enum.Material.Water, -9)

	Terrain:FillBlock(CFrame.new(442, 28, -250), Vector3.new(30, 74, 18), Enum.Material.Water)
	Terrain:FillBlock(CFrame.new(436, 76, -250), Vector3.new(56, 22, 22), Enum.Material.Water)
	Terrain:FillBlock(CFrame.new(380, -6, -182), Vector3.new(86, 8, 56), Enum.Material.Water)

	addTerrainStrip({
		Vector3.new(-466, 0, 174),
		Vector3.new(-486, 0, 246),
		Vector3.new(-518, 0, 308),
		Vector3.new(-548, 0, 378),
	}, 24, 12, Enum.Material.Water, -10)
end

local function buildPaths()
	local points = districtCenters
	addPath(folders.Paths, { points.Fountain, points.SpawnPlaza }, 22)
	addPath(folders.Paths, { points.Fountain, points.CentralGuildHall }, 24)
	addPath(folders.Paths, { points.Fountain, points.BuilderGuild }, 18)
	addPath(folders.Paths, { points.Fountain, points.AnimatorGuild }, 18)
	addPath(folders.Paths, { points.Fountain, points.ArtistGuild }, 18)
	addPath(folders.Paths, { points.Fountain, points.MusicianGuild }, 18)
	addPath(folders.Paths, { points.CentralGuildHall, points.Marketplace }, 18)
	addPath(folders.Paths, { points.CentralGuildHall, points.VFXArea }, 18)
	addPath(folders.Paths, { points.Marketplace, points.FutureSouth + Vector3.new(-38, 0, 0) }, 15)
	addPath(folders.Paths, { points.VFXArea, points.FutureSouth + Vector3.new(38, 0, 0) }, 15)
	addPath(folders.Paths, { points.BuilderGuild, points.FutureNorth }, 14)
	addPath(folders.Paths, { points.ArtistGuild, points.Marketplace }, 14)
	addPath(folders.Paths, { points.AnimatorGuild, points.MusicianGuild }, 14)
	addPath(folders.Paths, {
		Vector3.new(-560, 0, -88),
		Vector3.new(-468, 0, -112),
		Vector3.new(-398, 0, -124),
		points.BuilderGuild + Vector3.new(-32, 0, -18),
	}, 14)
	addPath(folders.Paths, {
		points.AnimatorGuild + Vector3.new(34, 0, -18),
		Vector3.new(402, 0, -136),
		Vector3.new(520, 0, -102),
	}, 14)
	addPath(folders.Paths, {
		points.MusicianGuild + Vector3.new(34, 0, 14),
		Vector3.new(432, 0, 230),
		Vector3.new(548, 0, 300),
	}, 14)
	addPath(folders.Paths, {
		Vector3.new(-330, 0, 372),
		Vector3.new(-424, 0, 430),
		Vector3.new(-540, 0, 454),
	}, 14)
end

local function buildRockEdges()
	scatterRocks(folders.Nature, Vector3.new(-540, 0, 190), 22, 100)
	scatterRocks(folders.Nature, Vector3.new(470, 0, -190), 24, 110)
	scatterRocks(folders.Nature, Vector3.new(-512, 0, 430), 18, 94)
	scatterRocks(folders.Nature, Vector3.new(500, 0, 338), 16, 90)
	scatterRocks(folders.Nature, Vector3.new(-10, 0, -390), 18, 116)
end

local function addLampPost(parent, position)
	newPart(parent, "LampPost", Vector3.new(1, 14, 1), CFrame.new(position + Vector3.new(0, 7, 0)), colors.DarkWood, Enum.Material.Wood)
	newPart(parent, "LampArm", Vector3.new(4, 0.7, 0.7), CFrame.new(position + Vector3.new(1.6, 13, 0)), colors.DarkWood, Enum.Material.Wood)
	local lantern = newPart(parent, "Lantern", Vector3.new(2.2, 2.8, 2.2), CFrame.new(position + Vector3.new(3.2, 11.4, 0)), colors.Gold, Enum.Material.Glass)
	lantern.Transparency = 0.18
	addPointLight(lantern, Color3.fromRGB(255, 228, 170), 1.8, 22)
end

local function addBench(parent, position, yaw)
	local base = CFrame.new(position) * CFrame.Angles(0, math.rad(yaw), 0)
	newPart(parent, "BenchSeat", Vector3.new(6, 0.6, 2.2), base * CFrame.new(0, 2, 0), colors.Wood, Enum.Material.WoodPlanks)
	newPart(parent, "BenchBack", Vector3.new(6, 2.4, 0.5), base * CFrame.new(0, 3.25, -0.8), colors.Wood, Enum.Material.WoodPlanks)
	for _, xOffset in ipairs({ -2.2, 2.2 }) do
		newPart(parent, "BenchLeg", Vector3.new(0.5, 2, 0.5), base * CFrame.new(xOffset, 1, -0.5), colors.DarkWood, Enum.Material.Wood)
		newPart(parent, "BenchLeg", Vector3.new(0.5, 2, 0.5), base * CFrame.new(xOffset, 1, 0.5), colors.DarkWood, Enum.Material.Wood)
	end
end

local function addShrub(parent, position, scale)
	newBall(parent, "Shrub", 5 * scale, position + Vector3.new(-1 * scale, 2.4 * scale, 0), colors.LeafMid, Enum.Material.Grass)
	newBall(parent, "Shrub", 4 * scale, position + Vector3.new(1 * scale, 2 * scale, 1 * scale), colors.LeafLight, Enum.Material.Grass)
	newBall(parent, "Shrub", 4 * scale, position + Vector3.new(0, 3 * scale, -1 * scale), colors.LeafDark, Enum.Material.Grass)
end

local function addFlowerPatch(parent, center, count, spread)
	for _ = 1, count do
		local offset = Vector3.new(rng:NextNumber(-spread, spread), 0.5, rng:NextNumber(-spread, spread))
		local flower = newBall(parent, "Flower", 0.8, center + offset, rng:NextNumber() > 0.5 and colors.RedRoof or colors.Gold, Enum.Material.Neon)
		flower.Transparency = 0.12
	end
end

local function addTownHouse(parent, name, center, footprint, height, roofColor)
	local house = addSimpleBuilding(parent, name, center, footprint, height, colors.WarmStone, roofColor)
	newPart(house, "Window", Vector3.new(3.4, 3.6, 0.4), CFrame.new(center + Vector3.new(-footprint.X * 0.22, height * 0.62 + 1.2, -footprint.Z * 0.5 - 0.45)), colors.Water, Enum.Material.Glass)
	newPart(house, "Window", Vector3.new(3.4, 3.6, 0.4), CFrame.new(center + Vector3.new(footprint.X * 0.22, height * 0.62 + 1.2, -footprint.Z * 0.5 - 0.45)), colors.Water, Enum.Material.Glass)
	newPart(house, "Chimney", Vector3.new(2.2, 8, 2.2), CFrame.new(center + Vector3.new(footprint.X * 0.25, height + 5.5, 0)), colors.Stone, Enum.Material.Brick)
	return house
end

local function addStall(parent, name, center, roofColor)
	local stall = Instance.new("Model")
	stall.Name = name
	stall.Parent = parent

	newPart(stall, "Counter", Vector3.new(12, 4, 7), CFrame.new(center + Vector3.new(0, 2, 0)), colors.Wood, Enum.Material.WoodPlanks)
	newPart(stall, "Roof", Vector3.new(16, 1.1, 11), CFrame.new(center + Vector3.new(0, 10, 0)) * CFrame.Angles(math.rad(-10), 0, 0), roofColor, Enum.Material.Fabric)
	for _, offset in ipairs({
		Vector3.new(-5, 4.5, -2.5),
		Vector3.new(5, 4.5, -2.5),
		Vector3.new(-5, 4.5, 2.5),
		Vector3.new(5, 4.5, 2.5),
	}) do
		newPart(stall, "Post", Vector3.new(0.8, 9, 0.8), CFrame.new(center + offset), colors.DarkWood, Enum.Material.Wood)
	end

	return stall
end

local function addCafeTable(parent, position)
	newPart(parent, "Table", Vector3.new(4, 0.5, 4), CFrame.new(position + Vector3.new(0, 2.8, 0)), colors.Wood, Enum.Material.WoodPlanks)
	newPart(parent, "TableStem", Vector3.new(0.7, 2.8, 0.7), CFrame.new(position + Vector3.new(0, 1.4, 0)), colors.DarkWood, Enum.Material.Wood)
	for _, offset in ipairs({
		Vector3.new(-3, 1.3, 0),
		Vector3.new(3, 1.3, 0),
		Vector3.new(0, 1.3, -3),
		Vector3.new(0, 1.3, 3),
	}) do
		newPart(parent, "Stool", Vector3.new(1.4, 0.5, 1.4), CFrame.new(position + offset), colors.OrangeRoof, Enum.Material.WoodPlanks)
	end
end

local function addDetailPass()
	local detailStructures = Instance.new("Model")
	detailStructures.Name = "DetailStructures"
	detailStructures.Parent = folders.Structures

	local detailProps = Instance.new("Model")
	detailProps.Name = "DetailProps"
	detailProps.Parent = folders.Props

	for _, lampPos in ipairs({
		Vector3.new(-32, 0, -28),
		Vector3.new(32, 0, -28),
		Vector3.new(-52, 0, 120),
		Vector3.new(52, 0, 120),
		Vector3.new(-74, 0, 24),
		Vector3.new(74, 0, 24),
	}) do
		addLampPost(detailProps, lampPos)
	end

	for _, benchData in ipairs({
		{ pos = Vector3.new(-28, 0, 22), yaw = 45 },
		{ pos = Vector3.new(28, 0, 22), yaw = -45 },
		{ pos = Vector3.new(-18, 0, 52), yaw = 15 },
		{ pos = Vector3.new(18, 0, 52), yaw = -15 },
	}) do
		addBench(detailProps, benchData.pos, benchData.yaw)
	end

	for _, shrubPos in ipairs({
		Vector3.new(-50, 0, -6),
		Vector3.new(50, 0, -6),
		Vector3.new(-48, 0, 96),
		Vector3.new(48, 0, 96),
		Vector3.new(-92, 0, 140),
		Vector3.new(92, 0, 140),
	}) do
		addShrub(detailProps, shrubPos, 1.2)
		addFlowerPatch(detailProps, shrubPos, 6, 3.5)
	end

	for stepIndex = 1, 4 do
		newPart(detailProps, "SpawnStep", Vector3.new(38 + stepIndex * 8, 1, 5), CFrame.new(districtCenters.SpawnPlaza + Vector3.new(0, 0.5, 29 + stepIndex * 4)), colors.Stone, Enum.Material.Marble)
	end

	for stepIndex = 1, 5 do
		newPart(detailProps, "HallStep", Vector3.new(44 + stepIndex * 10, 1, 5), CFrame.new(districtCenters.CentralGuildHall + Vector3.new(0, 0.5, -26 - stepIndex * 4)), colors.Stone, Enum.Material.Marble)
	end

	addTownHouse(detailStructures, "GuildHallWestWing", districtCenters.CentralGuildHall + Vector3.new(-54, 0, 8), Vector3.new(18, 13, 16), 13, colors.BlueRoof)
	addTownHouse(detailStructures, "GuildHallEastWing", districtCenters.CentralGuildHall + Vector3.new(54, 0, 8), Vector3.new(18, 13, 16), 13, colors.OrangeRoof)

	addTownHouse(detailStructures, "BuilderAnnexA", districtCenters.BuilderGuild + Vector3.new(-40, 0, -24), Vector3.new(16, 11, 14), 11, colors.BlueRoof)
	addTownHouse(detailStructures, "BuilderAnnexB", districtCenters.BuilderGuild + Vector3.new(-46, 0, 24), Vector3.new(14, 10, 12), 10, colors.OrangeRoof)
	newPart(detailProps, "BuilderCranePost", Vector3.new(2.4, 24, 2.4), CFrame.new(districtCenters.BuilderGuild + Vector3.new(32, 12, -6)), colors.DarkWood, Enum.Material.Wood)
	newPart(detailProps, "BuilderCraneArm", Vector3.new(24, 2, 2), CFrame.new(districtCenters.BuilderGuild + Vector3.new(40, 22, -6)) * CFrame.Angles(0, 0, math.rad(-8)), colors.DarkWood, Enum.Material.Wood)
	newPart(detailProps, "BuilderHook", Vector3.new(1, 8, 1), CFrame.new(districtCenters.BuilderGuild + Vector3.new(50, 16, -6)), colors.Shadow, Enum.Material.Metal)
	newPart(detailProps, "LumberStack", Vector3.new(18, 3, 5), CFrame.new(districtCenters.BuilderGuild + Vector3.new(36, 1.5, 18)) * CFrame.Angles(0, math.rad(18), 0), colors.Wood, Enum.Material.WoodPlanks)
	newPart(detailProps, "LumberStack", Vector3.new(16, 3, 4), CFrame.new(districtCenters.BuilderGuild + Vector3.new(6, 1.5, -28)) * CFrame.Angles(0, math.rad(-14), 0), colors.Wood, Enum.Material.WoodPlanks)
	scatterCrates(detailProps, districtCenters.BuilderGuild + Vector3.new(20, 0, -8), 14, 20)

	addTownHouse(detailStructures, "AnimatorBoothA", districtCenters.AnimatorGuild + Vector3.new(-36, 0, -18), Vector3.new(14, 10, 12), 10, colors.RedRoof)
	addTownHouse(detailStructures, "AnimatorBoothB", districtCenters.AnimatorGuild + Vector3.new(40, 0, 20), Vector3.new(14, 10, 12), 10, colors.OrangeRoof)
	newPart(detailProps, "RedCarpet", Vector3.new(12, 0.3, 34), CFrame.new(districtCenters.AnimatorGuild + Vector3.new(2, 0.2, 18)), colors.RedRoof, Enum.Material.Fabric)
	addBanner(detailProps, districtCenters.AnimatorGuild + Vector3.new(-22, 0, -24), colors.RedRoof)
	addBanner(detailProps, districtCenters.AnimatorGuild + Vector3.new(26, 0, -24), colors.Gold)

	addTownHouse(detailStructures, "ArtistTentHouse", districtCenters.ArtistGuild + Vector3.new(-38, 0, 18), Vector3.new(16, 10, 12), 10, colors.Canvas)
	addStall(detailStructures, "PaintStall", districtCenters.ArtistGuild + Vector3.new(26, 0, -18), colors.BlueRoof)
	addStall(detailStructures, "SketchStall", districtCenters.ArtistGuild + Vector3.new(38, 0, 22), colors.OrangeRoof)
	addEasel(detailProps, districtCenters.ArtistGuild + Vector3.new(-2, 0, 18))
	addEasel(detailProps, districtCenters.ArtistGuild + Vector3.new(12, 0, -16))
	scatterCrates(detailProps, districtCenters.ArtistGuild + Vector3.new(-22, 0, 18), 7, 14)

	addTownHouse(detailStructures, "MusicHouseA", districtCenters.MusicianGuild + Vector3.new(42, 0, 24), Vector3.new(16, 11, 14), 11, colors.OrangeRoof)
	addTownHouse(detailStructures, "MusicHouseB", districtCenters.MusicianGuild + Vector3.new(-42, 0, 18), Vector3.new(14, 10, 12), 10, colors.BlueRoof)
	addCafeTable(detailProps, districtCenters.MusicianGuild + Vector3.new(8, 0, -26))
	addCafeTable(detailProps, districtCenters.MusicianGuild + Vector3.new(30, 0, -22))
	addLampPost(detailProps, districtCenters.MusicianGuild + Vector3.new(-54, 0, -18))
	addLampPost(detailProps, districtCenters.MusicianGuild + Vector3.new(56, 0, 8))

	addTownHouse(detailStructures, "MarketHouseA", districtCenters.Marketplace + Vector3.new(-44, 0, 28), Vector3.new(18, 11, 14), 11, colors.OrangeRoof)
	addTownHouse(detailStructures, "MarketHouseB", districtCenters.Marketplace + Vector3.new(-14, 0, 32), Vector3.new(16, 10, 13), 10, colors.RedRoof)
	addTownHouse(detailStructures, "MarketHouseC", districtCenters.Marketplace + Vector3.new(18, 0, 30), Vector3.new(16, 10, 13), 10, colors.Canvas)
	addTownHouse(detailStructures, "MarketHouseD", districtCenters.Marketplace + Vector3.new(48, 0, 24), Vector3.new(18, 11, 14), 11, colors.BlueRoof)
	addStall(detailStructures, "MarketStallA", districtCenters.Marketplace + Vector3.new(-44, 0, -22), colors.RedRoof)
	addStall(detailStructures, "MarketStallB", districtCenters.Marketplace + Vector3.new(42, 0, -20), colors.OrangeRoof)

	addTownHouse(detailStructures, "VFXWorkshopA", districtCenters.VFXArea + Vector3.new(42, 0, 18), Vector3.new(16, 10, 12), 10, colors.BlueRoof)
	addTownHouse(detailStructures, "VFXWorkshopB", districtCenters.VFXArea + Vector3.new(-42, 0, 18), Vector3.new(16, 10, 12), 10, colors.RedRoof)
	addLampPost(detailProps, districtCenters.VFXArea + Vector3.new(-56, 0, -10))
	addLampPost(detailProps, districtCenters.VFXArea + Vector3.new(56, 0, 6))

	addStall(detailStructures, "FutureSupplyA", districtCenters.FutureSouth + Vector3.new(-76, 0, 0), colors.Canvas)
	addStall(detailStructures, "FutureSupplyB", districtCenters.FutureSouth + Vector3.new(76, 0, 0), colors.BlueRoof)
	scatterCrates(detailProps, districtCenters.FutureSouth + Vector3.new(-76, 0, 20), 5, 10)
	scatterCrates(detailProps, districtCenters.FutureSouth + Vector3.new(76, 0, 20), 5, 10)

	for _, rockCenter in ipairs({
		Vector3.new(-494, 0, 118),
		Vector3.new(-552, 0, 42),
		Vector3.new(-578, 0, 172),
		Vector3.new(356, 0, -184),
		Vector3.new(428, 0, -206),
		Vector3.new(472, 0, -140),
		Vector3.new(-532, 0, 330),
		Vector3.new(-560, 0, 398),
	}) do
		scatterRocks(folders.Nature, rockCenter, 8, 30)
	end

	scatterCluster(Vector3.new(-610, 0, 86), 58, 16, true)
	scatterCluster(Vector3.new(-598, 0, 210), 56, 12, true)
	scatterCluster(Vector3.new(322, 0, -188), 42, 10, false)
	scatterCluster(Vector3.new(470, 0, -104), 50, 12, false)
end

buildTerrainShell()
buildPaths()
addSpawnPlaza(districtCenters.SpawnPlaza)
addGuildHall(districtCenters.CentralGuildHall)
addWorkshopDistrict(districtCenters.BuilderGuild)
addAnimatorDistrict(districtCenters.AnimatorGuild)
addArtistDistrict(districtCenters.ArtistGuild)
addMusicianDistrict(districtCenters.MusicianGuild)
addMarketplace(districtCenters.Marketplace)
addVFXArea(districtCenters.VFXArea)
addFutureSouth(districtCenters.FutureSouth)
addFutureNorth(districtCenters.FutureNorth)
addFountain(districtCenters.Fountain)
buildRockEdges()
addDetailPass()

scatterForest(220, 360, 620)
scatterCluster(Vector3.new(-470, 0, 92), 110, 42, true)
scatterCluster(Vector3.new(420, 0, -176), 96, 30, false)
scatterCluster(Vector3.new(-78, 0, -226), 64, 20, false)
scatterCluster(Vector3.new(84, 0, 270), 60, 16, true)

addLabel(folders.Labels, "Forest Path", "To Forest Path", Vector3.new(-560, 4, -88))
addLabel(folders.Labels, "Mystic Falls", "To Mystic Falls", Vector3.new(546, 4, -102))
addLabel(folders.Labels, "Mystic Falls", "Southern Path", Vector3.new(546, 4, 304))
addLabel(folders.Labels, "Future Zones", "River Exit", Vector3.new(-542, 4, 454))
