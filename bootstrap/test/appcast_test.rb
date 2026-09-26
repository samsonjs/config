# frozen_string_literal: true

require_relative "test_helper"

class AppcastTest < Minitest::Test
  XML = <<~XML
    <?xml version="1.0" encoding="utf-8"?>
    <rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
      <channel>
        <item>
          <title>20260920.214100</title>
          <enclosure url="http://mudge:8787/sereno/Sereno-20260920.214100.zip" sparkle:version="20260920.214100" length="1" type="application/octet-stream"/>
          <sparkle:deltas>
            <enclosure url="http://mudge:8787/sereno/Sereno-20260920.214100-from-20260919.zip" sparkle:version="20260920.214100" sparkle:deltaFrom="20260919.000000" length="1"/>
          </sparkle:deltas>
        </item>
        <item>
          <title>20260924.034700</title>
          <enclosure url="http://mudge:8787/sereno/Sereno-20260924.034700.zip" sparkle:version="20260924.034700" length="1" type="application/octet-stream"/>
        </item>
      </channel>
    </rss>
  XML

  def test_the_newest_full_build_wins_regardless_of_item_order
    release = Bootstrap::Appcast.latest(XML)
    assert_equal "20260924.034700", release.version
    assert_equal "http://mudge:8787/sereno/Sereno-20260924.034700.zip", release.url
  end

  def test_an_empty_feed_is_an_error
    assert_raises(Bootstrap::Error) { Bootstrap::Appcast.latest("<rss><channel/></rss>") }
  end
end
