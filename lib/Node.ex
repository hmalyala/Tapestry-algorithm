defmodule Node.Supervisor do
    use Supervisor
    def start_link(n) do
        {myInt, _} = :string.to_integer(to_charlist(n))
        Supervisor.start_link(__MODULE__,n )
    end

    def init(myInt) do
       children =Enum.map(1..myInt, fn(s) ->
            #IO.puts "I am in supervisor init"
            worker(Actor,[s],[id: "#{s}"])
            end)
        supervise(children, strategy: :one_for_one)
    end
end
