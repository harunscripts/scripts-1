if _G.Enabled then
    repeat wait() until game:IsLoaded()
    repeat wait() until game.Players.LocalPlayer.PlayerGui:FindFirstChild("playerStatus")

    if _G.Options.Name then
        game.Players.LocalPlayer.PlayerGui.playerStatus.Frame.playerName.Text = _G.CustomSettings.Name or "script by vozoid/Zinzox"
    end

    if _G.Options.Level then
        game.Players.LocalPlayer.PlayerGui.playerStatus.Frame.levelBorder.level.Text =  _G.CustomSettings.Level or ""
    end

    if _G.Options.XP then
        game.Players.LocalPlayer.PlayerGui.playerStatus.Frame.xpFrame.xpUpdater:Destroy()
        game.Players.LocalPlayer.PlayerGui.playerStatus.Frame.xpFrame.xp.Text = _G.CustomSettings.XP or ""
    end

    if _G.Options.Health then
        game.Players.LocalPlayer.PlayerGui.playerStatus.Frame.healthFrame.healthUpdater:Destroy()
        game.Players.LocalPlayer.PlayerGui.playerStatus.Frame.healthFrame.health.Text = _G.CustomSettings.Health or ""
    end

    if _G.Options.Coins then
        game.Players.LocalPlayer.PlayerGui.playerStatus.Frame.moneyMain.updateMoney:Destroy()
        game.Players.LocalPlayer.PlayerGui.playerStatus.Frame.moneyMain.TextLabel.Text = _G.CustomSettings.Coins or ""
    end

    if _G.Options.ProfilePicture then
        game.Players.LocalPlayer.PlayerGui.playerStatus.Frame.portraitBorder.portrait.Image = _G.CustomSettings.ProfilePicture or ""
    end

    repeat wait() until game.Players.LocalPlayer.Character:FindFirstChild("playerNameplate")

    if _G.Options.Name then
        game.Players.LocalPlayer.Character.playerNameplate:Destroy()
    end
end
