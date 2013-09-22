require "multi_json"
require "sinatra/base"

class FactsApiStub < Sinatra::Base
  helpers do
    def auth
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
    end

    def auth_credentials
      auth.provided? && auth.basic? ? auth.credentials : nil
    end

    def authorized!
      raise ApiError.new(401) unless auth_credentials
    end

    def require_params!(*keys)
      keys.each do |key|
        raise ApiError.new(400) unless params[key]
      end
    end

    def respond(json, options={ status: 200 })
      [options[:status], { "Content-Type" => "application/json" },
        MultiJson.encode(json, :pretty => true)]
    end
  end

  class ApiError < StandardError
    attr_accessor :code
    def initialize(code)
      @code = code
    end
  end

  before do
    authorized! unless request.get?
  end

  get "/categories" do
    respond([category])
  end

  put "/categories" do
    require_params!(:categories)
    respond({})
  end

  get "/categories/search" do
    require_params!(:q)
    respond(category)
  end

  get "/categories/heroku" do
    respond(category)
  end

  # 200 for the known category
  put "/categories/heroku" do
    require_params!(:category)
    respond(category)
  end

  # 201 for any other category
  put "/categories/:slug" do
    require_params!(:category)
    respond(category, status: 201)
  end

  delete "/categories/heroku" do
    respond(category)
  end

  get "/facts" do
    respond([fact])
  end

  get "/facts/latest" do
    respond([fact])
  end

  get "/facts/random" do
    respond([fact])
  end

  get "/facts/search" do
    require_params!(:q)
    respond([fact])
  end

  get "/facts/1" do
    respond(fact)
  end

  post "/facts" do
    require_params!(:fact)
    respond(fact, status: 201)
  end

  put "/facts/1" do
    require_params!(:fact)
    respond(fact)
  end

  delete "/facts/1" do
    respond(fact)
  end

  private

  def category
    {
      id:        1,
      name:      "Heroku",
      slug:      "heroku",
      facts:     [{
        id:      1,
        content: "Heroku's API team is rockin'.",
      }]
    }
  end

  def fact
    {
      id:         1,
      content:    "Heroku's API team is rockin'.",
      category:   {
        id:       1,
        name:     "Heroku",
        slug:     "heroku",
      }
    }
  end
end
