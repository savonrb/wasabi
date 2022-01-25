# Wasabi

A simple WSDL parser.

[![Test](https://github.com/savonrb/wasabi/actions/workflows/test.yml/badge.svg)](https://github.com/savonrb/wasabi/actions/workflows/test.yml)
[![Gem Version](https://badge.fury.io/rb/wasabi.svg)](http://badge.fury.io/rb/wasabi)
[![Code Climate](https://codeclimate.com/github/savonrb/wasabi.svg)](https://codeclimate.com/github/savonrb/wasabi)
[![Coverage Status](https://coveralls.io/repos/savonrb/wasabi/badge.svg?branch=master)](https://coveralls.io/r/savonrb/wasabi)

## Installation

Wasabi is available through [RubyGems](http://rubygems.org/gems/wasabi) and can be installed via:

```
$ gem install wasabi
```

Probably, you are using this gem as a dependency of some other gem. But, if you want to control which version of Wasabi to pick, you can add a `gem` line to your `Gemfile`:

```
gem "wasabi"
```


## Getting started

```ruby
document = Wasabi.document File.read("some.wsdl")
```

Get the SOAP endpoint:

```ruby
document.endpoint
# => "http://soap.example.com"
```

Get the target namespace:

```ruby
document.namespace
# => "http://v1.example.com"
```

Check whether elementFormDefault is set to `:qualified` or `:unqualified`:

```ruby
document.element_form_default
# => :qualified
```

Get a list of available SOAP actions (snakecase for convenience):

```ruby
document.soap_actions
# => [:create_user, :find_user]
```

Get a map of SOAP action Symbols, their input tag and original SOAP action name:

```ruby
document.operations
# => { :create_user => { :input => "createUser", :action => "createUser" },
# =>   :find_user => { :input => "findUser", :action => "findUser" } }
```
