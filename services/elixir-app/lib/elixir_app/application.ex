defmodule ElixirApp.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4000")
    children = [{ElixirApp.Server, port}]
    Supervisor.start_link(children, strategy: :one_for_one, name: ElixirApp.Supervisor)
  end
end
