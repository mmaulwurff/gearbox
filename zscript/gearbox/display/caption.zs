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

class gb_Caption
{

  static
  gb_Caption from(gb_Text text)
  {
    let result = new("gb_Caption");

    result.mText      = text;
    result.mCaption   = "";
    result.mStartTime = 0;

    return result;
  }

  void setCaption(string caption)
  {
    mCaption   = caption;
    mStartTime = level.time;
  }

  ui
  void show(double fracTic, color aColor)
  {
    if (mCaption.length() == 0) return;

    double alpha;
    int timeSinceStart = level.time - mStartTime;

    if (timeSinceStart < FADE_IN_TIME)
    {
      alpha = (timeSinceStart + fracTic) / FADE_IN_TIME;
    }
    else if (timeSinceStart < HOLD_TIME)
    {
      alpha = 1.0;
    }
    else if (timeSinceStart < FADE_OUT_TIME)
    {
      alpha = 1.0 - (timeSinceStart + fracTic - HOLD_TIME) / (FADE_OUT_TIME - HOLD_TIME);
    }
    else
    {
      return;
    }

    int x, y, width, height;
    [x, y, width, height] = Screen.getViewWindow();
    vector2 pos = (x + width / 2, y + height * 15 / 16);
    mText.drawBox("", mCaption, "", pos, POS_IS_BOTTOM, aColor, alpha);
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  const POS_IS_BOTTOM = 0;

  const FADE_IN_TIME  = 35 / 4;
  const HOLD_TIME     = 35 * 2 + FADE_IN_TIME;
  const FADE_OUT_TIME = 35 + HOLD_TIME;

  private gb_Text mText;

  private string mCaption;
  private int    mStartTime;

} // class gb_Caption
