local schedule = require "schedule"
local balancer = require "ngx.balancer"


local rules, err = cache:get("rules")
if not rules then
    error("faild to get cache: " .. (err or "unknown"))
end

local host = ngx.var.host
local port = ngx.var.server_port
local uri = ngx.var.uri
local urls = rules[host][2]
local target_url = schedule.select_url(urls, uri)
local index = math.random(1, #urls[target_url][2])
local ip = urls[target_url][2][index][1]
local port = urls[target_url][2][index][2]

ngx.log(ngx.INFO, string.format("proxy request %s:%s%s to %s:%s", host, port, uri, ip, port))
ok, err = balancer.set_current_peer(ip, port)
if not ok then
    ngx.log(ngx.ERR, "failed to set the current peer: ", err)
    return ngx.exit(500)
end
