-- API
-- Crazyman32
-- June 6, 2018

--[[
	
	API:Fetch()
	
	API.Classes
	API.ClassesByName
	API.Enums
	API.EnumsByName
	
	Fetch must be called before classes and enums are available.
	
--]]



local API = {}

local API_URL = "https://anaminus.github.io/rbx/json/api/latest.json"


function FetchAPI()
	local successGetAsync, data = pcall(function()
		return require(script.SuperClassDataStatic)
	end)
	if (not successGetAsync) then
		warn("Failed to fetch Roblox API: " .. tostring(data))
		return
	end
	local successParse, dataArray = pcall(function()
		return game:GetService("HttpService"):JSONDecode(data)
	end)
	if (not successParse) then
		warn("Failed to parse Roblox API: " .. tostring(dataArray))
		return
	end
	return dataArray
end


function BuildClasses(api)
	
	local ValueNameMatch = {} 
	local classes, classesByName = {}, {}

	local function ApplyTags(item)
		if (item.tags) then
			for i = 1,#item.tags do
				local tag = item.tags[i]
				if (tag:match("Security$")) then
					item.Security = tag
				elseif (tag == "readonly") then
					item.ReadOnly = true
				elseif (tag == "hidden") then
					item.Hidden = true
				elseif (tag == "notCreatable") then
					item.NotCreatable = true
				elseif (tag == "notbrowsable") then
					item.NotBrowsable = true
				end
			end
		end
	end

	-- Collect all classes:
	for i = 1,#api do
		local item = api[i]
		if (item.type == "Class") then
			classes[#classes + 1] = item
			classesByName[item.Name] = item
			item.Subclasses = {}
			item.Properties = {}
			item.Methods = {}
			item.Events = {}
			ApplyTags(item)
			for _,key in pairs{"Properties", "Methods", "Events"} do
				setmetatable(item[key], {
					__index = function(self, index)
						return item.Superclass and item.Superclass[key][index]
					end;
				})
			end
			function item:GetAllProperties(discludeSecure)
				local properties = {}
				local class = item
				while (class) do
					for propName,propInfo in pairs(class.Properties) do
						if ((not propInfo.Security) or (not discludeSecure)) then
							properties[propName] = propInfo
						end
					end
					class = class.Superclass
				end
				return properties
			end
		end
	end

	-- Reference superclasses:
	for i = 1,#classes do
		local class = classes[i]
		if (class.Superclass) then
			class.Superclass = classesByName[class.Superclass]
			table.insert(class.Superclass.Subclasses, class)
		end
	end

	-- Collect properties, methods, and events:
	for i = 1,#api do
		local item = api[i]
		if item.Name and item.ValueType then 
			local class = classesByName[item.Class]
			ValueNameMatch[item.Name..":"..class.Name] = item.ValueType
		end 
		if (item.type == "Property") then
			local class = classesByName[item.Class]
			ApplyTags(item) 
			class.Properties[item.Name] = item
		elseif (item.type == "Function") then
			local class = classesByName[item.Class]
			ApplyTags(item)
			class.Methods[item.Name] = item
		elseif (item.type == "Event") then
			local class = classesByName[item.Class]
			ApplyTags(item)
			class.Events[item.Name] = item
		end
	end

	return classes, classesByName , ValueNameMatch

end


function BuildEnums(api)

	local enums, enumsByName = {}, {}

	-- Collect enums:
	for i = 1,#api do
		local item = api[i]
		if (item.type == "Enum") then
			enums[#enums + 1] = item
			enumsByName[item.Name] = item
			item.EnumItems = {}
		end
	end

	-- Collect enum items:
	for i = 1,#api do
		local item = api[i]
		if (item.type == "EnumItem") then
			local enum = enumsByName[item.Enum]
			table.insert(enum.EnumItems, item)
		end
	end

	return enums, enumsByName

end


function API:Fetch()

	if (self._fetched) then
		warn("API already fetched")
		return
	end

	if (self._fetching) then
		warn("API is already in the process of being fetched")
		return
	end

	self._fetching = true
	local api = FetchAPI()
	self._fetching = nil
	if (not api) then return end

	API.Classes, API.ClassesByName , API.ValueTypeMatch = BuildClasses(api)
	API.Enums, API.EnumsByName = BuildEnums(api)

	self._fetched = true

	return true

end


return API