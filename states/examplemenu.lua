local gui = require "Quickie"

local ExampleMenuClass = {}

local menu_open = {
    main  = false,
    right = false,
    foo   = false,
    demo  = false
}
local check1   = false
local check2   = false
local input    = {text = ""}
local slider   = {value = .5}
local slider2d = {value = {.5,.5}}


function ExampleMenuClass:new ()
	local newInstance = {}

	-- group defaults
	gui.group.default.size[1] = 150
	gui.group.default.size[2] = 25
	gui.group.default.spacing = 5


	self.__index = self
	return setmetatable(newInstance, self)
end


function ExampleMenuClass:update (dt)
    gui.group.push{grow = "down", pos = {5,5}}

    -- all widgets return true if they are clicked on/activated
    if gui.Checkbox{checked = menu_open.main, text = "Show Menu"} then
        menu_open.main = not menu_open.main
    end

    if menu_open.main then
        gui.group.push{grow = "right"}

        -- widgets can have custom ID's for tooltips etc (see below)
        if gui.Button{id = "group stacking", text = "Group stacking"} then
            menu_open.right = not menu_open.right
        end

        if menu_open.right then
            gui.group.push{grow = "up"}
            if gui.Button{text = "Foo"} then
                menu_open.foo = not menu_open.foo
            end
            if menu_open.foo then
                gui.Button{text = "???"}
            end
            gui.group.pop{}

            gui.Button{text = "Bar"}
            gui.Button{text = "Baz"}
        end
        gui.group.pop{}

        if gui.Button{text = "Widget demo"} then
            menu_open.demo = not menu_open.open
        end

    end
    gui.group.pop{}

    if menu_open.demo then
        gui.group{grow = "down", pos = {200, 80}, function()
            love.graphics.setFont(fonts[20])
            gui.Label{text = "Widgets"}
            love.graphics.setFont(fonts[12])
            gui.group{grow = "right", function()
                gui.Button{text = "Button"}
                gui.Button{text = "Tight Button", size = {"tight"}}
                gui.Button{text = "Tight² Button", size = {"tight", "tight"}}
            end}

            gui.group{grow = "right", function()
                gui.Button{text = "", size = {2}} -- acts as separator
                gui.Label{text = "Tight Label", size = {"tight"}}
                gui.Button{text = "", size = {2}}
                gui.Label{text = "Center Label", align = "center"}
                gui.Button{text = "", size = {2}}
                gui.Label{text = "Another Label"}
                gui.Button{text = "", size = {2}}
            end}

            gui.group.push{grow = "right"}
            if gui.Checkbox{checked = check1, text = "Checkbox", size = {"tight"}} then
                check1 = not check1
                print(check1)
            end
            if gui.Checkbox{checked = check2, text = "Another Checkbox"} then
                check2 = not check2
            end
            if gui.Checkbox{checked = check2, text = "Linked Checkbox"} then
                check2 = not check2
            end
            gui.group.pop{}

            gui.group{grow = "right", function()
                gui.Label{text = "Input", size = {70}}
                gui.Input{info = input, size = {300}}
            end}

            gui.group{grow = "right", function()
                gui.Label{text = "Slider", size = {70}}
                gui.Slider{info = slider}
                gui.Label{text = ("Value: %.2f"):format(slider.value), size = {70}}
            end}

            gui.Label{text = "2D Slider", pos = {nil,10}}
            gui.Slider2D{info = slider2d, size = {250, 250}}
            gui.Label{text = ("Value: %.2f, %.2f"):format(slider2d.value[1], slider2d.value[2])}
        end}
    end

    -- tooltip (see above)
    if gui.mouse.isHot('group stacking') then
        local mx,my = love.mouse.getPosition()
        gui.Label{text = 'Demonstrates group stacking', pos = {mx+10,my-20}}
    end
end

function ExampleMenuClass:draw(dt)
	gui.core.draw()
end

function ExampleMenuClass:keypressed(key)
    gui.keyboard.pressed(key)
end

return ExampleMenuClass

