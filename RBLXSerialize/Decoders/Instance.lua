local getRootParent = function(root,instance)
	local split = string.split(root,string.char(28))
	local index = instance 

	for i,v in ipairs(split) do 
		if v ~= "" then 
			local canIndex = index:FindFirstChild(v) 
			if canIndex then 
				index = canIndex 
			end
		end
	end

	return index 
end	
local IS_CYLIC_SEARCH = 0x01
--^^CylicSearching
local Binary = require(script.Parent.Parent.Binary)
local convertors = require(script.Parent.Parent.Convertors)
return function(API,Parsed,Parent,CylicTable,FLAG) 
	local instance = Instance.new(Parsed.ClassName)
	if FLAG == IS_CYLIC_SEARCH then 
		Parent = instance
	end
	for valueType,rawPropertyData in pairs(Parsed) do 
		local class 
		local classReferfence = API.ClassesByName[Parsed.ClassName]
		local propObject = classReferfence.Properties[valueType] 
		if propObject  then
			class = classReferfence.Properties[valueType].ValueType	
		end	
		if Parent then 
			if propObject then 
				if propObject.ValueType == "Class:PVInstance" or propObject.ValueType == "Class:BasePart" then 
					local CylicSearchFunction = function() 
						local InstanceReferenceSearch = getRootParent(rawPropertyData,Parent)
						if InstanceReferenceSearch then 
							instance[valueType] = InstanceReferenceSearch
						end
					end
					table.insert(CylicTable,CylicSearchFunction)
					-- get out!
					continue
				end
			end
		end
		if class and valueType ~= "ClassName" and valueType ~= "Archivable" then 
			local convertor = convertors[class]  
			if convertor then 
				local converted = convertor(false,rawPropertyData)	
				if converted then 
					local a,b= pcall(function()
						instance[valueType] = converted
					end) 
					if not a then 
						API.throw(b)
					end
				end
			end
		end
	end
	return instance
end