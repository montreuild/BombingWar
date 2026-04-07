# Bombing War

A top-down 2D aerial combat game for Android and iOS, built with Flutter + Flame.

## Overview

Control aircraft squadrons to destroy underground enemy bases across infinitely generated levels. Features three unlockable aircraft, multiple enemy types, a threat/detection system, and a score/progression system.

## Architecture

```
lib/
  config/           - Game constants and tuning values
  models/           - Pure Dart data models (aircraft, weapons, enemies, levels, progress)
  game/
    components/     - Flame PositionComponents (aircraft, enemies, projectiles, effects, HUD)
    systems/        - Stateless logic systems (collision, score, threat, waves)
    managers/       - Stateful managers (game state, levels, save data, audio)
  ui/
    screens/        - Flutter Widget screens (menu, hangar, level complete, game over)
    widgets/        - Reusable Flutter widgets
```

## Aircraft

| Aircraft      | Speed | Health | Weapons              | Special Ability                       | Unlock  |
|---------------|-------|--------|----------------------|---------------------------------------|---------|
| Interceptor   | 250   | 80     | Missiles + Guns      | Barrel Roll (dodge missiles)          | Default |
| Heavy Bomber  | 150   | 200    | Carpet Bombs         | Armor (50% damage reduction for 3s)   | Level 5 |
| Stealth X-26  | 200   | 100    | Penetrator Bomb      | Cloak (invisible to AA for 5s)        | Level 15|

## Enemy Types

- **Infantry** – Light infantry that pops from ruins, fires bullets. 30 HP, 10 pts.
- **RPG Unit** – Slow-moving rocket launcher. 60 HP, 25 pts.
- **Bunker** – Opens, fires missile salvo, closes. 150 HP, 100 pts.
- **Underground Factory** – Boss target destroyable only by penetrator bomb. 500 HP, 500 pts.

## Level Generation

Levels are procedurally generated from a deterministic seed (`levelNumber * 31337`):
- Difficulty scales at `base + (levelNumber * 0.15)`.
- Enemy count per wave: `3 + floor(levelNumber / 2)`.
- New enemy types unlock at levels 3, 7, and 12.
- A factory boss appears every 5 levels.

## Controls

- **Left joystick** – Move aircraft
- **A button** – Fire weapon
- **B button** – Activate special ability
- **C button** – Switch weapon

## Building

```bash
flutter pub get
flutter build apk          # Android
flutter build ios          # iOS
```
