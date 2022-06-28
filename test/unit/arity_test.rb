require "test_helper"

class ArityTest < Minitest::Test
  class Charity
    def donate(amount:); end
    def give(opts); end
  end

  def test_handles_kwargs_and_hashes
    aclu = Charity.new
    aclu.donate(amount: 100)
    aclu.give(to: :poor)

    wbc = Mocktail.of(Charity)
    wbc.donate(amount: 100)
    wbc.give({ to: :poor })
    wbc.give(to: :poor)
  end
end
