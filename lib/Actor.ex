
defmodule Actor do
    use GenServer
    def start_link(index) do
        GenServer.start_link(__MODULE__,index)
    end


    def init(index) do
        state = %{:node=>index,:nodeid=>index,:pid=>self(),:neighmap=>[],:rows=>[],:nodepids=>[],:maxhop=>0}
        {:ok,state}
    end

    def initneighmap(i,j,pid) do
        GenServer.cast(pid,{:initnode,i,j})
    end

    def hashfun(pid,hash) do
        GenServer.cast(pid,{:updatehash,hash})
    end

    def get_state(pid) do
        GenServer.call(pid, {:state})
    end

    def assignmap(pid,nodelist,nodepids) do
        lis = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
        state = get_state(pid)
        nodeid = Map.get(state,:nodeid)
        levellist  = nodelist[String.at(nodeid,0)]
        nearlist = Enum.map(lis,fn(x)-> cond do
                                            x<String.at(nodeid,0)->List.last(nodelist[x])
                                            x==String.at(nodeid,0)->"nil"
                                            x>String.at(nodeid,0)->List.first(nodelist[x])
                                            end end)
        genmap(pid,levellist,nearlist,nodepids)
    end

    def genmap(pid,levellist,nearlist,nodepids) do
        Enum.each(0..40,fn(x)->GenServer.cast(pid,{:genmap,levellist,nearlist,nodepids,x}) end)
        #IO.inspect get_state(pid)
    end

    def get_values(levellist,level,id) do
        lis = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
        #IO.puts "check"
        levelnodes = Enum.map(levellist,fn(y)->if String.slice(id,0..level-1)==String.slice(y,0..level-1) and String.slice(id,0..level)!=String.slice(y,0..level) do
                                        y
                                    else
                                        nil
                                    end end)|>Enum.uniq()
        levelnodes = levelnodes--[nil]
        ln = Enum.map(lis,fn(x)->val = Enum.map(levelnodes,fn(y)->if String.at(y,level)==x do
                                                            y
                                                        else
                                                            nil
                                                        end end)|>Enum.uniq()
                                            if val==[nil] do
                                                nil
                                            else
                                                val--[nil]
                                            end end)
        ln = Enum.map(ln,fn(x)->if x != nil do
                                    List.first(x)
                                else
                                    nil end end )
    end

    def routetonode(sourcenode,destnode,hop,pid) do
        #IO.puts "check1"
        GenServer.cast(pid,{:routetonode,sourcenode,pid,destnode,hop})
    end

    def get_nearnode(destnode,neighmap,nodeid) do
        level = Enum.map(0..String.length(nodeid),fn(x)->if String.at(nodeid,x)!=String.at(destnode,x), do: x end)|>Enum.uniq()
        level = level--[nil]|> List.first()#|>Integer.to_string()
        #IO.puts level
        nearlist = Enum.at(neighmap,level)|>Enum.uniq()
        nearlist = nearlist--[nil]
        nearnode = Enum.map(nearlist,fn(x)-> if String.at(x,level)==String.at(destnode,level), do: x end)|>Enum.uniq()
        nearnode = List.last(nearnode--[nil])
        #IO.puts "NExtnode       #{nearnode}"
        nearnode
    end

    def starttapestry(pid,req,nodelist) do
        sourcenode = Map.get(get_state(pid),:nodeid)
        destnodes = Enum.map(1..req,fn(_)->Enum.random(nodelist--[sourcenode]) end)
        for i<-destnodes do
            routetonode(sourcenode,i,0,pid)
            #:timer.sleep(1000)
        end
        #Enum.each(destnodes,fn(x)->routetonode(sourcenode,x,0,pid) end)
    end



    def handle_cast({:routetonode,sourcenode,sourcenodepid,destnode,hop},state) do
        nodepids = Map.get(state,:nodepids)
        neighmap = Map.get(state,:neighmap)
        #IO.inspect state
        nodeid   = Map.get(state,:nodeid)
        #IO.inspect nodeid
        nearnode = get_nearnode(destnode,neighmap,nodeid)
        nearnodepid = nodepids[String.to_atom(nearnode)]
        if nearnode == destnode or sourcenode== destnode do
            GenServer.cast(sourcenodepid,{:recievehop,hop+1})
            #IO.puts "#{sourcenode}      #{destnode}      #{hop}"
        else
            nearnodepid = nodepids[String.to_atom(nearnode)]
            GenServer.cast(nearnodepid,{:routetonode,sourcenode,sourcenodepid,destnode,hop+1})
        end
        {:noreply,state}
    end

    def handle_cast({:recievehop,hop},state) do
        maxhop = max(Map.get(state,:maxhop),hop)
        state = Map.put(state,:maxhop,maxhop)
        {:noreply,state}
    end

    def handle_cast({:genmap,levellist,nearlist,nodepids,level},state) do
        nodeid = Map.get(state,:nodeid)
        neighmap = Map.get(state,:neighmap)
        state = Map.put(state,:nodepids,nodepids)
        if level == 0 do
            neighmap = List.update_at(neighmap,0,&(&1=nearlist))
            state = Map.put(state,:neighmap,neighmap)
            #IO.inspect(levellist)
            {:noreply,state}
        else
            neighmap = List.update_at(neighmap,level,&(&1=get_values(levellist,level,nodeid)))
            state = Map.put(state,:neighmap,neighmap)
            {:noreply,state}
        end
        #IO.inspect state

    end

    def handle_cast({:initnode,i,j},state) do
        rows = Enum.map(0..i-1,fn(x)->x end)
        cols = Enum.map(0..j-1,fn(_)->"nil" end)
        neighmap = Enum.map(rows,fn(x)->{String.to_atom("level"<>Integer.to_string(x)),cols} end)
        state = Map.put(state,:neighmap,neighmap)
        state = Map.put(state,:rows,rows)
        {:noreply,state}
    end

    def handle_cast({:updatehash,hash},state) do
        state = Map.put(state,:nodeid,hash)
        {:noreply,state}
    end

    def handle_call({:state},_from,state) do
        {:reply,state,state}
    end

    def addnode(i,j,pid,nodelist,nodepids) do
        initneighmap(i,j,pid)
        assignmap(pid,nodelist,nodepids)
        IO.inspect Map.get(get_state(pid),:neighmap)
    end

end

