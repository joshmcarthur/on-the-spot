module Enumerable
  def sample
    self.sort_by { |element| rand }.first
  end
end