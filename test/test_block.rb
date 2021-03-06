require 'test_helper'
require 'hparser/parser'
require 'hparser/block/list'

class BlockTest < Test::Unit::TestCase
  include HParser::Block
  include HParser::Inline

  def setup
    @parser = HParser::Parser.new
  end

  def parse str
    @parser.parse str
  end

  def test_extra_empty
    assert_equal [Ul.new(li('a')),P.new([Text.new('b')])],parse(<<-END)
-a

b
END

    assert_equal [Head.new(1,[Text.new('a')]),P.new([Text.new('b')])],parse(<<-END)
*a

b
END
  end

  def test_ul
    assert_equal [Ul.new(li('a'),li('b'),li('c'))],
                  parse(<<-END)
- a
- b
- c
    END

    assert_equal [Ul.new(li('a'),Ul.new(li('b')),li('c'))],
                  parse(<<-END)
- a
-- b
- c
    END
  end

  def test_ol
    assert_equal [Ol.new(li('a'),li('b'),li('c'))],
                  parse(<<-END)
+ a
+ b
+ c
    END

    assert_equal [Ol.new(li('a'),Ol.new(li('b')),li('c'))],
                  parse(<<-END)
+ a
++ b
+ c
    END
  end

  def test_spre
    assert_equal [SuperPre.new(' a ')],parse(<<-END)
>||
 a 
||<
END
    assert_equal [SuperPre.new('a')],parse(<<-END), 'with space'
>|| 
a
||< 
END

  end

  def test_spre_html
    assert_equal [SuperPre.new('<foo />')],parse(<<-END)
>||
<foo />
||<
END

  end

  def test_spre_format
    parsed = parse(<<-END)
>|xml|
<foo />
||<
END
    assert_equal [SuperPre.new('<foo />')], parsed
    assert_equal 'xml', parsed.first.format
  end

  def test_list
    assert_equal [Ul.new(li('a'),Ol.new(li('b')),Ul.new(li('c')))],
                  parse(<<-END)
- a
++ b
-- c
    END
  end


  def test_comment
    assert_equal [HParser::Block::RAW.new([ Comment.new("\naaa\n") ])], parse(<<-END.unindent)
    ><!--
    aaa
    --><
    END
  end

  def test_raw
    assert_equal [RAW.new([ Text.new("<ins>") ]), P.new([ Text.new("foo") ]), RAW.new([ Text.new("</ins>") ])], parse(<<-END.unindent)
    ><ins><
    foo
    ></ins><
    END
  end

  def test_raw_without_end_lt
    assert_equal [RAW.new([ Text.new("<ins>") ]), P.new([ Text.new("foo") ]), RAW.new([ Text.new("</ins>") ])], parse(<<-END.unindent)
    ><ins><
    foo
    ></ins>
    END
  end

  def test_p
    assert_equal [P.new([ Text.new(" foo") ])], parse(<<END)
 foo
END

    str = <<END
 foo
 bar
 buz
END
    assert_equal [P.new([ Text.new(" foo")]), P.new([Text.new(" bar") ]), P.new([Text.new(" buz") ])], parse(str)
  end


  def li str
    Li.new([Text.new(str)])
  end
end
