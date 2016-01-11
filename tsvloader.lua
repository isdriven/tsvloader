--[[ 
---------------------- 
  tsvloader
----------------------
 Author: isdriven
 Licence: MIT
 
]]-- 

module("tsvloader", package.seeall)

FETCHNG_TITLE = 1
FETCHNG_BODY = 2
FETCHNG_MULTI = 3

local mode = FETCHNG_TITLE
local delimiter = "\t"
local rows = {}
local line = {}
local titles = {}
local column = 1
local pos = 1
local after_delimiter = false
local tmp_body = ""

function seek(text)
  from = pos
  local text_len = #text
  if from >= #text then
    if titles[column] ~= nil then
      line[titles[column]] = table.concat({tmp_body,ret_body},"")
    end
    table.insert(rows, line)
    return false 
  end
  local q = string.find(text, '"', from, true)
  local d = string.find(text,delimiter, from)
  local n = string.find(text,"\n", from)

  if q == nil then q = text_len end
  if d == nil then d = text_len end
  if n == nil then n = text_len end
  
  local positions = {q,d,n}
  
  table.sort(positions)
  local f = positions[1]
  local ret_body = ""

  if f == nil then
    f = #text
  end
  
  pos = f + 1
  ret_body = string.sub(text,from,f-1)

  if mode == FETCHNG_TITLE then
    -- in title, no '"'
    if f == d then
      table.insert(titles, ret_body)
    elseif f == n then
      table.insert(titles, ret_body)
      mode = FETCHNG_BODY
    end
  elseif mode == FETCHNG_BODY then
    if f == d then
      if titles[column] ~= nil then
	line[titles[column]] = table.concat({tmp_body,ret_body},"")
	tmp_body = ""
	column = column + 1
	if f + 1 == q then
	  pos = pos + 1
	  mode = FETCHNG_MULTI
	end
      end
    elseif f == n then
      if titles[column] ~= nil then
	line[titles[column]] = table.concat({tmp_body,ret_body},"")
      end
      tmp_body = ""
      column = 1
      table.insert(rows, line)
      line = {}
    end
  elseif mode == FETCHNG_MULTI then
    -- see next quote
    f = q
    tmp_body = string.sub(text, from, q-1)
    mode = FETCHNG_BODY
    pos = f + 1
  end
end

function dump(self)
  local rows = self.rows
  local ret = {} 
  for _,v in ipairs( rows ) do
    for _,key in pairs(self.keys) do
      table.insert(ret,string.format("  %s=%s", key, v[key]))
     end

    table.insert(ret,"----\n")
  end
  return table.concat(ret,"\n")
end

function wrap(row, keys)
  local t =  {
    rows={row},
    keys=keys,
    dump=dump
  }
  local mt = {
    __index = row
  }
  setmetatable(t,mt)
  return t
end

function find_by(self, name, key)
  local ret = {}
  if self.index_sorted[name] == nil then
    for k,v in pairs(self.rows) do
      ret[tostring(v.id)] = v
    end
    self.index_sorted[name] = ret
  end
  local ret2 = self.index_sorted[name][tostring(key)]
  if ret2 == nil then
    return nil
  else
    return wrap(ret2,self.keys)
  end
end

function load( text )
  -- initialize
  mode = FETCHNG_TITLE
  rows = {}
  line = {}
  titles = {}
  column = 1
  pos = 1
  after_delimiter = false
  tmp_body = ""
  
  while true do
    if seek(text) == false then
      break
    end
  end

  return {
    rows=rows,
    dump=dump,
    keys=titles,
    length=#rows,
    index_sorted={},
    find_by=find_by,
    first=wrap(rows[1], titles),
    last=wrap(rows[#rows],titles),
  }
end
 
