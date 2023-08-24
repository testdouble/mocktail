# typed: strict

require "test_helper"

class Region < T::Struct
  const :number, Integer
  const :color, T.nilable(Symbol)
end

class Page < T::Struct
  const :regions, T::Array[Region]
end

class BlankBook < T::Struct
  const :pages, T::Array[Page], default: []
  const :color_map, T::Hash[Integer, Symbol], default: {}
end

class PaintedBook < T::Struct
  const :pages, T::Array[Page], default: []
  const :author, String
end

class AssemblesBook
  extend T::Sig

  sig { params(blank_book: BlankBook, author: String, painted_regions: T::Array[Region]).returns(PaintedBook) }
  def assemble(blank_book, author:, painted_regions:)
    PaintedBook.new(pages: [], author: author)
  end
end

class MatchesPaint
  extend T::Sig

  sig { params(number: Integer).returns(Symbol) }
  def match(number)
    :a_color
  end
end

class PaintsRegion
  extend T::Sig

  sig { params(region: Region, color: Symbol).returns(Region) }
  def paint(region, color)
    Region.new(number: region.number, color: color)
  end
end

class PaintsByNumber
  extend T::Sig

  sig { void }
  def initialize
    @matches_paint = T.let(MatchesPaint.new, MatchesPaint)
    @paints_region = T.let(PaintsRegion.new, PaintsRegion)
    @assembles_book = T.let(AssemblesBook.new, AssemblesBook)
  end

  sig { params(blank_book: BlankBook, author: String).returns(PaintedBook) }
  def paint(blank_book, author:)
    regions = blank_book.pages.flat_map { |page| page.regions }

    colors = regions.map(&:number).uniq.map { |number|
      [number, @matches_paint.match(number)]
    }.to_h

    painted_regions = regions.map { |region| @paints_region.paint(region, colors.fetch(region.number)) }

    @assembles_book.assemble(blank_book, painted_regions: painted_regions, author: author)
  end
end

class PaintByNumberTest < Minitest::Test
  extend T::Sig

  sig { params(name: String).void }
  def initialize(name)
    super
    @matches_paint = T.let(Mocktail.of_next(MatchesPaint), MatchesPaint)
    @paints_region = T.let(Mocktail.of_next(PaintsRegion), PaintsRegion)
    @assembles_book = T.let(Mocktail.of_next(AssemblesBook), AssemblesBook)

    @subject = T.let(PaintsByNumber.new, PaintsByNumber)
  end

  sig { void }
  def test_paints_by_number
    blank_book = BlankBook.new(pages: [
      Page.new(regions: [
        region_1 = Region.new(number: 1),
        region_2 = Region.new(number: 2)
      ]),
      Page.new(regions: [region_3 = Region.new(number: 3)])
    ])
    region_1_painted = Region.new(number: 1)
    region_2_painted = Region.new(number: 2)
    region_3_painted = Region.new(number: 3)
    stubs { @matches_paint.match(1) }.with { :orange }
    stubs { @matches_paint.match(2) }.with { :green }
    stubs { @matches_paint.match(3) }.with { :blue }
    stubs { @paints_region.paint(region_1, :orange) }.with { region_1_painted }
    stubs { @paints_region.paint(region_2, :green) }.with { region_2_painted }
    stubs { @paints_region.paint(region_3, :blue) }.with { region_3_painted }
    expected_painted_book = PaintedBook.new(pages: [], author: "Doesn't matter")
    stubs { @assembles_book.assemble(blank_book, author: "Juice", painted_regions: [region_1_painted, region_2_painted, region_3_painted]) }.with { expected_painted_book }

    result = @subject.paint(blank_book, author: "Juice")

    assert_equal result, expected_painted_book
  end
end
