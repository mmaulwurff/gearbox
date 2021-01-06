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

class gb_WeaponMenu
{

  static
  gb_WeaponMenu from(gb_WeaponData weaponData)
  {
    let result = new("gb_WeaponMenu");
    result.mWeapons.move(weaponData.weapons);
    result.mSlots.move(weaponData.slots);
    result.mSelectedIndex = 0;
    return result;
  }

  int getSelectedIndex() const
  {
    return mSelectedIndex;
  }

  void setSelectedIndexFromView(gb_ViewModel viewModel, int index)
  {
    if (index == -1)
    {
      return;
    }

    mSelectedIndex = viewModel.indices[index];
  }

  void setSelectedWeapon(class<Weapon> aClass)
  {
    mSelectedIndex = getIndexOf(aClass);
    // Fixes the case when the player starts with no weapon selected.
    // Gearbox will still misbehave if there is no weapons at all.
    // We'll see if such a situation happens in reality.
    if (mSelectedIndex == mWeapons.size()) selectNextWeapon();
  }

  void selectNextWeapon()
  {
    mSelectedIndex = findNextWeapon();
  }

  void selectPrevWeapon()
  {
    mSelectedIndex = findPrevWeapon();
  }

  bool selectSlot(int slot)
  {
    uint nWeapons = mWeapons.size();
    for (uint i = 1; i < nWeapons; ++i)
    {
      uint index = (mSelectedIndex + nWeapons - i) % nWeapons;
      if (mSlots[index] == slot && players[consolePlayer].mo.findInventory(mWeapons[index]))
      {
        mSelectedIndex = index;
        return true;
      }
    }

    return false;
  }

  bool isOneWeaponInSlot(int slot) const
  {
    uint nWeapons = mWeapons.size();
    int  nWeaponsInSlot = 0;
    for (uint i = 1; i < nWeapons; ++i)
    {
      uint index = (mSelectedIndex + nWeapons - i) % nWeapons;
      nWeaponsInSlot += (mSlots[index] == slot);
      if (nWeaponsInSlot > 1) return false;
    }
    if (nWeaponsInSlot == 0) return false;
    return true;
  }

  string confirmSelection()
  {
    if (mSelectedIndex >= mWeapons.size()) return "";

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

      if (mSelectedIndex == i) viewModel.selectedWeaponIndex = viewModel.tags.size();

      let default = getDefaultByType(mWeapons[i]);

      viewModel.tags.push(default.getTag());
      viewModel.slots.push(mSlots[i]);
      viewModel.indices.push(i);

      TextureID icon = StatusBar.GetInventoryIcon(aWeapon, StatusBar.DI_ALTICONFIRST);

      if (!icon.isValid()) icon = TexMan.checkForTexture("gb_nope", TexMan.Type_Any);

      // Workaround, casting TextureID to int may be unreliable.
      viewModel.icons.push(int(icon));

      bool hasAmmo1 = aWeapon.ammo1;
      bool hasAmmo2 = aWeapon.ammo2 && aWeapon.ammo2 != aWeapon.ammo1;

      viewModel.   ammo1.push(hasAmmo1 ? aWeapon.ammo1.   amount : -1);
      viewModel.maxAmmo1.push(hasAmmo1 ? aWeapon.ammo1.maxAmount : -1);
      viewModel.   ammo2.push(hasAmmo2 ? aWeapon.ammo2.   amount : -1);
      viewModel.maxAmmo2.push(hasAmmo2 ? aWeapon.ammo2.maxAmount : -1);
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private play State getReadyState(Weapon w) const { return w.getReadyState(); }

  private uint findNextWeapon() const { return findWeapon( 1); }
  private uint findPrevWeapon() const { return findWeapon(-1); }

  /**
   * @param direction search direction from the selected weapon: 1 or -1.
   *
   * @returns a weapon in the direction. If there is only one weapon, return
   * it. If there are no weapons, return weapons number.
   */
  private
  uint findWeapon(int direction) const
  {
    let player = players[consolePlayer].mo;

    uint nWeapons = mWeapons.size();
    // Note range: [1; nWeapons + 1) instead of [0; nWeapons).
    // This is because I want the current weapon to be found last.
    for (uint i = 1; i < nWeapons + 1; ++i)
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

  private Array< class<Weapon> > mWeapons;
  private Array< int >           mSlots;
  private uint mSelectedIndex;

} // class gb_WeaponMenu
