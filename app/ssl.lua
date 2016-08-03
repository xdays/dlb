local ssl = require "ngx.ssl"
local common = require "common"

local function get_server_domain()
    local server_name, err = ssl.server_name()
    if not server_name then
        ngx.log(ngx.ERR, "failed to get server name: ", err)
        server_name = "default.everstring.com"
    end
    local t = common.split(server_name, "%.")
    if #t > 2 then
        table.remove(t, 1)
    end
    server_domain = table.concat(t, ".")
    return server_domain
end

local function load_certificate_chain()
    local domain_name = get_server_domain()
    local file_path = '/etc/nginx/certs.d/' .. domain_name .. ".crt"
    return common.get_file_content('/etc/nginx/certs.d/' .. domain_name .. ".crt")
end

local function load_certificate_key()
    local domain_name = get_server_domain()
    return common.get_file_content('/etc/nginx/certs.d/' .. domain_name .. ".key")
end
    

local ok, err = ssl.clear_certs()
if not ok then
    ngx.log(ngx.ERR, "failed to clear existing (fallback) certificates")
    return ngx.exit(ngx.ERROR)
end

local pem_cert_chain = assert(load_certificate_chain())
local der_cert_chain, err = ssl.cert_pem_to_der(pem_cert_chain)
if not der_cert_chain then
    ngx.log(ngx.ERR, "failed to convert certificate chain ",
            "from PEM to DER: ", err)
    return ngx.exit(ngx.ERROR)
end

local ok, err = ssl.set_der_cert(der_cert_chain)
if not ok then
    ngx.log(ngx.ERR, "failed to set DER cert: ", err)
    return ngx.exit(ngx.ERROR)
end

local pem_pkey = assert(load_certificate_key())
local der_pkey, err = ssl.priv_key_pem_to_der(pem_pkey)
if not der_pkey then
    ngx.log(ngx.ERR, "failed to convert certificate key ",
            "from PEM to DER: ", err)
    return ngx.exit(ngx.ERROR)
end

local ok, err = ssl.set_der_priv_key(der_pkey)
if not ok then
    ngx.log(ngx.ERR, "failed to set DER private key: ", err)
    return ngx.exit(ngx.ERROR)
end
