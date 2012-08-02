require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "PaypalSubscribe" do
  
  context "configuration section" do 
    
    subject{PaypalSubscribe}

    it{should respond_to :paypal_url}
    it{should respond_to :business}
    it{should respond_to :business=}
    it{should respond_to :item_name}
    it{should respond_to :item_name=}
    it{should respond_to :image_url}
    it{should respond_to :image_url=}
    it{should respond_to :success_callback}
    it{should respond_to :success_callback=}
    it{should respond_to :failure_callback}
    it{should respond_to :failure_callback=}
    it{should respond_to :a3}
    it{should respond_to :a3=}
    it{should respond_to :p3}
    it{should respond_to :p3=}
    it{should respond_to :t3}
    it{should respond_to :t3=}
    it{should respond_to :src}
    it{should respond_to :src=}
    it{should respond_to :sra}
    it{should respond_to :sra=}
    it{should respond_to :srt}
    it{should respond_to :srt=}
    it{should respond_to :no_note}
    it{should respond_to :no_note=}
    it{should respond_to :invoice}
    it{should respond_to :invoice=}
    it{should respond_to :currency_code}
    it{should respond_to :currency_code=}
    it{should respond_to :additional_values=}
    it{should respond_to :paypal_config}
    it{should respond_to :no_shipping}
    it{should respond_to :no_shipping=}
    
    context "defining additional_values" do 

      it "raises an error if argument is not a Proc" do
        expect do
          PaypalSubscribe.additional_values="sss"
        end.to raise_error(PaypalSubscribe::Errors::ArgumentError,
                        "Expected a proc (lambda) as argument.")
      end

      it "extends the configuration" do
        value_for_modify = 1
        PaypalSubscribe.additional_values = ->(config) do
          config[:modify] = value_for_modify

          return config
        end

        configs = PaypalSubscribe.paypal_config

        configs[:modify].should eq value_for_modify
      end

    end


  end

  context "configured" do

    before do

      PaypalSubscribe.setup do |config|
        config.business = "my@seller.com"
        config.no_note = true
      end

    end

    context "getting the config values hash" do

      subject{PaypalSubscribe.paypal_config}

      it "business is my@seller.com" do
        subject[:business].should eq "my@seller.com"
      end

      it "currency_code is 'EUR'" do
        subject[:currency_code].should eq "EUR"
      end

      it "not note is 1" do
        subject[:no_note].should eq 1
      end

      it "return is :paypal_success" do
        subject[:return].should eq :paypal_success
      end

      it "cancel is :paypal_failure" do
        subject[:cancel_return].should eq :paypal_failure
      end

    end

  end

end
