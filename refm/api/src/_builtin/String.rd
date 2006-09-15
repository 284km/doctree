= class String < Object

include Comparable
include Enumerable

文字列クラス。任意の長さのバイト列を扱うことができます。

このクラスのメソッドのうち名前が ! で終るものは文字列の中身を
直接変更します。このような場合は ! のついていない同じ名前の
メソッドを使うほうが概して安全です。たとえば以下のような場合に問題に
なることがあります。

  def foo(arg)
    arg.sub!(/good/, 'bad')
    arg
  end

  s = 'verygoodname'
  p foo(s)  # => 'verybadname'
  p s       # => 'verybadname'

また日本語文字列を正しく処理するためには
組み込み変数 [[m:$KCODE]] を
文字コードにあわせて設定しておく必要があります。
#@# あらい 2002-01-24: 覚書: $KCODE の影響はほとんどの場合 String よりも
#@# Regexp に対して。String に影響を与える部分として何がある
#@# かを書くこと。「Shift_JIS の 2 バイト目に \ が含まれても正しく扱う」
#@# (←これは String というより字句解析器)、
#@# upcase, downcase, swapcase, capitalize, inspect, split, gsub, scan は、
#@# $KCODE を設定すれば、日本語を意識して正しく処理する。(どのように影響
#@# するか書くこと)-))
#@# あらい 2002-01-24: inspect は、漢字をバックスラッシュ記法の8進で表
#@# 示するか、漢字で表示するかの違い。gsub, scan は、実装の都合で漢字を意
#@# 識しているのであくまでも Regexp が漢字を認識しているのだという理解で良
#@# いと思う。split は、split('') の処理がバイト単位か文字単位かの違い。
#@# もうちょい調べること-))

String クラスは自身をバイト列として扱います。
例えば str[1] は str の内容がなんであれ 2 バイト目の文字コードを返します。
日本語文字列に対して, バイト単位でなく文字単位の処理を行わせたい場合は
[[lib:jcode]] を使用します。

== Class Methods

--- new([string])

string と同じ内容の新しい文字列を作成して返します。
引数を省略した場合は空文字列を生成して返します。

== Instance Methods

--- +(other)

文字列を連結した新しい文字列を返します。

例:

  a = "abc"
  b = "def"
  p a + b   # => "abcdef"
  p a       # => "abc"  (変化なし)
  p b       # => "def"

--- *(times)

文字列の内容を times 回だけ繰り返した新しい文字列を作成して
返します。

例:

  str = "abc"
  p str * 4   #=> "abcabcabcabc"
  p str       #=> "abc"  (変化なし)

--- %(args)

文字列のフォーマット。引数をフォーマット文字列 self で書式化
した文字列を返します。

args が配列であれば sprintf(self, *args) と同じです。
それ以外の場合は、 sprintf(self, args) と同じです。

例:

  p "%#x"     % 10        # => "0xa"
  p "%#x,%#o" % [10, 10]  # => "0xa,012"

#@# 詳細は ((<sprintfフォーマット>))を参照してください。
#@include(printf-format)

--- ==(other)
--- >(other)
--- >=(other)
--- <(other)
--- <=(other)

文字列の比較。

変数 [[m:$=]] の値が真である時、
比較はアルファベットの大文字小文字を無視して行われます。
($= 変数はいずれ廃止されることになっています ((<obsolete>)) を参照)

--- <<(other)
--- concat(other)

文字列 other の内容を self に連結します
(self の内容が変更されます)。
other が 0 から 255 の範囲の [[c:Fixnum]] である場合は
その 1 バイトを末尾に追加します。

self を返します。

--- =~(other)

正規表現 other とのマッチを行います。マッチが成功すればマッ
チした位置のインデックスを、そうでなければ nil を返します。

組み込み変数 [[m:$~]], [[m:$1]], ...
にマッチに関する情報が設定されます。

other が正規表現でも文字列でもない場合は
other =~ self を行います。

#@if (version >= "1.8.0")
以前までは、other が文字列であった場合には
これを正規表現にコンパイルして self に対するマッチを行っていました。
Ruby 1.8 以降は、 other に文字列を指定したときには
例外 [[c:TypeError]] が発生します。
#@end

--- ~

#@if (version >= "1.8.0")
このメソッドは削除されました。
代わりに [[m:Regexp#~]] などを使用してください。
#@else
self を正規表現にコンパイルして、
組み込み変数 $_ に対してマッチを行い
マッチした位置のインデックスを返します。
$_ =~ Regexp.compile(self) と同じです。

$_ が文字列でなければ nil を返します。
#@end

--- [](nth)

nth 番目のバイトを整数 (文字コード) で返します
(逆に文字コードから文字列を得るには [[m:Integer#chr]] を使います)。
nth が負の場合は文字列の末尾から数えます。

nth が範囲外を指す場合は nil を返します。

例:

  p 'bar'[2]        # => 114
  p 'bar'[2] == ?r  # => true
  p 'bar'[-1]       # => 114

  p 'bar'[3]        # => nil
  p 'bar'[-4]       # => nil

--- [](nth, len)

nth バイト番目から長さ len バイトの部分文字列を新しく作って返します。
nth が負の場合は文字列の末尾から数えます。

nth が範囲外を指す場合は nil を返します。

例:

  str0 = "bar"
  p str0[2, 1]         #=> "r"
  p str0[2, 0]         #=> ""
  p str0[2, 100]       #=> "r"  (右側を超えても平気)
  p str0[2, 1] == ?r   #=> false  (左辺は長さ1の文字列、右辺は整数の文字コード)
  p str0[-1, 1]        #=> "r"
  p str0[-1, 2]        #=> "r" (飽くまでも「右に向かって len バイト」)

  p str0[3, 1]         #=> nil
  p str0[-4, 1]        #=> nil
  str1 = str[0, 2]     # (str0の「一部」をstr1とする)
  p str1               #=> "ba"
  str1[0] = "XYZ"
  p str1               #=> "XYZa" (str1の内容が破壊的に変更された)
  p str0               #=> "bar" (str0は無傷、str1はstr0と内容を共有していない)

--- [](substr)

self が substr を含む場合、一致した文字列を新しく作って返します。
substr を含まなければ nil を返します。

    substr = "bar"
    result = "foobar"[substr]
    p result                  # => "bar"
    p substr.equal? result    # => true (ruby 1.7 feature:1.7.2 以降は false)

--- [](regexp)
--- [](regexp, nth)

regexp にマッチする最初の部分文字列を返します。組み込み変数
[[m:$~]] にマッチに関する情報が設定されます。

regexp にマッチしない場合 nil を返します。

   p "foobar"[/bar/]  # => "bar"
   p $~.begin(0)      # => 3

#@if (version >= "1.8.0")
引数 nth を指定した場合は、regexp の、nth 番目の
括弧にマッチする最初の部分文字列を返します。nth が 0 の場合
は、マッチした部分文字列全体を返します。マッチしなかった場合や
nth に対応する括弧がなければ nil を返します。

   p "foobar"[/bar/]   # => "bar"
   p $~.begin(0)       # => 3

   p "def getcnt(line)"[ /def\s*(\w+)/, 1 ]   # => "getcnt"
#@end

--- [](first..last)

インデックス first から last までのバイトを含む
新しい文字列を作成して返します。

//emlist{
  0   1   2   3   4   5   (インデックス)
 -6  -5  -4  -3  -2  -1   (負のインデックス)
| a | b | c | d | e | f |
|<--------->|                'abcdef'[0..2]  # => 'abc'
                |<----->|    'abcdef'[4..5]  # => 'ef'
        |<--------->|        'abcdef'[2..4]  # => 'cde'
//}

last が文字列の長さ以上のときは
(文字列の長さ - 1) を指定したものとみなされます。

first が 0 より小さいか文字列の長さより大きいとき、
および first > last + 1 であるときは nil を
返します。ただし first および last のどちらか
または両方が負の数のときは一度だけ文字列の長さを足して
再試行します。

例:

  'abcd'[ 2 ..  1] # => ""
  'abcd'[ 2 ..  2] # => "c"
  'abcd'[ 2 ..  3] # => "cd"
  'abcd'[ 2 ..  4] # => "cd"

  'abcd'[ 2 .. -1] # => "cd"   # str[f..-1] は「f 文字目から
  'abcd'[ 2 .. -2] # => "c"    # 文字列の最後まで」を表す慣用句

  'abcd'[ 1 ..  2] # => "bc"
  'abcd'[ 2 ..  2] # =>  "c"
  'abcd'[ 3 ..  2] # =>   ""
  'abcd'[ 4 ..  2] # =>  nil

  'abcd'[-3 ..  2] # =>  "bc"
  'abcd'[-4 ..  2] # => "abc"
  'abcd'[-5 ..  2] # =>  nil

--- [](first...last)

文字列先頭を 0 番目の隙間、末尾を self.length 番目の隙間として、
first 番目の隙間から last 番目の隙間までに含まれる
バイト列を含んだ新しい文字列を作成して返します。

    文字列と「隙間」の模式図

     0   1   2   3   4   5   6  (隙間番号)
    -6  -5  -4  -3  -2  -1      (負の隙間番号)
     | a | b | c | d | e | f |
     |<--------->|                'abcdef'[0...3]  # => 'abc'
                     |<----->|    'abcdef'[4...6]  # => 'ef'
             |<--------->|        'abcdef'[2...5]  # => 'cde'

last が文字列の長さよりも大きいときは文字列の長さを
指定したものとみなされます。

first が 0 より小さいか文字列の長さより大きいとき、
および first > last であるときは nil を返します。
ただし first と last のどちらかまたは両方が負の数
であるときは一度だけ文字列の長さを足して再試行します。

例:
    'abcd'[ 2 ... 3] # => "c"
    'abcd'[ 2 ... 4] # => "cd"
    'abcd'[ 2 ... 5] # => "cd"

    'abcd'[ 1 ... 2] # => "b"
    'abcd'[ 2 ... 2] # => ""
    'abcd'[ 3 ... 2] # => nil

    'abcd'[-3 ... 2] # => "b"
    'abcd'[-4 ... 2] # => "ab"
    'abcd'[-5 ... 2] # => nil

--- []=(nth, val)

nth 番目のバイトを文字列 val で置き換えます。
val が 0 から 255 の範囲の整数である場合、文字コード
とみなしてその文字で置き換えます。

val を返します。

--- []=(nth, len, val)

nth バイト番目から長さ len バイトの部分文字
列を文字列 val で置き換えます。nth が負の場
合は文字列の末尾から数えます。

val を返します。

--- []=(substr, val)

文字列中の substr に一致する最初の部分文字列を文字列
val で置き換えます。

self が substr を含まない場合、
例外 [[c:IndexError]] が発生します。

val を返します。

--- []=(regexp, val)
--- []=(regexp, nth, val)

正規表現 regexp にマッチする最初の部分文字列を文字列
val で置き換えます。

正規表現がマッチしなければ例外 [[c:IndexError]] が発生します。

val を返します。

#@if (version >= "1.8.0")
引数 nth を指定した場合は、正規表現 regexp の
nth 番目の括弧にマッチする最初の部分文字列を文字列 val
で置き換えます。nth が 0 の場合は、マッチした部分文字列全体
を val で置き換えます。

正規表現がマッチしない場合や nth に対応する括弧が
なければ例外 [[c:IndexError]] が発生します。
#@end

--- []=(self, first..last, val)
--- []=(self, first...last, val)

first から last までの部分文字列を文字列 val で
置き換えます。

val を返します。

--- <=>(other)

self と other を ASCII コード順で比較して、self
が大きい時に正、等しい時に 0、小さい時に負の整数を返します。

変数 [[m:$=]] の値が真である時、比較は常にアルファベッ
トの大文字小文字を無視して行われます。
($= 変数はいずれ廃止されることになっています ((<obsolete>)) を参照)

#@if (version >= "1.8.0")
other が文字列でない場合、other.to_str と
other.<=> が定義されていれば
0 - (other <=> self) の結果を返します。
そうでなければ nil を返します。
#@end

--- capitalize
--- capitalize!

先頭の文字を (アルファベットであれば) 大文字に、
残りを小文字に変更します。

capitalize は変更後の文字列を生成して返します。
capitalize! は self を変更して返しますが、
変更が起こらなかった場合は nil を返します。

  p "foobar".capitalize   # => "Foobar"

$KCODE が適切に設定されていなければ、
漢字コードの一部も変換してしまいます
(これは、ShiftJIS コードで起こり得ます)。
逆に、$KCODE を設定しても
マルチバイト文字のアルファベットは処理しません。

  # -*- Coding: shift_jis -*-
  $KCODE ='n'
  puts "帰".capitalize # => 蟻

[[m:String#upcase]], [[m:String#downcase]],
[[m:String#swapcase]] も参照してください。

--- casecmp(other)

[[m:String#<=>]] と同様に文字列の順序を比較しますが、
アルファベットの大文字小文字の違いを無視します。

このメソッドの動作は [[m:$=]] には影響されません。

例:

  p 'a' <=> 'A'      #=> 1
  p 'a'.casecmp('A') #=> 0

--- center(width[, padding])
--- ljust(width[, padding])
--- rjust(width[, padding])

それぞれ中央寄せ、左詰め、右詰めした文字列を返します。

例:

  p "foo".center(10)      # => "   foo    "
  p "foo".ljust(10)       # => "foo       "
  p "foo".rjust(10)       # => "       foo"

文字列の長さが width より長い時には元の文字列の複製を返します。

例:

  s = "foo"
  p s.center(1).object_id == s.object_id   # => false

#@if (version >= "1.8.0")
第二引数 padding を指定すると
空白の代わりに padding を詰めます。

例:

  p "foo".center(10,"*")      # => "***foo****"
  p "foo".ljust(10,"*")       # => "foo*******"
  p "foo".rjust(10,"*")       # => "*******foo"
#@end

--- chomp([rs])
--- chomp!([rs])

文字列の末尾から rs で指定する行区切りを取り除きます。
rs のデフォルト値は変数 [[m:$/]] の値です。

rs に nil を指定した場合、このメソッドは何もしません。
rsが空文字列(パラグラフモード)の場合、
末尾の連続する改行はすべて取り除かれます。

chomp は改行を取り除いた文字列を生成して返します。
chomp! は self を変更して返しますが、
取り除く改行がなかった場合は nil を返します。

#@if (version >= "1.8.0")
rs が "\n"(デフォルト)のとき、システムによらず "\r", "\r\n",
"\n" のいずれでも行区切りの文字とみなして取り除きます。

例:

  p "foo\r".chomp    # => "foo"
  p "foo\r\n".chomp  # => "foo"
  p "foo\n".chomp    # => "foo"
  p "foo\n\r".chomp  # => "foo\n"
#@end

--- chop
--- chop!

文字列の最後の文字を取り除きます(終端が"\r\n"であれば2文字取
り除きます)。

chop は最後の文字を取り除いた文字列を生成して返します。
chop! は self を変更して返しますが、取り除く文字がなかった
場合は nil を返します。

#@if (version >= "1.9.0")
--- clear

文字列の内容を削除して空にします。
self を返します。

例:

  str = "abc"
  str.clear
  p str     # => ""
#@end

--- clone
--- dup

文字列と同じ内容を持つ新しい文字列を返します。
フリーズ [[m:Object#freeze]] した文字列の
clone はフリーズされた文字列を返しますが、
dup は内容の等しいフリーズされていない文字列を返します。
すなわち dup と [[m:String#new]] は等価です。

--- count(str[, str2[, ...]])

文字列中の文字の数を返します。

検索する文字を示す引数 str の形式は [[man:tr(1)]] と同じです。
つまり、`a-c' は a から c を意味し、
"^0-9" のように文字列の先頭が `^' の場合は
指定文字以外を意味します。

`-' は文字列の両端にない場合にだけ範囲指定の意味になります。
同様に、`^' もその効果は文字列の先頭にあるときだけです。
また、`-', `^', `\' は
バックスラッシュ (`\') によりエスケープすることができます。

引数を複数指定した場合は、すべての引数の積集合を意味します。

例:

  p 'abcdefg'.count('c')               # => 1
  p '123456789'.count('2378')          # => 4
  p '123456789'.count('2-8', '^4-6')   # => 4

以下はこのメソッドの典型的な使用例で、ファイルの行数を返します

  n_lines = File.open("foo").read.count("\n")

上記では、ファイルの末尾に改行がない場合に行としてカウントされません。
これを補うには以下のようにするとよいでしょう。

  buf = File.open("foo").read
  n_lines = buf.count("\n")
  n_lines += 1 if /[^\n]\z/ =~ buf   # if /\n\z/ !~ buf だと空ファイルを1行として数えるのでダメ

--- crypt(salt)

self と salt から暗号化された文字列を生成して返します。
salt には英数字、ドット (.)、スラッシュ (/) から構成される、
2 バイト以上の文字列を指定します。

salt には、以下の様になるべくランダムな文字列を選ぶべきです。
((-他にも ((<ruby-list:29297>)) などがあります-))

例:

  salt = [rand(64),rand(64)].pack("C*").tr("\x00-\x3f","A-Za-z0-9./")
  passwd.crypt(salt)

暗号化された文字列から暗号化前の文字列 (self) を求めることは
一般に((*難しい*))とされ、self を知っている者のみが同じ暗号化
された文字列を生成できます。このことから self を知っているか
どうかの認証に使うことが出来ます。

例えば UNIX パスワードの認証は以下のようにして行われます。
(この例は Etc.getpwnam で暗号化文字列が得られることを仮定しています)。

  require 'etc'

  user = "foo"
  passwd = "bar"

  ent = Etc.getpwnam(user)
  p passwd.crypt(ent.passwd) == ent.passwd

((*注意*)):

  * crypt の処理は [[man:crypt(3)]] の実装に依存しています。
    従って、crypt で処理される内容の詳細や salt の与え方については、
    利用環境の [[man:crypt(3)]] 等を見て確認してください。
  * crypt の結果は利用環境が異なると変わる場合があります。
    crypt の結果を、異なる利用環境を通して使用する場合には注意
    して下さい。
  * 典型的な DES を使用した [[man:crypt(3)]] の場合、
    self の最初の 8 バイト、salt の最初の 2 バイトだけが使用されます。

--- delete(str[, str2[,  ... ]])
--- delete!(str[, str2[,  ... ]])

文字列から str に含まれる文字を取り除きます。

str の形式は [[man:tr(1)]] と同じです。つまり、
`a-c' は a から c を意味し、"^0-9" のように
文字列の先頭が `^' の場合は指定文字以外を意味します。

`-' は文字列の両端にない場合にだけ範囲指定の意味になります。
同様に、`^' もその効果は文字列の先頭にあるときだけです。また、
`-', `^', `\' はバックスラッシュ(`\')によ
りエスケープすることができます。

引数を複数指定した場合は、すべての引数の積集合を意味します。

例:

  p "123456789".delete("2-8", "^4-6")  #=> "14569"
  p "123456789".delete("2378")         #=> "14569"

delete は変更後の文字列を生成して返します。
delete! は self を変更して返しますが、
変更が起こらなかった場合は nil を返します。

--- downcase
--- downcase!

文字列中のアルファベット大文字をすべて小文字に置き換えます。

downcase は変更後の文字列を生成して返します。
downcase! は self を変更して返しますが、置換が起こら
なかった場合は nil を返します。

$KCODE が適切に設定されていなければ、
漢字コードの一部も変換してしまいます
(これは、ShiftJIS コードで起こり得ます)。
逆に、$KCODE を設定しても
マルチバイト文字のアルファベットは処理しません。

例:

  # -*- Coding: shift_jis -*-
  $KCODE ='n'
  puts "帰".downcase   # => 蟻

[[m:String#upcase]], [[m:String#swapcase]],
[[m:String#capitalize]] も参照してください。

--- dump

文字列中の非表示文字をバックスラッシュ記法に
置き換えた文字列を返します。
str == eval(str.dump) となることが保証されています。

例:

  puts "abc\r\n\f\x00\b10\\\"".dump  # => "abc\r\n\f\000\01010\\\""

--- each([rs]) {|line| ... }
--- each_line([rs]) {|line| ... }

文字列中の各行に対して繰り返します。
行の区切りは rs に指定した文字列で、
そのデフォルトは変数 [[m:$/]] の値です。
各 line には区切りの文字列も含みます。

rs に nil を指定すると行区切りなしとみなします。
空文字列 "" を指定すると連続する改行を行の区切りとみなします
(パラグラフモード)。

self を返します。

--- each_byte {|byte| ... }

文字列の各バイトに対して繰り返します。

self を返します。

[[m:String#unpack]] も参照してください。
unpack('C*')でバイト単位の配列を取得できます。

--- empty?

文字列が空 (つまり長さ 0) の時、真を返します。

--- gsub(pattern, replace)
--- gsub!(pattern, replace)
--- gsub(pattern) {|matched| .... }
--- gsub!(pattern) {|matched| .... }

文字列中で pattern にマッチする部分((*全て*))を
replace で置き換えます。置換文字列 replace 中の
\& と \0 はマッチした部分文字列に、
\1 ... \9 は n 番目の括弧の内容に置き換えられます。
置換文字列内では \`、\'、\+ も使えます。
これらは [[m:$`]]、[[m:$']]、[[m:$+]] に対応します。

例:

  p 'abcabc'.gsub(/b/, '(\&)')   #=> "a(b)ca(b)c"

引数 replace を省略した時にはイテレータとして動作し、
ブロックを評価した結果で置換を行います。
ブロックには引数としてマッチした部分文字列が渡されます。
またブロックなしの場合と違い、ブロックの中からは
組み込み変数 [[m:$1]], $2, $3, ... を参照できます。

例:

  p 'abcabc'.gsub(/b/) {|s| s.upcase }  #=> "aBcaBc"
  p 'abcabc'.gsub(/b/) { $&.upcase }    #=> "aBcaBc"

gsub は置換後の文字列を生成して返します。
gsub! は self を変更して返しますが、
置換が起こらなかった場合は nil を返します。

例:

  p 'abcdefg'.gsub(/cd/, 'CD')   #=> "abCDefg"

  str = 'abcdefg'
  str.gsub!(/cd/, 'CD')
  p str                          #=> "abCDefg"

  p 'abbbxabx'.gsub(/a(b+)/, '\1')   #=> "bbbxbx"

((*注意*)):

引数 replace の中で [[m:$1]] を使うことはできません。
この文字列が評価される時点では
まだマッチが行われていないからです。
また replace は \ を 2 重にエスケープしなければなりません
(((<trap::\の影響>))参照)。

例:

  # 第二引数の指定でよくある間違い
  p 'abbbcd'.gsub(/a(b+)/, "#{$1}")       # これは間違い
  p 'abbbcd'.gsub(/a(b+)/, "\1")          # これも間違い
  p 'abbbcd'.gsub(/a(b+)/, "\\1")         # これは正解
  p 'abbbcd'.gsub(/a(b+)/, '\1')          # これも正解
  p 'abbbcd'.gsub(/a(b+)/, '\\1')         # これも正解 (より安全)
  p 'abbbcd'.gsub(/a(b+)/) { $1 }         # これも正解 (もっとも安全)

[[m:String#sub]] も参照してください。

#@if (version >= "1.8.0")
1.6 以前は、pattern が文字列の場合、
その文字列を正規表現にコンパイルしていました。
1.7 以降は、その文字列そのものがパターンになります。
#@end

--- hex

文字列を 16 進数表現と解釈して、整数に変換します。

例:

  p "10".hex    # => 16
  p "ff".hex    # => 255
  p "0x10".hex  # => 16
  p "-0x10".hex # => -16

接頭辞 "0x", "0X" は無視されます。
[_0-9a-fA-F] 以外の文字があればそこまでを変換対象とします。
変換対象が空文字列であれば 0 を返します。

例:

  p "xyz".hex   # => 0
  p "10z".hex   # => 16
  p "1_0".hex   # => 16

[[m:String#oct]], [[m:String#to_i]], [[m:String#to_f]],
[[m:Kernel#Integer]], [[m:Kernel#Float]]
も参照してください。

逆に、数値を文字列に変換するには
[[m:Kernel#sprintf]], [[m:String#%]],
[[m:Integer#to_s]]
を使用します。

--- include?(substr)

文字列中に部分文字列 substr が含まれていれば真を返します。

substr が 0 から 255 の範囲の [[c:Fixnum]] の場合、
文字コードとみなして、その文字が含まれていれば真を返します。

--- index(pattern[, pos])

部分文字列の探索を左端から右端に向かって行います。
見つかった部分文字列の左端の位置を返します。
見つからなければ nil を返します。

引数 pattern は探索する部分文字列の指定を文字列、
文字コードを示す 0 から 255 の整数、正規表現のいずれかで指定します。

pos が与えられた時にはその位置から探索します。
pos の省略時の値は 0 です。

例:

  p "astrochemistry".index("str")         # => 1
  p "character".index(?c)                 # => 0
  p "regexpindex".index(/e.*x/, 2)        # => 3

pos が負の場合、文字列の末尾から数えた位置から探索します。

例:

  p "foobarfoobar".index("bar", 6)        # => 9
  p "foobarfoobar".index("bar", -6)       # => 9

[[m:String#rindex]] も参照してください。

#@if (version >= "1.8.0")
--- insert(nth, other)

nth 番目の文字の直前に文字列 other を挿入します。
以下と (戻り値を除いて) 同じです。

例:

  self[nth, 0] = other

self を返します。

例:

  str = "foobaz"
  p str.insert(3, "bar")
  # => "foobarbaz"
#@end

--- intern
#@if (version >= "1.8.0")
--- to_sym
#@end

文字列に対応するシンボル値 [[c:Symbol]] を返します。
ナルキャラクタ ('\0') を含む文字列は intern できません
(例外 [[c:ArgumentError]] が発生します).

シンボルに対応する文字列を得るには [[m:Symbol#to_s]]
または [[m:Symbol#id2name]] を使います。

例:

  p "foo".intern                 # => :foo
  p "foo".intern.to_s == "foo"   # => true

--- length
--- size

文字列のバイト数を返します。

#@if (version >= "1.8.0")
--- match(regexp)
#@if (version >= "1.9.0")
--- match(regexp[, pos])
#@end

regexp.match(self[, pos]) と同じです ([[m:Regexp#match]] 参照)。
regexp が文字列の場合は、正規表現にコンパイルします。
#@end

--- next
--- next!
--- succ
--- succ!

次の文字列を返します。
「次」とは、アルファベットは 16 進数、
数字は 10 進数として数え上げを行った結果です。
負符号などは考慮されません。
数え上げは以下の例のように繰り上げも行われます。

例:

  p "aa".succ   # => "ab"
  p "99".succ   # => "100"
  p "a9".succ   # => "b0"
  p "Az".succ   # => "Ba"
  p "zz".succ   # => "aaa"
  p "-9".succ   # => "-10"
  p "9".succ    # => "10"
  p "09".succ   # => "10"

文字列がアルファベットや数字を含んでいれば
それ以外の文字はそのままになります。

例:

  p "1.9.9".succ # => # "2.0.0"

逆に、アルファベットや数字を含まなければ以下のように次のASCII文字
を返します。

例:

  p "/".succ     # => "0"
  p "\0".succ    # => "\001"
  p "\377".succ  # => "\001\000"

特別に "".succ は "" を返します。
またマルチバイトは意識せず文字列をバイト列として扱います。
succ と逆の動作をするメソッドはありません。

succ!, next! は文字列の内容を破壊的に修正します。

このメソッドは文字列の [[c:Range]] の内部で使用されます。

--- oct

文字列を 8 進文字列であると解釈して、整数に変換します。

例:

  p "10".oct  # => 8
  p "010".oct # => 8
  p "8".oct   # => 0

oct は文字列の接頭辞 ("0", "0b", "0B", "0x", "0X") に応じて
8 進以外の変換も行います。

例:

  p "0b10".oct  # => 2
  p "10".oct    # => 8
  p "010".oct   # => 8
  p "0x10".oct  # => 16

整数とみなせない文字があればそこまでを変換対象とします。
変換対象が空文字列であれば 0 を返します。

#@if (version >= "1.8.0")
Ruby 1.6 では、8 進だけが符号を許す。
Ruby 1.8 以降はいずれも符号を許す

例:

  p "-010".oct     # => -8
  p "-0x10".oct    # => 0
  p "-0b10".oct    # => 0

  p "1_0_1x".oct   # => 65
#@end

[[m:String#hex]], [[m:String#to_i]], [[m:String#to_f]],
[[m:Kernel#Integer]], [[m:Kernel#Float]]
も参照してください。

逆に、数値を文字列に変換するには
((<組み込み関数/sprintf>)),
((<String/%>)),
((<Integer#to_s|Integer/to_s>))
を使用します。

--- replace(other)

文字列の内容を other の内容で置き換えます。

例:

  s = "foo"
  id = s.object_id
  s.replace "bar"
  p s                   # => "bar"
  p id == s.object_id   # => true

self を返します。

--- reverse
--- reverse!

文字列をひっくり返します。

例:

  p "foobar".reverse   # => "raboof"

reverse は変更後の文字列を生成して返します。
reverse! は self を変更してそれを返します。

--- rindex(pattern[, pos])

部分文字列の探索を右端から左端に向かって行います。
見つかった部分文字列の左端の位置を返します。
見つからなければ nil を返します。

引数 pattern は探索する部分文字列の指定を文字列、
文字コードを示す 0 から 255 の整数、
正規表現のいずれかで指定します。

pos が与えられた時にはその位置から探索します。
pos の省略時の値は self.size (右端) です。

例:

  p "astrochemistry".rindex("str")        # => 10
  p "character".rindex(?c)                # => 5
  p "regexprindex".rindex(/e.*x/, 2)      # => 1

pos が負の場合、文字列の末尾から数えた位置から探索します。

例:

  p "foobarfoobar".rindex("bar", 6)       # => 3
  p "foobarfoobar".rindex("bar", -6)      # => 3

((<String/index>)) と完全に左右が反転した
動作をするわけではありません。
探索はその開始位置を右から左にずらしながら行いますが、
部分文字列の照合は左から右に向かって行います。
以下の例を参照してください。

  # String#index の場合
  p "fooooooobar".index("bar", 2)    # => 3
  #    bar <- ここから探索を行う
  #          bar  <- 右にずらしてここで見つかる

  # String#rindex の場合
  p "foooooooobar".rindex("bar", -2)  # => 3
  #    bar <- 右端が末尾から 2 番目ではなく,
  #            bar <- 左端が末尾から 2 番目から探索を行う
  #           bar  <- 左にずらしてここで見つかる

--- scan(re)
--- scan(re) {|s| ... }

self に対して正規表現 re で繰り返しマッチを行い、
マッチした部分文字列の配列を返します。

例:

  p "foobar".scan(/./)
      # => ["f", "o", "o", "b", "a", "r"]

  p "foobarbazfoobarbaz".scan(/ba./)
      # => ["bar", "baz", "bar", "baz"]

正規表現が括弧を含む場合は、括弧で括られたパターンにマッチした部分
文字列の配列の配列を返します。

例:

  p "foobar".scan(/(.)/)
  # => [["f"], ["o"], ["o"], ["b"], ["a"], ["r"]]

  p "foobarbazfoobarbaz".scan(/(ba)(.)/)
  # => [["ba", "r"], ["ba", "z"], ["ba", "r"], ["ba", "z"]]

ブロックを指定して呼び出した場合は、マッチした部分文字列(括弧を含
む場合は括弧で括られたパターンにマッチした文字列の配列)をブロック
のパラメータとします。ブロックを指定した場合は self を返しま
す。

例:

  "foobarbazfoobarbaz".scan(/ba./) {|s| p s}
  # => "bar"
  #    "baz"
  #    "baz"
  #    "baz"

  "foobarbazfoobarbaz".scan(/(ba)(.)/) {|s| p s}
  # => ["ba", "r"]
  #    ["ba", "z"]
  #    ["ba", "r"]
  #    ["ba", "z"]

#@if (version >= "1.8.0")
Ruby 1.6 以前は re が文字列の場合、
その文字列を正規表現にコンパイルしていました。
Ruby 1.8 以降は、その文字列そのものがパターンになります。
#@end

--- slice(nth[, len])
--- slice(substr)
--- slice(first..last)
--- slice(first...last)

((<self[]|String/[]>)) と同じです。

--- slice!(nth[, len])
--- slice!(substr)
--- slice!(first..last)
--- slice!(first...last)
#@if (version >= "1.8.0")
--- slice!(regexp[, nth])
#@end

指定した範囲 (((<self[]|String/[]>)) 参照) を
文字列から取り除いたうえで取り除いた部分文字列を返します。

引数が範囲外を指す場合は nil を返します。

--- split([sep[, limit]])

sep で指定されたパターンによって文字列を分割し配列に格納します。
sep は以下のいずれかです。

: 正規表現
    正規表現にマッチする文字列を区切りとして分割する。
    特に、括弧によるグルーピングがあればそのグループにマッチした
    文字列も結果の配列に含まれる(後述)。
: 1 バイトの文字列
    その文字を区切りとして分割する (Ruby 1.6)。
: 2 バイト以上の文字列
    Regexp.new(sep) にマッチする文字列を
    区切りとして分割する (Ruby 1.6)。
: 省略 or nil
    ((<組み込み変数/$;>)) の値を区切りとして分割する。
: 1 バイトの空白 ' ' か $; が使用される場合でその値が nil:
    先頭の空白を除いて空白で分割する。
: 空文字列 '' あるいは空にマッチする正規表現
    1文字ずつに分割する。マルチバイト文字を認識する。

#@if (version >= "1.8.0")
Ruby 1.7 以降は、sep が文字列の場合その長さにかかわらず
Regexp.new(Regexp.quote(sep)) にマッチする文字列
(つまりその文字列そのもの) が区切りとなります。
#@end

例:

  # awk split
  p "   a \t  b \n  c".split(/\s+/) # => ["", "a", "b", "c"]
  p "   a \t  b \n  c".split        # => ["a", "b", "c"] ($; のデフォルト値はnilです)
  p "   a \t  b \n  c".split(' ')   # => ["a", "b", "c"]

sep で指定されたパターンが空文字列とマッチする場合は
文字列が 1 文字ずつに分割されます.
[[m:$KCODE]] が適切に設定されていれば
漢字を認識して文字単位で分割します。

例:

  p 'hi there'.split(/ */).join(':')   # => "h:i:t:h:e:r:e"
  p 'hi there'.split(//).join(':')     # => "h:i: :t:h:e:r:e"
  $KCODE = 'e'
  p '文字列'.split(//).join(':')       # => "文:字:列"

sep で指定されたパターンに括弧が含まれている場合には、
各括弧のパターンにマッチした文字列も配列に含まれます。
括弧が複数ある場合は、マッチしたものだけが配列に含まれます。

例:

  p '1-10,20'.split(/([-,])/)   # => ["1", "-", "10", ",", "20"]
  p '1-10,20'.split(/(-)|(,)/)  # => ["1", "-", "10", ",", "20"]

limit は以下のいずれかです。

: limit == 0 or 省略
     配列末尾の空文字列は取り除かれる。
: limit > 0
     最大 limit 個のフィールドに分割する。
: limit < 0
     無限に大きい limit が指定されたかのように分割する。

例:

  # limit 省略時は、0 を指定したのと同じ。配列末尾の空文字列は取り除かれる
  p "a,b,c,,,".split(/,/)      # => ["a", "b", "c"]
  p "a,b,c,,,".split(/,/, 0)   # => ["a", "b", "c"]

  # limit が 最大のフィールド数に満たない場合は最後の要素に残りすべてが入る
  p "a,b,c,,,".split(/,/, 3)   # => ["a", "b", "c,,,"]

  # limit が -1 や最大のフィールド数以上の場合は最大のフィールド数を指定したのと同じ
  p "a,b,c,,,".split(/,/, 6)     # => ["a", "b", "c", "", "", ""]
  p "a,b,c,,,".split(/,/, -1)    # => ["a", "b", "c", "", "", ""]
  p "a,b,c,,,".split(/,/, 100)   # => ["a", "b", "c", "", "", ""]

--- squeeze([str[, str2[, ...]]])
--- squeeze!([str[, str2[, ...]]])

str に含まれる同一の文字の並びをひとつにまとめます。

str の形式は [[man:tr(1)]] と同じです。つまり、
`a-c' は a から c を意味し、"^0-9" のように
文字列の先頭が `^' の場合は指定文字以外を意味します。

`-' は文字列の両端にない場合にだけ範囲指定の意味になります。
同様に、`^' もその効果は文字列の先頭にあるときだけです。また、
`-', `^', `\' はバックスラッシュ(`\')によ
りエスケープすることができます。

引数を複数指定した場合は、すべての引数の積集合を意味します。

例:

  p "112233445566778899".squeeze          # =>"123456789"
  p "112233445566778899".squeeze("2-8")   # =>"11234567899"
  p "112233445566778899".squeeze("2-8", "^4-6")   # =>"11234455667899"
  p "112233445566778899".squeeze("2378")  # =>"11234455667899"

squeeze は変更後の文字列を生成して返します。
squeeze! は self を変更して返しますが、
変更が起こらなかった場合は nil を返します。

--- strip
--- strip!

先頭と末尾の空白文字を全て取り除きます。
空白文字の定義は " \t\r\n\f\v" です。

strip は変更後の文字列を新しく生成して返します。

strip! は self を変更して返します。
ただし取り除く空白がなかったときは nil を返します。

例:

  p "  abc  \r\n".strip    #=> "abc"
  p "abc\n".strip          #=> "abc"
  p "  abc".strip          #=> "abc"
  p "abc".strip            #=> "abc"

  str = "\tabc\n"
  p str.strip              #=> "abc"
  p str                    #=> "\tabc\n"  (変化なし)

  str = "  abc\r\n"
  p str.strip!             #=> "abc"
  p str                    #=> "abc"  (変化あり)

  str = "abc"
  p str.strip!             #=> nil
  p str                    #=> "abc"

#@if (version >= "1.8.0")
((<String/rstrip>)) と同様、
右側の空白類と "\0" を取り除きますが、
左側の "\0" は特別扱いされません。

例:

  str = "  \0  abc  \0"
  p str.strip           # => "\000  abc"
#@end

#@if (version >= "1.8.0")
--- lstrip
--- lstrip!

文字列の先頭にある空白文字を全て取り除きます。
空白文字の定義は " \t\r\n\f\v" です。

lstrip は加工後の文字列を新しく生成して返します。

lstrip! は self を変更して返します。
ただし取り除く空白がなかったときは nil を返します。

例:

  p "  abc\n".lstrip     #=> "abc\n"
  p "\t abc\n".lstrip    #=> "abc\n"
  p "abc\n".lstrip       #=> "abc\n"

  str = "\nabc"
  p str.lstrip           #=> "abc"
  p str                  #=> "\nabc"  (変化なし)

  str = "  abc"
  p str.lstrip!          #=> "abc"
  p str                  #=> "abc"  (変化あり)

  str = "abc"
  p str.lstrip!          #=> nil
  p str                  #=> "abc"
#@end

#@if (version >= "1.8.0")
--- rstrip
--- rstrip!

文字列の末尾にある空白文字を全て取り除きます。
空白文字の定義は " \t\r\n\f\v" です。

rstrip は加工後の文字列を新しく生成して返します。

rstrip! は自身を変更して返します。
ただし取り除く空白がなかったときは nil を返します。

例:

  p " abc\n".rstrip        #=> " abc"
  p " abc \t\r\n".rstrip   #=> " abc"
  p " abc".rstrip          #=> " abc"

  str = "abc\n"
  p str.rstrip           #=> "abc"
  p str                  #=> "abc\n"  (変化なし)

  str = "abc  "
  p str.rstrip!          #=> "abc"
  p str                  #=> "abc"  (変化あり)

  str = "abc"
  p str.rstrip!          #=> nil
  p str                  #=> "abc"

空白類と "\0" を取り除きます。
これに対して、((<String/lstrip>)) は "\0" を特別扱いしません。

例:

  str = "\0abc\0"
  p str.strip            # => "\0abc"
  p str.rstrip           # => "\0abc"
  p str.lstrip           # => "\0abc\0"
#@end

--- sub(pattern, replace)
--- sub!(pattern, replace)
--- sub(pattern) {|matched| ... }
--- sub!(pattern) {|matched| ... }

文字列中で pattern に((*最初に*))マッチする部分を
replace で置き換えます。

ブロックを指定して呼び出された時には、
最初にマッチした部分をブロックを評価した値で置き換えます。

sub は置換後の文字列を生成して返します。
sub! は self を変更して返しますが、
置換が起こらなかった場合は nil を返します。

マッチを一度しか行わない点を除けば ((<String/gsub>)) と同じです。

((*注意*)): ((<String/gsub>)) の項には sub/gsub を使用する上での注
意点が書かれています。((<String/gsub>)) も参照してください。

#@if (version >= "1.8.0")
Ruby 1.6 以前は pattern が文字列の場合、
その文字列を正規表現にコンパイルしていました。
Ruby 1.7 以降はその文字列そのものがパターンになります。
#@end

--- sum([bits = 16])

文字列の bits ビットのチェックサムを計算します。
以下と同じです。

  sum = 0
  str.each_byte {|c| sum += c}
  sum = sum & ((1 << bits) - 1) if bits != 0

例えば以下のコードで UNIX System V の
[[man:sum(1)]] コマンドと同じ値が得られます。

例:

  sum = 0
  ARGF.each do |line|
    sum += line.sum
  end
  sum %= 65536

--- swapcase
--- swapcase!

全ての大文字を小文字に、小文字を大文字に変更します。

swapcase は置換後の文字列を生成して返します。
swapcase! は self を変更して返しますが、置換が起こら
なかった場合は nil を返します。

$KCODE が適切に設定されていなければ、漢字コードの一部も変換
してしまいます(これは、ShiftJIS コードで起こり得ます)。
逆に、$KCODE を設定してもマルチバイト文字のアルファベット
は処理しません。

例:

  # -*- Coding: shift_jis -*-
  $KCODE ='n'
  puts "蟻".swapcase   # => 帰

((<String/upcase>)), ((<String/downcase>)),
((<String/capitalize>)) も参照してください。

--- to_f

文字列を 10 進数表現と解釈して、浮動小数点数 ((<Float>)) に変換します。

  p "10".to_f    # => 10.0
  p "10e2".to_f  # => 1000.0
  p "1e-2".to_f  # => 0.01
  p ".1".to_f    # => 0.1

  p "nan".to_f   # => 0.0
  p "INF".to_f   # => 0.0
  p "-Inf".to_f  # => -0.0
  p(("10" * 1000).to_f)   # => Infinity (with warning)

  p "".to_f      # => 0.0
  p "1_0_0".to_f # => 100.0
  p " \n10".to_f # => 10.0       # 先頭の空白は無視される
  p "0xa.a".to_f # => 0.0

浮動小数点数とみなせなくなるところまでを変換対象とします。
変換対象が空文字列であれば 0.0 を返します。

((<String/hex>)), ((<String/oct>)), ((<String/to_i>)),
((<組み込み関数/Integer>)), ((<組み込み関数/Float>))
も参照してください。

逆に、数値を文字列に変換するには
((<組み込み関数/sprintf>)),
((<String/%>)),
((<Integer#to_s|Integer/to_s>))
を使用します。

--- to_i(base = 10)

文字列を 10 進数表現と解釈して、整数に変換します。

  p " 10".to_i    # => 10
  p "010".to_i    # => 10
  p "-010".to_i   # => -10

整数とみなせない文字があればそこまでを変換対象とします。変換対象が
空文字列であれば 0 を返します。

  p "0x11".to_i   # => 0

((<String/hex>)), ((<String/oct>)), ((<String/to_f>)),
((<組み込み関数/Integer>)), ((<組み込み関数/Float>))
も参照してください。

逆に、数値を文字列に変換するには
((<組み込み関数/sprintf>)),
((<String/%>)),
((<Integer#to_s|Integer/to_s>))
を使用します。

#@if (version > "1.8.0")
基数を指定することでデフォルトの 10 進以外に 2 〜 36 進数への変換
を行うことができます。また、0 を指定すると prefix により基数を判断
します(逆に prefix を認識するのは 0 を指定したときだけです)。
0, 2 〜 36 以外の引数を指定した場合、例外 ((<ArgumentError>)) が発
生します。

  p "0b10".to_i(0)  # => 2
  p "0o10".to_i(0)  # => 8
  p "010".to_i(0)   # => 8
  p "0d10".to_i(0)  # => 10
  p "0x10".to_i(0)  # => 16
#@end

--- to_s
--- to_str

self を返します。

--- tr(search, replace)
--- tr!(search, replace)

文字列の中に search 文字列に含まれる文字が存在したら、
それを replace 文字列の対応する文字に置き換えます。

search の形式は [[man:tr(1)]] と同じです。つまり、
`a-c' は a から c を意味し、"^0-9" のように
文字列の先頭が `^' の場合は指定文字以外が置換の対象になります。

replace に対しても `-' による範囲指定が可能です。
例えば、((<String#upcase|String/upcase>)) を tr で書くと、

  p "foo".tr('a-z', 'A-Z')
  => "FOO"

となります。

`-' は文字列の両端にない場合にだけ範囲指定の意味になります。
同様に、`^' もその効果は文字列の先頭にあるときだけです。また、
`-', `^', `\' はバックスラッシュ(`\')によ
りエスケープすることができます。

replace の範囲が search の範囲よりも小さい場合は、
replace の最後の文字が無限に続くものとして扱われます。

tr は置換後の文字列を生成して返します。
tr! は self を変更して返しますが、置換が起こら
なかった場合は nil を返します。

--- tr_s(search, replace)
--- tr_s!(search, replace)

文字列の中に search 文字列に含まれる文字が存在したら、
replace 文字列の対応する文字に置き換えます。さらに、
置換した部分内に同一の文字の並びがあったらそれを 1 文字に圧縮します。

search の形式は [[man:tr(1)]] と同じです。つまり、
`a-c' は a から c を意味し、"^0-9" のように
文字列の先頭が `^' の場合は指定文字以外が置換の対象になります。

replace に対しても `-' による範囲指定が可能です。

  p "foo".tr_s('a-z', 'A-Z')
  => "FO"

`-' は文字列の両端にない場合にだけ範囲指定の意味になります。
同様に、`^' もその効果は文字列の先頭にあるときだけです。また、
`-', `^', `\' はバックスラッシュ(`\')によ
りエスケープすることができます。

replace の範囲が search の範囲よりも小さい場合、
replace の最後の文字が無限に続くものとして扱われます。

tr_s は置換後の文字列を生成して返します。
tr_s! は self を変更して返しますが、置換が起こら
なかった場合は nil を返します。

((*注意*)): このメソッドと tr(search, replace).squeeze(replace)
とでは挙動が異なります。tr と squeeze の組みあわせが置換後の文字列全体を
squeeze の対象にするのに対して、tr_s は((*置換された部分だけ*))を
squeeze の対象とします。

例:

  p "foo".tr_s("o", "f")              # => "ff"
  p "foo".tr("o", "f").squeeze("f")   # => "f"

--- unpack(template)

((<Array#pack|Array/pack>)) で生成された) 文字列を
template 文字列にしたがってアンパックし、
それらの要素を含む配列を返します。

#@# template 文字列のフォーマットについては
#@# ((<packテンプレート文字列>))を参照してください。
#@include(pack-template)

--- upcase
--- upcase!

ASCII 文字列の範囲内でアルファベットを全て大文字にします

upcase は置換後の文字列を生成して返します。
upcase! は self を変更して返しますが、置換が起こら
なかった場合は nil を返します。

$KCODE が適切に設定されていなければ、漢字コードの一部も変換
してしまいます (これは、Shift JIS コードで起こり得ます)。
逆に、$KCODE を設定してもマルチバイト文字のアルファベット
は処理しません。

  # -*- Coding: shift_jis -*-
  $KCODE ='n'
  puts "蟻".upcase # => 帰

[[m:String#downcase]], [[m:String#swapcase]],
[[m:String#capitalize]] も参照してください。

--- upto(max) {|s| ... }

self から始めて max まで
「次の文字列」を順番にブロックに与えて繰り返します。
「次」の定義については [[m:String#succ]] を参照してください。

たとえば以下のコードは a, b, c, ... z,aa, ... az, ..., za を
出力します。

  ("a" .. "za").each do |str|
    puts str
  end

