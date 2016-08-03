local http = require "resty.http"
local cjson = require "cjson.safe"
local M = {}


function M.split(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

function M.startswith(String, Start)
   return string.sub(String,1,string.len(Start))==Start
end

function M.endswith(String, End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function M.member(tbl, item)
    for key, value in pairs(tbl) do
        if key == item then
            return true
        end
    end
    return false
end

function M.get_or_default(tbl, key, default)
    for k,v in pairs(tbl) do
        if key == k then
            return v
        end
    end
    return default
end

function M.get_file_content(file_name)
    local r = ""
    local file, err = io.open(file_name, "r")
    if not file then
        ngx.log(ngx.ERR, "failed to open file: ", err)
    end
    for line in file:lines() do
        line = line .. '\n'
        r = r .. line
    end
    return r
end

function M.extract_env(env)
    local result = {}
    for i,v in pairs(env) do
        local vs = M.split(v, "=")
        result[vs[1]] = vs[2]
    end
    return result
end

function M.min_port(ports)
    local port = 65536
    for k,v in pairs(ports) do
        p = tonumber(M.split(k, "/")[1])
        if p < port then
            port = p
        end
    end
    return port
end

function M.generate_container_rules(ip)
    local httpc = http.new()
    local r, err = httpc:request_uri(string.format("http://%s:2375/containers/json", ip))
    if not r then
        error("faild to get container list: " .. (err or "unknown"))
    end
    local rules = {}
    containers = cjson.decode(r.body)
    for k,v in pairs(containers) do
        container_id = v["Id"]
        local r, err = httpc:request_uri(string.format("http://%s:2375/containers/%s/json", ip, container_id))
        if not r then
            error("faild to get container info: " .. (err or "unknown"))
        end
        local container_info = cjson.decode(r.body)
        local env = M.extract_env(container_info["Config"]["Env"])
        if M.member(env, "VIRTUAL_HOST") and M.member(env, "VIRTUAL_PROTO") then
            local host = env["VIRTUAL_HOST"]
            local proto = env["VIRTUAL_PROTO"]
            local url = M.get_or_default(env, "VIRTUAL_URL", "/")
            local ip = container_info["NetworkSettings"]["IPAddress"]
            local port = M.min_port(container_info["NetworkSettings"]["Ports"])
            if not M.member(rules, host) then
                rules[host] = {proto}
                rules[host][2] = {}
                rules[host][2][url] = {{ip, port}}
            else
                if not M.member(rules[host][2], url) then
                    rules[host][2][url] = {{ip, port}}
                else
                    index = #rules[host][2][url] + 1
                    rules[host][2][url][index] = {ip,port}
                end
            end
        end
    end
    return rules
end

return M
