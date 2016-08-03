local schedule = require "schedule"
local balancer = require "ngx.balancer"


local rules, err = cache:get("rules")
local urls = rules[ngx.var.host][2]
local target_url = schedule.select_url(urls, ngx.var.uri)
local index = math.random(1, #urls[target_url])
local ip = urls[target_url][index][1]
local port = urls[target_url][index][2]
ok, err = balancer.set_current_peer(ip, port)
if not ok then
    ngx.log(ngx.ERR, "failed to set the current peer: ", err)
    return ngx.exit(500)
end
