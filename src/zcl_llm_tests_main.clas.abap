"! <p class="shorttext synchronized" lang="en">LLM Test Scenarios to be re-used as provider test-runners</p>
CLASS zcl_llm_tests_main DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF response,
             out     TYPE string_table,
             success TYPE sap_bool,
           END OF response.

    "! <p class="shorttext synchronized"></p>
    "! A relatively simple call to the LLM
    "! @parameter model  | <p class="shorttext synchronized">LLM Model</p>
    "! @parameter result | <p class="shorttext synchronized">Result</p>
    CLASS-METHODS simple_call
      IMPORTING model         TYPE zllm_model
      RETURNING VALUE(result) TYPE response.

    "! <p class="shorttext synchronized"></p>
    "! Structured output with a simple structure
    "! @parameter model  | <p class="shorttext synchronized">LLM Model</p>
    "! @parameter result | <p class="shorttext synchronized">Result</p>
    CLASS-METHODS so_simple
      IMPORTING model         TYPE zllm_model
      RETURNING VALUE(result) TYPE response.

    "! <p class="shorttext synchronized"></p>
    "! Complex structured output
    "! @parameter model  | <p class="shorttext synchronized">LLM Model</p>
    "! @parameter result | <p class="shorttext synchronized">Result</p>
    CLASS-METHODS so_complex
      IMPORTING model         TYPE zllm_model
      RETURNING VALUE(result) TYPE response.

    "! <p class="shorttext synchronized"></p>
    "! Multiple Calls first using a model to create an implementation plan and then
    "! a code model to create the code
    "! @parameter model_plan | <p class="shorttext synchronized">LLM Model for plan task</p>
    "! @parameter model_code | <p class="shorttext synchronized">LLM Model for coding</p>
    "! @parameter result     | <p class="shorttext synchronized">Result</p>
    CLASS-METHODS multi_call
      IMPORTING model_plan    TYPE zllm_model
                model_code    TYPE zllm_model
      RETURNING VALUE(result) TYPE response.

    "! <p class="shorttext synchronized"></p>
    "! Function (Tool) Call Example using the ECHO tool that allows
    "! Tool calls using the echo class for tool use without any real tool implementation
    "! @parameter model  | <p class="shorttext synchronized">LLM Model</p>
    "! @parameter result | <p class="shorttext synchronized">Result</p>
    CLASS-METHODS func_call_echo
      IMPORTING model         TYPE zllm_model
      RETURNING VALUE(result) TYPE response.

    "! <p class="shorttext synchronized">Simple example with system message</p>
    "! Will talk like a pirate ;-) ... used to make sure system messages work fine.
    "! @parameter model  | <p class="shorttext synchronized">LLM Model</p>
    "! @parameter result | <p class="shorttext synchronized">Result</p>
    CLASS-METHODS custom_system_message
      IMPORTING model         TYPE zllm_model
      RETURNING VALUE(result) TYPE response.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_llm_tests_main IMPLEMENTATION.
  METHOD simple_call.
    TRY.
        DATA(client) = zcl_llm_factory=>get_client( model ).
      CATCH zcx_llm_authorization INTO DATA(error).
        APPEND |Authorization Error { error->if_message~get_text( ) }| TO result-out ##NO_TEXT.
        RETURN.
    ENDTRY.
    DATA(request) = client->new_request( ).

    request->add_message( VALUE #( role    = client->role_user
                                   content = `What makes the ABAP programming language special?` ) ) ##NO_TEXT.

    DATA(response) = client->chat( request = request ).

    IF response-success = abap_false.
      APPEND |Error: return code { response-error-http_code } message { response-error-error_text }| TO result-out ##NO_TEXT.
      RETURN.
    ENDIF.
    APPEND |Simple call result-out with { response-usage-prompt_tokens } input tokens and { response-usage-completion_tokens } output tokens.| TO result-out ##NO_TEXT.
    APPEND response-choice-message-content TO result-out.
    result-success = abap_true.
  ENDMETHOD.

  METHOD so_simple.
    TRY.
        DATA(client) = zcl_llm_factory=>get_client( model ).
      CATCH zcx_llm_authorization INTO DATA(error).
        APPEND |Authorization Error { error->if_message~get_text( ) }| TO result-out ##NO_TEXT.
        RETURN.
    ENDTRY.
    DATA(request) = client->new_request( ).

    DATA: BEGIN OF dog,
            breed         TYPE string,
            avg_age       TYPE i,
            avg_height_cm TYPE i,
            size_category TYPE string,
          END OF dog.
    DATA: BEGIN OF so,
            dogs LIKE STANDARD TABLE OF dog WITH EMPTY KEY,
          END OF so.
    DATA descriptions TYPE zif_llm_so=>def_descriptions.

    descriptions = VALUE #(
        ( fieldname = 'breed' description = 'Name of breed' )
        ( fieldname = 'avg_age' description = 'Average age' )
        ( fieldname = 'avg_height_cm' description = 'Average shoulder height in cm' )
        ( fieldname = 'size_category' description = 'Size Category' enum_values = VALUE #( ( `small` ) ( `medium` ) ( `large` ) ) ) ) ##NO_TEXT.

    request->add_message(
        VALUE #(
            role    = client->role_user
            content = |Create a list of dog breeds with name, average max age, average shoulder height and categorize them into small, medium and large.|
            && | Return at least 10 breeds.| ) ) ##NO_TEXT.

    request->set_structured_output( data_desc    = CAST #( cl_abap_datadescr=>describe_by_data( so ) )
                                    descriptions = descriptions ).

    " A low temperature often helps with structured output
    request->options( )->set_temperature( '0.1' ).

    DATA(response) = client->chat( request = request ).

    IF response-success = abap_false.
      APPEND |Error: return code { response-error-http_code } message { response-error-error_text }| TO result-out ##NO_TEXT.
      RETURN.
    ENDIF.
    FIELD-SYMBOLS <dogs> TYPE any.
    ASSIGN response-choice-structured_output->* TO <dogs>.
    so = <dogs>.

    APPEND |Structured Output call result-out with { response-usage-prompt_tokens } input tokens and { response-usage-completion_tokens } output tokens.| TO result-out ##NO_TEXT.

    LOOP AT so-dogs ASSIGNING FIELD-SYMBOL(<dog>).
      APPEND |Breed: { <dog>-breed } Avg Age: { <dog>-avg_age } Avg Height: { <dog>-avg_height_cm } Size Category { <dog>-size_category }| TO result-out ##NO_TEXT.
    ENDLOOP.
    IF sy-subrc <> 0.
      APPEND |No output result| TO result-out ##NO_TEXT.
      RETURN.
    ENDIF.
    result-success = abap_true.
  ENDMETHOD.

  METHOD so_complex.
    TRY.
        DATA(client) = zcl_llm_factory=>get_client( model ).
      CATCH zcx_llm_authorization INTO DATA(error).
        APPEND |Authorization Error { error->if_message~get_text( ) }| TO result-out ##NO_TEXT.
        RETURN.
    ENDTRY.
    DATA(request) = client->new_request( ).

    DATA: BEGIN OF dog_alt,
            breed         TYPE string,
            advantages    TYPE string,
            disadvantages TYPE string,
            decision      TYPE string,
          END OF dog_alt.
    DATA: BEGIN OF dog,
            recommended_breed TYPE string,
            reason            TYPE string,
            alternatives      LIKE STANDARD TABLE OF dog_alt WITH EMPTY KEY,
          END OF dog.
    DATA descriptions TYPE zif_llm_so=>def_descriptions.

    descriptions = VALUE #( ( fieldname = 'recommended_breed' description = 'Name of the recommended dog breed' )
                            ( fieldname = 'reason' description = 'Reasons for your choice' )
                            ( fieldname = 'alternatives' description = 'Alternative breends to consider' )
                            ( fieldname = 'alternatives-breed' description = 'Breed name' )
                            ( fieldname = 'alternatives-advantages' description = 'Advantages of this breed' )
                            ( fieldname = 'alternatives-disadvantages' description = 'Disadvantages of this breed' )
                            ( fieldname = 'alternatives-decision' description = 'Why this is was not your main choice' ) ) ##NO_TEXT.

    request->add_message(
        VALUE #(
            role    = client->role_user
            content = |Recommend a family friendly dog breed medium or large size and overall friendly but sportive character.|
            && | Also list alternative breends to consider with advantages, disadvantages and why you didn't choose this one.| ) ) ##NO_TEXT.
    request->set_structured_output( data_desc    = CAST #( cl_abap_datadescr=>describe_by_data( dog ) )
                                    descriptions = descriptions ).

    " A low temperature often helps with structured output
    request->options( )->set_temperature( '0.1' ).

    DATA(response) = client->chat( request = request ).

    IF response-success = abap_false.
      APPEND |Error: return code { response-error-http_code } message { response-error-error_text }| TO result-out ##NO_TEXT.
      RETURN.
    ENDIF.
    FIELD-SYMBOLS <dog> TYPE any.
    ASSIGN response-choice-structured_output->* TO <dog>.
    dog = <dog>.
    APPEND |Complex Structured Output result-out with { response-usage-prompt_tokens } input tokens and { response-usage-completion_tokens } output tokens.| TO result-out ##NO_TEXT.
    APPEND |Recommended breed: { dog-recommended_breed }| TO result-out ##NO_TEXT.
    APPEND |Reason: { dog-reason }| TO result-out ##NO_TEXT.
    LOOP AT dog-alternatives INTO DATA(alt).
      APPEND |Alternative breed: { alt-breed }\nAdvantages: { alt-advantages }\nDisadvantages: { alt-disadvantages }\nDecision: { alt-decision }| TO result-out ##NO_TEXT.
    ENDLOOP.

    IF sy-subrc <> 0.
      APPEND |No output result| TO result-out ##NO_TEXT.
      RETURN.
    ENDIF.

    result-success = abap_true.
  ENDMETHOD.

  METHOD multi_call.
    TRY.
        DATA(client) = zcl_llm_factory=>get_client( model_plan ).
      CATCH zcx_llm_authorization INTO DATA(error).
        APPEND |Authorization Error { error->if_message~get_text( ) }| TO result-out ##NO_TEXT.
        RETURN.
    ENDTRY.
    DATA(request) = client->new_request( ).

    request->add_message(
        VALUE #(
            role    = client->role_user
            content = |Write a short technical concept on how to develop a class to convert from snake case to camel case. |
            && |Do not write any code. Just outline main characteristics and points to consider. | ) ) ##NO_TEXT.

    DATA(response) = client->chat( request = request ).
    IF response-success = abap_false.
      APPEND |Error: return code { response-error-http_code } message { response-error-error_text }| TO result-out ##NO_TEXT.
      RETURN.
    ENDIF.
    APPEND |First call with { response-usage-prompt_tokens } input tokens and { response-usage-completion_tokens } output tokens.| TO result-out ##NO_TEXT.
    APPEND `Response of first call to llm: ` TO result-out ##NO_TEXT.
    APPEND response-choice-message-content TO result-out.

    " Switching to a different model taking over all history
    TRY.
        DATA(o1_clnt) = zcl_llm_factory=>get_client( model_code  ).
      CATCH zcx_llm_authorization INTO error.
        APPEND |Authorization Error { error->if_message~get_text( ) }| TO result-out ##NO_TEXT.
        RETURN.
    ENDTRY.
    DATA(qwen_request) = o1_clnt->new_request( ).

    " Add all messages from the last request
    qwen_request->add_messages( request->get_messages( ) ).

    " Add the choice from the last result-out
    qwen_request->add_choice( response-choice ).

    " Add a single message
    qwen_request->add_message(
        VALUE #(
            role    = client->role_user
            content = |Now implement this in ABAP considering abap clean code principles. Avoid variable prefixes like lv_ and iv_.| ) ) ##NO_TEXT.

    response = o1_clnt->chat( qwen_request ).
    IF response-success = abap_false.
      APPEND |Error: return code { response-error-http_code } message { response-error-error_text }| TO result-out ##NO_TEXT.
      RETURN.
    ENDIF.
    APPEND |Second Call with { response-usage-prompt_tokens } input tokens and { response-usage-completion_tokens } output tokens.| TO result-out ##NO_TEXT.
    APPEND `Response of second call to llm: ` TO result-out ##NO_TEXT.
    APPEND response-choice-message-content TO result-out.
    result-success = abap_true.
  ENDMETHOD.

  METHOD func_call_echo.
    TRY.
        DATA(client) = zcl_llm_factory=>get_client( model ).
      CATCH zcx_llm_authorization INTO DATA(error).
        APPEND |Authorization Error { error->if_message~get_text( ) }| TO result-out ##NO_TEXT.
        RETURN.
    ENDTRY.
    DATA(request) = client->new_request( ).

    request->add_message( VALUE #( role    = client->role_user
                                   content = `How is the weather in Stuttgart?` ) ) ##NO_TEXT.

    " Low temperature is also recommended for tool calls
    request->options( )->set_temperature( '0.1' ).

    DATA: BEGIN OF tool_data,
            city TYPE string,
          END OF tool_data.

    " Use the echo tool (usually use a fully implemented tool, this is for testing)
    DATA tool_details TYPE zif_llm_tool=>tool_details.
    tool_details-name        = `get_weather_for_city` ##NO_TEXT.
    tool_details-description = `Get real-time weather information for a specific city. One City per call only` ##NO_TEXT.
    tool_details-type        = zif_llm_tool=>type_function.
    tool_details-parameters-data_desc    ?= cl_abap_typedescr=>describe_by_data( tool_data ).
    tool_details-parameters-descriptions  = VALUE #( ( fieldname = `city` description = `City to get the weather for` ) ) ##NO_TEXT.

    DATA(echo_tool) = NEW zcl_llm_tool_echo( tool_details = tool_details ).

    request->add_tool( echo_tool ).

    DATA(response) = client->chat( request = request ).

    IF response-success = abap_false.
      IF response-error-tool_parse_error = abap_true.
        APPEND |Tool call error: { response-error-error_text }| TO result-out ##NO_TEXT.
        RETURN.
      ENDIF.
      APPEND |Error: return code { response-error-http_code } message { response-error-error_text }| TO result-out ##NO_TEXT.
      RETURN.
    ENDIF.
    APPEND |Tool call result-out with { response-usage-prompt_tokens } input tokens and { response-usage-completion_tokens } output tokens.| TO result-out ##NO_TEXT.

    IF lines( response-choice-tool_calls ) <> 1.
      APPEND `Incorrect number or tool calls - stopping!` TO result-out ##NO_TEXT.
      RETURN.
    ENDIF.

    " We know there should be only 1 result-out, usually you would iterate etc.
    ASSIGN response-choice-tool_calls[ 1 ] TO FIELD-SYMBOL(<tool>).
    ASSIGN <tool>-function-arguments->* TO FIELD-SYMBOL(<tool_data>).
    tool_data = <tool_data>.
    APPEND |Tool call for { <tool>-function-name } with City { tool_data-city }| TO result-out ##NO_TEXT.

    " Append the tool call to the llm messages
    request->add_tool_choices( VALUE #( ( <tool> ) ) ).

    " Simulate a tool result-out. Usually this would be done by the tool internally.
    DATA: BEGIN OF forecast_entry,
            day          TYPE string,
            min_temp_c   TYPE i,
            max_temp_c   TYPE i,
            rain_percent TYPE i,
          END OF forecast_entry.
    DATA: BEGIN OF forecast,
            forecasts LIKE STANDARD TABLE OF forecast_entry WITH EMPTY KEY,
          END OF forecast.

    forecast = VALUE #( forecasts = VALUE #( ( day = `Monday` min_temp_c = 8 max_temp_c = 20 rain_percent = 10  )
                                             ( day = `Tuesday` min_temp_c = 6 max_temp_c = 16 rain_percent = 60  )
                                             ( day = `Wednesday` min_temp_c = 9 max_temp_c = 24 rain_percent = 0  ) ) )
            ##NO_TEXT.

    echo_tool->execute( data         = REF #( forecast )
                        tool_call_id = <tool>-id ).

    " Append the tool result-out and call the LLM again to get the response
    request->add_tool_result( echo_tool ).
    " Disable tool usage
    request->set_tool_choice( zif_llm_chat_request=>tool_choice_none ).

    " Execute and evaluate next call
    response = client->chat( request ).

    IF response-success = abap_false.
      IF response-error-tool_parse_error = abap_true.
        APPEND |Tool call error: { response-error-error_text }| TO result-out ##NO_TEXT.
        RETURN.
      ENDIF.
      APPEND |Error: return code { response-error-http_code } message { response-error-error_text }| TO result-out ##NO_TEXT.
      RETURN.
    ENDIF.
    APPEND |Call with tool response with { response-usage-prompt_tokens } input tokens and { response-usage-completion_tokens } output tokens.| TO result-out ##NO_TEXT.
    APPEND response-choice-message-content TO result-out.
    result-success = abap_true.
  ENDMETHOD.

  METHOD custom_system_message.
    TRY.
        DATA(client) = zcl_llm_factory=>get_client( model ).
      CATCH zcx_llm_authorization INTO DATA(error).
        APPEND |Authorization Error { error->if_message~get_text( ) }| TO result-out ##NO_TEXT.
        RETURN.
    ENDTRY.
    DATA(request) = client->new_request( ).
    request->add_message( VALUE #( role    = client->role_system
                                   content = `You are a story telling pirate.` ) ) ##NO_TEXT.
    request->add_message( VALUE #( role    = client->role_user
                                   content = `I see land!` ) ) ##NO_TEXT.

    DATA(response) = client->chat( request = request ).

    IF response-success = abap_false.
      APPEND |Error: return code { response-error-http_code } message { response-error-error_text }| TO result-out ##NO_TEXT.
      RETURN.
    ENDIF.
    APPEND |System call result-out with { response-usage-prompt_tokens } input tokens and { response-usage-completion_tokens } output tokens.| TO result-out ##NO_TEXT.
    APPEND response-choice-message-content TO result-out.
    result-success = abap_true.
  ENDMETHOD.

ENDCLASS.
