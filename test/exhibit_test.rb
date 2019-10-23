require 'minitest/autorun'
require 'minitest/pride'
require 'pry'
require './lib/exhibit'

class ExhibitTest < Minitest::Test
  def test_it_exists
    exhibit = Exhibit.new("Gems and Minerals", 0)

    assert_instance_of Exhibit, exhibit
  end

  def test_it_has_attributes
    exhibit = Exhibit.new("Gems and Minerals", 0)

    assert_equal "Gems and Minerals", exhibit.name
    assert_equal 0, exhibit.cost
  end
end
