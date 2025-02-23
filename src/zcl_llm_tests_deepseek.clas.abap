CLASS zcl_llm_tests_deepseek DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_llm_tests_deepseek IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA(response) = zcl_llm_tests_main=>simple_call( 'ds-chat' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>custom_system_message( 'ds-chat' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    " Structured Output currently not supported https://github.com/deepseek-ai/DeepSeek-V3/issues/302
    response = zcl_llm_tests_main=>multi_call( model_plan = 'ds-reason'
                                               model_code = 'ds-chat' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>func_call_echo( 'ds-chat' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>execute_tool( 'ds-chat' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).
  ENDMETHOD.

ENDCLASS.
