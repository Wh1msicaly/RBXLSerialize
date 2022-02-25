# RBXLSerialize
a easy to use and really cool all-in-one Roblox Serializer

### What is this?
A cool serializer for roblox, that uses basic data structure instead of serializing a existing object structure like JSON. can describe properties in as  little as 3b. Created to fill the gap of exisiting serializers that are easy as a two method(s). And don't take a unnecessary amount of storage. 

### What can it do? 
It can serialize all the children of an instance aswell as any of the supported datatypes (without instance). It can also serialize references to instances so things like (welds, or instances with `Adornee` properties).


## Usage 

```
local RBLXSerialize = require(script.Parent.RBLXSerialize)

local BinaryString = RBLXSerialize.Encode(dataTypeOrInstance, shouldCompress) 
 
local Instance = RBLXSerialize.Decode(BinaryString,IsCompressed)
```

## Values

| Name | Description |
|--|--|
| RBXLSerialize.UseBase92 | Set to true by default, determines weather the raw binary is encoded into base92. |
| RBXLSerialize.SaveCFrames | Set to false by default, determines if CFrames are saved while encoding instances. |
| RBXLSerialize.AutoRename | Set to false by default, automatically renames instances with the same name and parent.  |

## Support
* String
* BinaryString
* Content
* ProtectedString
* UDim
* UDim2
* CFrame
* CoordianteFrame
* Boolean 
* Float
* Number
* Int
* Int16
* Int32
* Int64
* SurfaceType
* Material
* Faces
* BrickColor
* Vector3
* Vector2
* Color3
* Rect
* PhysicalProperties
* NumberRange
* Vector2int16
* Vector3int16
* ColorSequence
* ColorSequenceKeypoint
* NumberSequence 
* NumberSequenceKeypoint

## Size.

Default number type is float, unless specified as other than 'number'.
| Name | Size |
|--|--|
| Property  | 3 bytes. |
| Header | 4 bytes. |
| Bool | 1 bytes. |
**notable values*

## Limitations 

1. No value including isntancedata exceed 255bytes.
2. No backwards compatability or version/identification header.
3. Inability to differentiate instances with the same name.

## Libaries used

https://github.com/Rochet2/lualzw

.
