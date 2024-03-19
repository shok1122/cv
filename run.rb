require 'date'
require 'erb'
require 'yaml'

class Award
  def initialize(_data)
    @data = _data['award']
    @title = @data['title']
    @org = @data['org']
  end

  def biblio()
    return "#{@org}, #{@title}"
  end
end

class Career
  def initialize(_data)
    @data = _data
    @title = _data['title']
    @period = _data['period']
  end

  def biblio()
    return "<td>#{period}</td><td>#{@title}</td>"
  end

  def convert(_x)
    return nil if _x.nil?
    return "#{_x['year']}年#{_x['month']}月"
  end

  def period()
    s = convert(@period['start'])
    e = convert(@period['end'])

    if !s.nil? && !e.nil?
      return "#{s} &ndash; #{e}"
    elsif !s.nil?
      return "#{s} &ndash; 現在"
    elsif !e.nil?
      return "#{e}"
    end
  end
end

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
    when 'journal', 'proceedings', 'proceedings_jp', 'article' then
      return BiblioPaper::factory(_data)
    when 'poster', 'oral', 'speech' then
      return BiblioPresentation::factory(_data)
    else
      puts "Undefined type: #{type}"
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
    @page = (_data['page'].nil? || _data['page']['start'].nil? || _data['page']['start'].nil?) ? nil : _data['page']
    @doi = _data['doi']

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
    return "#{author}#{title}#{journal}#{volume}#{number}#{page}#{year}. #{tba}#{doi}".strip
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

  def doi()
    return @doi.nil? ? "" : " <a href=#{@doi} target=\"_blank\">#{@doi}</a>"
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

class BiblioFunding
  def initialize(_data)
    @title = _data['title']
    @role = _data['role']
    @year = (_data['year']['start'].nil? || _data['year']['start'].nil?) ? nil : _data['year']
    @category = _data['category']
    @fund = _data['fund']
    @number = _data['number']
    @institution = _data['institution']
    @url = _data['url']
  end

  def biblio()
    return "#{title}<br>#{@institution}：#{@fund}　#{@category}（#{@number}）<br>#{year}".strip
  end

  def title()
    return "<a href=#{@url} target=\"_blank\">#{@title}</a>"
  end

  def year()
    note = Date.today < Date.parse(@year['end']) ? "（予定）" : ""
    return @year.nil? ? "" : "研究期間：#{@year['start']} &ndash; #{@year['end']}#{note}"
  end

end

class XXX

  def make_biblio(_x)
    this = Biblio::factory(_x)
    return this.biblio()
  end

  def make_biblio_funding(_x)
    this = BiblioFunding.new(_x)
    return this.biblio()
  end

  def make_biblio_career(_x)
    this = Career.new(_x)
    return this.biblio()
  end

  def make_award(_x)
    this = Award.new(_x)
    return this.biblio()
  end

  def main()
    paper = YAML.load_file('./paper.yaml')
    journal = paper.find_all { |v| v['type'] == "journal" }.sort{|x| x['year']}.reverse
    proceedings = paper.find_all { |v| v['type'] == "proceedings" }.sort{|x| x['year']}.reverse
    proceedings_jp = paper.find_all { |v| v['type'] == "proceedings_jp" }.sort{|x| x['year']}.reverse
    article = paper.find_all { |v| v['type'] == "article" }.sort{|x| x['year']}.reverse

    award = paper.find_all { |v| v['award'].nil? == false }

    presentation = YAML.load_file('./presentation.yaml')
    poster = presentation.find_all { |v| v['type'] == 'poster' }.sort{ |x| x['year']}.reverse
    oral = presentation.find_all { |v| v['type'] == 'oral' }.sort{ |x| x['year']}.reverse
    speech = presentation.find_all { |v| v['type'] == 'speech' }.sort{ |x| x['year']}.reverse

    funding = YAML.load_file('./funding.yaml')
    funding_principal = funding.find_all { |v| v['role'] == 'principal' }
    funding_collaborator = funding.find_all { |v| v['role'] == 'collaborator' }

    career = YAML.load_file('./career.yaml')
    career_education = career['education']
    career_work = career['work']

    File.open('./template.erb') do |f|
      text = ERB.new(f.read, trim_mode: '%-').result(binding)
      puts text
    end
  end
end

## Entrypoint ##

this = XXX.new
this.main()
