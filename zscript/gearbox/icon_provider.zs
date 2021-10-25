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

class gb_IconProvider
{

  enum TextureTypes
  {
    TextureIcon,
    TextureSpawn,
    TextureReady
  }

  static
  gb_IconProvider from()
  {
    let result = new("gb_IconProvider");

    gb_ServiceLoader.loadServices("gb_IconService", result.mIconServices);

    return result;
  }

  /**
   * @returns texture and texture type (see TextureTypes enum) for a weapon.
   */
  ui
  TextureID, int getTextureFor(Inventory item) const
  {
    {
      uint nServices = mIconServices.size();
      string className = item.getClassName();
      for (uint i = 0; i < nServices; ++i)
      {
        string iconResponse = mIconServices[i].uiGet(className);
        if (iconResponse.length() != 0)
        {
          TextureID iconFromService = TexMan.checkForTexture(iconResponse, TexMan.Type_Any);
          if (iconFromService.isValid()) return iconFromService, TextureIcon;
        }
      }
    }

    {
      TextureID icon = BaseStatusBar.getInventoryIcon(item, TEXTURE_ICON_ONLY);
      if (icon.isValid()) return icon, TextureIcon;
    }

    {
      TextureID icon = BaseStatusBar.getInventoryIcon(item, TEXTURE_SPAWN_ONLY);
      if (icon.isValid()) return icon, TextureSpawn;
    }

    TextureID icon = BaseStatusBar.getInventoryIcon(item, TEXTURE_READY_ONLY);
    return icon, TextureReady;
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  const TEXTURE_ICON_ONLY  = StatusBarCore.DI_SkipSpawn | StatusBarCore.DI_SkipReady;
  const TEXTURE_SKIP_ICONS = StatusBarCore.DI_SkipIcon | StatusBarCore.DI_SkipAltIcon;
  const TEXTURE_SPAWN_ONLY = TEXTURE_SKIP_ICONS | StatusBarCore.DI_SkipReady;
  const TEXTURE_READY_ONLY = TEXTURE_SKIP_ICONS | StatusBarCore.DI_SkipSpawn;

  private Array<gb_Service> mIconServices;

} // class gb_IconProvider
