require 'rails_helper'

describe Movie do
  describe 'searching TMDb by keyword' do
    it 'calls Faraday with the TMDb search endpoint' do
      expect(Faraday).to receive(:get)
        .with('https://api.themoviedb.org/3/search/movie', hash_including(query: 'hacker'))
        .and_call_original
      Movie.find_in_tmdb({ title: 'hacker', language: 'en' })
    end

    it 'sends the API key it is given' do
      Movie.find_in_tmdb({ title: 'hacker', language: 'en' }, 'abc123')
      expect(a_request(:get, /api.themoviedb.org/)
        .with(query: hash_including('api_key' => 'abc123'))).to have_been_made
    end

    it 'returns unsaved Movie objects with a default rating of R' do
      movies = Movie.find_in_tmdb({ title: 'olympics', release_year: '2000', language: 'all' })
      expect(movies.length).to eq(2)
      expect(movies.first).to be_a(Movie)
      expect(movies.first).not_to be_persisted
      expect(movies.first.rating).to eq('R')
    end

    it 'returns an empty list when TMDb finds nothing' do
      stub_request(:get, /api.themoviedb.org/)
        .to_return(status: 200, body: JSON.generate({ page: 1, results: [] }), headers: {})
      expect(Movie.find_in_tmdb({ title: 'zzzzzzzz', language: 'all' })).to eq([])
    end

    it 'returns an empty list when the API key is invalid' do
      stub_request(:get, /api.themoviedb.org/)
        .to_return(status: 401, body: JSON.generate({ status_code: 7 }), headers: {})
      expect(Movie.find_in_tmdb({ title: 'hacker', language: 'all' }, 'bad')).to eq([])
    end
  end
end
