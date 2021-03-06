require_relative 'car'

class CarFactory
  attr_accessor :brands, :brands_counter

  class UnsupportedBrandException < StandardError
  end

  SUPPORTED_BRANDS = %i[fiat lancia ford subaru].freeze

  def initialize(factory_name, args = {})
    @brands_counter = 0
    @brands = args[:brands]
    check_if_brands_are_supported
    @factory_name = factory_name
  end

  def name
    "#{@factory_name} (produces #{formatted_brand_names})"
  end

  def make_cars(config)
    config.is_a?(Integer) ? make_n_cars(config) : make_cars_from_hash(config)
  end

  def make_car(brand = @brands)
    validate_given_brands(brand)
    Car.new(brand)
  end

  private

  def make_n_cars(amount = 1, brand = nil)
    created_cars = []
    amount.times do
      created_cars << if brand
                        make_car(brand)
                      else
                        make_car(brand_from_available_brands)
                      end
    end
    created_cars
  end

  def make_cars_from_hash(config = {})
    created_cars = []
    config.each do |brand, amount|
      next unless brand_available?(brand)
      created_cars << make_n_cars(amount, brand)
    end
    created_cars.flatten
  end

  def brand_available?(brand)
    brands.include?(brand)
  end

  def validate_given_brands(given_brands)
    return unless brands.is_a?(Array) && !brand_available?(given_brands)
    raise UnsupportedBrandException, 'Factory does not have a brand or do not support it'
  end

  def formatted_brand_names
    return brands.to_s.capitalize unless brands.is_a? Array
    brands.map { |b| b.to_s.capitalize }.join(', ')
  end

  def check_if_brands_are_supported
    if brands.is_a? Array
      brands.each { |brand| check_if_brand_is_supported(brand) }
    else
      check_if_brand_is_supported(brands)
    end
  end

  def check_if_brand_is_supported(brand)
    return if SUPPORTED_BRANDS.include? brand
    raise UnsupportedBrandException, "Brand not supported: '#{brand.capitalize}'"
  end

  def brand_from_available_brands
    return brands unless brands.is_a? Array
    picked_brand = brands[brands_counter]
    tick_brands_counter
    picked_brand
  end

  def tick_brands_counter
    return unless brands.is_a? Array
    self.brands_counter = brands_counter.next % brands.length
  end
end
