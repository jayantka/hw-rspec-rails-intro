require 'rails_helper'

describe Movie do
  describe 'searching TMDb when a result is already saved' do
    it 'leaves out movies already in the database' do
      Movie.create!(title: 'Sydney 2000 Olympics Opening Ceremony',
                    rating: 'R', release_date: '2000-09-15')
      movies = Movie.find_in_tmdb({ title: 'olympics', language: 'all' })
      expect(movies.map(&:title)).to eq(['Sydney 2000 Olympics Closing Ceremony'])
    end
  end
end
