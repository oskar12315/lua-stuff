local BulletFunction = Game.Bullet.CreateBullet 

    Hooks:Create(BulletFunction, LPH_JIT_MAX(function(Old, ...)
        local Args = {...};

        local AimpartKey

        for Key, Value in Args do
            if typeof(Value) == "Instance" and string.lower(Value.Name) == "aimpart" then
                AimpartKey = Key
            end

            if type(Value) == "string" then
                local Temp = ReplicatedStorage.AmmoTypes:FindFirstChild(Value)

                if Temp then
                    Player.LoadedAmmo = Temp 
                end
            end
        end

        if not AimpartKey then
            return Old(table.unpack(Args))
        end

        if flags["Aimbot"] and flags["Aimbot Mode"] == "Silent" and TargetPart then
            local Origin = Camera.CFrame.Position
            local Destination = TargetPart.Position

            Args[AimpartKey] = {
                    ClassName = "Part",
                    CFrame = CFrame.new(Origin, Destination)
                }
            end
        end

        return Old(table.unpack(Args))
    end))
