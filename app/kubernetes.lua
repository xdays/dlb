local http = require "resty.http"
local cjson = require "cjson.safe"
local common = require "common"
local M = {}

function M.kubernetes_client(ip, port, object)
    local token_path = "/var/run/secrets/kubernetes.io/serviceaccount/token"
    local token = common.get_file_content(token_path)
    local httpc = http.new()
    local request_url = string.format("https://%s:%s/api/v1/%s", ip, port, object)
    httpc:set_timeout(20000)
    local r, err = httpc:request_uri(request_url, {
        headers = {
            ["Authorization"] = string.format("Bearer %s", token),
            ["Host"] = string.format("%s:%s", ip, port),
        },
        ssl_verify = false
    })
    if not r then
        error("faild to get data from kubernetes: " .. (err or "unknown"))
    end
    return r.body
end

function M.get_kubernetes_services(ip, port)
    return M.kubernetes_client(ip, port, "services")
end

function M.generate_container_rules(ip, port)
    local service_data = M.get_kubernetes_services(ip, port)
    local rules = {}
    -- ngx.log(ngx.INFO, service_data)
    for k,v in pairs(cjson.decode(service_data)["items"]) do
        local metadata = v["metadata"]
        local service_name = metadata["name"]
        if common.member(metadata, "annotations") then
            annotations = metadata["annotations"]
            if common.member(annotations, "host") and common.member(annotations, "proto") then
                ngx.log(ngx.INFO, "add service " .. service_name .. " to the rules")
                local host = annotations["host"]
                local proto = annotations["proto"]
                local url = common.get_or_default(annotations, "url", "/")
                local ip = v["spec"]["clusterIP"]
                local port = v["spec"]["ports"][1]["port"]
                local rewrite = common.get_or_default(annotations, "rewrite", "0")
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
                ngx.log(ngx.INFO, "service " .. service_name .. " does not have enough annotations")
            end
        else
            ngx.log(ngx.INFO, "service " .. service_name .. " has no annotations")
        end
    end
    ngx.log(ngx.INFO, cjson.encode(rules))
    return rules
end

return M
