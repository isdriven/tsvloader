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

function seek(text, titles, rows)
  from = pos
  local text_len = #text
  if from >= #text then
    if titles[column] ~= nil then
      line[titles[column]] = refine(table.concat({tmp_body,ret_body},""))
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
	line[titles[column]] = refine(table.concat({tmp_body,ret_body},""))
	tmp_body = ""
	column = column + 1
	if f + 1 == q then
	  pos = pos + 1
	  mode = FETCHNG_MULTI
	end
      end
    elseif f == n then
      if column == 1 then -- expect nil rows
	return false
      end
      if titles[column] ~= nil then
	line[titles[column]] = refine(table.concat({tmp_body,ret_body},""))
      end
      tmp_body = ""
      column = 1
      table.insert(rows, line)
      line = {}
    elseif f == q then
      tmp_body = tmp_body..string.sub(text, from, q)
      pos = f + 1
    end
  elseif mode == FETCHNG_MULTI then
    -- see next quote with next delimiter
    next_d = string.find(text,delimiter,q)
    next_n = string.find(text,"\n",q)
    
    if (q + 1 == next_d ) or ( q + 1 == next_n ) then
      f = q
      tmp_body = tmp_body..string.sub(text, from, q-1)
      mode = FETCHNG_BODY
      pos = f + 1
    else
      tmp_body = tmp_body..string.sub(text, from, q)
      pos = f + 1
    end
  end
end

function refine(text)
  return string.gsub(text,'""', '"')
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

function index(self, index)
  return wrap(self.rows[index], self.keys)
end

function first(self)
  return self:index(1)
end

function last(self)
  return self:index(self.length)
end

function rewind(self)
  self.pos = 0
end

function has_next(self)
  if self.pos + 1 <= self.length then
    self.pos = self.pos + 1
    return true
  else
    self:rewind()
    return false
  end
end

function value(self)
  return self:index(self.pos)
end

function load_from_file(file_name)
  local f = io.open(file_name)
  if f == nil then
    io.write("Error: no sush file:"..file_name.."\n")
    return false
  end
  
  local text = f:read("*a")

  return load(text)
end

function load( text )
  -- initialize
  mode = FETCHNG_TITLE
  local rows = {}
  local titles = {}
  line = {}
  column = 1
  pos = 1
  after_delimiter = false
  tmp_body = ""
  
  while true do
    if seek(text, titles, rows) == false then
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
    first=first,
    last=last,
    index=index,
    has_next=has_next,
    value=value,
    rewind=rewind,
    pos=0,
  }
end
 
