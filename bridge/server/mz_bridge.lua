return function(session)
    local open, signIn, guard = session.open, session.signIn, session.guard

    local function valid(source)
        local current, active = exports.mz_sd_bridge:GetPlayer(source), session.get(source)
        if current and active and active.mzSession == current.session.id
            and active.mzCharacter == current.characterId and active.citizenid == current.citizenid then return true end
        if active then session.close(source) end
        return false
    end

    session.open = function(source, ...)
        local before = exports.mz_sd_bridge:GetPlayer(source)
        if not before then return { ok = false, error = 'no_character' } end
        local result = open(source, ...)
        local active, current = session.get(source), exports.mz_sd_bridge:GetPlayer(source)
        if result and result.ok and active and current and before.session.id == current.session.id
            and before.characterId == current.characterId and active.citizenid == current.citizenid then
            active.mzSession, active.mzCharacter = current.session.id, current.characterId
            return result
        end
        if active then session.close(source) end
        return result and not result.ok and result or { ok = false, error = 'session_changed' }
    end

    session.signIn = function(source, ...)
        if not valid(source) then return { ok = false, error = 'session_changed' } end
        return signIn(source, ...)
    end

    session.guard = function(source, ...)
        if not valid(source) then return nil, 'session_changed' end
        return guard(source, ...)
    end
end
