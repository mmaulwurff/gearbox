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

  void setSelectedIndex(int index)
  {
    mSelectedIndex = index;
  }

  void setSelectedWeapon(class<Weapon> aClass)
  {
    mSelectedIndex = getIndexOf(aClass);
  }

  void selectNextWeapon()
  {
    mSelectedIndex = findNextWeapon();
  }

  void selectPrevWeapon()
  {
    mSelectedIndex = findPrevWeapon();
  }

  string confirmSelection()
  {
    return getDefaultByType(mWeapons[mSelectedIndex]).getClassName();
  }

  ui
  void fill(out gb_ViewModel viewModel)
  {
    uint nWeapons = mWeapons.size();
    for (uint i = 0; i < nWeapons; ++i)
    {
      let aWeapon = Weapon(players[consolePlayer].mo.findInventory(mWeapons[i]));
      if (aWeapon == NULL) continue;

      console.printf("here %d", mSelectedIndex);
      if (mSelectedIndex == i) viewModel.selectedWeaponIndex = viewModel.tags.size();

      let default = getDefaultByType(mWeapons[i]);

      viewModel.tags.push(default.getTag());
      viewModel.slots.push(mSlots[i]);

      // Workaround, casting TextureID to int may break.
      TextureID icon = StatusBar.GetInventoryIcon(aWeapon, StatusBar.DI_ALTICONFIRST);

      if (!icon.isValid()) icon = TexMan.checkForTexture("gb_nope", TexMan.Type_Any);

      viewModel.icons.push(int(icon));
      //viewModel.iconOrientations.push(icon == getReadyState(aWeapon).getSpriteTexture(0));
      viewModel.iconOrientations.push(icon == aWeapon.icon);

      console.printf("%s, %d", viewModel.tags[i], viewModel.iconOrientations[i]);

      viewModel.   ammo1.push(aWeapon.ammo1 ? aWeapon.ammo1.   amount : -1);
      viewModel.maxAmmo1.push(aWeapon.ammo1 ? aWeapon.ammo1.maxAmount : -1);
      viewModel.   ammo2.push(aWeapon.ammo2 ? aWeapon.ammo2.   amount : -1);
      viewModel.maxAmmo2.push(aWeapon.ammo2 ? aWeapon.ammo2.maxAmount : -1);
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private play State getReadyState(Weapon w) const { return w.getReadyState(); }

  private uint findNextWeapon() const { return findWeapon( 1); }
  private uint findPrevWeapon() const { return findWeapon(-1); }

  /**
   * @param direction search direction from the selected weapon: 1 or -1.
   */
  private
  uint findWeapon(int direction)
  {
    let player = players[consolePlayer].mo;

    uint nWeapons = mWeapons.size();
    for (uint i = 1; i < nWeapons; ++i)
    {
      uint index = (mSelectedIndex + i * direction + nWeapons) % nWeapons;
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
