# FiveM Bar and Pub Resource

Last Call Pints is a Qbox FiveM bar resource for pouring and serving pints. It uses `qbx_core`, `ox_lib`, and `ox_inventory` to validate bar job, grade, and duty status, manage keg and pint items, and show configurable bar interactions.

## Install

1. Place the resource folder in your server’s resources directory.
2. Add `ensure ender_pub` to `server.cfg` after `qbx_core`, `ox_lib`, and `ox_inventory`.
3. Add the configured keg and pint item names to your `ox_inventory` item definitions: `lager_keg`, `pale_ale_keg`, `stout_keg`, `lager_pint`, `pale_ale_pint`, and `stout_pint`.
4. Make keg items available to bar staff through your server’s existing inventory workflow.
5. Set the interaction coordinates and job settings in `config.lua`.

## Use

1. Configure `Config.Job`, `Config.MinimumGrade`, and `Config.RequireDuty` to match your Qbox bar job.
2. Configure keg and pint item names, prices, interaction points, and action timings in `config.lua`.
3. In game, eligible bar staff can use the marked pour point to select a drink and pour a pint, the serve point to transfer a pint to a nearby player, and the storage point to check keg counts in their inventory.
4. Ensure staff have the required keg items and customers have room for the pint. Pouring consumes a keg item and creates a pint; serving transfers a pint from the bartender to the selected customer.

---

More FiveM resource projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/31d2aeb9-1088-4ccb-bdc6-f352d24dc2b1?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=31d2aeb9-1088-4ccb-bdc6-f352d24dc2b1
