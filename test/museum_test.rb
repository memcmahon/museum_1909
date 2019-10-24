require 'minitest/autorun'
require 'minitest/pride'
require 'pry'
require './lib/exhibit'
require './lib/patron'
require './lib/museum'

class MuseumTest < Minitest::Test
  def test_it_exists
    dmns = Museum.new("Denver Museum of Nature and Science")

    assert_instance_of Museum, dmns
  end

  def test_it_has_attributes
    dmns = Museum.new("Denver Museum of Nature and Science")

    assert_equal "Denver Museum of Nature and Science", dmns.name
    assert_equal [], dmns.exhibits
    assert_equal [], dmns.patrons
  end

  def test_it_adds_exhibits
    dmns = Museum.new("Denver Museum of Nature and Science")
    gems_and_minerals = Exhibit.new("Gems and Minerals", 0)
    dead_sea_scrolls = Exhibit.new("Dead Sea Scrolls", 10)
    imax = Exhibit.new("IMAX", 15)

    dmns.add_exhibit(gems_and_minerals)
    dmns.add_exhibit(dead_sea_scrolls)
    dmns.add_exhibit(imax)

    assert_equal [gems_and_minerals, dead_sea_scrolls, imax], dmns.exhibits
  end

  def test_it_admits_patrons
    dmns = Museum.new("Denver Museum of Nature and Science")
    bob = Patron.new("Bob", 20)
    sally = Patron.new("Sally", 20)

    dmns.admit(bob)
    dmns.admit(sally)

    assert_equal [bob, sally], dmns.patrons
  end

  def test_it_recommends_exhibits
    dmns = Museum.new("Denver Museum of Nature and Science")
    gems_and_minerals = Exhibit.new("Gems and Minerals", 0)
    dead_sea_scrolls = Exhibit.new("Dead Sea Scrolls", 10)
    imax = Exhibit.new("IMAX", 15)
    dmns.add_exhibit(gems_and_minerals)
    dmns.add_exhibit(dead_sea_scrolls)
    dmns.add_exhibit(imax)
    bob = Patron.new("Bob", 20)
    sally = Patron.new("Sally", 20)
    bob.add_interest("Dead Sea Scrolls")
    bob.add_interest("Gems and Minerals")
    sally.add_interest("IMAX")

    assert_equal 2, dmns.recommend_exhibits(bob).length
    assert_equal true, dmns.recommend_exhibits(bob).include?(gems_and_minerals)
    assert_equal true, dmns.recommend_exhibits(bob).include?(dead_sea_scrolls)
    # assert_equal [gems_and_minerals, dead_sea_scrolls], dmns.recommend_exhibits(bob)
    assert_equal [imax], dmns.recommend_exhibits(sally)
  end

  def test_it_returns_patrons_by_exh_interest
    dmns = Museum.new("Denver Museum of Nature and Science")
    gems_and_minerals = Exhibit.new("Gems and Minerals", 0)
    dead_sea_scrolls = Exhibit.new("Dead Sea Scrolls", 10)
    imax = Exhibit.new("IMAX", 15)
    dmns.add_exhibit(gems_and_minerals)
    dmns.add_exhibit(dead_sea_scrolls)
    dmns.add_exhibit(imax)
    bob = Patron.new("Bob", 20)
    bob.add_interest("Dead Sea Scrolls")
    bob.add_interest("Gems and Minerals")
    sally = Patron.new("Sally", 20)
    sally.add_interest("Dead Sea Scrolls")
    dmns.admit(bob)
    dmns.admit(sally)

    expected = {
      gems_and_minerals => [bob],
      dead_sea_scrolls => [bob, sally],
      imax => [],
    }

    assert_equal expected, dmns.patrons_by_exhibit_interest
    # assert_equal [], dmns.patrons_by_exhibit_interest[imax]
  end

  def test_it_returns_patrons_of_exhibits
    dmns = Museum.new("Denver Museum of Nature and Science")
    gems_and_minerals = Exhibit.new("Gems and Minerals", 0)
    imax = Exhibit.new("IMAX", 15)
    dead_sea_scrolls = Exhibit.new("Dead Sea Scrolls", 10)
    dmns.add_exhibit(gems_and_minerals)
    dmns.add_exhibit(imax)
    dmns.add_exhibit(dead_sea_scrolls)

    # This Patron is interested in two exhibits but none in their price range, so they attend none
    tj = Patron.new("TJ", 7)
    tj.add_interest("IMAX")
    tj.add_interest("Dead Sea Scrolls")
    dmns.admit(tj)

    # This Patron is interested in two exhibits and only Dead Sea Scrolls
    # is in their price range price, so they attend Dead Sea Scrolls
    bob = Patron.new("Bob", 10)
    bob.add_interest("Dead Sea Scrolls")
    bob.add_interest("IMAX")
    dmns.admit(bob)

    # This Patron is interested in two exhibits and both are in their price range.
    # They attend the more expensive one first (IMAX), but don't have enough money to attend
    # the second one
    sally = Patron.new("Sally", 20)
    sally.add_interest("IMAX")
    sally.add_interest("Dead Sea Scrolls")
    dmns.admit(sally)

    # This Patron is interested in two exhibits and both are in their price range.
    # They have enough spending money to afford both, so they attend both.
    morgan = Patron.new("Morgan", 15)
    morgan.add_interest("Gems and Minerals")
    morgan.add_interest("Dead Sea Scrolls")
    dmns.admit(morgan)

    expected = {
      gems_and_minerals => [morgan],
      dead_sea_scrolls => [bob, morgan],
      imax => [sally],
    }

    assert_equal expected, dmns.patrons_of_exhibits
  end

  def test_it_has_revenue
    dmns = Museum.new("Denver Museum of Nature and Science")
    gems_and_minerals = Exhibit.new("Gems and Minerals", 0)
    imax = Exhibit.new("IMAX", 15)
    dead_sea_scrolls = Exhibit.new("Dead Sea Scrolls", 10)
    dmns.add_exhibit(gems_and_minerals)
    dmns.add_exhibit(imax)
    dmns.add_exhibit(dead_sea_scrolls)

    assert_equal 0, dmns.revenue

    tj = Patron.new("TJ", 7)
    tj.add_interest("IMAX")
    tj.add_interest("Dead Sea Scrolls")
    dmns.admit(tj)

    bob = Patron.new("Bob", 10)
    bob.add_interest("Dead Sea Scrolls")
    bob.add_interest("IMAX")
    dmns.admit(bob)

    sally = Patron.new("Sally", 20)
    sally.add_interest("IMAX")
    sally.add_interest("Dead Sea Scrolls")
    dmns.admit(sally)

    morgan = Patron.new("Morgan", 15)
    morgan.add_interest("Gems and Minerals")
    morgan.add_interest("Dead Sea Scrolls")
    dmns.admit(morgan)

    assert_equal 35, dmns.revenue
  end

  def test_admitting_patrons_reduces_spending_money
    dmns = Museum.new("Denver Museum of Nature and Science")
    gems_and_minerals = Exhibit.new("Gems and Minerals", 0)
    imax = Exhibit.new("IMAX", 15)
    dead_sea_scrolls = Exhibit.new("Dead Sea Scrolls", 10)
    dmns.add_exhibit(gems_and_minerals)
    dmns.add_exhibit(imax)
    dmns.add_exhibit(dead_sea_scrolls)
    tj = Patron.new("TJ", 7)
    tj.add_interest("IMAX")
    tj.add_interest("Dead Sea Scrolls")
    dmns.admit(tj)
    bob = Patron.new("Bob", 10)
    bob.add_interest("Dead Sea Scrolls")
    bob.add_interest("IMAX")
    dmns.admit(bob)
    sally = Patron.new("Sally", 20)
    sally.add_interest("IMAX")
    sally.add_interest("Dead Sea Scrolls")
    dmns.admit(sally)
    morgan = Patron.new("Morgan", 15)
    morgan.add_interest("Gems and Minerals")
    morgan.add_interest("Dead Sea Scrolls")
    dmns.admit(morgan)

    assert_equal 7, tj.spending_money
    assert_equal 0, bob.spending_money
    assert_equal 5, sally.spending_money
    assert_equal 5, morgan.spending_money
  end
end
