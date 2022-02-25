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
				local SuperClassName = nil 
				
				if propObject.ValueType and propObject.ValueType:find(":") then 
					local superClass = propObject.ValueType:match(":(.*)")
					if superClass then 
						local Class =  API.ClassesByName[superClass]
						if Class and Class.Superclass then 
							SuperClassName = Class.Superclass.Name
						end
					end
				end
	
				if propObject.ValueType == "Class:PVInstance" or SuperClassName == "Instance" or SuperClassName == "PVInstance" then 
					
					local CylicSearchFunction = function() 
						local InstanceReferenceSearch = getRootParent(rawPropertyData,Parent)
						if InstanceReferenceSearch then 
							instance[valueType] = InstanceReferenceSearch
						end
					end
					
					table.insert(CylicTable,CylicSearchFunction)
					continue
				end
			end
		end
		
		if propObject then
			local EnumItemConvertor = convertors["EnumItem"] 
			local EnumData = API.EnumsByName[propObject.ValueType]
			if EnumData and EnumItemConvertor then 
				local converted = EnumItemConvertor(false,API,EnumData.Name,rawPropertyData)
				if converted then 
					local Success,Result= pcall(function()
						instance[valueType] = converted
					end) 
					if not Success then 
						API.throw(Result)
					end
				end
			end
			if EnumData then 
				continue -- Cannot contuine! This is what limits backwards-compatability! Will cause unpack errors. if removed!
			end
		end 
		
		if class and valueType ~= "ClassName" and valueType ~= "Archivable" then 
			local convertor = convertors[class]  
			if convertor then 
				local converted = convertor(false,rawPropertyData)	
				if converted then 
					local Success,Result= pcall(function()
						instance[valueType] = converted
					end) 
					if not Success then 
						API.throw(Result)
					end
				end
			end
		end
	end
	return instance
end