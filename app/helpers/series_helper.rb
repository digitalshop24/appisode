module SeriesHelper

  def on_air?(date)
    if date >= Time.zone.now.to_s.slice(0..9)
      true
    else
      false
    end
  end

end