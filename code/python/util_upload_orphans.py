import sys
import os
import time
from pathlib import Path

# Connect to the global Projects/.lib directory modules
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..', '..', '.lib')))

from research.literature import LiteratureAssistant, normalize_text

def main():
    assistant = LiteratureAssistant()
    folder = Path("/Users/pedro/Documents/Projects/papers/cyclicality/references")
    
    pdfs = list(folder.glob("*.pdf"))
    linked, unmatched = assistant._link_pdfs_to_db(pdfs)
    
    print(f"Checking {len(unmatched)} unlinked PDFs against Zotero API to isolate the missing 47...")
    missing_from_zotero = []
    
    for pdf in unmatched:
        query_str = pdf.stem.replace('_', ' ').replace('-', ' ').replace(' 01', '').replace(' 02', '').strip()
        results = assistant.search_zotero(query_str, limit=3, quiet=True)
        pdf_norm = normalize_text(query_str)
        
        match = False
        for r in results:
            r_title = normalize_text(r.get("data", {}).get("title", ""))
            if not r_title or not pdf_norm:
                continue
            if len(pdf_norm) >= 20 and (pdf_norm in r_title or r_title in pdf_norm):
                match = True
                break
            common = sum(1 for a, b in zip(pdf_norm, r_title) if a == b)
            if common >= 30:
                match = True
                break
                
        if not match:
            missing_from_zotero.append((pdf, query_str))

    print(f"\nFound {len(missing_from_zotero)} absolute orphans. Commencing bulk upload...\n")
    
    successful_uploads = 0
    
    for pdf, title in missing_from_zotero:
        # Never upload the bruteforce clones we made if they pop up
        if "_01" in pdf.name or "_02" in pdf.name:
            print(f"Skipping duplicate clone: {pdf.name}")
            continue
            
        print(f"Creating item for: {title[:60]}...")
        try:
            # Generate a blank preprint template native to Zotero API
            template = assistant.zot.item_template('preprint')
            template['title'] = title
            
            # Post the metadata item
            resp = assistant.zot.create_items([template])
            if not resp or 'successful' not in resp:
                print(f"  -> Error creating item: {resp}")
                continue
                
            new_key = resp['successful']['0']['key']
            
            # Push the physical PDF bytes as a child attachment to the new item
            print(f"  -> Uploading raw PDF attachment...")
            assistant.zot.attachment_simple([str(pdf)], new_key)
            successful_uploads += 1
            print(f"  -> Complete.")
            
        except Exception as e:
            print(f"  -> Failed: {e}")
            
    print(f"\nUpload complete! Successfully blasted {successful_uploads} papers into the Zotero cloud.")
    print("Run `python3 ../../.lib/research/literature.py gaps --folder references` to officially map them into your database.")

if __name__ == "__main__":
    main()
