require "test_helper"

class HTML::Pipeline::SanitizationFilterTest < Test::Unit::TestCase
  SanitizationFilter = HTML::Pipeline::SanitizationFilter

  def test_removing_script_tags
    orig = %(<p><img src="http://github.com/img.png" /><script></script></p>)
    html = SanitizationFilter.call(orig).to_s
    assert_no_match /script/, html
  end

  def test_removing_style_tags
    orig = %(<p><style>hey now</style></p>)
    html = SanitizationFilter.call(orig).to_s
    assert_no_match /style/, html
  end

  def test_removing_style_attributes
    orig = %(<p style='font-size:1000%'>YO DAWG</p>)
    html = SanitizationFilter.call(orig).to_s
    assert_no_match /font-size/, html
    assert_no_match /style/, html
  end

  def test_removing_javascript_protocol
    orig = %(<a href='javascript:alert(1)'>YO DAWG</a>)
    html = SanitizationFilter.call(orig).to_s
    assert_no_match /javascript/, html
    assert_no_match /href/, html
  end

  def test_removing_script_event_handler_attributes
    orig = %(<a onclick='javascript:alert(0)'>YO DAWG</a>)
    html = SanitizationFilter.call(orig).to_s
    assert_no_match /javascript/, html
    assert_no_match /onclick/, html
  end

  def test_does_not_sanitize_li_elements_contained_in_ul_or_ol
    stuff = "a\n<ul><li>b</li></ul>\nc"
    assert_equal stuff, SanitizationFilter.call(stuff).to_s
  end

  def test_script_contents_are_removed
    orig = '<script>JavaScript!</script>'
    assert_equal "", SanitizationFilter.call(orig).to_s
  end
end
