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

class gb_WheelTextureCache
{

  static
  gb_WheelTextureCache from()
  {
    return new("gb_WheelTextureCache");
  }

  void load()
  {
    isLoaded = true;

    circle     = TexMan.checkForTexture("gb_circ", TexMan.Type_Any);
    halfCircle = TexMan.checkForTexture("gb_hcir", TexMan.Type_Any);
    ammoPip    = TexMan.checkForTexture("gb_pip" , TexMan.Type_Any);
    hand       = TexMan.checkForTexture("gb_hand", TexMan.Type_Any);
    pointer    = TexMan.checkForTexture("gb_pntr", TexMan.Type_Any);

    ammoPipSize = TexMan.getScaledSize(ammoPip);
  }

  transient TextureID circle;
  transient TextureID halfCircle;
  transient TextureID ammoPip;
  transient TextureID hand;
  transient TextureID pointer;

  transient vector2 ammoPipSize;

// private: ////////////////////////////////////////////////////////////////////////////////////////

  transient bool isLoaded;

} // class gb_WheelTextureCache
