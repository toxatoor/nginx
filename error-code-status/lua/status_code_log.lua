local status_codes = ngx.shared.status_codes

local resp_code = tonumber(ngx.var.status)

local newval, err = status_codes:incr(resp_code, 1)
if not newval and err == "not found" then
    status_codes:add(resp_code, 0)
    status_codes:incr(resp_code, 1)
end
