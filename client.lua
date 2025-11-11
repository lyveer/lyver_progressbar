-- Queue all progress tasks to prevent infinite loops and overlap
local queue = {}

local function _internalStart(message, miliseconds, cb, theme, color, width, focus)
    table.insert(queue, {
        message = message,
        callback = cb,
        focus = focus
    })

    -- Optional focus override. Defaults to true if nil.
    if focus == nil or focus == true then
        SetNuiFocus(true, false)
    end

    SendNUIMessage({
        type = 'vp-open',  -- Yeni JS dosyamız bunu dinleyecek
        message = message, -- Yeni JS dosyamız bunu alacak
        mili = miliseconds -- Yeni JS dosyamız bunu alacak
    })
end

-- vorp_progressbar'dan alınan export
exports('initiate', function()
    local self = {}
    self.start = _internalStart
    return self
end)

-- vorp_progressbar'dan alınan CancelNext fonksiyonu
function CancelNext()
    local cancelled = {}
    if queue[1] ~= nil then
        if queue[1].focus ~= false then
            SetNuiFocus(false, false)
        end
        -- DEĞİŞİKLİK: 'vp-cancel' mesajı gönderilir
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

-- vorp_progressbar'dan alınan CancelAll fonksiyonu
exports('CancelAll', function(cb)
    local cancelled = {}
    while queue[1] ~= nil do
        table.insert(cancelled, CancelNext())
    end
    if cb ~= nil then
        cb(cancelled)
    end
end)

-- vorp_progressbar'dan alınan NUI Callback
-- Bu, JS dosyası işini bitirdiğinde tetiklenir
RegisterNUICallback('ProgressFinished', function(args, nuicb)
    if queue[1] and queue[1].focus ~= false then
        SetNuiFocus(false, false)
    end

    if queue[1] and queue[1].callback then
        queue[1].callback()
    end

    if queue[1] then
        table.remove(queue, 1) -- Remove prog from queue
    end

    nuicb('ok')
end)

-- =================================================================
--                        TEST KOMUTU
-- =================================================================
RegisterCommand('testbar', function(source, args, raw)
    local ProgressBar = exports[GetCurrentResourceName()]:initiate()

    local message = "Testing Bar"
    local duration = 4000 -- 4 saniye = 4000 milisaniye

    local function onFinish()
        print('Lyver Progress Bar testi başarıyla tamamlandı.')
    end
    ProgressBar.start(message, duration, onFinish)
end, false)
