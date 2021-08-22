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

    bool isClosed = mActivity.isNone();

    // Thaw regardless of the option to prevent player being locked frozen after
    // changing options.
    if (isClosed) mFreezer.thaw();
    else          mFreezer.freeze();

    if (!isClosed && (gb_Player.isDead() || isDisabledOnAutomap()))
    {
      close();
    }

    if (isClosed)
    {
      // Watch for the current weapon, because player can change it without
      // Gearbox. Also handles the case when Gearbox hasn't been opened yet,
      // initializing weapon menu.
      mWeaponMenu.setSelectedWeapon(gb_WeaponWatcher.current());
    }
    else if (mOptions.getViewType() == VIEW_TYPE_WHEEL)
    {
      mWheelController.process();
    }

    mInventoryUser.use();
  }

  /**
   * This function processes key bindings specific for Gearbox.
   */
  override
  void consoleProcess(ConsoleEvent event)
  {
    if (players[consolePlayer].mo == NULL) return;

    if (!mIsInitialized || isDisabledOnAutomap()) return;
    if (isPlayerFrozen() && mActivity.isNone()) return;

    switch (gb_EventProcessor.process(event, mOptions.isSelectOnKeyUp()))
    {
    case InputToggleWeaponMenu: toggleWeapons(); break;
    case InputConfirmSelection: confirmSelection(); close(); break;
    case InputToggleInventoryMenu: toggleInventory(); break;
    case InputRotateWeaponPriority: rotateWeaponPriority(); break;
    case InputRotateWeaponSlot:     rotateWeaponSlot(); break;
    }

    if (!mActivity.isNone()) mWheelController.reset();
  }

  /**
   * This function provides latching to existing key bindings, and processing mouse input.
   */
  override
  bool inputProcess(InputEvent event)
  {
    if (players[consolePlayer].mo == NULL) return false;
    if (!mIsInitialized || isDisabledOnAutomap() || gameState != GS_LEVEL) return false;
    if (isPlayerFrozen() && mActivity.isNone()) return false;

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
    else if (mActivity.isInventory())
    {
      switch (input)
      {
      case InputSelectNextWeapon: mInventoryMenu.selectNext(); mWheelController.reset(); break;
      case InputSelectPrevWeapon: mInventoryMenu.selectPrev(); mWheelController.reset(); break;
      case InputConfirmSelection: confirmSelection(); close(); break;
      case InputClose:            close(); break;

      default:
      {
        if (!gb_Input.isSlot(input)) return false;
        mWheelController.reset();
        int slot = gb_Input.getSlot(input);
        int index = (slot == 0) ? 9 : slot - 1;
        mInventoryMenu.setSelectedIndex(index);
        break;
      }
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
    if (players[consolePlayer].mo == NULL) return;

    int input = mNeteventProcessor.process(event);

    switch (input)
    {
    case InputResetCustomOrder: resetCustomOrder(); break;
    }
  }

  override
  void renderOverlay(RenderEvent event)
  {
    if (!mIsInitialized) return;

    if (!mTextureCache.isLoaded) mTextureCache.load();

    mCaption.show();
    mFadeInOut.fadeInOut((mActivity.isNone()) ? -0.1 : 0.2);
    gb_Blur.setEnabled(mOptions.isBlurEnabled() && !mActivity.isNone());

    double alpha = mFadeInOut.getAlpha();

    if (mActivity.isNone() && alpha == 0.0) return;

    gb_ViewModel viewModel;
    if      (mActivity.isWeapons())   mWeaponMenu.fill(viewModel);
    else if (mActivity.isInventory()) mInventoryMenu.fill(viewModel);

    verifyViewModel(viewModel);

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

      if (mActivity.isWeapons()) mWeaponMenu.setSelectedIndexFromView(viewModel, selectedViewIndex);
      else if (mActivity.isInventory()) mInventoryMenu.setSelectedIndex(selectedViewIndex);

      if (selectedViewIndex != -1) viewModel.selectedIndex = selectedViewIndex;

      int selectedIndex;
      selectedIndex = mActivity.isWeapons()
        ? mWeaponMenu.getSelectedIndex()
        : mInventoryMenu.getSelectedIndex();

      mWheelView.setAlpha(alpha);
      mWheelView.setBaseColor(mOptions.getColor());
      mWheelView.setRotating(mActivity.isWeapons());

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

    case VIEW_TYPE_TEXT:
      mTextView.setAlpha(alpha);
      mTextView.setScale(mOptions.getTextScale());
      mTextView.display(viewModel);
      break;

    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private play
  bool isDisabledOnAutomap() const
  {
    return automapActive && !mOptions.isOnAutomap();
  }

  private play
  bool isPlayerFrozen() const
  {
    return players[consolePlayer].isTotallyFrozen() && !mOptions.isFrozenCanOpen();
  }

  private ui
  void toggleWeapons()
  {
    if (mActivity.isWeapons()) close();
    else openWeapons();
  }

  private ui
  void toggleInventory()
  {
    if (mActivity.isInventory()) close();
    else openInventory();
  }

  private ui
  void openWeapons()
  {
    if (gb_Player.isDead()) return;

    mWeaponMenu.setSelectedWeapon(gb_WeaponWatcher.current());
    mSounds.playToggle();
    mActivity.openWeapons();
  }

  private ui
  void openInventory()
  {
    if (gb_Player.isDead()) return;

    mSounds.playToggle();
    mActivity.openInventory();
  }

  private clearscope
  void close()
  {
    mSounds.playToggle();
    mActivity.close();
  }

  private ui
  void confirmSelection()
  {
    if (mActivity.isWeapons())
    {
      gb_Sender.sendSelectEvent(mWeaponMenu.confirmSelection());
    }
    else if (mActivity.isInventory())
    {
      gb_Sender.sendUseItemEvent(mInventoryMenu.confirmSelection());
    }
  }

  private ui
  void rotateWeaponPriority()
  {
    if (mActivity.isWeapons())
    {
      gb_CustomWeaponOrderStorage.savePriorityRotation(mWeaponSetHash, mWeaponMenu.getSelectedIndex());
      mWeaponMenu.rotatePriority();
    }
  }

  private ui
  void rotateWeaponSlot()
  {
    if (mActivity.isWeapons())
    {
      gb_CustomWeaponOrderStorage.saveSlotRotation(mWeaponSetHash, mWeaponMenu.getSelectedIndex());
      mWeaponMenu.rotateSlot();
    }
  }

  private
  void resetCustomOrder()
  {
    gb_CustomWeaponOrderStorage.reset(mWeaponSetHash);
    gb_WeaponData weaponData;
    gb_WeaponDataLoader.load(weaponData);
    mWeaponMenu = gb_WeaponMenu.from(weaponData, mOptions, mSounds);
  }

  private ui
  void verifyViewModel(gb_ViewModel model)
  {
    uint nTags           = model.tags        .size();
    uint nSlots          = model.slots       .size();
    uint nIndices        = model.indices     .size();
    uint nIcons          = model.icons       .size();
    uint nIconScaleXs    = model.iconScaleXs .size();
    uint nIconScaleYs    = model.iconScaleYs .size();
    uint nQuantities1    = model.quantity1   .size();
    uint nQuantitiesMax1 = model.maxQuantity1.size();
    uint nQuantities2    = model.quantity2   .size();
    uint nQuantitiesMax2 = model.maxQuantity2.size();

    if (nTags > 0
        && (model.selectedIndex >= nTags
            || nTags != nSlots
            || nTags != nIndices
            || nTags != nIcons
            || nTags != nIconScaleXs
            || nTags != nIconScaleYs
            || nTags != nQuantities1
            || nTags != nQuantitiesMax1
            || nTags != nQuantities2
            || nTags != nQuantitiesMax2))
    {
      Console.printf("Bad view model:\n"
                     "selected index: %d,\n"
                     "tags: %d,\n"
                     "slots: %d,\n"
                     "indices: %d,\n"
                     "icons: %d,\n"
                     "icon scale X: %d,\n"
                     "icon scale Y: %d,\n"
                     "quantities 1: %d,\n"
                     "max quantities 1: %d,\n"
                     "quantities 2: %d,\n"
                     "max quantities 2: %d,\n"
                    , model.selectedIndex
                    , nTags
                    , nSlots
                    , nIndices
                    , nIcons
                    , nIconScaleXs
                    , nIconScaleYs
                    , nQuantities1
                    , nQuantitiesMax1
                    , nQuantities2
                    , nQuantitiesMax2
                    );
    }
  }

  enum ViewTypes
  {
    VIEW_TYPE_BLOCKY = 0,
    VIEW_TYPE_WHEEL  = 1,
    VIEW_TYPE_TEXT   = 2,
  }

  private
  void initialize()
  {
    mOptions         = gb_Options.from();
    mFontSelector    = gb_FontSelector.from();
    mSounds          = gb_Sounds.from(mOptions);

    gb_WeaponData weaponData;
    gb_WeaponDataLoader.load(weaponData);
    mWeaponSetHash   = gb_CustomWeaponOrderStorage.calculateHash(weaponData);
    mWeaponMenu      = gb_WeaponMenu.from(weaponData, mOptions, mSounds);
    gb_CustomWeaponOrderStorage.applyOperations(mWeaponSetHash, mWeaponMenu);
    mInventoryMenu   = gb_InventoryMenu.from(mSounds);

    mActivity        = gb_Activity.from();
    mFadeInOut       = gb_FadeInOut.from();
    mFreezer         = gb_Freezer.from(mOptions);

    mTextureCache    = gb_TextureCache.from();
    mCaption         = gb_Caption.from();
    mInventoryUser   = gb_InventoryUser.from();
    mChanger         = gb_Changer.from(mCaption, mOptions, mInventoryUser);
    mNeteventProcessor = gb_NeteventProcessor.from(mChanger);

    mBlockyView      = gb_BlockyView.from(mTextureCache, mOptions, mFontSelector);
    mTextView        = gb_TextView.from(mOptions, mFontSelector);

    mMultiWheelMode  = gb_MultiWheelMode.from(mOptions);
    let screen       = gb_Screen.from(mOptions);
    mWheelView       = gb_WheelView.from( mOptions
                                        , mMultiWheelMode
                                        , mTextureCache
                                        , screen
                                        , mFontSelector
                                        );
    mWheelController = gb_WheelController.from(mOptions, screen);
    mWheelIndexer    = gb_WheelIndexer.from(mMultiWheelMode, screen);

    mIsInitialized = true;
  }

  private gb_Options       mOptions;
  private gb_FontSelector  mFontSelector;
  private gb_Sounds        mSounds;

  private string           mWeaponSetHash;
  private gb_WeaponMenu    mWeaponMenu;
  private gb_InventoryMenu mInventoryMenu;
  private gb_Activity      mActivity;
  private gb_FadeInOut     mFadeInOut;
  private gb_Freezer       mFreezer;

  private gb_TextureCache  mTextureCache;
  private gb_Caption       mCaption;
  private gb_InventoryUser mInventoryUser;
  private gb_Changer       mChanger;
  private gb_NeteventProcessor mNeteventProcessor;

  private gb_BlockyView mBlockyView;
  private gb_TextView   mTextView;

  private gb_MultiWheelMode  mMultiWheelMode;
  private gb_WheelView       mWheelView;
  private gb_WheelController mWheelController;
  private gb_WheelIndexer    mWheelIndexer;

  private bool mIsInitialized;

} // class gb_EventHandler
