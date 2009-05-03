# See http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/212639
# And http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/210633 for alternative [:id] notation
class ActiveRecord::Base
  alias_method :id__, :id
end

class Object
  ##
  #   @person ? @person.name : nil
  # vs
  #   @person.try(:name)
  def try(method)
    send method if respond_to? method
  end
end

# From http://weblog.jamisbuck.org/2007/4/6/faking-cursors-in-activerecord
class <<ActiveRecord::Base
  def each(limit=1000)
    rows = find(:all, :conditions => ["#{primary_key} > ?", 0], :limit => limit)
    while rows.any?
      rows.each { |record| yield record }
      rows = find(:all, :conditions => ["#{primary_key} > ?", rows.last.id], :limit => limit)
    end
    self
  end
end