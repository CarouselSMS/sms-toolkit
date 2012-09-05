# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'sms_toolkit/version'

Gem::Specification.new do |s|
  s.name        = 'sms_toolkit'
  s.version     =  SmsToolkit::VERSION.dup
  s.summary     = 'Collection of tools to help developing SMS applications.'
  s.files       = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
end