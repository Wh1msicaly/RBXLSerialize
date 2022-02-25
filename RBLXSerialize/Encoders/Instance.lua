local searchForParent= function(parent,child) 
	local parentFound = false 
	local parentList = {child.Parent} 
	if child.Parent == parent then 
		return parentList 
	end
	repeat 
		local cParent = parentList[#parentList].Parent
		table.insert(parentList,cParent)
		if cParent == parent then 
			return parentList
		end
	until parentList[#parentList].Parent == nil
	return parentList 
end
local generateRoot = function(parentList) 
	local root = "" 
	for i=#parentList,1,-1 do 
		if i~= #parentList then 
			root = root .. parentList[i].Name
			root = root .. string.char(28)
		end 
	end
	return root 
end
--^^CylicSearching!
local convertors = require(script.Parent.Parent.Convertors)
local allowed = require(script.Parent.Parent.Allowed )
local defaultCheck = require(script.Parent.Parent.DefaultCheck)
local Binary = require(script.Parent.Parent.Binary)
return function(API,instance,instances) 
	local canCreate = defaultCheck.isCreatable(instance.ClassName)
	if not canCreate then 
		API.throw("Uncreatable isntance detetected  : ",instance.ClassName)
		return nil 
	end
	local allowedTable = allowed[instance.ClassName]
	local InstanceString = Binary.describe("StoreType","Instance")..Binary.describe("InstanceName",instance.ClassName)
	local obj = instance 
	local class = API.ClassesByName[obj.ClassName]
	if not class then 
		API.throw("Class defintion of ",instance.ClassName," not found!")
		return  
	end
	for propName,propInfo in pairs(class:GetAllProperties(true)) do
		if ((not propInfo.ReadOnly) and (not propInfo.Hidden) and propName ~= "Parent") then
			if propInfo.ValueType and propInfo.Name then  
				if allowedTable then  
					local whitelist = allowedTable[propInfo.Name]
					if not whitelist then 
						continue
					end
				end
				local deafult = defaultCheck.getDefaults(instance.ClassName,propInfo.Name)
				if deafult == instance[propInfo.Name] then else
					if not API.SaveCFrames then 
						if propInfo.ValueType == "CFrame" or propInfo.ValueType == "CoordinateFrame" then 
							continue
						end
					end
					
					--EnumCheck! 
					local EnumData = API.EnumsByName[propInfo.ValueType]
					if EnumData then
						local EnumItemConvertor = convertors["EnumItem"] 
						if EnumItemConvertor then  
							local Encoded = EnumItemConvertor(true,API,EnumData.Name,instance[propInfo.Name])
							if Encoded then 
								InstanceString =InstanceString.. Binary.describe("ValueType",propInfo.Name)..Binary.describe("Value",Encoded)
							
								continue
							end
						end
					end
					
					if instances then 
						local SuperClassName = nil 

						if propInfo.ValueType and propInfo.ValueType:find(":") then 
							local superClass = propInfo.ValueType:match(":(.*)")
							if superClass then 
								local Class =  API.ClassesByName[superClass]
								if Class and Class.Superclass then 
									SuperClassName = Class.Superclass.Name
								end
							end
						end	

						if propInfo.ValueType == "Class:PVInstance" or SuperClassName == "Instance" or SuperClassName == "PVInstance" then  
							local referenceInstance = instance[propInfo.Name]
							if typeof(referenceInstance) == "Instance" then
								if referenceInstance:IsDescendantOf(instances) then 
									local ParentSearch = searchForParent(instances,referenceInstance) 
									local CylicRoot = generateRoot(ParentSearch)..referenceInstance.Name
									
									
									InstanceString =InstanceString.. Binary.describe("ValueType",propName)..Binary.describe("Value",CylicRoot)	
									continue
								end
							end 
						end				 
					end

					local convertor = convertors[propInfo.ValueType] 
					if convertor then 
						local encodedValue = convertor(true,instance[propInfo.Name])
						if encodedValue then 
							InstanceString =InstanceString.. Binary.describe("ValueType",propInfo.Name)..Binary.describe("Value",encodedValue)	
						end
					end
				end
			end

		end 
	end
	return InstanceString
end