class Helper
  def url_name
    fetch(:url_name, fetch(:application))
  end  
end