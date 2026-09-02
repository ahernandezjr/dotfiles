#!/usr/bin/env python3
"""
Wabbajack Modlist Curator & Analyzer (Terminal TUI)
Parses, compares, categorizes, and curates mods from 1 or more .wabbajack files.
Pure local terminal tool - no WebUI, no hosted server.
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
import webbrowser
import curses
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
        except Exception as e:
            pass
    return {"mods": {}, "notes": {}}

def save_curation_db(db):
    try:
        with open(CURATION_DB_FILE, "w", encoding="utf-8") as f:
            json.dump(db, f, indent=2)
    except Exception as e:
        pass

# Global state
LOADED_MODLISTS = {} # id -> list dict
CURATION_DB = load_curation_db()

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

CATEGORIES_LIST = ["All Categories"] + [c[0] for c in CATEGORY_RULES] + ["Miscellaneous"]

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

def extract_modlist_info(zip_source, list_name_override=None):
    """Comprehensively parses a .wabbajack file (Archives + Directives/MO2 mods)."""
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

    # 1. Parse Archives
    for a in archives:
        st = a.get("State", {})
        st_type = st.get("$type", "")
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

    # 2. Parse Directives for MO2 Installed Mod Folders (Ensures 100% Comprehensive Mod List)
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

def fetch_url_modlist(url, name=None, progress_cb=None):
    """Fetches a .wabbajack file from URL, handling authored-files.wabbajack.org chunked downloads."""
    clean_url = url.strip()
    headers = {"User-Agent": "Mozilla/5.0"}

    # Handle authored-files.wabbajack.org chunked download
    if "authored-files.wabbajack.org" in clean_url:
        # Extract munged name
        # e.g. https://authored-files.wabbajack.org/authored_files/download/Visions%20of%20Vaermina.wabbajack_6253b840...
        munged = clean_url.rstrip("/").split("/")[-1]
        def_url = f"https://authored-files.wabbajack.org/authored_files/{munged}/definition.json.gz"

        if progress_cb:
            progress_cb(f"Fetching definition for {munged}...")

        req = urllib.request.Request(def_url, headers=headers)
        gz_bytes = urllib.request.urlopen(req).read()
        meta = json.loads(gzip.decompress(gz_bytes).decode("utf-8"))

        parts = meta.get("Parts", [])
        if not name:
            name = meta.get("OriginalFileName", munged)

        full_data = bytearray()
        total_parts = len(parts)

        for i in range(total_parts):
            if progress_cb:
                progress_cb(f"Downloading {name} (Part {i+1}/{total_parts})...")
            part_url = f"https://authored-files.wabbajack.org/authored_files/{munged}/parts/{i}"
            r = urllib.request.Request(part_url, headers=headers)
            p_bytes = urllib.request.urlopen(r).read()
            full_data.extend(p_bytes)

        return extract_modlist_info(io.BytesIO(full_data), list_name_override=name)
    else:
        if progress_cb:
            progress_cb("Downloading .wabbajack file...")
        req = urllib.request.Request(clean_url, headers=headers)
        data_bytes = urllib.request.urlopen(req).read()
        return extract_modlist_info(io.BytesIO(data_bytes), list_name_override=name)

# --- Curses TUI Application ---
def run_tui(stdscr):
    curses.curs_set(0) # Hide cursor
    stdscr.timeout(100) # Input timeout

    # Setup Colors
    curses.start_color()
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_CYAN, -1)     # Header / Category
    curses.init_pair(2, curses.COLOR_GREEN, -1)    # Selected / Starred
    curses.init_pair(3, curses.COLOR_RED, -1)      # Rejected
    curses.init_pair(4, curses.COLOR_YELLOW, -1)   # Nexus / Highlight
    curses.init_pair(5, curses.COLOR_MAGENTA, -1)  # Tab / Status
    curses.init_pair(6, curses.COLOR_BLACK, curses.COLOR_CYAN) # Selection bar

    selected_index = 0
    top_scroll = 0
    search_query = ""
    tab_mode = 0  # 0: All, 1: Common, 2: Unique, 3: Curated
    cat_filter_idx = 0
    status_msg = "Press 'l' to Load .wabbajack file, '/' Search, 'Space' Select, 'o' Open Nexus, 'e' Export, 'q' Quit"

    while True:
        stdscr.clear()
        height, width = stdscr.getmaxyx()

        # Build Aligned Combined Mods List
        list_ids = list(LOADED_MODLISTS.keys())
        mod_map = {}
        for lid in list_ids:
            ml = LOADED_MODLISTS[lid]
            for m in ml["mods"]:
                k = m["key"]
                if k not in mod_map:
                    mod_map[k] = {
                        "key": k,
                        "name": m["name"],
                        "author": m["author"],
                        "version": m["version"],
                        "category": m["category"],
                        "nexus_url": m["nexus_url"],
                        "desc": m["description"],
                        "presence": {}
                    }
                mod_map[k]["presence"][lid] = m["version"]

        all_mods = list(mod_map.values())

        # Filter mods based on tab, category, and search query
        filtered_mods = []
        for m in all_mods:
            # Search
            if search_query:
                q = search_query.lower()
                if q not in m["name"].lower() and q not in m["author"].lower() and q not in m["desc"].lower():
                    continue
            # Category
            if cat_filter_idx > 0:
                selected_cat = CATEGORIES_LIST[cat_filter_idx]
                if m["category"] != selected_cat:
                    continue
            # Tab
            num_p = len(m["presence"])
            if tab_mode == 1 and num_p < len(list_ids): # Common
                continue
            if tab_mode == 2 and num_p > 1: # Unique
                continue
            if tab_mode == 3 and CURATION_DB["mods"].get(m["key"]) != "SELECTED": # Curated
                continue

            filtered_mods.append(m)

        # Draw Header
        tab_names = ["All Mods", "Common", "Unique", "⭐ Curated Selection"]
        header_text = f"⚡ Wabbajack Curator | Modlists: {len(list_ids)} | Unique Mods: {len(all_mods)} | View: [{tab_names[tab_mode]}] | Cat: [{CATEGORIES_LIST[cat_filter_idx]}]"
        stdscr.attron(curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(0, 0, header_text[:width-1])
        stdscr.attroff(curses.color_pair(1) | curses.A_BOLD)

        # Draw Search Bar / Subheader
        sub_text = f"Search: '{search_query}' | Filtered: {len(filtered_mods)} mods" if search_query else f"Use ↑/↓ scroll, 'Space' Star, 'x' Reject, 'o' Open Nexus, '/' Search, 'Tab' Cat, 'e' Export"
        stdscr.addstr(1, 0, sub_text[:width-1], curses.color_pair(5))
        stdscr.hline(2, 0, "-", width)

        # List Area Dimensions
        list_top = 3
        list_height = height - 8
        if list_height < 3:
            list_height = 3

        # Clamp Selected Index & Scroll
        if selected_index >= len(filtered_mods):
            selected_index = max(0, len(filtered_mods) - 1)
        if selected_index < top_scroll:
            top_scroll = selected_index
        if selected_index >= top_scroll + list_height:
            top_scroll = selected_index - list_height + 1

        # Render Rows
        for i in range(list_height):
            idx = top_scroll + i
            row_y = list_top + i
            if row_y >= height - 5:
                break
            if idx < len(filtered_mods):
                m = filtered_mods[idx]
                is_selected = (idx == selected_index)

                status = CURATION_DB["mods"].get(m["key"], "NONE")
                status_icon = "[ ]"
                status_color = curses.color_pair(0)
                if status == "SELECTED":
                    status_icon = "[⭐]"
                    status_color = curses.color_pair(2) | curses.A_BOLD
                elif status == "REJECTED":
                    status_icon = "[✕]"
                    status_color = curses.color_pair(3)
                elif status == "CONSIDERING":
                    status_icon = "[?]"
                    status_color = curses.color_pair(4)

                # Format presence icons
                pres_str = "".join(["[✓]" if lid in m["presence"] else "[-]" for lid in list_ids])

                note = CURATION_DB.get("notes", {}).get(m["key"], "")
                note_str = f" 📝 {note}" if note else ""
                nexus_badge = " [NEXUS]" if m["nexus_url"] else ""

                row_str = f"{status_icon} {m['name'][:35]:<35} | {m['category'][:18]:<18} | {m['author'][:15]:<15} | {pres_str}{nexus_badge}{note_str}"

                if is_selected:
                    stdscr.attron(curses.color_pair(6) | curses.A_BOLD)
                    stdscr.addstr(row_y, 0, row_str[:width-1].ljust(width-1))
                    stdscr.attroff(curses.color_pair(6) | curses.A_BOLD)
                else:
                    stdscr.attron(status_color)
                    stdscr.addstr(row_y, 0, row_str[:width-1])
                    stdscr.attroff(status_color)

        # Draw Divider & Details Footer Box
        footer_top = height - 5
        stdscr.hline(footer_top, 0, "=", width)

        if filtered_mods and selected_index < len(filtered_mods):
            cur_m = filtered_mods[selected_index]
            n_url = cur_m["nexus_url"] or "No direct Nexus URL"
            n_note = CURATION_DB.get("notes", {}).get(cur_m["key"], "None")
            detail_1 = f"Selected Mod: {cur_m['name']} (v{cur_m['version']}) | Author: {cur_m['author']} | Category: {cur_m['category']}"
            detail_2 = f"Nexus Link: {n_url}"
            detail_3 = f"Notes: {n_note} | Description: {cur_m['desc'][:80]}"

            stdscr.addstr(footer_top + 1, 0, detail_1[:width-1], curses.color_pair(1) | curses.A_BOLD)
            stdscr.addstr(footer_top + 2, 0, detail_2[:width-1], curses.color_pair(4))
            stdscr.addstr(footer_top + 3, 0, detail_3[:width-1], curses.color_pair(0))

        # Bottom Status Bar
        stdscr.addstr(height - 1, 0, status_msg[:width-1], curses.color_pair(1) | curses.A_REVERSE)

        stdscr.refresh()

        # Handle Keyboard Input
        try:
            ch = stdscr.getch()
        except:
            continue

        if ch == -1:
            continue

        if ch in (ord('q'), ord('Q')):
            break
        elif ch in (curses.KEY_UP, ord('k')):
            if selected_index > 0:
                selected_index -= 1
        elif ch in (curses.KEY_DOWN, ord('j')):
            if selected_index < len(filtered_mods) - 1:
                selected_index += 1
        elif ch == ord(' '): # Toggle Star / Select
            if filtered_mods and selected_index < len(filtered_mods):
                k = filtered_mods[selected_index]["key"]
                CURATION_DB["mods"][k] = "NONE" if CURATION_DB["mods"].get(k) == "SELECTED" else "SELECTED"
                save_curation_db(CURATION_DB)
                status_msg = f"Updated status for {filtered_mods[selected_index]['name']}"
        elif ch in (ord('x'), ord('r')): # Toggle Reject
            if filtered_mods and selected_index < len(filtered_mods):
                k = filtered_mods[selected_index]["key"]
                CURATION_DB["mods"][k] = "NONE" if CURATION_DB["mods"].get(k) == "REJECTED" else "REJECTED"
                save_curation_db(CURATION_DB)
                status_msg = f"Toggled rejection for {filtered_mods[selected_index]['name']}"
        elif ch == ord('c'): # Toggle Consider
            if filtered_mods and selected_index < len(filtered_mods):
                k = filtered_mods[selected_index]["key"]
                CURATION_DB["mods"][k] = "NONE" if CURATION_DB["mods"].get(k) == "CONSIDERING" else "CONSIDERING"
                save_curation_db(CURATION_DB)
        elif ch in (ord('o'), ord('O'), 10, 13): # Open Nexus URL in browser
            if filtered_mods and selected_index < len(filtered_mods):
                url = filtered_mods[selected_index]["nexus_url"]
                if url:
                    webbrowser.open(url)
                    status_msg = f"Opened Nexus link: {url}"
                else:
                    status_msg = "No valid Nexus URL for this mod."
        elif ch == ord('n'): # Edit Note
            if filtered_mods and selected_index < len(filtered_mods):
                k = filtered_mods[selected_index]["key"]
                curses.echo()
                curses.curs_set(1)
                stdscr.addstr(height - 1, 0, "Enter note: ".ljust(width-1), curses.color_pair(4))
                stdscr.refresh()
                note_input = stdscr.getstr(height - 1, 12, 100).decode("utf-8")
                curses.noecho()
                curses.curs_set(0)
                if not CURATION_DB.get("notes"):
                    CURATION_DB["notes"] = {}
                CURATION_DB["notes"][k] = note_input
                save_curation_db(CURATION_DB)
                status_msg = "Saved note."
        elif ch == ord('/'): # Search Query
            curses.echo()
            curses.curs_set(1)
            stdscr.addstr(height - 1, 0, "Search query: ".ljust(width-1), curses.color_pair(4))
            stdscr.refresh()
            search_query = stdscr.getstr(height - 1, 14, 60).decode("utf-8")
            curses.noecho()
            curses.curs_set(0)
            selected_index = 0
        elif ch == 9: # Tab Key -> Cycle Tabs
            tab_mode = (tab_mode + 1) % len(tab_names)
            selected_index = 0
        elif ch in (ord('t'), ord('T')): # Cycle Categories
            cat_filter_idx = (cat_filter_idx + 1) % len(CATEGORIES_LIST)
            selected_index = 0
        elif ch in (ord('l'), ord('L')): # Load .wabbajack File or URL
            curses.echo()
            curses.curs_set(1)
            stdscr.addstr(height - 1, 0, "Enter .wabbajack path or URL: ".ljust(width-1), curses.color_pair(4))
            stdscr.refresh()
            load_input = stdscr.getstr(height - 1, 30, 200).decode("utf-8").strip()
            curses.noecho()
            curses.curs_set(0)

            if load_input:
                def update_cb(msg):
                    stdscr.addstr(height - 1, 0, msg.ljust(width-1), curses.color_pair(1))
                    stdscr.refresh()

                update_cb("Loading modlist...")
                try:
                    if load_input.startswith("http://") or load_input.startswith("https://"):
                        parsed = fetch_url_modlist(load_input, progress_cb=update_cb)
                    else:
                        parsed = extract_modlist_info(Path(load_input))
                    LOADED_MODLISTS[parsed["id"]] = parsed
                    status_msg = f"Successfully loaded {parsed['name']} ({len(parsed['mods'])} mods)"
                except Exception as e:
                    status_msg = f"Error loading modlist: {e}"
        elif ch in (ord('e'), ord('E')): # Export Curated List
            export_path = Path.home() / "curated_skyrim_modlist.md"
            lines = ["# Curated Skyrim Modlist Draft\n", "Generated by Wabbajack Curator TUI\n"]
            selected_keys = [k for k, v in CURATION_DB.get("mods", {}).items() if v == "SELECTED"]
            notes_map = CURATION_DB.get("notes", {})

            selected_mods = []
            for ml in LOADED_MODLISTS.values():
                for m in ml["mods"]:
                    if m["key"] in selected_keys and m not in selected_mods:
                        selected_mods.append(m)

            by_cat = {}
            for m in selected_mods:
                c = m["category"]
                by_cat.setdefault(c, []).append(m)

            for cat, mods in by_cat.items():
                lines.append(f"## {cat}\n")
                for m in mods:
                    note = notes_map.get(m["key"])
                    note_str = f" - *Note: {note}*" if note else ""
                    link_str = f"[{m['name']}]({m['nexus_url']})" if m['nexus_url'] else m['name']
                    lines.append(f"- **{link_str}** (by {m['author']}, v{m['version']}){note_str}")
                lines.append("")

            with open(export_path, "w", encoding="utf-8") as f:
                f.write("\n".join(lines))
            status_msg = f"Exported curated selection to {export_path}"

def main():
    parser = argparse.ArgumentParser(description="Wabbajack Modlist Curator & Analyzer (Terminal TUI)")
    parser.add_argument("files", nargs="*", help="Optional .wabbajack file paths or URLs to load")
    args = parser.parse_args()

    if args.files:
        for f in args.files:
            try:
                if f.startswith("http://") or f.startswith("https://"):
                    print(f"Fetching URL: {f}...")
                    parsed = fetch_url_modlist(f, progress_cb=lambda m: print(m))
                else:
                    parsed = extract_modlist_info(Path(f))
                LOADED_MODLISTS[parsed["id"]] = parsed
                print(f"Loaded modlist: {parsed['name']} ({len(parsed['mods'])} mods)")
            except Exception as e:
                print(f"Error loading {f}: {e}")

    curses.wrapper(run_tui)

if __name__ == "__main__":
    main()
