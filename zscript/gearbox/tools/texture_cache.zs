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

class gb_TextureCache
{

  static
  gb_TextureCache from()
  {
    return new("gb_TextureCache");
  }

  void load()
  {
    isLoaded = true;

    // Wheel
    circle     = TexMan.checkForTexture("gb_circ", TexMan.Type_Any);
    halfCircle = TexMan.checkForTexture("gb_hcir", TexMan.Type_Any);
    ammoPip    = TexMan.checkForTexture("gb_pip" , TexMan.Type_Any);
    hand       = TexMan.checkForTexture("gb_hand", TexMan.Type_Any);
    pointer    = TexMan.checkForTexture("gb_pntr", TexMan.Type_Any);
    textBox    = TexMan.checkForTexture("gb_desc", TexMan.Type_Any);
    noIcon     = TexMan.checkForTexture("gb_nope", TexMan.Type_Any);

    // Blocks
    blockBox   = TexMan.checkForTexture("gb_box",  TexMan.Type_Any);
    blockBig   = TexMan.checkForTexture("gb_weap", TexMan.Type_Any);
    corner     = TexMan.checkForTexture("gb_cor",  TexMan.Type_Any);
    ammoLine   = TexMan.checkForTexture("gb_ammo", TexMan.Type_Any);

    // Sizes
    ammoPipSize = TexMan.getScaledSize(ammoPip);
  }

  transient TextureID circle;
  transient TextureID halfCircle;
  transient TextureID ammoPip;
  transient TextureID hand;
  transient TextureID pointer;
  transient TextureID textBox;
  transient TextureID noIcon;

  transient TextureID blockBox;
  transient TextureID blockBig;
  transient TextureID corner;
  transient TextureID ammoLine;

  transient vector2 ammoPipSize;

  transient bool isLoaded;

} // class gb_TextureCache
