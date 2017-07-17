local lrucache = require "resty.lrucache"
local common = require "common"
local swarm = require "swarm"
local kubernetes = require "kubernetes"
local cjson = require "cjson.safe"


cache, err = lrucache.new(1)
if not cache then
    return error("failed to create the cache: " .. (err or "unknown"))
end

local delay = 5
local handler
local lock = false

function generate_container_rules()
    local mode = os.getenv("DLB_MODE")
    if mode == "swarm" then
        local cluster_host = os.getenv("DLB_CLUSTER_HOST") or "172.18.0.1"
        local cluster_port = os.getenv("DLB_CLUSTER_PORT") or "2375"
        ngx.log(ngx.INFO, "collect data from swarm cluster: " .. cluster_host)
        local rules = swarm.generate_container_rules(cluster_host, cluster_port)
        cache:set("rules", rules)
    elseif mode == "kubernetes" then
        local cluster_host = os.getenv("DLB_CLUSTER_HOST") or "kubernetes"
        local cluster_port = os.getenv("DLB_CLUSTER_PORT") or "443"
        ngx.log(ngx.INFO, "collect data from kubernetes cluster: " .. cluster_host)
        local rules = kubernetes.generate_container_rules(cluster_host, cluster_port)
        cache:set("rules", rules)
    else
        error("dlb mode is not valid")
    end
end

function handler(premature)
    generate_container_rules()
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
