require 'erb'
require 'yaml'

class Biblio
  @@LQUOTE = '&ldquo;'
  @@RQUOTE = '&rdquo;'
  @@ENDASH = '&ndash;'

  def initialize(_data, _name)
    @data = _data
    @title = _data['title']
    @author = _data['author']
    @journal = _data['journal']
    @year = _data['year']
    @volume = _data['volume']
    @number = _data['number']
    @page = (_data['page']['start'].nil? || _data['page']['start'].nil?) ? nil : _data['page']
    @tba = (_data['tba'].nil? || _data['tba'] == false) ? false : true

    @name = _name
  end

  def biblio()
    return "#{author}#{title}#{journal}#{volume}#{number}#{page}#{year}. #{tba}".strip
  end

  def title()
    return @title.nil? ? "" : ", #{@@LQUOTE}#{@title}#{@@RQUOTE}"
  end

  def author()
    @author.map!{ |x| (x == @name) ? "<u>#{x}</u>" : x }
    return @author.join(", ")
  end

  def journal()
    return @journal.nil? ? "" : ", #{@journal}"
  end

  def volume()
    return @volume.nil? ? "" : ", vol. #{@volume}"
  end

  def number()
    return @number.nil? ? "" : ", no. #{@number}"
  end

  def page()
    return @page.nil? ? "" : ", pp. #{@page["start"]}#{@@ENDASH}#{@page["end"]}"
  end

  def year()
    return @year.nil? ? "" : ", #{@year}"
  end

  def tba()
    return (@tba == true) ? "(To be appeared)" : ""
  end

end

class BiblioEn < Biblio
  def initialize(_data)
    super(_data, 'S. Kakei')
  end

  def author()
    authors = ""
    @author.map!{ |x| (x == @name) ? "<u>#{x}</u>" : x }
    if @author.length > 2
      authors = @author[0..-2].join(', ') + ", and #{@author[-1]}"
    elsif @author.length == 2
      authors = "#{@author[0]} and #{@author[1]}"
    elsif @author.length == 1
      authors = "#{@author[0]}"
    end
    return authors
  end

  def journal()
    return ", in <i>#{@journal}</i>"
  end
end

class BiblioJp < Biblio
  def initialize(_data)
    super(_data, '掛井将平')
  end
end

class XXX
  def make_biblio(_x)
    case _x['lang']
    when 'en' then
      this = BiblioEn.new(_x)
      return this.biblio()
    when 'jp' then
      this = BiblioJp.new(_x)
      return this.biblio()
    end
  end

  def main()
    publication = YAML.load_file('./publication.yaml')

    journal = publication.find_all { |v| v['type'] == "journal" }.sort{|x| x['year']}.reverse
    proceedings = publication.find_all { |v| v['type'] == "proceedings" }.sort{|x| x['year']}.reverse
    proceedings_jp = publication.find_all { |v| v['type'] == "proceedings_jp" }.sort{|x| x['year']}.reverse

    File.open('./template.erb') do |f|
      text = ERB.new(f.read, trim_mode: '%-').result(binding)
      puts text
    end
  end
end

## Entrypoint ##

this = XXX.new
this.main()
