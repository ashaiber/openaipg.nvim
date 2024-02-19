local commands = require "openaipg.commands"

local M = {}

-- Allows to add a setup function to the module
M.setup = function(opts)
  -- print("Options: ", opts)
  commands.setup()

end

return M
