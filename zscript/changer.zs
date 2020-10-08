/* Copyright Alexander Kromm (mmaulwurff@gmail.com) 2020
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

class gb_Changer play
{

  static
  void change(gb_Change aChange)
  {
    PlayerInfo player = players[aChange.playerNumber];

    switch (aChange.type)
    {
    case gb_Change.SelectWeapon: selectWeapon(player, aChange.object); break;
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private static
  void selectWeapon(PlayerInfo player, string weapon)
  {
    Weapon targetWeapon = Weapon(player.mo.findInventory(weapon));
    if (gb_WeaponWatcher.getCurrentWeapon(player) != targetWeapon.getClass())
    {
      player.pendingWeapon = targetWeapon;
    }
  }

} // class gb_Changer
