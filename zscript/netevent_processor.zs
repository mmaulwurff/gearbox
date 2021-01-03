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

class gb_NeteventProcessor
{

  static
  void process(ConsoleEvent event, out gb_Change change)
  {
    change.type = gb_Change.Nothing;

    if (event.name.left(3) != "gb_") return;

    Array<string> args;
    event.name.split(args, ":");

    if (args[0] == "gb_select_weapon")
    {
      change.type = gb_Change.SelectWeapon;
      change.object = args[1];
    }
  }

} // class gb_NeteventProcessor
