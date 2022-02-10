local Compressor = require(script.Compress)
--- STUPID
local RBLXSerialize = {
	_IDENTITY = "RBLXSerialize",
	_AUTHOR = "Whim#2127",
	_VERSION = "v0.6",
	_DESCRIPTION = "A All-In-One Roblox instance and datatype serializer.",
	_LICENSE = [[
    MIT LICENSE
    Copyright (c) 2022 Theron Akubuiro
    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:
    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    ]],
	Convertors = require(script.Convertors),
	SaveCFrames = false, 
	UseBase92 = true, 
	SaveSource = true,
	Encode = function(classOrDataType, shouldCompress : bool)end,
	Decode = function(encodedString : string, isCompressed :bool)end
} 
local throw = function(...) 
	warn("["..RBLXSerialize._IDENTITY.." "..RBLXSerialize._VERSION.."]:",...)
end
local base92 =require(script.base92)
local Binary = require(script.Binary)
local API = require(script.Properties)
local apiFetched =false 
local FetchApi = function() 
	API.throw = throw  
	API.SaveCFrames = RBLXSerialize.SaveCFrames
	API.SaveSource = RBLXSerialize.SaveSource 
	if (not apiFetched) then
		apiFetched = true
		local success, returnVal = pcall(function()
			return API:Fetch()
		end)
		if ((not success) or (not returnVal)) then
			apiFetched = false
			return
		end
	end
end

RBLXSerialize.Encode = function(class,compressed : bool)
	local compressed =compressed or true
	FetchApi() 
	
 	-- Gathering!
    local typeOfClass = typeof(class)
	if  typeOfClass == "Instance" then 
		-- Turns method form Instance to Intance(s)
		if #(class:GetDescendants()) == 0  then else
			typeOfClass ..= "s"
		end
	end 
	-- find the method!
	local enocdeMethod = script.Encoders:FindFirstChild(typeOfClass) 
	if not enocdeMethod then 
		enocdeMethod =  script.Encoders:FindFirstChild("Value") 
	end 
	
	-- actuall Encode!
	local result = require(enocdeMethod)(API,class)
	if not result then 
		throw("Failure to encode "..typeOfClass)
		return true 
	end
	
	-- do stuffs if compressed but only if their is somethig! ( avoid compressing nothing)
	if compressed and result  then 
		result =  Compressor.compress(result)
	end 
	
	--- Return actual result oof biinary based on format
	if RBLXSerialize.UseBase92 then 
		-- 
		return  base92.encode(result)
	end 
	return result 
	
end

RBLXSerialize.Decode = function(encoded,compressed : bool ) 
	local compressed =compressed or true  
	FetchApi()
	
	-- Yeah, i know...
	if RBLXSerialize.UseBase92 then 
		encoded = base92.decode(encoded)
	end
	if compressed then  
		encoded =  Compressor.decompress(encoded) 
	end
	
	-- Parse the string!
	local parsed = Binary.DecodeData(encoded)
	if not parsed then 
		throw("Instnace/Datatype failed to decode correctly!")
		return 
	end
	
	-- Gather information for decoder!
	local typeOfClass = parsed.TypeOf
	local decodeMethod = script.Decoders:FindFirstChild(typeOfClass)
	if not decodeMethod then 
		decodeMethod =  script.Encoders:FindFirstChild("Value") 
	end 
	
	-- Only thing left to do is give it to the decoder!
	local result = require(decodeMethod)(API,parsed) 
	return result 
end


throw("Initilization complete! Created " .. "by ".. RBLXSerialize._AUTHOR)
 
return RBLXSerialize