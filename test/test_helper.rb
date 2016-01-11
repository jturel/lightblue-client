require 'coveralls'
lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Coveralls.wear!

require 'pry'

require 'lightblue'
require 'ast_helper'
require 'minitest/autorun'
