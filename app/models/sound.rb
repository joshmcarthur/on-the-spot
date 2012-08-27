module Sound
	def self.mute!
    Sound.change_to(0)
    $redis.set "sound_state", "muted"
  end

  def self.unmute!
    Sound.change_to(60)
    $redis.set "sound_state", "unmuted"
  end

  protected

  def self.change_to(volume = 0)
    if Platform.mac?
      `osascript -e "set Volume #{volume.zero?? volume : volume / 10}"`
    elsif Platform.linux?
      `amixer set Master #{volume}`
    else
      raise "Volume control is not supported in #{RUBY_PLATFORM}"
    end 
  end
end 