"! <p class="shorttext synchronized" lang="en">Test Anthropic models (live test)</p>
CLASS zcl_llm_tests_anthropic DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_llm_tests_anthropic IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA(response) = zcl_llm_tests_main=>simple_call( 'an-haiku-3.5' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>custom_system_message( 'an-haiku-3.5' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    " Currently no structured output support, might simulate this via tool call later
*    response = zcl_llm_tests_main=>so_simple( 'an-haiku-3.5' ).
*    IF response-success = abap_false.
*      out->write( response-out ).
*      RETURN.
*    ENDIF.
*    out->write( response-out ).
*
*    response = zcl_llm_tests_main=>so_complex( 'an-haiku-3.5' ).
*    IF response-success = abap_false.
*      out->write( response-out ).
*      RETURN.
*    ENDIF.
*    out->write( response-out ).

    response = zcl_llm_tests_main=>multi_call( model_plan = 'an-haiku-3.5'
                                               model_code = 'an-sonnet-3.5' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>func_call_echo( 'an-haiku-3.5' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).
  ENDMETHOD.

ENDCLASS.
