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

/**
 * This class is the core of Gearbox.
 *
 * It delegates as much work to other classes while minimizing the relationships
 * between those classes.
 *
 * To ensure multiplayer compatibility, Gearbox does the following:
 *
 * 1. All visuals and input processing happens on client side and is invisible
 * to the network.
 *
 * 2. Actial game changing things, like switching weapons, are done through
 * network - even for the current player, even for the singleplayer game.
 */
class gb_EventHandler : EventHandler
{

  override
  void worldTick()
  {
    switch (gb_Level.getState())
    {
    case gb_Level.NotInGame:  return;
    case gb_Level.Loading:    return;
    case gb_Level.JustLoaded: initialize(); // fallthrough
    case gb_Level.Loaded:     break;
    }

    if (!mActivity.isWeapons())
    {
      mWeaponMenu.setSelectedWeapon(gb_WeaponWatcher.current());
    }

    if (!multiplayer)
    {
      // Thaw regardless of the option to prevent player being locked frozen
      // after changing options.
      if (mActivity.isNone())            mTimeMachine.thaw();
      else if (mOptions.isTimeFreezed()) mTimeMachine.freeze();
    }

    if (!mActivity.isNone() && gb_Player.isDead())
    {
      mActivity.setNone();
      mWheelController.setIsActive(false);
    }
  }

  /**
   * This function processes key bindings specific for Gearbox.
   */
  override
  void consoleProcess(ConsoleEvent event)
  {
    if (!mIsInitialized) return;

    switch (gb_EventProcessor.process(event, mOptions.isSelectOnKeyUp()))
    {
    case InputToggleWeaponMenu: toggleMenu(); break;
    case InputConfirmSelection: confirmSelectionAndCloseMenu(); break;
    case InputToggleWeaponMenuObsolete: gb_Log.notice("GB_TOGGLE_WEAPON_MENU_OBSOLETE"); break;
    }

    if (!mActivity.isNone()) mWheelController.reset();
  }

  /**
   * This function provides latching to existing key bindings, and processing mouse input.
   */
  override
  bool inputProcess(InputEvent event)
  {
    if (!mIsInitialized) return false;

    mWheelController.setMouseSensitivity(mOptions.getMouseSensitivity());

    switch (mOptions.getViewType())
    {
    case VIEW_TYPE_WHEEL:
      if (mOptions.isMouseInWheel() && mWheelController.process(event)) return true;
      break;
    }

    int input = gb_InputProcessor.process(event);

    if (mActivity.isWeapons())
    {
      if (InputSelectSlotBegin <= input && input <= InputSelectSlotEnd)
      {
        mWheelController.reset();
        int slot = input - InputSelectSlotBegin;
        mWeaponMenu.selectSlot(slot);
        return true;
      }

      switch (input)
      {
      case InputSelectNextWeapon: mWeaponMenu.selectNextWeapon(); mWheelController.reset(); return true;
      case InputSelectPrevWeapon: mWeaponMenu.selectPrevWeapon(); mWheelController.reset(); return true;
      case InputConfirmSelection: confirmSelectionAndCloseMenu(); return true;
      }
    }
    else if (mActivity.isNone())
    {
      mWheelController.reset();

      if (InputSelectSlotBegin <= input && input <= InputSelectSlotEnd)
      {
        int slot = input - InputSelectSlotBegin;

        if (mOptions.isNoMenuIfOne() && mWeaponMenu.isOneWeaponInSlot(slot))
        {
          mWheelController.reset();
          mWeaponMenu.selectSlot(slot);
          gb_Sender.sendSelectEvent(mWeaponMenu.confirmSelection());
          return true;
        }

        else if (mWeaponMenu.selectSlot(slot))
        {
          toggleMenu();
          return true;
        }

        return false;
      }

      switch (input)
      {
      case InputSelectNextWeapon:
        if (mOptions.isOpenOnScroll())
        {
          toggleMenu();
          mWeaponMenu.selectNextWeapon();
          return true;
        }
        break;

      case InputSelectPrevWeapon:
        if (mOptions.isOpenOnScroll())
        {
          toggleMenu();
          mWeaponMenu.selectPrevWeapon();
          return true;
        }
        break;
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
    if (!mIsInitialized) return;

    mFadeInOut.fadeInOut((mActivity.isNone()) ? -0.1 : 0.2);
    double alpha = mFadeInOut.getAlpha();

    if (mActivity.isWeapons() || alpha != 0.0)
    {
      gb_ViewModel viewModel;
      mWeaponMenu.fill(viewModel);

      if (mOptions.isDimEnabled()) gb_Dim.dim(alpha);

      switch (mOptions.getViewType())
      {
      case VIEW_TYPE_BLOCKY:
        mBlockyView.setAlpha(alpha);
        mBlockyView.setScale(mOptions.getScale());
        mBlockyView.setBaseColor(mOptions.getColor());
        mBlockyView.display(viewModel);
        break;

      case VIEW_TYPE_WHEEL:
      {
        gb_WheelControllerModel controllerModel;
        mWheelController.fill(controllerModel);
        mWheelIndexer.update(viewModel, controllerModel);
        int selectedIndex = mWheelIndexer.getSelectedIndex();
        mWeaponMenu.setSelectedIndexFromView(viewModel, selectedIndex);
        selectedIndex = mWeaponMenu.getSelectedIndex();

        mWheelView.setAlpha(alpha);
        mWheelView.setBaseColor(mOptions.getColor());
        int innerIndex = mWheelIndexer.getInnerIndex(selectedIndex, viewModel);
        int outerIndex = mWheelIndexer.getOuterIndex(selectedIndex, viewModel);
        mWheelView.display( viewModel
                          , controllerModel
                          , mOptions.isMouseInWheel()
                          , innerIndex
                          , outerIndex
                          );
        break;
      }

      }
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private ui
  void toggleMenu()
  {
    if (gb_Player.isDead()) return;

    mActivity.toggleWeaponMenu();

    // Note that we update wheel controller active status even if wheel is not
    // active. In that case, the controller won't do anything because of the
    // check in inputProcess function.
    mWheelController.setIsActive(!mActivity.isNone());
  }

  private ui
  void confirmSelectionAndCloseMenu()
  {
    if (mActivity.isNone()) return;

    gb_Sender.sendSelectEvent(mWeaponMenu.confirmSelection());
    mActivity.toggleWeaponMenu();

    switch (mOptions.getViewType())
    {
    case VIEW_TYPE_WHEEL:
      mWheelController.setIsActive(false);
      break;
    }
  }

  enum ViewTypes
  {
    VIEW_TYPE_BLOCKY = 0,
    VIEW_TYPE_WHEEL  = 1,
  }

  private
  void initialize()
  {
    gb_WeaponData weaponData;
    gb_WeaponDataLoader.load(weaponData);
    mWeaponMenu = gb_WeaponMenu.from(weaponData);

    mActivity    = gb_Activity.from();
    mFadeInOut   = gb_FadeInOut.from();
    mOptions     = gb_Options.from();
    mTimeMachine = gb_TimeMachine.from();

    mBlockyView = gb_BlockyView.from();

    mMultiWheelMode  = gb_MultiWheelMode.from(mOptions);
    mWheelView       = gb_WheelView.from(mOptions, mMultiWheelMode);
    mWheelController = gb_WheelController.from();
    mWheelIndexer    = gb_WheelIndexer.from(mMultiWheelMode);

    mIsInitialized = true;
  }

  private gb_WeaponMenu  mWeaponMenu;
  private gb_Activity    mActivity;
  private gb_FadeInOut   mFadeInOut;
  private gb_Options     mOptions;
  private gb_TimeMachine mTimeMachine;

  private gb_BlockyView mBlockyView;

  private gb_MultiWheelMode  mMultiWheelMode;
  private gb_WheelView       mWheelView;
  private gb_WheelController mWheelController;
  private gb_WheelIndexer    mWheelIndexer;

  private bool mIsInitialized;

} // class gb_EventHandler
