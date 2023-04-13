-- init.lua
AddCSLuaFile("shared.lua")
include("shared.lua")
AddCSLuaFile("cl_init.lua")
include("sql_loader.lua")

util.AddNetworkString("OpenDeckCreationMenu")
util.AddNetworkString("DuelData")
util.AddNetworkString("UpdateCardPositions")

-- init.lua
playerDecks = {
    BasicDeck = {"card1", "card2", "card3", "card4", "card5", "card6", "card7", "card8", "card9", "card10"},
}



function InitializeDatabase()
    sql.Query("CREATE TABLE IF NOT EXISTS player_decks (steamid64 TEXT PRIMARY KEY, deck TEXT)")
end
InitializeDatabase()


function SetPlayerDuelData(ply, duelData)
    ply:SetNWString("DuelData", util.TableToJSON(duelData))
end

function GM:PlayerSpawn(ply)
    self.BaseClass.PlayerSpawn(self, ply)
    InitializeDeck(ply)
end

hook.Add("PlayerSpawn", "InitializeDuelDataOnSpawn", function(ply)
    InitializeDuelData(ply)
end)

local BasicCards = {
    { Name = "Blue-Eyes White Dragon", Attack = 3000, Defense = 2500, Type = "Monster" },
    { Name = "Card2", Attack = 1500, Defense = 1500, Type = "Monster" },
    { Name = "Card3", Attack = 2000, Defense = 2000, Type = "Monster" },
    { Name = "Card4", Type = "Spell", Effect = "Draw 1 card" },
    { Name = "Card5", Type = "Spell", Effect = "Increase ATK by 500" }
}

-- init.lua

function CreateBasicDeck(deckSize)
    local basicDeck = {}

    for i = 1, deckSize do
        local randomCard = pickRandomCard()
        table.insert(basicDeck, table.Copy(randomCard))
    end

    return basicDeck
end


function AddPlayerDeck(playerName, deck)
    if not playerName or not deck then return end
    playerDecks[playerName] = deck
end

function InitializeDuelData(ply)
    if not ply then return end

    local defaultDeck = InitializeDeck(ply)
    local playerDeck = GetPlayerDeck(ply) or defaultDeck

    if not playerDeck or #playerDeck == 0 then
        print("InitializeDuelData: Player " .. ply:Nick() .. " has no deck.")
        playerDeck = defaultDeck
    end

    local hand = {}
    for i = 1, 5 do
        local card = table.remove(playerDeck, 1)
        if card then
            table.insert(hand, card)
            DrawCard(ply) -- Call DrawCard to display the card in the player's hand
        end
    end

    local duelData = {
        deck = playerDeck,
        hand = hand,
        field = {},
        graveyard = {},
        banished = {}
    }

    ply:SetDuelData(duelData)
end



function PlayerHasSavedDeck(ply)
    local steamID = ply:SteamID64()
    local result = sql.QueryValue("SELECT steamid64 FROM player_decks WHERE steamid64 = " .. sql.SQLStr(steamID))
    return result ~= nil
end






-- init.lua

hook.Add("PlayerInitialSpawn", "InitializeDuelDataOnJoin", function(ply)
    timer.Simple(0, function()
        InitializeDuelData(ply)
    print("PlayerInitialSpawn called for:", ply:Nick())
    AssignDeck(ply)
    SetupZones(ply)
    end)
	
	
end)





hook.Add("PlayerDisconnected", "SaveDeckOnDisconnect", function(ply)
    SavePlayerDeck(ply)
end)


function BeginDuel(ply, cmd, args)
    local players = player.GetAll()

    if #players ~= 2 then
        ply:ChatPrint("This gamemode only supports 2 players.")
        return
    end

    local player1 = players[1]
    local player2 = players[2]

    -- Retrieve player decks from your desired storage method (e.g., database, file)
    local player1Deck = GetPlayerDeck(player1)
    local player2Deck = GetPlayerDeck(player2)

    if not player1Deck or not player2Deck then
        ply:ChatPrint("Both players must have a deck to start a duel.")
        return
    end

    -- Create decks and hands for both players
    local player1Deck = CreateBasicDeck(40)
    local player2Deck = CreateBasicDeck(40)

    local player1Hand = drawCards(player1Deck, 5)
    local player2Hand = drawCards(player2Deck, 5)

    -- Set the players' hands using the previously created hands
    SetPlayerHand(player1, player1Hand)
    SetPlayerHand(player2, player2Hand)

    -- Add logic to determine the first player, for example:
    local firstPlayer = math.random(2) == 1 and player1 or player2

    -- Start the first player's turn
    PerformTurn(firstPlayer)

    -- Add logic to draw starting hands and set up the game state
    -- You may need to create additional functions to manage game state,
    -- such as drawing cards, placing cards on the field, etc.
end


concommand.Add("begin_duel", BeginDuel)

concommand.Add("begin_duel", function()
    local player1, player2 = GetPlayersForDuel()
    if player1 and player2 then
        StartDuel(player1, player2)
    else
        print("Not enough players to start a duel.")
    end
end)


-- init.lua

util.AddNetworkString("CardDrawn")
util.AddNetworkString("CardPlayed")
util.AddNetworkString("CardMovedToGraveyard")

-- init.lua



function InitializeDeck(ply)
    if not ply or not IsValid(ply) then return end

    local deckID = ply:SteamID64()
    if not deckID or deckID == "" then
        print("InitializeDeck: Invalid DeckID for player " .. ply:Nick())
        return
    end

    ply:SetNWString("DeckID", deckID)

    if not playerDecks[deckID] then
        local defaultDeck = {
            "blueeyeswhitedragon", "darkmagician", "monster_reborn","darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician",
		"darkmagician"
		
            -- Add the other 37 default cards here
        }
        playerDecks[deckID] = table.Copy(defaultDeck)
    end
end





-- init.lua

function GetDeck(deckID)
    -- Replace this with your actual implementation to fetch the deck.
    local deck = {
        Cards = {
            -- Example cards, replace with actual cards in your deck implementation.
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10
        }
    }

    return deck
end


function DeepCopyTable(tbl)
    local newTable = {}
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            newTable[key] = DeepCopyTable(value)
        else
            newTable[key] = value
        end
    end
    return newTable
end




function MoveCardToGraveyard(ply, card)
    local duelData = GetDuelData(ply)
    table.RemoveByValue(duelData.Hand, card)
    table.insert(duelData.Graveyard, card)
    SetDuelData(ply, duelData)

    NotifyCardMovedToGraveyard(ply)
    net.Start("CardMovedToGraveyard")
    net.WriteEntity(ply)
    net.Broadcast()
end


-- init.lua

function UpdateLifePoints(ply, delta)
   local duelData = GetDuelData(ply)
    duelData.LifePoints = duelData.LifePoints + delta
    SetDuelData(ply, duelData)

    -- Notify players of life points update (implement this function if necessary)
    NotifyLifePointsUpdate(ply)
end


-- init.lua

function HandleCardAttack(attacker, defender, attackingCard, defendingCard)
    -- Calculate battle damage and update life points (assuming you have a CalculateBattleDamage function)
    local battleDamage = CalculateBattleDamage(attackingCard, defendingCard)
    UpdateLifePoints(defender, -battleDamage)

    -- Move cards to appropriate positions based on the outcome of the battle
    local attackerDuelData = attacker:GetNW2Table("DuelData")
    local defenderDuelData = defender:GetNW2Table("DuelData")

    -- Example: Move defending card to the graveyard if it was destroyed
    table.RemoveByValue(defenderDuelData.Field, defendingCard)
    table.insert(defenderDuelData.Graveyard, defendingCard)

    -- Save updated DuelData
    attacker:SetNW2Table("DuelData", attackerDuelData)
    defender:SetNW2Table("DuelData", defenderDuelData)

    -- Notify players of the outcome (implement this function if necessary)
    NotifyCardAttackOutcome(attacker, defender, attackingCard, defendingCard)
end

-- init.lua

function ActivateSpellCard(ply, spellCard)
    local duelData = ply:GetNW2Table("DuelData")

    -- Example: Move spell card from hand to field
    table.RemoveByValue(duelData.Hand, spellCard)
    table.insert(duelData.Field, spellCard)

    -- Apply the spell card's effect (assuming you have an ApplySpellEffect function)
    ApplySpellEffect(ply, spellCard)

    -- Save updated DuelData
    ply:SetNW2Table("DuelData", duelData)

    -- Notify players of the spell card activation (implement this function if necessary)
    NotifySpellCardActivation(ply, spellCard)
end


-- init.lua

function ActivateSpellCard(ply, spellCard)
    local duelData = ply:GetNW2Table("DuelData")

    -- Example: Move spell card from hand to field
    table.RemoveByValue(duelData.Hand, spellCard)
    table.insert(duelData.Field, spellCard)

    -- Apply the spell card's effect (assuming you have an ApplySpellEffect function)
    ApplySpellEffect(ply, spellCard)

    -- Save updated DuelData
    ply:SetNW2Table("DuelData", duelData)

    -- Notify players of the spell card activation (implement this function if necessary)
    NotifySpellCardActivation(ply, spellCard)
end

-- init.lua

function GetPlayerDeck(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return nil end
    local deckID = ply:GetNWString("DeckID", "")

    if deckID == "" then
        print("GetPlayerDeck: DeckID is empty for player " .. ply:Nick())
        return nil
    end

    local deck = playerDecks[deckID]

    if not deck then
        print("GetPlayerDeck: Deck not found for player " .. ply:Nick())
        return nil
    end

    return table.Copy(deck)
end

function SetNW2Deck(ply, deck)
    for i, card in ipairs(deck) do
        ply:SetNW2String("Deck_" .. i, card)
    end
end

function CreateDeckTable()
    local createTableQuery = [[
        CREATE TABLE IF NOT EXISTS yugioh_decks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            steamid TEXT NOT NULL UNIQUE,
            deck TEXT NOT NULL
        );
    ]]

    local result = sql.Query(createTableQuery)

    if result == false then
        print("Error creating 'yugioh_decks' table: ", sql.LastError())
    else
        print("yugioh_decks table created or already exists.")
    end
end
hook.Add("Initialize", "CreateDeckTableOnInitialize", CreateDeckTable)


function SavePlayerDeck(ply, deck)
    if not ply or not IsValid(ply) or not deck then return end

    local deckID = ply:SteamID64()
    if not deckID or deckID == "" then
        print("SavePlayerDeck: Invalid DeckID for player " .. ply:Nick())
        return
    end

    local deckJSON = util.TableToJSON(deck)
    if not deckJSON then
        print("Error converting deck table to JSON for player " .. ply:Nick())
        return
    end

    local query = "REPLACE INTO yugioh_decks (deck_id, deck_data) VALUES ('" .. deckID .. "', " .. sql.SQLStr(deckJSON) .. ")"
    local result = sql.Query(query)

    if result == false then
        local error_msg = sql.LastError()
        print("Error saving player deck:", error_msg)
    else
        print("Deck saved for player " .. ply:Nick())
    end
end



function LoadPlayerDeck(ply)
    local steamID = ply:SteamID64()
    local result = sql.Query("SELECT deck FROM player_decks WHERE steamid64 = " .. sql.SQLStr(steamID))

    if result then
        local deckData = result[1]["deck"]
        print("Player deck loaded:", ply:Nick())
        return util.JSONToTable(deckData)
    end

    print("No saved deck found for player:", ply:Nick())
    return nil
end

function AssignDeck(ply)
    local deckID = ply:SteamID64()

    local deck = LoadPlayerDeck(ply)
    if not deck then
        print("No saved deck found for player: " .. ply:Nick())
        InitializeDeck(ply)
        deck = playerDecks[deckID]
        SavePlayerDeck(ply, deck)
    end

    SetNW2Deck(ply, deck)
end







function DuelInProgress()
    return GetGlobalBool("DuelInProgress", false)
end


-- init.lua

function SetDuelPlayers(player1, player2)
    SetGlobalEntity("DuelPlayer1", player1)
    SetGlobalEntity("DuelPlayer2", player2)
    SetGlobalBool("DuelInProgress", true)
end



function StartDuel(player1, player2)
    if not player1 or not player2 then
        print("Unable to start duel. Players not found.")
        return
    end

    if DuelInProgress() then
        print("A duel is already in progress.")
        return
    end

    print("Starting duel between " .. player1:Nick() .. " and " .. player2:Nick())

    SetDuelPlayers(player1, player2)
    player1:SetNWString("DeckID", "default")
    player2:SetNWString("DeckID", "default")
    LoadPlayerDeck(player1)
    LoadPlayerDeck(player2)
    InitializeDuelData(player1)
    InitializeDuelData(player2)

    -- Draw 5 cards for each player
    for i = 1, 5 do
        DrawCard(player1)
        DrawCard(player2)
    end

    PerformTurn(player1)
end







-- init.lua

function GetPlayersForDuel()
    local players = player.GetAll()
    if #players >= 2 then
        return players[1], players[2]
    else
        return nil, nil
    end
end


-- init.lua

util.AddNetworkString("ShowDuelPanel")

function PerformTurn(player)
    print("Performing turn for " .. player:Nick())

    DrawCard(player)

    -- Add your turn logic here

    net.Start("ShowDuelPanel")
    net.Send(player)

    -- Temporarily comment out the timer to avoid switching turns automatically
    -- local nextPlayer = GetNextPlayer(player)
    -- timer.Simple(5, function()
    --     PerformTurn(nextPlayer)
    -- end)
end


-- init.lua

function GetNextPlayer(currentPlayer)
    local player1 = GetGlobalEntity("DuelPlayer1")
    local player2 = GetGlobalEntity("DuelPlayer2")

    if currentPlayer == player1 then
        return player2
    else
        return player1
    end
end



local cardImages = file.Find("materials/card_images/*.jpg", "GAME")
for _, image in ipairs(cardImages) do
    resource.AddFile("materials/" .. image)
end

sql.Query("CREATE TABLE IF NOT EXISTS cards (card_id INTEGER PRIMARY KEY, card_name TEXT, card_type TEXT, card_effect TEXT, card_atk INTEGER, card_def INTEGER, card_level INTEGER)")

loadCardsFromSql()
loadCards()



