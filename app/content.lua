local rules, err = cache:get("rules")
local common = require "common"
local cjson = require "cjson.safe"

if not rules then
    error("faild to get cache: " .. (err or "unknown"))
end

if ngx.var.uri == "/status" then
    ngx.say(cjson.encode(rules))
    ngx.exit(ngx.HTTP_OK)
end

if common.member(rules, ngx.var.host) then
    local proto = rules[ngx.var.host][1]
    if common.startswith(proto, "http") then
        ngx.exec("@http")
    elseif common.startswith(proto, "uwsgi") then
        ngx.exec("@uwsgi")
    else
        ngx.say('unsupported backend')
    end
else
    ngx.say("unsupported host")
end
