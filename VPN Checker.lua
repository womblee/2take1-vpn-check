-- Bool
local enable_vpn_check = true

-- Util
local function dec_to_ipv4(ip)
    if ip then
        return string.format("%i.%i.%i.%i", ip >> 24 & 255, ip >> 16 & 255, ip >> 8 & 255, ip & 255)
    end
end

-- Main
local function check_vpn(pid)
    if not enable_vpn_check then return end
    system.wait(1000)
    local paramType = type(pid)
    if paramType == "table" or paramType == "userdata" then
        pid = pid.player
    end
    local ip = player.get_player_ip(pid)
    local response, my_info = web.get("http://ip-api.com/json/" .. dec_to_ipv4(ip) .. "?fields=131072")
    if response == 200 then
        if string.find(my_info, "true") then
            menu.notify(player.get_player_name(pid) .. " was flagged for using a VPN", "VPN Checker")
        end
    else
        print("Error.")
    end
end

-- Option
local vpnFeat = menu.add_feature("Disable VPN Check", "toggle", 0, function(f)
    if f.on then
        enable_vpn_check = not enable_vpn_check
    else
        check_vpn(pid)
    end
end)

-- Event
local vpnListener = event.add_event_listener("player_join", check_vpn)
menu.create_thread(function()
    if network.is_session_started() then -- Does a check when you change session
        for i = 0, 31 do
            check_vpn(i)
        end
    end

    for i = 0, 31 do
        if player.is_player_valid(i) then -- Does a check for everyone in the session when loading the script
            check_vpn(i)
            system.wait(100)
        end
    end
end)