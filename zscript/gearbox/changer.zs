/* Copyright Alexander Kromm (mmaulwurff@gmail.com) 2020-2021
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
  gb_Changer from(gb_Caption caption, gb_Options options)
  {
    let result = new("gb_Changer");
    result.mCaption = caption;
    result.mOptions = options;
    return result;
  }

  void change(gb_Change aChange)
  {
    PlayerInfo player = players[aChange.playerNumber];

    switch (aChange.type)
    {
    case gb_Change.SelectWeapon: selectWeapon(player, aChange.object); break;
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  void selectWeapon(PlayerInfo player, string weapon)
  {
    Weapon targetWeapon = Weapon(player.mo.findInventory(weapon));
    if (targetWeapon && gb_WeaponWatcher.currentFor(player) != targetWeapon.getClass())
    {
      player.pendingWeapon = targetWeapon;
      if (mOptions.isShowingWeaponTagsOnChange()) mCaption.setCaption(targetWeapon.getTag());
    }
  }

  private gb_Caption mCaption;
  private gb_Options mOptions;

} // class gb_Changer
