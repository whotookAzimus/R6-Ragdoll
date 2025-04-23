local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player: Player)
    player.CharacterAppearanceLoaded:Connect(function(character: Model)
        for _, instance in character:GetDescendants() do
            if instance:IsA("BasePart") then
                instance.CollisionGroup = "Player"
            end
        end
    end)
end)