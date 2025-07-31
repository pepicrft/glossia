defmodule GlossiaWeb.Router do
  use GlossiaWeb, :router

  pipeline :browser do
    plug :accepts, ["html", "xml"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GlossiaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug GlossiaWeb.Plugs.Auth
  end

  pipeline :marketing do
    plug :accepts, ["html", "xml"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GlossiaWeb.Layouts, :marketing}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug GlossiaWeb.Plugs.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Marketing pages with marketing layout
  scope "/", GlossiaWeb do
    pipe_through :marketing

    get "/", PageController, :home
    get "/about", InfoController, :about
    get "/terms", InfoController, :terms
    get "/cookies", InfoController, :cookies

    get "/blog", BlogController, :index
    get "/blog/:id", BlogController, :show
    get "/blog/feed/:format", BlogController, :feed

    get "/changelog", ChangelogController, :index
    get "/changelog/:id", ChangelogController, :show
    get "/changelog/feed/:format", ChangelogController, :feed
  end

  # App pages with app layout
  scope "/", GlossiaWeb do
    pipe_through :browser

    get "/login", AuthController, :login
    get "/dashboard", PageController, :dashboard
  end

  scope "/auth", GlossiaWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/logout", AuthController, :logout
  end

  # Other scopes may use custom stacks.
  # scope "/api", GlossiaWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:glossia, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GlossiaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
