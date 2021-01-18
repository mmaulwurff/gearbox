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

/**
 * This class provides helper functions for screen position and sizes.
 */
class gb_Screen
{

  static
  gb_Screen from()
  {
    let result = new("gb_Screen");
    result.mWheelPositionCvar = gb_Cvar.from("gb_wheel_position");
    return result;
  }

  vector2 getWheelCenter() const
  {
    int screenWidth      = Screen.getWidth();
    int halfScreenHeight = Screen.getHeight() / 2;
    int centerPosition   = int((screenWidth / 2 - halfScreenHeight) * mWheelPositionCvar.getDouble());
    return (screenWidth / 2 + centerPosition, halfScreenHeight);
  }

  static
  int getWheelRadius()
  {
    return Screen.getHeight() / 4;
  }

  static
  int getWheelDeadRadius()
  {
    return Screen.getHeight() / 16;
  }

  static
  double getScaleFactor()
  {
    return Screen.getHeight() / 1080.0;
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private gb_Cvar mWheelPositionCvar;

} // class gb_Screen
