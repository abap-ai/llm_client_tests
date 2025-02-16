CLASS zcl_llm_tests_simple_agent DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_llm_tests_simple_agent IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    TRY.
        DATA(tools) = VALUE zllm_tools( ( NEW zcl_llm_tool_calculator( ) ) ).
        DATA(agent) = NEW zcl_llm_text_agent( model = `llama3.2` tools = tools ).
        DATA(response) = agent->execute(
            `What is 15 x 16665?` ).
        out->write( response-choice-message-content ).
      CATCH zcx_llm_agent_error INTO DATA(error).
        out->write( error->get_text(  ) ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
