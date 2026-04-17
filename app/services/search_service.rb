require 'httparty'
require 'nokogiri'
require 'uri'

class SearchService
  HEADERS = {
    'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept-Language' => 'en-US,en;q=0.9'
  }.freeze

  def initialize(query, engine = 'duckduckgo')
    @query = query
    @engine = engine
  end

  def search
    case @engine
    when 'google', 'bing'
      scrape_duckduckgo
    when 'duckduckgo'
      scrape_duckduckgo
    when 'gogo'
      scrape_gogo
    when 'news'
      scrape_news_mn
    else
      { error: "Unknown engine: #{@engine}" }
    end
  end

  private

  def scrape_duckduckgo
    url = "https://html.duckduckgo.com/html/?q=#{URI.encode_www_form_component(@query)}"
    response = HTTParty.get(url, headers: HEADERS)
    doc = Nokogiri::HTML(response.body)

    results = []
    position = 1

    doc.css('.result').each do |result|
      title   = result.css('.result__title').first&.text&.strip
      link    = result.css('.result__url').first&.text&.strip
      snippet = result.css('.result__snippet').first&.text&.strip

      next if title.nil? || link.nil?

      results << {
        position: position,
        title: title,
        link: "https://#{link}",
        snippet: snippet || ''
      }
      position += 1
    end

    {
      query: @query,
      engine: 'duckduckgo',
      total_results: results.count,
      organic_results: results
    }
  end

  def scrape_gogo
    date = Time.now.strftime('%Y-%m-%d')
    encoded_date = URI.encode_www_form_component("#{date} 23:59:59")
    url = "https://gogo.mn/cache/news-shinemedee?size=20&lastNewsDate=#{encoded_date}"

    response = HTTParty.get(url, headers: HEADERS)
    articles = []

    if response.parsed_response.is_a?(Hash)
      articles = response.parsed_response['shinemedee_list'] || []
    end

    results = []
    articles.first(10).each_with_index do |article, i|
      results << {
        position: i + 1,
        title: article['title'] || '',
        link: "https://gogo.mn/r/#{article['id']}",
        snippet: article['short_content'] || ''
      }
    end

    {
      query: @query,
      engine: 'gogo',
      total_results: results.count,
      organic_results: results
    }
  end

  def scrape_news_mn
    encoded_query = URI.encode_www_form_component(@query)
    url = "https://news.mn/wp-json/wp/v2/posts?per_page=10&search=#{encoded_query}"

    response = HTTParty.get(url, headers: HEADERS)
    articles = response.parsed_response || []
    articles = [] unless articles.is_a?(Array)

    results = []
    articles.each_with_index do |article, i|
      title   = article.dig('title', 'rendered') || ''
      link    = article['link'] || ''
      excerpt = article.dig('excerpt', 'rendered') || ''
      snippet = excerpt.gsub(/<[^>]+>/, '').strip

      results << {
        position: i + 1,
        title: title,
        link: link,
        snippet: snippet
      }
    end

    {
      query: @query,
      engine: 'news.mn',
      total_results: results.count,
      organic_results: results
    }
  end
end