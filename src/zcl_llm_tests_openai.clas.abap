CLASS zcl_llm_tests_openai DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS:
      so_complex IMPORTING out TYPE REF TO if_oo_adt_intrnl_classrun,
      simple_call IMPORTING out TYPE REF TO if_oo_adt_intrnl_classrun,
      so_simple IMPORTING out TYPE REF TO if_oo_adt_intrnl_classrun,
      multi_call IMPORTING out TYPE REF TO if_oo_adt_intrnl_classrun.
ENDCLASS.



CLASS zcl_llm_tests_openai IMPLEMENTATION.

  METHOD simple_call.
    " Setup: this maps to openai-4o-mini

    DATA(client) = zcl_llm_factory=>get_client( 'gpt-4o-mini' ).
    DATA(request) = client->new_request( ).

    request-metadata-caller = 'zcl_llm_test_openai'.
    request-messages = VALUE #( ( role = 'user' content = `What makes the ABAP programming language special?` ) ).

    DATA(response) = client->chat( request = request ).

    IF response-success = abap_false.
      out->write( |Error: return code { response-error-http_code } message { response-error-error_text }| ).
      RETURN.
    ENDIF.
    out->write( |Simple call result with { response-usage-prompt_tokens } input tokens and { response-usage-completion_tokens } output tokens.| ).
    LOOP AT response-choices INTO DATA(choice).
      out->write( choice-message-content ).
    ENDLOOP.


  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    simple_call( out ).
    so_simple( out ).
    so_complex( out ).
    multi_call( out ).
  ENDMETHOD.

  METHOD so_simple.
    " Setup: this maps to openai-4o-mini

    DATA(client) = zcl_llm_factory=>get_client( 'gpt-4o-mini' ).
    DATA(request) = client->new_request( ).

    DATA: BEGIN OF dog,
            breed         TYPE string,
            avg_age       TYPE i,
            avg_height_cm TYPE i,
            size_category TYPE string,
          END OF dog.
    DATA: BEGIN OF so,
            dogs LIKE STANDARD TABLE OF dog WITH EMPTY KEY,
          END OF so,
          descriptions TYPE zif_llm_so=>def_descriptions.

    descriptions = VALUE #(
      ( fieldname = 'dogs' description = 'Array of dog' )
      ( fieldname = 'dogs-breed' description = 'Name of breed' )
      ( fieldname = 'dogs-avg_age' description = 'Average age' )
      ( fieldname = 'dogs-avg_height_cm' description = 'Average shoulder height in cm' )
      ( fieldname = 'dogs-size_category' description = 'Size Category' enum_values = VALUE #( ( `small` ) ( `medium` ) ( `large` ) ) ) ).

    request-metadata-caller = 'zcl_llm_test_openai'.
    request-messages = VALUE #( ( role = 'user'
        content = |Create a list of dog breeds with name, average max age, average shoulder height and categorize them into small, medium and large.|
               && | Return at least 10 breeds.| ) ).
    request-structured_output->set_schema( data = so description = descriptions ).
    request-use_structured_output = abap_true.

    " A low temperature often helps with structured output
    request-options->set_temperature( '0.1' ).

    DATA(response) = client->chat( request = request ).

    IF response-success = abap_false.
      out->write( |Error: return code { response-error-http_code } message { response-error-error_text }| ).
      RETURN.
    ENDIF.
    FIELD-SYMBOLS <dogs> TYPE any.
    ASSIGN response-structured_output->* TO <dogs>.
    so = <dogs>.

    out->write( |Structured Output call result with { response-usage-prompt_tokens } input tokens and { response-usage-completion_tokens } output tokens.| ).

    LOOP AT so-dogs ASSIGNING FIELD-SYMBOL(<dog>).
      out->write( |Breed: { <dog>-breed } Avg Age: { <dog>-avg_age } Avg Height: { <dog>-avg_height_cm } Size Category { <dog>-size_category }|  ).
    ENDLOOP.

  ENDMETHOD.

  METHOD so_complex.
    " Setup: this maps to openai-4o-mini

    DATA(client) = zcl_llm_factory=>get_client( 'gpt-4o-mini' ).
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

    descriptions = VALUE #(
          ( fieldname = 'recommended_breed' description = 'Name of the recommended dog breed' )
          ( fieldname = 'reason' description = 'Reasons for your choice' )
          ( fieldname = 'alternatives' description = 'Alternative breends to consider' )
          ( fieldname = 'alternatives-breed' description = 'Breed name' )
          ( fieldname = 'alternatives-advantages' description = 'Advantages of this breed' )
          ( fieldname = 'alternatives-disadvantages' description = 'Disadvantages of this breed' )
          ( fieldname = 'alternatives-decision' description = 'Why this is was not your main choice' ) ).

    request-metadata-caller = 'zcl_llm_test_openai'.
    request-messages = VALUE #( ( role = 'user'
        content = |Recommend a family friendly dog breed medium or large size and overall friendly but sportive character.|
               && | Also list alternative breends to consider with advantages, disadvantages and why you didn't choose this one.| ) ).
    request-structured_output->set_schema( data = dog description = descriptions ).
    request-use_structured_output = abap_true.

    " A low temperature often helps with structured output
    request-options->set_temperature( '0.1' ).

    DATA(response) = client->chat( request = request ).

    IF response-success = abap_false.
      out->write( |Error: return code { response-error-http_code } message { response-error-error_text }| ).
      RETURN.
    ENDIF.
    FIELD-SYMBOLS <dog> TYPE any.
    ASSIGN response-structured_output->* TO <dog>.
    dog = <dog>.
    out->write( |Complex Structured Output result with { response-usage-prompt_tokens } input tokens and { response-usage-completion_tokens } output tokens.| ).
    out->write( |Recommended breed: { dog-recommended_breed }| ).
    out->write( |Reason: { dog-reason }| ).
    LOOP AT dog-alternatives INTO DATA(alt).
      out->write( |Alternative breed: { alt-breed }\nAdvantages: { alt-advantages }\nDisadvantages: { alt-disadvantages }\nDecision: { alt-decision }| ).
    ENDLOOP.

  ENDMETHOD.

  METHOD multi_call.
    " Setup: this maps to openai-4o-mini and o1-mini
    DATA(client) = zcl_llm_factory=>get_client( 'gpt-4o-mini' ).
    DATA(request) = client->new_request( ).

    request-metadata-caller = 'zcl_llm_test_openai'.
    request-messages = VALUE #( ( role = 'user'
        content = |Write a short technical concept on how to develop a class to convert from snake case to camel case. |
        && |Do not write any code. Just outline main characteristics and points to consider. | ) ).

    DATA(response) = client->chat( request = request ).
    IF response-success = abap_false.
      out->write( |Error: return code { response-error-http_code } message { response-error-error_text }| ).
      RETURN.
    ENDIF.
    out->write( |First call with { response-usage-prompt_tokens } input tokens and { response-usage-completion_tokens } output tokens.| ).
    out->write( `Response of first call to llm: ` ).
    LOOP AT response-choices INTO DATA(choice).
      out->write( choice-message-content ).
    ENDLOOP.

    "Switching to a different model taking over all history
    DATA(haiku_clnt) = zcl_llm_factory=>get_client( 'o1-mini' ).
    DATA(haiku_request) = haiku_clnt->new_request( ).
    APPEND LINES OF request-messages TO haiku_request-messages.
    APPEND VALUE #( role = response-choices[ 1 ]-message-role content = response-choices[ 1 ]-message-content ) TO haiku_request-messages.
    APPEND VALUE #( role = 'user'
        content = |Now implement this in ABAP considering abap clean code principles. Avoid variable prefixes like lv_ and iv_.| ) TO haiku_request-messages.
    response = haiku_clnt->chat( request = haiku_request ).
    IF response-success = abap_false.
      out->write( |Error: return code { response-error-http_code } message { response-error-error_text }| ).
      RETURN.
    ENDIF.
    out->write( |Second Call with { response-usage-prompt_tokens } input tokens and { response-usage-completion_tokens } output tokens.| ).
    out->write( `Response of second call to llm: ` ).
    LOOP AT response-choices INTO choice.
      out->write( choice-message-content ).
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
