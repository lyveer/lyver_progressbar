
local queue = {}

local function _internalStart(message, miliseconds, cb, theme, color, width, focus)
    table.insert(queue, {
        message = message,
        callback = cb,
        focus = focus
    })

    if focus == nil or focus == true then
        SetNuiFocus(true, false)
    end

    SendNUIMessage({
        type = 'vp-open',  
        message = message, 
        mili = miliseconds 
    })
end

exports('initiate', function()
    local self = {}
    self.start = _internalStart
    return self
end)

function CancelNext()
    local cancelled = {}
    if queue[1] ~= nil then
        if queue[1].focus ~= false then
            SetNuiFocus(false, false)
        end

        SendNUIMessage({ type = 'vp-cancel' })
        cancelled = queue[1];
        table.remove(queue, 1)
    end
    return cancelled;
end

exports('CancelNext', function(cb)
    local cancelled = CancelNext()
    if cb ~= nil then
        cb(cancelled)
    end
end)

exports('CancelAll', function(cb)
    local cancelled = {}
    while queue[1] ~= nil do
        table.insert(cancelled, CancelNext())
    end
    if cb ~= nil then
        cb(cancelled)
    end
end)

RegisterNUICallback('ProgressFinished', function(args, nuicb)
    if queue[1] and queue[1].focus ~= false then
        SetNuiFocus(false, false)
    end

    if queue[1] and queue[1].callback then
        queue[1].callback()
    end

    if queue[1] then
        table.remove(queue, 1) 
    end

    nuicb('ok')
end)
