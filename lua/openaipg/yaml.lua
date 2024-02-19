yaml = {}

local function extractYamlFrontMatter()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local yamlContent = {}
    local inYamlBlock = false

    for _, line in ipairs(lines) do
        if line:match("^---$") then
            if inYamlBlock then
                break -- End of YAML block
            else
                inYamlBlock = true -- Start of YAML block
            end
        elseif inYamlBlock then
            table.insert(yamlContent, line)
        end
    end

    return yamlContent
end

local function parseSimpleYaml(yamlLines)
    local parsedYaml = {}

    for _, line in ipairs(yamlLines) do
        -- Match simple key-value pairs (ignores arrays, nested objects, etc.)
        local key, value = line:match("^([^:]+):%s*(.*)$")
        if key and value then
            -- Trim the key and value, and store in the table
            key = key:gsub("^%s*(.-)%s*$", "%1")
            value = value:gsub("^%s*(.-)%s*$", "%1")
            parsedYaml[key] = value
        end
    end

    return parsedYaml
end

yaml.extractYamlFrontMatter = extractYamlFrontMatter
yaml.parseSimpleYaml = parseSimpleYaml

return yaml
