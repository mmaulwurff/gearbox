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
    result.mCacheTime     = 0;
    loadIconServices(result.mIconServices);
    loadHideServices(result.mHideServices);
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
      if (mSlots[index] == slot && isInInventory(index))
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
      nWeaponsInSlot += (mSlots[index] == slot && isInInventory(index));
      if (nWeaponsInSlot > 1) return false;
    }
    if (nWeaponsInSlot == 0) return false;
    return true;
  }

  bool isInInventory(int index) const
  {
    return NULL != players[consolePlayer].mo.findInventory(mWeapons[index]);
  }

  string confirmSelection()
  {
    if (mSelectedIndex >= mWeapons.size()) return "";

    return getDefaultByType(mWeapons[mSelectedIndex]).getClassName();
  }

  ui
  void fill(out gb_ViewModel viewModel)
  {
    // every other tic.
    bool isCacheValid = (level.time <= mCacheTime + 1);
    if (!isCacheValid)
    {
      mCacheTime = level.time;
      mCachedViewModel.tags.clear();
      mCachedViewModel.slots.clear();
      mCachedViewModel.indices.clear();
      mCachedViewModel.icons.clear();
      mCachedViewModel.ammo1.clear();
      mCachedViewModel.maxAmmo1.clear();
      mCachedViewModel.ammo2.clear();
      mCachedViewModel.maxAmmo2.clear();
      fillDirect(mCachedViewModel);
    }

    copy(mCachedViewModel, viewModel);
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private ui
  void copy(gb_ViewModel source, out gb_ViewModel destination)
  {
    source.selectedWeaponIndex = destination.selectedWeaponIndex;

    destination.tags.copy(source.tags);
    destination.slots.copy(source.slots);
    destination.indices.copy(source.indices);
    destination.icons.copy(source.icons);
    destination.ammo1.copy(source.ammo1);
    destination.maxAmmo1.copy(source.maxAmmo1);
    destination.ammo2.copy(source.ammo2);
    destination.maxAmmo2.copy(source.maxAmmo2);
  }

  private ui
  void fillDirect(out gb_ViewModel viewModel)
  {
    uint nWeapons = mWeapons.size();
    for (uint i = 0; i < nWeapons; ++i)
    {
      let aWeapon = Weapon(players[consolePlayer].mo.findInventory(mWeapons[i]));
      if (aWeapon == NULL || isHidden(aWeapon)) continue;

      if (mSelectedIndex == i) viewModel.selectedWeaponIndex = viewModel.tags.size();

      let default = getDefaultByType(mWeapons[i]);

      viewModel.tags.push(default.getTag());
      viewModel.slots.push(mSlots[i]);
      viewModel.indices.push(i);

      TextureID icon = getIconFor(aWeapon);

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

  private ui
  bool isHidden(Weapon aWeapon) const
  {
    bool result = false;

    uint nServices = mHideServices.size();
    string className = aWeapon.getClassName();
    for (uint i = 0; i < nServices; ++i)
    {
      let service = mHideServices[i];
      string hideResponse = service.uiGet(className);
      if (hideResponse.length() != 0)
      {
        bool isHidden = hideResponse.byteAt(0) - 48; // convert to bool from "0" or "1".
        result = isHidden;
      }
    }

    return result;
  }

  private ui
  TextureID getIconFor(Weapon aWeapon) const
  {
    TextureID icon = StatusBar.GetInventoryIcon(aWeapon, StatusBar.DI_ALTICONFIRST);

    {
      uint nServices = mIconServices.size();
      string className = aWeapon.getClassName();
      for (uint i = 0; i < nServices; ++i)
      {
        let service = mIconServices[i];
        string iconResponse = service.uiGet(className);
        if (iconResponse.length() != 0)
        {
          TextureID iconFromService = TexMan.checkForTexture(iconResponse, TexMan.Type_Any);
          if (iconFromService.isValid()) icon = iconFromService;
        }
      }
    }

    if (!icon.isValid()) icon = TexMan.checkForTexture("gb_nope", TexMan.Type_Any);

    return icon;
  }

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

  private static
  void loadIconServices(out Array<gb_Service> services)
  {
    loadServices("gb_IconService", services);
  }

  private static
  void loadHideServices(out Array<gb_Service> services)
  {
    loadServices("gb_HideService", services);
  }

  private static
  void loadServices(string serviceName, out Array<gb_Service> services)
  {
    let iterator = gb_ServiceIterator.find(serviceName);
    gb_Service aService;
    while (aService = iterator.next())
    {
      services.push(aService);
    }
  }

  private Array< class<Weapon> > mWeapons;
  private Array< int >           mSlots;
  private uint mSelectedIndex;

  private Array<gb_Service> mIconServices;
  private Array<gb_Service> mHideServices;

  private gb_ViewModel mCachedViewModel;
  private int          mCacheTime;

} // class gb_WeaponMenu
