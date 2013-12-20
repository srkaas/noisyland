# 2D Array.
class Matrix
  attr_accessor :columns, :width, :height

  def initialize(width, height, &default_contents)
    @columns = Array.new(width) { |x| Array.new(height) { |y| default_contents.call(x, y) } }
    @width = width
    @height = height
  end

  # Some custom iterators
  def each_row
    @columns[0].each_with_index do |entry, row_number|
      current_row = []
      @columns.each do |column|
        current_row << column[row_number]
      end
      yield current_row
    end
  end
  def each_row_with_index
    @columns[0].each_with_index do |entry, row_number|
      current_row = []
      @columns.each do |column|
        current_row << column[row_number]
      end
      yield current_row, row_number
    end
  end
  def each_column
    @columns.each do |column|
      yield column
    end
  end
  def each_column_with_index
    @columns.each_with_index do |column, column_number|
      yield column, column_number
    end
  end

  # Print the matrix
  def display
    each_row do |row|
      row.each do |entry|
        if entry.is_a?(Float)
          representation = sprintf('%.2f', entry)
        else
          representation = entry.to_s
        end
        print representation
        number_of_padding_spaces = 6 - representation.size
        number_of_padding_spaces.times do
          print ' '
        end
      end
      print "\n"
    end
  end
end

# Put enough random numbers in a matrix to fill the target matrix or, if the period is at least the matrix size, enough to make it not wrap around
def random_matrix_for_octave(octave_number, parameters)
  matrix_width = [2 ** octave_number + 1, parameters[:width]].max
  matrix_height = [2 ** octave_number + 1, parameters[:height]].max
  return Matrix.new(matrix_width, matrix_height + 1) { |x, y| rand }
end

# This will be the main function
def matrix_with_noise(parameters)
  if parameters[:method] == 'perlin'
    world = perlin(parameters)
  elsif parameters[:method] == 'worley'
  elsif parameters[:method] == 'diamond-square'
  end
  return world 
end

# Returns a matrix filled with Perlin noise starting from a random matrix with values between 0.0 and 1.0.
# Based on http://devmag.org.za/2009/04/25/perlin-noise/
def perlin(parameters)
  # First create and store each octave.
  octaves = []
  parameters[:octave_count].times do |octave_number|
    octaves << perlin_octave(octave_number, random_matrix_for_octave(octave_number, parameters))
  end

  # Mix the octaves together based on an amplitude that decreases exponentially according to a persistence parameter. 
  out_world = Matrix.new(parameters[:width], parameters[:height]) { |x, y| 0 }
  current_amplitude = 1.0
  total_amplitude = 0.0
  
  # Higher octaves (greater period, lower frequency) get more amplitude.
  octaves.reverse_each do |octave|
    current_amplitude *= parameters[:persistence]
    total_amplitude += current_amplitude
    out_world.each_column_with_index do |column, column_number|
      column.each_with_index do |entry, row_number|
        out_world.columns[column_number][row_number] += current_amplitude * octave.columns[column_number][row_number]
      end
    end
  end

  # Normalize the values to end up between 0 and 1.
  out_world.each_column_with_index do |column, column_number|
    column.each_with_index do |entry, row_number|
      out_world.columns[column_number][row_number] /= total_amplitude
    end
  end

  return out_world
end

# Fills a matrix with smoothed-out noise depending on octave number.
# Based on http://devmag.org.za/2009/04/25/perlin-noise/
def perlin_octave(octave_number, world)
  octave = Matrix.new(world.width, world.height) { |x, y| 0 }

  period = 2 ** octave_number
  frequency = 1.0 / period

  world.each_column_with_index do |column, column_number|
    # Set left and right indices to interpolate between.
    leftmost = (column_number / period) * period
    rightmost = (leftmost + period) % world.width
    horizontal_blend = (column_number - leftmost) * frequency
    column.each_with_index do |entry, row_number|
      # Set top and bottom indices to interpolate between.
      topmost = (row_number / period) * period
      bottommost = (topmost + period) % world.height
      vertical_blend = (row_number - topmost) * frequency
      top_value = interpolate(world.columns[leftmost][topmost], world.columns[rightmost][topmost], horizontal_blend)
      bottom_value = interpolate(world.columns[leftmost][bottommost], world.columns[rightmost][bottommost], horizontal_blend)
      octave.columns[column_number][row_number] = interpolate(top_value, bottom_value, vertical_blend)
    end
  end
  return octave
end

# Linear interpolation between two values. "weight" is the weight of the second value.
def interpolate(a, b, weight)
  return a * (1 - weight) + b * weight
end

def test_me_with(parameters)
  matrix_with_noise(parameters).display
end

test_me_with({width: 16, height: 32, method: 'perlin', octave_count: 4, persistence: 0.9})
