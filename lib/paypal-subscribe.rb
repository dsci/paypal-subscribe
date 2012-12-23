require 'bundler/setup'

begin 
  Bundler.setup
rescue 
  raise RuntimeError, "Bundler couldn't find some gems." + 
    "Did you run 'bundle install'?"
end

require 'active_support/core_ext/module/attribute_accessors'
require 'paypal-subscribe/action_view/form_helper'

module PaypalSubscribe

  extend self

  @production_uri = "https://www.paypal.com/cgi-bin/webscr"
  @sandbox_uri    = "https://www.sandbox.paypal.com/cgi-bin/webscr"

  @@paypal_config_hash = {}

  SHIPPING = {
      :address          => 0,
      :none             => 1,
      :require_address  => 2 
    }

  autoload :Errors, 'paypal-subscribe/errors'

  # INTERNAL - Form url. 
  #
  # For production environment:
  #  - https://www.paypal.com/cgi-bin/webscr
  # 
  # In any other environment it returns a sandbox link.
  def paypal_url
    if defined?(Rails.env)
      return Rails.env.eql?("production") ? @production_uri : @sandbox_uri
    else
      return @sandbox_uri
    end
  end

  # Your PayPal ID or an email address associated with your PayPal account. 
  # Email addresses must be confirmed.
  mattr_accessor :business
  @@business = "paypal@seller.com"

  # Description of item being sold. If you are collecting aggregate payments, 
  # the value can be a summary of all items purchased, a tracking number, or 
  # a generic term such as “subscription.” If this variable is omitted, buyers
  # see a field in which they can enter the item name.
  mattr_accessor :item_name
  @@item_name = "my awesome subscription"

  # The URL of the 150x50-pixel image displayed as your logo in the upper left 
  # corner of the PayPal checkout pages. 

  # Default – Your business name, if you have a PayPal Business account, or your 
  # email address, if you have PayPal Premier or Personal account.
  mattr_accessor :image_url
  @@item_name = "my_logo.png"

  # The paypal return config.
  # 
  # The URL to which PayPal redirects buyers’ browser after they complete their payments.
  # For example, specify a URL on your site that displays a “Thank you for your payment” page.
  #
  # Note that you have to define a named route:
  #
  # match '/mypaypal/success' => "transactions/success", :as => :paypal_success
  #
  # :paypal_success is default 
  #
  # Paypal returns params like this:
  # {"auth"=>"AwkacusGt-1J7vlbxI88Yi0D-BsC4mxY.lmJw9DtfsqDUnuCWN0O5oYv0gZ7QJO0mVnmAEhdEymQHTAP4skMN0w"}
  mattr_accessor :success_callback
  @@success_callback = :paypal_success

  # The paypal cancel return config
  #
  # A URL to which PayPal redirects the buyers’ browsers if they cancel checkout before 
  # completing their payments. For example, specify a URL on your website that displays 
  # a “Payment Canceled” page.
  # 
  # Note that you have to define a named route:
  #
  # match '/mypaypal/failure' => "transactions/failure", :as => :paypal_failure
  #
  # :paypal_success is default 
  mattr_accessor :failure_callback
  @@failure_callback = :paypal_failure
  
  # The Paypal ipn callback config
  #
  # The URL to which PayPal posts information about the payment,
  # in the form of Instant Payment Notification messages.
  #
  # Note that you have define a named route:
  #
  # match '/mypaypal/notification' => 'transaction/notify', :as => :paypal_notify
  #
  # :paypal_notify is default.
  mattr_accessor :notify_callback
  @@notify_callback = :paypal_notify

  # Regular subscription price.
  # mattr_accessor :a3

  # Regular subscription units of duration. 
  #
  # Allowable values are: 
  #
  #  D – for days; allowable range for p3 is 1 to 90 
  #  W – for weeks; allowable range for p3 is 1 to 52 
  #  M – for months; allowable range for p3 is 1 to 24 
  #  Y – for years; allowable range for p3 is 1 to 5
  mattr_accessor :t3

  # Subscription duration. Specify an integer value in 
  # the allowable range for the units of duration that you specify with t3.
  mattr_accessor :p3

  # Recurring payments. Subscription payments recur unless subscribers cancel
  # their subscriptions before the end of the current billing cycle or you 
  # limit the number of times that payments recur with the value that you 
  # specify for srt.
  # 
  # true or false
  mattr_reader :src
  def src=(value)
    @@src = no_able(value)
  end

  # Reattempt on failure. If a recurring payment fails, PayPal attempts to 
  # collect the payment two more times before canceling the subscription. 
  mattr_reader :sra
  def sra=(value)
    @@sra = no_able(value)
  end

  # Recurring times. Number of times that subscription payments recur. 
  # Specify an integer with a minimum value of 1 and a maximum value 
  # of 52. Valid only if you specify src="1".
  mattr_accessor :srt

  # Do not prompt buyers to include a note with their payments
  mattr_reader :no_note

  # Do not prompt buyers to include a note with their payments.
  def no_note=(value)
    @@no_note = no_able(value)
  end

  mattr_reader :no_shipping

  # Do not prompt buyers for a shipping address.  
  #
  # Allowable values are:
  #   :address – prompt for an address, but do not require one 
  #   :none - do not prompt for an address 
  #   :required_address – prompt for an address, and require one 
  def no_shipping=(value)
    @@no_shipping = SHIPPING[value]
  end

  # Pass-through variable you can use to identify your 
  # invoice number for this purchase
  mattr_accessor :invoice

  # The currency of the payment. Defaults to "EUR"
  mattr_accessor :currency_code
  @@currency_code = "EUR"
  
  # Extend config options which ever you want. 
  # See 
  # https://cms.paypal.com/us/cgi-bin/?cmd=_render-content&content_ID=developer/e_howto_html_Appx_websitestandard_htmlvariables
  # 
  # This has to be a lambda:
  #
  # PaypalSubscribe.additional_values = ->(config) do
  #        config[:modify] = value_for_modify
  #
  #        return config
  #      end
  def additional_values=(method)
    unless method.is_a?(Proc)
      raise Errors::ArgumentError.new("Expected a proc (lambda) as argument.") 
    else
      @@paypal_config_hash = method.call(@@paypal_config_hash)
    end
  end

  # INTERNAL - Builds the form config hash
  # 
  # Returns a hash with all config options.
  def paypal_config
    exceptionals = {:success_callback => :return, 
                    :failure_callback => :cancel_return,
                    :notify_callback  => :notify_url}
    self.class_variables.each do |c_var|
      key = c_var.to_s.gsub("@@","").to_sym
      unless key.eql?(:paypal_config_hash)
        if exceptionals.keys.include?(key)
          key = exceptionals[key]
        end
        @@paypal_config_hash[key] = self.class_variable_get(c_var)
      end
    end
    return @@paypal_config_hash
  end

  def setup(&block)
    yield(self)
  end

  private 

  def no_able(value)
    return  case value.class.name
              when "TrueClass" then 1
              when "FalseClass" then 0
              else value
            end
  end
end