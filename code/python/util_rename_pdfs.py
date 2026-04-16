import os
import re
import json
import subprocess
import urllib.request
import shutil
from pathlib import Path

OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL = "qwen2.5-coder:7b"

def extract_title(text):
    prompt = (
        "Extract the exact academic title from this document text.\n"
        "Return ONLY valid JSON, no markdown.\n"
        '{"title": "..."}\n\n'
        f"Text:\n{text[:2500]}"
    )
    payload = json.dumps({"model": MODEL, "prompt": prompt, "stream": False}).encode()
    try:
        req = urllib.request.Request(OLLAMA_URL, data=payload, headers={"Content-Type": "application/json"})
        resp = urllib.request.urlopen(req, timeout=30)
        raw = json.loads(resp.read())["response"]
        raw = re.sub(r"^```json\s*", "", raw.strip())
        raw = re.sub(r"\s*```\s*$", "", raw)
        return json.loads(raw).get("title", "")
    except Exception as e:
        return ""

def clean_filename(title):
    # Strip illegal characters, replace spaces with underscores, and limit length
    clean = re.sub(r'[^\w\s-]', '', title).strip()
    return re.sub(r'\s+', '_', clean)[:100] + ".pdf"

def main():
    folder = Path("/Users/pedro/Documents/Projects/papers/cyclicality/references")
    
    pdfs = list(folder.glob("*.pdf"))
    print(f"Examining {len(pdfs)} PDFs in {folder}...\n")
    
    for count, pdf in enumerate(pdfs, 1):
        # Skip files that already look decently named (no raw numerical strings like 1-s2.0)
        if not re.search(r'^\d-s2\.0', pdf.name) and not "wp" in pdf.name and not re.search(r'^\d+\.pdf$', pdf.name):
            if "IMPORTANT" not in pdf.name:
                continue # if it already has a clean looking name, maybe leave it alone.
                
        print(f"[{count}/{len(pdfs)}] Reading: {pdf.name}")
        
        try:
            # Extract first page text
            result = subprocess.run(
                ["pdftotext", "-f", "1", "-l", "1", str(pdf), "-"], 
                capture_output=True, text=True, timeout=10
            )
            text = result.stdout.strip()
            
            if not text:
                print(f"  -> Skipping (no extractable text)")
                continue
                
            title = extract_title(text)
            
            if title and len(title) > 5:
                base_new_name = clean_filename(title)
                new_path = folder / base_new_name
                
                counter = 1
                while new_path.exists() and new_path != pdf:
                    # Append _01, _02, etc. if the file exists to FORCE the rename
                    new_name_with_suffix = f"{base_new_name[:-4]}_{counter:02d}.pdf"
                    new_path = folder / new_name_with_suffix
                    counter += 1
                
                if new_path != pdf:
                    shutil.copy2(str(pdf), str(new_path))
                    print(f"  -> FORCED COPIED: {new_path.name}")
                else:
                    print(f"  -> Already named correctly.")
            else:
                print(f"  -> Failed to extract title.")
                
        except Exception as e:
            print(f"  -> Error: {str(e)}")

if __name__ == "__main__":
    main()
