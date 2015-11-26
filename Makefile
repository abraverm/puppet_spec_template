.PHONY: install test clean
.DEFAULT: help
MODULE=`basename "${PWD}"`

help:
	@echo "This is a template for puppet modlues unit testing and syntax check.";\
	echo "Make sure to change the name "


install:
	@if [[ ! $$EUID -ne 0 ]]; then \
		RVMPATH="/usr/local/rvm";\
		RVMRC="/etc/rvmrc";\
	else \
		RVMPATH="${HOME}/.rvm";\
		RVMRC="${HOME}/.rvmrc";\
	fi; \
	if [[ $$(grep --exclude=Makefile "puppet_spec_template" -R .) ]]; then \
		echo "initialize the files with the new module name ${MODULE}" ;\
		find . ! -name 'Makefile' -type f -exec sed -i "s/puppet_spec_template/${MODULE}/g" {} + ;\
	fi ;\
	if [[ ! -e "$$RVMPATH/scripts/rvm" ]]; then \
		echo "Installing RVM";\
		gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 ;\
		curl -sSL https://get.rvm.io | bash -s stable --ruby ;\
	fi;\
	source "$$RVMPATH/scripts/rvm";\
	if [[ ! $$(grep "rvm_project_rvmrc=1" "$$RVMRC") ]]; then \
		echo "Setting RVM to allow each project to have own rvm settings";\
		cat .rvmrc >> "$$RVMRC";\
	fi;\
	if [[ ! $$(grep "bundler" "$$RVMPATH/gemsets/default.gems") ]]; then \
		echo "Setting RVM to install 'bundler' gem by default";\
		echo "bundler" >> "$$RVMPATH/gemsets/default.gems";\
	fi;\
	echo "Looking for required gems on the system: 'rspec-puppet' and 'wwtd'";\
	[[ $$(which rspec-puppet-init) ]] || gem install rspec-puppet ;\
	[[ $$(which wwtd) ]] || gem install wwtd ;\
	[[ $$(which puppet) ]] || gem install puppet ;\
	if [[ ! -e "Rakefile" || ! -d "spec" ]]; then \
		echo "initialize spec and Rakefile";\
		rspec-puppet-init;\
		sed -i '0,/^$$/{s//require \"wwtd\/tasks\"\n/g}' Rakefile ;\
		sed -i '0,/^$$/{s//require "rake\/testtask"\n/g}' Rakefile ;\
		sed -i '0,/^$$/{s//require "puppetlabs_spec_helper\/rake_tasks"\n/g}' Rakefile ;\
		sed -i '0,/^$$/{s//require "rake\/testtask"\n/g}' Rakefile ;\
		sed -i "s/^task :default =>.*/task :default => :wwtd/g" Rakefile ;\
		sed -i '0,/^$$/{s//require "puppetlabs_spec_helper\/module_spec_helper"\n/g}' spec/spec_helper.rb ;\
		sed -i '0,/^$$/{s//require "rspec-puppet-facts"\n/g}' spec/spec_helper.rb ;\
		sed -i '0,/^$$/{s//include RspecPuppetFacts\n/g}' spec/spec_helper.rb ;\
		echo "Creating example spec";\
		echo -e "require 'spec_helper'\n\n" \
				 		"describe '${MODULE}' do\n" \
						"		on_supported_os.each do |os, facts|\n" \
						"			context \"on #{os}\" do\n" \
						"				let(:facts) do\n" \
						"					facts\n" \
						"				end\n\n" \
				 		"	  		it { should contain_class('stdlib') }\n" \
						"			end\n" \
						"		end\n" \
				 		"end" > spec/classes/init_spec.rb ;\
	fi ;\
	echo "Everything is installed, to test run 'make test'"

test:
	@if [[ ! $$EUID -ne 0 ]]; then \
		RVMPATH="/usr/local/rvm";\
		RVMRC="/etc/rvmrc";\
	else \
		RVMPATH="${HOME}/.rvm";\
		RVMRC="${HOME}/.rvmrc";\
	fi; \
	if [[ -e "$$RVMPATH/scripts/rvm" ]]; then \
		source "$$RVMPATH/scripts/rvm";\
		wwtd -i env;\
	else \
		echo "run 'make install' first to prepare your system  for testing" ;\
	fi

clean:
	@if [[ ! $$EUID -ne 0 ]]; then \
		RVMPATH="/usr/local/rvm";\
		RVMRC="/etc/rvmrc";\
	else \
		RVMPATH="${HOME}/.rvm";\
		RVMRC="${HOME}/.rvmrc";\
	fi; \
	if [[ -e "$$RVMPATH/scripts/rvm" ]]; then \
		source "$$RVMPATH/scripts/rvm";\
		wwtd;\
	else \
		echo "run 'make install' first to prepare your system  for testing" ;\
	fi

purge:
	rm -rf Rakefile spec/spec_helper.rb .gemfiles/*.lock .bundle
