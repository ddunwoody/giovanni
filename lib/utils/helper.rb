class Helper
  def url_name
    fetch(:war_file_name, fetch(:application))
  end  
end