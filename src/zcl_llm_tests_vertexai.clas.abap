"! <p class="shorttext synchronized" lang="en">Vertex AI Tests</p>
CLASS zcl_llm_tests_vertexai DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_llm_tests_vertexai IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA(response) = zcl_llm_tests_main=>simple_call( 'gv-gemini-1.5-flash' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>custom_system_message( 'gv-gemini-1.5-flash' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>so_simple( 'gv-gemini-1.5-flash' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>so_complex( 'gv-gemini-1.5-flash' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>multi_call( model_plan = 'gv-gemini-1.5-flash'
                                               model_code = 'gv-gemini-1.5-pro' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).
    "
    response = zcl_llm_tests_main=>func_call_echo( 'gv-gemini-1.5-flash' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).
  ENDMETHOD.

ENDCLASS.
