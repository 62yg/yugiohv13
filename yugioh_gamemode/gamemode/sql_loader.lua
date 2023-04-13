local function readFile(filePath)
    local file = file.Open(filePath, "r", "GAME")
    if not file then return nil end

    local content = file:Read(file:Size())
    file:Close()

    return content
end


function loadCardsFromSqlFile(filePath)
    local sqlContent = readFile(filePath)

    if not sqlContent then
        print("[YGO] Failed to read card SQL file.")
        return
    end

    local queries = string.Explode(";", sqlContent)
    for _, query in ipairs(queries) do
        if string.Trim(query) ~= "" then
            local result = sql.Query(query)
            if not result then
                print("[YGO] Error loading card data from SQL file: " .. sql.LastError())
            end
        end
    end
end
