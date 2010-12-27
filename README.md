fastr-compress
================

*fastr-compress* is a plugin for [fastr](http://github.com/chrismoos/fastr) that will compress a Rack response body.

how it works
-------------

The plugin is called after a Rack response has been returned from your application. It will inspect the **Accept-Encoding** header and attempt to encode the response's body if possible. Currently gzip and deflate are supported.

usage
--------

Add *fastr-compress* to your Gemfile

    source "http://rubygems.org"
    gem 'fastr-compress'
    ...

Enable the plugin in your fastr application by modifying your **app/config/settings.rb** file

    config.plugins << Fastr::Compress

limitations
---------------

Currently asynchronous/streaming responses are not supported.
