require 'helper'

class TestFormize < Test::Unit::TestCase
  def test_configuration
    assert_not_nil Formize.default_source
    assert_not_nil Formize.radio_count_max
    assert_not_nil Formize.select_count_max
  end
end
