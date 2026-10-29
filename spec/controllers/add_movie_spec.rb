require 'rails_helper'

describe MoviesController, type: :controller do
  describe 'adding a movie from TMDb' do
    it 'saves the movie and redirects back to the search page' do
      expect do
        post :add_movie, params: { title: 'Manhunter', rating: 'R', release_date: '1986-08-15' }
      end.to change(Movie, :count).by(1)
      expect(response).to redirect_to(search_tmdb_path)
    end

    it 'shows a success message' do
      post :add_movie, params: { title: 'Manhunter', rating: 'R', release_date: '1986-08-15' }
      expect(flash[:success]).to include('Manhunter was successfully added')
    end
  end
end
