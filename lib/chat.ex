defmodule Chat do
  def start() do
    {host, port} = get_host_and_port()
    options = [mode: :binary, active: true, packet: 2]

    case :gen_tcp.connect(String.to_charlist(host), port, options) do
      {:ok, socket} ->
        IO.puts("Connection successful")

        nickname = String.trim(IO.gets("Nickname: "))
        spawn_gets_process(nickname)

        loop(socket, nickname)

      {:error, reason} ->
        raise "Failed to open connection: #{inspect(reason)}"
    end
  end

  defp spawn_gets_process(nickname) do
    parent = self()

    spawn(fn ->
      message = String.trim(IO.gets("#{nickname}: "))
      send(parent, {:gets, message})
    end)
  end

  defp loop(socket, nickname) do
    receive do
      {:gets, message} ->
        IO.puts("#{nickname}: #{message}")
        spawn_gets_process(nickname)
        loop(socket, nickname)

      {:tcp, ^socket, data} ->
        data
        |> Jason.decode!()
        |> handle_message()

        loop(socket, nickname)

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

  # To compare your code:
  # git fetch && git diff origin/master

  # To catch up with our code:
  # git fetch && git reset --hard origin/master
end
