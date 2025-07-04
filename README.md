I am currently away ; please use [this link](https://forms.gle/vUoarawnYjy3hXJi9) to report bugs. Feature requests may still use the issues tab

~ Hev

# VelocityPlus
A collection of small QOL changes and additions.

> [!WARNING]
> HevLib may be required for some features to function.
> A download can be found from it's [releases page](https://github.com/rwqfsfasxc100/HevLib/releases/latest)

## Features
* All non-keybind toggles supported by Mod Menu

* Adds a label containing the total value of ore stored in the mineral market (Defaults to enabled)
  * Parity fix for [issue #5033](https://git.kodera.pl/games/delta-v/-/issues/5033)
* Adds the ability to adjust the shader style of the Minding Virtual Flight Service
  * Ported from and expanded from the No Simulation Hex mod
  * Remove HEX - disables the HEX shader overlay (Default)
  * Remove HEX and BG - disables the HEX shader and replaces the background with a solid black base
  * Equipment preview shader - swaps out the shader to make the MVFS appear like the equipment previews
* Allows the removal of crew portraits
  * Ported from the No Crew Portraits mod
  * Allows the portraits at Enceladus and in OMS to be toggled independently of each other
  * Disabled by default 
* Adds empty cradle equipment for 50k E$
  * **Requires HevLib to be installed to function**
  * Parity fix for [issue #5133](https://git.kodera.pl/games/delta-v/-/issues/5133)
* Flips the Voyager 180 degrees in OCP holds (Defaults to enabled)
  * Ported from the OCP Voyager Fix mod
* Removes the 200 m/s velocity limit (Defaults to enabled)
  * Ported from the Remove Ring Restrictions mod
* Removes the automatic return to Enceladus by exiting the ring (negative depth) (Defaults to enabled)
  * Ported from the Remove Ring Restrictions mod
* Removes the automatic return to Enceladus by entering the Encke Gap (3005km) (Defaults to enabled)
  * Ported from the Remove Ring Restrictions mod
* Variates the time of broadcast-like astrogation targets (Defaults to enabled)
  * **Requires HevLib to be installed to function**
  * Ported from the RingActivity mod
  * Broadcast-like astro targets include: locations provided by crew, locations provided by miner crews, SRO broadcasts, pirate container and ship locations.
* Allows the fixing of gimballed and turreted equipment in place (Defaults to disabled)
* Hud can be quickly hidden from view with a keybind
  * Ported from the HUD Hider mod
  * Defaults to F6
* Repair menu now only displays equipment not at 100%.
  * Enabled by default
  * Parity fix for [issue #5241](https://git.kodera.pl/games/delta-v/-/issues/5241)
* Added tooltips to repair and dealership menus to help explain disabled buttons
  * Enabled by default
  * Parity fix for [issue #5284](https://git.kodera.pl/games/delta-v/-/issues/5284)
