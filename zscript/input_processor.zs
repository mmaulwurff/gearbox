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

class gb_InputProcessor
{

  static
  gb_Input process(InputEvent event)
  {
    if (event.type != InputEvent.Type_KeyDown) return InputNothing;

    int key = event.keyScan;
    if (isKeyForCommand(key, "weapnext")) return InputSelectNextWeapon;
    if (isKeyForCommand(key, "weapprev")) return InputSelectPrevWeapon;
    if (isKeyForCommand(key, "+attack"))  return InputConfirmSelection;

    return InputNothing;
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private static
  bool isKeyForCommand(int key, string command)
  {
    int key1;
    int key2;
    [key1, key2] = bindings.getKeysForCommand(command);
    return (key == key1 || key == key2);
  }

} // class gb_InputProcessor
