/*
 *  Copyright (C) 1998 Friedrich Leisch
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <pgm.h>



int readpgm(char **filename, int *image)
{
  FILE *fp;
  gray gmaxval;
  gray **gimage;
  int cols, rows, k;

  fp = fopen(*filename, "r");

  if(fp==NULL){
    printf("Can't open %s for reading\n", *filename);
    return(0);
  }

  gimage = pgm_readpgm(fp, &cols, &rows, &gmaxval);  
  
  for(k=0; k<rows*cols; k++){
      image[k] = (int) (*gimage)[k];
  }
}


int readpgminit(char **filename, int *cols, int *rows, int *maxval)
{
  FILE *fp;
  gray gmaxval;
  int format;
  
  fp = fopen(*filename, "r");

  if(fp==NULL){
    printf("Can't open %s for reading\n", *filename);
    return(0);
  }
  
  pgm_readpgminit(fp, cols, rows, &gmaxval, &format);
  *maxval = (int)gmaxval;
  
  fclose(fp);
}


int writepgm(char **filename, int *image, int *cols, int *rows, int
	     *maxval, int *forceplain)
{
  FILE *fp;
  gray gmaxval;
  gray **gimage;
  int k;

  fp = fopen(*filename, "w");

  if(fp==NULL){
    printf("Can't open %s for writing\n", *filename);
    return(0);
  }

  gmaxval = (gray)(*maxval);
  gimage = pgm_allocarray(*cols, *rows);
  for(k=0; k<(*rows) * (*cols); k++){
      (*gimage)[k] = (gray) image[k];
  }

  pgm_writepgm(fp, gimage, *cols, *rows, gmaxval, *forceplain);  
  fclose(fp);
}




