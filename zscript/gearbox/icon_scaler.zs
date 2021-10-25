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

class gb_IconScaler
{

  static
  double, double getMaxWidthHeight(gb_ViewModel viewModel)
  {
    double maxWidth  = 0;
    double maxHeight = 0;

    uint nItems = viewModel.tags.size();
    for (uint i = 0; i < nItems; ++i)
    {
      if (viewModel.iconBigs[i]) continue;

      double width  = viewModel.iconWidths[i];
      double height = viewModel.iconHeights[i];
      bool   isWide = (width > height);
      if (!isWide)
      {
        double tmp = width;
        width      = height;
        height     = tmp;
      }

      maxWidth  = max(maxWidth,  width);
      maxHeight = max(maxHeight, height);
    }

    return maxWidth, maxHeight;
  }

  static
  double calculateMaxAllowedScale(int allowedWidth, int allowedHeight, double width, double height)
  {
    double xScale = allowedWidth  / width;
    double yScale = allowedHeight / height;

    return min(xScale, yScale);
  }

} // class gb_IconScaler
