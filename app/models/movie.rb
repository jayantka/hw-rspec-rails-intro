class Movie < ApplicationRecord
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  # search: hash with :title, :release_year (optional), :language ('en' or 'all')
  # Returns unsaved Movie objects built from the TMDb results, leaving out
  # movies that are already in the database.
  def self.find_in_tmdb(search, api_key = ENV['TMDB_API_KEY'])
    query = { api_key: api_key, query: search[:title] }
    query[:year] = search[:release_year] if search[:release_year].present?
    query[:language] = 'en' if search[:language] == 'en'
    response = Faraday.get('https://api.themoviedb.org/3/search/movie', query)
    results = JSON.parse(response.body)['results'] || []
    results.reject { |m| exists?(title: m['title'], release_date: m['release_date']) }
           .map { |m| new(title: m['title'], rating: 'R', release_date: m['release_date']) }
  rescue JSON::ParserError, Faraday::Error
    []
  end
end
