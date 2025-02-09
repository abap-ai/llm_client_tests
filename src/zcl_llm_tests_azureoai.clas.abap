"! <p class="shorttext synchronized" lang="en">Test Azure OpenAI models (live test)</p>
CLASS zcl_llm_tests_azureoai DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_llm_tests_azureoai IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA(response) = zcl_llm_tests_main=>simple_call( 'az-gpt-4o-mini' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>custom_system_message( 'az-gpt-4o-mini' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>so_simple( 'az-gpt-4o-mini' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>so_complex( 'az-gpt-4o-mini' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>multi_call( model_plan = 'az-gpt-4o-mini'
                                               model_code = 'az-gpt-4o' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>func_call_echo( 'az-gpt-4o-mini' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).
  ENDMETHOD.

ENDCLASS.
