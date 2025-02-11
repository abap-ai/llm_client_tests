"! <p class="shorttext synchronized" lang="en">Test Azure AI Foundry models (live test)</p>
CLASS zcl_llm_tests_azureaif DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_llm_tests_azureaif IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA(response) = zcl_llm_tests_main=>simple_call( 'az-llama3.3' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>custom_system_message( 'az-llama3.3' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>so_simple( 'az-llama3.3' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>so_complex( 'az-llama3.3' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>multi_call( model_plan = 'az-mistral-large'
                                               model_code = 'az-llama3.3' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>func_call_echo( 'az-mistral-large' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).
  ENDMETHOD.

ENDCLASS.
