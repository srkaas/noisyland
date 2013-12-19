# 2D Array.
class Matrix
  attr_accessor :columns, :width, :height

  def initialize(width, height, &default_contents)
    @columns = Array.new(width) { |x| Array.new(height) { |y| default_contents.call(x, y) } }
    @width = width
    @height = height
  end
  def each_row
    @columns[0].each_with_index do |entry, row_number|
      current_row = []
      @columns.each do |column|
        current_row << column[row_number]
      end
      yield current_row
    end
  end
  def each_column
    @columns.each do |column|
      yield column
    end
  end
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

# This will be the main function
def matrix_with_noise(parameters)
  # x counts from left to right, starting at 0
  # y counts from up to down, starting at 0
  world = Matrix.new(parameters[:width], parameters[:height]) { |x, y| rand }
  if parameters[:method] == 'perlin'
  elsif parameters[:method] == 'worley'
  elsif parameters[:method] == 'diamond-square'
  end
  return world 
end

def test_me_with(parameters)
  matrix_with_noise(parameters).display
end

test_me_with({width: 5, height: 10, method: 'blank'})
