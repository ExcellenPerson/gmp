/* mpz_kronecker_si -- mpz+long Kronecker/Jacobi symbol. */

/*
Copyright 1999, 2000, 2001 Free Software Foundation, Inc.

This file is part of the GNU MP Library.

The GNU MP Library is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or (at your
option) any later version.

The GNU MP Library is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
License for more details.

You should have received a copy of the GNU Lesser General Public License
along with the GNU MP Library; see the file COPYING.LIB.  If not, write to
the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
MA 02111-1307, USA.
*/

#include "gmp.h"
#include "gmp-impl.h"
#include "longlong.h"


/* This implementation depends on BITS_PER_MP_LIMB being even, so that
   (a/2)^BITS_PER_MP_LIMB = 1 and so there's no need to pay attention to how
   many low zero limbs are stripped.  */
#if BITS_PER_MP_LIMB % 2 != 0
Error, error, unsupported BITS_PER_MP_LIMB
#endif


/* After the absolute value of b is established it's treated as an unsigned
   long, because 0x80..00 doesn't fit in a signed long. */

int
mpz_kronecker_si (mpz_srcptr a, long b)
{
  mp_srcptr  a_ptr = PTR(a);
  int        a_size;
  mp_limb_t  a_rem;
  int        result_bit1;

  a_size = SIZ(a);
  if (a_size == 0)
    return JACOBI_0S (b);

  if ((b & 1) != 0)
    {
      result_bit1 = JACOBI_BSGN_SS_BIT1 (a_size, b);
    }
  else
    {
      mp_limb_t  a_low = a_ptr[0];
      int        twos;

      if (b == 0)
        return JACOBI_LS0 (a_low, a_size);   /* (a/0) */

      if (! (a_low & 1))
        return 0;  /* (even/even)=0 */

      /* (a/2)=(2/a) for a odd */
      count_trailing_zeros (twos, b);  
      b >>= twos;
      result_bit1 = (JACOBI_TWOS_U_BIT1 (twos, a_low)
                     ^ JACOBI_BSGN_SS_BIT1 (a_size, b));
    }

  b = ABS (b);

  if (b == 1)
    return JACOBI_BIT1_TO_PN (result_bit1);  /* (a/1)=1 for any a */

  result_bit1 ^= JACOBI_ASGN_SU_BIT1 (a_size, b);
  a_size = ABS(a_size);

  /* (a/b) = (a mod b / b) */
  JACOBI_MOD_OR_MODEXACT_1_ODD (result_bit1, a_rem, a_ptr, a_size,
                                (unsigned long) b);
  return mpn_jacobi_base (a_rem, (mp_limb_t) (unsigned long) b, result_bit1);
}


