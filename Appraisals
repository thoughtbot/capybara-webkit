appraise "2.7" do
  gem "capybara", "~> 2.7.0"
  gem 'addressable', '< 2.5.0', :platforms=>[:ruby_19, :jruby_19] # 2.5 requires public_suffix which requires ruby 2.0
  gem 'nokogiri', '< 1.7.0', :platforms=>[:ruby_19, :jruby_19] # 1.7.0 requires ruby 2.1+
end

appraise "2.11" do
  gem "capybara", "~> 2.11.0"
  gem 'addressable', '< 2.5.0', :platforms=>[:ruby_19, :jruby_19] # 2.5 requires public_suffix which requires ruby 2.0
  gem 'nokogiri', '< 1.7.0', :platforms=>[:ruby_19, :jruby_19] # 1.7.0 requires ruby 2.1+
end

appraise "master" do
  gem "capybara", github: "jnicklas/capybara"
end
