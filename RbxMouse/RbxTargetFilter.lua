local methods = {} do
    local filterTable = {}

    methods.Set = function(self, object)
        if typeof(object) == "table" then
            filterTable = object
        else
            filterTable = {object}
        end
    end

    methods.Get = function()
        return filterTable
    end

    methods.Add = function(self, object)
        for index = 1, #filterTable do
            if object == filterTable[index] then
                return
            end
        end
        table.insert(filterTable, object)
    end

    methods.Remove = function(self, object)
        for index = 1, #filterTable do
            if object == filterTable[index] then
                table.remove(filterTable, index)
                break
            end
        end
    end
end

local RbxTargetFilter = {} do
    setmetatable(RbxTargetFilter, {
        __index = function(self, index)
            local method = methods[index]
            if method then return method end

            error(tostring(index).. " is not a valid member of RbxTargetFilter")
        end,
        __newindex = function() end
    })
end

return RbxTargetFilter
