xml.instruct! :xml, version: "1.0"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc root_url
    xml.changefreq "daily"
    xml.priority "1.0"
  end

  @static_urls.each do |url|
    xml.url do
      xml.loc url
      xml.changefreq "monthly"
      xml.priority "0.5"
    end
  end

  @categories.each do |category|
    xml.url do
      xml.loc listings_url(category_id: category.id)
      xml.changefreq "daily"
      xml.priority "0.7"
    end
  end

  @listings.each do |listing|
    xml.url do
      xml.loc listing_url(listing)
      xml.lastmod listing.updated_at.iso8601
      xml.changefreq "weekly"
      xml.priority "0.6"
    end
  end
end
