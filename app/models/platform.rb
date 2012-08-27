module Platform
	def self.mac?
		::RUBY_PLATFORM.downcase.include?("darwin")
	end

	def self.windows?
		::RUBY_PLATFORM.downcase.include?("mswin")
	end

	def self.linux?
		::RUBY_PLATFORM.downcase.include?("linux")
	end
end