#include <iostream>
#include <opencv2/opencv.hpp>

#include "common.hpp"

using namespace cv;
using namespace std;

FFI_EXPORT void ComposeImage(uint8_t* input, uint8_t* composed) {
  auto composed_mat = Mat(Size(320, 240), CV_8UC4, composed);
  auto input_mat = Mat(Size(32, 24), CV_32FC1, input);
  flip(input_mat, input_mat, 1);

  normalize(input_mat, input_mat, 0, 255, NORM_MINMAX);

  Mat temp;
  input_mat.convertTo(temp, CV_8UC1);
  fastNlMeansDenoising(temp, temp, 40.0f);

  applyColorMap(temp, temp, COLORMAP_JET);
  cvtColor(temp, temp, COLOR_BGR2BGRA);
  resize(temp, composed_mat, Size(320, 240));
}