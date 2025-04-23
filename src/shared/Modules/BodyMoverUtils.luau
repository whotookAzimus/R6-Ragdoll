local Debris = game:GetService("Debris")

local BodyMoverUtils = {}

function BodyMoverUtils.CreateLinearVelocity(data: {
    Lifetime: number,
    Attachment: Attachment,
    MaxForce: number,
    Name: string?,
})
    local linearVelocity = Instance.new("LinearVelocity")
    linearVelocity.Name = data.Name or "LinearVelocity"
    linearVelocity.MaxForce = data.MaxForce
    linearVelocity.Attachment0 = data.Attachment
    linearVelocity.Parent = data.Attachment

    Debris:AddItem(linearVelocity, data.Lifetime)

    return linearVelocity
end

function BodyMoverUtils.CreateAngularVelocity(data: {
    Lifetime: number,
    Attachment: Attachment,
    MaxTorque: number,
    Name: string?,
})
    local angularVelocity = Instance.new("AngularVelocity")
    angularVelocity.Name = data.Name or "AngularVelocity"
    angularVelocity.MaxTorque = data.MaxTorque
    angularVelocity.Attachment0 = data.Attachment
    angularVelocity.Parent = data.Attachment

    Debris:AddItem(angularVelocity, data.Lifetime)

    return angularVelocity
end

return BodyMoverUtils