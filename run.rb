require 'erb'
require 'yaml'

class Biblio
  @@LQUOTE = '&ldquo;'
  @@RQUOTE = '&rdquo;'
  @@ENDASH = '&ndash;'

  @@NAME_EN = 'S. Kakei'
  @@NAME_JP = '掛井将平'

  def initialize(_data, _name)
    @data = _data
    @title = _data['title']
    @author = _data['author']
    @year = _data['year']
    @tba = (_data['tba'].nil? || _data['tba'] == false) ? false : true
    @name = _name
  end

  def self.factory(_data)
    type = _data['type']
    case type
    when 'journal', 'proceedings', 'proceedings_jp' then
      return BiblioPaper::factory(_data)
    when 'poster' then
      return BiblioPresentation::factory(_data)
    end
  end

  def title()
    return @title.nil? ? "" : ", #{@@LQUOTE}#{@title}#{@@RQUOTE}"
  end

  def author_jp()
    @author.map!{ |x| (x == @name) ? "<u>#{x}</u>" : x }
    return @author.join(", ")
  end

  def author_en()
    @author.map!{ |x| (x == @name) ? "<u>#{x}</u>" : x }
    if @author.length > 2
      return @author[0..-2].join(', ') + ", and #{@author[-1]}"
    elsif @author.length == 2
      return "#{@author[0]} and #{@author[1]}"
    elsif @author.length == 1
      return "#{@author[0]}"
    end
  end

  def year()
    return @year.nil? ? "" : ", #{@year}"
  end

  def tba()
    return (@tba == true) ? "(To be appeared)" : ""
  end

end

class BiblioPresentation < Biblio

  def initialize(_data, _name)
    @conference = _data['conference']
    @number = _data['number']
    @city = _data['city']
    @country = _data['country']
    super(_data, _name)
  end

  def self.factory(_data)
    case _data['lang']
    when 'en' then
      return BiblioPresentationEn.new(_data)
    when 'jp' then
      return BiblioPresentationJp.new(_data)
    end
  end

  def biblio()
    return "#{author}#{title}#{conference}#{number}#{city}#{country}#{year}. #{tba}".strip
  end

  def conference()
    return @conference.nil? ? "" : ", #{@conference}"
  end

  def number()
    return @number.nil? ? "" : ", #{@number}"
  end

  def city()
    return @city.nil? ? "" : ", #{@city}"
  end

  def country()
    return @country.nil? ? "" : ", #{@country}"
  end

end

class BiblioPresentationEn < BiblioPresentation

  def initialize(_data)
    super(_data, @@NAME_EN)
  end

  def author()
    return author_en()
  end

  def conference()
    return @conference.nil? ? "" : ", <i>#{@conference}</i>"
  end

end

class BiblioPresentationJp < BiblioPresentation

  def initialize(_data)
    super(_data, @@NAME_JP)
  end

  def author()
    return author_jp()
  end

end

class BiblioPaper < Biblio

  def initialize(_data, _name)
    @journal = _data['journal']
    @volume = _data['volume']
    @number = _data['number']
    @page = (_data['page']['start'].nil? || _data['page']['start'].nil?) ? nil : _data['page']

    super(_data, _name)
  end

  def self.factory(_data)
    case _data['lang']
    when 'en' then
      return BiblioPaperEn.new(_data)
    when 'jp' then
      return BiblioPaperJp.new(_data)
    end
  end

  def biblio()
    return "#{author}#{title}#{journal}#{volume}#{number}#{page}#{year}. #{tba}".strip
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

end

class BiblioPaperEn < BiblioPaper
  def initialize(_data)
    super(_data, @@NAME_EN)
  end

  def author()
    return author_en()
  end

  def journal()
    return ", in <i>#{@journal}</i>"
  end
end

class BiblioPaperJp < BiblioPaper
  def initialize(_data)
    super(_data, @@NAME_JP)
  end

  def author()
    return author_jp()
  end
end

class XXX
  def factory(_data)
    return Biblio::factory(_data)
  end

  def make_biblio(_x)
    this = factory(_x)
    return this.biblio()
  end

  def main()
    paper = YAML.load_file('./paper.yaml')
    journal = paper.find_all { |v| v['type'] == "journal" }.sort{|x| x['year']}.reverse
    proceedings = paper.find_all { |v| v['type'] == "proceedings" }.sort{|x| x['year']}.reverse
    proceedings_jp = paper.find_all { |v| v['type'] == "proceedings_jp" }.sort{|x| x['year']}.reverse

    presentation = YAML.load_file('./presentation.yaml')
    poster = presentation.find_all { |v| v['type'] == 'poster' }.sort{ |x| x['year']}.reverse

    File.open('./template.erb') do |f|
      text = ERB.new(f.read, trim_mode: '%-').result(binding)
      puts text
    end
  end
end

## Entrypoint ##

this = XXX.new
this.main()
