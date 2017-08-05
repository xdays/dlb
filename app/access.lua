local common = require "common"
local schedule = require "schedule"
local cjson = require "cjson.safe"


local rules, err = cache:get("rules")
if not rules then
    error("faild to get cache: " .. (err or "unknown"))
end

local host = ngx.var.host
local uri = ngx.var.uri
--  ngx.log(ngx.INFO, "request uri is: " .. uri)

if uri == "/dlb-status" then
    ngx.say(cjson.encode(rules))
    ngx.exit(ngx.HTTP_OK)
end

if common.member(rules, host) then
    urls = rules[host][2]
    target_url = schedule.select_url(urls, uri)
    if not target_url then
        ngx.log(ngx.INFO, "can not find target url for " .. uri)
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end
else
    ngx.log(ngx.INFO, "can not find host: " .. host)
    ngx.exit(ngx.HTTP_NOT_FOUND)
end
