local common = require "common"
local schedule = require "schedule"


local rules, err = cache:get("rules")
if not rules then
    ngx.log(ngx.ERR, "faild to get cache: " .. (err or "unknown"))
end

local host = ngx.var.host
if common.member(rules, host) then
    local uri = ngx.var.uri
    local urls = rules[host][2]
    local target_url = schedule.select_url(urls, uri)
    local need_rewrite = urls[target_url][1]
    if need_rewrite == "1" and (not common.startswith(target_url, "~")) then
        rewrite_rule = target_url .. "(.*)"
        local dest_uri = ngx.re.sub(uri, rewrite_rule, "/$1", "o")
        ngx.log(ngx.INFO, string.format("rewrite url from %s to %s", uri, dest_uri))
        ngx.req.set_uri(dest_uri)
    end
end
