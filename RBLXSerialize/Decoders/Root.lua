
local instanceCreator = require(script.Parent.Instance)

return function(API,Parsed)
	-- First but data 2
	local CylicSearches = {}													--[CylicFlag]
	local startInstance = instanceCreator(API,Parsed.Root[1][2],nil,CylicSearches,0x01) 
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
	for i,rootData in ipairs(Parsed.Root) do 
		if i ~= 1 then 
			local instance =  instanceCreator(API,rootData[2],startInstance,CylicSearches)
			local Parent = getRootParent(rootData[1],startInstance)
			
			if Parent then 
				instance.Parent = Parent 
			else 
				API.throw("no parent found for ",instance)
			end
		end
	end
	-- do all of the CylicSearches!
	for _,AppendedCylicSearch in ipairs(CylicSearches)  do
		if AppendedCylicSearch then 
			AppendedCylicSearch() 
		end
	end
	return startInstance
end