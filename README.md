# Tapestry Algorithm
Hemanth Kumar Malyala - UFID 63485914
Gopichand Kommineni - UFID 03055523

Project Description.
The goal of this project is to implement in Elixir using the actor model
the Tapestry Algorithm and a simple object access service to prove its usefulness.

We implemented Dynamic Node Join and Node Routing in Elixir using Actor model and GenServer.
Input takes two arguments numnodes and numrequests.

Modules.
Actor1 -> Creates nodes and implements nodejoin for atleast 1 node and routing for all the nodes.
Project3 -> initiates node creation, node join and node routing.
## Executing the project
To run a test case, do:
->Unzip contents to your desired elixir project folder.
->Enter "Project3" folder and then enter "lib" subfolder
->Open the CMD in the path of lib
-> type "Mix run Project3.ex <numberofnodes> <numberofrequests>"
#### Whats happening.

We are creating network for N-10 nodes and implementing dynamic node join to the remaining 10 nodes. Once the entire network is setup we implement node routing by initiating each node to send the given number of requests to randomly choosen other nodes in the network.

All the hop counts are returned to the parent, Which returns the maximum of all.

#### Largest Network tested.
Largest number of nodes tested : 3000
Largest number of requests testes : 100
## Output
Output is the maximum hops of all nodes taken to route to destination.
Maximum hops "<number of hops>"

# Bonus

Fault Tolerance System.

To keep the network fault tolerant we are inserting a list of 2 to 3 nearest nodes instead of a single node in the routing table.
### Modules
Actor1 -> Creates nodes and implements nodejoin for atleast 1 node and routing for all the nodes.
Project3_bonus -> initiates node creation, node join and node routing.
### Implementation

To execute the bonus part 
->Unzip "Project3_bonus.zip" 
-> Enter Project3_bonus folder then enter lib folder
-> Open the CMD in the path of lib
->type "Mix run Project3_bonus.ex <parameter1> <parameter2> <parameter3>"

Here

-> <Parameter1>  is the number of Nodes to create
-> <Parameter2>  is the number of requests
-> <Parameter3>  is the number of Nodes to kill

After creating the routing table, we will kill the number no nodes in param3 deliberatey by selecting random nodes from the network.
When the killed node pid is encountered, The code will check if the process in alive or not.

If the process is dead then it will route to the nearest node with most prefix match it can find.