# Stillcolor for macOS
Stillcolor is a lightweight menu bar app for macOS which disables temporal dithering on Apple Silicon GPUs M1/M2/M3.

A lot of people are sensitive to [temporal dithering](https://en.wikipedia.org/wiki/Frame_rate_control) which alternates pixel colors at the speed of your display's refresh rate, causing eyestrain and various other symptoms.

Stillcolor activates on login and whenever a new display connects.

## Requirements
- Apple Silicon eg. M1/M2/M3
- macOS >= 13

Tested on macOS 14 with M2 and M3 Max.

## Installation
Head over to [Releases](https://github.com/aiaf/Stillcolor/releases) and download the latest zip. Unzip Stillcolor.app to your Applications folder and launch.

Select “Launch a Login” to make this app run automatically and disable dithering whenever your computer starts.

## Verifying status of temporal dithering

To check wether the app did the job, run the following in Terminal:

`ioreg -lw0 | grep -i enableDither`

Should see 1 or more `”enableDither” = No` corresponding to each live or past display.

To re-enable dithering simply uncheck “Disable Dithering.”

`enableDither` is reset back to `Yes` on computer restart that's why you need to launch this app on login.

To verify that your GPU is not applying dithering you can try a visual test by visiting [Lagom LCD Gradient (banding) test](http://www.lagom.nl/lcd-test/gradient.php) 

Set your built-in display’s color profile to sRGB at full brightness and look carefully at the gray parts, you should be able to see subtle banding when you disable dithering which happens in realtime.

And if you're sensitive to temporal dithering you should notice a lot less eyestrain while dithering is disabled.

A more complicated approach is to use a [video capture card](https://www.blackmagicdesign.com/products/ultrastudio/techspecs/W-DLUS-12) and record your display's uncompressed output then run the recording through ffmpeg to visualize dithering with the following command: 

`ffmpeg -i input.mov -sws_flags full_chroma_int+bitexact+accurate_rnd -vf "format=gbrp,tblend=all_mode=grainextract,eq=contrast=-60" -c:v v210 -pix_fmt yuv422p10le diff.mov`

## Roadmap
- Make this app compatible macOS 11+
- Test and verify various Macs M1 Pro, Max, etc
- Make it work with Intel Macs?
- Create a foolproof and easy dithering test





