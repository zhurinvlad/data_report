# frozen_string_literal: true
require "data_report/version"

# load Rails/Railtie
begin
  require 'rails'
rescue LoadError
  #do nothing
end

module DataReport
  # Your code goes here...
  class Engine < ::Rails::Engine
    # isolate_namespace PdfInvoice
  end
end

# load DataReport components
require 'data_report/config'
require 'data_report/utils'
