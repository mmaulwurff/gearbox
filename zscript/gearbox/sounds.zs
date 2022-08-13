/* Copyright Alexander Kromm (mmaulwurff@gmail.com) 2021-2022
 * Carrascado 2022
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

class gb_Sounds
{
  static
  
  gb_Sounds from(gb_Options options)
  {
    let result = new("gb_Sounds");
    result.mOptions = options;
    return result;
  }

  void playTick()
  {
    switch(mOptions.GetSoundpack())
    {
        case(0):
            playSound("gearbox/tick");
            break;
        case(1):
            playSound("gearbox/pack/tick");
            break;
        DEFAULT:
            playSound("gearbox/nope");
            break;
    }
  }

  void playOpen()
  {
    switch(mOptions.GetSoundpack())
    {
        case(0):
            playSound("gearbox/open");
            break;
        case(1):
            playSound("gearbox/pack/open");
            break;
        DEFAULT:
            playSound("gearbox/nope");
            break;
    }
  }

  void playClose()
  {
    switch(mOptions.GetSoundpack())
    {
        case(0):
            playSound("gearbox/close");
            break;
        case(1):
            playSound("gearbox/pack/close");
            break;
        DEFAULT:
            playSound("gearbox/nope");
            break;
    }
  }

  void playNope()
  {
    switch(mOptions.GetSoundpack())
    {
        case(0):
            playSound("gearbox/nope");
            break;
        case(1):
            playSound("gearbox/pack/nope");
            break;
        DEFAULT:
            playSound("gearbox/nope");
            break;
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  void playSound(string sound)
  {
    if (!mOptions.isSoundEnabled()) return;

    players[consolePlayer].mo.a_StartSound(sound, CHAN_AUTO, CHANF_UI | CHANF_OVERLAP | CHANF_LOCAL);
  }

  private gb_Options mOptions;

} // class gb_Sounds
