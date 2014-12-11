!=======================================================================
SUBROUTINE SetProg


   ! This routine sets the version number.  By doing it this way instead
   !   of the old way of initializing it in a module, we will no longer
   !   have to recompile everything every time we change versions.


USE                                NWTC_Library


IMPLICIT                           NONE


   ! Local Variables:

CHARACTER(26)                   :: Version = 'v3.05.00a-adp, 09-Nov-2012'             ! String containing the current version.



ProgName = 'WT_Perf'

IF ( ReKi == 4 )  THEN     ! Single precision
   ProgVer = ' ('//TRIM( Version )//')'
ELSEIF ( ReKi == 8 )  THEN     ! Double precision
   ProgVer = ' ('//TRIM( Version )//', compiled using double precision)'
ELSE                       ! Unknown precision - it should be impossible to compile using a KIND that is not 4 or 8, but I'll put this check here just in case.
   ProgVer = ' ('//TRIM( Version )//', compiled using '//TRIM( Int2LStr( ReKi ) )//'-byte precision)'
ENDIF


RETURN
END SUBROUTINE SetProg
