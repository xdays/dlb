local M = {}

function M.select_url(urls, url)
    local index = 0
    local target_url = ""
    for k, v in pairs(urls) do
        i, j = string.find(url, k)
        if j and j > index then
            index = j
            target_url = k
        end
    end
    return target_url
end

return M
