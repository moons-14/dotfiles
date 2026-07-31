local codexbar = "@codexbarPath@"
local refreshIntervalMs = 60000
local usagePage = "https://chatgpt.com/codex/settings/usage"

local refreshing = false

local function percent(value)
    if type(value) ~= "number" then
        return "—"
    end
    return tostring(math.floor(value + 0.5)) .. "%"
end

local function oneDecimal(value)
    local tenths = math.floor(value * 10 + 0.5)
    return tostring(math.floor(tenths / 10)) .. "." .. tostring(tenths % 10)
end

local function unixSeconds(isoTime)
    if type(isoTime) ~= "string" then
        return nil
    end

    local year, month, day, hour, minute, second = string.match(
        isoTime,
        "^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)"
    )
    if year == nil then
        return nil
    end

    year = tonumber(year)
    month = tonumber(month)
    day = tonumber(day)
    hour = tonumber(hour)
    minute = tonumber(minute)
    second = tonumber(second)

    if month <= 2 then
        year = year - 1
        month = month + 12
    end

    local era = math.floor(year / 400)
    local yearOfEra = year - era * 400
    local dayOfYear = math.floor((153 * (month - 3) + 2) / 5) + day - 1
    local dayOfEra = yearOfEra * 365 + math.floor(yearOfEra / 4) - math.floor(yearOfEra / 100) + dayOfYear
    local daysSinceEpoch = era * 146097 + dayOfEra - 719468

    return daysSinceEpoch * 86400 + hour * 3600 + minute * 60 + second
end

local function resetRemaining(resetsAt, resetDescription)
    local resetSeconds = unixSeconds(resetsAt)
    if resetSeconds == nil then
        return resetDescription or "—"
    end

    local remaining = math.max(0, resetSeconds - math.floor(noctalia.nowMs() / 1000))
    local days = math.floor(remaining / 86400)
    if days > 0 then
        return tostring(days) .. "d" .. oneDecimal((remaining - days * 86400) / 3600) .. "h"
    end

    return oneDecimal(remaining / 3600) .. "h"
end

local function showError(message)
    barWidget.setGlyph("alert-circle")
    barWidget.setText("Codex: unavailable")
    barWidget.setTooltip("CodexBar: " .. message)
end

local function showUsage(item)
    local usage = item.usage or {}
    local primary = usage.primary or {}
    local secondary = usage.secondary or {}
    local primaryReset = resetRemaining(primary.resetsAt, primary.resetDescription)
    local secondaryReset = resetRemaining(secondary.resetsAt, secondary.resetDescription)

    barWidget.setGlyph("ai")
    barWidget.setText(
        "5h:"
            .. percent(primary.usedPercent)
            .. "("
            .. primaryReset
            .. ") - 7d:"
            .. percent(secondary.usedPercent)
            .. "("
            .. secondaryReset
            .. ")"
    )
    barWidget.setTooltip({
        { "5-hour usage", percent(primary.usedPercent) .. " · resets in " .. primaryReset },
        { "Weekly usage", percent(secondary.usedPercent) .. " · resets in " .. secondaryReset },
        { "Click", "Open Codex usage settings" },
    })
end

local function refresh()
    if refreshing then
        return
    end

    refreshing = true
    noctalia.runAsync(
        codexbar .. " usage --provider codex --source cli --format json",
        function(result)
            refreshing = false

            if result.exitCode ~= 0 then
                showError(result.stderr ~= "" and result.stderr or "codexbar exited " .. tostring(result.exitCode))
                return
            end

            local data, error = noctalia.json.decode(result.stdout)
            if data == nil then
                showError("invalid CodexBar JSON: " .. (error or "unknown error"))
                return
            end

            local item = data[1] or data
            if item.error ~= nil then
                showError(item.error.message or "CodexBar returned an error")
                return
            end

            showUsage(item)
        end,
        30000
    )
end

function update()
    noctalia.setUpdateInterval(refreshIntervalMs)
    refresh()
end

function onClick()
    noctalia.runAsync("xdg-open " .. usagePage)
end

function onRightClick()
    refresh()
end
