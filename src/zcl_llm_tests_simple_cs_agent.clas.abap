"! <p class="shorttext synchronized" lang="en">Simple Code Summary Agent Test</p>
CLASS zcl_llm_tests_simple_cs_agent DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_llm_tests_simple_cs_agent IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    TRY.

        " Get class source code
        DATA source TYPE string_table.
        READ REPORT 'ZCL_LLM_TEMPLATE_PARSER=======CS' INTO source.
        CONCATENATE LINES OF source INTO DATA(source_string) SEPARATED BY cl_abap_char_utilities=>newline.
        DATA(agent) = NEW zcl_llm_text_agent( model = `claude-3.5-haiku`).
        DATA(response) = agent->execute(
            `Write a short summary of the given class. Start with a short summary followed by it's main features and it's main technical components and architecture (most important only). \n`
            && source_string ).
        out->write( response-choice-message-content ).
      CATCH zcx_llm_agent_error INTO DATA(error).
        out->write( error->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
