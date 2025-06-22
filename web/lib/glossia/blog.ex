defmodule Glossia.Blog do
  @moduledoc """
  Blog post management using Nimble Publisher.
  """

  use NimblePublisher,
    build: Glossia.Blog.Post,
    from: Application.app_dir(:glossia, "priv/posts/**/*.md"),
    as: :posts,
    highlighters: []

  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})
  @tags @posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  def all_posts, do: @posts
  def published_posts, do: Enum.filter(@posts, & &1.published)
  def all_tags, do: @tags

  def get_post_by_id!(id) do
    Enum.find(all_posts(), &(&1.id == id)) || raise Glossia.Blog.NotFoundError
  end

  def get_posts_by_tag(tag) do
    Enum.filter(all_posts(), &(tag in &1.tags))
  end

  def recent_posts(count \\ 5) do
    published_posts()
    |> Enum.take(count)
  end

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end
end
