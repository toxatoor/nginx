local status_codes = ngx.shared.status_codes
local notfound = status_codes:get("404") or 0
local badgateway = status_codes:get("502") or 0
local gatewaytimeout = status_codes:get("504") or 0
local clienterr = status_codes:get("499") or 0
local total = badgateway + gatewaytimeout

ngx.say(notfound, " " , clienterr , " " , badgateway, " " , gatewaytimeout , " = ", total)
