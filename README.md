## tsvloader

tsv loader in pure lua.
you can load tsv data sush as

    id	name	description
    1	ever white	"the ""dragon"", 
    the best creature in the world"
    2	shining "black"	other ways
    3	bloody blue	other ways

usage:
------
    require("tsvloader")

    -- load from file
    local tsv = tsvloader.load_from_file("tests.tsv")
    local tsv2 = tsvloader.load_from_file("tests2.tsv")

    -- pick from index
    print(tsv:index(1).name)
    print(tsv:index(2).name)

    -- first or last
    print(tsv2:first().name)
    print(tsv2:last().name)

    -- sure, use while loop
    while tsv2:has_next() do
      print("name: "..tsv2:value().name)
    end

usage: in Japanese
------

- これは何?
  - Google Spread Sheetなどから転写したデータファイルをそのままの形で読み込むことを実現するものです。

- 特徴
  - 改行混じりの説明文や、改行ではない「",',`,?」などの特殊文字入りの文章を含むtsvを問題なく読み込む事が出来ます。
  - キーで検索できる
  - キーでデータを参照できる
  - while loop で回すことができる


