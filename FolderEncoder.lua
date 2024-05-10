local FolderEncoder = {}

--// Helper functions
local function GetAttributeName(key)
	local attrStart, attrEnd = string.find(key, "attr_")
	if attrStart == 1 then
		return string.sub(key, attrEnd)
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

function FolderEncoder.FolderToTable(dataFile: folder|ValueBase)
	assert(typeof(dataFile) == "Instance" and (dataFile:IsA("Folder") or dataFile:IsA("ValueBase")), 
		"Must provide Folder or ValueBase for serialization.")
	
	local data = {}
	
	if dataFile:IsA("ValueBase") and #dataFile:GetChildren() == 0 then
		local attributes = dataFile:GetAttributes()
		if not next(attributes) then
			return dataFile.Value
		else
			data.__value = dataFile.Value
		end
	else
		if dataFile:IsA("ValueBase") then
			data.__value = dataFile.Value
		end
		
		for i, entry in pairs(dataFile:GetChildren()) do
			local key = tonumber(entry.Name) or entry.Name
			data[key] = FolderEncoder.FolderToTable(entry)
		end
	end
	
	for attribute, value in pairs(dataFile:GetAttributes()) do
		local key = "attr_" .. attribute
		data[key] = value
	end

	return data
end

function FolderEncoder.TableToFolder(data: table|any, folderName: string?, folderParent: Instance?)
	local dataFile
	
	if typeof(data) == "table" then
		if data.__value then
			dataFile = FolderEncoder.GetValueBase(data.__value)
		else
			dataFile = Instance.new("Folder")
		end
		
		for key, value in pairs(data) do
			local attribute = GetAttributeName(key)
			if attribute then
				dataFile:SetAttribute(attribute, value)
			elseif key ~= "__value" then
				local entry = FolderEncoder.TableToFolder(value)
				entry.Name = key
				entry.Parent = dataFile
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
