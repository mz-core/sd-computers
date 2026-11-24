local target = { system = 'mz_target' }
local zones = {}

local function options(items)
    local converted = {}
    for _, item in ipairs(items or {}) do
        converted[#converted + 1] = {
            label = item.label, icon = item.icon, distance = item.distance,
            canInteract = item.canInteract,
            action = function(entity) if item.onSelect then item.onSelect({ entity = entity }) end end
        }
    end
    return { options = converted, distance = 2.5 }
end

function target.addModel(models, items)
    exports.mz_target:AddTargetModel(type(models) == 'table' and models or { models }, options(items))
    return true
end

function target.addLocalEntity(entity, items)
    exports.mz_target:AddTargetEntity(entity, options(items))
    return true
end

function target.removeLocalEntity(entity, label)
    exports.mz_target:RemoveTargetEntity(entity, label)
    return true
end

function target.addBoxZone(data)
    local id = data.name
    zones[id] = data.options or {}
    local ok, err = exports.mz_interact:AddPoint({
        id = id, coords = data.coords, interactDistance = data.distance or 2.0,
        text = { label = (zones[id][1] or {}).label or 'Usar computador' },
        event = { type = 'client', name = 'sd-computers:mz:select', args = { id } }
    })
    if not ok then print(('[sd-computers] mz_interact: %s'):format(tostring(err))) end
    return id
end

function target.removeZone(id)
    zones[id] = nil
    return exports.mz_interact:RemovePoint(id)
end

AddEventHandler('sd-computers:mz:select', function(id)
    for _, item in ipairs(zones[id] or {}) do
        if (not item.canInteract or item.canInteract(0)) and item.onSelect then item.onSelect({}) end
    end
end)

return target
