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
 * 2. Actual game changing things, like switching weapons, are done through
 * network - even for the current player, even for the single-player game.
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
    case gb_Level.JustLoaded: initialize(); // fall through
    case gb_Level.Loaded:     break;
    }

    if (!multiplayer)
    {
      // Thaw regardless of the option to prevent player being locked frozen
      // after changing options.
      if (mActivity.isNone())                  mTimeMachine.thaw();
      else if (mOptions.isTimeFreezeEnabled()) mTimeMachine.freeze();
    }

    if (!mActivity.isNone() && (gb_Player.isDead() || isDisabledOnAutomap()))
    {
      close();
    }
  }

  /**
   * This function processes key bindings specific for Gearbox.
   */
  override
  void consoleProcess(ConsoleEvent event)
  {
    if (!mIsInitialized || isDisabledOnAutomap()) return;

    switch (gb_EventProcessor.process(event, mOptions.isSelectOnKeyUp()))
    {
    case InputToggleWeaponMenu: toggleWeapons(); break;
    case InputConfirmSelection: confirmSelection(); close(); break;
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
    if (!mIsInitialized || isDisabledOnAutomap() || gamestate != GS_LEVEL) return false;

    if (mOptions.getViewType() == VIEW_TYPE_WHEEL && mOptions.isMouseInWheel()
        && mWheelController.process(event))
    {
      return true;
    }

    int input = gb_InputProcessor.process(event);

    if (mActivity.isWeapons())
    {
      switch (input)
      {
      case InputSelectNextWeapon: mWeaponMenu.selectNextWeapon(); mWheelController.reset(); break;
      case InputSelectPrevWeapon: mWeaponMenu.selectPrevWeapon(); mWheelController.reset(); break;
      case InputConfirmSelection: confirmSelection(); close(); break;
      case InputClose:            close(); break;

      default:
        if (!gb_Input.isSlot(input)) return false;
        mWheelController.reset();
        mWeaponMenu.selectSlot(gb_Input.getSlot(input));
        break;
      }

      return true;
    }
    else if (mActivity.isNone())
    {
      mWheelController.reset();

      if (gb_Input.isSlot(input) && mOptions.isOpenOnSlot())
      {
        int slot = gb_Input.getSlot(input);

        if (mOptions.isNoMenuIfOne() && mWeaponMenu.isOneWeaponInSlot(slot))
        {
          mWeaponMenu.selectSlot(slot);
          gb_Sender.sendSelectEvent(mWeaponMenu.confirmSelection());
        }
        else if (mWeaponMenu.selectSlot(slot))
        {
          mSounds.playToggle();
          mActivity.openWeapons();
          mWheelController.setIsActive(true);
        }
        else
        {
          return false;
        }

        return true;
      }

      if (!mOptions.isOpenOnScroll()) return false;

      switch (input)
      {
      case InputSelectNextWeapon: toggleWeapons(); mWeaponMenu.selectNextWeapon(); return true;
      case InputSelectPrevWeapon: toggleWeapons(); mWeaponMenu.selectPrevWeapon(); return true;
      }
    }

    return false;
  }

  override
  void networkProcess(ConsoleEvent event)
  {
    gb_Change change;
    gb_NeteventProcessor.process(event, change);
    mChanger.change(change);
  }

  override
  void renderOverlay(RenderEvent event)
  {
    if (!mIsInitialized) return;

    if (!mTextureCache.isLoaded) mTextureCache.load();

    mCaption.show(event.fracTic, mOptions.getColor());

    mFadeInOut.fadeInOut((mActivity.isNone()) ? -0.1 : 0.2);
    double alpha = mFadeInOut.getAlpha();

    if (!mActivity.isWeapons() && alpha == 0.0) return;

    gb_ViewModel viewModel;
    mWeaponMenu.fill(viewModel);

    gb_Dim.dim(alpha, mOptions);

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
      int selectedViewIndex = mWheelIndexer.getSelectedIndex();
      mWeaponMenu.setSelectedIndexFromView(viewModel, selectedViewIndex);
      if (selectedViewIndex != -1) viewModel.selectedWeaponIndex = selectedViewIndex;
      int selectedIndex = mWeaponMenu.getSelectedIndex();

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

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private play
  bool isDisabledOnAutomap() const
  {
    return automapActive && !mOptions.isOnAutomap();
  }

  private ui
  void toggleWeapons()
  {
    if (mActivity.isWeapons()) close();
    else openWeapons();
  }

  private ui
  void openWeapons()
  {
    if (gb_Player.isDead()) return;

    mWeaponMenu.setSelectedWeapon(gb_WeaponWatcher.current());
    mSounds.playToggle();
    mActivity.openWeapons();

    // Note that we update wheel controller active status even if wheel is not
    // active. In that case, the controller won't do anything because of the
    // check in inputProcess function.
    mWheelController.setIsActive(true);
  }

  private clearscope
  void close()
  {
    mSounds.playToggle();
    mActivity.close();

    // Note that we update wheel controller active status even if wheel is not
    // active. In that case, the controller won't do anything because of the
    // check in inputProcess function.
    mWheelController.setIsActive(false);
  }

  private ui
  void confirmSelection()
  {
    gb_Sender.sendSelectEvent(mWeaponMenu.confirmSelection());
  }

  enum ViewTypes
  {
    VIEW_TYPE_BLOCKY = 0,
    VIEW_TYPE_WHEEL  = 1,
  }

  private
  void initialize()
  {
    mOptions         = gb_Options.from();
    mSounds          = gb_Sounds.from(mOptions);

    gb_WeaponData weaponData;
    gb_WeaponDataLoader.load(weaponData);
    mWeaponMenu      = gb_WeaponMenu.from(weaponData, mOptions, mSounds);

    mActivity        = gb_Activity.from();
    mFadeInOut       = gb_FadeInOut.from();
    mTimeMachine     = gb_TimeMachine.from();

    mTextureCache    = gb_TextureCache.from();
    mText            = gb_Text.from(mTextureCache);
    mCaption         = gb_Caption.from(mText);
    mChanger         = gb_Changer.from(mCaption, mOptions);

    mBlockyView      = gb_BlockyView.from(mTextureCache, mOptions);

    mMultiWheelMode  = gb_MultiWheelMode.from(mOptions);
    mWheelView       = gb_WheelView.from(mOptions, mMultiWheelMode, mText, mTextureCache);
    mWheelController = gb_WheelController.from(mOptions);
    mWheelIndexer    = gb_WheelIndexer.from(mMultiWheelMode);

    mIsInitialized = true;
  }

  private gb_Options     mOptions;
  private gb_Sounds      mSounds;
  private gb_WeaponMenu  mWeaponMenu;
  private gb_Activity    mActivity;
  private gb_FadeInOut   mFadeInOut;
  private gb_TimeMachine mTimeMachine;

  private gb_TextureCache mTextureCache;
  private gb_Text         mText;
  private gb_Caption      mCaption;
  private gb_Changer      mChanger;

  private gb_BlockyView mBlockyView;

  private gb_MultiWheelMode  mMultiWheelMode;
  private gb_WheelView       mWheelView;
  private gb_WheelController mWheelController;
  private gb_WheelIndexer    mWheelIndexer;

  private bool mIsInitialized;

} // class gb_EventHandler
