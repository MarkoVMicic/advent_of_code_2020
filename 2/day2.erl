-module( day2 ).
-export( [main_1/1, main_2/1] ).

main_1( Input_Path )
->
    case file:read_file( Input_Path ) of
        {ok, Binary} 
        -> 
            Unzipped_Password_List = process_bin_to_password_list( Binary ),
            Password_List = zip( Unzipped_Password_List ),
            Valid_Password_Count = count_valid_passwords( Password_List ),
            Valid_Password_Count
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
            Unzipped_Password_List = process_bin_to_password_list( Binary ),
            Password_List = zip( Unzipped_Password_List ),
            Valid_Password_Count = count_valid_passwords2( Password_List ),
            Valid_Password_Count
        ;
        _            
        -> 
            throw( file_not_read )
    end
.

process_bin_to_password_list( Binary ) 
->
    process_bin_to_password_list( binary_to_list(Binary), [], [] )
.

process_bin_to_password_list( [Char | Rest], 
                              Policy_Or_Password, 
                              List ) when ([Char] == "\n") or
                                          ([Char] == ":")
->
    process_bin_to_password_list( Rest,
                                  [],
                                  [lists:reverse(Policy_Or_Password) | List] )
;
process_bin_to_password_list( [Char | Rest], 
                              Policy_Or_Password,
                              List )
->
    process_bin_to_password_list( Rest,
                                  [Char | Policy_Or_Password],
                                  List )
;                              
process_bin_to_password_list( [], Policy_Or_Password, List )
->
    lists:reverse( [lists:reverse(Policy_Or_Password) | List] )
.

zip( Unzipped_List ) -> zip( Unzipped_List, [] ).
zip( [Policy, Password | Rest], Zipped_List ) 
-> 
    zip( Rest, [{Policy, Password} | Zipped_List] )
;
zip( [], Zipped_List )
->
    lists:reverse( Zipped_List )
.

count_valid_passwords( Password_List ) 
-> 
    count_valid_passwords( Password_List, 0 )
.
count_valid_passwords( [Policy_Password_Pair | Rest], Valid_Count )
->
    case validate_password( Policy_Password_Pair ) of
        valid   ->  count_valid_passwords( Rest, Valid_Count + 1 );
        invalid ->  count_valid_passwords( Rest, Valid_Count )
    end
;
count_valid_passwords( [], Valid_Count ) 
-> 
    Valid_Count
.

count_valid_passwords2( Password_List )
->
    count_valid_passwords2( Password_List, 0 )
.
count_valid_passwords2( [Policy_Password_Pair | Rest], Valid_Count )
->
    case validate_password2( Policy_Password_Pair ) of
        valid   ->  count_valid_passwords2( Rest, Valid_Count + 1 );
        invalid ->  count_valid_passwords2( Rest, Valid_Count )
    end
;
count_valid_passwords2( [], Valid_Count ) 
-> 
    Valid_Count
.

validate_password( {Policy, Password} ) 
->
    {Char, Min, Max} = parse_policy( Policy ),
    Char_Count = count_char_occurence_in_password( Password, Char ),
    case (Char_Count =< Max) andalso (Char_Count >= Min) of
        true    ->  valid;
        false   ->  invalid
    end
.

validate_password2( {Policy, Password} ) 
->
    % using parse_policy, replacing Min with Idx 1 and Max with Idx 2.
    {Char, Idx1, Idx2} = parse_policy( Policy ),
    case check_idx_of_char( Password, Char, Idx1, Idx2 ) of
        true    ->  valid;
        false   ->  invalid
    end
.

parse_policy( Policy ) -> parse_policy( Policy, [], 0, 0).
% Getting min/Idx1
parse_policy( [Char | Rest],
              Current_Component,
              0,
              Max ) when [Char] == "-"
->
    parse_policy( Rest, 
                  [],
                  list_to_integer(lists:reverse(Current_Component)),
                  Max )
;
% Getting max/Idx2
parse_policy( [Char | Rest],
              Current_Component,
              Min,
              _Max ) when [Char] == " "
->
    parse_policy( Rest, 
                  [],
                  Min,
                  list_to_integer(lists:reverse(Current_Component)) )
;
% This default setting should get the Char output
parse_policy( [Char | Rest],
              Current_Component,
              Min,
              Max )
->
    parse_policy( Rest, 
                  [Char | Current_Component], 
                  Min,
                  Max )
;
parse_policy( [],
              Current_Component,
              Min,
              Max)
->
    {Current_Component, Min, Max}
.

count_char_occurence_in_password( Password, Char ) 
->
    count_char_occurence_in_password( Password, Char, 0 )
.
count_char_occurence_in_password( [Password_Char | Rest], 
                                  Char, 
                                  Count ) when [Password_Char] == Char
->
    count_char_occurence_in_password( Rest, Char, Count + 1 )
;
count_char_occurence_in_password( [_Password_Char | Rest], 
                                  Char, 
                                  Count )
->
    count_char_occurence_in_password( Rest, Char, Count )
;
count_char_occurence_in_password( [], _Char, Count ) 
->
    Count
.

check_idx_of_char( Password, Char, Idx1, Idx2 )
->
    check_idx_of_char( Password, Char, Idx1, Idx2, 0, 0, false)
.
check_idx_of_char( [Password_Char | Rest],
                   Char,
                   Idx1,
                   Idx2,
                   Current_Idx,
                   0,
                   false ) when ([Password_Char] == Char) andalso
                                (
                                    (Current_Idx == Idx1) or
                                    (Current_Idx == Idx2)
                                )
->
    check_idx_of_char( Rest,
                       Char,
                       Idx1,
                       Idx2,
                       Current_Idx + 1,
                       1,
                       true)
;
check_idx_of_char( [Password_Char | Rest],
                   Char,
                   Idx1,
                   Idx2,
                   Current_Idx,
                   Found,
                   _True_Or_False )  when ([Password_Char] == Char) andalso
                                          (
                                              (Current_Idx == Idx1) or
                                              (Current_Idx == Idx2)
                                          )                         andalso
                                          Found > 0
->
    check_idx_of_char( Rest,
                       Char,
                       Idx1,
                       Idx2,
                       Current_Idx + 1,
                       Found,
                       false)
;
check_idx_of_char( [_Password_Char | Rest],
                   Char,
                   Idx1,
                   Idx2,
                   Current_Idx,
                   Found,
                   True_Or_False )
->
    check_idx_of_char( Rest,
                       Char,
                       Idx1,
                       Idx2,
                       Current_Idx + 1,
                       Found,
                       True_Or_False )
;
check_idx_of_char( [],
                   _Char,
                   _Idx1,
                   _Idx2,
                   _Current_Idx,
                   _Found,
                   True_Or_False )
->
    True_Or_False 
.
