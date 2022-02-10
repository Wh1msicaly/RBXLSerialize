local defaults = {} 
local valid = {} 

return{
	isCreatable = function(className) 
		local validD = valid[className] 
		if not validD then 
			valid[className] = pcall(function() 
				Instance.new(className)
			end)
			validD = valid[className]
		end
		return validD
	end,
	getDefaults = function(className,property) 
		local instanceDefault = defaults[className]
		if not instanceDefault then 
			defaults[className] = Instance.new(className) 
			instanceDefault = defaults[className]
		end
		return instanceDefault[property]
	end
}