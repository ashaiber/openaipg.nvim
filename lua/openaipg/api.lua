local yaml = require"openaipg.yaml"

local Api = {}

local function callOpenAI(promptText, model)
    local apiKey = os.getenv("OPENAI_API_KEY") -- Make sure the API key is set in your environment variables
    if not apiKey then
        vim.api.nvim_err_writeln("OPENAI_API_KEY environment variable not set")
        return
    end

    -- Prepare the JSON payload using Neovim's built-in JSON support
    local data = vim.json.encode({
        model = model,
        messages = {
            { role = "system", content = "You are a helpful assistant." },
            { role = "user", content = promptText }
        }
    })

    -- Prepare the curl command
    local curlCmd = string.format([[curl -s -X POST https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer %s" \
        -d '%s']], apiKey, data:gsub("'", "'\\''")) -- Handle single quotes in JSON

    -- Execute the curl command
    local result = vim.fn.system(curlCmd)

    -- Check for curl error
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_err_writeln("Failed to call OpenAI API: " .. result)
        return
    end

    -- Decode the JSON response using Neovim's built-in JSON support
    local decodedResponse, err = vim.json.decode(result)
    if err then
        vim.api.nvim_err_writeln("Failed to decode JSON response: " .. err)
        return
    end

    -- Extract and return the desired message content
    if decodedResponse.choices and #decodedResponse.choices > 0 then
        return decodedResponse.choices[1].message.content
    else
        vim.api.nvim_err_writeln("Unexpected API response format.")
    end
end

local function splitStringByNewline(str)
    local t = {}
    table.insert(t, "")
    table.insert(t, "-------------------------------------------------")
    table.insert(t, "")
    for line in str:gmatch("([^\n]*)\n?") do
        table.insert(t, line)
    end
    return t
end

local function findAndProcessPrompt()
    local yamlLines = yaml.extractYamlFrontMatter()
    local config = yaml.parseSimpleYaml(yamlLines)

    local model = "gpt-3.5-turbo" -- Default model
    if config["model"] then
        model = config["model"]
        -- print("Model specified in YAML: " .. config["model"])
    else
        print("Model not specified in YAML. Using default model: gpt-3.5-turbo")
    end


    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local startLine, endLine = nil, nil

    -- Use case-insensitive pattern matching to find the markers
    for i, line in ipairs(lines) do
        if not startLine and line:lower():match("^%% prompt") then
            startLine = i
        elseif startLine and line:lower():match("^%% end of prompt") then
            endLine = i
            break
        end
    end

    -- Check if the markers were not found
    if not startLine or not endLine then
        vim.api.nvim_err_writeln("Could not find lines with '% Prompt' and '% End of Prompt'. Please check the document.")
        return
    end

    -- Proceed with extracting the text and making the API call
    local promptText = table.concat(lines, "\n", startLine, endLine)
    local responseContent = callOpenAI(promptText, model) -- Assuming callOpenAI is implemented as discussed earlier

    if responseContent then
        -- Insert the API response into the buffer after "% End of Prompt" line
        local linesToInsert = splitStringByNewline(responseContent)
        vim.api.nvim_buf_set_lines(0, endLine, endLine, false, linesToInsert)
    end
end

Api.callOpenAI = callOpenAI
Api.findAndProcessPrompt = findAndProcessPrompt

return Api
-- vim.api.nvim_create_user_command("findAndProcessPrompt", findAndProcessPrompt, {})

