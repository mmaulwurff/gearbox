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

class gb_WeaponMenu
{

  static
  gb_WeaponMenu from(gb_WeaponData weaponData)
  {
    let result = new("gb_WeaponMenu");
    result.mWeapons.move(weaponData.weapons);
    result.mSlots.move(weaponData.slots);
    return result;
  }

  void setSelectedWeapon(class<Weapon> aClass)
  {
    mSelectedIndex = getIndexOf(aClass);
  }

  void selectNextWeapon()
  {
    mSelectedIndex = findNextWeapon();
  }

  string confirmSelection()
  {
    return getDefaultByType(mWeapons[mSelectedIndex]).getClassName();
  }

  void fill(out gb_ViewModel viewModel)
  {
    uint nWeapons = mWeapons.size();
    for (uint i = 0; i < nWeapons; ++i)
    {
      if (!players[consolePlayer].mo.findInventory(mWeapons[i])) continue;

      if (mSelectedIndex == i) viewModel.selectedWeaponIndex = viewModel.tags.size();

      let default = getDefaultByType(mWeapons[i]);

      viewModel.tags.push(default.getTag());
      viewModel.icons.push(getIcon(default));
      viewModel.slots.push(mSlots[i]);

      viewModel.   ammo1.push(default.ammo1 ? default.ammo1.   amount : -1);
      viewModel.maxAmmo1.push(default.ammo1 ? default.ammo1.maxAmount : -1);
      viewModel.   ammo2.push(default.ammo2 ? default.ammo2.   amount : -1);
      viewModel.maxAmmo2.push(default.ammo2 ? default.ammo2.maxAmount : -1);
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  string getIcon(readonly<Weapon> aWeapon)
  {
    TextureID iconID = aWeapon.SpawnState.GetSpriteTexture(0);
    string    result = TexMan.GetName(iconID);

    string placeholder = "NOWEAPONOFF";

    if (result == "TNT1A0")   { result = TexMan.GetName(aWeapon.icon); }
    if (result == "TNT1A0")   { result = placeholder; }
    if (result == "ALTHUDCF") { result = placeholder; }

    return result;
  }

  private
  uint findNextWeapon() const
  {
    let player = players[consolePlayer].mo;

    uint nWeapons = mWeapons.size();
    for (uint i = 1; i < nWeapons; ++i)
    {
      uint index = (mSelectedIndex + i) % nWeapons;
      if (player.findInventory(mWeapons[index])) return index;
    }

    return nWeapons;
  }

  private
  uint getIndexOf(class<Weapon> aClass) const
  {
    uint nWeapons = mWeapons.size();
    for (uint i = 0; i < nWeapons; ++i)
    {
      if (mWeapons[i] == aClass) return i;
    }
    return nWeapons;
  }

  Array< class<Weapon> > mWeapons;
  Array< int >           mSlots;
  uint mSelectedIndex;

} // class gb_WeaponMenu
