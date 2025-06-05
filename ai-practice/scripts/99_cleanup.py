#!/usr/bin/env python3
"""
99 — Cleanup Script for Study Q&A Lab

Deletes lab-related threads, OpenAI files (for assistants), vector stores,
and optionally the main lab assistant. Also cleans up known local temporary files.
Helps maintain a clean OpenAI account and manage costs.

Usage: python scripts/99_cleanup.py [--max-age <hours>] [--delete-assistant]
"""

import os
import sys
import time
from pathlib import Path
from dotenv import load_dotenv
from openai import OpenAI

# Load environment variables
load_dotenv()

# --- Configuration: Define paths relative to the project root ---
PROJECT_ROOT = Path(__file__).resolve().parent.parent
ASSISTANT_ID_FILE = PROJECT_ROOT / ".assistant"  # ENSURE THIS MATCHES YOUR 00_bootstrap.py
LAST_THREAD_FILE = PROJECT_ROOT / ".last_thread"
EXAM_NOTES_FILE = PROJECT_ROOT / "exam_notes.json" # From the lab's 02_generate_notes.py
DATA_DIR = PROJECT_ROOT / "data"
# Files that might have been created by original versions of lab scripts (if any)
SAMPLE_MD_LLM = DATA_DIR / "intro_to_llms.md"
SAMPLE_MD_API = DATA_DIR / "api_best_practices.md"
# -------------------------------------------------------------

def get_client():
    """Initialize OpenAI client."""
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("❌ Error: OPENAI_API_KEY not found.")
        sys.exit(1)
    org_id = os.getenv("OPENAI_ORG")
    return OpenAI(api_key=api_key, organization=org_id if org_id else None)

def cleanup_threads(client: OpenAI, max_age_hours=24):
    """Clean up old threads."""
    print("🧹 Cleaning up threads...")
    deleted_count = 0
    try:
        threads = client.beta.threads.list(limit=100)
        current_time = int(time.time())
        for thread_item in threads.data:
            age_hours = (current_time - thread_item.created_at) / 3600
            if age_hours > max_age_hours:
                try:
                    client.beta.threads.delete(thread_item.id)
                    print(f"  🗑️ Deleted thread: {thread_item.id} (age: {age_hours:.1f}h)")
                    deleted_count += 1
                except Exception as e:
                    print(f"  ⚠️ Could not delete thread {thread_item.id}: {e}")
        print(f"✅ Deleted {deleted_count} threads older than {max_age_hours} hours.")
    except Exception as e:
        print(f"❌ Error listing/cleaning threads: {e}")

def cleanup_openai_files(client: OpenAI, max_age_hours=24):
    """Clean up 'assistants' purpose files uploaded to OpenAI."""
    print("\n🧹 Cleaning up OpenAI 'assistants' purpose files...")
    deleted_count = 0
    try:
        openai_files = client.files.list(purpose="assistants")
        current_time = int(time.time())
        for file_obj in openai_files.data:
            age_hours = (current_time - file_obj.created_at) / 3600
            if age_hours > max_age_hours:
                try:
                    client.files.delete(file_obj.id)
                    print(f"  🗑️ Deleted OpenAI file: {file_obj.id} ({file_obj.filename}) (age: {age_hours:.1f}h)")
                    deleted_count += 1
                except Exception as e:
                    print(f"  ⚠️ Could not delete OpenAI file {file_obj.id}: {e}")
        print(f"✅ Deleted {deleted_count} 'assistants' purpose files from OpenAI older than {max_age_hours} hours.")
    except Exception as e:
        print(f"❌ Error listing/cleaning OpenAI files: {e}")

def cleanup_vector_stores(client: OpenAI, max_age_hours=24):
    """Clean up old vector stores."""
    print("\n🧹 Cleaning up Vector Stores...")
    deleted_count = 0
    try:
        vector_stores = client.beta.vector_stores.list(limit=100)
        current_time = int(time.time())
        for vs in vector_stores.data:
            if hasattr(vs, 'created_at') and vs.created_at is not None:
                age_hours = (current_time - vs.created_at) / 3600
                if age_hours > max_age_hours:
                    try:
                        client.beta.vector_stores.delete(vs.id)
                        print(f"  🗑️ Deleted Vector Store: {vs.id} (Name: {vs.name or 'N/A'}, Age: {age_hours:.1f}h)")
                        deleted_count += 1
                    except Exception as e:
                        print(f"  ⚠️ Could not delete Vector Store {vs.id}: {e}")
            # Optional: Add name-based deletion logic for VS without created_at if needed
        print(f"✅ Deleted {deleted_count} Vector Stores older than {max_age_hours} hours.")
    except Exception as e:
        print(f"❌ Error listing/cleaning Vector Stores: {e}")

def cleanup_lab_assistant(client: OpenAI, keep_assistant_flag=True):
    """Optionally cleans up the main lab assistant."""
    if not ASSISTANT_ID_FILE.exists():
        print(f"\n📋 No assistant ID file ({ASSISTANT_ID_FILE}) found - skipping assistant cleanup.")
        return
    assistant_id = ASSISTANT_ID_FILE.read_text().strip()
    if not assistant_id:
        print("\n📋 Assistant ID file is empty - skipping assistant cleanup.")
        return

    if keep_assistant_flag:
        print(f"\n📋 Keeping assistant: {assistant_id} (Use --delete-assistant flag to remove).")
        return
    
    print(f"\n🧹 Deleting Lab Assistant: {assistant_id}...")
    try:
        client.beta.assistants.delete(assistant_id) # Assistant deletion is still client.beta.assistants
        print(f"  🗑️ Deleted assistant {assistant_id} from OpenAI.")
        ASSISTANT_ID_FILE.unlink()
        print(f"  🗑️ Deleted local assistant ID file: {ASSISTANT_ID_FILE}")
    except Exception as e:
        print(f"⚠️  Could not delete assistant {assistant_id}: {e}")

def cleanup_local_lab_files():
    """Cleans up known local temporary files generated by lab scripts."""
    print("\n🧹 Cleaning up local lab-generated files...")
    
    files_to_delete_locally = [
        LAST_THREAD_FILE,
        EXAM_NOTES_FILE, # Added this
        SAMPLE_MD_LLM,   # Kept, in case old versions created them
        SAMPLE_MD_API    # Kept, in case old versions created them
    ]
    
    deleted_local_count = 0
    for file_path_obj in files_to_delete_locally:
        if file_path_obj.exists():
            try:
                file_path_obj.unlink()
                print(f"  🗑️ Deleted local file: {file_path_obj}")
                deleted_local_count += 1
            except Exception as e:
                print(f"  ⚠️ Could not delete local file {file_path_obj}: {e}")
        else:
            print(f"  ℹ️ Local file not found, skipping: {file_path_obj}")
    
    # This will only try to remove DATA_DIR if it's completely empty.
    # It will NOT delete your PDFs if they are still in DATA_DIR.
    if DATA_DIR.exists() and not any(DATA_DIR.iterdir()):
        try:
            DATA_DIR.rmdir()
            print(f"  🗑️ Removed empty data directory: {DATA_DIR}")
        except Exception as e:
            print(f"  ⚠️ Could not remove data directory {DATA_DIR} (it might not be empty): {e}")
    else:
        if DATA_DIR.exists():
             print(f"  ℹ️ Directory {DATA_DIR} not empty, not removing directory (likely contains your PDFs).")

    print(f"✅ Cleaned up {deleted_local_count} specified local files.")

def show_current_usage(client: OpenAI):
    """Displays a snapshot of current OpenAI resource usage."""
    print("\n📊 Current OpenAI Resource Usage Snapshot")
    print("=" * 40)
    try:
        threads_count = len(client.beta.threads.list(limit=100).data)
        print(f"🧵 Threads (up to 100): {threads_count}")
        
        all_files = client.files.list().data
        assistant_files_count = len([f for f in all_files if f.purpose == "assistants"])
        print(f"📄 Assistant files on OpenAI: {assistant_files_count} (out of {len(all_files)} total)")
        
        vs_count = len(client.beta.vector_stores.list(limit=100).data)
        print(f"🗂️  Vector Stores (up to 100): {vs_count}")
        
        if ASSISTANT_ID_FILE.exists():
            print(f"🤖 Lab Assistant ID (local file): {ASSISTANT_ID_FILE.read_text().strip()}")
        else:
            print(f"🤖 Lab Assistant ID (local file): {ASSISTANT_ID_FILE} not found.")
    except Exception as e:
        print(f"❌ Error fetching usage: {e}")

def main():
    """Main cleanup orchestration function."""
    print("🚀 OpenAI Study Q&A Lab - Cleanup Utility")
    print("=" * 50)
    
    should_delete_assistant = "--delete-assistant" in sys.argv
    age_threshold_hours = 24
    if "--max-age" in sys.argv:
        try:
            idx = sys.argv.index("--max-age") + 1
            if idx < len(sys.argv): age_threshold_hours = int(sys.argv[idx])
            else: raise ValueError("Missing value for --max-age")
        except (ValueError, IndexError):
            print(f"⚠️ Invalid --max-age. Using default: {age_threshold_hours} hours.")
    
    client = get_client()
    show_current_usage(client)
    
    print(f"\n🤔 This will attempt to delete OpenAI resources older than {age_threshold_hours} hours.")
    if should_delete_assistant:
        print("   ⚠️ WARNING: The --delete-assistant flag is active! The lab assistant will be deleted.")
    
    confirm = input("Proceed with cleanup? (y/N): ").lower().strip()
    if confirm != 'y':
        print("❌ Cleanup cancelled by user."); return
    
    print("\n🚀 Starting cleanup operations...")
    cleanup_threads(client, age_threshold_hours)
    cleanup_openai_files(client, age_threshold_hours)
    cleanup_vector_stores(client, age_threshold_hours) # Will use corrected calls
    cleanup_lab_assistant(client, keep_assistant_flag=not should_delete_assistant)
    cleanup_local_lab_files()
    
    print("\n🎯 Cleanup process finished.")
    print("\n📊 Post-Cleanup Resource Usage Snapshot:")
    show_current_usage(client) # Will use corrected calls
    print("\n💡 Tip: Run regularly. Use `--max-age <hours>` and `--delete-assistant` for control.")

if __name__ == "__main__":
    main()