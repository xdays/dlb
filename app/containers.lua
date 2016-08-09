local lrucache = require "resty.lrucache"
local common = require "common"
local swarm = require "swarm"


cache, err = lrucache.new(1)
if not cache then
    return error("failed to create the cache: " .. (err or "unknown"))
end

local delay = 5
local handler
local lock = false

function handler(premature)
    cluster_host = os.getenv("DLB_CLUSTER_HOST")
    if not cluster_host then
        cluster_host = "172.18.0.1"
    end
    ngx.log(ngx.INFO, "collect date from swarm cluster: " .. cluster_host)
    local rules = swarm.generate_container_rules(cluster_host)
    cache:set("rules", rules)
    ngx.log(ngx.INFO, "load rules successfully")
    if premature then
        return
    end
    local ok, err = ngx.timer.at(delay, handler)
    if not ok then
        ngx.log(ngx.ERR, "failed to create the timer: ", err)
        return
    end
end

if not lock then
    local ok, err = ngx.timer.at(delay, handler)
    if not ok then
        ngx.log(ngx.ERR, "failed to create the timer: ", err)
        return
    end
    lock = true
end
