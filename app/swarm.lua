local http = require "resty.http"
local cjson = require "cjson.safe"
local common = require "common"
local M = {}


function M.swarm_client(ip, port, object)
    local httpc = http.new()
    local r, err = httpc:request_uri(string.format("http://%s:%s/%s", ip, port, object))
    if not r then
        error("faild to get data from swarm: " .. (err or "unknown"))
    end
    return r.body
end

function M.get_swarm_services(ip, port)
    return M.swarm_client(ip, port, "services")
end 

function M.generate_container_rules(ip, port)
    local httpc = http.new()
    local service_data = M.get_swarm_services(ip, port)
    local nodes = {}
    local services = {}
    local rules = {}
    for k,v in pairs(cjson.decode(service_data)) do
        local service_name = v["Spec"]["Name"]
        if common.member(v["Spec"], "Labels") then
            ngx.log(ngx.INFO, "collect labels from service " .. service_name )
            labels = v["Spec"]["Labels"]
            if labels and common.member(labels, "host") and common.member(labels, "proto") then
                local host = labels["host"]
                local proto = labels["proto"]
                local url = common.get_or_default(labels, "url", "/")
                local ip = common.split(v["Endpoint"]["VirtualIPs"][1]["Addr"], "/")[1]
                if common.member(labels, "rewrite") then
                    rewrite = labels["rewrite"]
                else
                    rewrite = "0"
                end
                if common.member(v["Endpoint"], "Ports") then
                    port = v["Endpoint"]["Ports"][1]["TargetPort"]
                    if not common.member(rules, host) then
                        rules[host] = {proto}
                        rules[host][2] = {}
                        rules[host][2][url] = {rewrite, {{ip, port}}}
                    else
                        if not common.member(rules[host][2], url) then
                            rules[host][2][url] = {rewrite, {{ip, port}}}
                        else
                            index = #rules[host][2][url] + 1
                            rules[host][2][url][2][index] = {ip,port}
                        end
                    end
                else
                    ngx.log(ngx.INFO, "service " .. service_name .. " has no published port")
                end
            end
        else
            ngx.log(ngx.INFO, "service " .. service_name .. " has no labels")
        end
    end
    return rules
end

return M
