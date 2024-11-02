--[[
	Easily convert folders to tables and vice versa
	Supports attributes, subfolders, and non-folder instance types
		Instance properties are not encoded except for the Value of ValueBases
]]

local FolderEncoder = {}

--// Constants
local ATTRIBUTE_PREFIX = "__attr/" -- prefix of attribute encodings
local RESERVED_DATA_KEYS = { -- keys used for encoding data. input data should not use these keys
	"__value",
	"__className",
} 


--// Helper functions
local function GetAttributeName(key)
	local attrStart, attrEnd = string.find(key, ATTRIBUTE_PREFIX)
	if attrStart == 1 then
		return string.sub(key, attrEnd + 1)
	end
end


--// Methods
function FolderEncoder.GetValueBase(var: any)
	local typeofVar = typeof(var)
	local valueBase
	
	if typeofVar == "boolean" then
		valueBase = Instance.new("BoolValue")
	elseif typeofVar == "Instance" then
		valueBase = Instance.new("ObjectValue")
	else
		valueBase = Instance.new(typeofVar:gsub("^%l", string.upper) .. "Value")
	end
	
	valueBase.Value = var
	
	return valueBase
end

function FolderEncoder.FolderToTable(dataFile: Instance): {} | any
	assert(typeof(dataFile) == "Instance", "Must provide an instance for serialization.")
	
	local data = {}
	local dataFileChildren = dataFile:GetChildren()
	
	if dataFile:IsA("ValueBase") and #dataFileChildren == 0 then
		local attributes = dataFile:GetAttributes()
		if not next(attributes) then
			return dataFile.Value
		else
			data.__value = dataFile.Value
		end
	else
		if dataFile:IsA("ValueBase") then
			data.__value = dataFile.Value
		elseif not dataFile:IsA("Folder") then
			data.__className = dataFile.ClassName
		end
		
		for i, entry in pairs(dataFileChildren) do
			local key = tonumber(entry.Name) or entry.Name
			if table.find(RESERVED_DATA_KEYS, key) then 
				error(`Reserved data key is being used ({key})`)
			elseif data[key] ~= nil then
				error(`Folder encoding has duplicate key ({key} in {entry:GetFullName()})`)
			end
			data[key] = FolderEncoder.FolderToTable(entry)
		end
	end
	
	for attribute, value in pairs(dataFile:GetAttributes()) do
		local key = ATTRIBUTE_PREFIX .. attribute
		data[key] = value
	end

	return data
end

function FolderEncoder.TableToFolder(data: {}|any, folderName: string?, folderParent: Instance?): Folder | ValueBase
	local dataFile
	
	if typeof(data) == "table" then
		if data.__value ~= nil then
			dataFile = FolderEncoder.GetValueBase(data.__value)
		else
			dataFile = Instance.new(data.__className or "Folder")
		end
		
		for key, value in pairs(data) do
			local attribute = GetAttributeName(key)
			if attribute then
				dataFile:SetAttribute(attribute, value)
			elseif not table.find(RESERVED_DATA_KEYS, key) then
				FolderEncoder.TableToFolder(value, key, dataFile)
			end
		end
	else
		dataFile = FolderEncoder.GetValueBase(data)
	end
	
	if folderName then
		dataFile.Name = folderName
	end
	
	if folderParent then
		dataFile.Parent = folderParent
	end
	
	return dataFile
end

--//
return FolderEncoder
