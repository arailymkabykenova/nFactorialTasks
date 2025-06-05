#!/usr/bin/env python3
"""
02 — Structured Output Lab (Study Q&A Focus)

Demonstrates how the Study Q&A Assistant can provide structured JSON output.
Compares:
1. JSON Mode: Directly asking for JSON matching LectureSummary.
2. Function Tools (Strict): Using a function schema (derived from LectureSummary)
   to get structured arguments from the assistant.

Usage: python scripts/02_structured_output.py
Docs: https://platform.openai.com/docs/guides/structured-output
"""

import os
import sys
import json
from pathlib import Path
from typing import List, Optional 
from dotenv import load_dotenv
from openai import OpenAI
from pydantic import BaseModel, Field

# Load environment variables
load_dotenv()

# Pydantic Model for Structured Output
class LectureSummary(BaseModel):
    """Structured explanation of a lecture topic."""
    topic: str = Field(description="The name of the topic being explained")
    explanation: str = Field(description="Simple and clear explanation of the topic")
    examples: List[str] = Field(description="Practical examples related to the topic")
    key_points: List[str] = Field(description="Main takeaways or important ideas")
    difficulty: Optional[str] = Field(None, description="Difficulty level: Beginner, Intermediate, or Advanced") # Made optional explicit
    resources: Optional[List[str]] = Field(None, description="Suggested resources to learn more") # Made optional explicit


def get_client():
    """Initialize OpenAI client with API key from environment."""
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("❌ Error: OPENAI_API_KEY not found in environment variables.")
        sys.exit(1)
    
    org_id = os.getenv("OPENAI_ORG")
    client_kwargs = {"api_key": api_key}
    if org_id:
        client_kwargs["organization"] = org_id
    
    return OpenAI(**client_kwargs)

def load_assistant_id():
    """Load assistant ID from .assistant file."""
    assistant_file = Path(__file__).resolve().parent.parent / ".assistant"
    if not assistant_file.exists():
        print(f"❌ No assistant file found at {assistant_file}. Please run: python scripts/00_bootstrap.py (or similar)")
        sys.exit(1)
    return assistant_file.read_text().strip()

def demonstrate_json_mode(client: OpenAI, assistant_id: str):
    """Demonstrate basic JSON mode for LectureSummary."""
    print("🔧 Demonstrating JSON Mode (for LectureSummary)")
    print("-" * 40)
    
    topic_for_summary = "Recursion in Programming" # Example topic
    thread = client.beta.threads.create(
        messages=[{
            "role": "user",
            "content": f"""Create a Lecture Summary for the topic: "{topic_for_summary}".
            Ensure the JSON object has the following fields: topic, explanation, examples (list), key_points (list), and optionally difficulty and resources (list)."""
        }]
    )
    
    run = client.beta.threads.runs.create_and_poll(
        thread_id=thread.id,
        assistant_id=assistant_id,
        response_format={"type": "json_object"},
        instructions="You are a Study Q&A Assistant. Respond with valid JSON matching the requested LectureSummary structure. Populate all requested fields accurately."
    )
    
    if run.status == "completed":
        messages = client.beta.threads.messages.list(thread_id=thread.id)
        response_content_str = messages.data[0].content[0].text.value
        
        print(f"📄 Raw JSON Response for '{topic_for_summary}':")
        print(response_content_str)
        
        try:
            processed_content_str = response_content_str.strip()
            if processed_content_str.startswith("```json"):
                processed_content_str = processed_content_str[len("```json"):].strip()
            elif processed_content_str.startswith("```"):
                 processed_content_str = processed_content_str[len("```"):].strip()
            if processed_content_str.endswith("```"):
                processed_content_str = processed_content_str[:-len("```")].strip()
            
            print(f"DEBUG_JSON_MODE: Processed for parsing: '{processed_content_str}'")
            json_data = json.loads(processed_content_str)
            print("\n✅ Valid JSON parsed successfully")
            print(f"📊 Fields found: {list(json_data.keys())}")
            
            try:
                lecture_summary_obj = LectureSummary(**json_data)
                print("✅ Pydantic validation successful (LectureSummary)!")
                return lecture_summary_obj
            except Exception as e:
                print(f"⚠️  Pydantic validation failed for LectureSummary: {e}")
                return json_data 
            
        except json.JSONDecodeError as e:
            print(f"❌ Invalid JSON from assistant: {e}")
            print(f"   Content that failed parsing: '{response_content_str}'")
            return None
    else:
        print(f"❌ Run failed (JSON Mode). Status: {run.status}")
        return None

def demonstrate_function_tools_strict(client: OpenAI, assistant_id: str):
    """Demonstrate function tools with strict schema for LectureSummary."""
    print("\n🎯 Demonstrating Function Tools (Strict Schema for LectureSummary)")
    print("-" * 60)
    
   
    pydantic_params_schema = LectureSummary.model_json_schema()
 
    function_parameters = {
        "type": "object",
        "properties": pydantic_params_schema.get("properties", {}),
        # 'required' list is derived from Pydantic model (non-Optional fields)
        "required": pydantic_params_schema.get("required", []),
        "additionalProperties": False
    }


    function_schema_definition = {
        "name": "summarize_lecture_topic", # Consistent name
        "description": "Summarizes a lecture topic providing explanation, examples, key points, and optionally difficulty and resources.",
        "strict": True,
        "parameters": function_parameters
    }
    
    print(f"DEBUG: Function Schema (parameters part) being sent to OpenAI:\n{json.dumps(function_parameters, indent=2)}")

    try:
        print("🔧 Updating assistant with 'summarize_lecture_topic' tool...")
        client.beta.assistants.update(
            assistant_id=assistant_id,
            tools=[
                {"type": "file_search"},
                {"type": "function", "function": function_schema_definition}
            ]
        )
        print("✅ Assistant updated successfully.")
    except Exception as e:
        print(f"❌ Failed to update assistant with function tool: {e}")
        return None # Cannot proceed if assistant update fails
    
    topic_for_function = "Dynamic Programming"
    thread = client.beta.threads.create(
        messages=[{
            "role": "user",
            # Corrected prompt to use the defined function name and provide a topic
            "content": f"""Please summarize the topic '{topic_for_function}' using the summarize_lecture_topic function. 
            Include its explanation, examples, key_points, and if possible, its difficulty and some learning resources."""
        }]
    )
    
    print(f"🚀 Running assistant to get structured summary for '{topic_for_function}' via function call...")
    run = client.beta.threads.runs.create_and_poll(
        thread_id=thread.id,
        assistant_id=assistant_id,
        # Corrected instructions to use the defined function name
        instructions="You are a Study Q&A Assistant. Use the summarize_lecture_topic function to provide a structured summary of the requested topic."
    )
    
    if run.status == "completed":
        print("🔍 Run completed. Checking for function call in run steps...")
        steps = client.beta.threads.runs.steps.list(thread_id=thread.id, run_id=run.id)
        function_call_found = False
        for step in steps.data:
            if step.type == "tool_calls" and step.step_details and step.step_details.tool_calls:
                for tool_call in step.step_details.tool_calls:
                    # Check for the correct function name
                    if tool_call.type == "function" and tool_call.function.name == "summarize_lecture_topic":
                        function_call_found = True
                        print(f"✅ Function '{tool_call.function.name}' was called by the assistant.")
                        function_args_str = tool_call.function.arguments
                        print(f"📋 Raw Function Call Arguments (JSON string):\n{function_args_str}")
                        
                        try:
                            function_args_dict = json.loads(function_args_str)
                            print("\n✅ Parsed function arguments successfully.")
                            
                            # Validate with LectureSummary Pydantic model
                            try:
                                lecture_summary_obj = LectureSummary(**function_args_dict)
                                print("✅ Pydantic validation successful (LectureSummary for function args)!")
                                # Corrected print statements
                                print(f"📊 Topic: {lecture_summary_obj.topic}")
                                print(f"📊 Explanation (snippet): {lecture_summary_obj.explanation[:100]}...")
                                print(f"📊 Examples: {len(lecture_summary_obj.examples)} items")
                                print(f"📊 Key Points: {len(lecture_summary_obj.key_points)} items")
                                if lecture_summary_obj.difficulty:
                                    print(f"📊 Difficulty: {lecture_summary_obj.difficulty}")
                                return lecture_summary_obj
                            except Exception as e_pydantic:
                                print(f"❌ Pydantic validation failed for LectureSummary (function args): {e_pydantic}")
                                return function_args_dict # Return raw dict if Pydantic fails
                        except json.JSONDecodeError as e_json:
                            print(f"❌ Failed to parse function arguments JSON: {e_json}")
                            print(f"   Raw arguments string: {function_args_str}")
                            return None # Cannot proceed if args are not JSON
        
        if not function_call_found:
            print("⚠️  No call to 'summarize_lecture_topic' function found in run steps.")
            messages = client.beta.threads.messages.list(thread_id=thread.id)
            if messages.data and messages.data[0].content and messages.data[0].content[0].type == "text":
                 print(f"   Assistant's last message: {messages.data[0].content[0].text.value[:200]}...")
            return None
    else:
        print(f"❌ Run failed (Function Tools). Status: {run.status}")
        if run.last_error:
            print(f"   Error: {run.last_error.message}")
        return None

def compare_approaches(json_result, function_result):
    """Compare the results from both approaches for LectureSummary."""
    print("\n📊 Comparison of Approaches for LectureSummary Output")
    print("=" * 60) 
    
    print("🔧 JSON Mode (aiming for LectureSummary):")
    if json_result:
        # Corrected instance check and field access
        if isinstance(json_result, LectureSummary):
            print("  ✅ Pydantic validation: SUCCESS (LectureSummary)")
            print(f"  📖 Topic: {json_result.topic}")
            print(f"  🔑 Key Points: {len(json_result.key_points)} items")
        else: # Likely a raw dict because Pydantic validation failed
            print("  ⚠️  Pydantic validation: FAILED for LectureSummary")
            print(f"  📄 Raw data type: {type(json_result)}, Keys: {list(json_result.keys()) if isinstance(json_result, dict) else 'N/A'}")
    else:
        print("  ❌ No valid result from JSON Mode.")
    
    print("\n🎯 Function Tools (Strict, aiming for LectureSummary):")
    if function_result:
        # Corrected instance check and field access
        if isinstance(function_result, LectureSummary):
            print("  ✅ Pydantic validation: SUCCESS (LectureSummary from function args)")
            print(f"  📖 Topic: {function_result.topic}")
            if function_result.difficulty:
                print(f"  📈 Difficulty: {function_result.difficulty}")
            else:
                print(f"  📈 Difficulty: Not provided")
        else: # Likely a raw dict because Pydantic validation failed
            print("  ⚠️  Pydantic validation: FAILED for LectureSummary (function args)")
            print(f"  📄 Raw data type: {type(function_result)}, Keys: {list(function_result.keys()) if isinstance(function_result, dict) else 'N/A'}")
    else:
        print("  ❌ No valid result from Function Tools.")
    
    print("\n💡 Key Takeaways for Structured Lecture Summaries:")
    print("  • JSON Mode: Can work if the prompt is very specific about fields, but less reliable for schema adherence.")
    print("  • Function Tools (Strict): More robust for ensuring the output (function arguments) matches a predefined Pydantic schema like LectureSummary.")
    print("  • Using Pydantic's `model_json_schema()` for function parameters is a good practice.")

def reset_assistant_tools(client: OpenAI, assistant_id: str):
    """Reset assistant tools to its original state (likely just file_search)."""
    print("\n🔄 Resetting assistant tools to default ('file_search')...")
    try:
        client.beta.assistants.update(
            assistant_id=assistant_id,
            tools=[{"type": "file_search"}] # Assuming this is the default for Study Q&A Assistant
        )
        print("✅ Assistant tools reset successfully.")
    except Exception as e:
        print(f"⚠️ Error resetting assistant tools: {e}")

def main():
    """Main function to run the structured output lab for LectureSummary."""
    print("🚀 OpenAI Practice Lab - Structured Output (LectureSummary Focus)")
    print("=" * 60) # Adjusted separator length
    
    client = get_client()
    assistant_id = load_assistant_id()
    print(f"✅ Using assistant: {assistant_id}")
    
    json_mode_output = None
    function_tool_output = None

    try:
        # 1. Demonstrate JSON mode for LectureSummary
        json_mode_output = demonstrate_json_mode(client, assistant_id)
        
        # 2. Demonstrate function tools with strict schema for LectureSummary
        function_tool_output = demonstrate_function_tools_strict(client, assistant_id)
        
        # 3. Compare approaches
        compare_approaches(json_mode_output, function_tool_output)
        
        print(f"\n🎯 Lab Complete!")
        print(f"   Next suggestion: python scripts/03_rag_file_search.py (if you adapt it for lecture files)")
        print(f"   To clean up resources: python scripts/99_cleanup.py")
        
    except Exception as e:
        print(f"❌ An unexpected error occurred in main: {e}")
        import traceback
        traceback.print_exc() 
    finally:

        reset_assistant_tools(client, assistant_id)

if __name__ == "__main__":
    main()