watch( 'spec/(.*)_spec\.rb' ) {|md| system ("rspec #{md[0]} --color --format doc") }
