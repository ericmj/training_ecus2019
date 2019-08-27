defmodule Chat do
  def start() do
    {host, port} = get_host_and_port()
    options = [mode: :binary, active: true, packet: 2]

    case :gen_tcp.connect(String.to_charlist(host), port, options) do
      {:ok, socket} ->
        IO.puts("Connection successful")
        loop(socket)

      {:error, reason} ->
        raise "Failed to open connection: #{inspect(reason)}"
    end
  end

  defp loop(socket) do
    receive do
      {:tcp, ^socket, data} ->
        data
        |> Jason.decode!()
        |> handle_message()

        loop(socket)

      {:tcp_closed, ^socket} ->
        raise "TCP connection was closed"

      {:tcp_error, ^socket, reason} ->
        raise "TCP connection error: #{inspect(reason)}"
    end
  end

  defp handle_message(%{"kind" => "welcome", "users_online" => num_users})
       when is_integer(num_users) do
    IO.puts(
      "Welcome to the ElixirConf server, there are #{num_users} " <>
        "users online"
    )
  end

  defp handle_message(unknown_message) do
    IO.puts("Received unknown message: #{inspect(unknown_message)}")
  end

  defp get_host_and_port do
    address = String.trim(IO.gets("Server address (localhost:4000): "))

    address =
      if address == "" do
        "localhost:4000"
      else
        address
      end

    [host, port] = String.split(address, ":")
    port = String.to_integer(port)

    {host, port}
  end

  # git diff origin/master
  # git fetch && git reset --hard origin/master
end
