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

struct gb_MultiWheelModel
{
  Array<bool> isWeapon;
  Array<int>  data; // slot or weapon index
}

class gb_MultiWheel
{

  static
  void fill(gb_ViewModel viewModel, out gb_MultiWheelModel model)
  {
    uint nWeapons = viewModel.tags.size();
    int  lastSlot = -1;

    for (uint i = 0; i < nWeapons; ++i)
    {
      int  slot     = viewModel.slots[i];
      bool isSingle = isSingleWeaponInSlot(viewModel, nWeapons, slot);
      if (isSingle)
      {
        model.isWeapon.push(true);
        model.data.push(i);
      }
      else
      {
        if (slot != lastSlot)
        {
          lastSlot = slot;
          model.isWeapon.push(false);
          model.data.push(slot);
        }
      }
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private static
  bool isSingleWeaponInSlot(gb_ViewModel viewModel, uint nWeapons, int slot)
  {
    int nWeaponsInSlot = 0;
    for (uint i = 0; i < nWeapons; ++i)
    {
      nWeaponsInSlot += (viewModel.slots[i] == slot);
      if (nWeaponsInSlot > 1) return false;
    }
    return true;
  }

} // class gb_MultiWheel

class gb_WheelIndexer
{

  static
  gb_WheelIndexer from()
  {
    let result = new("gb_WheelIndexer");
    return result;
  }

  int getSelectedIndex(gb_ViewModel viewModel, gb_WheelControllerModel controllerModel)
  {
    if (controllerModel.radius < DEAD_RADIUS)
    {
      return -1;
    }

    uint nWeapons       = viewModel.tags.size();
    bool multiWheelMode = (nWeapons > 12);

    if (!multiWheelMode)
    {
      return gb_WheelInnerIndexer.getSelectedIndex(nWeapons, controllerModel);
    }

    gb_MultiWheelModel multiWheelModel;
    gb_MultiWheel.fill(viewModel, multiWheelModel);

    uint nPlaces = multiWheelModel.data.size();

    if (controllerModel.radius < WHEEL_RADIUS)
    {
      int  innerIndex = gb_WheelInnerIndexer.getSelectedIndex(nPlaces, controllerModel);
      bool isWeapon   = multiWheelModel.isWeapon[innerIndex];

      return isWeapon ? multiWheelModel.data[innerIndex] : -1;
    }
    else
    {
//      if (mLastSlot == -1) return -1;
//
//      uint start = 0;
//      for (; start < nWeapons && viewModel.slots[start] != slot; ++start);
//      uint end = start;
//      for (; end < nWeapons && viewModel.slots[end] == slot; ++end);
//
//      uint nWeaponsInSlot = end - start;
//
//      double slotAngle = itemAngle(nPlaces, );

      return -1;
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private static
  double itemAngle(uint nItems, uint index)
  {
    return 360.0 / nItems * index;
  }

  const DEAD_RADIUS  = 67;
  const WHEEL_RADIUS = 270;

} // class gb_WheelIndexer
