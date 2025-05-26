--[[ 
    This is SimpleDataStore by CrabGuy


    Automatically saves and loads player data so you don't have to deal with datastores at all.

    To use this script, put the code inside a module script, require it using a normal script in ServerScriptService and call it.

    Add a folder in ReplicatedStorage called "Data" and you can put Values or other Folders inside of it.
    The Data folder will get cloned and parented to the player and every change made to its values will save between joins.

    Values in the Data folder can have the boolean attribute "Volatile" set to true to avoid saving them (if you want to have a value inside Data which is not saved)

    The module script can have attributes to modify the behaviour:
        - DataFolderName [string] : use a custom name for the Data folder (default: "Data")
        - DataStoreKey [string] : use a custom datastore key, to change the datastore (default: "a")
        - DontSaveInStudio [boolean] : avoids saving and loading data while testing in studio, does not affect the actual servers of the game (default: False)
]]


local folder_name = script:GetAttribute("DataFolderName") or "Data"
local data_folder = script:FindFirstChild(folder_name, true) or game:GetService("ReplicatedStorage"):FindFirstChild(folder_name, true)

assert(data_folder, "Could not locate data folder, it needs to be put in ReplicatedStorage")

local datastore_key = script:GetAttribute("DataStoreKey") or "a"
local datastore = game:GetService("DataStoreService"):GetDataStore(datastore_key)

local function is_value(instance: Instance)
    return instance.ClassName:match("Value") ~= nil
end

local function is_folder(instance: Instance)
    return instance:IsA("Folder")
end

local function instance_to_table(instance: Instance)
    if is_value(instance) then

        return (instance :: NumberValue).Value

    elseif is_folder(instance) then

        local result = {}
        for name, child in pairs(instance:GetChildren()) do
            result[name] = instance_to_table(child)
        end

        return result

    else
        return error(`Invalid element of data folder: {instance:GetFullName()}`)
    end
end

local function populate_instance(instance: Instance, values: {})
    for name, child in pairs(instance:GetChildren()) do

        if is_value(child) then
        
            child.Value = (child:GetAttribute("Volatile") and child.Value) or values[name]

        elseif is_folder(child) then
    
            populate_instance(child, values[name])

        else
            error(`Invalid element of {instance:GetFullName()}: {child:GetFullName()}`)
        end
    end
end

local function save_data(player: Player)
    if script:GetAttribute("DontSaveInStudio") and game:GetService("RunService"):IsStudio() then
        return
    end

    local folder = player:FindFirstChild(folder_name)
    assert(folder, `Folder could not be located under {player:GetFullName()}`)

    if not xpcall(function()

        datastore:SetAsync(tostring(player.UserId), game:GetService("HttpService"):JSONEncode(instance_to_table(folder)))
    
    end, warn) then
        error(`Error in saving {player.Name} (id: {player.UserId}) data`)
    end
end

local function load_data(player: Player)    
	local clone = data_folder:Clone()
    clone.Parent = player

    if script:GetAttribute("DontSaveInStudio") and game:GetService("RunService"):IsStudio() then
        return
    end

    local valid, data = xpcall(function()
        return datastore:GetAsync(tostring(player.UserId))
    end, warn)

    assert(valid, `Error while loading {player.Name} (id: {player.UserId})`)

    populate_instance(clone, game:GetService("HttpService"):JSONDecode(data))
end


return function()
	game:GetService("Players").PlayerAdded:Connect(load_data)
	game:GetService("Players").PlayerRemoving:Connect(save_data)
end