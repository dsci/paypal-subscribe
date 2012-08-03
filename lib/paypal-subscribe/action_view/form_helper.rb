require 'active_support/core_ext/array/extract_options'

module ActionView
  module Helpers
    module FormTagHelper
      # PUBLIC Rails view helper to generate a PayPal subscription form.
      # 
      # Generated output will be something like this:
      #
      # <form action="https://www.sandbox.paypal.com/cgi-bin/webscr" method="post">
      #   <input type="hidden" name="cmd" value="_xclick-subscriptions">
      #   <input type="hidden" name="business" value="selle__1343901688_biz@gmail.com">
      #   <input type="hidden" name="item_name" value="Baseball Hat Monthly">
      #   <input type="hidden" name="image_url" value="https://www.yoursite.com/logo.gif">
      #   <input type="hidden" name="no_shipping" value="1">
      #   <input type="hidden" name="return" value="http://www.yoursite.com/thankyou.htm">
      #   <input type="hidden" name="cancel_return"     #   value="http://www.yoursite.com/cancel.htm">
      #   <input type="hidden" name="a3" value="3.99">
      #   <input type="hidden" name="p3" value="1">
      #   <input type="hidden" name="t3" value="M">
      #   <input type="hidden" name="src" value="1">
      #   <input type="hidden" name="sra" value="1">
      #   <input type="hidden" name="srt" value="12">
      #   <input type="hidden" name="no_note" value="1">
      #   <input type="hidden" name="custom" value="customcode">
      #   <input type="hidden" name="invoice" value="invoicenumber">
      #   <input type="hidden" name="currency_code" value="EUR" >
      #   <input type="image" src="http://images.paypal.com/images/x-click-but01.gif" border="0" name="submit" alt="Make payments with PayPal - it’s fast, free and secure!">
      # </form>
      # 
      # * args - a list of arguments that includes an options hash:
      #   * image  -  The name of the image which is used within submit button.
      #               Note that the image should be just a name which is accesible
      #               through the asset pipeline
      #   * alt    -  The alt tag content for the button
      # Other configurations should be made in Rails.root/config/initializers
      #
      # Returns a HTML form.  
      def paypal_subscribe_button(*args)
        options = args.extract_options!
        id      = options.fetch(:id, "paypal_submit")
        paypal_uri = PaypalSubscribe.paypal_url
        paypal_form = form_tag(paypal_uri, :method => "POST")

        paypal_form += hidden_field_tag("cmd", "_xclick-subscriptions")
        
        config = PaypalSubscribe.paypal_config
        callbacks = []
        callbacks << {:return => config.delete(:return)}
        callbacks << {:cancel_return => config.delete(:cancel_return)}
        callbacks << {:notify_url => config.delete(:notify_url)}

        config.each_pair do |key,value|
          paypal_form += hidden_field_tag("#{key}", value)
        end

        callbacks.each do |callback_config|
          callback_config.each_pair do |key,value|
            paypal_form += hidden_field_tag(key,self.send("#{value}_url"))
          end
        end

        image_source = asset_path(options[:image])

        paypal_form += image_submit_tag(image_source, 
                                        { :alt => options[:alt],
                                          :name => "submit",
                                          :id => id
                                        })

        paypal_form
      end
      alias_method :paypal_subscribe_form,:paypal_subscribe_button
    end
  end

end