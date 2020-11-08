%Made by: Arches, Keith Nicole M. and Grace Garganera

-module(arches1garganera2).
-compile(export_all).
% -import(string,[equal/2]). 

%TASKS FOR THE EXER:
%----------DONE--------- - Connecting Two Nodes
%----------DONE--- - Disconnecting when bye message is sent
%----------DONE--------- - Send Messages but waits for the reply of the other code
%----------DONE--- - Send Messages but does not wait for the reply of the other code

% romeo = pong, first chat
% juliet = ping, second chat

%used to initialize first message/chat
init_chat()->
    Name = io:get_line("Enter your name: "),
    register(chat1, spawn(arches1garganera2,chat1,[string:trim(Name)])).

chat1(Name) -> 
    receive
        %_ is for the receiving end of the other node, to match the cases 
        { ping, Chat2_Node } ->
           spawn(arches1garganera2, getInput, [Chat2_Node, Name, self()]),
           Chat2_Node ! chatter,
        %  reset the receiver
           chat1(Name);
        { restart, Chat2_Node } ->
            spawn(arches1garganera2, getInput, [Chat2_Node, Name, self()]),
            chat1(Name);
        { response, Name2, Theconvo2, Chat2_Node } ->
            io:format("~p: ~s", [Name2, Theconvo2]),
            Chat2_Node ! chatter,
            chat1(Name);    
        exit ->
            io:format("Your partner has disconnected.~n"),
            erlang:halt()
    end.
    

%used to initialize the second chat 
init_chat2(Chat1_Node) ->
    Name2 = io:get_line("Enter your name: "),
    spawn(arches1garganera2,chat2,[1,Chat1_Node,string:trim(Name2)]).

%ping part with N 
chat2(Flag,Chat1_Node,Name2) when Flag == 1->
    {chat1, Chat1_Node} ! { ping, self() },
    % seperates the process
    chat2(2,Name2,Chat1_Node);
chat2(Flag, Name2, Chat1_Node) -> 
    receive
        %receives the response from the first node
        chatter -> 
            spawn(arches1garganera2, getInput, [{chat1, Chat1_Node}, Name2, self()]),
            % reset the receiver
            chat2(Flag, Name2, Chat1_Node);
        { response, Name, Theconvo,_} ->
            io:format("~p: ~s", [Name, Theconvo]),
            { chat1, Chat1_Node } ! { restart, self() },
            chat2(Flag, Name2, Chat1_Node);
        exit ->
            io:format("Your partner has disconnected.~n"),
            erlang:halt()
            

    end.

%spawn function was resolved all thanks to Asilo and Bernabe, fellow classmates
%passing of important parameters was made possible through making this function
%The function displays what the author is going to chat
%The code checks the item to see whether it is a goodbye message. else, it sends its message
%to the other node, and vice versa
getInput(Chat_Node, Name, Chat2_pid) ->
    % Gets the line
    Theconvo2 = io:get_line("You: "),
    Bye_string = "bye\n",
    Status2 = string:equal(Theconvo2,Bye_string),
    if
        (Status2 == true) == false ->
            Chat_Node ! {response, Name, Theconvo2, Chat2_pid};
        true ->
            io:format("Goodbye!~n"),
            Chat_Node ! exit,
            erlang:halt()
    end.
    

% REFERENCES:
% Checking if both strings are equal: https://www.tutorialspoint.com/erlang/erlang_equal.htm


