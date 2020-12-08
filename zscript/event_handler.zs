/* Copyright Alexander Kromm (mmaulwurff@gmail.com) 2020
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

class gb_EventHandler : EventHandler
{

  override
  void worldTick()
  {
    if (level.time == 0) return;
    if (level.time == 1) initialize();

    if (!mActivity.isWeapons())
    {
      class<Weapon> currentWeapon = gb_WeaponWatcher.getCurrentWeapon(players[consolePlayer]);
      mWeaponMenu.setSelectedWeapon(currentWeapon);
    }
  }

  /**
   * This function processes key bindings specific for Gearbox.
   */
  override
  void consoleProcess(ConsoleEvent event)
  {
    if (!isInitialized()) return;

    switch (gb_EventProcessor.process(event))
    {
    case EventToggleWeaponMenu: mActivity.toggleWeaponMenu(); break;
    }

    mWheelController.setIsActive(!mActivity.isNone());
  }

  /**
   * This function provides latching to existing key bindings.
   */
  override
  bool InputProcess(InputEvent event)
  {
    if (!isInitialized()) return false;

    if (mWheelController.process(event))
    {
      return true;
    }

    if (mActivity.isWeapons())
    {
      mWheelController.reset();

      switch (gb_InputProcessor.process(event))
      {
      case InputSelectNextWeapon: mWeaponMenu.selectNextWeapon(); return true;
      case InputSelectPrevWeapon: mWeaponMenu.selectPrevWeapon(); return true;

      case InputConfirmSelection:
        gb_Sender.sendSelectEvent(mWeaponMenu.confirmSelection());
        mActivity.toggleWeaponMenu();
        return true;
      }
    }

    return false;
  }

  override
  void networkProcess(ConsoleEvent event)
  {
    gb_Change change;
    gb_NeteventProcessor.process(event, change);
    gb_Changer.change(change);
  }

  override
  void renderOverlay(RenderEvent event)
  {
    if (!isInitialized()) return;

    mFadeInOut.fadeInOut((mActivity.isNone()) ? -0.1 : 0.2);
    double alpha = mFadeInOut.getAlpha();

    if (mActivity.isWeapons() || alpha != 0.0)
    {
      gb_ViewModel viewModel;
      mWeaponMenu.fill(viewModel);

      {
        mWeaponView1.setAlpha(alpha);
        mWeaponView1.setScale(mScaleCvar.getInt());
        mWeaponView1.setBaseColor(mColorCvar.getInt());

        //mWeaponView1.display(viewModel);
      }

      {
        gb_WheelControllerModel controllerModel;
        mWheelController.fill(controllerModel);
        mWheelIndexer.update(viewModel, controllerModel);
        mWeaponMenu.setSelectedIndex(mWheelIndexer.getSelectedIndex());

        mWeaponView2.setAlpha(alpha);
        mWeaponView2.setBaseColor(mColorCvar.getInt());
        mWeaponView2.display(viewModel, controllerModel);
      }
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  void initialize()
  {
    gb_WeaponData weaponData;
    gb_WeaponDataLoader.load(weaponData);
    mWeaponMenu = gb_WeaponMenu.from(weaponData);

    mActivity    = gb_Activity.from();
    mFadeInOut   = gb_FadeInOut.from();
    mWeaponView1 = gb_BlockyView.from();
    mWeaponView2 = gb_WheelView.from();
    mScaleCvar   = gb_Cvar.from("gb_scale");
    mColorCvar   = gb_Cvar.from("gb_color");

    mWheelController = gb_WheelController.from();
    mWheelIndexer    = gb_WheelIndexer.from();
  }

  private
  bool isInitialized() const
  {
    return mWeaponMenu != NULL;
  }

  private gb_WeaponMenu mWeaponMenu;
  private gb_Activity   mActivity;
  private gb_FadeInOut  mFadeInOut;
  private gb_BlockyView mWeaponView1;
  private gb_WheelView  mWeaponView2;
  private gb_Cvar       mScaleCvar;
  private gb_Cvar       mColorCvar;

  private gb_WheelController mWheelController;
  private gb_WheelIndexer    mWheelIndexer;

} // class gb_EventHandler
