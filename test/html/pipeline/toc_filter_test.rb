require "test_helper"

class HTML::Pipeline::TableOfContentsFilterTest < Test::Unit::TestCase
  TocFilter = HTML::Pipeline::TableOfContentsFilter
  CONTEXT = { toc_minimal_length: 1, toc_header: 'Table of contents' }

  def test_anchors_are_added_properly
    orig = %(<h2>Ice cube</h2><p>Will swarm on any motherfucker in a blue uniform</p>)
    assert_includes '<h2 id=', TocFilter.call(orig, CONTEXT).to_s
  end

  def test_anchors_have_sane_names
    orig = %(<h2>Dr Dre</h2><h2>Ice Cube</h2><h2>Eazy-E</h2><h2>MC Ren</h2>)
    result = TocFilter.call(orig, CONTEXT).to_s

    assert_includes '"dr-dre"', result
    assert_includes '"ice-cube"', result
    assert_includes '"eazy-e"', result
    assert_includes '"mc-ren"', result
  end

  def test_dupe_headers_have_unique_trailing_identifiers
    orig = %(<h2>Straight Outta Compton</h2>
             <h3>Dopeman</h3>
             <h4>Express Yourself</h4>
             <h2>Dopeman</h2>)

    result = TocFilter.call(orig, CONTEXT).to_s

    assert_includes '"dopeman"', result
    assert_includes '"dopeman-1"', result
  end

  def test_all_header_tags_are_found_when_adding_anchors
    orig = %(<h2>"Funky President" by James Brown</h2>
             <h3>"It's My Thing" by Marva Whitney</h3>
             <h4>"Boogie Back" by Roy Ayers</h4>
             <h5>"Feel Good" by Fancy</h5>
             <h6>"Funky Drummer" by James Brown</h6>
             <h7>"Ruthless Villain" by Eazy-E</h7>
             <h8>"Be Thankful for What You Got" by William DeVaughn</h8>)

    doc = TocFilter.call(orig, CONTEXT)
    assert_equal 5, doc.search('a').size
  end
end
