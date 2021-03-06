# Safetypay

Ruby SDK for Safetypay API

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'safetypay'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install safetypay

## Usage

#### 1. Initiate the Client

```ruby
Safetypay::Client.configure do |config|
    config.api_key = '...'
    config.signature_key = '...'
    config.environment = :production | anything else will go to sandbox
end
```

#### 2. Create an ExpressTokenRequest

```ruby
# Default Currency is BRL, but it can be overriden
# Default Language is PT, but it can overriden
request = Safetypay::ExpressTokenRequest.new({
    MerchantSalesID: 'Order #12345',
    ExpirationTime: 60, # (in minutes)
    ShopperEmail: 'shopper@domain.com',
    Amount: 101.35,
    TransactionOkURL: '...', # redirect the user to this URL, upon successful transaction
    TransactionErrorURL: '...', # redirect the user to this URL, upon failed transaction
})
```

#### 3. Create An Express Token using the ExpressTokenRequest
```ruby
express_token = Safetypay::Client.create_express_token(request: request)
=> #<Safetypay::ExpressToken shopper_redirect_url="https://sandbox-gateway.safetypay.com/Express4/Checkout/index?TokenID=0a93f62b-f7eb-4e9c-acfb-1e41e905b97d" error_manager={:error_number=>0, :description=>"No Error"}>
```

```ruby
express_token.invalid? => false
express_token.valid? => true
express_token.error_manager => { error_number: 0, description: 'Some Message' }
```

#### 4. Get a List of Unconfirmed Transactions

```ruby
operations = Safetypay::Client.get_new_operations_activity
```

Any given `Safetypay::Operation` has following attributes:

```ruby
Safetypay::Operation#id
Safetypay::Operation#operation_id
Safetypay::Operation#merchant_sales_id
Safetypay::Operation#merchant_order_id
Safetypay::Operation#creation_date_time
Safetypay::Operation#amount
Safetypay::Operation#currency_id
Safetypay::Operation#shopper_currency_id
Safetypay::Operation#confirm!
```

#### 5. Check if a Transaction is Paid?

```ruby
operations = Safetypay::Client.get_new_operations_activity
operations.first.paid?
```

#### 6. Confirm a Transaction

```ruby
operations = Safetypay::Client.get_new_operations_activity
operation = operations.first
if operation.paid?
  operation.confirm!
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/metaware/safetypay. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Safetypay project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/metaware/safetypay/blob/master/CODE_OF_CONDUCT.md).
