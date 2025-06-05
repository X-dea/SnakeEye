// Copyright (C) 2020-2025 Jason C.H.

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

#include <opencv2/opencv.hpp>

#include "common.hpp"

using namespace cv;

FFI_EXPORT void ProcessImage(uint8_t* input, uint8_t* output) {
  auto input_mat = Mat(Size(32, 24), CV_32FC1, input);
  auto output_mat = Mat(Size(320, 240), CV_8UC4, output);

  flip(input_mat, input_mat, 1);
  normalize(input_mat, input_mat, 0, 255, NORM_MINMAX);

  Mat temp;
  input_mat.convertTo(temp, CV_8UC1);
  fastNlMeansDenoising(temp, temp, 30.0f);

  applyColorMap(temp, temp, COLORMAP_JET);
  cvtColor(temp, temp, COLOR_BGR2BGRA);
  resize(temp, output_mat, Size(320, 240));
}