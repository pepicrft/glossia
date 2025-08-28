defmodule GlossiaWeb.Router do
  use GlossiaWeb, :router

  alias GlossiaWeb.Plugs.Auth
  alias Plug.Swoosh.MailboxPreview

  pipeline :browser do
    plug :accepts, ["html", "xml"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GlossiaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :repository do
    plug :fetch_repository
  end

  scope "/", GlossiaWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/login", AuthController, :login

    scope "/:forge/:owner/:repo" do
      pipe_through :repository

      get "/", RepositoryController, :show
      get "/settings", RepositoryController, :settings

      scope "/commits/:sha" do
        get "/", CommitController, :show
      end
    end
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
      forward "/mailbox", MailboxPreview
    end
  end

  defp fetch_repository(%{params: %{"forge" => "local", "owner" => owner, "repo" => repo}} = conn, _opts) do
    repository = Glossia.Repositories.local() |> Map.merge(%{owner: owner, name: repo})

    conn
    |> assign(:selected_repository, repository)
  end

  defp fetch_repository(conn, _opts), do: conn
end
