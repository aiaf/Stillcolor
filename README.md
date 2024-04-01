

# Stillcolor for macOS
<img src="https://github.com/aiaf/Stillcolor/assets/119462/26f4fe39-44bb-436d-9348-fc5ba9e8dfde" align=left width=256>
Save your eyesight and disable temporal dithering on your Mac with Stillcolor, a lightweight menu bar app for macOS running on Apple M1/M2/M3.  

* * *

  

**Why?**


[Heaps](https://ledstrain.org/) of [people](https://www.reddit.com/r/PWM_Sensitive) are sensitive to certain properties of modern displays such as blue light, [PWM](https://www.notebookcheck.net/Why-Pulse-Width-Modulation-PWM-is-such-a-headache.270240.0.html), and [temporal dithering (FRC)](https://en.wikipedia.org/wiki/Frame_rate_control) which alternates pixel colors at the speed of your display's refresh rate, tricking your eyes into perceiving a wider range of colors than the display can actually produce.

These sensitivities manifest as eyestrain and fatigue, dry eyes, headache, nausea, inability to focus, and other physical symptoms.

There's even a [petition](https://www.change.org/p/apple-add-accessibility-options-to-reduce-eye-strain-and-support-vision-disability-sufferers) urging Apple to make use of these technologies known and to implement accessbility options.

While there are apps and accessories to help dim blue light, and plenty of flicker-free monitors, temporal dithering can happen at the GPU level with no visible option to disable it (such as the case in Apple silicon Macs).

Stillcolor allows you to disable GPU/DCP-generated temporal dithering from user space, helping massively reduce eyestrain with little to no degradation in image quality.

## Caveats
Note that while Stillcolor is 100% confirmed to remove GPU/DCP-generated temporal dithering, which is applied directly to the pixel framebuffer right before it's sent to the external/embedded display, the display panel's timing contoller (TCON) may still apply its own dithering/FRC to achieve advertised color bit depth. Whether or not Apple displays actively use TCON dithering in addition to DCP/GPU dithering is under investigation.


## Story and write-up
[Thread on LEDStrain](https://ledstrain.org/d/2686-i-disabled-dithering-on-apple-silicon-introducing-stillcolor-macos-m1m2m3/)

## Stillcolor in action
See this timeblend video of how your screen looks like with temporal dithering vs without:

[https://www.youtube.com/watch?v=D9AZqJH-U-U](https://www.youtube.com/watch?v=D9AZqJH-U-U) 

## Requirements
- Apple silicon Mac e.g. M1/M2/M3
- macOS >= 13

## Installation
Head over to [Releases](https://github.com/aiaf/Stillcolor/releases) and download the latest zip.

Unzip Stillcolor.app to your Applications folder and launch.

Select “Launch a login” to make this app run automatically and disable dithering whenever your computer starts.

## Verifying status of temporal dithering

To check wether the app did the job, run the following in Terminal:

`ioreg -lw0 | grep -i enableDither`

Should see 1 or more `”enableDither” = No` corresponding to each live or past display.

To re-enable dithering simply uncheck “Disable Dithering.”

`enableDither` is reset back to `Yes` on computer restart that's why you need to launch this app on login.

To verify that your GPU is not applying dithering you can try a visual test by visiting [Lagom LCD Gradient (banding) test](http://www.lagom.nl/lcd-test/gradient.php) 

Set your built-in display’s color profile to sRGB at full brightness and look carefully at the gray parts, you should be able to see subtle banding when you disable dithering which happens in realtime.

And if you're sensitive to temporal dithering you should notice a lot less eyestrain while dithering is disabled.

A more complicated approach is to use a [video capture card](https://www.blackmagicdesign.com/products/ultrastudio/techspecs/W-DLUS-12) and record your display's uncompressed output then run the recording through ffmpeg to visualize dithering with something like the following command: 

`ffmpeg -i input.mov -sws_flags full_chroma_int+bitexact+accurate_rnd -vf "format=gbrp,tblend=all_mode=grainextract,eq=contrast=-60" -c:v v210 -pix_fmt yuv422p10le diff.mov`

## Roadmap
- Make this app compatible macOS 11+
- Create a foolproof and easy dithering test
- Intel Macs?
- iOS?





