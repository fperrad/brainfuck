#!/usr/bin/env lua
--  Copyright (c) 2016 Francois Perrad

local f = arg[1] and assert(io.open(arg[1], 'r')) or io.stdin
local src = f:read'*a'
f:close()
io.stdout:setvbuf'no'

local code = {}
for i = 1, #src do
    code[i] = src:sub(i, i)
end
src = nil

local buffer = setmetatable({}, {
    __index = function ()
        return 0    -- default value
    end
})

local ptr = 1
local pc = 1
local incr = 1
local level = 0
local len = #code
while pc <= len do
    local opcode = code[pc]
    if level ~= 0 then
        if opcode == '[' then
            level = level + incr
        elseif opcode == ']' then
            level = level - incr
        end
        if level == 0 then
            incr = 1
        end
--[[
        print('pc', pc, 'opcode', opcode, 'incr', incr, 'level', level)
--]]
    else
        if opcode == '>' then
            ptr = ptr + 1
        elseif opcode == '<' then
            ptr = ptr - 1
        elseif opcode == '+' then
            buffer[ptr] = buffer[ptr] + 1
        elseif opcode == '-' then
            buffer[ptr] = buffer[ptr] - 1
        elseif opcode == '.' then
            io.stdout:write(string.char(buffer[ptr]))
        elseif opcode == ',' then
            buffer[ptr] = string.byte(io.stdin:read(1) or '\0')
        elseif opcode == '[' then
            if buffer[ptr] == 0 then
                level = 1
                incr = 1
            end
        elseif opcode == ']' then
            if buffer[ptr] ~= 0 then
                level = 1
                incr = -1
            end
        end
--[[
        print('pc', pc, 'opcode', opcode, 'ptr', ptr, 'buffer', table.concat(buffer, ' '))
--]]
    end
    pc = pc + incr
end
