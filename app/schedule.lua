local common = require "common"
local M = {}

function M.select_url(urls, url)
    local index = 0
    for k, v in pairs(urls) do
        if common.startswith(k, "~") then
            url_re = common.split(k, " ")[2]
            local m, err = ngx.re.match(url, url_re)
            if m then
                ngx.log(ngx.INFO, "uri match: " .. url_re)
                target_url = k
            else
                ngx.log(ngx.INFO, "uri does not match: " .. url_re)
            end
        else
            i, j = string.find(url, k)
            if j and j > index then
                index = j
                ngx.log(ngx.INFO, "uri match: " .. k)
                target_url = k
            else
                ngx.log(ngx.INFO, "uri does not match: " .. k)
            end
        end
    end
    return target_url
end

function M.round_robin()
    return
end

function M.random()
    return
end

return M
