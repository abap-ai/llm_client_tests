# LLM Client Testing Repository

## Overview

This repository contains tests for the [ABAP LLM clients](https://github.com/abap-ai/llm_client_tests), demonstrating various interaction patterns and capabilities across different LLM providers. You can use it as simple example on how to use the LLM client.

## Features

- Multiple LLM client implementations:
  - Ollama
  - OpenAI
  - OpenRouter

### Test Methods

The test class `ZCL_LLM_TESTS_XXXX` includes several testing scenarios:

1. `simple_call()`: Basic LLM interaction
   - Sends a simple query about ABAP programming language
   - Demonstrates basic chat functionality

2. `so_simple()`: Structured Output (Simple)
   - Retrieves a list of dog breeds
   - Utilizes structured output with predefined schema
   - Demonstrates type-safe data retrieval

3. `so_complex()`: Structured Output (Complex)
   - Recommends a dog breed with detailed alternatives
   - Shows nested structured output capabilities
   - Includes multi-level data extraction

4. `multi_call()`: Multi-Model Interaction
   - Demonstrates switching between different LLM providers
   - Shows conversation history preservation
   - Illustrates step-by-step problem-solving

## Requirements

- ABAP development environment
- LLM client library
- Configured LLM providers (Ollama, OpenAI, OpenRouter)
    - RFC Destinations for all providers
    - STRUST setup
    - SSL Setup (see abapGIT docs on recommended settings in case of issues https://docs.abapgit.org/user-guide/setup/ssl-setup.html)
    - Configured models as documented in the source code

## Usage

Run the specific class in ADT Eclipse as ABAP Application (Console) to execute test scenarios.

## Contributing

Contributions are welcome for all official clients. Note that this repository is focused on tests for the LLM Clients. Depending on demand a future examples repo is planned, if you'd like to see that open an issue or discussion in the llm client repo.

## License

MIT (see license file).