#!/usr/bin/env lua
--  Copyright (c) 2016 Francois Perrad

local f = arg[1] and assert(io.open(arg[1], 'r')) or io.stdin
local src = string.gsub(f:read'*a', '[^><+%-%.,%[%]]', '')
local len = string.len(src)
f:close()
io.stdout:setvbuf'no'

local stack = {}
local jump = {}
local pat = {
    ['<'] = '<+',
    ['>'] = '>+',
    ['+'] = '++',
    ['-'] = '-+',
    ['['] = '%[',
    [']'] = '%]',
    ['.'] = '%.',
    [','] = ',',
}
local nb = {}
local code = {}
for pc = 1, len do
    local opcode = src:sub(pc, pc)
    code[pc] = opcode
    nb[pc] = src:match(pat[opcode], pc):len()
    if opcode == '[' then
        stack[#stack+1] = pc
    elseif opcode == ']' then
        local target = stack[#stack]
        stack[#stack] = nil
        jump[target] = pc
        jump[pc] = target
    end
end
src = nil
stack = nil

local buffer = setmetatable({}, {
    __index = function ()
        return 0    -- default value
    end
})

local ptr = 1
local pc = 1
while pc <= len do
    local opcode = code[pc]
    local n = nb[pc]
    if opcode == '>' then
        ptr = ptr + n
    elseif opcode == '<' then
        ptr = ptr - n
    elseif opcode == '+' then
        buffer[ptr] = buffer[ptr] + n
    elseif opcode == '-' then
        buffer[ptr] = buffer[ptr] - n
    elseif opcode == '.' then
        io.stdout:write(string.char(buffer[ptr]))
    elseif opcode == ',' then
        buffer[ptr] = string.byte(io.stdin:read(1) or '\0')
    elseif opcode == '[' then
        if buffer[ptr] == 0 then
            pc = jump[pc]
        end
    elseif opcode == ']' then
        if buffer[ptr] ~= 0 then
            pc = jump[pc]
        end
    end
    pc = pc + n
end
