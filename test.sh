#!/bin/bash

rm test_output.html
ruby directory_maker.rb reference_input.csv test_output.html
diff test_output.html reference_output.html

