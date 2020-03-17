module Testimonials
  extend ActiveSupport::Concern
  include Admin2Helper

  def title_listing
    listing_title || t("admin.communities.transactions.not_available")
  end

  def customer_title
    p = starter
    unless p.deleted
      person_name(p)
    end
  end

  def customer_status
    customer = testimonial_from_starter
    if starter_skipped_feedback
      I18n.t("admin.communities.testimonials.status.skipped")
    elsif customer.present?
      if customer.blocked?
        I18n.t("admin.communities.testimonials.status.blocked")
      else
        customer.positive? ? 'Positive' : 'Negative'
      end
    else
      I18n.t("admin.communities.testimonials.status.waiting")
    end
  end

  def customer_positive?
    customer = testimonial_from_starter
    return nil unless customer.present?
    return nil if customer.blocked?

    customer.positive?
  end

  def customer_negative?
    customer = testimonial_from_starter
    return nil unless customer.present?
    return nil if customer.blocked?

    !customer.positive?
  end

  def customer_text
    testimonial_from_starter&.text
  end

  def provider_text
    testimonial_from_author&.text
  end

  def provider_title
    p = listing_author
    unless p.deleted
      person_name(p)
    end
  end

  def provider_status
    provider = testimonial_from_author
    if author_skipped_feedback
      I18n.t("admin.communities.testimonials.status.skipped")
    elsif provider.present?
      if provider.blocked?
        I18n.t("admin.communities.testimonials.status.blocked")
      else
        provider.positive? ? 'Positive' : 'Negative'
      end
    else
      I18n.t("admin.communities.testimonials.status.waiting")
    end
  end

  def provider_positive?
    provider = testimonial_from_author
    return nil unless provider.present?
    return nil if provider.blocked?

    provider.positive?
  end

  def provider_negative?
    provider = testimonial_from_author
    return nil unless provider.present?
    return nil if provider.blocked?

    !provider.positive?
  end
end
