#!/usr/bin/env python3
"""
03 — RAG via file_search Lab (Adapted for KMP Algorithm Document)

Demonstrates end-to-end RAG using the Study Q&A Assistant's
built-in file_search tool with an uploaded PDF about Algorithms and KMP.
OpenAI hosts the vector store.

Usage: python scripts/03_rag_file_search.py
"""

import os
import sys
import json 
import time 
from typing import List, Optional
from pathlib import Path
from dotenv import load_dotenv
from openai import OpenAI

# Load environment variables
load_dotenv()

PROJECT_ROOT = Path(__file__).resolve().parent.parent 
DATA_DIR = PROJECT_ROOT / "data" # Your data directory with the KMP PDF

def get_client():
    """Initialize OpenAI client."""
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("❌ Error: OPENAI_API_KEY not found.")
        sys.exit(1)
    org_id = os.getenv("OPENAI_ORG")
    return OpenAI(api_key=api_key, organization=org_id if org_id else None)

def load_assistant_id():
    """Load assistant ID for the 'Study Q&A Assistant'."""
    assistant_file = PROJECT_ROOT / ".assistant" 
    if not assistant_file.exists():
        print(f"❌ No assistant file found at {assistant_file}. Run 00_bootstrap.py first.")
        sys.exit(1)
    return assistant_file.read_text().strip()

def get_document_paths_from_data_dir():
    """
    Finds PDF documents in your DATA_DIR for the RAG demonstration.
    """
    print(f"🔍 Looking for PDF files in: {DATA_DIR}")
    if not DATA_DIR.is_dir():
        print(f"❌ Error: Data directory '{DATA_DIR}' not found.")
        sys.exit(1)

    pdf_files = list(DATA_DIR.glob("*.pdf")) 

    if not pdf_files:
        print(f"❌ No PDF files found in {DATA_DIR}. Please add your KMP algorithm PDF (or other lectures).")
        sys.exit(1)
    
    print(f"📄 Found {len(pdf_files)} PDF document(s) to use:")
    for pdf_path in pdf_files:
        print(f"  - {pdf_path.name}")
    return pdf_files

def upload_documents(client: OpenAI, file_paths: List[Path]):
    """Uploads your local documents to OpenAI for RAG."""
    print("\n📤 Uploading your documents to OpenAI...")
    uploaded_openai_files = []
    for local_file_path in file_paths:
        print(f"  Uploading: {local_file_path.name}")
        try:
            with open(local_file_path, "rb") as file_data:
                uploaded_file = client.files.create(
                    file=file_data,
                    purpose="assistants" 
                )
            uploaded_openai_files.append(uploaded_file)
            print(f"  ✅ Uploaded '{local_file_path.name}' -> OpenAI File ID: {uploaded_file.id}")
        except Exception as e:
            print(f"  ❌ Error uploading {local_file_path.name}: {e}")
    
    if not uploaded_openai_files:
        print("❌ No files were successfully uploaded. Cannot proceed.")
        sys.exit(1)
    return uploaded_openai_files

def create_vector_store_with_files(client: OpenAI, uploaded_openai_files: List, vector_store_name_prefix: str = "KMP_Algorithm_VS"):
    """Creates a new vector store and adds the uploaded files to it."""
    # Add a timestamp to the vector store name for uniqueness
    timestamp = int(time.time())
    full_vector_store_name = f"{vector_store_name_prefix}_{timestamp}"
    print(f"\n🗂️  Creating new Vector Store: '{full_vector_store_name}'...")
    
    try:
        vector_store = client.vector_stores.create( # Corrected: removed .beta
            name=full_vector_store_name,
            file_ids=[file.id for file in uploaded_openai_files], 
            expires_after={ 
                "anchor": "last_active_at",
                "days": 1 
            }
        )
        print(f"✅ Vector Store '{vector_store.name}' created with ID: {vector_store.id}")
        print(f"⏳ Waiting for files to be processed in the vector store...")

        while True:
            retrieved_vector_store = client.vector_stores.retrieve(vector_store_id=vector_store.id) # Corrected: removed .beta
            if retrieved_vector_store.file_counts.in_progress == 0:
                print(f"✅ All {retrieved_vector_store.file_counts.completed} files processed in Vector Store.")
                if retrieved_vector_store.file_counts.failed > 0:
                    print(f"⚠️  {retrieved_vector_store.file_counts.failed} files failed to process.")
                break
            print(f"  ... {retrieved_vector_store.file_counts.in_progress} files processing. Status: {retrieved_vector_store.status}")
            time.sleep(5)
        return vector_store # Return the original vector_store object which now has updated status
    except Exception as e:
        print(f"❌ Error creating or processing vector store: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

def attach_vector_store_to_assistant(client: OpenAI, assistant_id: str, vector_store_id: str):
    """Attaches the created vector store to your Study Q&A Assistant."""
    print(f"\n🔗 Attaching Vector Store '{vector_store_id}' to Assistant '{assistant_id}'...")
    try:
        assistant = client.beta.assistants.update( # Assistants API methods are still under client.beta
            assistant_id=assistant_id,
            tool_resources={
                "file_search": {
                    "vector_store_ids": [vector_store_id] 
                }
            }
        )
        print("✅ Vector Store successfully attached to the assistant.")
        return assistant
    except Exception as e:
        print(f"❌ Error attaching vector store to assistant: {e}")
        sys.exit(1)

def demonstrate_rag_queries(client: OpenAI, assistant_id: str):
    """
    Asks questions relevant to the KMP Algorithm PDF content.
    """
    print("\n🔍 Demonstrating RAG Queries (using KMP Algorithm PDF)")
    print("=" * 60)
    
    queries = [
        "According to the document, what is an algorithm?",
        "What are the three characteristics of a good algorithm mentioned in the text?",
        "Explain the Knuth-Morris-Pratt (KMP) Algorithm in your own words, based on the document.",
        "What problem does the KMP algorithm solve, as stated in the material?",
        "How does the KMP algorithm work? Describe the two main phases mentioned.",
        "What is the time complexity for the preprocessing (LPS table) phase of KMP?",
        "What is the time complexity for the search phase of KMP?",
        "What is the overall time complexity of the KMP algorithm according to the document?"
    ]
    
    query_results = []
    
    for i, user_query in enumerate(queries, 1):
        print(f"\n📝 Query {i}: {user_query}")
        print("-" * 50)
        
        thread = client.beta.threads.create(
            messages=[{
                "role": "user",
                "content": f"{user_query}\n\nPlease answer based *only* on the information found in the uploaded KMP algorithm document. Cite specific information if possible."
            }]
        )
        
        print(f"🧵 Thread created: {thread.id}. Running assistant...")
        try:
            run = client.beta.threads.runs.create_and_poll(
                thread_id=thread.id,
                assistant_id=assistant_id,
                instructions="You are the Study Q&A Assistant. Answer questions strictly based on the KMP algorithm document provided. Use your file_search tool and provide citations."
            )
            
            if run.status == "completed":
                messages = client.beta.threads.messages.list(thread_id=thread.id, order="asc", limit=20)
                assistant_response_message = next((msg for msg in reversed(messages.data) if msg.role == "assistant"), None)
                
                if assistant_response_message and assistant_response_message.content:
                    # === START OF CORRECTED CITATION HANDLING ===
                    full_response_text = ""
                    citation_details_list = [] # To store details of each citation

                    for content_block_idx, content_block in enumerate(assistant_response_message.content):
                        if content_block.type == "text":
                            # Append the raw text from this block to the full response
                            full_response_text += content_block.text.value
                            
                            annotations = content_block.text.annotations
                            if annotations:
                                for ann_idx, annotation in enumerate(annotations):
                                    # The text in the assistant's response that is being cited
                                    text_segment_cited_by_assistant = annotation.text
                                    file_id_of_source = None
                                    
                                    if hasattr(annotation, 'file_citation') and annotation.file_citation:
                                        file_id_of_source = annotation.file_citation.file_id
                                    elif hasattr(annotation, 'file_path') and annotation.file_path: # Older style
                                        file_id_of_source = annotation.file_path.file_id
                                    
                                    if file_id_of_source:
                                        citation_details_list.append(
                                            f"  - Assistant's text \"{text_segment_cited_by_assistant[:70]}...\" is linked to Source File ID: {file_id_of_source}"
                                        )
                    
                    print("🤖 Assistant Response:")
                    print(full_response_text if full_response_text else "[No text content in assistant's message]") # Print the full combined response
                    
                    if citation_details_list:
                        print("\n📚 Citation Details (Linking assistant's text to source files):")
                        for detail in citation_details_list:
                            print(detail)
                    else:
                        print("ℹ️ No direct file citations found in this response's annotations.")
                    # === END OF CORRECTED CITATION HANDLING ===

                    run_steps = client.beta.threads.runs.steps.list(thread_id=thread.id, run_id=run.id)
                    file_search_tool_used = any(
                        tc.type == "file_search" for step in run_steps.data if step.type == "tool_calls" and step.step_details for tc in step.step_details.tool_calls
                    )
                    print("🔍 file_search tool was used by the assistant." if file_search_tool_used else "⚠️ file_search tool was NOT explicitly used by the assistant for this query.")
                    
                    query_results.append({
                        "query": user_query,
                        "response_length": len(full_response_text),
                        "file_search_used": file_search_tool_used,
                        "citations_count": len(citation_details_list), # Use count of detailed citations
                        "thread_id": thread.id
                    })
                else: 
                    print("❌ Assistant provided no content in its message.")
                    query_results.append({"query": user_query, "status": "NoContent", "thread_id": thread.id})
            else:
                print(f"❌ Query run not completed. Status: {run.status}")
                if run.last_error: print(f"  Error: {run.last_error.message}")
                query_results.append({"query": user_query, "status": run.status, "thread_id": thread.id})
        except Exception as e:
            print(f"❌ Error during RAG query for '{user_query}': {e}")
            import traceback
            traceback.print_exc() # Print full traceback for detailed error
            query_results.append({"query": user_query, "status": "Exception", "error": str(e), "thread_id": getattr(thread, 'id', 'N/A')})
    return query_results

def analyze_rag_performance(results: List[dict]):
    """Analyzes RAG query performance for KMP algorithm document."""
    print("\n📊 RAG Performance Analysis (KMP Algorithm Document)")
    print("=" * 60)
    if not results: print("No results to analyze."); return

    successful_queries = [r for r in results if r.get("status", "completed") == "completed" and "response_length" in r]
    print(f"✅ Successful queries: {len(successful_queries)}/{len(results)}")
    
    if successful_queries:
        avg_resp_len = sum(r["response_length"] for r in successful_queries) / len(successful_queries)
        fs_usage_count = sum(1 for r in successful_queries if r["file_search_used"])
        queries_with_citations = sum(1 for r in successful_queries if r["citations_count"] > 0)
        
        print(f"📏 Avg response length: {avg_resp_len:.0f} chars")
        print(f"🔍 file_search used: {fs_usage_count}/{len(successful_queries)} queries")
        print(f"📚 Queries with citations: {queries_with_citations}/{len(successful_queries)}")
        
        print("\n💡 KMP RAG Insights:")
        print("  • Assistant should answer based on your KMP algorithm PDF.")
        print("  • Verify citations point to the KMP document.")
        print("  • If file_search isn't used, query might be too general or unrelated to the PDF.")

def cleanup_resources(client: OpenAI, vector_store_id: Optional[str], uploaded_openai_file_ids: List[str]):
    """Cleans up Vector Store and uploaded OpenAI File objects."""
    print("\n🧹 Cleaning up OpenAI resources...")
    if vector_store_id:
        try:
            print(f"  🗑️ Deleting Vector Store: {vector_store_id}...")
            client.vector_stores.delete(vector_store_id) # Corrected: removed .beta
            print(f"  ✅ Vector Store {vector_store_id} deleted.")
        except Exception as e: print(f"  ⚠️ Could not delete Vector Store {vector_store_id}: {e}")
    else: print("  ℹ️ No Vector Store ID for cleanup.")

    if uploaded_openai_file_ids:
        print(f"  🗑️ Deleting {len(uploaded_openai_file_ids)} uploaded OpenAI File(s)...")
        for file_id in uploaded_openai_file_ids:
            try:
                client.files.delete(file_id)
                print(f"    Deleted OpenAI File: {file_id}")
            except Exception as e: print(f"    ⚠️ Could not delete OpenAI File {file_id}: {e}")
    else: print("  ℹ️ No OpenAI File IDs for cleanup.")

def main():
    """Main RAG lab function for KMP Algorithm document."""
    print("🚀 OpenAI Practice Lab - RAG with KMP Algorithm PDF")
    print("=" * 60)
    
    client = get_client()
    assistant_id = load_assistant_id()
    print(f"✅ Using Study Q&A Assistant: {assistant_id}")
    
    created_vector_store_id = None
    openai_file_ids_this_session = []
    
    try:
        local_document_paths = get_document_paths_from_data_dir()
        if not local_document_paths: return
        
        uploaded_openai_files = upload_documents(client, local_document_paths)
        if not uploaded_openai_files: return
        openai_file_ids_this_session = [f.id for f in uploaded_openai_files]

        vector_store_obj = create_vector_store_with_files(client, uploaded_openai_files, vector_store_name_prefix=f"VS_KMP_{assistant_id[:6]}")
        if not vector_store_obj: return
        created_vector_store_id = vector_store_obj.id
        
        attach_vector_store_to_assistant(client, assistant_id, created_vector_store_id)
        rag_results = demonstrate_rag_queries(client, assistant_id)
        analyze_rag_performance(rag_results)
        
        print(f"\n🎯 Lab Complete! Assistant should now use your KMP PDF.")
        print(f"   Vector Store '{created_vector_store_id}' will auto-expire.")
        
    except Exception as e:
        print(f"❌ Unexpected error in main RAG flow: {e}")
        import traceback
        traceback.print_exc()
        
    finally:
        print("\n--- Resource Cleanup ---")
        if created_vector_store_id or openai_file_ids_this_session:
            cleanup_choice = input(f"🤔 Clean up VS '{created_vector_store_id}' & {len(openai_file_ids_this_session)} files? (y/N): ").lower().strip()
            if cleanup_choice == 'y':
                cleanup_resources(client, created_vector_store_id, openai_file_ids_this_session)
        else: print("ℹ️ No new VS or OpenAI files to clean from this session.")
        
        if created_vector_store_id: # Only try to detach if a VS was created and attached
            try:
                print(f"\n🔧 Detaching Vector Store {created_vector_store_id} from assistant {assistant_id}...")
                client.beta.assistants.update(
                    assistant_id=assistant_id,
                    tool_resources={"file_search": {"vector_store_ids": []}} 
                )
                print("✅ Assistant's file_search tool resources reset.")
            except Exception as e:
                print(f"⚠️  Could not reset assistant tool_resources: {e}")

if __name__ == "__main__":
    main()