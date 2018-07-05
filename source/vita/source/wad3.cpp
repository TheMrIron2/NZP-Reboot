/*
Copyright (C) 2012 leileilol

Used code from "Engoo" modify by leileilol

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

#include "quakedef.h"
#include "wad3.h"

/*
===============
BestColor
===============
*/
byte BestColor (int r, int g, int b, int start, int stop)
{
	int	i;
	int	dr, dg, db;
	int	bestdistortion, distortion;
	int	berstcolor;
	byte	*pal;

//
// let any color go to 0 as a last resort
//
	bestdistortion = 256*256*4;
	berstcolor = 0;

	pal = host_basepal + start*3;
	for (i=start ; i<= stop ; i++)
	{
		dr = r - (int)pal[0];
		dg = g - (int)pal[1];
		db = b - (int)pal[2];
		pal += 3;
		distortion = dr*dr + dg*dg + db*db;
		if (distortion < bestdistortion)
		{
			if (!distortion)
				return i;		// perfect match

			bestdistortion = distortion;
			berstcolor = i;
		}
	}

	return berstcolor;
}

byte *W_ConvertWAD3Texture(miptex_t *tex)
{
	byte	*in, *data, *out, *pal;
	int		d, p;

	in		= (byte *)((int) tex + tex->offsets[0]);
	data	= out = (byte *)malloc(tex->width * tex->height * 4);

	if (!data)
		return NULL;

	int image_width		= tex->width;
	int image_height	= tex->height;
	pal				= in + (((image_width * image_height) * 85) >> 6);
	pal				+= 2;

	for (d = 0;d < image_width * image_height;d++)
	{
		p = *in++;
		if (tex->name[0] == '{' && p == 255)
			out[0] = out[1] = out[2] = out[3] = 0;
		else
		{
			p *= 3;
			out[0] = pal[p];
			out[1] = pal[p+1];
			out[2] = pal[p+2];
			out[3] = 255;
		}
		out += 4;
	}
	return data;
}

extern byte *host_otherpal;
extern int host_fullbrights;

int FindOurColor(miptex_t *tex)
{
	byte	*in, *data, *out, *pal;
	int		d, p, color;

	in		= (byte *)((int) tex + tex->offsets[0]);
	data	= out = (byte *)malloc(tex->width * tex->height * 4);

	if (!data)
		return 0;

	int image_width		= tex->width;
	int image_height	= tex->height;
	pal				= host_otherpal;

	for (d = 0;d < image_width * image_height;d++)
	{
		p = *in++;
		{
			if (p > host_fullbrights){
				color = p;	// we got a fullbright so we can sue it.
				return color;
			} else
			color = p;
		}
	}

	return color;
}