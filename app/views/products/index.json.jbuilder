
json.result do
  if params[:page].present?
    json.pagination do
      current = @products.current_page
      total = @products.total_pages
      per_page = @products.limit_value
      json.current current
      json.per_page per_page
      json.pages total
      json.count @products.total_count
      json.previous (current > 1 ? (current - 1) : nil)
      json.next (current == total ? nil : (current + 1))
    end
  end
  json.products do
    json.array! @products do |product|
      json.extract! product, :id, :title, :active, :discarded_at
      json.price number_to_currency(product.price)
      json.image_url Rails.application.routes.url_helpers.url_for(product.image) if product.image.attached?
    end
  end
end
