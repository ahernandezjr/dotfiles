#!/usr/bin/env python3
"""
Wabbajack Modlist Curator CLI Tool Suite
Command-line tool suite to parse, compare, search, and curate Skyrim/game modlists from .wabbajack files or CDN URLs.
Pure CLI script - fast, Unix-pipeable, no GUI/TUI overhead.
"""

import os
import sys
import json
import zipfile
import gzip
import urllib.request
import urllib.parse
import re
import argparse
import io
from pathlib import Path

# --- Persistence Storage ---
CONFIG_DIR = Path.home() / ".config" / "wabbajack-curator"
CONFIG_DIR.mkdir(parents=True, exist_ok=True)
CURATION_DB_FILE = CONFIG_DIR / "curation_db.json"

def load_curation_db():
    if CURATION_DB_FILE.exists():
        try:
            with open(CURATION_DB_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            pass
    return {"mods": {}, "notes": {}}

def save_curation_db(db):
    try:
        with open(CURATION_DB_FILE, "w", encoding="utf-8") as f:
            json.dump(db, f, indent=2)
    except Exception as e:
        print(f"Error saving curation DB: {e}", file=sys.stderr)

CATEGORY_RULES = [
    ("Core & Bug Fixes", [r"skse", r"address library", r"bug fix", r"engine fix", r"po3", r"powerofthree", r"unofficial skyrim", r"ussep", r"displaytweaks", r"sse engine", r"skse64", r"crashlogger", r"scriptextender"]),
    ("Graphics & Textures", [r"texture", r"hd", r"2k", r"4k", r"parallax", r"retexture", r"mesh", r"smim", r"noble", r"skyland", r"pfuscher", r"visual", r"graphics", r"shader", r"enb", r"community shaders"]),
    ("Environment & Weather", [r"weather", r"sky", r"cloud", r"tree", r"grass", r"flora", r"water", r"landscape", r"nature", r"cathedral", r"lux", r"elfx", r"lighting", r"fog"]),
    ("User Interface & HUD", [r"ui", r"hud", r"skyui", r"menu", r"font", r"map", r"compass", r"widget", r"mcm", r"interface", r"cursor", r"inventory"]),
    ("Animations & Physics", [r"animation", r"dar", r"oar", r"hdt", r"smp", r"physics", r"nemesis", r"motion", r"dodge", r"behavior", r"combat animation", r"skeleton", r"cbpc"]),
    ("Armors, Weapons & Clothes", [r"armor", r"armour", r"weapon", r"sword", r"shield", r"outfit", r"clothing", r"helmet", r"apparel", r"immersive armors", r"immersive weapons"]),
    ("Characters & Followers", [r"npc", r"follower", r"companion", r"skin", r"body", r"cbbe", r"bhunp", r"hair", r"face", r"eyes", r"beauty", r"bijin", r"pandorable"]),
    ("Gameplay & Combat", [r"combat", r"gameplay", r"perk", r"magic", r"spell", r"enchant", r"survival", r"economy", r"leveling", r"stealth", r"ai", r"valhalla", r"blade and soul"]),
    ("Quests & Locations", [r"quest", r"dungeon", r"city", r"town", r"expansion", r"lotd", r"legacy of the dragonborn", r"bruma", r"wyrmstooth", r"falskaar", r"location", r"world"]),
    ("Audio & Sound", [r"audio", r"sound", r"music", r"voice", r"sfx", r"ambient", r"acoustic"])
]

def auto_categorize(mod_name, desc=""):
    combined = f"{mod_name} {desc}".lower()
    for cat, patterns in CATEGORY_RULES:
        for p in patterns:
            if re.search(p, combined):
                return cat
    return "Miscellaneous"

def clean_game_name(g):
    clean = (g or "skyrimspecialedition").lower()
    if "skyrimspecialedition" in clean or "sse" in clean or "skyrimse" in clean:
        return "skyrimspecialedition"
    if "skyrim" in clean:
        return "skyrim"
    if "enderalse" in clean or "enderalspecialedition" in clean:
        return "enderalspecialedition"
    if "enderal" in clean:
        return "enderal"
    if "fallout4" in clean or "fo4" in clean:
        return "fallout4"
    if "newvegas" in clean or "falloutnv" in clean or "fnv" in clean:
        return "newvegas"
    if "fallout3" in clean or "fo3" in clean:
        return "fallout3"
    if "starfield" in clean:
        return "starfield"
    return clean

def parse_modlist_data(zip_source, list_name_override=None):
    """Comprehensively parses a .wabbajack zip source (Archives + Directives/MO2 mods)."""
    if isinstance(zip_source, (str, Path)):
        z = zipfile.ZipFile(zip_source, 'r')
    else:
        z = zipfile.ZipFile(zip_source, 'r')

    if "modlist" not in z.namelist():
        raise ValueError("Invalid .wabbajack file: missing 'modlist' manifest entry.")

    raw_json = z.read("modlist").decode("utf-8", errors="ignore")
    data = json.loads(raw_json)

    list_id = list_name_override or data.get("Name") or "Unnamed Modlist"
    archives = data.get("Archives", [])
    directives = data.get("Directives", [])

    all_mods = {}

    # 1. Archives
    for a in archives:
        st = a.get("State", {})
        mod_name = st.get("Name") or a.get("Name") or "Unknown Archive"
        mod_id = st.get("ModID") or st.get("ModId") or None
        file_id = st.get("FileID") or st.get("FileId") or None
        game_name = clean_game_name(st.get("GameName") or data.get("GameType"))
        author = st.get("Author") or "Unknown"
        version = str(st.get("Version") or "1.0")
        desc = st.get("Description") or ""

        nexus_url = None
        if mod_id:
            nexus_url = f"https://www.nexusmods.com/{game_name}/mods/{mod_id}"
        elif st.get("Url"):
            nexus_url = st.get("Url")

        unique_key = f"{mod_id}_{game_name}" if mod_id else f"name_{mod_name.lower().strip()}"
        cat = auto_categorize(mod_name, desc)

        all_mods[unique_key] = {
            "key": unique_key,
            "name": mod_name,
            "mod_id": mod_id,
            "file_id": file_id,
            "game": game_name,
            "author": author,
            "version": version,
            "description": desc,
            "nexus_url": nexus_url,
            "category": cat,
            "source": "Archive"
        }

    # 2. Directives (MO2 installed mods)
    for d in directives:
        to_path = d.get("To", "")
        norm_path = to_path.replace("\\", "/")
        if norm_path.startswith("files/mods/"):
            parts = norm_path.split("/")
            if len(parts) > 2:
                mod_folder_name = parts[2]
                key = f"name_{mod_folder_name.lower().strip()}"
                if key not in all_mods:
                    cat = auto_categorize(mod_folder_name)
                    all_mods[key] = {
                        "key": key,
                        "name": mod_folder_name,
                        "mod_id": None,
                        "file_id": None,
                        "game": clean_game_name(data.get("GameType")),
                        "author": "MO2 Installed Mod",
                        "version": "1.0",
                        "description": f"Installed MO2 Mod Component: {mod_folder_name}",
                        "nexus_url": None,
                        "category": cat,
                        "source": "Directive"
                    }

    return {
        "id": list_id,
        "name": data.get("Name") or list_id,
        "author": data.get("Author") or "Unknown",
        "version": str(data.get("Version") or "1.0"),
        "game": clean_game_name(data.get("GameType")),
        "archives_count": len(archives),
        "directives_count": len(directives),
        "mods": list(all_mods.values())
    }

def load_source(source_path_or_url):
    """Loads a .wabbajack file from local file path or remote CDN URL."""
    clean_src = source_path_or_url.strip()
    headers = {"User-Agent": "Mozilla/5.0"}

    if clean_src.startswith("http://") or clean_src.startswith("https://"):
        if "authored-files.wabbajack.org" in clean_src:
            munged = clean_src.rstrip("/").split("/")[-1]
            def_url = f"https://authored-files.wabbajack.org/authored_files/{munged}/definition.json.gz"

            print(f"Fetching manifest definition from {munged}...", file=sys.stderr)
            req = urllib.request.Request(def_url, headers=headers)
            gz_bytes = urllib.request.urlopen(req).read()
            meta = json.loads(gzip.decompress(gz_bytes).decode("utf-8"))

            parts = meta.get("Parts", [])
            name = meta.get("OriginalFileName", munged)
            full_data = bytearray()
            total_parts = len(parts)

            for i in range(total_parts):
                print(f"Downloading {name} (Chunk {i+1}/{total_parts})...", file=sys.stderr)
                part_url = f"https://authored-files.wabbajack.org/authored_files/{munged}/parts/{i}"
                r = urllib.request.Request(part_url, headers=headers)
                p_bytes = urllib.request.urlopen(r).read()
                full_data.extend(p_bytes)

            return parse_modlist_data(io.BytesIO(full_data), list_name_override=name)
        else:
            print(f"Downloading .wabbajack file from {clean_src}...", file=sys.stderr)
            req = urllib.request.Request(clean_src, headers=headers)
            data_bytes = urllib.request.urlopen(req).read()
            return parse_modlist_data(io.BytesIO(data_bytes), list_name_override=clean_src.split("/")[-1])
    else:
        p = Path(clean_src)
        if not p.exists():
            raise FileNotFoundError(f"File not found: {clean_src}")
        return parse_modlist_data(p)

# --- CLI Subcommands ---

def cmd_parse(args):
    """Parses a modlist and prints all mods in a clean table format."""
    ml = load_source(args.source)
    db = load_curation_db()

    print(f"\n==========================================================================================================")
    print(f"⚡ WABBAJACK MODLIST: {ml['name']} (v{ml['version']})")
    print(f"Author: {ml['author']} | Game: {ml['game']} | Total Extracted Mods: {len(ml['mods'])}")
    print(f"==========================================================================================================\n")

    print(f"{'STATUS':<8} | {'MOD NAME':<40} | {'CATEGORY':<20} | {'AUTHOR':<18} | {'NEXUS LINK'}")
    print("-" * 115)

    count = 0
    for m in ml["mods"]:
        if args.search:
            q = args.search.lower()
            if q not in m["name"].lower() and q not in m["author"].lower() and q not in m["category"].lower():
                continue

        st = db.get("mods", {}).get(m["key"], "[ ]")
        if st == "SELECTED":
            st = "[⭐]"
        elif st == "REJECTED":
            st = "[✕]"
        elif st == "CONSIDERING":
            st = "[?]"
        else:
            st = "[ ]"

        n_url = m["nexus_url"] or "-"
        print(f"{st:<8} | {m['name'][:40]:<40} | {m['category'][:20]:<20} | {m['author'][:18]:<18} | {n_url}")
        count += 1

    print("-" * 115)
    print(f"Total displayed mods: {count}\n")

def cmd_compare(args):
    """Compares 2 or more modlists side-by-side."""
    if len(args.sources) < 2:
        print("Error: Compare requires 2 or more .wabbajack sources.", file=sys.stderr)
        sys.exit(1)

    modlists = []
    for s in args.sources:
        modlists.append(load_source(s))

    mod_map = {}
    for ml in modlists:
        lid = ml["id"]
        for m in ml["mods"]:
            k = m["key"]
            if k not in mod_map:
                mod_map[k] = {
                    "key": k,
                    "name": m["name"],
                    "category": m["category"],
                    "nexus_url": m["nexus_url"],
                    "presence": {}
                }
            mod_map[k]["presence"][lid] = m["version"]

    print(f"\n==========================================================================================================")
    print(f"📊 MODLIST COMPARISON: {len(modlists)} Modlists ({len(mod_map)} Total Unique Mods)")
    for ml in modlists:
        print(f"  • {ml['name']} (Total Mods: {len(ml['mods'])})")
    print(f"==========================================================================================================\n")

    list_ids = [ml["id"] for ml in modlists]
    pres_headers = " | ".join([lid[:12] for lid in list_ids])
    print(f"{'MOD NAME':<42} | {'CATEGORY':<20} | {pres_headers} | {'NEXUS LINK'}")
    print("-" * 115)

    common_count = 0
    unique_counts = {lid: 0 for lid in list_ids}

    for m in mod_map.values():
        p_str = " | ".join(["  ✓  " if lid in m["presence"] else "  -  " for lid in list_ids])
        num_pres = len(m["presence"])
        if num_pres == len(list_ids):
            common_count += 1
        elif num_pres == 1:
            only_lid = list(m["presence"].keys())[0]
            unique_counts[only_lid] += 1

        if args.mode == "common" and num_pres < len(list_ids):
            continue
        if args.mode == "unique" and num_pres > 1:
            continue

        n_url = m["nexus_url"] or "-"
        print(f"{m['name'][:42]:<42} | {m['category'][:20]:<20} | {p_str} | {n_url}")

    print("-" * 115)
    print(f"SUMMARY: Shared Common Mods across all lists: {common_count}")
    for lid, c in unique_counts.items():
        print(f"  • Unique to {lid}: {c} mods")
    print()

def cmd_select(args):
    """Marks a mod as Selected (Starred) in the curation DB."""
    db = load_curation_db()
    key = f"name_{args.mod_name.lower().strip()}"
    db["mods"][key] = "SELECTED"
    save_curation_db(db)
    print(f"⭐ Marked mod '{args.mod_name}' as SELECTED in curation DB.")

def cmd_reject(args):
    """Marks a mod as Rejected in the curation DB."""
    db = load_curation_db()
    key = f"name_{args.mod_name.lower().strip()}"
    db["mods"][key] = "REJECTED"
    save_curation_db(db)
    print(f"✕ Marked mod '{args.mod_name}' as REJECTED in curation DB.")

def cmd_note(args):
    """Adds or updates a personal note for a mod in the curation DB."""
    db = load_curation_db()
    key = f"name_{args.mod_name.lower().strip()}"
    if "notes" not in db:
        db["notes"] = {}
    db["notes"][key] = args.text
    save_curation_db(db)
    print(f"📝 Saved note for '{args.mod_name}': {args.text}")

def cmd_status(args):
    """Displays current curation DB selections, rejections, and notes."""
    db = load_curation_db()
    mods = db.get("mods", {})
    notes = db.get("notes", {})

    selected = [k for k, v in mods.items() if v == "SELECTED"]
    rejected = [k for k, v in mods.items() if v == "REJECTED"]

    print(f"\n==========================================================================================================")
    print(f"📋 CURATION DATABASE STATUS")
    print(f"==========================================================================================================")
    print(f"⭐ Total Selected Mods : {len(selected)}")
    print(f"✕ Total Rejected Mods : {len(rejected)}")
    print(f"📝 Total Notes Saved   : {len(notes)}\n")

    if selected:
        print("⭐ Selected Mods List:")
        for s in selected:
            n = notes.get(s, "")
            n_str = f" (Note: {n})" if n else ""
            clean_n = s.replace("name_", "")
            print(f"  • {clean_n}{n_str}")
        print()

def cmd_export(args):
    """Exports all selected/curated mods with notes to a Markdown file."""
    db = load_curation_db()
    selected_keys = [k for k, v in db.get("mods", {}).items() if v == "SELECTED"]
    notes = db.get("notes", {})

    out_file = Path(args.output or (Path.home() / "curated_skyrim_modlist.md"))

    lines = [
        "# Curated Skyrim Modlist Draft\n",
        f"Generated by Wabbajack Curator CLI | Total Curated Mods: {len(selected_keys)}\n"
    ]

    if not selected_keys:
        lines.append("*(No mods currently selected in curation database)*\n")
    else:
        for k in selected_keys:
            clean_n = k.replace("name_", "").title()
            note = notes.get(k, "")
            note_str = f"\n  - *Note: {note}*" if note else ""
            lines.append(f"- **{clean_n}**{note_str}")
        lines.append("")

    with open(out_file, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"💾 Successfully exported curated modlist to: {out_file}")

def main():
    parser = argparse.ArgumentParser(
        prog="wabbajack-curator",
        description="Wabbajack Modlist Curator CLI Tool Suite - Fast CLI tool to parse, compare, filter, and curate Wabbajack modlists."
    )
    subparsers = parser.add_subparsers(dest="command", help="Available subcommands")

    # 1. parse / list
    p_parse = subparsers.add_parser("parse", help="Parse and print all mods from a .wabbajack file or URL")
    p_parse.add_argument("source", help="Path to local .wabbajack file or URL (authored-files.wabbajack.org)")
    p_parse.add_argument("-s", "--search", help="Optional keyword search filter")
    p_parse.set_defaults(func=cmd_parse)

    # 2. compare
    p_comp = subparsers.add_parser("compare", help="Compare 2 or more .wabbajack modlists side-by-side")
    p_comp.add_argument("sources", nargs="+", help="2 or more .wabbajack files or URLs")
    p_comp.add_argument("-m", "--mode", choices=["all", "common", "unique"], default="all", help="Display mode")
    p_comp.set_defaults(func=cmd_compare)

    # 3. select
    p_sel = subparsers.add_parser("select", help="Mark a mod as Selected (⭐ Starred)")
    p_sel.add_argument("mod_name", help="Name of the mod to select")
    p_sel.set_defaults(func=cmd_select)

    # 4. reject
    p_rej = subparsers.add_parser("reject", help="Mark a mod as Rejected (✕)")
    p_rej.add_argument("mod_name", help="Name of the mod to reject")
    p_rej.set_defaults(func=cmd_reject)

    # 5. note
    p_note = subparsers.add_parser("note", help="Add or update a personal note for a mod")
    p_note.add_argument("mod_name", help="Name of the mod")
    p_note.add_argument("text", help="Note text to attach to the mod")
    p_note.set_defaults(func=cmd_note)

    # 6. status
    p_stat = subparsers.add_parser("status", help="Show current curation DB selections and notes")
    p_stat.set_defaults(func=cmd_status)

    # 7. export
    p_exp = subparsers.add_parser("export", help="Export curated selection to Markdown report")
    p_exp.add_argument("-o", "--output", help="Output markdown file path (defaults to ~/curated_skyrim_modlist.md)")
    p_exp.set_defaults(func=cmd_export)

    args = parser.parse_args()
    if not args.command:
        parser.print_help()
        sys.exit(1)

    args.func(args)

if __name__ == "__main__":
    main()
