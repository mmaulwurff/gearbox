/* Copyright Alexander Kromm (mmaulwurff@gmail.com) 2020-2021
 * SandPoot 2025
 *
 * This file is part of Gearbox.
 *
 * Gearbox is free software: you can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Gearbox is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Gearbox.  If not, see <https://www.gnu.org/licenses/>.
 */

class gb_Sender
{

  static
  void sendSelectEvent(string className)
  {
    EventHandler.sendNetworkEvent(string.format("gb_select_weapon:%s", className));
  }

  static
  void sendUseItemEvent(string className)
  {
    EventHandler.sendNetworkEvent(string.format("gb_use_item:%s", className));
  }

  static
  void sendDropItemEvent(string className)
  {
    EventHandler.sendNetworkEvent(string.format("gb_drop_item:%s", className));
  }

  static
  void sendFreezePlayerEvent(int cheats, vector3 velocity, double gravity)
  {
    EventHandler.sendNetworkEvent(string.format( "gb_freeze_player:%d:%f:%f:%f:%f"
                                               , cheats
                                               , velocity.x
                                               , velocity.y
                                               , velocity.z
                                               , gravity
                                               ));
  }

  static
  void sendPlayerAngles(double pitch, double yaw)
  {
    EventHandler.sendNetworkEvent("gb_set_angles:" .. pitch .. ":" .. yaw);
  }

} // class gb_Sender
