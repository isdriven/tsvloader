#!/usr/local/bin/lua

require("tsvloader")

local tsv = tsvloader.load_from_file("tests.tsv")
local tsv2 = tsvloader.load_from_file("tests2.tsv")

--[[
print(tsv:index(1).name)
print(tsv:index(2).name)
print(tsv2:first().name)
print(tsv2:last().name)
]]--

while tsv2:has_next() do
  print("name: "..tsv2:value().name)
  print('---')
end

while tsv2:has_next() do
  print("description: "..tsv2:value().description)
  print('---')
end
