defmodule ElixirApp.Server do
  @moduledoc false
  use GenServer

  def start_link(port), do: GenServer.start_link(__MODULE__, port, name: __MODULE__)

  @impl true
  def init(port) do
    {:ok, listen} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    spawn_link(fn -> accept(listen) end)
    IO.puts("elixir-app listening on http://127.0.0.1:#{port}")
    {:ok, port}
  end

  defp accept(listen) do
    case :gen_tcp.accept(listen) do
      {:ok, socket} ->
        spawn(fn -> handle(socket) end)
        accept(listen)

      {:error, _reason} ->
        :ok
    end
  end

  defp handle(socket) do
    _ = :gen_tcp.recv(socket, 0)
    body = ~s({"service":"elixir-app"})

    response =
      "HTTP/1.1 200 OK\r\ncontent-type: application/json\r\ncontent-length: #{byte_size(body)}\r\n\r\n#{body}"

    _ = :gen_tcp.send(socket, response)
    :gen_tcp.close(socket)
  end
end
