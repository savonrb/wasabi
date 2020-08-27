# 3.6.1 (2020-08-27)

- Fix: Repair unlinked Markdown in the CHANGELOG
- Add: Link to the CHANGELOG in the RubyGems.org metadata
- Add: Link to the Rubydocs.info documentation in the RubyGems.org metadata

# 3.6.0 (2020-08-27)

- Add: Support RPC-encoded WSDL ([#63](https://github.com/savonrb/wasabi/pull/63), [@fernandes][])
- Fix: Depend on [addressable](https://github.com/sporkmonger/addressable), for unescape to avoid a Ruby warning ([#81](https://github.com/savonrb/wasabi/pull/81) , [@chaymaeBZ][], [@bvicenzo][])
- Fix: [#59](https://github.com/savonrb/wasabi/issue/59) Turn `String` monkeypatches into `Wasabi` class methods ([@tjarratt][]) (released this version)
- Change: Reduced size of gem by focusing the files list ([#89](https://github.com/savonrb/wasabi/pull/89), [@utkarsh2102][])
- Remove: No longer tested on Rubinius

# 3.5.1 (2015-05-18)

NB: This version was never released to RubyGems.org.

* Fix: [#59](https://github.com/savonrb/wasabi/issue/59) Stop monkey patching the String class to provide #snakecase

# 3.5.0 (2015-03-31)

* Formally drop support for ruby 1.8.7

# 3.4.0 (2015-03-02)

* Fix: [#634](https://github.com/savonrb/savon/issues/634) Reverts PR #46, generates *most* operation names correctly.

# 3.3.1 (2014-09-25)

* Fix: [#48](https://github.com/savonrb/wasabi/issues/48) Remove dependency on mime-type gem

# 3.3.0 (2014-05-03)
* Feature: [#44](https://github.com/savonrb/wasabi/pull/44) adds a feature to specify the HTTPI adapter you'd like to use.

# 3.2.3 (2013-12-16)
* Fix [#39](https://github.com/savonrb/wasabi/pull/39) fixes new regression in operation names. Huge thank you to #leoping for investigating this and issuing a pull request.

# 3.2.2 (2013-12-09)

* Fix: [#32](https://github.com/savonrb/wasabi/issues/32) fixes a regression in operation names that was adversely affecting Savon: https://github.com/savonrb/savon/issues/520

# 3.2.1 (2013-12-05)

* Feature: Drops requirement for Nokogiri <= 1.6 for modern rubies. This was in place for ruby 1.8 but since support for that is going away, we shouldn't prevent users from using newer versions of Nokogiri.

## 3.2.0 (2013-07-26)

* Feature: [#20](https://github.com/savonrb/wasabi/issues/20) Limited support for listing an
  operation's parameters. Please note that if your WSDL defines imports, this method might
  not return all types.

* Improvement: [#7](https://github.com/savonrb/wasabi/issues/7) Major speed improvements.

* Improvement: [#16](https://github.com/savonrb/wasabi/issues/16) Various improvements regarding
  element order and type information.

* Fix: [#25](https://github.com/savonrb/wasabi/issues/25) Fixes a problem where Wasabi escaped
  an already escaped endpoint URL.

* Fix: [#15](https://github.com/savonrb/wasabi/issues/15) Fixes a bug where the operation tag
  name was not correctly extracted from the WSDL document.

## 3.1.0 (2013-04-21)

* Feature: [#22](https://github.com/savonrb/wasabi/issues/22) added `Wasabi::Document#service_name`
  to return the name of the SOAP service. Original issue: [savonrb/savon#408](https://github.com/savonrb/savon/pull/408).

* Fix: [#21](https://github.com/savonrb/wasabi/issues/21) when the Resolver gets an
  erroneous response (such as a 404), we now raise a more useful HTTPError.

* Fix: [#23](https://github.com/savonrb/wasabi/issues/23) ignore extension base elements
  defined in imports.

## 3.0.0 (2012-12-17)

* Updated to HTTPI 2.0 to play nicely with Savon 2.0.

## 2.5.1 (2012-08-22)

* Fix: [#14](https://github.com/savonrb/wasabi/issues/14) fixes an issue where
  finding the correct SOAP input tag and namespace identifier fails when portTypes
  are imported, since imports are currently not supported.

  The bug was introduced in v2.2.0 by [583cf6](https://github.com/savonrb/wasabi/commit/583cf658f1953411a7a7a4c22923fa0a046c8d6d)

* Refactoring: Removed `Object#blank?` core extension.

## 2.5.0 (2012-06-28)

* Fix: [#10](https://github.com/savonrb/wasabi/issues/10) fixes an issue where
  Wasabi used the wrong operation name.

## 2.4.1 (2012-06-18)

* Fix: [savonrb/savon#296](https://github.com/savonrb/savon/issues/296) fixes an issue where
  the WSDL message element doesn't have part element.

## 2.4.0 (2012-06-08)

* Feature: `Wasabi::Document` now accepts either a URL of a remote document,
  a path to a local file or raw XML. The code for this was moved from Savon over
  here as a first step towards supporting WSDL imports.

## 2.3.0 (2012-06-07)

* Improvement: [#3](https://github.com/savonrb/wasabi/pull/3) adds object inheritance.

## 2.2.0 (2012-06-06)

* Improvement: [#5](https://github.com/savonrb/wasabi/pull/5) - Get input from message
  element or portType input. See [savonrb/savon#277](https://github.com/savonrb/savon/pull/277)
  to get the full picture on how this all works together, and enables you to pass a single
  symbol into the `Savon::Client#request` method and get automatic namespace mapping, as well
  as the proper operation name -> input message mapping.

## 2.1.1 (2012-05-18)

* Fix: [issue 7](https://github.com/savonrb/wasabi/issues/7) - Performance regression.

## 2.1.0 (2012-02-17)

* Improvement: The value of elementFormDefault can now be manually specified/overwritten.

* Improvement: [issue 2](https://github.com/savonrb/wasabi/issues/2) - Allow symbolic endpoints
  like "http://server:port".

## 2.0.0 (2011-07-07)

* Feature: Wasabi can now parse type definitions and namespaces.
  Thanks to [jkingdon](https://github.com/jkingdon) for implementing this.

## 1.0.0 (2011-07-03)

* Initial version extracted from the [Savon](http://rubygems.org/gems/savon) library.
  Use it to build your own SOAP client and help to improve it!

[@fernandes]: https://github.com/fernandes
[@utkarsh2102]: https://github.com/utkarsh2102
[@tjarratt]: https://github.com/tjarratt
[@chaymaeBZ]: https://github.com/chaymaeBZ
[@bvicenzo]: https://github.com/bvicenzo
