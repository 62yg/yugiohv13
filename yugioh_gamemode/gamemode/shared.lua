-- shared.lua

GM.Name = "Yu-Gi-Oh Gamemode"
GM.Author = "Your Name"

CARD_TYPE_MONSTER = 1
CARD_TYPE_SPELL = 2

local PLAYER = FindMetaTable("Player")
cards = {}

CardExamples = {
    {
        name = "Blue-Eyes White Dragon",
        cardType = CARD_TYPE_MONSTER,
        attack = 3000,
        defense = 2500,
        level = 8,
        imagePath = "blueeyeswhitedragon.jpg",
    },
    {
        name = "Dark Magician",
        cardType = CARD_TYPE_MONSTER,
        attack = 2500,
        defense = 2100,
        level = 7,
        imagePath = "darkmagician.jpg",
    },
    {
        name = "Monster Reborn",
        cardType = CARD_TYPE_SPELL,
        effect = function(player, target)
            -- Add logic to revive a monster from the graveyard
        end,
        imagePath = "monster_reborn.jpg",
    },
}

-- shared.lua

function GM:ShowHelp(ply)
    if SERVER then
        net.Start("OpenDeckCreationMenu")
        net.Send(ply)
    end
end

function DrawCard(ply)
    local duelData = ply:GetDuelData()

    if not duelData or not duelData.deck or #duelData.deck == 0 then
        --print("DrawCard: Deck is empty or nil for player " .. ply:Nick())
       -- print("DuelData:")
        PrintTable(duelData)
        return
    end

    local cardID = table.remove(duelData.deck, 1)
    duelData.hand = duelData.hand or {}
    table.insert(duelData.hand, cardID)

    ply:SetDuelData(duelData)

    print("DrawCard: " .. cardID .. " drawn for player " .. ply:Nick())
end





-- shared.lua

function PerformTurn(player)
    print("Performing turn for " .. player:Nick())

    local card = DrawCard(player)

    if card then
        net.Start("UpdateCardPositions")
        net.WriteEntity(player)
        net.Broadcast()
    end

    local duelData = ply:GetNW2Var("DuelData")
    if not duelData then
        return
    end

    if DuelInProgress() then
        local cardID = DrawCard(ply)
        if cardID then
            net.Start("CardDrawn")
            net.WriteEntity(ply)
            net.WriteUInt(cardID, 32)
            net.Broadcast()
        end

        local nextPlayer = GetNextDuelPlayer(ply)
        if nextPlayer then
            timer.Simple(1, function()
                PerformTurn(nextPlayer)
            end)
        end
    end
end


function EndTurn(ply)
    -- Add logic for handling end-of-turn effects and other cleanup tasks

    -- Start the next player's turn
    timer.Simple(1, function() PerformTurn(ply) end)
end

-- shared.lua

function PlaceCardOnField(ply, cardIndex, fieldIndex, isDefence)
    local duelData = ply:GetNWTable("DuelData")
    local hand = duelData.hand
    local field = duelData.field

    local card = table.remove(hand, cardIndex)

    if card.cardType == CARD_TYPE_MONSTER then
        card.isDefence = isDefence
    end

    field[fieldIndex] = card

    ply:SetNWTable("DuelData", duelData)
end

-- shared.lua

function Attack(ply, attackerIndex, targetIndex)
    local attacker = ply:GetNWTable("DuelData").field[attackerIndex]
    local targetPly = GetOpponent(ply)
    local target = targetPly:GetNWTable("DuelData").field[targetIndex]

    if attacker.cardType ~= CARD_TYPE_MONSTER then
        ply:ChatPrint("Only monster cards can attack.")
        return
    end

    if not target then
        -- Direct attack
        local damage = attacker.attack
        ApplyDamage(targetPly, damage)
    elseif attacker.attack > target.defense then
        -- Destroy the target and apply damage
        local damage = attacker.attack - target.defense
        ApplyDamage(targetPly, damage)
        targetPly:GetNWTable("DuelData").field[targetIndex] = nil
    else
        -- Attacker is destroyed
        ply:GetNWTable("DuelData").field[attackerIndex] = nil
    end
end

function ApplyDamage(ply, damage)
    local duelData = ply:GetNWTable("DuelData")
    duelData.lifePoints = duelData.lifePoints - damage

    if duelData.lifePoints <= 0 then
        EndDuel(GetOpponent(ply))
    else
        ply:SetNWTable("DuelData", duelData)
    end
end

-- shared.lua

function EndDuel(winner)
    local loser = GetOpponent(winner)

    winner:ChatPrint("Congratulations, you have won the duel!")
    loser:ChatPrint("You have lost the duel.")

    -- Add logic to reset the game state and handle any post-duel tasks
end


-- shared.lua

function ActivateSpell(ply, cardIndex, targetIndex)
    local duelData = ply:GetNWTable("DuelData")
    local hand = duelData.hand
    local field = duelData.field

    local card = hand[cardIndex]

    if card.cardType ~= CARD_TYPE_SPELL then
        ply:ChatPrint("Only Spell cards can be activated.")
        return
    end

    local targetPly = ply
    if targetIndex then
        local targetCard = field[targetIndex]
        if not targetCard then
            targetPly = GetOpponent(ply)
            targetCard = targetPly:GetNWTable("DuelData").field[targetIndex]
        end

        if targetCard then
            card.effect(targetPly, targetCard)
        end
    else
        card.effect(targetPly)
    end

    table.remove(hand, cardIndex)
    ply:SetNWTable("DuelData", duelData)
end



-- shared.lua

function RenderHand(ply, hand)
    if not hand then return end

    local sw, sh = ScrW(), ScrH()
    local cardWidth, cardHeight = sw * 0.1, sh * 0.25
    local cardSpacing = cardWidth * 0.1
    local totalWidth = (#hand * cardWidth) + (#hand - 1) * cardSpacing
    local startX = (sw - totalWidth) / 2

    for i, card in ipairs(hand) do
        local x = startX + (i - 1) * (cardWidth + cardSpacing)
        local y = sh - cardHeight

        -- Assuming you have a GetCardTexture function to load the card image
        local cardTexture = GetCardTexture(card)
        surface.SetDrawColor(255, 255, 255)
        surface.SetTexture(cardTexture)
        surface.DrawTexturedRect(x, y, cardWidth, cardHeight)
    end
end

-- shared.lua

-- shared.lua

function GetCardTexture(card)
    -- Assuming you have a folder named "card_images" containing card images
    local cardImagePath = "card_images/" .. card.Name .. ".jpg"

    if file.Exists("materials/" .. cardImagePath, "GAME") then
        return Material(cardImagePath, "smooth")
    else
        -- If the card image is not found, display a default image
        return Material("card_images/default_card.jpg", "smooth")
    end
end


-- shared.lua


function PLAYER:SetDuelData(duelData)
    if not self or not self:IsValid() then return end
    if not duelData then
        print("SetDuelData: Attempting to set nil DuelData for player " .. self:Nick())
        return
    end

    local duelDataJson = util.TableToJSON(duelData)
    if not duelDataJson then
        print("SetDuelData: Failed to convert DuelData to JSON for player " .. self:Nick())
        return
    end

    self:SetNWString("DuelData", duelDataJson)
    print("SetDuelData: DuelData set for player " .. self:Nick() .. ", JSON: " .. duelDataJson)
end



function PLAYER:GetDuelData()
    local duelData = self:GetNWString("duelData", "{}")
    local data = util.JSONToTable(duelData) or {}
    return data
end




function UpdateDuelData(ply)
    if SERVER then
        local duelData = ply:GetDuelData()
        if not duelData then return end
        local duelDataJson = util.TableToJSON(duelData)
        ply:SetNW2String("duelDataJson", duelDataJson)
    end
end


function Shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end

function pickRandomCard()
    local cardCountQuery = "SELECT COUNT(*) as count FROM cards"
    local cardCountResult = sql.QueryRow(cardCountQuery)
    local cardCount = tonumber(cardCountResult.count)

    local randomId = math.random(1, cardCount)
    local query = string.format("SELECT * FROM cards WHERE id = '%d'", randomId)
    local card = sql.QueryRow(query)

    return {
        id = tonumber(card.id),
        name = card.name,
        description = card.description,
        type = card.type,
        attack = tonumber(card.attack),
        defense = tonumber(card.defense),
        stars = tonumber(card.stars),
        attribute = card.attribute,
        imagePath = card.imagePath
    }
end


function loadCards()
    local cardData = sql.Query("SELECT * FROM cards")
    if not cardData then
        print("[YGO] Failed to retrieve card data from SQLite.")
        return
    end

    for _, data in ipairs(cardData) do
        local card = {
            id = tonumber(data.card_id),
            name = data.card_name,
            type = data.card_type,
            effect = data.card_effect,
            atk = tonumber(data.card_atk) or nil,
            def = tonumber(data.card_def) or nil,
            level = tonumber(data.card_level) or nil
        }

        cards[card.id] = card
    end
end


function loadCardsFromSql()
    -- Drop the existing cards table
    local dropTableQuery = "DROP TABLE IF EXISTS cards;"
    sql.Query(dropTableQuery)

    -- Create the cards table with the correct schema
    local createTableQuery = [[
        CREATE TABLE IF NOT EXISTS cards (
            card_id INTEGER PRIMARY KEY,
            card_name TEXT NOT NULL,
            card_type TEXT NOT NULL,
            card_desc TEXT NOT NULL,
            attack INTEGER,
            defense INTEGER,
            stars INTEGER,
            attribute TEXT,
            image_path TEXT
        );
    ]]
    sql.Query(createTableQuery)

    -- Insert card data into the cards table
    local insertCardsQuery = [[
        INSERT OR IGNORE INTO cards (card_id, card_name, card_type, card_desc, attack, defense, stars, attribute, image_path)
        VALUES 
            (1, 'Dark Magician', 'Monster', 'The ultimate wizard in terms of attack and defense.', 2500, 2100, 7, 'Dark', 'darkmagician.jpg'),
            (2, 'Blue-Eyes White Dragon', 'Monster', 'This legendary dragon is a powerful engine of destruction.', 3000, 2500, 8, 'Light', 'blueeyeswhitedragon.jpg'),
            (3, 'Monster Reborn', 'Spell', 'Target 1 monster in either player''s Graveyard; Special Summon it.', NULL, NULL, NULL, NULL, 'monster_reborn.jpg');
    ]]
    sql.Query(insertCardsQuery)

    local cardCountQuery = "SELECT COUNT(*) as count FROM cards"
    local cardCountResult = sql.QueryRow(cardCountQuery)
    local cardCount = tonumber(cardCountResult.count)

    print("[YGO] Loaded " .. cardCount .. " cards.")
end

