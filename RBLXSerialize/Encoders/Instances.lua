local convertors = require(script.Parent.Parent.Convertors)
local allowed = require(script.Parent.Parent.Allowed )
local instanceFunc = require(script.Parent.Instance)
local Binary = require(script.Parent.Parent.Binary)
return function(API,instance) 

	if API.AutoRename then 
		local ParentNameIndex = {}
		for i,v in ipairs(instance:GetDescendants()) do 
			ParentNameIndex[v.Name] = ParentNameIndex[v.Name] or {} 
			ParentNameIndex[v.Name][v.Parent] = ParentNameIndex[v.Name][v.Parent] or -1
			ParentNameIndex[v.Name][v.Parent] = ParentNameIndex[v.Name][v.Parent]+1
			local ParentNameOccurance = ParentNameIndex[v.Name][v.Parent]
			if ParentNameOccurance > 0 then 
				v.Name = v.Name..ParentNameOccurance
			end 
		end
	end
	
	local instances = instance 
	local allowedTable = allowed[instance.ClassName]
	local RootString = Binary.describe("StoreType","Root")
	local addToRoot = function(root,instance)
		local parsed = instanceFunc(API,instance,instances)
		if parsed then 
			RootString = RootString .. Binary.describe("Value",root) ..  Binary.describe("Value",parsed)
		end
	end  
	
	addToRoot("",instance)
	
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
	for i,v in ipairs(instance:GetDescendants()) do 
		local parent = searchForParent(instance,v) 
		local root = generateRoot(parent)
		
		
		addToRoot(root,v)
	end
	
	
	return RootString
end