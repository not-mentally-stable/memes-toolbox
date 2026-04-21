# TypedRemotes
TypedRemotes is a lightweight Luau module that provides strict runtime type validation for [RemoteEvent](https://create.roblox.com/docs/reference/engine/classes/RemoteEvent) and [UnreliableRemoteEvent](https://create.roblox.com/docs/reference/engine/classes/UnreliableRemoteEvent) communication in Roblox.
It acts as a protective wrapper around ``.OnServerEvent``, ensuring that all incoming arguments match expected types before executing your callback. This helps prevent common developer mistakes and mitigates simple exploit attempts without cluttering your codebase with repetitive checks.

# Installation
1. Open RobloxStudio
2. Paste the following code in the studio **commandbar** then execute
```Luau
local Http = game:GetService("HttpService")
local Selection = game:GetService("Selection")
Http.HttpEnabled = true

local Module = Instance.new("ModuleScript", Selection:Get()[1] or game:GetService("ReplicatedStorage"))
Module.Name = "TypedRemotes"
Module.Source = Http:GetAsync("https://raw.githubusercontent.com/not-mentally-stable/memes-toolbox/blob/main/TypedRemotes/TypedRemote.luau")
Selection:Set({Module})
```
3. Require it then enjoy!

# Usage
Basic Example:

```Luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TypedRemotes = require("./TypedRemotes")

local remote = ReplicatedStorage.MyRemote

TypedRemotes:Create(remote, "number", "string", function(player, numberArg, stringArg)
	print(player.Name, numberArg, stringArg)
end)
```

## How It Works
When a client fires a remote:
1. Arguments are captured
2. Each argument is validated against the expected type list
3. If any mismatch occurs, execution stops immediately
4. If all checks pass, your callback runs safely

## Example Templates

Single Argument
```Luau
TypedRemotes:Create(remote, "number", function(player, value)
	print("Received number:", value)
end)
```

Multiple Arguments (you can put as much as you want)
```Luau
TypedRemotes:Create(remote, "string", "Vector3", "boolean", function(player, name, position, isActive)
	print(name, position, isActive)
end)
```

With Instance Validation
```Luau
TypedRemotes:Create(remote, "Instance", function(player, instance)
	if instance:IsA("Part") then
		print("Valid part:", instance.Name)
	end
end)
```

> [!WARNING]
> Argument count must match or exceed expected types
> 
> invalid calls fail silently (no errors thrown)
> 
> This is not a replacement for full server-side validation, but a strong first layer
