require 'rubygems'
require 'bundler/setup'
require_relative 'keys.local.rb'
require 'unicorn'
require 'rack/cors'
require 'grape'
require 'json'
require 'time'
require 'net/http'
require 'uri'
require 'telegram/bot'
require 'telegram/bot/botan'
require 'google/apis/customsearch_v1'
require 'fastimage'
require 'fileutils'
require 'open-uri'
require 'pg'
require 'algoliasearch'
require 'wannabe_bool'
require 'mini_magick'
require 'mixpanel-ruby'
require 'logger'
require 'aws-sdk'
require 'mandrill'
