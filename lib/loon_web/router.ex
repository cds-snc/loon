defmodule LoonWeb.Router do
  use LoonWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LoonWeb do
    pipe_through :api
    get "/", JobsController, :index
    get "/:id", JobsController, :show
  end
end
