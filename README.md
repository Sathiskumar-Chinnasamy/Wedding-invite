# LinkedBlox Map Blockout

This workspace now includes a Roblox Studio map generator: [GuildHubTerrainBuilder.server.lua](./GuildHubTerrainBuilder.server.lua)
It also includes a movement script: [GuildHubMovement.client.lua](./GuildHubMovement.client.lua)

## How to use it

1. Open your place in Roblox Studio.
2. Insert `GuildHubTerrainBuilder.server.lua` into `ServerScriptService`.
3. Insert `GuildHubMovement.client.lua` into `StarterPlayer` > `StarterPlayerScripts`.
4. Run the place once in Studio.
5. The terrain script generates the hub at `Workspace.GeneratedGuildHub`.
6. When you are happy with the blockout, keep editing it in Studio and remove or disable the terrain script so it does not regenerate every run.

## What it builds

- Spawn plaza with a domed castle-like structure
- Central guild hall
- Builder, animator, artist, and musician guild districts
- Marketplace
- VFX / UI prototype zone
- Future expansion pads
- Central fountain
- Forest ring, rock edges, lake, river, and waterfall
- Path network matching the concept layout
- Extra houses, props, lamps, benches, and district support buildings
- Sprint and custom shift-lock controls

## Controls

- `LeftShift`: hold to sprint
- `LeftAlt`: toggle shift lock

## Notes

- This is a stylized blockout, not a final art pass.
- It is designed for an empty or mostly empty place centered around `(0, 0, 0)`.
- Re-running the script clears and rebuilds the area around the hub.

## Wedding invitation

A separate static invitation website with the supplied photos and editable event details is in the [wedding-invitation](./wedding-invitation/) folder. See its README for personalization and publishing notes.
