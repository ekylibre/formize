require 'helper'

class TestFormize < Formize::TestCase
  def test_configuration
    assert Formize.default_source
    assert Formize.radio_count_max
    assert Formize.select_count_max
  end
end
