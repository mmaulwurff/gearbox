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

      // slot number box
      if (slot != lastDrawnSlot)
      {
        Screen.drawTexture( boxTexture
                          , NO_ANIMATION
                          , slotX
                          , BORDER
                          , DTA_FillColor    , 0x0000AA
                          , DTA_AlphaChannel , true
                          );

        string slotText = string.format("%d", slot);
        int    textX    = slotX + SLOT_SIZE / 2 - aFont.stringWidth(slotText) / 2;

        Screen.drawText(aFont, Font.CR_WHITE, textX, textY, slotText);

        lastDrawnSlot = slot;
      }

      if (slot == selectedSlot) // selected slot (big boxes)
      {
        bool isSelectedWeapon = (i == viewModel.selectedWeaponIndex);
        int  weaponColor      = isSelectedWeapon ? 0x6666CC : 0x2222CC;
        int  weaponY = BORDER + SLOT_SIZE + (SELECTED_WEAPON_HEIGHT + MARGIN) * inSlotIndex;

        // big box
        Screen.drawTexture( bigTexture
                          , NO_ANIMATION
                          , slotX
                          , weaponY
                          , DTA_FillColor    , weaponColor
                          , DTA_AlphaChannel , true
                          );

        // weapon
        {
          Screen.setClipRect(slotX, weaponY, SELECTED_SLOT_WIDTH, SELECTED_WEAPON_HEIGHT);
          TextureID weaponTexture = TexMan.checkForTexture(viewModel.icons[i], TexMan.Type_Any);
          Screen.drawTexture( weaponTexture
                            , NO_ANIMATION
                            , slotX + SELECTED_SLOT_WIDTH / 2
                            , weaponY + SELECTED_WEAPON_HEIGHT / 2
                            , DTA_CenterOffset, true
                            );
          Screen.clearClipRect();
        }

        // corners
        if (isSelectedWeapon)
        {
          vector2 lineEnd = (slotX, weaponY) + (SELECTED_SLOT_WIDTH, SELECTED_WEAPON_HEIGHT);
          int lineColor = 0xEEEEEE;
          // top left
          Screen.drawLine(slotX,     weaponY, slotX + CORNER_SIZE, weaponY, lineColor);
          Screen.drawLine(slotX + 1, weaponY, slotX, weaponY + CORNER_SIZE, lineColor);
          // top right
          Screen.drawLine(lineEnd.x, weaponY, lineEnd.x - CORNER_SIZE, weaponY, lineColor);
          Screen.drawLine(lineEnd.x, weaponY, lineEnd.x, weaponY + CORNER_SIZE, lineColor);
          // bottom left
          Screen.drawLine(slotX, lineEnd.y - 1, slotX + CORNER_SIZE, lineEnd.y, lineColor);
          Screen.drawLine(slotX + 1, lineEnd.y, slotX, lineEnd.y - CORNER_SIZE, lineColor);
          // bottom right
          Screen.drawLine(lineEnd.x, lineEnd.y - 1, lineEnd.x - CORNER_SIZE, lineEnd.y, lineColor);
          Screen.drawLine(lineEnd.x, lineEnd.y,     lineEnd.x, lineEnd.Y - CORNER_SIZE, lineColor);
        }

        // ammo indicators
        if (viewModel.ammo1[i] != -1)
        {
          Screen.drawThickLine( slotX + MARGIN * 2
                              , weaponY + AMMO_HEIGHT / 2
                              , slotX + MARGIN + AMMO_WIDTH
                              , weaponY + AMMO_HEIGHT / 2
                              , AMMO_HEIGHT
                              , 0x8888DD
                              );
          int ammoRatioWidth = round(float(viewModel.ammo1[i]) / viewModel.maxAmmo1[i] * AMMO_WIDTH);
          Screen.drawThickLine( slotX + MARGIN * 2
                              , weaponY + AMMO_HEIGHT / 2
                              , slotX + MARGIN + ammoRatioWidth
                              , weaponY + AMMO_HEIGHT / 2
                              , AMMO_HEIGHT
                              , 0x22DD22
                              );
        }
      }
      else // unselected slot (small boxes)
      {
        Screen.drawTexture( boxTexture
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

  const SLOT_SIZE = 25;
  const SELECTED_SLOT_WIDTH = 100;
  const SELECTED_WEAPON_HEIGHT = SLOT_SIZE * 2 + MARGIN;

  const NO_ANIMATION = 0; // == false

  const CORNER_SIZE = 4;

  const AMMO_WIDTH = 40;
  const AMMO_HEIGHT = 6;

} // class gb_HalfLifeView
