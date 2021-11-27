
gem:: xmms2_utils.gemspec
	gem build $<

install::
	gem install --force --local --user xmms2_utils-*.gem
