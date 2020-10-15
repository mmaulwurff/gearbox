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

class gb_BlockyView
{

  static
  gb_BlockyView from()
  {
    let result = new("gb_BlockyView");
    result.setAlpha(1.0);
    result.setScale(1);
    result.setBaseColor(0x2222CC);
    return result;
  }

  void setAlpha(double alpha)
  {
    mAlpha    = alpha;
    mIntAlpha = int(alpha * 255);
  }

  void setScale(int scale)
  {
    if (scale < 1) scale = 1;

    mScale        = scale;
    mScreenWidth  = Screen.getWidth()  / mScale;
    mScreenHeight = Screen.getHeight() / mScale;
  }

  void setBaseColor(int color)
  {
    mBaseColor     = color;
    mSlotColor     = addColor(mBaseColor, -0x22, -0x22, -0x22);
    mSelectedColor = addColor(mBaseColor,  0x44,  0x44,     0);
    mAmmoBackColor = addColor(mBaseColor,  0x66,  0x66,  0x11);
  }

  void display(gb_ViewModel viewModel) const
  {
    int lastDrawnSlot = 0;
    int slotX = BORDER;
    int inSlotIndex = 0;

    int selectedSlot = viewModel.slots[viewModel.selectedWeaponIndex];
    TextureID boxTexture = TexMan.checkForTexture("gb_box",  TexMan.Type_Any);
    TextureID bigTexture = TexMan.checkForTexture("gb_weap", TexMan.Type_Any);

    Font aFont      = "NewSmallFont";
    int  fontHeight = aFont.getHeight();
    int  textY      = BORDER + SLOT_SIZE / 2 - fontHeight / 2;

    uint nWeapons = viewModel.tags.size();
    for (uint i = 0; i < nWeapons; ++i)
    {
      int slot = viewModel.slots[i];

      // slot number box
      if (slot != lastDrawnSlot)
      {
        drawAlphaTexture(boxTexture, slotX, BORDER, mSlotColor);

        string slotText = string.format("%d", slot);
        int    textX    = slotX + SLOT_SIZE / 2 - aFont.stringWidth(slotText) / 2;

        drawText(aFont, Font.CR_WHITE, textX, textY, slotText);

        lastDrawnSlot = slot;
      }

      if (slot == selectedSlot) // selected slot (big boxes)
      {
        bool isSelectedWeapon = (i == viewModel.selectedWeaponIndex);
        int  weaponColor      = isSelectedWeapon ? mSelectedColor : mBaseColor;
        int  weaponY = BORDER + SLOT_SIZE + (SELECTED_WEAPON_HEIGHT + MARGIN) * inSlotIndex;

        // big box
        drawAlphaTexture(bigTexture, slotX, weaponY, weaponColor);

        // weapon
        {
          // code is adapted from GZDoom AltHud.DrawImageToBox.
          TextureID weaponTexture = TexMan.checkForTexture(viewModel.icons[i], TexMan.Type_Any);
          let weaponSize = TexMan.getScaledSize(weaponTexture);

          int allowedWidth  = SELECTED_SLOT_WIDTH    - MARGIN * 2;
          int allowedHeight = SELECTED_WEAPON_HEIGHT - MARGIN * 2;

          double scaleHor = (allowedWidth  < weaponSize.x) ? allowedWidth  / weaponSize.x : 1.0;
          double scaleVer = (allowedHeight < weaponSize.y) ? allowedHeight / weaponSize.y : 1.0;
          double scale    = min(scaleHor, scaleVer);

          int weaponWidth  = round(weaponSize.x * scale);
          int weaponHeight = round(weaponSize.y * scale);

          drawWeapon( weaponTexture
                    , slotX + SELECTED_SLOT_WIDTH / 2
                    , weaponY + SELECTED_WEAPON_HEIGHT / 2
                    , weaponWidth
                    , weaponHeight
                    );
        }

        // corners
        if (isSelectedWeapon)
        {
          int lineEndX = slotX   + SELECTED_SLOT_WIDTH    - CORNER_SIZE;
          int lineEndY = weaponY + SELECTED_WEAPON_HEIGHT - CORNER_SIZE;
          TextureID cornerTexture = TexMan.checkForTexture("gb_cor", TexMan.Type_Any);
          // top left, top right, bottom left, bottom right
          drawFlippedTexture(cornerTexture, slotX,    weaponY,  NoHorizontalFlip, NoVerticalFlip);
          drawFlippedTexture(cornerTexture, lineEndX, weaponY,    HorizontalFlip, NoVerticalFlip);
          drawFlippedTexture(cornerTexture, slotX,    lineEndY, NoHorizontalFlip,   VerticalFlip);
          drawFlippedTexture(cornerTexture, lineEndX, lineEndY,   HorizontalFlip,   VerticalFlip);
        }

        // ammo indicators
        TextureID ammoTexture = TexMan.checkForTexture("gb_ammo", TexMan.Type_Any);
        int ammoY = weaponY;
        if (viewModel.ammo1[i] != -1)
        {
          drawAlphaTexture( ammoTexture
                          , slotX + MARGIN * 2
                          , ammoY
                          , mAmmoBackColor
                          );
          int ammoRatioWidth = round(float(viewModel.ammo1[i]) / viewModel.maxAmmo1[i] * AMMO_WIDTH);
          drawAlphaWidthTexture( ammoTexture
                               , slotX + MARGIN * 2
                               , ammoY
                               , FILLED_AMMO_COLOR
                               , ammoRatioWidth
                               );
          ammoY += MARGIN + AMMO_HEIGHT;
        }
        if (viewModel.ammo2[i] != -1)
        {
          drawAlphaTexture( ammoTexture
                          , slotX + MARGIN * 2
                          , ammoY
                          , mAmmoBackColor
                          );
          int ammoRatioWidth = round(float(viewModel.ammo2[i]) / viewModel.maxAmmo2[i] * AMMO_WIDTH);
          drawAlphaWidthTexture( ammoTexture
                               , slotX + MARGIN * 2
                               , ammoY
                               , FILLED_AMMO_COLOR
                               , ammoRatioWidth
                               );
        }
      }
      else // unselected slot (small boxes)
      {
        int boxY = BORDER - MARGIN + (SLOT_SIZE + MARGIN) * (inSlotIndex + 1);
        drawAlphaTexture(boxTexture, slotX, boxY, mBaseColor);
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

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  void drawAlphaTexture(TextureID texture, int x, int y, int color) const
  {
    Screen.drawTexture( texture
                      , NO_ANIMATION
                      , x
                      , y
                      , DTA_FillColor     , color
                      , DTA_AlphaChannel  , true
                      , DTA_Alpha         , mAlpha
                      , DTA_VirtualWidth  , mScreenWidth
                      , DTA_VirtualHeight , mScreenHeight
                      , DTA_KeepRatio     , true
                      );
  }

  private
  void drawAlphaWidthTexture(TextureID texture, int x, int y, int color, int width) const
  {
    Screen.drawTexture( texture
                      , NO_ANIMATION
                      , x
                      , y
                      , DTA_FillColor     , color
                      , DTA_AlphaChannel  , true
                      , DTA_Alpha         , mAlpha
                      , DTA_VirtualWidth  , mScreenWidth
                      , DTA_VirtualHeight , mScreenHeight
                      , DTA_KeepRatio     , true
                      , DTA_DestWidth     , width
                      );
  }

  enum HorizontalFlipOptions
  {
    NoHorizontalFlip = 0,
    HorizontalFlip = 1,
  }

  enum VerticalFlipOptions
  {
    NoVerticalFlip = 0,
    VerticalFlip = 1,
  }

  private
  void drawFlippedTexture(TextureID texture, int x, int y, int horFlip, int verFlip) const
  {
    Screen.drawTexture( texture
                      , NO_ANIMATION
                      , x
                      , y
                      , DTA_Alpha         , mAlpha
                      , DTA_VirtualWidth  , mScreenWidth
                      , DTA_VirtualHeight , mScreenHeight
                      , DTA_KeepRatio     , true
                      , DTA_FlipX         , horFlip
                      , DTA_FlipY         , verFlip
                      );
  }

  private
  void drawWeapon(TextureID texture, int x, int y, int w, int h) const
  {
    Screen.drawTexture( texture
                      , NO_ANIMATION
                      , x
                      , y
                      , DTA_CenterOffset  , true
                      , DTA_KeepRatio     , true
                      , DTA_DestWidth     , w
                      , DTA_DestHeight    , h
                      , DTA_Alpha         , mAlpha
                      , DTA_VirtualWidth  , mScreenWidth
                      , DTA_VirtualHeight , mScreenHeight
                      );
  }

  private
  void drawThickLine(int x1, int y1, int x2, int y2, int width, int color) const
  {
    Screen.drawThickLine(x1, y1, x2, y2, width, color, mIntAlpha);
  }

  private
  void drawText(Font aFont, int color, int x, int y, string text) const
  {
    Screen.drawText( aFont
                   , color
                   , x
                   , y
                   , text
                   , DTA_Alpha         , mAlpha
                   , DTA_VirtualWidth  , mScreenWidth
                   , DTA_VirtualHeight , mScreenHeight
                   , DTA_KeepRatio     , true
                   );
  }

  private static
  color addColor(color base, int addRed, int addGreen, int addBlue)
  {
    uint newRed   = clamp(base.r + addRed,   0, 255);
    uint newGreen = clamp(base.g + addGreen, 0, 255);
    uint newBlue  = clamp(base.b + addBlue,  0, 255);
    uint result   = (newRed << 16) + (newGreen << 8) + newBlue;
    return result;
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

  const FILLED_AMMO_COLOR = 0x22DD22;

  private double mAlpha;
  private int    mIntAlpha;

  private int    mScale;
  private int    mScreenWidth;
  private int    mScreenHeight;

  private color  mBaseColor;
  private color  mSlotColor;
  private color  mSelectedColor;
  private color  mAmmoBackColor;

} // class gb_BlockyView
