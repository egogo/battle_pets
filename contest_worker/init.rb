require 'bundler'

Bundler.require

require 'sidekiq/api'

require_relative 'workers/contest_worker'