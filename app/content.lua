local common = require "common"
local cjson = require "cjson.safe"

local rules, err = cache:get("rules")
if not rules then
    error("faild to get cache: " .. (err or "unknown"))
end

local host = ngx.var.host
if common.member(rules, host) then
    local proto = rules[host][1]
    if common.startswith(proto, "http") then
        ngx.exec("@http")
    elseif common.startswith(proto, "uwsgi") then
        ngx.exec("@uwsgi")
    else
        ngx.say('unsupported backend')
    end
end
