## paypal-subscribe

Dealing with PayPal is hell. It's nice to use it as customer. But implementing its API isn't very nice. 
Unfortunately in Germany there is no support for PayPal's recurring payment API on the part of PayPal. 

Before smashing my head against the wall, I decided to use their offer of creating a **subscription** button. 

But that's hell too. Doing it once, and when I need another one, generating a new one - and it's not sure if this is working well at this time? 

That is why this gem comes along. Drop it in your Rails app. Add some lines of configuration. Add the helper to the view. Done. 

### Installation

```ruby
gem 'paypal-subscribe', :git => "git@github.com:dsci/paypal-subscribe.git"
```

to your Gemfile. (It's not released via RubyGems)

### Configuration

Add a <code>paypal.rb</code> file in your <code>#{Rails.root}/config/initializers</code>

Copy and paste this:

```ruby
PaypalSubscribe.setup do |config|

  # Your PayPal ID or an email address associated with your PayPal account. 
  # Email addresses must be confirmed.
  config.business = "selle__1343901688_biz@gmail.com"
  
  # Do not prompt buyers to include a note with their payments
  config.no_note = true

  # Description of item being sold. If you are collecting aggregate payments, 
  # the value can be a summary of all items purchased, a tracking number, or 
  # a generic term such as “subscription.” If this variable is omitted, buyers
  # see a field in which they can enter the item name.
  config.item_name = "Grreeeat Magazine"

  # Regular subscription price.
  config.a3 = 5.99

  # Subscription duration. Specify an integer value in 
  # the allowable range for the units of duration that you specify with t3.
  config.p3 = 1
  
  # Regular subscription units of duration. 
  #
  # Allowable values are: 
  #
  #  D – for days; allowable range for p3 is 1 to 90 
  #  W – for weeks; allowable range for p3 is 1 to 52 
  #  M – for months; allowable range for p3 is 1 to 24 
  #  Y – for years; allowable range for p3 is 1 to 5 
  config.t3 = "M"

  # Recurring payments. Subscription payments recur unless subscribers cancel
  # their subscriptions before the end of the current billing cycle or you 
  # limit the number of times that payments recur with the value that you 
  # specify for srt.
  # 
  # true or false
  config.src = true

  # Reattempt on failure. If a recurring payment fails, PayPal attempts to 
  # collect the payment two more times before canceling the subscription.
  #
  # true or false
  config.sra = true

  # Recurring times. Number of times that subscription payments recur. 
  # Specify an integer with a minimum value of 1 and a maximum value 
  # of 52. Valid only if you specify src="1".
  config.srt = 12

  # Extend config options which ever you want. 
  # See 
  # https://cms.paypal.com/us/cgi-bin/?cmd=_render-content&content_ID=developer/e_howto_html_Appx_websitestandard_htmlvariables
  # 
  # This has to be a lambda:
  #
  # config.additional_values = ->(config) do
  #        config[:modify] = value_for_modify
  #
  #        return config
  #      end
  # And it has to return the config object!
  #
  # config.additional_values= lambda { |config| }
end
```

I added just a few configs which I need and which are required. You can extend the form options by adding a lambda to <code>config.additional_values</code>.

Currency defaults to <code>EUR</code>. But is changeable via <code>config.currency_code</code>. 

See more at [PayPal](https://cms.paypal.com/us/cgi-bin/?cmd=_render-content&content_ID=developer/e_howto_html_Appx_websitestandard_htmlvariables)

For more informations which options are already included see [here](https://github.com/dsci/paypal-subscribe/blob/master/lib/paypal-subscribe.rb)

Open your view and put a helper in it:

```ruby
<%=paypal_subscribe_form :image => "logo.png", :alt => "Button description"%>
```

To use a ordinary button instead of an image use:

```ruby
<%= paypal_subscribe_form :button => true, :value => "Pay with Paypal", 
                          :html => {:class=> "btn btn-alert"} %>
``


**Note** that image is just a file (name) which should be accessible through the asset pipeline.

## Callbacks

The gem provides three default callbacks:

* success
* failure
* notify

To get use of this callbacks you have to define named routes like this. 

```ruby
scope :module => "transactions" do
    match "/paypal/success" => "paypal#paypal_success", :as => :paypal_success
    match "/paypal/failure" => "paypal#paypal_failure", :as => :paypal_failure
    match "/paypal/notify"  => "paypal#paypal_notify",  :as => :paypal_notify
  end
```

**paypal-subscribe** default to:

* <code>paypal_success</code> on *return*
* <code>paypal_failure</code> on *cancel_return*
* <code>paypal_notify</code> on *notify*

If you are fine with that, all is done. 

If you are not fine with that, assign your custom routes within the config block:

```ruby
config.success_callback = :my_own_success_callback_route
config.failure_callback = :my_own_failure_callback_route
config.paypal_notify    = :my_own_notify_callback_route
```

## Contributors

Thanks to Paavo Leinonen <paavo@dealmachine.net>. 

## Contributing to paypal-subscribe
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2012 Daniel Schmidt. See LICENSE.txt for
further details.

