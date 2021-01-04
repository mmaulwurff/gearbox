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

class gb_Options
{

  static
  gb_Options from()
  {
    let result = new("gb_Options");

    result.mScale    = gb_Cvar.from("gb_scale");
    result.mColor    = gb_Cvar.from("gb_color");
    result.mViewType = gb_Cvar.from("gb_view_type");
    result.mOpenOnScroll = gb_Cvar.from("gb_open_on_scroll");
    result.mMouseInWheel = gb_Cvar.from("gb_mouse_in_wheel");

    result.mMouseSensitivityX = gb_Cvar.from("gb_mouse_sensitivity_x");
    result.mMouseSensitivityY = gb_Cvar.from("gb_mouse_sensitivity_y");

    return result;
  }

  int getViewType() const { return mViewType.getInt(); }
  int getScale()    const { return mScale.getInt(); }
  int getColor()    const { return mColor.getInt(); }

  bool isOpenOnScroll() const { return mOpenOnScroll.getBool(); }
  bool isMouseInWheel() const { return mMouseInWheel.getBool(); }

  Vector2 getMouseSensitivity() const
  {
    return (mMouseSensitivityX.getDouble(), mMouseSensitivityY.getDouble());
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private gb_Cvar mScale;
  private gb_Cvar mColor;
  private gb_Cvar mViewType;
  private gb_Cvar mOpenOnScroll;
  private gb_Cvar mMouseInWheel;

  private gb_Cvar mMouseSensitivityX;
  private gb_Cvar mMouseSensitivityY;

} // class gb_Options
