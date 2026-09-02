#!/usr/bin/env python3
"""
Wabbajack Modlist Curator & Analyzer
Parses, compares, categorizes, and curates mods from 1 or more .wabbajack files.
"""

import os
import sys
import json
import zipfile
import urllib.request
import urllib.parse
import re
import argparse
import webbrowser
import threading
from pathlib import Path
from http.server import HTTPServer, BaseHTTPRequestHandler
import io

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
            print(f"Error loading curation DB: {e}")
    return {"mods": {}, "categories": {}, "notes": {}}

def save_curation_db(db):
    try:
        with open(CURATION_DB_FILE, "w", encoding="utf-8") as f:
            json.dump(db, f, indent=2)
    except Exception as e:
        print(f"Error saving curation DB: {e}")

# In-memory store for loaded modlists in current session
LOADED_MODLISTS = {}  # modlist_id -> dict of parsed data
CURATION_DB = load_curation_db()

# --- Mod Categorization Rules ---
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

def extract_modlist_info(zip_bytes_or_path, list_name_override=None):
    """Parses a .wabbajack zip file and extracts archives, directives, and metadata."""
    if isinstance(zip_bytes_or_path, (str, Path)):
        z = zipfile.ZipFile(zip_bytes_or_path, 'r')
    else:
        z = zipfile.ZipFile(zip_bytes_or_path, 'r')

    if "modlist" not in z.namelist():
        raise ValueError("Invalid .wabbajack file: missing 'modlist' manifest entry.")

    raw_json = z.read("modlist").decode("utf-8", errors="ignore")
    data = json.loads(raw_json)

    list_id = list_name_override or data.get("Name") or "Unnamed Modlist"
    archives = data.get("Archives", [])
    directives = data.get("Directives", [])

    parsed_mods = []
    for a in archives:
        st = a.get("State", {})
        st_type = st.get("$type", "")

        # Extract mod metadata
        mod_name = st.get("Name") or a.get("Name") or "Unknown Mod"
        mod_id = st.get("ModID") or st.get("ModId") or None
        file_id = st.get("FileID") or st.get("FileId") or None
        game_name = st.get("GameName") or data.get("GameType") or "skyrimspecialedition"
        author = st.get("Author") or "Unknown"
        version = st.get("Version") or "1.0"
        desc = st.get("Description") or ""
        image_url = st.get("ImageURL") or ""
        size = a.get("Size") or 0
        file_hash = a.get("Hash") or ""

        # Nexus URL resolution
        nexus_url = None
        clean_game = (game_name or "skyrimspecialedition").lower()
        if mod_id and game_name:
            if "skyrimspecialedition" in clean_game or "sse" in clean_game:
                clean_game = "skyrimspecialedition"
            elif "skyrim" in clean_game:
                clean_game = "skyrim"
            elif "fallout4" in clean_game:
                clean_game = "fallout4"
            elif "enderalse" in clean_game or "enderal" in clean_game:
                clean_game = "enderalspecialedition"
            nexus_url = f"https://www.nexusmods.com/{clean_game}/mods/{mod_id}"
        elif st.get("Url"):
            nexus_url = st.get("Url")

        # Key for unique identification across modlists
        unique_key = f"{mod_id}_{clean_game}" if mod_id else f"name_{mod_name.lower().strip()}"

        cat = auto_categorize(mod_name, desc)

        parsed_mods.append({
            "key": unique_key,
            "name": mod_name,
            "mod_id": mod_id,
            "file_id": file_id,
            "game": game_name,
            "author": author,
            "version": str(version),
            "description": desc,
            "image_url": image_url,
            "nexus_url": nexus_url,
            "size": size,
            "hash": file_hash,
            "category": cat,
            "download_type": st_type.split(",")[0]
        })

    return {
        "id": list_id,
        "name": data.get("Name") or list_id,
        "author": data.get("Author") or "Unknown",
        "version": str(data.get("Version") or "1.0"),
        "description": data.get("Description") or "",
        "game": data.get("GameType") or "skyrimspecialedition",
        "archives_count": len(archives),
        "directives_count": len(directives),
        "mods": parsed_mods
    }

# --- HTTP Request Handler for Backend & Web UI ---
HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Wabbajack Modlist Curator & Analyzer</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-base: #0f1115;
            --bg-surface: #181b20;
            --bg-card: #20242c;
            --bg-hover: #2a2f3a;
            --border: #2e3440;
            --border-bright: #434c5e;
            --text-main: #e5e9f0;
            --text-muted: #8892b0;
            --accent: #88c0d0;
            --accent-green: #a3be8c;
            --accent-orange: #d08770;
            --accent-purple: #b48ead;
            --accent-gold: #ebcb8b;
            --accent-red: #bf616a;
            --radius: 8px;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Inter', sans-serif;
            background: var(--bg-base);
            color: var(--text-main);
            height: 100vh;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        /* Header */
        header {
            background: var(--bg-surface);
            border-bottom: 1px solid var(--border);
            padding: 12px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .logo { display: flex; align-items: center; gap: 12px; font-weight: 700; font-size: 1.15rem; color: var(--accent); }
        .logo-badge { background: rgba(136, 192, 208, 0.15); border: 1px solid var(--accent); padding: 2px 8px; border-radius: 12px; font-size: 0.75rem; }

        .header-actions { display: flex; gap: 10px; }
        .btn {
            background: var(--bg-card);
            color: var(--text-main);
            border: 1px solid var(--border-bright);
            padding: 8px 16px;
            border-radius: var(--radius);
            font-size: 0.85rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .btn:hover { background: var(--bg-hover); border-color: var(--accent); }
        .btn-primary { background: var(--accent); color: #0f1115; border: none; font-weight: 600; }
        .btn-primary:hover { background: #81a1c1; }

        /* Main Workspace Layout */
        .workspace {
            display: flex;
            flex: 1;
            overflow: hidden;
        }

        /* Sidebar / Controls */
        sidebar {
            width: 320px;
            background: var(--bg-surface);
            border-right: 1px solid var(--border);
            padding: 16px;
            display: flex;
            flex-direction: column;
            gap: 16px;
            overflow-y: auto;
        }
        .panel { background: var(--bg-card); border: 1px solid var(--border); border-radius: var(--radius); padding: 14px; }
        .panel-title { font-size: 0.85rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; color: var(--text-muted); margin-bottom: 10px; }

        .modlist-chip {
            background: var(--bg-surface);
            border: 1px solid var(--border);
            padding: 8px 10px;
            border-radius: 6px;
            margin-bottom: 6px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 0.85rem;
        }
        .modlist-chip-remove { color: var(--accent-red); cursor: pointer; font-weight: bold; padding: 2px 6px; }

        /* Content Area */
        main {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            background: var(--bg-base);
        }

        /* Filter Toolbar */
        .toolbar {
            padding: 14px 24px;
            background: var(--bg-surface);
            border-bottom: 1px solid var(--border);
            display: flex;
            gap: 12px;
            align-items: center;
            flex-wrap: wrap;
        }
        .search-box {
            flex: 1;
            min-width: 240px;
            background: var(--bg-card);
            border: 1px solid var(--border);
            color: var(--text-main);
            padding: 8px 14px;
            border-radius: var(--radius);
            font-size: 0.9rem;
            outline: none;
        }
        .search-box:focus { border-color: var(--accent); }

        select.filter-select {
            background: var(--bg-card);
            border: 1px solid var(--border);
            color: var(--text-main);
            padding: 8px 12px;
            border-radius: var(--radius);
            font-size: 0.85rem;
            outline: none;
        }

        /* Tabs */
        .tabs { display: flex; gap: 4px; background: var(--bg-card); padding: 4px; border-radius: var(--radius); border: 1px solid var(--border); }
        .tab-btn {
            padding: 6px 12px;
            font-size: 0.8rem;
            border-radius: 6px;
            border: none;
            background: transparent;
            color: var(--text-muted);
            cursor: pointer;
            font-weight: 500;
        }
        .tab-btn.active { background: var(--accent); color: #0f1115; font-weight: 600; }

        /* Mod List Table Container */
        .table-container {
            flex: 1;
            overflow: auto;
            padding: 16px 24px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.85rem;
        }
        th {
            position: sticky;
            top: 0;
            background: var(--bg-surface);
            color: var(--text-muted);
            font-weight: 600;
            text-align: left;
            padding: 10px 14px;
            border-bottom: 1px solid var(--border);
            z-index: 10;
        }
        td {
            padding: 10px 14px;
            border-bottom: 1px solid var(--border);
            vertical-align: middle;
        }
        tr:hover { background: var(--bg-card); }
        tr.selected-mod { background: rgba(163, 190, 140, 0.12); }
        tr.rejected-mod { background: rgba(191, 97, 106, 0.08); opacity: 0.6; }

        .mod-name { font-weight: 600; color: var(--text-main); text-decoration: none; }
        .mod-name:hover { color: var(--accent); }
        .nexus-link { color: var(--accent); text-decoration: none; margin-left: 6px; font-size: 0.8rem; }
        .badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 12px;
            font-size: 0.72rem;
            font-weight: 600;
            text-transform: uppercase;
        }
        .badge-cat { background: rgba(136, 192, 208, 0.15); color: var(--accent); border: 1px solid rgba(136, 192, 208, 0.3); }
        .badge-present { background: rgba(163, 190, 140, 0.2); color: var(--accent-green); }
        .badge-absent { color: var(--text-muted); opacity: 0.3; }

        .action-icon {
            cursor: pointer;
            padding: 4px 8px;
            border-radius: 4px;
            border: 1px solid var(--border);
            background: var(--bg-surface);
            font-size: 0.8rem;
            margin-right: 4px;
        }
        .action-icon:hover { border-color: var(--accent); }
        .action-icon.active-star { background: var(--accent-green); color: #0f1115; border-color: var(--accent-green); }
        .action-icon.active-reject { background: var(--accent-red); color: #fff; border-color: var(--accent-red); }

        .note-input {
            width: 100%;
            background: var(--bg-base);
            border: 1px solid var(--border);
            color: var(--text-main);
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.8rem;
        }

        /* Modals */
        .modal-overlay {
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(0, 0, 0, 0.7);
            backdrop-filter: blur(4px);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 100;
        }
        .modal {
            background: var(--bg-surface);
            border: 1px solid var(--border-bright);
            border-radius: var(--radius);
            width: 650px;
            max-width: 90vw;
            max-height: 85vh;
            display: flex;
            flex-direction: column;
            overflow: hidden;
            box-shadow: 0 20px 40px rgba(0,0,0,0.5);
        }
        .modal-header { padding: 16px 20px; border-bottom: 1px solid var(--border); display: flex; justify-content: space-between; font-weight: 600; }
        .modal-body { padding: 20px; overflow-y: auto; flex: 1; }
        .gallery-item {
            background: var(--bg-card);
            border: 1px solid var(--border);
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
    </style>
</head>
<body>
    <header>
        <div class="logo">
            <span>⚡ Wabbajack Modlist Curator</span>
            <span class="logo-badge">Skyrim SE Suite</span>
        </div>
        <div class="header-actions">
            <button class="btn" onclick="openGalleryModal()">🌐 Add Modlist from Gallery</button>
            <button class="btn" onclick="openUrlModal()">🔗 Load URL / Local File</button>
            <button class="btn btn-primary" onclick="exportSelection()">💾 Export Curated List</button>
        </div>
    </header>

    <div class="workspace">
        <sidebar>
            <div class="panel">
                <div class="panel-title">Active Modlists (<span id="modlists-count">0</span>)</div>
                <div id="modlists-container">
                    <div style="color: var(--text-muted); font-size: 0.8rem;">No modlists loaded yet. Add a modlist from the gallery or load a .wabbajack file.</div>
                </div>
            </div>

            <div class="panel">
                <div class="panel-title">Curation Summary</div>
                <div style="font-size: 0.85rem; display: flex; flex-direction: column; gap: 8px;">
                    <div>Selected Mods: <strong id="stat-selected" style="color: var(--accent-green)">0</strong></div>
                    <div>Considering: <strong id="stat-considering" style="color: var(--accent-gold)">0</strong></div>
                    <div>Rejected: <strong id="stat-rejected" style="color: var(--accent-red)">0</strong></div>
                </div>
            </div>
        </sidebar>

        <main>
            <div class="toolbar">
                <input type="text" id="search-input" class="search-box" placeholder="Search mods by name, author, or description..." oninput="renderTable()">
                
                <select id="category-filter" class="filter-select" onchange="renderTable()">
                    <option value="ALL">All Categories</option>
                    <option value="Core & Bug Fixes">Core & Bug Fixes</option>
                    <option value="Graphics & Textures">Graphics & Textures</option>
                    <option value="Environment & Weather">Environment & Weather</option>
                    <option value="User Interface & HUD">User Interface & HUD</option>
                    <option value="Animations & Physics">Animations & Physics</option>
                    <option value="Armors, Weapons & Clothes">Armors, Weapons & Clothes</option>
                    <option value="Characters & Followers">Characters & Followers</option>
                    <option value="Gameplay & Combat">Gameplay & Combat</option>
                    <option value="Quests & Locations">Quests & Locations</option>
                    <option value="Audio & Sound">Audio & Sound</option>
                    <option value="Miscellaneous">Miscellaneous</option>
                </select>

                <div class="tabs">
                    <button class="tab-btn active" data-tab="ALL" onclick="setTab(this)">All Mods</button>
                    <button class="tab-btn" data-tab="COMMON" onclick="setTab(this)">Common</button>
                    <button class="tab-btn" data-tab="UNIQUE" onclick="setTab(this)">Unique</button>
                    <button class="tab-btn" data-tab="CURATED" onclick="setTab(this)">⭐ My Curated Selection</button>
                </div>
            </div>

            <div class="table-container">
                <table>
                    <thead>
                        <tr id="table-head-row">
                            <th style="width: 90px">Status</th>
                            <th>Mod Name & Info</th>
                            <th>Category</th>
                            <th>Author</th>
                            <th id="th-modlists-header">Modlists Presence</th>
                            <th style="width: 200px">Notes</th>
                        </tr>
                    </thead>
                    <tbody id="mods-table-body">
                        <!-- Rows rendered dynamically -->
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <!-- Gallery Modal -->
    <div class="modal-overlay" id="gallery-modal">
        <div class="modal">
            <div class="modal-header">
                <span>Wabbajack Official Modlists Catalog</span>
                <span style="cursor:pointer" onclick="closeModal('gallery-modal')">✕</span>
            </div>
            <div class="modal-body" id="gallery-list">
                Loading official gallery...
            </div>
        </div>
    </div>

    <!-- URL / File Modal -->
    <div class="modal-overlay" id="url-modal">
        <div class="modal">
            <div class="modal-header">
                <span>Load .wabbajack File or Direct URL</span>
                <span style="cursor:pointer" onclick="closeModal('url-modal')">✕</span>
            </div>
            <div class="modal-body">
                <div style="margin-bottom: 14px">
                    <label style="display:block; margin-bottom: 6px; font-size: 0.85rem">Paste .wabbajack URL (e.g. from authored-files.wabbajack.org):</label>
                    <input type="text" id="url-input" class="search-box" style="width: 100%" placeholder="https://authored-files.wabbajack.org/...">
                    <button class="btn btn-primary" style="margin-top: 8px" onclick="loadFromUrl()">Fetch & Parse URL</button>
                </div>
            </div>
        </div>
    </div>

    <script>
        let currentTab = 'ALL';
        let loadedModlists = {}; // id -> modlist object
        let curationDb = { mods: {}, notes: {} };

        async function init() {
            await fetchModlists();
            await fetchCuration();
        }

        async function fetchModlists() {
            const res = await fetch('/api/modlists');
            loadedModlists = await res.json();
            renderSidebar();
            renderTable();
        }

        async function fetchCuration() {
            const res = await fetch('/api/curation');
            curationDb = await res.json();
            updateStats();
            renderTable();
        }

        function renderSidebar() {
            const container = document.getElementById('modlists-container');
            const keys = Object.keys(loadedModlists);
            document.getElementById('modlists-count').textContent = keys.length;

            if (keys.length === 0) {
                container.innerHTML = '<div style="color: var(--text-muted); font-size: 0.8rem;">No modlists loaded yet. Use gallery or URL to load modlists.</div>';
                return;
            }

            container.innerHTML = keys.map(k => {
                const ml = loadedModlists[k];
                return `<div class="modlist-chip">
                    <div>
                        <strong>${ml.name}</strong>
                        <div style="font-size:0.75rem; color: var(--text-muted)">${ml.mods.length} mods</div>
                    </div>
                    <span class="modlist-chip-remove" onclick="removeModlist('${k}')">✕</span>
                </div>`;
            }).join('');
        }

        async function removeModlist(id) {
            await fetch('/api/modlists?id=' + encodeURIComponent(id), { method: 'DELETE' });
            await fetchModlists();
        }

        function setTab(btn) {
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            currentTab = btn.getAttribute('data-tab');
            renderTable();
        }

        function updateStats() {
            let sel = 0, cons = 0, rej = 0;
            Object.values(curationDb.mods || {}).forEach(status => {
                if (status === 'SELECTED') sel++;
                if (status === 'CONSIDERING') cons++;
                if (status === 'REJECTED') rej++;
            });
            document.getElementById('stat-selected').textContent = sel;
            document.getElementById('stat-considering').textContent = cons;
            document.getElementById('stat-rejected').textContent = rej;
        }

        async function setModStatus(key, status) {
            if (curationDb.mods[key] === status) {
                delete curationDb.mods[key];
            } else {
                curationDb.mods[key] = status;
            }
            await fetch('/api/curation', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(curationDb)
            });
            updateStats();
            renderTable();
        }

        async function updateNote(key, noteText) {
            if (!curationDb.notes) curationDb.notes = {};
            curationDb.notes[key] = noteText;
            await fetch('/api/curation', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(curationDb)
            });
        }

        function renderTable() {
            const listIds = Object.keys(loadedModlists);
            const search = (document.getElementById('search-input').value || '').toLowerCase();
            const category = document.getElementById('category-filter').value;

            // Update Dynamic Headings for loaded lists
            const headRow = document.getElementById('table-head-row');
            const baseHeadHtml = `
                <th style="width: 90px">Status</th>
                <th>Mod Name & Info</th>
                <th>Category</th>
                <th>Author</th>
                ${listIds.map(id => `<th>${loadedModlists[id].name}</th>`).join('')}
                <th style="width: 220px">My Notes</th>
            `;
            headRow.innerHTML = baseHeadHtml;

            // Build aligned list of all mods
            const modMap = {};
            listIds.forEach(id => {
                const ml = loadedModlists[id];
                ml.mods.forEach(m => {
                    if (!modMap[m.key]) {
                        modMap[m.key] = {
                            key: m.key,
                            name: m.name,
                            author: m.author,
                            category: m.category,
                            nexus_url: m.nexus_url,
                            version: m.version,
                            desc: m.description,
                            presence: {}
                        };
                    }
                    modMap[m.key].presence[id] = m.version;
                });
            });

            const allMods = Object.values(modMap);
            const tbody = document.getElementById('mods-table-body');

            if (allMods.length === 0) {
                tbody.innerHTML = `<tr><td colspan="${5 + listIds.length}" style="text-align: center; color: var(--text-muted); padding: 40px">Load one or more modlists to begin comparing and curating mods.</td></tr>`;
                return;
            }

            const filtered = allMods.filter(m => {
                // Search filter
                if (search && !m.name.toLowerCase().includes(search) && !m.author.toLowerCase().includes(search) && !m.desc.toLowerCase().includes(search)) return false;
                // Category filter
                if (category !== 'ALL' && m.category !== category) return false;
                // Tab filter
                const numPresent = Object.keys(m.presence).length;
                if (currentTab === 'COMMON' && numPresent < listIds.length) return false;
                if (currentTab === 'UNIQUE' && numPresent > 1) return false;
                if (currentTab === 'CURATED' && curationDb.mods[m.key] !== 'SELECTED') return false;

                return true;
            });

            tbody.innerHTML = filtered.slice(0, 500).map(m => {
                const status = curationDb.mods[m.key] || 'NONE';
                const note = (curationDb.notes && curationDb.notes[m.key]) || '';

                let trClass = '';
                if (status === 'SELECTED') trClass = 'selected-mod';
                if (status === 'REJECTED') trClass = 'rejected-mod';

                return `<tr class="${trClass}">
                    <td>
                        <span class="action-icon ${status === 'SELECTED' ? 'active-star' : ''}" title="Select for Custom List" onclick="setModStatus('${m.key}', 'SELECTED')">⭐</span>
                        <span class="action-icon ${status === 'REJECTED' ? 'active-reject' : ''}" title="Reject Mod" onclick="setModStatus('${m.key}', 'REJECTED')">✕</span>
                    </td>
                    <td>
                        <div>
                            <span class="mod-name">${m.name}</span>
                            ${m.nexus_url ? `<a href="${m.nexus_url}" target="_blank" class="nexus-link">↗ Nexus</a>` : ''}
                        </div>
                    </td>
                    <td><span class="badge badge-cat">${m.category}</span></td>
                    <td style="color: var(--text-muted)">${m.author}</td>
                    ${listIds.map(id => {
                        const ver = m.presence[id];
                        return VerBadgeHtml(ver);
                    }).join('')}
                    <td>
                        <input type="text" class="note-input" value="${escapeHtml(note)}" placeholder="Add note..." onchange="updateNote('${m.key}', this.value)">
                    </td>
                </tr>`;
            }).join('');
        }

        function VerBadgeHtml(ver) {
            if (ver) {
                return `<td><span class="badge badge-present">✓ v${ver}</span></td>`;
            }
            return `<td><span class="badge badge-absent">-</span></td>`;
        }

        function escapeHtml(str) {
            return (str || '').replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
        }

        function openGalleryModal() {
            document.getElementById('gallery-modal').style.display = 'flex';
            loadGallery();
        }
        function openUrlModal() {
            document.getElementById('url-modal').style.display = 'flex';
        }
        function closeModal(id) {
            document.getElementById(id).style.display = 'none';
        }

        async function loadGallery() {
            const container = document.getElementById('gallery-list');
            try {
                const res = await fetch('/api/gallery');
                const gallery = await res.json();
                container.innerHTML = gallery.map(item => `
                    <div class="gallery-item">
                        <div>
                            <strong>${item.title}</strong> (${item.game})
                            <div style="font-size: 0.8rem; color: var(--text-muted)">Author: ${item.author}</div>
                        </div>
                        <button class="btn btn-primary" onclick="loadGalleryUrl('${item.links.download}', '${item.title}')">Load List</button>
                    </div>
                `).join('');
            } catch(e) {
                container.innerHTML = 'Error loading gallery: ' + e;
            }
        }

        async function loadGalleryUrl(url, name) {
            closeModal('gallery-modal');
            await fetch('/api/load-url', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({url: url, name: name})
            });
            await fetchModlists();
        }

        async function loadFromUrl() {
            const url = document.getElementById('url-input').value.trim();
            if (!url) return;
            closeModal('url-modal');
            await fetch('/api/load-url', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({url: url})
            });
            await fetchModlists();
        }

        async function exportSelection() {
            window.open('/api/export', '_blank');
        }

        window.onload = init;
    </script>
</body>
</html>
"""

class CuratorHTTPRequestHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass # Suppress verbose http logs in terminal

    def do_GET(self):
        parsed_url = urllib.parse.urlparse(self.path)
        path = parsed_url.path

        if path in ("/", "/index.html"):
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(HTML_TEMPLATE.encode("utf-8"))
            return

        if path == "/api/modlists":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(LOADED_MODLISTS).encode("utf-8"))
            return

        if path == "/api/curation":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(CURATION_DB).encode("utf-8"))
            return

        if path == "/api/gallery":
            try:
                gallery_url = "https://raw.githubusercontent.com/wabbajack-tools/mod-lists/master/modlists.json"
                req = urllib.request.Request(gallery_url, headers={"User-Agent": "Mozilla/5.0"})
                data = json.loads(urllib.request.urlopen(req).read().decode("utf-8"))
                # Filter for Bethesda modlists
                skyrim_lists = [m for m in data if "skyrim" in (m.get("game") or "").lower() or "fallout" in (m.get("game") or "").lower()]
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps(skyrim_lists).encode("utf-8"))
            except Exception as e:
                self.send_error(500, str(e))
            return

        if path == "/api/export":
            # Generate Markdown report of curated selection
            lines = ["# Curated Skyrim Modlist Draft\n"]
            lines.append("Generated by Wabbajack Modlist Curator\n")
            
            selected_keys = [k for k, v in CURATION_DB.get("mods", {}).items() if v == "SELECTED"]
            notes_map = CURATION_DB.get("notes", {})

            # Collect all selected mod details
            selected_mods = []
            for ml in LOADED_MODLISTS.values():
                for m in ml["mods"]:
                    if m["key"] in selected_keys and m not in selected_mods:
                        selected_mods.append(m)

            # Group by category
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

            report = "\n".join(lines)
            self.send_response(200)
            self.send_header("Content-Type", "text/markdown; charset=utf-8")
            self.send_header("Content-Disposition", 'attachment; filename="curated_skyrim_modlist.md"')
            self.end_headers()
            self.wfile.write(report.encode("utf-8"))
            return

        self.send_error(404, "Not Found")

    def do_POST(self):
        parsed_url = urllib.parse.urlparse(self.path)
        path = parsed_url.path
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length).decode("utf-8") if length > 0 else "{}"
        post_data = json.loads(body) if body else {}

        if path == "/api/curation":
            global CURATION_DB
            CURATION_DB = post_data
            save_curation_db(CURATION_DB)
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok"}).encode("utf-8"))
            return

        if path == "/api/load-url":
            url = post_data.get("url")
            override_name = post_data.get("name")
            if not url:
                self.send_error(400, "Missing URL")
                return

            try:
                # Fetch wabbajack archive
                req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
                data_bytes = urllib.request.urlopen(req).read()
                
                parsed = extract_modlist_info(io.BytesIO(data_bytes), list_name_override=override_name)
                LOADED_MODLISTS[parsed["id"]] = parsed

                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"status": "ok", "id": parsed["id"]}).encode("utf-8"))
            except Exception as e:
                self.send_error(500, f"Error fetching or parsing modlist: {e}")
            return

        self.send_error(404, "Not Found")

    def do_DELETE(self):
        parsed_url = urllib.parse.urlparse(self.path)
        query = urllib.parse.parse_qs(parsed_url.query)
        list_id = query.get("id", [None])[0]
        if list_id and list_id in LOADED_MODLISTS:
            del LOADED_MODLISTS[list_id]
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps({"status": "ok"}).encode("utf-8"))

def main():
    parser = argparse.ArgumentParser(description="Wabbajack Modlist Curator & Analyzer")
    parser.add_argument("--port", type=int, default=8765, help="Port to serve web interface")
    parser.add_argument("--load", type=str, nargs="*", help="Optional .wabbajack file paths to load immediately")
    parser.add_argument("--no-browser", action="store_true", help="Do not open browser automatically")
    args = parser.parse_args()

    if args.load:
        for path_str in args.load:
            p = Path(path_str)
            if p.exists():
                try:
                    parsed = extract_modlist_info(p)
                    LOADED_MODLISTS[parsed["id"]] = parsed
                    print(f"Loaded modlist: {parsed['name']} ({len(parsed['mods'])} mods)")
                except Exception as e:
                    print(f"Failed to load {p}: {e}")

    server = HTTPServer(("127.0.0.1", args.port), CuratorHTTPRequestHandler)
    url = f"http://127.0.0.1:{args.port}"
    print(f"⚡ Wabbajack Modlist Curator running at {url}")

    if not args.no_browser:
        threading.Timer(0.8, lambda: webbrowser.open(url)).start()

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down Wabbajack Curator.")

if __name__ == "__main__":
    main()
