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

class gb_WheelView
{

  static
  gb_WheelView from()
  {
    let result = new("gb_WheelView");
    result.setAlpha(1.0);
    result.setBaseColor(0x2222CC);
    result.mCenterX = Screen.getWidth() - Screen.getHeight() / 2;
    result.mCenterY = Screen.getHeight() / 2;
    return result;
  }

  void setAlpha(double alpha)
  {
    mAlpha = alpha;
  }

  void setBaseColor(int color)
  {
    mBaseColor = color;
  }

  void display(gb_ViewModel viewModel, gb_WheelControllerModel controllerModel) const
  {
    Screen.Dim(0x999999, mAlpha * 0.3, 0, 0, Screen.getWidth(), Screen.getHeight());

    TextureID circleTexture = TexMan.checkForTexture("gb_circ", TexMan.Type_Any);
    Screen.drawTexture( circleTexture
                      , NO_ANIMATION
                      , mCenterX
                      , mCenterY
                      , DTA_FillColor     , mBaseColor
                      , DTA_AlphaChannel  , true
                      , DTA_Alpha         , mAlpha
                      , DTA_CenterOffset  , true
                      );

    uint nWeapons = viewModel.tags.size();
    for (uint i = 0; i < nWeapons; ++i)
    {
      double angle = 360.0 / nWeapons * i;

      int radius = Screen.getHeight() * 5 / 32;
      int x = int(round( sin(angle) * radius + mCenterX));
      int y = int(round(-cos(angle) * radius + mCenterY));

      // code is adapted from GZDoom AltHud.DrawImageToBox.
      TextureID weaponTexture = viewModel.icons[i];
      let weaponSize = TexMan.getScaledSize(weaponTexture) * 2;

      int allowedWidth = Screen.getHeight() * 3 / 16 - MARGIN * 2;
      double scale = (allowedWidth < weaponSize.x) ? allowedWidth / weaponSize.x : 1.0;
      int weaponWidth  = int(round(weaponSize.x * scale));
      int weaponHeight = int(round(weaponSize.y * scale));

      drawWeapon( weaponTexture
                , x
                , y
                , weaponWidth
                , weaponHeight
                , angle
                );
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  void drawWeapon(TextureID texture, int x, int y, int w, int h, double angle) const
  {
    bool flipX = (angle > 180);
    if (angle > 180) angle -= 180;
    angle = -angle + 90;

    Screen.drawTexture( texture
                      , NO_ANIMATION
                      , x
                      , y
                      , DTA_CenterOffset  , true
                      , DTA_KeepRatio     , true
                      , DTA_DestWidth     , w
                      , DTA_DestHeight    , h
                      , DTA_Alpha         , mAlpha
                      , DTA_Rotate        , angle
                      , DTA_FlipX         , flipX
                      );

    Screen.drawTexture( texture
                      , NO_ANIMATION
                      , x
                      , y
                      , DTA_CenterOffset  , true
                      , DTA_KeepRatio     , true
                      , DTA_DestWidth     , w
                      , DTA_DestHeight    , h
                      , DTA_Alpha         , mAlpha * 0.3
                      , DTA_FillColor     , mBaseColor
                      , DTA_Rotate        , angle
                      , DTA_FlipX         , flipX
                      );
  }

  const NO_ANIMATION = 0; // == false

  const MARGIN = 4;
  const SLOT_SIZE = 25;
  const SELECTED_SLOT_WIDTH = 100;
  const SELECTED_WEAPON_HEIGHT = SLOT_SIZE * 2 + MARGIN;

  private double mAlpha;
  private color mBaseColor;
  private int mCenterX;
  private int mCenterY;

} // class gb_WheelView
