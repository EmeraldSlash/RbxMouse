local Signal = {} do
    Signal.new = function()
        local newSignal = Instance.new("BindableEvent")
        return newSignal
    end
end

return Signal
