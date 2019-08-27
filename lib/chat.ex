defmodule Chat do
  def start() do
    {host, port} = get_host_and_port()
    options = [mode: :binary, active: true, packet: 2]
    {:ok, socket} = :gen_tcp.connect(String.to_charlist(host), port, options)

    receive do
      {:tcp, ^socket, data} ->
        data
        |> Jason.decode!()
        |> IO.inspect()
    end
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
end
