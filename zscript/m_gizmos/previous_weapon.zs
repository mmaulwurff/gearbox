/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2021
 *
 * This file is a part of Gearbox.
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

class gb_PreviousWeaponEventHandler : EventHandler
{

// public: // EventHandler /////////////////////////////////////////////////////

  override
  void onRegister()
  {
    mPreviousWeapon = NULL;
    mCurrentWeapon  = NULL;
    bool mIsHolstered = false;
  }

  override
  void networkProcess(ConsoleEvent event)
  {
    PlayerInfo player = players[event.player];
    if (event.name == "gb_prev_weapon") selectPreviousWeapon(player);
  }

  override
  void worldTick()
  {
    PlayerInfo player = players[consolePlayer];
    updatePreviousWeapon(player);
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  void updatePreviousWeapon(PlayerInfo player)
  {
    let ready = player.ReadyWeapon;

    if (ready == NULL || ready.GetClassName() == "mg_Holstered")
    {
      if (!mIsHolstered)
      {
        // swap
        let tmp         = mCurrentWeapon;
        mCurrentWeapon  = mPreviousWeapon;
        mPreviousWeapon = tmp;
      }
      mIsHolstered = true;
      return;
    }

    mIsHolstered = false;

    if (mCurrentWeapon != ready)
    {
      mPreviousWeapon = mCurrentWeapon;
    }

    mCurrentWeapon = ready;
  }

  private
  void selectPreviousWeapon(PlayerInfo player)
  {
    if (mPreviousWeapon != NULL && player.ReadyWeapon != mPreviousWeapon)
    {
      player.PendingWeapon = mPreviousWeapon;
    }
  }

  private Weapon mCurrentWeapon;
  private Weapon mPreviousWeapon;
  private bool   mIsHolstered;

} // class gb_PreivousWeaponEventHandler
