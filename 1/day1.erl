-module( day1 ).
-export( [main_1/1, main_2/1] ).

main_1( Input_Path )
->
    case file:read_file( Input_Path ) of
        {ok, Binary} 
        -> 
            Number_List = process_bin_to_number_list( Binary ),
            {Number_1, Number_2} = find_sum_pair( Number_List, 2020 ),
            Number_1 * Number_2
        ;
        _            
        -> 
            throw( file_not_read )
    end
.

main_2( Input_Path )
->
    case file:read_file( Input_Path ) of
        {ok, Binary} 
        -> 
            Number_List = process_bin_to_number_list( Binary ),
            {Number_1, Number_2, Number_3} = find_sum_triplet( Number_List, 2020 ),
            Number_1 * Number_2 * Number_3
        ;
        _
        ->
            throw( file_not_read )
    end
.


process_bin_to_number_list( Binary ) 
-> 
    process_bin_to_number_list( binary_to_list(Binary), [], [] )
.
process_bin_to_number_list( [Char | Rest], String, List ) when [Char] == "\n"
->
    process_bin_to_number_list( Rest, [], [list_to_integer(lists:reverse(String)) | List] )
;
process_bin_to_number_list( [Char | Rest], String, List )
->
    process_bin_to_number_list( Rest, [Char | String], List )
;
process_bin_to_number_list( [], String, List )
->
    lists:reverse( [list_to_integer(lists:reverse(String)) | List] )
.

find_sum_pair( [Number | Rest], Target_Sum)
->
    Difference = Target_Sum - Number,
    case lists:member( Difference, Rest ) of
        true -> {Number, Difference};
        _    -> find_sum_pair( Rest, Target_Sum )
    end
;
find_sum_pair( [], _Target_Sum )
->
    not_found
.

find_sum_triplet( [Number | Rest], Target_Sum ) 
->
    Difference = Target_Sum - Number,
            case find_sum_pair( Rest, Difference ) of
                {Number_1, Number_2}
                ->
                    {Number, Number_1, Number_2}
                ;
                not_found
                ->
                    find_sum_triplet( Rest, Target_Sum )
            end
;
find_sum_triplet( [], _Target_Sum )
->
    not_found
.