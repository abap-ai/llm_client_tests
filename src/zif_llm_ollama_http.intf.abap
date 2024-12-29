INTERFACE zif_llm_ollama_http
  PUBLIC .
  CLASS-METHODS: get_client IMPORTING config TYPE zllm_config RETURNING VALUE(result) TYPE REF TO if_http_client.

ENDINTERFACE.
