# frozen_string_literal: true

class PagesController < ApplicationController
  def how_it_works
    render "pages/how_it_works"
  end

  def help_center
    render "pages/help_center"
  end

  def contact
    render "pages/contact"
  end

  def safety_tips
    render "pages/safety_tips"
  end

  def faqs
    render "pages/faqs"
  end

  def privacy_policy
    render "pages/privacy_policy"
  end

  def terms_of_service
    render "pages/terms_of_service"
  end

  def cookie_policy
    render "pages/cookie_policy"
  end

  def community_guidelines
    render "pages/community_guidelines"
  end
end
