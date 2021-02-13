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

class gb_WheelView
{

  static
  gb_WheelView from( gb_Options        options
                   , gb_MultiWheelMode multiWheelMode
                   , gb_Text           text
                   , gb_TextureCache   textureCache
                   )
  {
    let result = new("gb_WheelView");

    result.setAlpha(1.0);
    result.setBaseColor(0x2222CC);

    result.mScreen         = gb_Screen.from();
    result.mOptions        = options;
    result.mMultiWheelMode = multiWheelMode;
    result.mText           = text;
    result.mTextureCache   = textureCache;

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

  void display( gb_ViewModel viewModel
              , gb_WheelControllerModel controllerModel
              , bool showPointer
              , int  innerIndex
              , int  outerIndex
              ) const
  {
    mScaleFactor = gb_Screen.getScaleFactor();

    drawInnerWheel();

    uint nWeapons = viewModel.tags.size();
    int  radius   = Screen.getHeight() * 5 / 32;
    int  allowedWidth = int(Screen.getHeight() * 3 / 16 - MARGIN * 2 * mScaleFactor);

    mCenter = mScreen.getWheelCenter();

    int nPlaces = 0;

    if (mMultiWheelMode.isEngaged(viewModel))
    {
      gb_MultiWheelModel multiWheelModel;
      gb_MultiWheel.fill(viewModel, multiWheelModel);

      nPlaces = multiWheelModel.data.size();
      for (uint i = 0; i < nPlaces; ++i)
      {
        bool isWeapon = multiWheelModel.isWeapon[i];
        int  data     = multiWheelModel.data[i];

        if (isWeapon) displayWeapon(i, data, nPlaces, radius, allowedWidth, viewModel, mCenter);
        else          displaySlot  (i, data, nPlaces, radius);
      }

      drawHands(nPlaces, innerIndex, mCenter, 0);

      if (outerIndex != UNDEFINED_INDEX && !multiWheelModel.isWeapon[innerIndex])
      {
        int slot = multiWheelModel.data[innerIndex];
        drawOuterWeapons( innerIndex
                        , outerIndex
                        , nPlaces
                        , slot
                        , viewModel
                        , radius
                        , allowedWidth
                        , int(controllerModel.radius)
                        );
      }
    }
    else
    {
      for (uint i = 0; i < nWeapons; ++i)
      {
        displayWeapon(i, i, nWeapons, radius, allowedWidth, viewModel, mCenter);
      }

      nPlaces = nWeapons;
      drawHands(nPlaces, innerIndex, mCenter, 0);
    }

    if (showPointer) drawPointer(controllerModel.angle, controllerModel.radius);
    if (mOptions.isShowingTags()) drawWeaponDescription(viewModel, innerIndex, nPlaces);
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  void drawOuterWeapons( int  innerIndex
                       , int  outerIndex
                       , uint nPlaces
                       , int  slot
                       , gb_ViewModel viewModel
                       , int  radius
                       , int  allowedWidth
                       , int  controllerRadius
                       )
  {
    int     wheelRadius      = gb_Screen.getWheelRadius();
    double  angle            = itemAngle(nPlaces, innerIndex);
    vector2 outerWheelCenter = (sin(angle), -cos(angle)) * wheelRadius + mCenter;
    drawOuterWheel(outerWheelCenter.x, outerWheelCenter.y, -angle);

    uint nWeapons = viewModel.tags.size();

    uint start = 0;
    for (; start < nWeapons && viewModel.slots[start] != slot; ++start);
    uint end = start;
    for (; end < nWeapons && viewModel.slots[end] == slot; ++end);

    uint   nWeaponsInSlot = end - start;
    double startingAngle  = angle - 90 + (180.0 / nWeaponsInSlot / 2);

    uint place = 0;
    for (uint i = start; i < end; ++i, ++place)
    {
      displayWeapon( place
                   , i
                   , nWeaponsInSlot * 2
                   , radius
                   , allowedWidth
                   , viewModel
                   , outerWheelCenter
                   , startingAngle
                   );
    }

    int deadRadius = gb_Screen.getWheelDeadRadius();

    drawHands( nWeaponsInSlot * 2
             , outerIndex
             , outerWheelCenter
             , -startingAngle
             );
  }

  private
  void drawInnerWheel()
  {
    int wheelDiameter = gb_Screen.getWheelRadius() * 2;
    Screen.drawTexture( mTextureCache.circle
                      , NO_ANIMATION
                      , mCenter.x
                      , mCenter.y
                      , DTA_FillColor    , mBaseColor
                      , DTA_AlphaChannel , true
                      , DTA_Alpha        , mAlpha
                      , DTA_CenterOffset , true
                      , DTA_DestWidth    , wheelDiameter
                      , DTA_DestHeight   , wheelDiameter
                      );
  }

  private
  void drawOuterWheel(double x, double y, double angle)
  {
    int wheelDiameter = gb_Screen.getWheelRadius() * 2;
    Screen.drawTexture( mTextureCache.halfCircle
                      , NO_ANIMATION
                      , x
                      , y
                      , DTA_FillColor    , mBaseColor
                      , DTA_AlphaChannel , true
                      , DTA_Alpha        , mAlpha
                      , DTA_CenterOffset , true
                      , DTA_Rotate       , angle
                      , DTA_DestWidth    , wheelDiameter
                      , DTA_DestHeight   , wheelDiameter
                      );
  }

  private
  void displayWeapon( uint place
                    , uint weaponIndex
                    , uint nPlaces
                    , int  radius
                    , int  allowedWidth
                    , gb_ViewModel viewModel
                    , vector2 center
                    , double startingAngle = 0.0
                    )
  {
    double angle = (startingAngle + itemAngle(nPlaces, place)) % 360;

    vector2 xy =(sin(angle), -cos(angle)) * radius + center;

    // code is adapted from GZDoom AltHud.DrawImageToBox.
    TextureID weaponTexture = viewModel.icons[weaponIndex];
    Vector2   weaponSize    = TexMan.getScaledSize(weaponTexture) * 2;
    bool      isTall        = (weaponSize.y > weaponSize.x);

    double scale = isTall
      ? ((allowedWidth < weaponSize.y) ? allowedWidth / weaponSize.y : 1.0)
      : ((allowedWidth < weaponSize.x) ? allowedWidth / weaponSize.x : 1.0)
      ;

    scale *= mScaleFactor;

    int weaponWidth  = int(weaponSize.x * scale);
    int weaponHeight = int(weaponSize.y * scale);

    drawWeapon(weaponTexture, xy, weaponWidth, weaponHeight, angle, isTall);
    drawAmmo(angle, center, viewModel, weaponIndex);
  }

  private
  void drawAmmoPip(double angle, double radius, vector2 center, bool colored)
  {
    vector2 xy   = (sin(angle), -cos(angle)) * radius + center;
    vector2 size = mTextureCache.ammoPipSize * mScaleFactor;

    if (colored)
    {
      Screen.drawTexture( mTextureCache.ammoPip
                        , NO_ANIMATION
                        , round(xy.x)
                        , round(xy.y)
                        , DTA_CenterOffset , true
                        , DTA_Alpha        , mAlpha
                        , DTA_DestWidth    , int(size.x)
                        , DTA_DestHeight   , int(size.y)
                        , DTA_FillColor    , FILLED_AMMO_COLOR
                        );
    }
    else
    {
      Screen.drawTexture( mTextureCache.ammoPip
                        , NO_ANIMATION
                        , round(xy.x)
                        , round(xy.y)
                        , DTA_CenterOffset , true
                        , DTA_Alpha        , mAlpha
                        , DTA_DestWidth    , int(size.x)
                        , DTA_DestHeight   , int(size.y)
                        );
    }
  }

  private
  void drawAmmo(double weaponAngle, vector2 center, gb_ViewModel viewModel, uint weaponIndex)
  {
    if (viewModel.ammo1[weaponIndex] != -1)
    {
      int margin       = int(10 * mScaleFactor);
      int radius       = Screen.getHeight() / 4 - margin;
      int nColoredPips = int(ceil(N_PIPS * double(viewModel.ammo1   [weaponIndex])
                                                / viewModel.maxAmmo1[weaponIndex]));
      drawAmmoPips(radius, weaponAngle, center, nColoredPips);
    }

    if (viewModel.ammo2[weaponIndex] != -1)
    {
      int margin       = int(20 * mScaleFactor);
      int radius       = Screen.getHeight() / 4 - margin;
      int nColoredPips = int(ceil(N_PIPS * double(viewModel.ammo2   [weaponIndex])
                                                / viewModel.maxAmmo2[weaponIndex]));
      drawAmmoPips(radius, weaponAngle, center, nColoredPips);
    }
  }

  void drawAmmoPips(double radius, double weaponAngle, vector2 center, int ammoRatio)
  {
    for (int i = -N_PIPS_HALVED + 1; i <= 0; ++i)
    {
      double angle = weaponAngle - PIPS_GAP + i * PIPS_STEP;
      drawAmmoPip(angle, radius, center, ammoRatio > 0);
      --ammoRatio;
    }

    for (int i = 0; i < N_PIPS_HALVED; ++i)
    {
      double angle = weaponAngle + PIPS_GAP + i * PIPS_STEP;
      bool colored = true;
      drawAmmoPip(angle, radius, center, ammoRatio > 0);
      --ammoRatio;
    }
  }

  private
  void displaySlot(uint place, int slot, uint nPlaces, int radius)
  {
    double  angle = itemAngle(nPlaces, place);
    vector2 pos   = (sin(angle), -cos(angle)) * radius + mCenter;
    Font    aFont = "NewSmallFont";

    gb_Text.draw(string.format("%d", slot), pos, aFont, mAlpha, true);
  }

  private static
  double itemAngle(uint nItems, uint index)
  {
    return 360.0 / nItems * index;
  }

  private
  void drawHands(uint nPlaces, uint selectedIndex, vector2 center, double startAngle)
  {
    if (nPlaces < 2) return;

    double handsAngle = startAngle - itemAngle(nPlaces, selectedIndex);

    double sectorAngleHalfWidth = 360.0 / 2.0 / nPlaces - 2;

    double baseHeight  = 1080;
    double heightRatio = Screen.getHeight() / baseHeight;
    double baseWidth   = Screen.getWidth() / heightRatio;

    Screen.drawTexture( mTextureCache.hand
                      , NO_ANIMATION
                      , center.x / heightRatio
                      , center.y / heightRatio
                      , DTA_KeepRatio     , true
                      , DTA_CenterOffset  , true
                      , DTA_Alpha         , mAlpha
                      , DTA_Rotate        , handsAngle - sectorAngleHalfWidth
                      , DTA_VirtualWidth  , int(baseWidth)
                      , DTA_VirtualHeight , int(baseHeight)
                      , DTA_FlipX         , true
                      );

    Screen.drawTexture( mTextureCache.hand
                      , NO_ANIMATION
                      , center.x / heightRatio
                      , center.y / heightRatio
                      , DTA_KeepRatio     , true
                      , DTA_CenterOffset  , true
                      , DTA_CenterOffset  , true
                      , DTA_Alpha         , mAlpha
                      , DTA_Rotate        , handsAngle + sectorAngleHalfWidth
                      , DTA_VirtualWidth  , int(baseWidth)
                      , DTA_VirtualHeight , int(baseHeight)
                      );
  }

  private
  void drawWeaponDescription(gb_ViewModel viewModel, int innerIndex, int nPlaces)
  {
    int    index       = viewModel.selectedWeaponIndex;
    string description = viewModel.tags[index];
    string ammo1 = (viewModel.ammo1[index] != -1)
      ? string.format("%d/%d", viewModel.ammo1[index], viewModel.maxAmmo1[index])
      : "";
    string ammo2 = (viewModel.ammo2[index] != -1)
      ? string.format("%d/%d", viewModel.ammo2[index], viewModel.maxAmmo2[index])
      : "";

    double  angle   = itemAngle(nPlaces, innerIndex);
    bool    isOnTop = (90.0 < angle && angle < 270.0);
    vector2 pos     = mCenter;
    pos.y += gb_Screen.getWheelRadius() * (isOnTop ? -1 : 1);

    mText.drawBox(ammo1, description, ammo2, pos, !isOnTop, mBaseColor, mAlpha);
  }

  private
  void drawPointer(double angle, double radius)
  {
    vector2 pos = (sin(angle), -cos(angle)) * radius + mCenter;
    vector2 size = TexMan.getScaledSize(mTextureCache.pointer);
    size *= mScaleFactor;

    Screen.drawTexture( mTextureCache.pointer
                      , NO_ANIMATION
                      , pos.x
                      , pos.y
                      , DTA_CenterOffset , true
                      , DTA_Alpha        , mAlpha
                      , DTA_DestWidth    , int(size.x)
                      , DTA_DestHeight   , int(size.y)
                      );
  }

  private
  void drawWeapon(TextureID texture, vector2 xy, int w, int h, double angle, bool isTall) const
  {
    bool flipX = (angle > 180);
    if (flipX) angle -= 180;
    angle = -angle + 90;

    if (isTall) angle -= 90;

    Screen.drawTexture( texture
                      , NO_ANIMATION
                      , xy.x
                      , xy.y
                      , DTA_CenterOffset , true
                      , DTA_KeepRatio    , true
                      , DTA_DestWidth    , w
                      , DTA_DestHeight   , h
                      , DTA_Alpha        , mAlpha
                      , DTA_Rotate       , angle
                      , DTA_FlipX        , flipX
                      );

    if (!mOptions.getWheelTint()) return;

    Screen.drawTexture( texture
                      , NO_ANIMATION
                      , xy.x
                      , xy.y
                      , DTA_CenterOffset , true
                      , DTA_KeepRatio    , true
                      , DTA_DestWidth    , w
                      , DTA_DestHeight   , h
                      , DTA_Alpha        , mAlpha * 0.3
                      , DTA_FillColor    , mBaseColor
                      , DTA_Rotate       , angle
                      , DTA_FlipX        , flipX
                      );
  }

  const NO_ANIMATION = 0; // == false

  const MARGIN = 4;

  const UNDEFINED_INDEX = -1;

  // For LZDoom 3.87b: define missing drawing attributes.
  // Sort-of compatibility. The mod is able to load. Wheel still crashes LZDoom,
  // but Blocks view works.
  const DTA_ScaleX = 1073746885;
  const DTA_ScaleY = 1073746886;
  const DTA_Rotate = 1073746894;

  const N_PIPS = 10;
  const N_PIPS_HALVED = N_PIPS / 2;

  const PIPS_GAP  = 1.2;
  const PIPS_STEP = 1.5;

  const FILLED_AMMO_COLOR = 0x22DD22;

  private double  mAlpha;
  private color   mBaseColor;
  private vector2 mCenter;

  private gb_Screen mScreen;
  private gb_Options mOptions;
  private gb_MultiWheelMode mMultiWheelMode;

  private gb_Text mText;

// cache ///////////////////////////////////////////////////////////////////////////////////////////

  private gb_TextureCache mTextureCache;
  private double mScaleFactor;

} // class gb_WheelView
