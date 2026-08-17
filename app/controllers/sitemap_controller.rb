class SitemapController < ApplicationController
  STATIC_ROUTES = %i[
    how_it_works_url help_center_url contact_url safety_tips_url
    faqs_url privacy_policy_url terms_of_service_url cookie_policy_url
    community_guidelines_url
  ].freeze

  def show
    @static_urls = STATIC_ROUTES.map { |route| send(route) }
    @categories = Category.visible.order(:name)
    @listings = Listing.available.order(updated_at: :desc).limit(5000)

    respond_to do |format|
      format.xml
    end
  end
end
