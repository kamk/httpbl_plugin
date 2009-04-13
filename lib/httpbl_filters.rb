module HttpblFilters

  SURNAMES = %w(Smith Johnson Williams Jones Brown Davis Miller Wilson Moore Taylor
                Anderson Thomas Jackson White Harris Martin Thompson Garcia Martinez Robinson
                Clark Rodriguez Lewis Lee Walker Hall Allen Young Hernandez King
                Wright Lopez Hill Scott Green Adams Baker Gonzalez Nelson Carter
                Mitchell Perez Roberts Turner Phillips Campbell Parker Evans Edwards Edwards)
  FIRST_NAMES = %w(James John Robert Michael William David Richard Charles Joseph Thomas
                   Christopher Daniel Paul Mark Donald George Kenneth Steven Edward Brian
                   Ronald Anthony Kevin Jason Jeff
                   Mary Patricia Linda Barbara Elizabeth Jennifer Maria Susan Margaret Dorothy
                   Lisa Nancy Karen Betty Helen Sandra Donna Carol Ruth Sharon
                   Michelle Laura Sarah Kimberly Deborah)
  
  @@ip_cache = Hash.new
  
  def self.included(base)
    base.extend(ClassMethods)
    base.helper_method :mail_to
  end
  

  module ClassMethods
    require 'httpBL'
    attr_reader :httpbl_checker
  
    def httpbl_key(key)
      @httpbl_checker = HttpBl.new(key)
    end

    def httpbl_options
    end
  end
  
  
  def mail_to(email_address, name = nil, html_options = {})
    return url_helper.mail_to(email_address, name, html_options) \
      unless httpbl_harvester_visiting?
    
    first_name = FIRST_NAMES[rand(50)]
    first_name = first_name[0..0] if coinhead?
    last_name = SURNAMES[rand(50)]
    sep = {0 => "", 1 => ".", 2 => "_"}[rand(3)]
    e = coinhead? ? first_name + sep + last_name \
                  : last_name + sep + first_name
    e.downcase! if coinhead?
    e += "@" + random_string
    if coinhead?(10)
      e += ["", ".", "-"].at(rand 3)
      e += random_string
    end
    e += "." + %w(com net org us eu info name biz gov edu).at(rand 10)
    return url_helper.mail_to(e, name, html_options)
  end
  
  def httpbl_harvester_visiting?
    return false unless self.class.httpbl_checker
    httpbl_check_remote_ip[:type].include?(:harvester)
  end
  
  
  private
  def url_helper; Helper.instance; end  
  class Helper
    include Singleton
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
  end
  
  def httpbl_check_remote_ip
    cached_r = @@ip_cache[request.remote_ip]
    if not cached_r or cached_r[:expire] < Time.now
      r = self.class.httpbl_checker.check(request.remote_ip) # or "127.1.1.2" for testing
      @@ip_cache[request.remote_ip] = { :result => r, :expire => Time.now + 300 }
      # wipe out obsolete records
      @@ip_cache.delete_if { |ip, data| data[:expire] < Time.now}
    else
      r = cached_r[:result]
    end
    # logger.info "CACHE: " + @@ip_cache.inspect
    return r
  end
  
  
  # returns true or false randomly
  def coinhead?(weight = 0); rand(2 + weight) == 0; end
  
  def random_string
    r = ""
    5.times do
      r += %w(b c d f g h j k l m n p q r s t v w x z)[rand(20)]
      r += %w(a e i o u y)[rand(6)]
    end
    r[0..(5 + rand(8))]
  end
  
end