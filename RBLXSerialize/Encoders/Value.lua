local convertors = require(script.Parent.Parent.Convertors)
local Binary = require(script.Parent.Parent.Binary)

return function(API,value) 
	local ValueString = Binary.describe("StoreType","Value")
	local ValueType = typeof(value)
	
	
	local convertor = convertors[ ValueType ]
	if convertor  then
		local converted = convertor(true,value)
		if converted then 
			return ValueString .. Binary.describe("DataType",ValueType)..Binary.describe("Value",converted)
		else 
			return nil 
		end
	else 
		return nil 
	end
	
end