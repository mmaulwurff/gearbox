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
    result.mScaleCvar    = gb_Cvar.from("gb_scale");
    result.mColorCvar    = gb_Cvar.from("gb_color");
    result.mViewTypeCvar = gb_Cvar.from("gb_view_type");
    return result;
  }

  int getViewType() const { return mViewTypeCvar.getInt(); }
  int getScale()    const { return mScaleCvar.getInt(); }
  int getColor()    const { return mColorCvar.getInt(); }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private gb_Cvar mScaleCvar;
  private gb_Cvar mColorCvar;
  private gb_Cvar mViewTypeCvar;

} // class gb_Options
