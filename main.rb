# This will be the main function
def fill_2d_array_with_noise(parameters)
  #x counts from left to right, starting at 0
  #y counts from up to down, starting at 0
  world = Array.new(parameters[:x_size]) {|x| Array.new(parameters[:y_size]) {|y| x + 10*y} }
  if parameters[:method] == 'perlin'
  elsif parameters[:method] == 'worley'
  elsif parameters[:method] == 'diamond-square'
  end
  return world 
end

# Print an array of arrays (all assumed to be the same size) as a list of columns
def print_2d_array(world)
  world[0].each_with_index do |entry, row_number|
    world.each do |column|
      print "#{column[row_number]}"
      number_of_padding_spaces = 4 - column[row_number].to_s.size
      number_of_padding_spaces.times do
        print ' '
      end
    end
    print "\n"
  end
end

def test_me_with(parameters)
  print_2d_array(fill_2d_array_with_noise(parameters))
end

test_me_with({x_size: 10, y_size: 10, method: 'blank'})
