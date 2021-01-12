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

class gb_TimeMachine
{

  static
  gb_TimeMachine from()
  {
    let result = new("gb_TimeMachine");
    result.mWasFrozen = false;
    return result;
  }

  play
  void freeze()
  {
    if (mWasFrozen) return;

    mWasFrozen = true;

    level.setFrozen(true);

    PlayerInfo player = players[consolePlayer];

    mCheats   = player.cheats;
    mVelocity = player.vel;

    player.cheats |=  FROZEN_CHEATS_FLAGS;
    player.vel     = (0, 0);
  }

  play
  void thaw()
  {
    if (!mWasFrozen) return;

    mWasFrozen = false;

    level.setFrozen(false);

    PlayerInfo player = players[consolePlayer];

    player.cheats = mCheats;
    player.vel    = mVelocity;
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  const FROZEN_CHEATS_FLAGS  = CF_TOTALLYFROZEN | CF_FROZEN | CF_NOVELOCITY;

  private bool    mWasFrozen;
  private int     mCheats;
  private vector2 mVelocity; // to reset weapon bobbing.


} // class gb_TimeMachine
