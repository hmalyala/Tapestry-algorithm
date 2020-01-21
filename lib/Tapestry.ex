defmodule Tapestry do

  def func(args \\ []) do
    options = [switches: [file: :string],aliases: [f: :file]]
        {_,ar2,_} = OptionParser.parse(args,options)

    num = String.to_integer(List.first(ar2))
    req = String.to_integer(List.last(ar2))

    generate(num,req)
  end
def generate(num,req) do
    li = Enum.map(1..num,&(&1))

#................... Generate Children ..................................................
    {:ok,pid}=Node.Supervisor.start_link(num)
    IO.inspect(pid) #supervisor's pid
    list=Supervisor.which_children(pid)
    child_list=(for x <- list, into: [] do
                {_,cid,_,_}=x
                cid
                 end)
    child_list = Enum.reverse(child_list)

#..........................................................................................

#..................Assign NodeIds..........................................................
    hashlist = Enum.map(li,fn(x)->:crypto.hash(:sha,Integer.to_string(x))|>Base.encode16 end)
    Enum.each(li,fn(x)->Actor.hashfun(Enum.at(child_list,x-1),Enum.at(hashlist,x-1)) end)
    Enum.each(child_list,fn(x)->Actor.initneighmap(40,16,x) end)
    nodelist = Enum.sort(hashlist)
    lis = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"]
    nodes = Enum.map(lis,fn(x)->groupnodelist(nodelist,x) end)
    nodes = %{"0"=>Enum.at(nodes,0),"1"=>Enum.at(nodes,1),"2"=>Enum.at(nodes,2),"3"=>Enum.at(nodes,3),"4"=>Enum.at(nodes,4),"5"=>Enum.at(nodes,5),"6"=>Enum.at(nodes,6),"7"=>Enum.at(nodes,7),"8"=>Enum.at(nodes,8),"9"=>Enum.at(nodes,9),"A"=>Enum.at(nodes,10),"B"=>Enum.at(nodes,11),"C"=>Enum.at(nodes,12),"D"=>Enum.at(nodes,13),"E"=>Enum.at(nodes,14),"F"=>Enum.at(nodes,15)}

#..................Assign Map....................................................
    nodepids = Enum.map(child_list,fn(x)->id = Map.get(Actor.get_state(x),:nodeid)
                                                {String.to_atom(id),x} end)
    Enum.each(child_list,fn(x)->Actor.assignmap(x,nodes,nodepids) end)
#.....................StartTapestry.......................................................
    Enum.each(child_list,fn(x)->Actor.starttapestry(x,req,nodelist) end)
    :timer.sleep(5000)
    maxhop = Enum.map(child_list,fn(x)->Map.get(Actor.get_state(x),:maxhop) end)|> Enum.max()
    IO.puts "Maximum Hop    #{maxhop}"
end



def groupnodelist(nodelist,y) do
    res = Enum.map(nodelist,fn(x)->groupnode(x,y) end)|>Enum.uniq()
    res= res--[nil]
    res
end

def groupnode(nodeid,x) do
    if String.at(nodeid,0) == x do
        nodeid
    else
        nil
    end
end

end

Tapestry .func(System.argv)
