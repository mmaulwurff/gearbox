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

class gb_Options
{

  static
  gb_Options from()
  {
    let result = new("gb_Options");

    result.mScale                  = gb_Cvar.from("gb_scale");
    result.mColor                  = gb_Cvar.from("gb_color");
    result.mDimColor               = gb_Cvar.from("gb_dim_color");
    result.mViewType               = gb_Cvar.from("gb_view_type");
    result.mIsDimEnabled           = gb_Cvar.from("gb_enable_dim");
    result.mWheelTint              = gb_Cvar.from("gb_wheel_tint");
    result.mMultiWheelLimit        = gb_Cvar.from("gb_multiwheel_limit");
    result.mShowTags               = gb_Cvar.from("gb_show_tags");
    result.mShowWeaponTagsOnChange = gb_Cvar.from("DisplayNameTags");
    result.mIsPositionLocked       = gb_Cvar.from("gb_lock_positions");

    result.mOpenOnScroll           = gb_Cvar.from("gb_open_on_scroll");
    result.mOpenOnSlot             = gb_Cvar.from("gb_open_on_slot");
    result.mMouseInWheel           = gb_Cvar.from("gb_mouse_in_wheel");
    result.mSelectOnKeyUp          = gb_Cvar.from("gb_select_on_key_up");
    result.mNoMenuIfOne            = gb_Cvar.from("gb_no_menu_if_one");
    result.mTimeFreeze             = gb_Cvar.from("gb_time_freeze");
    result.mOnAutomap              = gb_Cvar.from("gb_on_automap");
    result.mEnableSounds           = gb_Cvar.from("gb_enable_sounds");

    result.mMouseSensitivityX      = gb_Cvar.from("gb_mouse_sensitivity_x");
    result.mMouseSensitivityY      = gb_Cvar.from("gb_mouse_sensitivity_y");

    return result;
  }

  int  getViewType()                 const { return mViewType              .getInt();     }
  int  getScale()                    const { return mScale                 .getInt();     }
  int  getColor()                    const { return mColor                 .getInt();     }
  int  getDimColor()                 const { return mDimColor              .getInt();     }
  bool isDimEnabled()                const { return mIsDimEnabled          .getBool();    }
  bool getWheelTint()                const { return mWheelTint             .getBool();    }
  int  getMultiWheelLimit()          const { return mMultiWheelLimit       .getInt();     }
  bool isShowingTags()               const { return mShowTags              .getBool();    }
  bool isShowingWeaponTagsOnChange() const { return mShowWeaponTagsOnChange.getInt() & 2; }
  bool isPositionLocked()            const { return mIsPositionLocked      .getBool();    }

  bool isOpenOnScroll()              const { return mOpenOnScroll          .getBool();    }
  bool isOpenOnSlot()                const { return mOpenOnSlot            .getBool();    }
  bool isMouseInWheel()              const { return mMouseInWheel          .getBool();    }
  bool isSelectOnKeyUp()             const { return mSelectOnKeyUp         .getBool();    }
  bool isNoMenuIfOne()               const { return mNoMenuIfOne           .getBool();    }
  bool isTimeFreezeEnabled()         const { return mTimeFreeze            .getBool();    }
  bool isOnAutomap()                 const { return mOnAutomap             .getBool();    }
  bool isSoundEnabled()              const { return mEnableSounds          .getBool();    }

  Vector2 getMouseSensitivity() const
  {
    return (mMouseSensitivityX.getDouble(), mMouseSensitivityY.getDouble());
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private gb_Cvar mScale;
  private gb_Cvar mColor;
  private gb_Cvar mDimColor;
  private gb_Cvar mViewType;
  private gb_Cvar mIsDimEnabled;
  private gb_Cvar mWheelTint;
  private gb_Cvar mMultiWheelLimit;
  private gb_Cvar mShowTags;
  private gb_Cvar mShowWeaponTagsOnChange;
  private gb_Cvar mIsPositionLocked;

  private gb_Cvar mOpenOnScroll;
  private gb_Cvar mOpenOnSlot;
  private gb_Cvar mMouseInWheel;
  private gb_Cvar mSelectOnKeyUp;
  private gb_Cvar mNoMenuIfOne;
  private gb_Cvar mTimeFreeze;
  private gb_Cvar mOnAutomap;
  private gb_Cvar mEnableSounds;

  private gb_Cvar mMouseSensitivityX;
  private gb_Cvar mMouseSensitivityY;

} // class gb_Options
