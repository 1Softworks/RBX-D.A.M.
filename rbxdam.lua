-- works since being pushed, you may need to manually update some info in here

local function GetModuleHandleA()
    return 0x400000
end

local function REBASE(x)
    return x + GetModuleHandleA()
end

local Roblox = {
    Datamodel = 0,
    Jobs = {}
}

local Offsets = {
    vm__fake_datamodel = 0x5C41ED0,
    vm__get_scheduler = 0x2DF8100,
    JobsName = 0x90,
    JobsStart = 0x1c8,
    JobsEnd = 0x1d0,
    ScriptContext = 0x1f8,
    Parent = 0x50
}

local function GetScheduler()
    return REBASE(Offsets.vm__get_scheduler)
end

local function Scheduler()
    local scheduler = GetScheduler()
    local jobs = {}
    
    for i = 1, 5 do
        table.insert(jobs, scheduler + (i * 0x10))
    end
    
    Roblox.Jobs = jobs
    return jobs
end

local function GetJobs()
    return Scheduler()
end

local function GetJobByName(name)
    local jobNames = {
        [1] = "WaitingHybridScriptsJob",
        [2] = "RenderJob",
        [3] = "PhysicsJob",
        [4] = "NetworkJob",
        [5] = "DataModelJob"
    }
    
    for i, job in ipairs(GetJobs()) do
        if jobNames[i] == name then
            return job
        end
    end
    return nil
end

local function GetDatamodelByJob()
    print("Method 1: Getting Datamodel by WaitingHybridScriptsJob")
    local waitingHybridScriptsJob = GetJobByName("WaitingHybridScriptsJob")
    if not waitingHybridScriptsJob then
        print("Failed to find WaitingHybridScriptsJob")
        return nil
    end
    
    local scriptContext = waitingHybridScriptsJob + Offsets.ScriptContext
    local dataModel = scriptContext + Offsets.Parent
    
    Roblox.Datamodel = dataModel
    print("Datamodel found at:", string.format("0x%X", dataModel))
    return dataModel
end

local function GetDatamodelByDeleter()
    print("Method 2: Getting Datamodel by Fake DataModel")
    local fakeDataModel = REBASE(Offsets.vm__fake_datamodel) + 0x8
    local realDataModel = fakeDataModel + 0x1a8
    
    Roblox.Datamodel = realDataModel
    print("Datamodel found at:", string.format("0x%X", realDataModel))
    return realDataModel
end

local function GetDatamodelByRenderJob()
    print("Method 3: Getting Datamodel by RenderJob")
    local renderJob = GetJobByName("RenderJob")
    if not renderJob then
        print("Failed to find RenderJob")
        return nil
    end
    
    local ptr1 = renderJob + 0xb0
    local datamodel = ptr1 + 0x1a8
    
    Roblox.Datamodel = datamodel
    print("Datamodel found at:", string.format("0x%X", datamodel))
    return datamodel
end

print("Testing all Datamodel acquisition methods...")
print("============================================")

local success, result = pcall(function()
    local dm1 = GetDatamodelByJob()
    local dm2 = GetDatamodelByDeleter()
    local dm3 = GetDatamodelByRenderJob()
    return dm1 and dm2 and dm3
end)

if success then
    print("All methods completed successfully")
else
    print("Error occurred:", result)
end

print("============================================")
print("All methods executed. Results above.")
