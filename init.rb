ActiveSupport::Dependencies.load_once_paths \
  .delete(File.expand_path(File.dirname(__FILE__))+'/lib')

ActionController::Base.send(:include, HttpblFilters)
