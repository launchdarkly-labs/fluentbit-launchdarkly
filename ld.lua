local ld = require("launchdarkly_server_sdk")


local YOUR_SDK_KEY = os.getenv("LD_SDK_KEY")
local LD_LOG_LEVEL = os.getenv("LD_LOG_LEVEL")


local YOUR_FEATURE_KEY = "filter-log-entry"

local config = {
    key = YOUR_SDK_KEY
}

local client = ld.clientInit(config, 1000)


function cb_filter(tag, timestamp, record)
    local customAttributes = { tag = tag }
    for k,v in pairs(record) do customAttributes[k] = v end
    local user = ld.makeUser({
      key = "service.fluentbit",
      anonymous = true,
      custom = customAttributes
    })

    if client:boolVariation(user, YOUR_FEATURE_KEY, true) then
      -- forward the record
      return 0,0,0
    else
      -- drop the record
      return -1,0,0
    end
 end

function ld_log(level, line)
  print(line)
end

ld.registerLogger(LD_LOG_LEVEL, ld_log)

