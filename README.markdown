This is the ruby notifier library for integration your app with the Yeller exception notifier.

When an uncaught exception occurs, you can use this library to log the
exception to Yeller's servers, letting you easily diagnose exceptions in your
running app.

# Integration

Note that `yeller_ruby` is a low-level client, and doesn't include
integrations with web frameworks, background job systems, etc.

## Adding to your project

`yeller_ruby` is distributed via rubygems. If you use bundler, add it to your Gemfile:

```ruby
gem "yeller_ruby"
```

Otherwise you can install it:

```bash
gem install yeller_ruby
```

## Integrating

Once you've got the gem installed, you'll need to setup a Yeller client. This means you'll need the api key from your Yeller project (which you can find on your project's setting screen). Once you have the api key, you can create a client like this:

```ruby
yeller_client = Yeller.client do |client|
  client.token = "YOUR_TOKEN_HERE"
end
```

To report an exception, pass it into `client#report`. That's all you need for
basic usage, after that the exception will be reported to the server, with it's
stacktrace, message, type, the current host etc.

### Report your own exception

```ruby
begin
  # your code here
rescue StandardError => e
  yeller_client.report(e)
end
```

### Reporting more data

Often when you want to report an exception, you have some additional data to
report with it. For example, in a web application, the http request that you
were processing when an exception was thrown would be helpful when debugging
said exception. Yeller supports this, you can pass a hash of additional data to
`Yeller::Client#report`, as a ```:custom_data``` option:

```ruby
begin
  # your code here
rescue StandardError => e
  yeller_client.report(e, :custom_data => {:params => request.params})
end
```

### Other customizable fields

Yeller supports a few other customizable fields.

For web applications, you can report the `url` you were processing:

```ruby
yeller_client.report(e, :url => 'http://example.com/posts/1')
```

You can report the `location` the exception happened at. In a web application,
this might be the controller action the exception ocurred in, for background
jobs, the job class/queue:

```ruby
yeller_client.report(e, :location => 'BillingController#update')
```

All of those fields are optional.

### Configuration

```yeller_ruby``` supports a few configuration options outside of the api token. You can
change which servers you report to, override the hostname that's reported, or
override the environment:

```ruby
yeller_client = Yeller.client do |client|
  client.token = 'YOUR_TOKEN_HERE'
  client.environment = 'production'
  client.host = 'myserver.example.com'

  # to remove the default set of yeller api servers:
  client.remove_default_servers

  # to add a custom https server:
  client.add_server 'example.com', 443

  # to add a custom insecure http server (not recommended,
  # and yellerapp.com's servers don't support http, for
  # security reasons. Mostly just used for testing.
  client.add_insecure_server 'example.com', 80
end
```

# Robustness

This client does some basic roundtripping/timeouts, so it can handle problems
with individual yeller servers. After trying all the servers twice, it will
stop reporting the current exception, then try each one again for the next one.

Note that in the case of network partitions, this can lead to an exception
being recorded multiple times, e.g. if a connection fails (leading to a socket
error) whilst reading the response from the api, but after the api has received
the error. We err on the side of double reporting errors rather than
potentially missing them.

## What happens if the yeller api throws an error?

If the yeller api fails after trying each server twice, the client will report
this error to it's error handler, which by default logs to stdout.

You can change this behaviour in the configuration:

```ruby
yeller_client = Yeller.client do |client|
  client.token = 'YOUR_TOKEN_HERE'
  client.environment = 'production'
  client.host = 'myserver.example.com'
  client.error_handler = YOUR_ERROR_HANDLER
end
```

`error_handler` is any object that responds to `handle`, a method that takes the http api error as it's sole argument. Yeller also ships with a logging error handler, so if you have a logger in your application already, you can use that:

```ruby
config.error_handler = Yeller::LogErrorHandler.new(your_logger)
```

## Integrations

`yeller_ruby` ships with two integrations out of the box: Rack and Rails:

## Rack

Because there isn't a decent way to pass a block into a rack middleware that you're using with `use` (in a way that doesn't look awful anyway), `Yeller::Rack` relies on a global instance of the yeller client. Configure it thusly:

```ruby
Yeller::Rack.configure do |config|
  config.token = 'YOUR API KEY HERE'
end
```

The config block takes all the same options as `Yeller.client` (indeed, it's directly passed into it). After configuration, simply use the middleware:

```ruby
use Yeller::Rack
```

For a sinatra example, you can see `examples/sinatra.rb` in this repo

## Rails

The Rails plugin relies on the same global instance of the client that the rack one does, only it configures it in a slightly different way:

```ruby
Yeller::Rails.configure do |config|
  config.token = 'YOUR API KEY HERE'
end
```

This also sets up the error logger for yeller as the Rails logger (see above for more about error loggers), and hooks into Rails via a railtie so that exceptions are caught correctly. Once you've done `Yeller::Rails.configure`, everything else should be automatic.
