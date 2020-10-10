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

class gb_HalfLifeView
{

  static
  gb_HalfLifeView from()
  {
    let result = new("gb_HalfLifeView");
    return result;
  }

  void display(gb_ViewModel viewModel, double fracTic)
  {
    drawSlot(viewModel);
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  void drawSlot(gb_ViewModel viewModel)
  {
    int lastDrawnSlot = 0;
    int slotX = BORDER;
    int inSlotIndex = 0;

    int selectedSlot = viewModel.slots[viewModel.selectedWeaponIndex];
    TextureID boxTexture = TexMan.checkForTexture("gb_box",  TexMan.Type_Any);
    TextureID bigTexture = TexMan.checkForTexture("gb_weap", TexMan.Type_Any);

    Font aFont = "NewSmallFont";
    int fontHeight = aFont.getHeight();
    int textY = BORDER + SLOT_SIZE / 2 - fontHeight / 2;

    uint nWeapons = viewModel.tags.size();
    for (uint i = 0; i < nWeapons; ++i)
    {
      int slot = viewModel.slots[i];

      if (slot != lastDrawnSlot)
      {
        screen.drawTexture( boxTexture
                          , NO_ANIMATION
                          , slotX
                          , BORDER
                          , DTA_FillColor    , 0x0000AA
                          , DTA_AlphaChannel , true
                          );

        string slotText = string.format("%d", slot);
        int    textX    = slotX + SLOT_SIZE / 2 - aFont.stringWidth(slotText) / 2;

        screen.drawText(aFont, Font.CR_WHITE, textX, textY, slotText);

        lastDrawnSlot = slot;
      }

      if (slot == selectedSlot)
      {
        screen.drawTexture( bigTexture
                          , NO_ANIMATION
                          , slotX
                          , BORDER + SLOT_SIZE + (SELECTED_WEAPON_HEIGHT + MARGIN) * (inSlotIndex)
                          , DTA_FillColor    , 0x2222CC
                          , DTA_AlphaChannel , true
                          );
      }
      else
      {
        screen.drawTexture( boxTexture
                          , NO_ANIMATION
                          , slotX
                          , BORDER - MARGIN + (SLOT_SIZE + MARGIN) * (inSlotIndex + 1)
                          , DTA_FillColor    , 0x2222CC
                          , DTA_AlphaChannel , true
                          );
      }

      if (i + 1 < nWeapons && viewModel.slots[i + 1] != slot)
      {
        slotX += ((slot == selectedSlot) ? SELECTED_SLOT_WIDTH : SLOT_SIZE) + MARGIN;
        inSlotIndex = 0;
      }
      else
      {
        ++inSlotIndex;
      }
    }
  }

  const BORDER = 20;
  const MARGIN = 4;

  const SLOT_SIZE = 50;
  const SELECTED_SLOT_WIDTH = 200;
  const SELECTED_WEAPON_HEIGHT = SLOT_SIZE * 2 + MARGIN;

  const NO_ANIMATION = 0; // == false

} // class gb_HalfLifeView
