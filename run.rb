require 'erb'
require 'yaml'

class XXX

  def initialize()
  end

  def get_page(_x)
    if _x.nil?
      return ""
    else
      return ", pp. #{_x["start"]}–#{_x["end"]}"
    end
  end

  def get_name_jp(_authors)
    _authors.map!{ |x| (x == "掛井将平") ? "<u>#{x}</u>" : x }
    return _authors.join(", ")
  end

  def get_jp(_x)
    author = get_name_jp(_x['author'])
    title = ", \"#{_x['title']}\""
    journal = ", #{_x['journal']}"
    volume = _x['volume'].nil? ? "" : ", vol. #{_x['volume']}"
    number = _x['number'].nil? ? "" : ", no. #{_x['number']}"
    page = get_page(_x['page'])
    year = ", #{_x['year']}"
    return "#{author}#{title}#{journal}#{volume}#{number}#{page}#{year}."
  end

  def get_name_en(_authors)
    _authors.map!{ |x| (x == "S. Kakei") ? "<u>#{x}</u>" : x }

    if _authors.length > 2
      authors = _authors[0..-2].join(', ') + ", and #{_authors[-1]}"
    elsif _authors.length == 2
      authors = "#{_authors[0]} and #{_authors[1]}"
    elsif _authors.length == 1
      authors = "#{_authors[0]}"
    end

    return authors
  end

  def get_en(_x)
    author = get_name_en(_x['author'])
    title =   ", \"#{_x['title']}\""
    journal = ", in <i> #{_x['journal']}</i>"
    volume = _x['volume'].nil? ? "" : ", vol. #{_x['volume']}"
    number = _x['number'].nil? ? "" : ", no. #{_x['number']}"
    page = get_page(_x['page'])
    year = ", #{_x['year']}"
    return "#{author}#{title}#{journal}#{volume}#{number}#{page}#{year}."
  end

  def get(_x)
    case _x['lang']
    when 'en' then
      get_en(_x)
    when 'jp' then
      get_jp(_x)
    else
      return "lang field is null."
    end
  end

  def main()
    publication = YAML.load_file('./publication.yaml')

    journal = publication.find_all { |v| v['type'] == "journal" }
    proceedings = publication.find_all { |v| v['type'] == "proceedings" }

    File.open('./template.erb') do |f|
      text = ERB.new(f.read, trim_mode: '%-').result(binding)
      puts text
    end
  end
end

this = XXX.new
this.main()
