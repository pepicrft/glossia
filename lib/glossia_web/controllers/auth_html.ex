defmodule GlossiaWeb.AuthHTML do
  @moduledoc """
  This module contains pages rendered by AuthController.
  """
  use GlossiaWeb, :html

  embed_templates "auth_html/*"
end
