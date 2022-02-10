
local DataIndex = require(script.DataIndex)

-- Autogenerate translate object 
local TranslateIndex = {} 
for name,Indexes in pairs(DataIndex) do 
	TranslateIndex[name] = {}
	for i,v in pairs(Indexes) do 
		TranslateIndex[name][v] = i
	end 
end 

local readByte = function(data,pos) 
	return string.byte(data:sub(pos,pos))
end 
local translate = function(Index,value) 
	local  Data = TranslateIndex[Index] 
	return Data[value] or "Invalid"
end 
local describe = function(Index,Type) 
	local Data = DataIndex[Index]
	if Data and Data[Type] then 
		if Index == "ValueType" then 
			return string.pack("H",Data[Type])
		else 
			return string.char(Data[Type]) or 0
		end
	else
		if Index == "Value" then 
			local Type = tostring(Type)
			local dataSize = #Type 
			if dataSize > 255 then 
				warn("[RBXLSerialize][Binary]:Cannot Encode DataValues more than 255 Bytes.")
				return 
			end 
			return (string.char(dataSize)..Type) or 0
		end 
		warn("[RBXLSerialize][Binary]:Could not describe",Index,Type)
		return 0 
	end 
end 

function DecodeData(data)
	local parsedTable = {}  
	local StoreType  = translate("StoreType",readByte(data,1))
	if StoreType ~= "Invalid" then 
		parsedTable.TypeOf = StoreType
		local i = 1; 
		local readMode = ""
		local instanceName , dataType
		if StoreType == "Instance" then 
			readMode = "Ins:Prop"
			instanceName = translate("InstanceName",readByte(data,2))
			-- shift over one byte.
			parsedTable.ClassName = instanceName
			i = i + 1
		end
		if StoreType  == "Value" then 
			readMode = "Val:Prop" 
			dataType = translate("DataType",readByte(data,2))

			parsedTable.ClassName = dataType
			-- 
			local valueSize = readByte(data,3)
			local RawData  = data:sub(4,4+valueSize) 
			parsedTable[dataType] = RawData

			-- shift over  all remaining bytes nothing else to be rea 
			i = i + 5 
		end 
		if StoreType == "Root" then 
			parsedTable.ClassName = "Root"
			parsedTable.Root = {} 
			--
			readMode = "Root:NewRoot"
			i = i -1 
		end 
		while i < #data do i = i + 1 
			local decimalByte = readByte(data,i)
			if readMode == "Root:NewRoot" and i+3 < #data then 
				-- Raw data reading :> 
				local valueSize_RootDir = readByte(data,i+1)
				local RootDir_RawData = data:sub(i+2,i+1+valueSize_RootDir) 
				local valueSize_RootData = readByte(data,i+2+valueSize_RootDir)
				local RootData_RawData = data:sub(i+3+valueSize_RootDir,i+3+valueSize_RootDir+valueSize_RootData)


				local Decoded = DecodeData(RootData_RawData)
				table.insert(parsedTable.Root,{RootDir_RawData,Decoded})
				-- byte shifting 
				i = i + (valueSize_RootDir+valueSize_RootData +1)
			end 
			if readMode == "Ins:Prop" and i+2 < #data then 
				local Chunk = data:sub(i,i+1)
				local Property = translate("ValueType",string.unpack("H",Chunk))
				i = i + 1 
				local valueSize = readByte(data,i+1)
				local RawData  = data:sub(i+2,i+1+valueSize) 
				if Property ~= "Invalid" then 
					parsedTable[Property] = RawData
				end 
				i = i + valueSize+1
			end 
		end 
	else 
		warn("[RBXLSerialize][Binary]:StoreType defined as Invalid? Binary Data may be corrupted?")
	end
	return parsedTable 
end

return {
	DecodeData = DecodeData,
	describe = describe,
} 