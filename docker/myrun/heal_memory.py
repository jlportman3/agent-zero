
import asyncio
import os
import json
from python.helpers.memory import Memory, MyFaiss
from python.helpers import files
from langchain_core.documents import Document
from langchain_community.vectorstores import FAISS
from langchain_community.docstore.in_memory import InMemoryDocstore
from langchain_community.vectorstores.utils import DistanceStrategy
from langchain.embeddings import CacheBackedEmbeddings
from langchain.storage import LocalFileStore
import faiss
from agent import Agent, ModelConfig, ModelProvider, ModelType

async def heal_memory_index(memory_subdir: str = "default"):
    print(f"Attempting to heal memory index in: memory/{memory_subdir}")

    db_dir = files.get_abs_path("memory", memory_subdir)
    em_dir = files.get_abs_path("memory/embeddings")

    if not os.path.exists(db_dir) or not files.exists(db_dir, "index.faiss"):
        print(f"No FAISS index found at {db_dir}. Nothing to heal.")
        return

    # Load embedding model config from embedding.json
    meta_file_path = files.get_abs_path(db_dir, "embedding.json")
    if not files.exists(meta_file_path):
        print(f"No embedding.json found at {meta_file_path}. Cannot load embeddings.")
        return

    with open(meta_file_path, "r") as f:
        embedding_set = json.load(f)

    model_config = ModelConfig(
        provider=ModelProvider[embedding_set["model_provider"].upper()],
        name=embedding_set["model_name"],
        type=ModelType.EMBEDDING,
        kwargs={}
    )

    # Re-initialize embeddings model
    store = LocalFileStore(em_dir)
    embeddings_model = ModelConfig.get_model(
        ModelType.EMBEDDING,
        model_config.provider,
        model_config.name,
        **model_config.kwargs,
    )
    embeddings_model_id = files.safe_file_name(
        model_config.provider.name + "_" + model_config.name
    )
    embedder = CacheBackedEmbeddings.from_bytes_store(
        embeddings_model, store, namespace=embeddings_model_id
    )

    # Load the FAISS index
    db = MyFaiss.load_local(
        folder_path=db_dir,
        embeddings=embedder,
        allow_dangerous_deserialization=True,
        distance_strategy=DistanceStrategy.COSINE,
        relevance_score_fn=Memory._cosine_normalizer,
    )

    print("FAISS index loaded. Checking for corrupted entries...")

    bad_ids = []
    all_doc_ids = list(db.docstore._dict.keys()) # Get all IDs from the docstore

    # Iterate through the FAISS index's internal IDs
    # This is a bit hacky as FAISS doesn't expose a direct way to get all indexed IDs
    # without also getting their vectors. We'll rely on the docstore for the source of truth.
    # The error indicates IDs in the FAISS index that are NOT in the docstore.
    # So, we need to find IDs in the FAISS index that are not in all_doc_ids.
    # This requires iterating through the FAISS index's internal structure, which is not
    # directly exposed by langchain_community.
    # A simpler approach is to re-add all good documents to a new index.

    # Let's get all documents from the docstore and rebuild the index
    good_docs = []
    for doc_id in all_doc_ids:
        try:
            doc = db.docstore._dict[doc_id]
            good_docs.append(doc)
        except KeyError:
            # This should not happen if all_doc_ids comes from docstore._dict.keys()
            # But it's here for robustness.
            print(f"Warning: Document with ID {doc_id} found in docstore keys but not retrievable.")
            bad_ids.append(doc_id)

    if not good_docs:
        print("No good documents found in docstore. Index will be empty after healing.")
        # If no good docs, we effectively clear the index
        if os.path.exists(db_dir):
            for f in ["index.faiss", "index.pkl", "embedding.json"]:
                if files.exists(db_dir, f):
                    os.remove(files.get_abs_path(db_dir, f))
            print(f"Cleared all index files in {db_dir}.")
        return

    print(f"Found {len(good_docs)} good documents. Rebuilding index...")

    # Create a new FAISS index with only the good documents
    index = faiss.IndexFlatIP(len(embedder.embed_query("example")))
    new_db = MyFaiss(
        embedding_function=embedder,
        index=index,
        docstore=InMemoryDocstore(),
        index_to_docstore_id={},
        distance_strategy=DistanceStrategy.COSINE,
        relevance_score_fn=Memory._cosine_normalizer,
    )

    # Add good documents to the new index
    new_ids = [doc.metadata["id"] for doc in good_docs]
    await new_db.aadd_documents(documents=good_docs, ids=new_ids)

    # Save the new, healed index
    Memory._save_db_file(new_db, memory_subdir)

    print(f"Memory index healed successfully. Removed {len(bad_ids)} corrupted entries.")
    print(f"New index contains {len(new_ids)} documents.")

if __name__ == "__main__":
    # This part is for testing the script directly if needed
    # In a real scenario, it would be called via run_shell_command
    # You might need to set up a dummy agent config or pass memory_subdir
    # For now, we'll assume 'default'
    asyncio.run(heal_memory_index("default"))
