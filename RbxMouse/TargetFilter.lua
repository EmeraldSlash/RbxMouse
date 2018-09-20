local TargetFilter = {} do
    filterTable = {}

    targetFilter.Set = function(self, object)
        if typeof(object) == "table" then
            filterTable = object
        else
            filterTable = {object}
        end
    end

    targetFilter.Add = function(self, object)
        for index = 1, #filterTable do
            if object == filterTable[index] then
                return
            end
        end
        table.insert(filterTable, object)
    end

    targetFilter.Remove = function(self, object)
        for index = 1, #filterTable do
            if object == filterTable[index] then
                table.remove(filterTable, index)
                break
            end
        end
    end

    targetFilter.Get = function(self)
        return filterTable
    end
end

return TargetFilter
