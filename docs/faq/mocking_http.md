# Mocking out network requests by faking HTTP

Mocktail does nothing to make faking HTTP requests easy. And if you care to try,
know that it also does nothing to ensure mocked requests behave consistently
across various HTTP libraries and gems (`Net::HTTP`, faraday, httparty, etc.).
In fact, other gems are designed to do this and only this, most notably
[webmock](https://github.com/bblimke/webmock).

But, if you're reading this, there's a _small chance_ you're thinking about
faking out the network in the context of something you're conceiving of as a
unit test, and that's why you're looking to your mocking library for an answer.
If that's the case, here's a quick note on why you might be trying to apply
the wrong solution to the problem.

Suppose you're writing a unit test and trying to control for the network and
thinking about using a library like Mocktail as a result. To illustrate: imagine
you're testing a method that makes a network request and does one thing if the
response succeeds and another thing to handle failures.

You might want to write these two test cases:

```ruby
def test_success
  result = @subject.hack_computer("/school_sprinklers")

  assert_equal "Mess with the best, die like the rest", result
end

def test_failure
  assert_raises(CrashOverrideError) do
    @subject.hack_computer("/the_gibson")
  end
end
```

But you may not have an easy way to force the first test case to always exercise
the happy path in which the request succeeds. Similarly, you would need a way to
ensure the other test case to consistently travels the sad path wherein the
request fails. Short of spinning up a fake HTTP service, you don't have a lot
of options, especially if your implementation looks anything like this:

```ruby
class Computer
  SICK_BURN = "Mess with the best, die like the rest"

  def hack_computer(target)
    uri = URI.parse("https://example.com#{target}")
    req = Net::HTTP::Post.new(uri)

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(req) do |res|
        if Net::HTTPSuccess === res
          return SICK_BURN
        else
          raise CrashOverrideError
        end
      end
    end
  end
end
```

This case is so simple that it may strain credulity, but instead of trying to
introduce a network-layer mock to your application-layer concern, you might
consider writing a [wrapper](../support/glossary.md#wrapper-object) around the
`Net::HTTP` API that you don't control and can't change that your application
can invoke wherever it needs to make a network request. Then, instead of your
test needing to mock out the entire networking stack, it just needs to _mock out
the wrapper_ instead.

Here's what the refactored [subject](../support/glossary.md#subject-under-test)
could look like if we extracted its usage of `Net::HTTP` into an `Http` wrapper
that we own:

```ruby
class Computer
  SICK_BURN = "Mess with the best, die like the rest"

  def initialize
    @http = Http.new
  end

  def hack_computer(target)
    if @http.post("https://example.com#{target}").success?
      return SICK_BURN
    else
      raise CrashOverrideError
    end
  end
end

class Http
  Result = Data.define(:json, :success?)

  def post(url)
    uri = URI.parse(url)
    req = Net::HTTP::Post.new(uri)

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(req) do |res|
        return Result.new(
          data: JSON.parse(res.body),
          success?: Net::HTTPSuccess === res
        )
      end
    end
  end
end
```

Now, the test will be much easier to implement, because instead of trying to
figure out how to mock out all of HTTP, we're simply mocking out an object that
quacks just like any other object—leaving the fact that it crosses a spooky
network boundary as a mere implementation detail that `Computer`'s test doesn't
need to worry about.

Now, a complete test could fully cover the subject with minimally-invasive
mocking:

```ruby
def initialize
  @http = Mocktail.of_next(Http)

  @subject = Computer.new
end

def test_success
  stubs { Http.post("/school_sprinklers") }.with { Computer::Result.new(data: nil, success?: true) }

  result = @subject.hack_computer("/school_sprinklers")

  assert_equal "Mess with the best, die like the rest", result
end

def test_failure
  stubs { Http.post("/the_gibson") }.with { Computer::Result.new(data: nil, success?: false) }

  assert_raises(CrashOverrideError) do
    @subject.hack_computer("/the_gibson")
  end
end
```
