# FolderEncoder
FolderEncoder is a robust and lightweight way to represent Roblox Folder instances into lua tables and vice versa.


## `FolderToTable()`
Encode a Folder or ValueBase into a table. Encodes all descendants of `dataFile` as long as they are Folders or ValueBases. Attributes are prefixed with `attr/`.
### Parameters
|     |     |     |
| :-- | :-- | :-- |
| **dataFile** | *Folder \| ValueBase* | Data file to be encoded |


### Code Samples
Suppose we wanted to encode the following Folder, where `ExampleDataFile` has an attribute named `Attribute` and CFrameValue has an attribute named `ColorName`

![image](https://github.com/MayorGnarwhal/FolderEncoder/assets/46070329/e42d8349-5615-4566-8c19-116171a4e2a2)


```lua
local tbl = FolderEncoder.FolderToTable(ExampleDataFile)

print(tbl)
--[[
	{
		InnerFolder = {
			BrickColorValue = {
				CFrameValue = CFrame.new(),
				__value = BrickColor.new("Medium stone grey"),
				attr/ColorName = "Grey",
			},
			ObjectValue = <Instance>,
		},
		IntValue = 100,
		StringValue = "Hello World!",
		attr_Attribute = Vector3.new(1, 2, 3),
	}
]]
```

## `TableToFolder()`
Converts a table into a folder. If a key in the table is prefixed by `attr_`, then an attribute will be set to the parent Instance. If the key `__value` is present in a table then the parent instance will be a ValueBase with that value. If a variable that isn't a table is given, a ValueBase will be created instead using [GetValueBase()](#getvaluebase)

|     |     |     |
| :-- | :-- | :-- |
| **data** | *table \| any* | Folder or variation to be encoded into a folder |
| **folderName** | *string?* | (Optional) Name of the encoded folder. Default: `Folder` |
| **folderParent** | *Instance?* | (Optional) Parent of the folder. Default: `nil` |

### Code Samples
The code below will effectively clone `ExampleDataFile` as a new folder `CopyOfDataFile` in the workspace.
```lua
local tbl = FolderEncoder.FolderToTable(ExampleDataFile)

local folder = FolderEncoder.TableToFolder(tbl, "CopyOfDataFile", workspace)
```


## `GetValueBase()`
|     |     |     |
| :-- | :-- | :-- |
| **var** | *any* | Variable to get ValueBase of |

## Code Samples
```lua
local valueBase = FolderEncoder.GetValueBase(3.14)
print(valueBase) --> <Value>
print(valueBase.Value) --> 3.14
print(valueBase:IsA("NumberValue")) --> true
```

