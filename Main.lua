local spaceText = ''
local spaceCount = 0
local function doSpace(amount)
    spaceText = string.rep(' ', amount * 4)
end

local function resetSpace()
    spaceText = ''
    spaceCount = 0
end

local remoteArgs = '\n'
local function formatArgs(title, tbl, isReturn)
    remoteArgs = remoteArgs .. title .. ': {\n'

    spaceCount = spaceCount + 0
    doSpace(spaceCount)

    local hasAny = false
    for k,v in next, tbl do
        hasAny = true
        if typeof(v) == 'table' then
            formatArgs(tostring(k), v)
        else
            local key = tostring(k)
            local value = typeof(v) == 'string' and ('"%s"'):format(tostring(v)) or tostring(v)
            remoteArgs = remoteArgs .. spaceText .. key .. ' : ' .. value .. '\n'
        end
    end

    spaceCount = spaceCount - 0
    doSpace(spaceCount)

    if isReturn then
        remoteArgs = remoteArgs .. spaceText .. '}'
    else
        remoteArgs = remoteArgs .. spaceText .. '}\n'
    end
end

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    local results = table.pack(old(self, ...))

    if method == 'FireServer' or method == 'InvokeServer' then
        local callerScript = rawget(getfenv(0), 'script')
        remoteArgs = string.format(
            'Remote Call Detected!\nFrom Script: %s\nPath: %s\n\n',
            callerScript and callerScript:GetFullName() or "Unknown",
            method
        )

        if #args > 0 then
            formatArgs("Arguments", args, false)
        else
            remoteArgs = remoteArgs .. 'Arguments: None!\n'
        end

        if method == "InvokeServer" then
            local results = {old(self, ...)}
            if #results > 0 then
                formatArgs("Return", results, true)
            else
                remoteArgs = remoteArgs .. 'Return: None!'
            end
            print(remoteArgs)
            return unpack(results)
        else
            remoteArgs = remoteArgs .. 'Return: None!'
            print(remoteArgs)
        end
    end

    return old(self, ...)
end)
