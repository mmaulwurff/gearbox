/* Copyright Alexander Kromm (mmaulwurff@gmail.com) 2021
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

class gb_InventoryMenu
{

  static
  gb_InventoryMenu from(gb_Sounds sounds, gb_IconProvider iconProvider, gb_Options options)
  {
    let result = new("gb_InventoryMenu");

    result.mSelectedIndex = 0;
    result.mSounds = sounds;
    result.mIconProvider = iconProvider;
    result.mOptions = options;

    return result;
  }

  string confirmSelection() const
  {
    let item  = players[consolePlayer].mo.inv;
    int index = 0;
    while (item != NULL)
    {
      if (item.bInvBar)
      {
        if (index == mSelectedIndex) return item.getClassName();
        ++index;
      }
      item = item.inv;
    }

    return "";
  }

  ui
  void selectNext()
  {
    int nItems = getItemsNumber();
    if (nItems == 0) return;

    mSounds.playTick();
    mSelectedIndex = (mSelectedIndex + 1) % nItems;
  }

  ui
  void selectPrev()
  {
    int nItems = getItemsNumber();
    if (nItems == 0) return;

    mSounds.playTick();
    mSelectedIndex = (mSelectedIndex - 1 + nItems) % nItems;
  }

  ui
  void setSelectedIndex(int index)
  {
    if (index == -1 || mSelectedIndex == index) return;

    mSounds.playTick();
    mSelectedIndex = index;
  }

  ui
  int getSelectedIndex() const
  {
    return mSelectedIndex;
  }

  ui
  void fill(out gb_ViewModel viewModel)
  {
    let item  = players[consolePlayer].mo.inv;
    int index = 0;
    while (item != NULL)
    {
      if (item.bInvBar)
      {
        TextureID icon;
        int textureType;
        [icon, textureType] = mIconProvider.getTextureFor(item);

        vector2 iconSize = TexMan.getScaledSize(icon);
        if (textureType == gb_IconProvider.TextureSpawn)
        {
          iconSize.x *= item.scale.x;
          iconSize.y *= item.scale.y;
        }

        if (mOptions.isTallItems())
        {
          iconSize.y *= 1.2;
        }

        viewModel.tags        .push(item.getTag());
        viewModel.slots       .push(index + 1);
        viewModel.indices     .push(index);
        viewModel.icons       .push(int(icon));
        viewModel.iconWidths  .push(iconSize.x);
        viewModel.iconHeights .push(iconSize.y);
        viewModel.iconBigs    .push(false);
        viewModel.quantity1   .push(item.maxAmount > 1 ? item.amount : -1);
        viewModel.maxQuantity1.push(item.maxAmount);
        viewModel.quantity2   .push(-1);
        viewModel.maxQuantity2.push(-1);

        ++index;
      }
      item = item.inv;
    }

    mSelectedIndex = min(mSelectedIndex, getItemsNumber() - 1);
    if (mSelectedIndex == -1 && getItemsNumber() > 0) mSelectedIndex = 0;
    viewModel.selectedIndex = mSelectedIndex;
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private static
  int getItemsNumber()
  {
    let item   = players[consolePlayer].mo.inv;
    int result = 0;
    while (item != NULL)
    {
      result += item.bInvBar;
      item = item.inv;
    }
    return result;
  }

  private int mSelectedIndex;
  private gb_Sounds mSounds;
  private gb_IconProvider mIconProvider;
  private gb_Options mOptions;

} // class gb_InventoryMenu
