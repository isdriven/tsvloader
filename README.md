# tsvloader
tsv loader in pure lua.
========================= 

you can load tsv data sush as

    id	name	description
    1	name1	"description is 
    here with ..."
    2	name2	description here!!!

usage:
------

    local tl = require("tsvloader")
    local io = require("io")

    local f = io.open("data.tsv", "r")
    local text = f:read("*a")
    f:close()

    local tsv =  tl.load(text)

    local row = tsv:find_by("id", 10219)
    local first = tsv.first
    local last = tsv.last
    
    print(last:dump())
    
    print(last.name)

