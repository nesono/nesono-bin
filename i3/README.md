# README for i3 configuration

In general, the setup should work after calling `install_nesono_bin`.

## HDPI setup

### Xorg configuration

Add the following to yout $HOME/.Xresources file for HDPI displays (tweak the dpi number to your liking)

```
! Fonts {{{
Xft.antialias: true
Xft.hinting:   true
Xft.rgba:      rgb
Xft.hintstyle: hintfull
Xft.dpi:       150
! }}}
```

### Sublime Text 3

Add the following settings to Sublime Text for HDPI

```json
{
	"font_size": 10,
	...
	"font_options":
	[
		"subpixel_antialias"
	],
	"ignored_packages":
	[
		"Vintage"
	],
	"ui_scale": 1.5
}
```
