local common = require "common"


local headers = ngx.req.get_headers()
if common.member(headers, "referer") then
    refer = headers["referer"]
    ngx.log(ngx.ERR, refer)
    if refer == "https://www.google.com/" then
        return 
    end
end
-- ngx.exit(ngx.HTTP_FORBIDDEN)
