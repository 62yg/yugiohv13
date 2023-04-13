
cardTextures = {}
local playerZones = {
    [1] = {
        Hand = nil,
        Field = nil,
        Graveyard = nil
    },
    [2] = {
        Hand = nil,
        Field = nil,
        Graveyard = nil
    }
}

-- cl_init.lua

include("shared.lua")

function OpenDeckCreationMenu()
    local frame = vgui.Create("DFrame")
    frame:SetSize(600, 400)
    frame:SetTitle("Deck Creation")
    frame:Center()
    frame:MakePopup()

    -- Add logic to display available cards, allow players to add/remove cards to/from their deck, and save the deck
end

net.Receive("OpenDeckCreationMenu", function(len)
    OpenDeckCreationMenu()
end)


-- cl_init.lua

function CreateFieldZone(player, parentPanel)
    local fieldZone = vgui.Create("DPanel", parentPanel)
    fieldZone:SetSize(100, 100)
    fieldZone:SetPos(0, 0)
    fieldZone.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 255, 100))
    end
    return fieldZone
end

function CreatePlayingField(parentPanel)

    local mainPanel = vgui.Create("DFrame")
    mainPanel:SetSize(ScrW(), ScrH())
    mainPanel:SetTitle("")
    mainPanel:ShowCloseButton(false)
    mainPanel:SetDraggable(false)
    mainPanel:MakePopup()
    mainPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 200))
    end

    local playingField = vgui.Create("DPanel", mainPanel)
    playingField:SetSize(mainPanel:GetWide(), mainPanel:GetTall())
    playingField:SetPos(0, 0)
    playingField.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 0))
    end

    local player = LocalPlayer()

    -- Create Life Points display
    local lifePointsDisplay = CreateLifePointsDisplay(player, playingField)
    
    -- Add Monster Zones
    CreateMonsterZone(player, playingField, 550, 850) -- players's Monster Zones
    CreateMonsterZone(player, playingField, 850, 850)
    CreateMonsterZone(player, playingField, 1150, 850)
	CreateMonsterZone(player, playingField, 1450, 850)
    CreateMonsterZone(player, playingField, 1750, 850)
	CreateMonsterZone(opponent, playingField, 550, 299) -- Opponent's Monster Zones
	CreateMonsterZone(opponent, playingField, 850, 299) 
	CreateMonsterZone(opponent, playingField, 1150, 299) 
	CreateMonsterZone(opponent, playingField, 1450, 299) 
	CreateMonsterZone(opponent, playingField, 1750, 299) 


    -- Add Spell & Trap Zones
    CreateSpellTrapZone(player, playingField, 550, 1099)
    CreateSpellTrapZone(player, playingField, 850, 1099)
    CreateSpellTrapZone(player, playingField, 1150, 1099)
    CreateSpellTrapZone(player, playingField, 1450, 1099)
    CreateSpellTrapZone(player, playingField, 1750, 1099)
	CreateSpellTrapZone(opponent, playingField, 550, 50) -- Opponent's Spell & Trap Zones
    CreateSpellTrapZone(opponent, playingField, 850, 50) -- Opponent's Spell & Trap Zones
    CreateSpellTrapZone(opponent, playingField, 1150, 50) -- Opponent's Spell & Trap Zones
    CreateSpellTrapZone(opponent, playingField, 1450, 50) -- Opponent's Spell & Trap Zones
    CreateSpellTrapZone(opponent, playingField, 1750, 50) -- Opponent's Spell & Trap Zones



    -- Add Deck Zone
    CreateDeckZone(player, playingField, 500, 200)

    -- Add Extra Deck Zone
    CreateExtraDeckZone(player, playingField, 600, 200)

    -- Add Graveyard Zone
    CreateGraveyardZone(player, playingField, 700, 200)
	
	-- Add Hand Zones
local yourPlayer = LocalPlayer()
local opponent = GetOpponent(yourPlayer)


local yourHandZone = CreateHandZone(yourPlayer, mainPanel, mainPanel, 100, 450, 80, 120)
local opponentHandZone = CreateHandZone(opponent, mainPanel, mainPanel, 100, 20, 80, 120)



	
	    playerZones[yourPlayer:EntIndex()] = {
        HandZone = yourHandZone,
        FieldZone = CreateFieldZone(yourPlayer, mainPanel),
        GraveyardZone = CreateGraveyardZone(yourPlayer, mainPanel)
    }

    playerZones[opponent:EntIndex()] = {
        HandZone = opponentHandZone,
        FieldZone = CreateFieldZone(opponent, mainPanel),
        GraveyardZone = CreateGraveyardZone(opponent, mainPanel)
    }

    return playingField
end







-- cl_init.lua

function CreateCardDisplay(parent, card, isOpponent)
    local cardDisplay = vgui.Create("DImage", parent)
    cardDisplay:SetSize(parent:GetWide() / parent:GetChildCount(), parent:GetTall())

    if isOpponent then
        cardDisplay:SetImage("card_back.jpg")
    else
        cardDisplay:SetImage(card.image)
    end

    cardDisplay.DoClick = function(card, parent, x, y, width, height)
    if not isOpponent then
    local cardPanel = vgui.Create("DPanel", parent)
    cardPanel:SetSize(width, height)
    cardPanel:SetPos(x, y)
    cardPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 255))
    end

    local cardImage = vgui.Create("DImage", cardPanel)
    cardImage:SetSize(width, height)
    cardImage:SetImage(card.imagePath)
    end
    end

    return cardDisplay
end


  


-- cl_init.lua



function DisplayHand(ply)
    if not IsValid(ply) then return end

    local hand = {}
    local duelDataEntity = ply:GetNW2Entity("DuelData")

    if IsValid(duelDataEntity) then
        for i = 1, 7 do
            local cardID = duelDataEntity:GetNW2Int("Hand_" .. i, -1)
            if cardID ~= -1 then
                hand[i] = cardID
            end
        end
    end

    local handZone = GetHandZoneForPlayer(ply)

    for i, cardID in ipairs(hand) do
        CreateCardDisplay(cardID, handZone)
    end
end


function DisplayField(ply)
    if not IsValid(ply) then return end

    local field = {}
    local duelDataEntity = ply:GetNW2Entity("DuelData")

    if IsValid(duelDataEntity) then
        for i = 1, 5 do
            local cardID = duelDataEntity:GetNW2Int("Field_" .. i, -1)
            if cardID ~= -1 then
                field[i] = cardID
            end
        end
    end

    local fieldZone = GetFieldZoneForPlayer(ply)

    for i, cardID in ipairs(field) do
        CreateCardDisplay(cardID, fieldZone)
    end
end


function DisplayGraveyard(ply)
    if not IsValid(ply) then return end

    local graveyard = {}
    local duelDataEntity = ply:GetNW2Entity("DuelData")

    if IsValid(duelDataEntity) then
        local count = duelDataEntity:GetNW2Int("GraveyardCount", 0)

        for i = 1, count do
            local cardID = duelDataEntity:GetNW2Int("Graveyard_" .. i, -1)
            if cardID ~= -1 then
                graveyard[i] = cardID
            end
        end
    end

    local graveyardZone = GetGraveyardZoneForPlayer(ply)

    for i, cardID in ipairs(graveyard) do
        CreateCardDisplay(cardID, graveyardZone)
    end
end


-- cl_init.lua

function ClearZone(zone)
    if zone ~= nil then
       for _, child in ipairs(zone:GetChildren()) do
         child:Remove()
       end
    else

    end
end

function GetOpponent(ply)
    if not IsValid(ply) then return end

    for _, opponent in ipairs(player.GetAll()) do
        if opponent ~= ply then
            return opponent
        end
    end
end

-- cl_init.lua

function UpdatePlayingField(ply, handZone, fieldZone, graveyardZone)
    ClearZone(handZone)
    ClearZone(fieldZone)
    ClearZone(graveyardZone)

    DisplayHand(ply, handZone)
    DisplayField(ply, fieldZone)
    DisplayGraveyard(ply, graveyardZone)
end


-- cl_init.lua

hook.Add("CardDrawn", "UpdatePlayingFieldOnCardDrawn", function(ply)
    local handZone = GetHandZoneForPlayer(ply) -- You will need to create this function
    local fieldZone = GetFieldZoneForPlayer(ply) -- You will need to create this function
    local graveyardZone = GetGraveyardZoneForPlayer(ply) -- You will need to create this function

    UpdatePlayingField(ply, handZone, fieldZone, graveyardZone)
end)

hook.Add("CardPlayed", "UpdatePlayingFieldOnCardPlayed", function(ply)
    local handZone = GetHandZoneForPlayer(ply) -- You will need to create this function
    local fieldZone = GetFieldZoneForPlayer(ply) -- You will need to create this function
    local graveyardZone = GetGraveyardZoneForPlayer(ply) -- You will need to create this function

    UpdatePlayingField(ply, handZone, fieldZone, graveyardZone)
end)

hook.Add("CardMovedToGraveyard", "UpdatePlayingFieldOnCardMovedToGraveyard", function(ply)
    local handZone = GetHandZoneForPlayer(ply) -- You will need to create this function
    local fieldZone = GetFieldZoneForPlayer(ply) -- You will need to create this function
    local graveyardZone = GetGraveyardZoneForPlayer(ply) -- You will need to create this function

    UpdatePlayingField(ply, handZone, fieldZone, graveyardZone)
end)

function GetHandZoneForPlayer(ply)
    return playerZones[ply] and playerZones[ply].handZone
end

function GetFieldZoneForPlayer(ply)
    return playerZones[ply] and playerZones[ply].fieldZone
end

function GetGraveyardZoneForPlayer(ply)
    return playerZones[ply] and playerZones[ply].graveyardZone
end


-- cl_init.lua

net.Receive("CardDrawn", function(len)
    local ply = net.ReadEntity()
    hook.Run("CardDrawn", ply)
end)

net.Receive("CardPlayed", function(len)
    local ply = net.ReadEntity()
    hook.Run("CardPlayed", ply)
end)

net.Receive("CardMovedToGraveyard", function(len)
    local ply = net.ReadEntity()
    hook.Run("CardMovedToGraveyard", ply)
end)

-- cl_init.lua



function CreateLifePointsDisplay(ply, parentPanel)
    local lifePointsPanel = vgui.Create("DPanel", parentPanel)
    lifePointsPanel:SetSize(200, 30) -- Adjust the size as needed.
    lifePointsPanel:SetPos(0, 0)
    lifePointsPanel.Paint = function(self, w, h)
        local lifePoints = ply:GetNWInt("LifePoints", 0)
        draw.SimpleText("Life Points: " .. lifePoints, "DermaDefault", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    return lifePointsPanel
end





-- cl_init.lua

function ShowDuelPanel()
    if not IsValid(DuelPanel) then
        CreatePlayingField(duelPanel)
    end
    DuelPanel:SetVisible(true)
end


net.Receive("ShowDuelPanel", function()
    ShowDuelPanel()
end)

function ShowDuelPanel()
    local screenWidth, screenHeight = ScrW(), ScrH()

    local duelPanel = vgui.Create("DPanel")
    duelPanel:SetSize(screenWidth, screenHeight)
    duelPanel:SetPos(0, 0)
    duelPanel.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(Material("field.jpg"))
        surface.DrawTexturedRect(0, 0, w, h)
    end

    CreatePlayingField(duelPanel)
end


function CreateMonsterZone(player, parentPanel, x, y)
    local monsterZone = vgui.Create("DPanel", parentPanel)
    monsterZone:SetSize(240, 230) -- Set the size of the Monster Zone
    monsterZone:SetPos(x, y)
    monsterZone.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 255, 100)) -- Set a background color for the Monster Zone
    end

    return monsterZone
end


function CreateSpellTrapZone(player, parentPanel, x, y)
    local spellTrapZone = vgui.Create("DPanel", parentPanel)
    spellTrapZone:SetSize(240, 230) -- Set the size of the Spell & Trap Zone
    spellTrapZone:SetPos(x, y)
    spellTrapZone.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(100, 255, 100, 100)) -- Set a background color for the Spell & Trap Zone
    end

    return spellTrapZone
end



function CreateDeckZone(player, parentPanel, x, y)
    local deckZone = vgui.Create("DButton", parentPanel)
    deckZone:SetSize(80, 120)
    deckZone:SetPos(x, y)
    deckZone:SetText("")
    deckZone.Paint = function(self, w, h)
            local card = GetCardFromPlayer(player, zone, index) -- Replace with the actual function to get the card
    if card then
      surface.SetDrawColor(255, 255, 255, 255)
      surface.SetMaterial(GetCardImageMaterial(card.imagePath))
      surface.DrawTexturedRect(0, 0, w, h)
    end
    end

    return deckZone
end

function CreateExtraDeckZone(player, parentPanel, x, y)
    local extraDeckZone = vgui.Create("DButton", parentPanel)
    extraDeckZone:SetSize(80, 120)
    extraDeckZone:SetPos(x, y)
    extraDeckZone:SetText("")
    extraDeckZone.Paint = function(self, w, h)
          local card = GetCardFromPlayer(player, zone, index) -- Replace with the actual function to get the card
    if card then
      surface.SetDrawColor(255, 255, 255, 255)
      surface.SetMaterial(GetCardImageMaterial(card.imagePath))
      surface.DrawTexturedRect(0, 0, w, h)
    end
    end

    return extraDeckZone
end

function CreateGraveyardZone(player, parentPanel, x, y)
    local graveyardZone = vgui.Create("DButton", parentPanel)
    graveyardZone:SetSize(80, 120)
    graveyardZone:SetPos(x, y)
    graveyardZone:SetText("")
    graveyardZone.Paint = function(self, w, h)
            local card = GetCardFromPlayer(player, zone, index) -- Replace with the actual function to get the card
    if card then
      surface.SetDrawColor(255, 255, 255, 255)
      surface.SetMaterial(GetCardImageMaterial(card.imagePath))
      surface.DrawTexturedRect(0, 0, w, h)
    end
    end

    return graveyardZone
end

function GetCardImageMaterial(imagePath)
    return Material(imagePath)
end

function GetCardFromPlayer(player, zone, index)
    if not IsValid(player) then return nil end
    local cardsJSON = player:GetNWString("Cards")
    if cardsJSON ~= "" then
        local cards = util.JSONToTable(cardsJSON)
        if cards and cards[zone] and cards[zone][index] then
            return cards[zone][index]
        end
    end
    return nil	
end

	
function CreateHandZone(player, parentPanel, width, height, xPos, yPos)
    local handZone = vgui.Create("DPanel", parentPanel)
    handZone:SetSize(width, height)
    handZone:SetPos(xPos, yPos)
    handZone.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 100))
    end

    -- Get player hand cards data from the server
    local playerHandCards = player:GetNWVarTable("Hand")

    -- Loop through the player's hand cards and create a card panel for each card
    for i, card in ipairs(playerHandCards) do
        local cardPanel = vgui.Create("DPanel", handZone)
        cardPanel:SetSize(50, 70) -- Set the card size
        cardPanel:SetPos((i - 1) * 55, 0) -- Set the card position
        cardPanel.Paint = function(self, w, h)
            -- Draw the card here
            draw.RoundedBox(0, 0, 0, w, h, Color(255, 0, 0, 255))
            draw.SimpleText(card.name, "default", w / 2, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    return handZone
end






-- cl_init.lua

local function UpdatePlayingFieldForAllPlayers()
    for _, ply in ipairs(player.GetAll()) do
        local handZone = GetHandZoneForPlayer(ply)
        local fieldZone = GetFieldZoneForPlayer(ply)
        local graveyardZone = GetGraveyardZoneForPlayer(ply)

        UpdatePlayingField(ply, handZone, fieldZone, graveyardZone)
    end
end

timer.Create("UpdatePlayingFieldTimer", 1, 0, UpdatePlayingFieldForAllPlayers)


function RemoveCardFromHand(ply, cardIndex)
    if not IsValid(ply) then
        print("Error: Player object is not valid.")
        return
    end

    local hand = ply:GetNW2Table("Hand")
    if hand == nil then
        print("Error: Networked Variables not accessible.")
        return
    end

    if hand[cardIndex] then
        table.remove(hand, cardIndex)
        ply:SetNW2Table("Hand", hand)
    end
end


function AddCardToHand(ply, card)
    if not IsValid(ply) then
        print("Error: Player object is not valid.")
        return
    end

    local hand = ply:GetNW2Table("Hand")
    if hand == nil then
        print("Error: Networked Variables not accessible.")
        return
    end

    table.insert(hand, card)
    ply:SetNW2Table("Hand", hand)
end

net.Receive("BeginDuel", function(len)
    local duelPanel = ShowDuelPanel()

    if duelPanel then
        local playingField = CreatePlayingField(duelPanel)

        -- Draw 5 cards for each player at the beginning of the duel
        local yourPlayer = LocalPlayer()
        local opponent = GetOpponent(yourPlayer)

        for i = 1, 5 do
            DrawCard(yourPlayer)
            DrawCard(opponent)
        end
    end
end)


function DrawCard(player)
    local duel_data = GetDuelData(player)

    if duel_data and duel_data.deck and #duel_data.deck > 0 then
        local card_name = table.remove(duel_data.deck, 1)
        table.insert(duel_data.hand, card_name)
        SetDuelData(player, duel_data)
        return card_name
    else
       -- PrintToConsole("DrawCard: Deck is empty or nil for player " .. player:GetName())
       -- PrintDuelData(player)
        return nil
    end
end




function LoadCardTextures()
    cardTextures = {}
    local cardFiles, _ = file.Find("materials/card_images/*.jpg", "GAME")
    PrintTable(cardFiles)
    for _, cardFile in ipairs(cardFiles) do
        local cardName = string.gsub(cardFile, ".jpg", "")
        local cardMaterialPath = "card_images/" .. cardFile
        local cardMaterial = Material(cardMaterialPath, "noclamp smooth")
        cardTextures[cardName] = cardMaterial
        print("Loaded card texture: " .. cardMaterialPath)
    end
    print("Loaded card textures: " .. table.Count(cardTextures))
end






function DrawHand(ply)
    local hand = GetPlayerHand(ply)
    local handSize = #hand

    if handSize > 0 then
        local cardWidth = 100
        local cardHeight = 150
        local cardSpacing = 20
        local handWidth = handSize * cardWidth + (handSize - 1) * cardSpacing
        local startX = (ScrW() - handWidth) / 2
        local startY = ScrH() - cardHeight - 30

        for i, card in ipairs(hand) do
            local xPos = startX + (i - 1) * (cardWidth + cardSpacing)
            print("Drawing card at position:", xPos, startY)
            DrawCard(card, xPos, startY, cardWidth, cardHeight)
        end
    end
end

hook.Add("InitPostEntity", "LoadCardTexturesOnInit", function()
    LoadCardTextures()
end)

hook.Add("UpdateCardPositions", "UpdateCardPositionsOnDraw", function()
    local player = LocalPlayer()
    local duelData = GetDuelData(player)
    local hand = duelData.Hand
    UpdateHandPositions(hand)
end)

function RenderCards()
print("cl_init.lua: Rendering cards for player", LocalPlayer():Nick())

    local ply = LocalPlayer()
    if not ply or not ply:IsValid() then return end

    local duelDataJSON = ply:GetNWString("DuelData")
    local duelData = duelDataJSON and duelDataJSON ~= "" and util.JSONToTable(duelDataJSON) or nil
print("cl_init.lua: DuelData JSON:", localPlayer:GetNWString("duelDataJson", ""))

    if not duelData then return end

    local hand = duelData.Hand
    if not hand then return end

    for i, cardID in ipairs(playerHand) do
        local card = Cards[cardID]
        if not card then
            print("Invalid card ID:", cardID)
            return
        end

        local cardTexture = CardTextures[card.image]
        if not cardTexture then
            print("Missing card texture for card ID:", cardID)
            return
        end

        local cardPos, cardAngles = GetCardPositionAndAngles(i)

        render.SetMaterial(cardTexture)
        render.DrawQuadEasy(cardPos, Vector(0, 0, 1), CARD_WIDTH, CARD_HEIGHT, Color(255, 255, 255), cardAngles.yaw)
    end
end

local HAND_DISTANCE = 100
local HAND_HEIGHT = 100
local HAND_ANGLE_OFFSET = 15

function GetCardPositionAndAngles(index)
    local localPlayer = LocalPlayer()
    if not localPlayer then return end

    local eyeAngles = localPlayer:EyeAngles()

    local cardAngles = Angle(0, eyeAngles.yaw + 90, 90)
    local cardPosition = localPlayer:GetShootPos()
        + localPlayer:GetForward() * HAND_DISTANCE
        + localPlayer:GetUp() * HAND_HEIGHT
        + localPlayer:GetRight() * ((index - 1) * CARD_WIDTH - HAND_ANGLE_OFFSET * (index - 1))

    return cardPosition, cardAngles
end


function GM:HUDPaint()
    local ply = LocalPlayer()
    local duelData = ply:GetDuelData()

    if duelData.hand then
        for i, card in ipairs(duelData.hand) do
            local x, y = (i - 1) * 110, ScrH() - 200
            draw.SimpleText(card, "Trebuchet24", x, y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end
end




hook.Add("HUDPaint", "RenderCardsOnHUD", function()
    local ply = LocalPlayer()
    if not ply or not ply:IsValid() then return end

    local duelData = ply:GetDuelData()

    if not duelData then return  end
	

    --print("HUDPaint: DuelData for player " .. ply:Nick())
    PrintTable(duelData)

    if not duelData then
        print("cl_init.lua: Duel data is nil")
        return
    end

    local hand = duelData.Hand

    if not hand then
       -- print("cl_init.lua: Hand is nil")
        return
    end

    for _, cardID in ipairs(hand) do
        local card = cardTextures[cardID]
        if card then
            -- Here you should use the GetCardPositionAndAngles function
            -- to get the position and angles for the card and draw it on the HUD
        end
    end
end)



hook.Add("PostDrawOpaqueRenderables", "DrawCards", function()
    local ply = LocalPlayer()
    if not ply or not ply:IsValid() then return end

    local duelData = ply:GetDuelData()
    if not duelData then
        print("cl_init.lua: Duel data is nil")
        return
    end

    local hand = duelData.Hand
    if not hand then
      --  print("cl_init.lua: Hand is nil")
        return
    end

    for _, cardID in ipairs(hand) do
        local card = cardTextures[cardID]
        if card then
            card:Draw()
        end
    end
end)

function GetCardImagePath(cardName)
    return "yugioh_gamemode/materials/card_images/" .. cardName .. ".jpg"
end


hook.Add("PlayerInitialSpawn", "InitializeZonesOnInitialSpawn", function(ply)
    if CLIENT then
        InitializePlayerZones(ply)
    end
end)

function GM:BeginTurn()
    local ply = LocalPlayer()
    local duelData = GetDuelData(ply)
    
    if duelData then
        local currentPlayer = duelData.CurrentPlayer
        local opponent = duelData.Opponent

        if currentPlayer == ply:EntIndex() then
            DrawCard(ply)
            print("Performing turn for " .. ply:Nick())
        elseif opponent == ply:EntIndex() then
            print("Waiting for opponent's turn...")
        end
    end
end


function InitializePlayerZones(ply)
    local duelData = {
        hand = {},
        monsterZones = {},
        spellTrapZones = {},
        fieldZone = {},
        graveyard = {},
        banished = {},
        extraDeck = {},
        mainDeck = {}
    }

    for i = 1, 5 do
        duelData.monsterZones[i] = "Empty"
        duelData.spellTrapZones[i] = "Empty"
    end

    for i = 1, 40 do
        duelData.mainDeck[i] = "Main " .. i
    end

    for i = 1, 15 do
        duelData.extraDeck[i] = "Extra " .. i
    end

    for i = 1, 6 do
        duelData.hand[i] = "Hand " .. i
    end

    duelData.fieldZone = "Empty"
    duelData.graveyard = "Empty"
    duelData.banished = "Empty"

    ply:SetDuelData(duelData)
end
