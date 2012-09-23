require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = Rails.root.join("spec", "vcr_cassettes")
  c.hook_into :fakeweb
  c.filter_sensitive_data('<OAUTHTOKEN>') { '00DU0000000H5Ip!AQQAQGhd1iZu8eGuVtCr667emTbJgvNSaSnjZ.Cobonjl7m8zHH3Af9U491FoxxQWoZDjHVi6Tms7ELqVVnlzXNsiWjxc40a' }
end