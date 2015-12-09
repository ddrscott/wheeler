#!/usr/bin/env ruby

require 'bundler/setup'
require 'wheeler'
require 'pry'

include Wheeler

puzzle = ARGV.shift || raise('First arg should be a string containing letters and underscores!')

guess(puzzle, ARGF)
