CLASS zcl_llm_tests_ollama DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_llm_tests_ollama IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA(response) = zcl_llm_tests_main=>simple_call( 'llama3.2' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>custom_system_message( 'llama3.2' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>so_simple( 'llama3.2' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>so_complex( 'llama3.2' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>multi_call( model_plan = 'llama3.2' model_code = 'deepseek-coder-v2' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

    response = zcl_llm_tests_main=>func_call_echo( 'qwen2.5' ).
    IF response-success = abap_false.
      out->write( response-out ).
      RETURN.
    ENDIF.
    out->write( response-out ).

  ENDMETHOD.

ENDCLASS.
