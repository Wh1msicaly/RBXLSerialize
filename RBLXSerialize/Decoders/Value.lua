local convertors = require(script.Parent.Parent.Convertors)


return function(API,Parsed) 
	local ValueType = Parsed.ClassName 
	local ValueUnParsed = Parsed[ValueType] 
	
	if ValueUnParsed then 
		local convertor = convertors[ ValueType ]
		if convertor  then
			return convertor(false,ValueUnParsed)
		else 
			return nil 
		end
	else 
		return nil 
	end

end