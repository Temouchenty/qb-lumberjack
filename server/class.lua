function CreatePlayer(Id, CitizenId, data)
	local self = {}

    self.source = Id
	self.CitizenId = CitizenId

    if data ~= false then
        self.level = data.level
        self.action = data.action
    else
        self.level = 1
        self.action = 0
    end

    self.newAction = function()
        if self.level < 3 then
            if self.action >= 99 then
                self.level = self.level + 1
                self.action = 0
                TriggerClientEvent("qb-lumberjack:onLevelUpdate", self.source, self.level)
            else
                self.action = self.action + 1
            end
        end
	end

    TriggerClientEvent("qb-lumberjack:onPlayerLoaded", self.source, self.level)

	return self
end