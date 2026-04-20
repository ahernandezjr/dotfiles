## NixOS / Home‑Manager Style & Structure Guide

This is a house‑style guide for how we organize and write our NixOS and Home‑Manager modules in this repo.

It is opinionated, tuned to this codebase, and meant to answer:

- **“Is this system or user?”**
- **“Which module does this belong in?”**
- **“Where in the file / folder does this go?”**

Use this as the default, and deviate only when you have a strong reason.

---

## 1. System vs user split

- **System modules (`nixos/modules/system/*`)**
  - **What belongs here**
    - Kernel, drivers, hardware enablement.
    - System‑wide daemons and services (systemd units, networking, display managers, login managers).
    - Global graphics / audio stack (Mesa, PipeWire, nvidia drivers, X11/Wayland display server bits).
    - System‑level gaming stack (e.g. `gamemode`, `gamescope`, `programs.steam`, HDR plumbing).
    - Things that must exist before any user logs in.
  - **Typical knobs**
    - `options.systemSettings.<name>.enable`
    - Writes to `environment.systemPackages`, `environment.sessionVariables`, `services.*`, `programs.*`, `boot.*`, etc.

- **User modules (`nixos/modules/user/*`)**
  - **What belongs here**
    - Shells, terminal emulators, CLI tools, editors.
    - Per‑user config for WMs/DEs (e.g. `user.niri`), launchers, bars, themes.
    - Personal apps: browsers, chat, media players, launchers, game frontends (Lutris, Heroic, PrismLauncher, etc.).
    - Dotfiles and per‑user XDG config (`home.*`, `xdg.*`, `programs.*` from Home‑Manager).
  - **Typical knobs**
    - `options.userSettings.<name>.enable`
    - Writes to `home.*`, `programs.*`, `services.*` (HM), `xdg.*`, `home.file.*`.

**Rule of thumb**: if changing it requires a `nixos-rebuild` and affects all users, it’s **system**; if it can be scoped to a single user and mostly lives in Home‑Manager, it’s **user**.

---

## 2. Module categories and what goes where

We group modules by **concern**, not by package name. Some examples:

- **Shell (`user/shell`)**
  - Shells (fish/zsh/bash/nushell), terminal emulator, prompt, fuzzy finder, cd helper, basic CLI tools.
  - Things like `ghostty`, `zoxide`, `fzf`, `bat`, `eza`, `tmux`, `starship`, `nushell`, generic CLI utilities (`fd`, `ripgrep`, `btop`, `yazi`, archivers…).
  - Pattern: one options block + a single `config = mkIf cfg.enable { ... }` with `home.packages` and `programs.*`.

- **Gaming (`system/gaming`, `user/gaming`)**
  - **System**: kernel tweaks, `programs.gamemode`, `programs.gamescope`, `programs.steam`, system HDR / WSI helpers, global gaming env vars.
  - **User**: Wine/Proton helpers (`wineWow64Packages.*`, `winetricks`), game launchers (Lutris, Heroic, PrismLauncher), per‑user tools (ScopeBuddy config in `home.file.*`), per‑user overlays and icons.

- **Kernel / drivers / hardware**
  - Always **system**: kernel packages, nvidia options, hardware quirks, power management, input devices, etc.

- **WM / desktop (e.g. `user/niri`)**
  - WM binary belongs in **system** (installed once), but:
    - Keybinds, layouts, per‑user rules, Noctalia integration, themes → **user** module.
    - System unit wiring (graphical session) still lives in **system**.

- **Browsers, editors, media, chat, etc.**
  - Usually **user**: `home.packages` + `programs.<name>` where relevant.
  - System module only if you need system services (e.g. media servers) or special sandboxing.

When in doubt:

1. **Does it store config in `$HOME`?** → user.
2. **Does it ship a systemd unit or driver?** → system.
3. **Is it tightly coupled to a specific WM or shell?** → put it in that module’s user side.

---

## 3. Per‑module file layout

### 3.1. `default.nix` structure

Every module’s `default.nix` should look roughly like `user/shell/default.nix` or `system/gaming/default.nix`:

- **Arguments**
  - `"{ config, lib, pkgs, ... }:"` for system or user modules.
  - Add `inputs` or other extras only when needed.

- **Local `cfg`**
  - System: `cfg = config.systemSettings.<name>;`
  - User: `cfg = config.userSettings.<name>;`

- **Options block**
  - For user:
    - `options = { userSettings.<name> = { enable = mkEnableOption "..."; <other options> }; };`
  - For system:
    - `options.systemSettings.<name> = { enable = mkEnableOption "..."; <other options> };`

- **Config block**
  - `config = lib.mkIf cfg.enable { ... };`
  - Inside, follow the **section ordering** from section 4.
  - For more complex modules, you can wrap the body in `lib.mkMerge [ ... ]` but keep `mkIf` at the top level, like in `user/shell` and `user/gaming`.

### 3.2. Splitting into part files

Smaller files are good. The pattern we use:

- **`default.nix`**
  - Declares options and the main `config` block.
  - Owns the high‑level wiring (`mkIf`, `mkMerge`, imports of sub‑files).
  - Should be readable top‑to‑bottom without hunting for definitions.

- **Part files (same dir)**
  - Named by concern, not by order: e.g. `binds.nix`, `layout.nix`, `animations.nix`, `rules.nix`, `misc.nix`, `outputs.nix`, `theme.nix`, `pkgs.nix`, `services.nix`.
  - **Return just a config fragment** (an attrset) – no new `options` here.
  - Imported by `default.nix` and merged:
    - Example from `user/niri`:
      - `(import ./binds.nix { inherit config lib noctalia term; })`
      - `(import ./layout.nix { inherit lib config; })`

**Guideline**:

- **Options + global structure** → `default.nix`.
- **Plain config chunks / lists / keybinds / theme definitions** → part files.

---

## 4. Inside `config`: standard section ordering

Within a module’s `config = lib.mkIf cfg.enable { ... };` body, we keep a consistent ordering to make files scannable.

For **system modules**:

1. **Env vars**
   - `environment.sessionVariables` (or `environment.variables` if needed).
2. **Dependencies / supporting services**
   - `services.*` and `programs.*` that are there purely to support this module.
   - Low‑level plumbing (e.g. gamescope HDR helpers, gamemode, drivers).
3. **Non‑configured system packages**
   - `environment.systemPackages = with pkgs; [ ... ];`
   - Plain CLIs and libraries that don’t have their own `programs.*` in this module.
4. **Configured packages / services**
   - Remaining `programs.*` and `services.*` where this module really owns the configuration.

For **user modules**:

1. **Env vars**
   - `home.sessionVariables` or `home.sessionPath`, anything that must be set before running tools.
2. **Dependencies / helpers**
   - Services and programs that are “supporting cast” (e.g. background daemons, helper packages).
   - XDG base directories or shared state needed by later sections.
3. **Non‑configured packages**
   - `home.packages = with pkgs; [ ... ];`
   - Keep this mostly to “dumb” CLIs and GUI apps that don’t need their own module.
4. **Configured programs**
   - `programs.<name> = { ... };` (fish, ghostty, tmux, starship, etc.).
   - `services.<name> = { ... };` for Home‑Manager services.
5. **Files / templates / XDG glue**
   - `home.file.*`, `xdg.configFile.*`, etc., especially when they depend on earlier sections.

You don’t have to use every section, but **keep the relative order** (env → deps → plain packages → configured programs → files).

---

## 5. Where different things go

### 5.1. Env vars

- **System‑wide environment**
  - `environment.sessionVariables` (NixOS): things every user should see (e.g. graphics, default language, global feature flags).
  - Use sparingly and only for truly global behavior.

- **Per‑user environment**
  - `home.sessionVariables` (Home‑Manager): shell‑level tweaks, per‑user feature flags, app‑specific env.
  - Prefer this when possible.

**Rule**: if an env var is only relevant to one module’s user‑space behavior, put it in that **user module’s config**, not globally.

### 5.2. Dependencies

- “Dependencies” here are **things this module needs to function**, not user‑visible features.
  - Example: `gamescope-wsi` and `steam-run` as system‑level dependencies in `system/gaming`.
  - Example: `fd` as the backing command for `fzf` in `user/shell`.
- Put them early in the config, after env vars, so it’s obvious what the module relies on.

### 5.3. Non‑configured packages

- Packages with **no module config here**:
  - CLIs, GUI apps, icons, themes, small tools.
  - Example from `user/shell`: `btop`, `fd`, `lazygit`, `neofetch`, `ripgrep`, `yazi`, `p7zip`, `unrar`.
- These live in:
  - `environment.systemPackages` (system).
  - `home.packages` (user).
- Keep them **grouped and roughly categorized** with comments if the list gets long.

### 5.4. Configured packages

- When something has non‑trivial options:
  - Use `programs.<name> = { ... };` or `services.<name> = { ... };`.
  - Only put it under this module if it logically belongs there.
    - Example: `programs.zoxide`, `programs.fzf`, `programs.tmux` in `user/shell`.
    - Example: `programs.gamemode`, `programs.gamescope`, `programs.steam` in `system/gaming`.
- Large or complex configs can be split into part files and merged in with `lib.mkMerge`.

---

## 6. Adding something new: decision checklist

When you add a new tool / package / config, follow this checklist:

1. **System vs user**
   - Needs drivers, systemd units, kernel tweaks, or affects all users? → **system module**.
   - Purely user‑space (CLI/GUI app, per‑user daemon, WM/keybinds)? → **user module**.

2. **Pick the category**
   - Shell / base CLI? → `user/shell`.
   - Wayland/i3/etc. behavior or keybinds? → that WM’s user module (e.g. `user/niri`).
   - Game launchers, Wine helpers, game tweaks? → `user/gaming`.
   - Game performance, Steam/gamescope/HDR plumbing? → `system/gaming`.
   - Something else? Create / reuse a module under the closest concern (e.g. `browsers`, `development`, `media`, `chat`).

3. **Within the module, choose the right place**
   - Just a package, no options? → `home.packages` or `environment.systemPackages` under “non‑configured packages”.
   - Needs configuration?
     - Small: add a `programs.<name> = { ... };` block in the “configured packages” section.
     - Big / WM‑style config: create a descriptive part file (e.g. `bindings.nix`, `rules.nix`, `theme.nix`) and import it in `default.nix`.
   - Needs env vars? → add them to the **env vars** section at the top of the module’s `config`.

4. **Naming**
   - Prefer `userSettings.<name>` / `systemSettings.<name>` for top‑level options.
   - Part files named by concern (`binds`, `layout`, `rules`, `theme`, `misc`, `pkgs`, `services`), not generic `part1`, `part2`.

---

## 7. Style notes

- **Options first, config second**
  - Follow the NixOS module manual: options at the top, config at the bottom.
  - Avoid defining options in part files; centralize them in `default.nix`.

- **Keep imports explicit**
  - In `nixos/modules/user/default.nix`, we auto‑import submodules, but **inside each module directory** keep imports explicit (`imports = [ ./binds.nix ./layout.nix ... ];` or `lib.mkMerge` of `import`s).

- **Minimal cleverness**
  - Prefer direct, explicit lists (`home.packages = with pkgs; [ ... ];`) over nested `lib.optional` gymnastics unless there’s a clear benefit.

- **Shared helpers for large, repeated code**
  - When a large, non‑trivial block is repeated across modules, extract it into a helper under `nixos/lib` instead of copying it again.
  - Example: `nixos/lib/import-all.nix` exposes `importAllDir { root; filter; }`, used by both `modules/system/default.nix` and `modules/user/default.nix` to recursively import all module files under a directory.
  - Future helpers should follow the same pattern: small, focused functions that hide traversal/boilerplate (like directory walking or repeated `mapAttrs` logic) while keeping per‑module behavior (filters, options, paths) explicit in the caller.

- **Consistency over perfection**
  - If you’re unsure, mirror the structure of an existing “clean” module like `user/shell` or `user/gaming` and adapt the names.

Over time, the idea is that you can open any module, scroll once, and immediately see:

- What it controls (options),
- When it’s active (`cfg.enable`),
- What env vars it sets,
- What it depends on,
- What it installs,
- What it configures.

