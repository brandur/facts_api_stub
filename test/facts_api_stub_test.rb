require "bundler/setup"
Bundler.require(:default, :test)

require "minitest/spec"
require "minitest/autorun"

require_relative "../facts_api_stub"

#
# just a couple tests to verify general sanity
#

describe FactsApiStub do
  include Rack::Test::Methods

  def app
    FactsApiStub
  end

  describe "unauthenticated" do
    it "GET /categories" do
      get "/categories"
      last_response.status.must_equal 200
    end

    it "GET /categories/heroku" do
      get "/categories/heroku"
      last_response.status.must_equal 200
    end

    it "GET /categories/other" do
      get "/categories/other"
      last_response.status.must_equal 404
    end

    it "PUT /categories" do
      put "/categories"
      last_response.status.must_equal 401
    end
  end

  describe "authenticated" do
    before do
      authorize "", "secret"
    end

    it "GET /categories" do
      get "/categories"
      last_response.status.must_equal 200
    end

    it "PUT /categories" do
      put "/categories"
      last_response.status.must_equal 400
    end

    it "PUT /categories" do
      put "/categories", :categories => "[{}]"
      last_response.status.must_equal 200
    end

    it "PUT /category/heroku" do
      put "/categories/heroku", :category => "{}"
      last_response.status.must_equal 200
    end

    it "PUT /category/other" do
      put "/categories/other", :category => "{}"
      last_response.status.must_equal 201
    end
  end
end
