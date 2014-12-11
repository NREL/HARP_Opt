MODULE WTP_Subs


   ! This module contains WT_Perf-specific subroutines and functions.

   ! It containes the following routines:

   !     SUBROUTINE AllocPar
   !     SUBROUTINE AllocProp
   !     SUBROUTINE CombCase
   !     SUBROUTINE GetAero      ( ISeg, AInd, TInd )
   !     SUBROUTINE GetData
   !     SUBROUTINE GetInds      ( IOmg, IPit, ISpd, IRow, ICol, ITab )
   !     SUBROUTINE GetVel       ( VWndNorm )
   !     SUBROUTINE InductBEM    ( ISeg, ZFound, Converg, AxIndPrevSeg, TanIndPrevSeg )
   !        FUNCTION   AxIndErr     ( AInd, AxIndErr_Curr )
   !        FUNCTION   FindZC       ( AxMin, AxMax, NumStep, ZFound, AxIndLo, AxIndHi, AxIndErr_Curr )
   !        FUNCTION   BinSearch    ( XLo, XHi, Display, AxIndErr_Curr )
   !        SUBROUTINE GetAFTI      ( AInd, TInd, AF, AxIndErr_Curr )
   !        SUBROUTINE NewtRaph     ( AxInd, TanInd, AxIndErr_Curr )
   !        FUNCTION   TanIndErr    ( AxInd, TInd, AxIndErr_Curr )
   !     SUBROUTINE IOInit
   !     SUBROUTINE ParmAnal
   !     FUNCTION   Prandtl      ( R1, R2, SinAFA )
   !     SUBROUTINE RotAnal
   !     SUBROUTINE SetConv

USE                                NWTC_Library


CONTAINS

!=======================================================================
   SUBROUTINE AllocPar


      ! This routine allocates the WT_Perf parameter arrays.


   USE                             WTP_Data

   IMPLICIT                        NONE


      ! Local declarations.

   INTEGER                      :: Sttus                                        ! Status returned from an allocation attempt.



      ! Calculate the size of the parameter arrays and allocate them.

   IF ( OmgDel /= 0.0 )  THEN
      NumOmg = NINT( ( OmgEnd - OmgSt )/OmgDel ) + 1
   ELSE
      NumOmg = 1
   ENDIF

   IF ( PitDel /= 0.0 )  THEN
      NumPit = NINT( ( PitEnd - PitSt )/PitDel ) + 1
   ELSE
      NumPit = 1
   ENDIF

   IF ( SpdDel /= 0.0 )  THEN
      NumSpd = NINT( ( SpdEnd - SpdSt )/SpdDel ) + 1
   ELSE
      NumSpd = 1
   ENDIF

   CALL GetInds ( NumOmg, NumPit, NumSpd, MaxRow, MaxCol, MaxTab )

   ALLOCATE ( CpAry(MaxRow, MaxCol, MaxTab) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the CpAry array.')
   ENDIF

   ALLOCATE ( FlpAry(MaxRow, MaxCol, MaxTab) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the FlpAry array.')
   ENDIF

   ALLOCATE ( PwrAry(MaxRow, MaxCol, MaxTab) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the PwrAry array.')
   ENDIF

   ALLOCATE ( ThrAry(MaxRow, MaxCol, MaxTab) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the ThrAry array.')
   ENDIF

   ALLOCATE ( TrqAry(MaxRow, MaxCol, MaxTab) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the TrqAry array.')
   ENDIF

   ALLOCATE ( RowAry(MaxRow) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the RowAry array.')
   ENDIF

   ALLOCATE ( ColAry(MaxCol) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the ColAry array.')
   ENDIF

   ALLOCATE ( TabAry(MaxTab) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the TabAry array.')
   ENDIF

   ALLOCATE ( OmgAry(NumOmg) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the OmgAry array.')
   ENDIF

   ALLOCATE ( PitAry(NumPit) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the PitAry array.')
   ENDIF

   ALLOCATE ( SpdAry(NumSpd) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the SpdAry array.')
   ENDIF


   RETURN
   END SUBROUTINE AllocPar
!=======================================================================
   SUBROUTINE AllocProp


      ! This routine allocates the WT_Perf property arrays.


   USE                             ProgGen
   USE                             WTP_Data

   IMPLICIT                        NONE


      ! Local declarations.

   INTEGER                      :: Sttus                                        ! Status returned from an allocation attempt.



   ALLOCATE ( AlfaStal(NumSeg) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the AlfaStal array.')
   ENDIF

   ALLOCATE ( AlfShift(NumSeg) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the AlfShift array.')
   ENDIF

   ALLOCATE ( CdMin(NumSeg) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the CdMin array.')
   ENDIF

   ALLOCATE ( Chord(NumSeg) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the Chord array.')
   ENDIF

   ALLOCATE ( DClShift(NumSeg) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the DClShift array.')
   ENDIF

   ALLOCATE ( DelRLoc(NumSeg) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the DelRLoc array.')
   ENDIF

   ALLOCATE ( IndClBrk(NumSeg) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the IndClBrk array.')
   ENDIF

   ALLOCATE ( NumCd(NumSeg) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the NumCd array.')
   ENDIF

   ALLOCATE ( NumCl(NumSeg) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the NumCl array.')
   ENDIF

   ALLOCATE ( PrntElem(NumSeg) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the PrntElem array.')
   ENDIF

   ALLOCATE ( RLoc(NumSeg) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the RLoc array.')
   ENDIF

   ALLOCATE ( RLocND(NumSeg) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the RLocND array.')
   ENDIF

   ALLOCATE ( Thick(NumSeg) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the Thick array.')
   ENDIF

   ALLOCATE ( Twist(NumSeg) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the Twist array.')
   ENDIF


   RETURN
   END SUBROUTINE AllocProp
!=======================================================================
   SUBROUTINE CombCase


      ! This routine performs the analysis for the combined cases.


   USE                             Parameters
   USE                             ProgGen
   USE                             WTP_Data

   IMPLICIT                        NONE


      ! Local declarations.

   LOGICAL                      :: Converged                                    ! Flag indicating RotAnal fully converged on all loops.

   INTEGER                      :: ICase                                        ! Index for the combined case.

   CHARACTER( 23), PARAMETER    :: FmtDaSpc = "( 8F12.3,2F12.4,L5,L7 )"
   CHARACTER( 35), PARAMETER    :: FmtDaTab = "( 8(F12.3,'"//Tab//"'),2(F12.4,'"//Tab//"'),L5,L7 )"
   CHARACTER(142), PARAMETER    :: FmtHdSpc = "( '   WindSpeed         TSR  RotorSpeed       Pitch       Power      Torque" &
                                            //"      Thrust  FlapMoment          Cp          Cq   Cav  Converge' )"
   CHARACTER( 87), PARAMETER    :: FmtHdTab = "( 'WindSpeed"//Tab//"TSR"//Tab//"RotorSpeed"//Tab//"Pitch"//Tab//"Power"//Tab &
                                            //"Torque"//Tab//"Thrust"//Tab//"FlapMoment"//Tab//"Cp"//Tab//"Cq"//Tab//"Cav" &
                                            //"Converge' )"

   CHARACTER( 82), PARAMETER    :: FmtUnSpc = "(8X,A,11X,'-',9X,'rpm',9X,'deg',10X,A,5X,A,8X,A,5X,A,2(11X,'-'),'    -','      -')"
   CHARACTER( 49), PARAMETER    :: FmtUnTab = "(A,'"//Tab//"-"//Tab//"rpm"//Tab//"deg"//Tab//"',A,'"//Tab//"',A,'"//Tab//"',A,'" &
                                            //Tab//"',A,'"//Tab//"-"//Tab//"-"//Tab//"-"//Tab//"-')"



      ! Write header to output file.

   WRITE (UnOu,'(A)')  'Results generated by '//TRIM( ProgName )//TRIM( ProgVer )//' for input file "'//TRIM( InpFile )//'".'
   WRITE (UnOu,'(A)')  'Generated on '//TRIM( DateNow )//' at '//TRIM( TimeNow )//'.'
   WRITE (UnOu,'(A)')  'Input file title:'
   WRITE (UnOu,'(A)')  '  '//TRIM( RunTitle )
   WRITE (UnOu,'(A)')  ' '


   IF ( TabDel )  THEN
      WRITE (UnOu,FmtHdTab)
      WRITE (UnOu,FmtUnTab)  TRIM( ADJUSTL( SpdUnits ) ), TRIM( ADJUSTL( PwrUnits ) ), TRIM( ADJUSTL( MomUnits ) ), &
                             TRIM( ADJUSTL( FrcUnits ) ), TRIM( ADJUSTL( MomUnits ) )
   ELSE
      WRITE (UnOu,FmtHdSpc)
      WRITE (UnOu,FmtUnSpc)  SpdUnits, PwrUnits, MomUnits, FrcUnits, MomUnits
   ENDIF


      ! Run all the combined cases.

   DO ICase=1,NumCases
      CavForAnyCase = .FALSE. !reset this flag before each combined case so we can distinguish which cases have cavitation

      Spd      = Cases(ICase)%WndSpeed
      TSR      = Cases(ICase)%TSR
      OmgRPM   = Cases(ICase)%RotSpeed
      PitDeg   = Cases(ICase)%Pitch

      VelHH    = Spd*ConvFact
      Omega    = OmgRPM*RPM2RPS
      TipSpeed = Omega*SweptRad
      Pitch    = PitDeg*D2R

      Call RotAnal(Converged)


         ! Write results to output file.

      IF ( ( .NOT. Converged ) .and. ( ConvFlag == 1 ) ) THEN
         IF ( TabDel )  THEN
            WRITE (UnOu,FmtDaTab)  Spd, TSR, OmgRPM, PitDeg, 9999.99, 9999.99, 9999.99, 9999.99, &
                                    9999.99,  9999.99, CavForAnyCase, Converged
         ELSE
            WRITE (UnOu,FmtDaSpc)  Spd, TSR, OmgRPM, PitDeg, 9999.99, 9999.99, 9999.99, 9999.99, &
                                    9999.99,  9999.99, CavForAnyCase, Converged
         ENDIF

      ELSEIF ( ( .NOT. Converged ) .and. ( ConvFlag == 2 ) ) THEN
         IF ( TabDel )  THEN
            WRITE (UnOu,FmtDaTab)  Spd, TSR, OmgRPM, PitDeg, NaN, NaN, NaN, NaN, &
                                    NaN,  NaN, CavForAnyCase, Converged
         ELSE
            WRITE (UnOu,FmtDaSpc)  Spd, TSR, OmgRPM, PitDeg, NaN, NaN, NaN, NaN, &
                                    NaN,  NaN, CavForAnyCase, Converged
         ENDIF
      ELSE ! ( ( .NOT. Converged ) .and. ( ConvFlag == 1or2 ) )
         IF ( TabDel )  THEN
            WRITE (UnOu,FmtDaTab)  Spd, TSR, OmgRPM, PitDeg, ConvPwr*Power, ConvTrq*Torque, ConvFrc*Thrust, ConvTrq*FlapMom, &
                                   PwrC, TrqC, CavForAnyCase, Converged
         ELSE
            WRITE (UnOu,FmtDaSpc)  Spd, TSR, OmgRPM, PitDeg, ConvPwr*Power, ConvTrq*Torque, ConvFrc*Thrust, ConvTrq*FlapMom, &
                                   PwrC, TrqC, CavForAnyCase, Converged
         ENDIF

      ENDIF

   ENDDO ! ICase



   RETURN
   END SUBROUTINE CombCase
!=======================================================================
   SUBROUTINE GetAero ( ISeg, AInd, TInd )


      ! Get some aerodynamic information.


   USE                             ProgGen
   USE                             WTP_Data


      ! Argument declarations.

   REAL(ReKi), INTENT(IN)       :: AInd                                         ! The axial-induction factor.
   REAL(ReKi), INTENT(IN)       :: TInd                                         ! The tangential-induction factor.

   INTEGER, INTENT(IN)          :: ISeg                                         ! The segment number.


      ! Local declarations.

   REAL(ReKi)                   :: AFang                                        ! The angle between the wind vector and the cone of rotation in radians.
   REAL(ReKi)                   :: AlfaR                                        ! The angle of attack in radians.
   REAL(ReKi)                   :: CnLoc                                        ! The local normal coefficient.
   REAL(ReKi)                   :: CtLoc                                        ! The local tangential coefficient.
   REAL(ReKi)                   :: LossHub  = 1.0                               ! Hub-loss correction factor.
   REAL(ReKi)                   :: LossTip  = 1.0                               ! Tip-loss correction factor.
   REAL(ReKi)                   :: Re                                           ! Reynolds number.
   REAL(ReKi)                   :: VInd                                         ! The total relative wind speed.


      ! External references.



      ! Apply the induction factors to the speeds.

   VIndTang = VTotTang*( 1.0 + TInd )
   VIndNorm = VTotNorm*( 1.0 - AInd*SWcorr )
   VIndNrm2 = VIndNorm**2
   VInd2    = VIndTang**2 + VIndNrm2
   VInd     = SQRT( VInd2 )


      ! Calculate the airflow angle.

   AFang  = ATAN2( VIndNorm, VIndTang )
   AFangD = AFang*R2D
   CosAF  = COS( AFang )
   SinAF  = SIN( AFang )


      ! Calculate the angle of attack.  Ensure that it is within +/- 180 degrees.

   AlfaR   = AFang - IncidAng
   AlfaD   = AlfaR*R2D

   IF     ( AlfaD >  180.0 )  THEN
      AlfaD = AlfaD - 360.0
   ELSEIF ( AlfaD < -180.0 )  THEN
      AlfaD = AlfaD + 360.0
   ENDIF


      ! Tip-loss calculation.

   IF ( TipLoss )  LossTip = Prandtl( 1.0, RLocND(ISeg), SinAF )


      ! Don't calculate the hub loss if there is no hub.

   IF ( HubLoss .AND. ( HubRadND .GT. EPSILON( HubRadND ) ) )  LossHub = Prandtl( RLocND(ISeg), HubRadND, SinAF )


      ! Total the losses.

   Loss = LossTip*LossHub


      ! Calculate Reynolds number.

   Re = VInd*Chord(ISeg)*RotorRad/KinVisc


      ! Calculate Cn and Ct for the local segment.

   IF ( AIDrag .OR. TIDrag )  THEN
      CALL GetCoefs ( ISeg, AlfaD, Re, AF_Table(AFfile(ISeg)), ClLoc, CdLoc, CmLoc, CpminLoc, .TRUE., .TRUE. , UseCm ,UseCpmin)
   ELSE
      CALL GetCoefs ( ISeg, AlfaD, Re, AF_Table(AFfile(ISeg)), ClLoc, CdLoc, CmLoc, CpminLoc, .TRUE., .FALSE., UseCm ,UseCpmin)
      CdLoc = 0.0
   ENDIF

   IF ( AIDrag )  THEN
      CnLoc = ClLoc*CosAF + CdLoc*SinAF
   ELSE
      CnLoc = ClLoc*CosAF
   ENDIF

   IF ( TIDrag )  THEN
      CtLoc = ClLoc*SinAF - CdLoc*CosAF
   ELSE
      CtLoc = ClLoc*SinAF
   ENDIF


   RETURN
   END SUBROUTINE GetAero ! ( ISeg, AInd, TInd )
!=======================================================================
   SUBROUTINE GetData


      ! This routine opens the gets the data from the input files.


   USE                             Parameters
   USE                             ProgGen
   USE                             WTP_Data

   IMPLICIT                        NONE


      ! Local declarations.

   REAL(ReKi)                   :: BldLen                                       ! Blade length.
   REAL(ReKi)                   :: InpCase   (3)                                ! Temporary array to hold combined-case input parameters.
   REAL(ReKi)                   :: OmgSets   (3)                                ! Temporary array to hold omega-setting parameters.
   REAL(ReKi)                   :: PitSets   (3)                                ! Temporary array to hold pitch-setting parameters.
   REAL(ReKi)                   :: SpdSets   (3)                                ! Temporary array to hold speed-setting parameters.

   INTEGER                      :: IAF                                          ! Index for input airfoil table.
   INTEGER                      :: ICase                                        ! Index for combined-analysis case.
   INTEGER                      :: IOmg                                         ! Index into the OmgAry array.
   INTEGER                      :: IOS                                          ! I/O status result.
   INTEGER                      :: IPit                                         ! Index into the PitAry array.
   INTEGER                      :: ISeg                                         ! The blade-segment number.
   INTEGER                      :: ISpd                                         ! Index into the SpdAry array.
   INTEGER                      :: NumAF                                        ! The number of unique (input) airfoil files.
   INTEGER                      :: Sttus                                        ! The status returned from allocation attempts.

   CHARACTER(200)               :: AF_File                                      ! String containing the name of an aifoil file.
   CHARACTER(200)               :: InpVersn                                     ! String containing the input-version information.
   CHARACTER(200)               :: Line                                         ! String containing a line of input.
   CHARACTER(200)               :: SubTitle                                     ! String containing the RunTitle of a subsection.



      ! Skip a line, read the run title and the version information.

   READ (UnIn,'(/,A,/,A)',IOSTAT=IOS)  RunTitle, InpVersn

   IF ( IOS < 0 )  CALL PremEOF ( InpFile , 'RunTitle' )

   CALL WrScr1 ( ' '//RunTitle )


      ! Read in the title line for the input-configuration subsection.

   READ (UnIn,'(A)',IOSTAT=IOS)  SubTitle

   IF ( IOS < 0 )  CALL PremEOF ( InpFile , 'the input-configuration subtitle' )

      ! See if we should echo the output.

    READ (UnIn,*,IOSTAT=IOS)  Echo

   IF ( Echo )  THEN
      CALL OpenFOutFile ( UnEc, TRIM( RootName )//'.ech' )
      WRITE (UnEc,'(A)')                        'Echo of WT_Perf Input File:'
      WRITE (UnEc,'(A)')                        ' "'//TRIM( InpFile )//'"'
      WRITE (UnEc,'(A)')                        'Generated on: '//TRIM( DateNow )//' at '//TRIM( TimeNow )//'.'
      WRITE (UnEc,'(A,/,A)')                    RunTitle, InpVersn
      WRITE (UnEc,'(A)')                        SubTitle
      WRITE (UnEc,"(2X,L11,2X,A,T27,' - ',A)")  Echo, 'Echo', 'Echo input parameters to "echo.out"?'
   ENDIF


      ! Read the rest of input-configuration section.

   CALL ReadVar ( UnIn, InpFile, DimenInp, 'DimenInp', 'Turbine parameters are dimensional?'         )
   CALL ReadVar ( UnIn, InpFile, Metric,   'Metric',   'Turbine parameters are Metric (MKS vs FPS)?' )


      ! Read the model-configuration section.

   CALL ReadCom ( UnIn, InpFile,                       'the model-configuration subtitle'                )
   CALL ReadVar ( UnIn, InpFile, NumSect,  'NumSect',  'Number of circumferential sectors.'              )
   CALL ReadVar ( UnIn, InpFile, MaxIter,  'MaxIter',  'Max number of iterations for Newt-Raphson.'      )
   CALL ReadVar ( UnIn, InpFile, NSplit,   'NSplit',   'Max number of splits in BinSearch.'              )
   CALL ReadVar ( UnIn, InpFile, ATol,     'ATol',     'Error tolerance for induction iteration.'        )
   CALL ReadVar ( UnIn, InpFile, SWTol,    'SWTol',    'Error tolerance for skewed-wake iteration.'      )

   ATol2 = ATol**2


      ! Check for valid choices.

   IF ( NumSect < 1 )  THEN
      CALL ProgAbort ( ' Variable "NumSect" must be greater than 0.  Instead, it is "'//Trim( Int2LStr( NumSect ) )//'".' )
   ENDIF

   IF ( MaxIter < 1 )  THEN
      CALL ProgAbort ( ' Variable "MaxIter" must be greater than 0.  Instead, it is "'//Trim( Int2LStr( MaxIter ) )//'".' )
   ENDIF

   IF ( NSplit < 1 )  THEN
      CALL ProgAbort ( ' Variable "NSplit" must be greater than 0.  Instead, it is "'//Trim( Int2LStr( NSplit ) )//'".' )
   ENDIF


   IF ( ATol <= 0.0 )  THEN
      CALL ProgAbort ( ' Variable "ATol" must be greater than 0.  Instead, it is "'//Trim( Num2LStr( ATol ) )//'".' )
   ENDIF

   IF ( SWTol <= 0.0 )  THEN
      CALL ProgAbort ( ' Variable "SWTol" must be greater than 0.  Instead, it is "'//Trim( Num2LStr( SWTol ) )//'".' )
   ENDIF


      ! Read the algorithm-configuration section.

   CALL ReadCom ( UnIn, InpFile,                       'the algorithm-configuration subtitle'                           )
   CALL ReadVar ( UnIn, InpFile, TipLoss,  'TipLoss',  'Use the Prandtl tip-loss model?'                                )
   CALL ReadVar ( UnIn, InpFile, HubLoss,  'HubLoss',  'Use the Prandtl hub-loss model?'                                )
   CALL ReadVar ( UnIn, InpFile, Swirl,    'Swirl',    'Include Swirl effects?'                                         )
   CALL ReadVar ( UnIn, InpFile, SkewWake, 'SkewWake', 'Apply skewed-wake correction?'                                  )
   CALL ReadVar ( UnIn, InpFile, IndType,  'IndType',  'Use BEM induction algorithm?'                        )
   CALL ReadVar ( UnIn, InpFile, AIDrag,   'AIDrag',   'Include the drag term in the axial-induction calculation?'      )
   CALL ReadVar ( UnIn, InpFile, TIDrag,   'TIDrag',   'Include the drag term in the tangential-induction calculation?' )


   IF ( AiDrag )  THEN
      AiDragM = 1.0
   ELSE
      AiDragM = 0.0
   ENDIF

   IF ( TiDrag )  THEN
      TiDragM = 1.0
   ELSE
      TiDragM = 0.0
   ENDIF

   CALL ReadVar ( UnIn, InpFile, TISingularity,   'TISingularity',  &
         'Use the singularity avoidance method in the tangential-induction calculation?' )

   CALL ReadVar ( UnIn, InpFile, DAWT,   'DAWT',   &
         'Run Diffuser Augmented Water Turbine Analysis? Marshall will hunt you down and kill you if use this for a wind turbine.' )
   CALL ReadVar ( UnIn, InpFile, Cavitation,   'Cavitation',   &
         'Run cavitation check? if cavitation, output sevens, check 12 oclock azimuth' )

   CALL ReadCom ( UnIn, InpFile, 'Cavitation Model subtitle' )
   CALL ReadVar ( UnIn, InpFile, PressAtm,   'PressAtm',   'Air Atmospheric Pressure, Pa units, absolute' )
   CALL ReadVar ( UnIn, InpFile, PressVapor,   'PressVapor',   'Vapor Pressure of Water, Pa units, absolute' )
   CALL ReadVar ( UnIn, InpFile, CavSF,   'CavSF',   'Cavitation Safety Factor' )
   CALL ReadVar ( UnIn, InpFile, WatDepth,   'WatDepth',   'Depth from water free surface to mudline (tower base)' )

      ! Check for valid choices.

      ! The DAWT (diffuser augmented water turbine) does not have a good model right now for the diffuser as it is written here.
      ! Therefore, we will exit and state that this should not be used. Refer to the users guide on what it did and how to manually do that.
   IF (DAWT) THEN
      ! Read CavBeta and CavLambda from DAWT.dat -- not implimented.
      CALL WrScr('')
      CALL ProgAbort(' Incomplete feature: DAWT. The DAWT (diffuser augmented water turbine) has not been implimented yet. &
                     &Set this flag to false and try running again. See the users guide for more information.')
      CavBeta = 1.3
      CavLambda = 1.0
   ELSE
      CavBeta = 1.0
      CavLambda = 1.0
   ENDIF
   ! Cavitation parameters are checked after HubHu is read.

   IF ( .NOT. IndType )  THEN    ! Don't do skewed wakes if induction calculations are disabled.
      SkewWake = .FALSE.
   ENDIF


      ! Read the turbine-data section.

   CALL ReadCom ( UnIn, InpFile, 'the turbine-data subtitle' )
   CALL ReadVar ( UnIn, InpFile, NumBlade, 'NumBlade', 'Number of blades.'     )
   CALL ReadVar ( UnIn, InpFile, RotorRad, 'RotorRad', 'Unconed rotor radius.' )
   CALL ReadVar ( UnIn, InpFile, HubRad,   'HubRad',   'Hub radius.' )
   CALL ReadVar ( UnIn, InpFile, PreCone,  'PreCone',  'Cone angle.' )
   CALL ReadVar ( UnIn, InpFile, Tilt,     'Tilt',     'Shaft tilt.' )
   CALL ReadVar ( UnIn, InpFile, Yaw,      'Yaw',      'Yaw error.' )
   CALL ReadVar ( UnIn, InpFile, HubHt,    'HubHt',    'Hub height.' )

   IF ( DimenInp )  THEN
      HubRadND = HubRad/RotorRad
      HubHtND  = HubHt /RotorRad
   ELSE
      HubRadND = HubRad
      HubHtND  = HubHt
      HubRad = HubRadND*RotorRad
      HubHt  = HubHtND *RotorRad
   ENDIF

   IF (Cavitation) THEN
      ! Check that CavSF is greater then zero.
      IF  ( CavSF <= 0.0 )   THEN
         CALL ProgAbort ( ' The cavitation safety factor must be positive and greater than zero.  Instead it is ' &
                 //TRIM( Num2LStr( CavSF ) )//' '//TRIM( LenUnits )//'.' )
      ENDIF
      ! Check that PressAtm is positive.
      IF  ( PressAtm < 0.0 )   THEN
         CALL ProgAbort ( ' The atmospheric pressure (PressAtm) must be positive.  Instead it is ' &
                 //TRIM( Num2LStr( PressAtm ) )//' '//TRIM( LenUnits )//'.' )
      ENDIF
      ! Check that PressVapor is positive
      IF  ( PressVapor < 0.0 )   THEN
         CALL ProgAbort ( ' The vapor pressure (PressVapor) must be positive.  Instead it is ' &
                 //TRIM( Num2LStr( PressVapor ) )//' '//TRIM( LenUnits )//'.' )
      ENDIF
      ! Define non-dim watdepth
      IF ( DimenInp )  THEN
         WatDepthND = WatDepth/RotorRad
      ELSE
         WatDepthND = WatDepth
         WatDepth = WatDepthND*RotorRad
      ENDIF
      ! Check that WatDepth is positive
      IF  ( WatDepthND < 0.0 )   THEN
         CALL ProgAbort ( ' The water depth must be positive.  Instead it is ' &
                 //TRIM( Num2LStr( WatDepth ) )//' '//TRIM( LenUnits )//'.' )
      ENDIF
      ! Check that WatDepth-HubHt is greater than or equal to RotorRad so blade does not stick above the water surface.
      IF ( WatDepthND-HubHtND < 1.0 )   THEN
         CALL ProgAbort ( ' The water depth minus the hub height exceeds the rotor radius.  It reaches this far' &
                 // ' above the surface:' //TRIM( Num2LStr( WatDepth - HubHt - RotorRad ) )//' '//TRIM( LenUnits )//'.' )
      ENDIF
   ENDIF

   PressVaporCavSF = PressVapor*CavSF


   BldLen  = RotorRad - HubRad
   PreCone = PreCone*D2R
   SinCone = SIN( PreCone )
   CosCone = COS( PreCone )

   Tilt    = Tilt*D2R
   CosTilt = COS( Tilt )
   SinTilt = SIN( Tilt )

   Yaw    = Yaw*D2R
   CosYaw = COS( Yaw )
   SinYaw = SIN( Yaw )

   IF ( .NOT. SkewWake .OR. ( ( Yaw == 0.0 ) .AND. ( Tilt == 0.0 ) ) )  THEN
      DoSkew   = .FALSE.
      SkewWake = .FALSE.
      SWconst  = 0.0
      SWconv   = .TRUE.
      SWcorr   = 1.0
   ENDIF


      ! Read in the number of segments and allocate the property arrays.

   CALL ReadVar ( UnIn, InpFile, NumSeg,   'NumSeg',   'Number of blade segments (entire rotor radius).' )

   IF ( NumSeg < 1 )  CALL ProgAbort ( ' Variable "NumSeg" must be greater than 0.  Instead, it is "'//Int2LStr( NumSeg )//'".' )

   CALL AllocProp

   ALLOCATE ( AFfile(NumSeg) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort(' Error allocating memory for the AFfile array.')
   ENDIF


      ! Read in the distributed blade properties.

   CALL ReadCom  ( UnIn, InpFile, 'the header for the blade-element data' )

   NumElmPr = 0

   DO ISeg=1,NumSeg

      READ (UnIn,'(A)',IOSTAT=IOS)  Line

      CALL CheckIOS ( IOS, InpFile, 'line #'//TRIM( Int2LStr( ISeg ) )//' of the blade-element data table.' , StrType )

      READ (Line,*,IOSTAT=IOS)  RLoc(ISeg), Twist(ISeg), Chord(ISeg), AFfile(ISeg), PrntElem(ISeg)

      CALL CheckIOS ( IOS, InpFile, 'line #'//TRIM( Int2LStr( ISeg ) )//' of the blade-element data table.' , NumType )

      IF ( Chord(ISeg) <= 0.0 )  THEN
         CALL ProgAbort ( ' The chord for segment #'//Trim( Int2LStr( NumSect ) )//' must be > 0.  Instead, it is "' &
                    //Trim( Num2LStr( Chord(ISeg) ) )//'".' )
      ENDIF


         ! Convert to or from dimensional data.

      IF ( DimenInp )  THEN
         RLocND(ISeg) = RLoc  (ISeg)/RotorRad
         Chord (ISeg) = Chord (ISeg)/RotorRad
      ELSE
         RLocND(ISeg) = RLoc(ISeg)
         RLoc  (ISeg) = RLocND(ISeg)*RotorRad
      ENDIF

      Twist(ISeg) = Twist(ISeg)*D2R

      IF ( PrntElem(ISeg) )  NumElmPr = NumElmPr +1

   ENDDO ! ISeg


      ! Compute the segment lengths and check their validity.

   CALL CompDR ( NumSeg, RLoc, HubRad, RotorRad, DimenInp, DelRLoc )


       ! The Tim Olsen memorial hub-radius check.

   IF ( ( HubRadND < 0.0 ) .OR. ( 1.0 <= HubRadND ) )  THEN
      CALL ProgAbort ( ' The hub radius must be positive and less than the rotor radius.  Instead it is ' &
                 //TRIM( Num2LStr( HubRad ) )//' '//TRIM( LenUnits )//'.' )
   ENDIF


      ! Make sure hub is high enough so the blade doesn't hit the ground.  We wouldn't want to get it dirty.  :-)
   IF ( HubHtND*CosCone*CosTilt .LT. 1.0 )  CALL ProgAbort ( ' The hub is so low, the blade will hit the ground.' )

      ! Read the aerodynamic-data section.

   CALL ReadCom ( UnIn, InpFile, 'the aerodynamic-data subtitle'   )
   CALL ReadVar ( UnIn, InpFile, AirDens,  'AirDens',  'Air density.' )
   CALL ReadVar ( UnIn, InpFile, KinVisc,  'KinVisc',  'Kinesmatic viscosity.' )
   CALL ReadVar ( UnIn, InpFile, ShearExp, 'ShearExp', 'Shear exponent.' )
   CALL ReadVar ( UnIn, InpFile, UseCm,    'UseCm',    'Cm data included in airfoil tables?' )
   CALL ReadVar ( UnIn, InpFile, UseCpmin, 'UseCpmin', 'Cp,min data included in airfoil tables?' )
   CALL ReadVar ( UnIn, InpFile, NumAF,    'NumAF',    'Number of unique airfoil tables.'     )

   IF ( AirDens <= 0.0 )  CALL ProgAbort ( ' The air density must be greater than zero.' )
   IF ( KinVisc <= 0.0 )  CALL ProgAbort ( ' The kinesmatic viscosity must be greater than zero.' )

   IF (Cavitation) THEN
      IF ( .NOT. UseCpmin )   THEN
         CALL ProgAbort ( ' Minimum pressure coefficients are required when checking for cavitation. Please provide' &
                        // ' minimum pressure coeffiecients in the airfoil files and set UseCpmin to True.' )
      ENDIF
   ENDIF




      ! Check the list of airfoil tables to make sure they are all within limits.

   IF ( NumAF < 1 )  CALL ProgAbort ( ' The number of unique airfoil tables (NumAF) must be greater than zero.' )

   DO ISeg=1,NumSeg
      IF ( ( AFfile(ISeg) < 1 ) .OR. ( AFfile(ISeg) > NumAF ) )  THEN
         CALL ProgAbort ( ' Segment #'//TRIM( Int2LStr( ISeg ) )//' requested airfoil input table #' &
                    //TRIM( Int2LStr( AFfile(ISeg) ) ) &
                    //'.  However, it must be between 1 and NumAF (='//TRIM( Int2LStr( NumAF ) )//'), inclusive.' )
      ENDIF
   ENDDO ! ISeg


      ! Allocate the airfoil data super-supertables for both unique data and complete data.

   ALLOCATE ( AF_Table(NumAF) , STAT=Sttus )
   IF ( Sttus /= 0 )  THEN
      CALL ProgAbort ( ' Error allocating memory for the AF_Uniq super-supertable in T_GetAF.' )
   ENDIF


      ! Read in NumAF unique airfoil data files.

   DO IAF=1,NumAF

      CALL ReadVar ( UnIn, InpFile, AF_File, 'AF_File', 'Airfoil file #'//TRIM( Int2LStr( IAF ) )//'.' )
      CALL GetAF   ( AF_File, AF_Table(IAF), IAF )

   ENDDO


      ! Make sure we have a minimum of four sectors if we have shear, shaft tilt, or yaw.

   IF (  ( Tilt /= 0.0 ) .OR. ( Yaw /= 0.0 ) .OR. ( ShearExp /= 0.0 ) )  THEN
      NumSect = MAX( NumSect, 4 )
   ELSE
      NumSect = 1
   ENDIF


      ! Read the I/O-configuration section.

   CALL ReadCom ( UnIn, InpFile, 'the I/O-configuration subtitle'                                                                 )
   CALL ReadVar ( UnIn, InpFile, UnfPower,   'UnfPower',   'Write Power to an unformatted file?'                                  )
   CALL ReadVar ( UnIn, InpFile, TabDel,     'TabDel',     'Make output tab-delimited (fixed-width otherwise)?'                   )
   CALL ReadVar ( UnIn, InpFile, ConvFlag,   'ConvFlag',   '0 to output the result, 1 to output nines, 2 to output NaN (safest).' )
   CALL ReadVar ( UnIn, InpFile, Beep,       'Beep',       'Beep on exit?'                                                        )
   CALL ReadVar ( UnIn, InpFile, KFact,      'KFact',      'Output dimensional parameters in K?'                                  )
   CALL ReadVar ( UnIn, InpFile, WriteBED,   'WriteBED',   'Write out blade element data to "bladelem.dat"?'                      )
   CALL ReadVar ( UnIn, InpFile, InputTSR,   'InputTSR',   'Input speeds as TSRs?'                                                )
   CALL ReadVar ( UnIn, InpFile, OutMaxCp,   'OutMaxCp',   'Output conditions leading to maximum Cp?'                             )
   CALL ReadVar ( UnIn, InpFile, SpdUnits,   'SpdUnits',   'Wind-speed units (mps, fps, mph).'                                    )

   IF ( ( ConvFlag < 0 ) .OR. ( ConvFlag > 2 ) )  THEN
      CALL ProgAbort ( ' Option "ConvFlag" must be between 0 and 2 (inclusive).  Instead, it is "'//TRIM( Int2LStr( ConvFlag ) ) &
                      //'".' )
   ENDIF

      ! Set units conversion and compute TSR parameters.

   CALL SetConv


      ! No sense creating a BED file if we're not putting anything in it.

   IF ( NumElmPr == 0 )  WriteBED = .FALSE.


      ! Read the combined-case section.

   CALL ReadCom  ( UnIn, InpFile,                       'the combined-case subtitle'     )
   CALL ReadVar  ( UnIn, InpFile, NumCases, 'NumCases', 'Number of cases to run.'        )
   CALL ReadCom  ( UnIn, InpFile,                       'the combined-case-block header' )

   IF ( NumCases < 0 )  THEN

      CALL ProgAbort ( ' Variable "NumCases" must be >= 0.  Instead, it is "'//TRIM( Int2LStr( NumCases ) )//'".' )

   ELSEIF ( NumCases > 0 )  THEN

      ALLOCATE ( Cases(NumCases) , STAT=Sttus )
      IF ( Sttus /= 0 )  THEN
         CALL ProgAbort(' Error allocating memory for the Cases array.')
      ENDIF

      DO ICase=1,NumCases

         CALL ReadRAry ( UnIn, InpFile, InpCase,  3, 'InpCase',  'Wind Speed or TSR, Rotor Speed, and Pitch for Case #' &
                       //TRIM( Int2LStr( ICase ) )//'.' )

         IF ( InputTSR )  THEN
            Cases(ICase)%TSR      = InpCase(1)
            Cases(ICase)%WndSpeed = RotorRad*InpCase(2)*Pi/( 30.0*InpCase(1) )
         ELSE
            Cases(ICase)%TSR      = RotorRad*InpCase(2)*Pi/( 30.0*InpCase(1) )
            Cases(ICase)%WndSpeed = InpCase(1)
         ENDIF

         Cases(ICase)%RotSpeed = InpCase(2)
         Cases(ICase)%Pitch    = InpCase(3)

      ENDDO ! ICase

   ELSE ! ( NumCases ==0 )


         ! Read the parametric-analysis-configuration section.

      CALL ReadCom ( UnIn, InpFile,                   'the parametric-analysis-configuration subtitle'  )
      CALL ReadVar ( UnIn, InpFile, ParRow, 'ParRow', 'Row parameter    (1-rpm, 2-pitch, 3-TSR/speed).' )
      CALL ReadVar ( UnIn, InpFile, ParCol, 'ParCol', 'Column parameter (1-rpm, 2-pitch, 3-TSR/speed).' )
      CALL ReadVar ( UnIn, InpFile, ParTab, 'ParTab', 'Sheet parameter  (1-rpm, 2-pitch, 3-TSR/speed).' )
      CALL ReadVar ( UnIn, InpFile, OutPwr, 'OutPwr', 'Request output of rotor power?'                  )
      CALL ReadVar ( UnIn, InpFile, OutCp,  'OutCp',  'Request output of Cp?'                           )
      CALL ReadVar ( UnIn, InpFile, OutTrq, 'OutTrq', 'Request output of shaft torque?'                 )
      CALL ReadVar ( UnIn, InpFile, OutFlp, 'OutFlp', 'Request output of flap bending moment?'          )
      CALL ReadVar ( UnIn, InpFile, OutThr, 'OutThr', 'Request output of rotor thrust?'                 )


         ! Check for valid choices.

      IF ( ( ParRow < 1 ) .OR. ( ParRow > 3 ) )  THEN
         CALL ProgAbort ( ' Variable "ParRow" must be between 1 and 3 (inclusive).  Instead, it is "'//TRIM( Int2LStr( ParRow ) ) &
                      //'".' )
      ENDIF

      IF ( ( ParCol < 1 ) .OR. ( ParCol > 3 ) )  THEN
         CALL ProgAbort ( ' Variable "ParCol" must be between 1 and 3 (inclusive).  Instead, it is "'//TRIM( Int2LStr( ParCol ) ) &
                      //'".' )
      ENDIF

      IF ( ( ParTab < 1 ) .OR. ( ParTab > 3 ) )  THEN
         CALL ProgAbort ( ' Variable "ParTab" must be between 1 and 3 (inclusive).  Instead, it is "'//TRIM( Int2LStr( ParTab ) ) &
                      //'".' )
      ENDIF

      IF ( ParCol == ParRow )  THEN
         CALL ProgAbort ( ' Variable "ParCol" must differ from "ParRow".  Both are "'//TRIM( Int2LStr( ParRow ) )//'".' )
      ENDIF

      IF ( ParTab == ParRow )  THEN
         CALL ProgAbort ( ' Variable "ParTab" must differ from "ParRow".  Both are "'//TRIM( Int2LStr( ParRow ) )//'".' )
      ELSEIF ( ParTab == ParCol )  THEN
         CALL ProgAbort ( ' Variable "ParTab" must differ from "ParCol".  Both are "'//TRIM( Int2LStr( ParCol ) )//'".' )
      ENDIF


         ! Make sure at least on request is made for output.

      IF ( ( .NOT. OutCp  ) .AND. &
           ( .NOT. OutFlp ) .AND. &
           ( .NOT. OutPwr ) .AND. &
           ( .NOT. OutThr ) .AND. &
           ( .NOT. OutTrq ) )  THEN

            CALL ProgAbort ( ' No output requested.  At least one of OutCp, OutFlp, OutPwr, OutThr, OutTrq must be TRUE.' )

      ENDIF

      CALL ReadRAry ( UnIn, InpFile, PitSets,  3, 'PitSets',  'First, last, delta blade pitch (deg).' )
      CALL ReadRAry ( UnIn, InpFile, OmgSets,  3, 'OmgSets',  'First, last, delta rotor speed (rpm).' )
      CALL ReadRAry ( UnIn, InpFile, SpdSets,  3, 'SpdSets',  'First, last, delta speeds.'            )


         ! Check for valid choices.

      IF ( ( PitSets(3) /= 0.0 ) .AND. ( PitSets(2) - PitSets(1) )/PitSets(3) < 0.0 ) &
                                       CALL ProgAbort ( ' Your pitch settings (PitSt, PitEnd, PitDel) are not consistent.' )
      IF ( ( OmgSets(3) /= 0.0 ) .AND. ( OmgSets(2) - OmgSets(1) )/OmgSets(3) < 0.0 ) &
                                       CALL ProgAbort ( ' Your rotor-speed settings (OmgSt, OmgEnd, OmgDel) are not consistent.' )
      IF ( ( SpdSets(3) /= 0.0 ) .AND. ( SpdSets(2) - SpdSets(1) )/SpdSets(3) < 0.0 ) &
                                       CALL ProgAbort ( ' Your speed settings (SpdSt, SpdEnd, SpdDel) are not consistent.' )

      PitSt  = PitSets(1)
      PitEnd = PitSets(2)
      PitDel = PitSets(3)

      OmgSt  = OmgSets(1)
      OmgEnd = OmgSets(2)
      OmgDel = OmgSets(3)

      SpdSt  = SpdSets(1)
      SpdEnd = SpdSets(2)
      SpdDel = SpdSets(3)

      IF ( .NOT. InputTSR )  ParamStr(3) = 'WndSp'


         ! Allocate the parameter arrays.

      CALL AllocPar


         ! Load the parameter arrays.

      DO IPit=1,NumPit
         PitAry(IPit) = PitSt + PitDel*( IPit - 1 )
      ENDDO ! IPit

      DO IOmg=1,NumOmg
         OmgAry(IOmg) = OmgSt + OmgDel*( IOmg - 1 )
      ENDDO ! IOmg

      DO ISpd=1,NumSpd
         SpdAry(ISpd) = SpdSt + SpdDel*( ISpd - 1 )
      ENDDO ! ISpd


         ! Point the row, column, and table parameter arrays to the appropiate pitch, omega, and speed parameter arrays.

      SELECT CASE ( ParTab )
      CASE ( 1 )
         IF ( ParCol == 2 )  THEN
            RowAry => SpdAry
            ColAry => PitAry
            TabAry => OmgAry
         ELSE
            RowAry => PitAry
            ColAry => SpdAry
            TabAry => OmgAry
         ENDIF
      CASE ( 2 )
         IF ( ParCol == 1 )  THEN
            RowAry => SpdAry
            ColAry => OmgAry
            TabAry => PitAry
         ELSE
            RowAry => OmgAry
            ColAry => SpdAry
            TabAry => PitAry
         ENDIF
      CASE ( 3 )
         IF ( ParCol == 1 )  THEN
            RowAry => PitAry
            ColAry => OmgAry
            TabAry => SpdAry
         ELSE
            RowAry => OmgAry
            ColAry => PitAry
            TabAry => SpdAry
         ENDIF
      END SELECT

   ENDIF ! ( NumCases > 0 )

      ! Close the input and echo files.

   CLOSE ( UnIn )

   IF ( Echo )  CLOSE ( UnEc )


   RETURN
   END SUBROUTINE GetData
!=======================================================================
   SUBROUTINE GetInds ( IOmg, IPit, ISpd, IRow, ICol, ITab )


      ! This subroutine gets the output indices for given omega, pitch, and speed indices.


   USE                             WTP_Data

   IMPLICIT                        NONE


      ! Argument declarations.

   INTEGER, INTENT(OUT)         :: ICol                                         ! The column index.
   INTEGER, INTENT(IN)          :: IOmg                                         ! The rotor-speed index.
   INTEGER, INTENT(IN)          :: IPit                                         ! The blade-pitch index.
   INTEGER, INTENT(OUT)         :: IRow                                         ! The row index.
   INTEGER, INTENT(IN)          :: ISpd                                         ! The TSR/wind-speed index.
   INTEGER, INTENT(OUT)         :: ITab                                         ! The table index.



   SELECT CASE ( ParTab )

   CASE ( 1 )

      IF ( ParCol == 2 )  THEN

         IRow = ISpd
         ICol = IPit
         ITab = IOmg

      ELSE

         IRow = IPit
         ICol = ISpd
         ITab = IOmg

      ENDIF

   CASE ( 2 )

      IF ( ParCol == 1 )  THEN

         IRow = ISpd
         ICol = IOmg
         ITab = IPit

      ELSE

         IRow = IOmg
         ICol = ISpd
         ITab = IPit

      ENDIF

   CASE ( 3 )

      IF ( ParCol == 1 )  THEN

         IRow = IPit
         ICol = IOmg
         ITab = ISpd

      ELSE

         IRow = IOmg
         ICol = IPit
         ITab = ISpd

      ENDIF

   END SELECT


   RETURN
   END SUBROUTINE GetInds ! ( IOmg, IPit, ISpd, IRow, ICol, ITab )
!=======================================================================
   SUBROUTINE GetVel ( VWndNorm )

      ! This function return the value of the local dynamic pressure.


   USE                             WTP_Data

   IMPLICIT                        NONE


      ! Argument declarations.

   REAL(ReKi), INTENT(OUT)      :: VWndNorm


      ! Local declarations.

   REAL(ReKi)                   :: VWndTang



      ! Calculate the normal and tangential wind speed in the local reference system.

   VWndNorm =  VWndGnd*( CosCone*CosYaw*CosTilt - SinCone*( CosYaw*CosAzim*SinTilt - SinYaw*SinAzim ) )
   VWndTang = -VWndGnd*( CosAzim*SinYaw + CosYaw*SinTilt*SinAzim )


      ! Calculate total tangential wind speed.

   VTotTang = VWndTang + VBodTang


   RETURN
   END SUBROUTINE GetVel ! ( VBodTang, VWndGnd, CosAzim, SinAzim, VTotTang, VWndNorm )
! =======================================================================
   SUBROUTINE InductBEM ( ISeg, ISect, ZFound, Converg, AxIndPrevSeg, TanIndPrevSeg  )


      ! This routine calculates the induction factors.
      ! It will also allow the addition of the drag terms in either or both of
      ! the induction factors to (possibly) mimic the BLADED algorithm.


   USE                             Parameters
   USE                             ProgGen
   USE                             WTP_Data

   IMPLICIT                        NONE


      ! Argument declarations.

   INTEGER, INTENT(IN)          :: ISeg                                         ! The segment number.
   INTEGER, INTENT(IN)          :: ISect                                        ! The sector number.

   LOGICAL, INTENT(OUT)         :: Converg                                      ! Flag that says if we fully converged the induction loop.
   LOGICAL, INTENT(OUT)         :: ZFound                                       ! Flag that says if we even found a possible solution (zero crossing).

      ! Variables for Convergence
   REAL(ReKi), INTENT(INOUT)       :: AxIndPrevSeg                            !Value of AxInd from previous converged segment, if not converged, uses these default values.
   REAL(ReKi), INTENT(INOUT)       :: TanIndPrevSeg                           !Value of TanInd from previous converged segment, if not converged, uses these default values.



      ! Local declarations.

   REAL(ReKi)                   :: AFang                                        ! The angle between the wind vector and the cone of rotation in radians.
   REAL(ReKi)                   :: AxIndHi                                      ! The upper value of AxInd for the two points defining a zero crossing.
   REAL(ReKi)                   :: AxIndLo                                      ! The lower value of AxInd for the two points defining a zero crossing.
   REAL(ReKi), PARAMETER        :: AxOneMin =  0.9999999999999                             ! The lower value of AxInd range around 1.0 (1-delta).
   REAL(ReKi), PARAMETER        :: AxOnePlu =  1.0000000000001                             ! The upper value of AxInd range around 1.0 (1+delta).
   REAL(ReKi)                   :: AxIndErr_Curr                                ! The current value of AxIndErr() after the last solve. We pass this to TanIndErr and only calculate TanIndErr when AxIndErr_PrevCalc is small (near solution for AxInd).

   REAL(ReKi)                   :: ClBEM                                        ! The local life-coefficient from BEM theory. DCM 6-18-09
   REAL(ReKi)                   :: CnLoc                                        ! The local normal coefficient.
 ! REAL(ReKi)                   :: CpminLoc                                     ! The local minimum-pressure coefficient.
   REAL(ReKi)                   :: CtLoc                                        ! The local tangential coefficient.
   REAL(ReKi)                   :: DctZero
   REAL(ReKi)                   :: DctLs                                        !Thrust coeffecient from momentum theory(aka axial Head loss), < 0.96 and AInd < 0.4, for Dct
   REAL(ReKi)                   :: DctGr_Glau                                   !Thrust coeffecient from Glauert empirical, > 0.96 and AInd > 0.4, for Dct
   REAL(ReKi)                   :: DctBem                                       !Dct from momentum theory or Glauert's empirical curve for AInd

   REAL(ReKi)                   :: DctNew                                       !Dct from momentum theory or Glauert's empirical curve for AInd    !New formula to calculate Dct, removes singularity due to SinAF going to zero
   REAL(ReKi)                   :: Find_ZC
   REAL(ReKi)                   :: SwNew                                        !Dct from momentum theory or Glauert's empirical curve for AInd    !New part of formula to calculate Dct, removes singularity due to SinAF going to zero
   !Integer                     :: TanIndNew                                    !New equation for Tangentional Induction factor
   REAL(ReKi)                   :: TanIndCoef                                   !Coefficient for New equation for Tangentional Induction factor
   REAL(ReKi)                   :: TanIndCoef_Cd                                !Cd term of Coefficient for New equation for Tangentional Induction factor 16-Jul-2009
   REAL(ReKi)                   :: TanIndCoef_Cl                                !Cl term of Coefficient for New equation for Tangentional Induction factor 16-Jul-2009
   REAL(ReKi)                   :: TanIndCoef_Old
 ! REAL(ReKi),PARAMETER         :: SingAminSlope = -0.0594                      !Slope for equation for lower bound of Correction for (1-a) singularity
 ! REAL(ReKi),PARAMETER         :: SingAminOffset = 0.9655                      !Offset for equation for lower bound of Correction for (1-a) singularity
 ! REAL(ReKi),PARAMETER         :: SingAmaxSlope = 0.8292                       !Slope for equation for upper bound of Correction for (1-a) singularity
 ! REAL(ReKi),PARAMETER         :: SingAmaxOffset = 1.0225                      !Offset for equation for upper bound of Correction for (1-a) singularity
 ! REAL(ReKi),PARAMETER         :: DelSing = 0.45                               !Delta for the transition region, from Amax to Amax*(1+DelSing) and Amin*(1-DelSing) to Amin
 ! REAL(ReKi),PARAMETER         :: DelSingZero = 0.0                            !Delta for the transition region about AInd = 1.0, lower A1Sing = 1.0-DelSingZero, upper A0Sing = 1.0+DelSingZero
   REAL(ReKi)                   :: A0sing
   REAL(ReKi)                   :: A1Sing
 ! REAL(ReKi)                   :: AminSing
 ! REAL(ReKi)                   :: AmaxSing
   REAL(ReKi)                   :: SingTransition
   REAL(ReKi)                   :: SingUpper
   REAL(ReKi),PARAMETER         :: SingOffset = 0.2

   REAL(ReKi), SAVE             :: Del                                          ! Variable to hold the delta for finite differencing.
   REAL(ReKi)                   :: LSR                                          ! The local speed ratio.
   REAL(ReKi)                   :: Re                                           ! Reynolds number.
   REAL(ReKi)                   :: Step                                         ! Step size for stepping through the possible range of axial-induction factor.
   REAL(ReKi)                   :: Sw                                           ! Windmill-state equation.

   INTEGER                      :: Iters                                        ! Number of iterations taken for this case.


   !! In debug mode, use the following to print out the full AxIndErr vs. AxInd curve from -0.5 to 1.5
   !#IFDEF DEBUG THEN
   !   Iters = 0
   !   CALL WrScr('')
   !   CALL WrScr('')
   !   CALL WrScr('# ISeg: '//TRIM(Num2LStr(ISeg))//'  ISect: '//TRIM(Num2LStr(ISect)))
   !   CALL WrScr('# AxInd   AxIndErr')
   !   DO WHILE (  Iters .LT. 2001 )
   !      AxInd = -0.5 + 0.001 * Iters
   !      CALL WrScr(TRIM(Num2LStr(AxInd))//'   '//TRIM(Num2LStr(AxIndErr(AxInd,AxIndErr_Curr))))
   !      Iters = Iters + 1
   !   END DO
   !#ENDIF

      ! Initialize induction-factor variables.

   LSR      = VTotTang/VTotNorm
   TanInd   = 0.0
   Del      = SQRT( EPSILON( 0.0 ) )
   Converg  = .FALSE.

   AxIndErr_Curr = 10.0        ! Dummy value to start

   Iters = 0



   ! First we run a Newton-Raphson iteration, just in case we can find the solution easily

      ! Set initial guess
   IF (ISeg .EQ. 1) THEN
      ! Find Closed form soln for AxInd and TanInd
      AxInd  = 0.0      !1.0/3.0            !  AxIndclosed
      TanInd = AxInd*(1.0-AxInd)/(LSR*LSR)  ! TanIndclosed
   ELSE
      ! Set inital guess to last converged values
      AxInd  = AxIndPrevSeg
      TanInd = TanIndPrevSeg
   ENDIF ! (ISeg .EQ. 1)

      ! Now do a Newton Raphson iteration
   DO WHILE ( ( .NOT. Converg ) .AND. ( Iters .LT. MaxIter ) )
      Iters = Iters + 1
      CALL NewtRaph ( AxInd, TanInd,.False.,AxIndErr_Curr )
   END DO

   IF (Converg) THEN
     TanIndPrevSeg = TanInd
     AxIndPrevSeg = AxInd
     ZFound = .true.

      ! Start: Add skewed-wake correction to axial induction.

     AxInd = AxInd*SWcorr

      IF ( .NOT. ( AIDrag .OR. TIDRAG ) )  THEN
         CALL GetCoefs ( ISeg, AlfaD, Re, AF_Table(AFfile(ISeg)), ClLoc, CdLoc, CmLoc, CpminLoc, .FALSE., .TRUE., UseCm ,UseCpmin)
      ENDIF ! ( .NOT. ( AIDrag .OR. TIDRAG ) )
                ! End: Add skewed-wake correction to axial induction.
      RETURN
   ENDIF ! (Converg)

   AxIndLo = AxInd - 1.0
   AxIndHi = AxInd + 1.0

      ! Since we did not find a solution and might have changed the tangential induction (2D Newt Raphson case), we reset the tangential induction.
   IF (ISeg .EQ. 1) THEN
      TanInd = AxInd*(1.0-AxInd)/(LSR*LSR)  ! TanInd -- closed form solution.
   ELSE
      ! Set inital guess to last converged values
      TanInd = TanIndPrevSeg
   ENDIF ! (ISeg .EQ. 1)


      ! Since the Newton-Raphson didn't give us a solution immediately, let's try to bound it using another method
   Call FindZC( .TRUE., -0.5, 1.0, 200, ZFound, AxIndLo, AxIndHi, Find_ZC, AxIndErr_Curr )
   AxInd = Find_ZC

      ! If we bounded the solution, now try the Newton-Raphson to quickly find it (assuming we have a smooth function)
   IF (ZFound) THEN
      Iters=0
      DO WHILE ( ( .NOT. Converg ) .AND. ( Iters .LT. MaxIter ) )
         Iters = Iters + 1
         CALL NewtRaph ( AxInd, TanInd,.False., AxIndErr_Curr )
      END DO

      ! If the Newton-Raphson did not converge, then reset the tangential induction, and try a binary search.
      ! Try  Binary Search
      IF (.NOT. Converg) THEN
            ! Since we did not find a solution and might have changed the tangential induction (2D Newt Raphson case), we reset the tangential induction.
         IF (ISeg .EQ. 1) THEN
            TanInd = AxInd*(1.0-AxInd)/(LSR*LSR)  ! TanInd -- closed for solution
         ELSE
            ! Set inital guess to last converged values
            TanInd = TanIndPrevSeg
         ENDIF ! (ISeg .EQ. 1)

         ! write (*,'(A,1F13.6,L3,2F13.6)') "AxInd,ZFound, AxIndLo, AxIndHi:",AxInd,ZFound, AxIndLo, AxIndHi
         AxInd = BinSearch( AxIndLo, AxIndHi, .False., AxIndErr_Curr )
      ENDIF ! (.NOT. Converg)

      IF (Converg) THEN
         TanIndPrevSeg = TanInd
         AxIndPrevSeg = AxInd
         ZFound = .TRUE.

         ! Add skewed-wake correction to axial induction.
         AxInd = AxInd*SWcorr

         IF ( .NOT. ( AIDrag .OR. TIDRAG ) )  THEN
            CALL GetCoefs ( ISeg, AlfaD, Re, AF_Table(AFfile(ISeg)), ClLoc, CdLoc, CmLoc, CpminLoc, .FALSE., .TRUE., UseCm,UseCpmin) ! .FALSE., .FALSE. ).FALSE., .FALSE. )
         ENDIF ! ( .NOT. ( AIDrag .OR. TIDRAG ) )

         Return
      ENDIF !(Converg)
   ENDIF !(ZFound)

      ! Not converged on a solution using the Newton-Raphson and FindZC methods.
      ! Since we have not returned, we must not have found a solution at all. So, now we need to try a different approach
   AxIndLo = -0.5
   AxIndHi =  0.6
   AxInd   = BinSearch( AxIndLo, AxIndHi, .False., AxIndErr_Curr )

      ! Try a different range
   IF (.NOT. Converg) THEN
      AxIndLo = -1.0
      AxIndHi = -0.51
      AxInd   = BinSearch( AxIndLo, AxIndHi, .False., AxIndErr_Curr )
   ENDIF ! (.NOT. Converg)

      ! Try a different range, again
   IF (.NOT. Converg) THEN
      AxIndLo = 0.59
      AxIndHi = 2.5
      AxInd   = BinSearch( AxIndLo, AxIndHi, .False., AxIndErr_Curr )
   ENDIF ! (.NOT. Converg)

   IF (Converg) THEN
      TanIndPrevSeg = TanInd
      AxIndPrevSeg  =  AxInd
      ZFound = .TRUE.

      ! Add skewed-wake correction to axial induction.
      AxInd = AxInd*SWcorr

      IF ( .NOT. ( AIDrag .OR. TIDRAG ) )  THEN
         CALL GetCoefs ( ISeg, AlfaD, Re, AF_Table(AFfile(ISeg)), ClLoc, CdLoc, CmLoc, CpminLoc, .FALSE., .TRUE., UseCm ,UseCpmin) !.FALSE., .FALSE. )
      ENDIF ! ( .NOT. ( AIDrag .OR. TIDRAG ) )

      Return
   ENDIF ! (Converg)

      ! Still have not found a solution. Try a different range again
   AxIndLo = -1.0
   AxIndHi = 2.5
   AxInd = BinSearch( AxIndLo, AxIndHi, .False., AxIndErr_Curr )
   IF (Converg) THEN
      TanIndPrevSeg = TanInd
      AxIndPrevSeg  = AxInd
      ZFound = .TRUE.

      ! Add skewed-wake correction to axial induction.
      AxInd = AxInd*SWcorr

      IF ( .NOT. ( AIDrag .OR. TIDRAG ) )  THEN
         CALL GetCoefs ( ISeg, AlfaD, Re, AF_Table(AFfile(ISeg)), ClLoc, CdLoc, CmLoc, CpminLoc, .FALSE., .TRUE., UseCm ,UseCpmin) ! .FALSE., .FALSE. )
      ENDIF ! ( .NOT. ( AIDrag .OR. TIDRAG ) )

      Return
   ENDIF ! (Converg)

      ! If by this point we have not converged on a solution, there most likely isn't one.


Return  ! End of iteration routine


   !-----------------------------------------------------------------------
   CONTAINS
      FUNCTION AxIndErr ( AInd, AxIndErr_Curr )


         ! Compute the error in the axial induction.


         ! Function declaration.

      REAL(ReKi)                   :: AxIndErr                                     ! This function.


         ! Argument declarations.

      REAL(ReKi), INTENT(IN)       :: AInd                                         ! The axial-induction factor.
      REAL(ReKi), INTENT(INOUT)    :: AxIndErr_Curr                                ! Current value of AxIndErr to pass to TanIndErr


         ! Local declarations.

      REAL(ReKi)                   :: B0                                           ! Polynomial coefficient used to calculate Dct in the advanced brake state.
      REAL(ReKi)                   :: B1                                           ! Polynomial coefficient used to calculate Dct in the advanced brake state.
      REAL(ReKi)                   :: B2                                           ! Polynomial coefficient used to calculate Dct in the advanced brake state.
      REAL(ReKi)                   :: Dct                                          ! Head-loss coefficient.





         ! For this axial induction, iterate on airflow angle and tangential induction to get better values for them.

      CALL GetAFTI ( AInd, TanInd, AFang, AxIndErr_Curr )


         ! Calculate the error in axial induction.  Dct = Head-loss coefficient.
         ! Deal with the airflow angle being zero by forcing it to use the imperical expression.


      IF ( AInd .GT. 0.97 .and. AInd .LT. 1.03 )  THEN
         SwNew = ((VtotTang*VTotTang*(1+TanInd)*(1+TanInd))/(VTotNorm*VTotNorm))+ ((1-AInd)*(1-AInd))
         Dct   = Solidity*CnLoc *SwNew / CosCone
      ELSE
         Sw  = Solidity*CnLoc*CosCone*CosCone/( 4.0*SinAF*SinAF )
         Dct = Sw*4.0*( 1.0 - AInd )*( 1.0 - AInd )
      END IF


      IF ( Dct < 0.96*Loss )  THEN
         AxIndErr = 0.5*( 1.0 - SQRT( 1.0 - Dct/Loss ) ) - AInd
         B2       = 1/0.18 - 4.0*Loss                                              !  1.555 w/o loss
         B1       = 0.8*( Loss - B2 )                                              ! -1.244 w/o loss
         B0       = 2.0 - B1 - B2                                                  !  1.688 w/o loss
      ELSE
         B2       = 1/0.18 - 4.0*Loss                                              !  1.555 w/o loss
         B1       = 0.8*( Loss - B2 )                                              ! -1.244 w/o loss
         B0       = 2.0 - B1 - B2                                                  !  1.688 w/o loss
         AxIndErr = 0.5*( -B1 + SQRT( B1*B1 - 4.0*B2*( B0 - Dct ) ) )/B2 - AInd
      ENDIF


!!Keep the following for future plotting options: Start
!DctLs = 4.0*AInd*Loss*(1.0 - AInd);
!DctGr_Glau = B0 + B2*(AInd*AInd) + B1*AInd;

!IF (DctLs .LT. 0.96*Loss .AND. AInd .LT. 0.4) THEN
!DctBem = DctLs
!ELSE
!DctBem = DctGr_Glau
!ENDIF

!ClBem = (1.0/CosAF)*(((DctBem*SinAF*SinAF)/((1-(AInd))*(1-(AInd))*Solidity*CosCone*CosCone))-CdLoc*SinAF)

!IF (.FALSE. .and. WriteDebug) THEN
!write (UnDB,'(1X,1F20.13,2F24.6,4F13.6,1F20.4,10F16.6,8F24.6)') AInd, Sw, Dct, AxIndErr + AInd, AxIndErr,AlfaD,ClLoc,ClBem,DctZero,Loss,DctBem,SinAF,DctNew,SwNew,TanInd,TISingularity,AFang,CtLoc,TanIndCoef,TanIndCoef_Cd,TanIndCoef_Old,TanIndCoef_Cl,SingTransition,Solidity,LSR,SingUpper
!ENDIF

!!Keep the following for future plotting options: END


      RETURN
      END FUNCTION AxIndErr ! ( AInd )
   !-----------------------------------------------------------------------
      FUNCTION BinSearch( XLo, XHi, Display, AxIndErr_Curr )


         ! Do a binary search of function AxIndErr between XLo and XHi by splitting the region NSplit times.
         ! This method is sometimes referred to as a half-interval search or bisection method.


         ! Function declaration.

      REAL(ReKi)                   :: BinSearch                                    ! This function.


         ! Argument declarations.

      REAL(ReKi), INTENT(INOUT)    :: XLo                                        ! The lower X.
      REAL(ReKi), INTENT(INOUT)    :: XHi                                        ! The upper X.
      REAL(ReKi), INTENT(INOUT)    :: AxIndErr_Curr                              ! Current AxIndErr value for

      Logical, INTENT(IN)          :: Display                                    ! Display output?

         ! Local declarations.

      REAL(ReKi)                   :: F                                          ! The function evaluated at the midpoint of the current segment.
      REAL(ReKi)                   :: FHi                                        ! The function evaluated at the higher endpoint of the current segment.
      REAL(ReKi)                   :: FLo                                        ! The function evaluated at the lower endpoint of the current segment.
      REAL(ReKi)                   :: X                                          ! The midpoint of the current segment.

      INTEGER                      :: Iter                                       ! Iteration counter


         ! Let's see if the function evaluates to zero for either endpoint.  If so, we are done.

      FLo = AxIndErr( XLo, AxIndErr_Curr )
      FHi = AxIndErr( XHi, AxIndErr_Curr )


      IF ( ABS( FLo ) <= ATol )  THEN
         BinSearch = Xlo
         Converg   = .TRUE.
         RETURN
      ELSE IF ( ABS( FHi ) <= ATol )  THEN
         BinSearch = XHi
         Converg   = .TRUE.
         RETURN
      END IF


         ! Let's make sure we bound the function zero.

      IF ( FHi/FLo > 0.0 )  THEN
         BinSearch = 0.0
         Return
      END IF


         ! Let's split at most NSplit times.  One last split done later.

      DO Iter=1,NSplit-1

         X = 0.5*( XHi + XLo )
         F = AxIndErr( X, AxIndErr_Curr )
         AxIndErr_Curr = F

         IF ( ABS( F ) <= ATol )  THEN
            BinSearch = X
            Converg   = .TRUE.
            RETURN
         END IF

         IF ( FHi/F < 0.0 )  THEN
            XLo = X
            FLo = F
         ELSE
            XHi = X
            FHi = F
         END IF

      END DO


         ! And one last split.

      BinSearch = 0.5*( XHi + XLo )
      CALL GetAFTI ( BinSearch, TanInd, AFang, AxIndErr_Curr )

      Converg = .TRUE.

      F = AxIndErr( BinSearch, AxIndErr_Curr )
      AxIndErr_Curr = F

      RETURN
      END FUNCTION BinSearch ! ( XLo, XHi, NSplit, AxIndErr_Curr )
   !-----------------------------------------------------------------------
      RECURSIVE Subroutine FindZC( PriCall, AxMin, AxMax, NumStep, ZFound, AxIndLo, AxIndHi, FindZ_C, AxIndErr_Curr )


         ! Find the zero crossing of the function whose zero we are trying to find. This is an exhaustive search method.
         ! Return the linearly interpolated value between the two bounding points.


         ! Function declaration.
      REAL(ReKi),INTENT(OUT)       :: FindZ_C                                      ! This function.

         ! Argument declarations.

      REAL(ReKi), INTENT(OUT)      :: AxIndHi                                      ! The upper of the two bounding points.
      REAL(ReKi), INTENT(OUT)      :: AxIndLo                                      ! The lower of the two bounding points.
      REAL(ReKi), INTENT(IN)       :: AxMax                                        ! The upper bound for axial induction.
      REAL(ReKi), INTENT(IN)       :: AxMin                                        ! The lower bound for axial induction.
      REAL(ReKi), INTENT(INOUT)    :: AxIndErr_Curr                                ! Current value of AxIndErr

      INTEGER, INTENT(IN)          :: NumStep                                      ! The number of steps to take.

      LOGICAL, INTENT(IN)          :: PriCall                                      ! Flag to indicate if the current call to the routine is a primary or secondary (recursive) call.
      LOGICAL, INTENT(OUT)         :: ZFound                                       ! Flag to indicate if we found a zero crossing.


         ! Local declarations.

      REAL(ReKi)                   :: AxErr                                        ! Current error in axial induction.
      REAL(ReKi)                   :: AxErrMin                                     ! The error for the 1-delta case.
      REAL(ReKi)                   :: AxErrOld                                     ! Previous error in axial induction.
      REAL(ReKi)                   :: AxErrPlu                                     ! The error for the 1+delta case.
      REAL(ReKi)                   :: AxInd                                        ! Current value of axial induction.
      REAL(ReKi)                   :: AxPrev                                       ! Previous value of axial induction.
      REAL(ReKi)                   :: DeltaErr                                     ! The change in the error function between two tests.
      REAL(ReKi)                   :: Step                                         ! Step size for axial induction.

      INTEGER                      :: Iter                                         ! The iteration counter.

      LOGICAL                      :: Init                                         ! Flag to indicate if we are in the initialization phase.



         ! Initializations.

      Step   = ( AxMax - AxMin )/REAL( NumStep )
      Init   = .TRUE.
      ZFound = .FALSE.


      AxErrOld = AxIndErr( AxMin, AxIndErr_Curr )
      ! PRINT *, "     FindZC1: ", iters, AxMin, AxErrOld
      IF ( AxErrOld == 0.0 )  THEN
         AxIndHi = AxMin + Step
         AxIndLo = AxMin
         FindZ_C  = AxMin
         ZFound  = .TRUE.
         RETURN
      END IF

      AxPrev = AxMin


      DO Iter=1,NumStep

         AxInd = AxMin + Iter*Step

         ! IF ( ( AxOneMin < AxInd ) .AND. ( AxInd < AxOnePlu ) )  AxInd = AxOnePlu    ! Let's avoid a singulatity.

         AxErr = AxIndErr( AxInd, AxIndErr_Curr )
         AxIndErr_Curr = AxErr

         If (Iter .EQ. 1) Then
         DeltaErr = AxErr - AxErrOld  ! Initialize First Point
         ENDIF

         IF ( AxErr/AxErrOld <= 0.0 )  THEN

            ZFound  = .TRUE.
         Else IF ( PriCall .AND. ( AxErr == AxErrOld ) )  THEN   ! We don't want to do this on a recursive call.  It may not ever touch the zero line!
      ! We are at a minimum or maximum.  Let's do a finer search here to see if we just kissed the zero line.
            Call FindZC( .FALSE., AxInd-Step, AxInd+Step, 1*NumStep, ZFound, AxIndLo, AxIndHi, FindZ_C, AxIndErr_Curr )
         ELSE IF ( PriCall .AND. ( DeltaErr/( AxErr - AxErrOld ) < 0.0 ) )  THEN   ! This was done as two tests because not all compilers shortcut.
      ! We just passed a minimum or maximum.  Let's do a finer search here to see if we just kissed the zero line.
            Call FindZC( .FALSE., AxInd-Step, AxInd+Step, 1*NumStep, ZFound, AxIndLo, AxIndHi, FindZ_C, AxIndErr_Curr )
         END IF

         IF ( ZFound )  THEN

               AxIndHi  = AxInd
               AxIndLo  = AxPrev
               FindZ_C  = AxErrOld*( AxIndHi - AxIndLo )/( AxErrOld - AxErr ) + AxIndLo
               RETURN
         END IF
         DeltaErr = AxErr - AxErrOld
         Init     = .FALSE.
         AxPrev   = AxInd
         AxErrOld = AxErr

      ENDDO ! Iter


      RETURN
      END Subroutine FindZC ! ( FirstCall, AxMin, AxMax, NumStep, ZFound, AxIndLo, AxIndHi )
   ! -----------------------------------------------------------------------
      SUBROUTINE GetAFTI ( AInd, TInd, AF, AxIndErr_Curr )


         ! Get the airflow angle and tangential induction factor.


         ! Argument declarations.

      REAL(ReKi), INTENT(INOUT)    :: AF                                           ! The airflow angle.
      REAL(ReKi), INTENT(IN)       :: AInd                                         ! The axial-induction factor.
      REAL(ReKi), INTENT(INOUT)    :: TInd                                         ! The tangential-induction factor.
      REAL(ReKi), INTENT(INOUT)    :: AxIndErr_Curr                                ! Current value of AxIndErr to pass to TanIndErr.


         ! Local declarations.

      REAL(ReKi)                   :: AlfaR                                        ! The angle of attack in radians.
      REAL(ReKi)                   :: LossHub  = 1.0                               ! Hub-loss correction factor.
      REAL(ReKi)                   :: LossTip  = 1.0                               ! Tip-loss correction factor.
      REAL(ReKi)                   :: Re                                           ! Reynolds number.
      REAL(ReKi)                   :: VInd                                         ! The total relative wind speed.

      INTEGER                      :: I                                            ! DO loop counter.
      INTEGER, PARAMETER           :: NAFTIit  = 10                                ! Number of iterations for airflow angle and tangential induction for a given axial induction.



         ! External references.




      VIndTang = VTotTang
      VIndNrm2 = ( VTotNorm*( 1.0 - AInd*SWcorr ) )**2

      DO I=1,NAFTIit

         VIndTang = VTotTang*( 1.0 + TInd )
         VInd     = SQRT( VIndTang**2 + VIndNrm2 )
         AF       = ATAN2( 1.0-AInd, (1.0+TInd)*LSR )
         CosAF    = COS( AF )
         SinAF    = SIN( AF )
         AlfaR    = AF - IncidAng
         AlfaD    = AlfaR*R2D

         IF ( AlfaD > 180.0 )  THEN
            AlfaD = AlfaD - 360.0
         ELSEIF ( AlfaD < -180.0 )  THEN
            AlfaD = AlfaD + 360.0
         ENDIF

         IF ( TIDrag )  THEN
            CALL GetCoefs ( ISeg, AlfaD, Re, AF_Table(AFfile(ISeg)), ClLoc, CdLoc, CmLoc, CpminLoc, .TRUE.,.TRUE. ,UseCm ,UseCpmin)
         ELSE
            CALL GetCoefs ( ISeg, AlfaD, Re, AF_Table(AFfile(ISeg)), ClLoc, CdLoc, CmLoc, CpminLoc, .TRUE.,.FALSE.,UseCm ,UseCpmin)
            CdLoc = 0.0
         ENDIF

         CtLoc = ClLoc*SinAF - CdLoc*CosAF



            ! Calculate the losses.

         IF ( TipLoss )                                              LossTip = Prandtl( 1.0,          RLocND(ISeg), SinAF )
         IF ( HubLoss .AND. ( HubRadND .GT. EPSILON( HubRadND ) ) )  LossHub = Prandtl( RLocND(ISeg), HubRadND,     SinAF )

         Loss = LossTip*LossHub
         TInd = TanIndErr( AInd, TInd, AxIndErr_Curr ) + TInd


      END DO

      IF ( AIDrag )  THEN
         CnLoc = ClLoc*CosAF + CdLoc*SinAF
      ELSE
         CnLoc = ClLoc*CosAF
      ENDIF


      RETURN
      END SUBROUTINE GetAFTI ! ( AInd, TInd, AF, AxIndErr_Curr )
   ! -----------------------------------------------------------------------
      SUBROUTINE NewtRaph ( AxInd, TanInd, Display, AxIndErr_Curr )


         ! This is a Newton-Raphson method used to find the induction factors. This will run in either a 1D or 2D
         ! configuration (2D only if Swirl is included).
         ! Only keep the new values for AxIndErr and TanIndErr if they fall within certain reasonable limits.


         ! Argument declarations.

      REAL(ReKi), INTENT(INOUT)    :: AxInd                                        ! The axial-induction factor.
      REAL(ReKi), INTENT(INOUT)    :: TanInd                                       ! The tangential-induction factor.
      REAL(ReKi), INTENT(INOUT)    :: AxIndErr_Curr                                ! Current value of AxIndErr
      Logical, INTENT(IN)          :: Display                                      ! Display screen output?

         ! Local declarations.

      REAL(ReKi)                   :: AIdel                                        ! The iterative change in the axial induction factor.
      REAL(ReKi)                   :: AxErrAP                                      ! The error in the axial induction after perturbing the old value of the axial induction.
      REAL(ReKi)                   :: AxErrSlp                                     ! The slope of the axial-only error function.
      REAL(ReKi)                   :: AxErrTP                                      ! The error in the axial induction after perturbing the old value of the tangential induction.
      REAL(ReKi)                   :: AxErrUP                                      ! The unperturbed error in the axial induction.
      REAL(ReKi)                   :: DelAx                                        ! THe amount of change for the axial-induction finite differencing.
      REAL(ReKi)                   :: DelTan                                       ! THe amount of change for the tangential-induction finite differencing.
      REAL(ReKi)                   :: FunctAP                                      ! The axial-only error function using a finite differenced value for the old axial induction.
      REAL(ReKi)                   :: FunctUP                                      ! The unperturbed axial-only error function.
      REAL(ReKi)                   :: JacDet                                       ! The determinant of the Jacobian matrix.
      REAL(ReKi)                   :: JacInv   (2,2)                               ! The inverse of the Jacobian matrix.
      REAL(ReKi)                   :: Jacob    (2,2)                               ! The Jacobian matrix.
      REAL(ReKi)                   :: SumSqChng                                    ! The sum of the squares of the changes in the inductions.
      REAL(ReKi)                   :: TanErrAP                                     ! The error in the tangential induction after perturbing the old value of the axial induction.
      REAL(ReKi)                   :: TanErrTP                                     ! The error in the tangential induction after perturbing the old value of the tangential induction.
      REAL(ReKi)                   :: TanErrUP                                     ! The unperturbed error in the tangential induction.
      REAL(ReKi)                   :: TIdel                                        ! The iterative change in the tangential induction factor.


         ! For the Newt Raphson, we want to include the TanIndErr in the calculation (particularly in the 2-D case). Therefore, we set the AxIndErr_Curr to 0.0 so that
         ! TanIndErr will actually be calculated. For cases where the AxInd is far from a solution, TanIndErr could return ubsurd results. At the end of this routine we
         ! do a sanity check to make certain that the new values for AInd are between -0.5 and 1.5, and we check that TanInd is also between -0.5 and 0.5. If not, we
         ! don't return the new value. This routine could then be sped up slightly by checking for when this happens and not running again. This would involve another
         ! flag being added to the InductBEM routine to check this.

      AxIndErr_Curr = 0.0                       ! TanIndErr does not calculate unless AxIndErr is small. See the function for the exact limit used.

         ! Are we including swirl effects?

      IF ( Swirl )  THEN                        ! Include tangential-induction effects.

            ! Compute unperturbed induction,

         CALL GetAero ( ISeg, AxInd, TanInd )

         AxErrUP  =  AxIndErr(  AxInd, AxIndErr_Curr )
         TanErrUP = TanIndErr( AxInd, TanInd, AxIndErr_Curr )

         ! See if convergence is achieved.

         IF ( ( AxErrUP**2 + TanErrUP**2 ) <= ATol2 )  THEN
            Converg = .TRUE.
            RETURN
         ENDIF


            ! Perturb axial induction for finite differencing.

         DelAx = SIGN( MAX( ABS( AxInd*Del ), SQRT( Epsilon( AxInd ) ) ), AxInd )

         CALL GetAero ( ISeg, AxInd + DelAx, TanInd )

         AxErrAP  =  AxIndErr( AxInd + DelAx, AxIndErr_Curr )
         TanErrAP = TanIndErr( AxInd + DelAx, TanInd, AxIndErr_Curr )

            ! Perturb tangential induction for finite differencing.

         DelTan = SIGN( MAX( ABS( TanInd*Del ), SQRT( Epsilon( TanInd ) ) ), TanInd )

         CALL GetAero ( ISeg, AxInd, TanInd + DelTan )

         AxErrTP  =  AxIndErr( AxInd, AxIndErr_Curr )
         TanErrTP = TanIndErr( AxInd, TanInd + DelTan, AxIndErr_Curr )


            ! Compute the Jacobian.

         Jacob(1,1) = (  AxErrAP -  AxErrUP )/DelAx
         Jacob(1,2) = (  AxErrTP -  AxErrUP )/DelTan
         Jacob(2,1) = ( TanErrAP - TanErrUP )/DelAx
         Jacob(2,2) = ( TanErrTP - TanErrUP )/DelTan


            ! Invert the Jacobian.

         JacDet = Jacob(1,1)*Jacob(2,2) - Jacob(1,2)*Jacob(2,1)

         JacInv(1,1) =  Jacob(2,2)/JacDet
         JacInv(1,2) = -Jacob(1,2)/JacDet
         JacInv(2,1) = -Jacob(2,1)/JacDet
         JacInv(2,2) =  Jacob(1,1)/JacDet


            ! Calculate the required changes, the magnitude of the change squared, and the new values.

         AIdel = -JacInv(1,1)*AxErrUP - JacInv(1,2)*TanErrUP
         TIdel = -JacInv(2,1)*AxErrUP - JacInv(2,2)*TanErrUP

         SumSqChng = AIdel**2 + TIdel**2


            ! check that the new value will make some physical sense, then save it. Otherwise exit as non-convergent.
         IF ( ((AxInd  + AIdel) >= -0.5) .and. ((AxInd + AIdel)  <= 1.5)   .and. &
              ((TanInd + TIdel) >= -0.5) .and. ((TanInd + TIdel) <= 0.5) ) THEN
            AxInd  =  AxInd + AIdel
            TanInd = TanInd + TIdel
         ELSE
            Converg = .FALSE.
            RETURN
         ENDIF


      ELSE                                      ! Exclude tangential-induction effects.


            ! Compute unperturbed induction,

         CALL GetAero ( ISeg, AxInd, 0.0 )

         FunctUP = AxIndErr( AxInd, AxIndErr_Curr )

            ! See if convergence is achieved.

         IF ( FunctUP**2 <= ATol2 )  THEN
            Converg = .TRUE.
            RETURN
         ENDIF


            ! Perturb axial induction for finite differencing.

         CALL GetAero ( ISeg, AxInd+Del, 0.0 )

         FunctAP  = AxIndErr( AxInd+Del, AxIndErr_Curr )

            ! Compute slope.

         AxErrSlp  = ( FunctAP - FunctUP )/del
         AIdel     = -FunctUP/AxErrSlp
         SumSqChng = AIdel**2

            ! check that the new value will make sense, then save it. Otherwise don't change it
         IF ( ((AxInd + AIdel) <= 1.0) .and. ((AxInd + AIdel) >= -1.0) ) THEN
            AxInd     = AxInd + AIdel
         ELSE
            Converg = .FALSE.
            RETURN
         ENDIF




      ENDIF


      RETURN
      END SUBROUTINE NewtRaph ! ( AxInd, TanInd, Display, AxIndErr_Curr )
   !-----------------------------------------------------------------------
      FUNCTION TanIndErr ( AInd, TInd, AxIndErr_Curr )


         ! Compute the error in the tangential induction, but only if the Error in the Axial Induction (AxIndErr_Curr) is smallish
         ! This function also has a singularity avoidance smoothing built in for when SinAF = 0.0.


         ! Function declaration.

      REAL(ReKi)                   :: TanIndErr                                    ! This function.


         ! Argument declarations.

      REAL(ReKi), INTENT(IN)       :: TInd                                         ! The tangential-induction factor.
      REAL(ReKi), INTENT(IN)       :: AInd                                         ! The Axial-induction factor.
      REAL(ReKi), INTENT(IN)       :: AxIndErr_Curr                                ! Current value of AxIndErr

         ! Calcaluate error in tangential induction, but only if the Error in the Axial Induction (AxIndErr_Curr) is smallish
         ! Account for case where CtLoc is zero (means SinAF is zero).

         ! Only perform TanIndErr calculation when AxIndErr_Curr is small (limit was determined by trial and error).
      IF ( ABS(AxIndErr_Curr) <= 0.025 ) THEN
         IF ( CtLoc == 0.0 )  THEN
            TanIndErr = 1.0/( 4.0*Loss/Solidity - 1.0 ) - TInd
         ELSE

            SingUpper =((1.0718*ABS(CtLoc*Solidity) - 0.003)* ABS(LSR) + 1.01)* (SingOffset+1.0)

            IF (TISingularity .And. AInd .GE. 2.0-SingUpper .And. AInd .LE. SingUpper) THEN
               ! Smoothing over the singularity with function SingTransition
               A0Sing = 1.0
               A1Sing = SingUpper
               SingTransition = cos((Pi/2.0)*(AInd-A0Sing)/(A1Sing - A0Sing) - (Pi/2.0))  ! Cosine Transition
               SingTransition = SingTransition*SingTransition
            ELSE
               SingTransition = 1.0                                                       ! No transition
            END IF

            TanIndCoef_Cd = Solidity*CdLoc / (4.0*Loss*SinAF*CosCone)
            TanIndCoef_Cl = Solidity*ClLoc / (4.0*Loss*CosAF*CosCone)
            TanIndCoef    = TanIndCoef_Cl - SingTransition*TanIndCoef_Cd

               ! Calculate the error in the tangential induction.
            TanIndErr     = (TanIndCoef/(1-TanIndCoef)) - TInd

         ENDIF
      ELSE
         TanIndErr = 0.0         ! AxIndErr_Curr is too large, so we don't want to return a TanIndErr
      ENDIF   !( ABS(AxIndErr_Curr) <= 0.025 )


         ! Verify that the TanIndErr did not blow up, otherwise force it to a small value.
         ! Without this check, TanIndErr can blow up unexpectedly and lead to non-convergence because we end up
         !    in the wrong part of the solution space. This is particularly true with the Newt-Raphson routine.
      TanIndErr = max(TanIndErr, -2.0)         ! make sure is greater than -2.0 -- determined by trial and error
      TanIndErr = min(TanIndErr,  2.0)         ! make sure is   less  than  2.0 -- determined by trial and error

         !FUTURE ideas:  The turn on of this function is abrupt. It might be worth allowing it to be gradually turned
         !               on (perhaps with a gaussian weighting or something similar).

      RETURN
      END FUNCTION TanIndErr !( AInd, TInd, AxIndErr_Curr )
   !-----------------------------------------------------------------------

   END SUBROUTINE InductBEM ! ( ISeg, ZFound, Converg )
!=======================================================================
   SUBROUTINE IOInit


      ! This routine opens the I/O files.


   USE                             NWTC_Library
   USE                             Parameters
   USE                             ProgGen

   IMPLICIT                        NONE


      ! Local declarations.

   LOGICAL                      :: Error                                        ! Flag that says whether or not an error occurred.



      ! Get the input file name from the argument string.

   CALL Get_Arg ( 1, InpFile, Error )


      ! Check syntax.

   IF ( Error )  CALL ProgAbort ( ' Syntax is: wt_perf <InpFile>' )


      ! Open the input file.

   CALL OpenFInpFile ( UnIn,    InpFile                  )
   CALL GetRoot      ( InpFile, RootName                 )
   CALL OpenFOutFile ( UnOu,    TRIM( RootName )//'.oup' )


   RETURN
   END SUBROUTINE IOInit
!=======================================================================
   SUBROUTINE ParmAnal


      ! This routine performs the rotor analysis.


   USE                             Parameters
   USE                             ProgGen
   USE                             WTP_Data

   IMPLICIT                        NONE


      ! Argument declarations.



      ! Local decarations.

   LOGICAL                      :: Converged                                       ! Flag indicating RotAnal fully converged in all loops.

   REAL(ReKi)                   :: MaxCp                                           ! The maximum Cp for a given sheet.



   INTEGER                      :: ICol                                            ! Index for the column parameter.
   INTEGER                      :: Ind(2)                                          ! Index array for maximum Cp.
   INTEGER                      :: IOmg                                            ! Index for rotor speed.
   INTEGER                      :: IPit                                            ! Index for pitch angle.
   INTEGER                      :: IRow                                            ! Index for the row parameter.
   INTEGER                      :: ISpd                                            ! Index for wind speed or TSR.
   INTEGER                      :: ITab                                            ! Index for the table parameter.

   CHARACTER( 20), PARAMETER    :: FmtCpSpc = "(F7.3,1000(F11.4,:))"
   CHARACTER( 24), PARAMETER    :: FmtCpTab = "(F7.3,1000('"//Tab//"',F9.6,:))"
   CHARACTER( 20), PARAMETER    :: FmtDaSpc = "(F7.3,1000(F11.3,:))"
   CHARACTER( 24), PARAMETER    :: FmtDaTab = "(F7.3,1000('"//Tab//"',F11.3,:))"
   CHARACTER( 11), PARAMETER    :: FmtDbLin = "(80('='),/)"
   CHARACTER(107), PARAMETER    :: FmtHdSpc = "(80('-'),/," &
                                            //"A,' (', A,') for ',A,' = ',A,' ',A,'.',//," &
                                            //"2X,A,'   ',A,' (',A,')',/," &
                                            //"2X,'(',A,')',1000( F11.3,:))"
   CHARACTER( 99), PARAMETER    :: FmtHdTab = "(80('-'),/" &
                                            //"A,' (',A,') for ',A,' = ',A,' ',A,'.',//" &
                                            //"A,'"//Tab//"',A,' (',A,')',/" &
                                            //"'(',A,')',1000('"//Tab//"',F7.3,:))"


   OmegaLoop: DO IOmg=1,NumOmg      ! -------------------------  Start of rotor-speed loop  -------------------------

      OmgRPM   = OmgAry(IOmg)
      Omega    = OmgRPM*RPM2RPS
      TipSpeed = Omega*SweptRad


         ! Print out rotor speed.

      CALL WrScr ( ' Rotor speed = '//TRIM( Num2LStr( OmgRPM ) )//' rpm.' )




         ! Start of Pitch-angle loop.

      PitchLoop: DO IPit=1,NumPit

         PitDeg = PitAry(IPit)
         Pitch  = PitDeg*D2R


            ! Print out pitch angle.


            ! Start of wind-speed or TSR loop.

         SpeedLoop: DO ISpd=1,NumSpd

            Spd = SpdAry(ISpd)

            CALL GetInds ( IOmg, IPit, ISpd, IRow, ICol, ITab )


               ! Make appropriate conversion between wind speed and tip-speed ratio.

            IF ( InputTSR )  THEN
               VelHH = TipSpeed/Spd
               TSR   = Spd
            ELSE
               VelHH = Spd*ConvFact
               TSR   = TipSpeed/VelHH
            ENDIF


               ! Compute rotor performance.

            CALL RotAnal(Converged)


                 ! Store results if the case converged.
                 ! If it failed, set the output according to the

            IF ( Converged ) THEN

               IF ( OutPwr .OR. UnfPower )  PwrAry(IRow,ICol,ITab) = Power
               IF ( OutCp  )                CpAry (IRow,ICol,ITab) = PwrC
               IF ( OutTrq )                TrqAry(IRow,ICol,ITab) = Torque
               IF ( OutFlp )                FlpAry(IRow,ICol,ITab) = FlapMom
               IF ( OutThr )                ThrAry(IRow,ICol,ITab) = Thrust

            ELSE ! ( Converged )
               IF ( ConvFlag == 1 ) THEN
                  IF ( OutPwr .OR. UnfPower )  PwrAry(IRow,ICol,ITab) = 9999.999   / ConvPwr
                  IF ( OutCp  )                CpAry (IRow,ICol,ITab) =  999.9999
                  IF ( OutTrq )                TrqAry(IRow,ICol,ITab) = 9999.999   / ConvTrq
                  IF ( OutFlp )                FlpAry(IRow,ICol,ITab) = 9999.999   / ConvTrq
                  IF ( OutThr )                ThrAry(IRow,ICol,ITab) = 9999.999   / ConvFrc
               ELSE ! ( ConvFlag == 1 )
                  IF ( OutPwr .OR. UnfPower )  PwrAry(IRow,ICol,ITab) = NaN
                  IF ( OutCp  )                CpAry (IRow,ICol,ITab) = NaN
                  IF ( OutTrq )                TrqAry(IRow,ICol,ITab) = NaN
                  IF ( OutFlp )                FlpAry(IRow,ICol,ITab) = NaN
                  IF ( OutThr )                ThrAry(IRow,ICol,ITab) = NaN
               ENDIF
            ENDIF


         ENDDO SpeedLoop ! ISpd


            ! Increment the blade Pitch angle.

         PitDeg = PitDeg + PitDel

      ENDDO PitchLoop ! IPit


         ! Increment the rotor speed.

      OmgRPM = OmgRPM + OmgDel

   ENDDO OmegaLoop ! IOmg

! this header is only printed at the beginning of the file.
! The cavitation flag is TRUE if cavitation occurs during ANY case of the parametric analysis
   WRITE (UnOu,'(A)')  'Results generated by '//TRIM( ProgName )//TRIM( ProgVer )//' for input file "'//TRIM( InpFile )//'".'
   WRITE (UnOu,'(A)')  'Generated on '//TRIM( DateNow )//' at '//TRIM( TimeNow )//'.'
   WRITE (UnOu,'(A)')  'Input file title:'
   WRITE (UnOu,'(A)')  '  '//TRIM( RunTitle )
   WRITE (UnOu,'(A)')  ' '

   IF ( Cavitation ) THEN
      WRITE (UnOu,'(A)') 'Cavitation detected:'
      If ( CavForAnyCase ) THEN
         WRITE (UnOu,'(A)') '  Yes'
      ELSE
         WRITE (UnOu,'(A)') '  No'
      ENDIF
   ElSE
      WRITE (UnOu,'(A)')  ' '
      WRITE (UnOu,'(A)')  ' '
   ENDIF
   WRITE (UnOu,'(A)') '================================================================================'
   WRITE (UnOu,'(A)')  ' '

      ! If requested, write out array dimensions and power to an unformatted file.

   IF ( UnfPower )  THEN

      CALL OpenUOutfile ( UnUn, TRIM( RootName )//'.pwr' )

      WRITE (UnUn)  MaxRow, MaxCol, MaxTab
      WRITE (UnUn)  ConvPwr*PwrAry(:,:,:)

      CLOSE ( UnUn )

   ENDIF


      ! If requested, write out results matrices to a formatted file.

   DO ITab=1,MaxTab


         ! Write out matrix header.


         ! Output the maximum Cp case if requested.

      IF ( OutMaxCp )  THEN

         MaxCp = MAXVAL( CpAry(:,:,ITab) )
         Ind   = MAXLOC( CpAry(:,:,ITab) )

         WRITE (UnOu,'(A)')  'Conditions leading to the maximum Cp:'
         WRITE (UnOu,'("  ",A," = ",F7.3," ",A)')  ParamStr(ParRow), RowAry(Ind(1)), UnitsStr(ParRow)
         WRITE (UnOu,'("  ",A," = ",F7.3," ",A)')  ParamStr(ParCol), ColAry(Ind(2)), UnitsStr(ParCol)
         WRITE (UnOu,'("  ",A," = ",F7.3)'      )  'MaxCp', MaxCp
         WRITE (UnOu,'()')

      ENDIF


         ! Output power?

      IF ( OutPwr )  THEN

         IF ( TabDel )  THEN
            WRITE (UnOu,FmtHdTab)  'Power', TRIM( ADJUSTL( PwrUnits ) ), TRIM( ParamStr(ParTab) ), TRIM(Num2LStr(TabAry(ITab))) &
                                  , UnitsStr(ParTab), TRIM( ParamStr(ParRow) ), TRIM( ParamStr(ParCol) ), UnitsStr(ParCol) &
                                  , UnitsStr(ParRow), ( ColAry(ICol), ICol=1,MaxCol )
         ELSE
            WRITE (UnOu,FmtHdSpc)  'Power', TRIM( ADJUSTL( PwrUnits ) ), TRIM( ParamStr(ParTab) ), TRIM(Num2LStr(TabAry(ITab)))  &
                                  , UnitsStr(ParTab), TRIM( ParamStr(ParRow) ), TRIM( ParamStr(ParCol) ), UnitsStr(ParCol)  &
                                  , UnitsStr(ParRow), ( ColAry(ICol), ICol=1,MaxCol )
         ENDIF

         DO IRow=1,MaxRow

            IF ( TabDel )  THEN
               WRITE (UnOu,FmtDaTab)   RowAry(IRow), ( ConvPwr*PwrAry(IRow,ICol,ITab), ICol=1,MaxCol )
            ELSE
               WRITE (UnOu,FmtDaSpc)   RowAry(IRow), ( ConvPwr*PwrAry(IRow,ICol,ITab), ICol=1,MaxCol )
            ENDIF

         ENDDO ! IRow

         WRITE (UnOu,'(A)')  ' '

      ENDIF


         ! Output Cp?

      IF ( OutCp )  THEN

         IF ( TabDel )  THEN
            WRITE (UnOu,FmtHdTab)  'Cp', '-', TRIM( ParamStr(ParTab) ), TRIM(Num2LStr(TabAry(ITab))), UnitsStr(ParTab) &
                                  , TRIM( ParamStr(ParRow) ), TRIM( ParamStr(ParCol) ), UnitsStr(ParCol), UnitsStr(ParRow) &
                                  , ( ColAry(ICol), ICol=1,MaxCol )
         ELSE
            WRITE (UnOu,FmtHdSpc)  'Cp', '-', TRIM( ParamStr(ParTab) ), TRIM(Num2LStr(TabAry(ITab))), UnitsStr(ParTab) &
                                  , TRIM( ParamStr(ParRow) ), TRIM( ParamStr(ParCol) ), UnitsStr(ParCol), UnitsStr(ParRow) &
                                  , ( ColAry(ICol), ICol=1,MaxCol )
         ENDIF

         DO IRow=1,MaxRow

            IF ( TabDel )  THEN
               WRITE (UnOu,FmtCpTab)   RowAry(IRow), ( CpAry(IRow,ICol,ITab), ICol=1,MaxCol )
            ELSE
               WRITE (UnOu,FmtCpSpc)   RowAry(IRow), ( CpAry(IRow,ICol,ITab), ICol=1,MaxCol )
            ENDIF

         ENDDO ! IRow

         WRITE (UnOu,'(A)')  ' '

      ENDIF


         ! Output torque?

      IF ( OutTrq )  THEN

         IF ( TabDel )  THEN
            WRITE (UnOu,FmtHdTab)  'Torque', TRIM( ADJUSTL( MomUnits ) ), TRIM( ParamStr(ParTab) ), TRIM(Num2LStr(TabAry(ITab))) &
                                  , UnitsStr(ParTab), TRIM( ParamStr(ParRow) ), TRIM( ParamStr(ParCol) ), UnitsStr(ParCol) &
                                  , UnitsStr(ParRow), ( ColAry(ICol), ICol=1,MaxCol )
         ELSE
            WRITE (UnOu,FmtHdSpc)  'Torque', TRIM( ADJUSTL( MomUnits ) ), TRIM( ParamStr(ParTab) ), TRIM(Num2LStr(TabAry(ITab))) &
                                  , UnitsStr(ParTab), TRIM( ParamStr(ParRow) ), TRIM( ParamStr(ParCol) ), UnitsStr(ParCol) &
                                  , UnitsStr(ParRow), ( ColAry(ICol), ICol=1,MaxCol )
         ENDIF

         DO IRow=1,MaxRow

            IF ( TabDel )  THEN
               WRITE (UnOu,FmtDaTab)   RowAry(IRow), ( ConvTrq*TrqAry(IRow,ICol,ITab), ICol=1,MaxCol )
            ELSE
               WRITE (UnOu,FmtDaSpc)   RowAry(IRow), ( ConvTrq*TrqAry(IRow,ICol,ITab), ICol=1,MaxCol )
            ENDIF

         ENDDO ! IRow

         WRITE (UnOu,'(A)')  ' '

      ENDIF


         ! Output flap bending moment?

      IF ( OutFlp )  THEN

         IF ( TabDel )  THEN
            WRITE (UnOu,FmtHdTab)  'Flap bending moment', TRIM( ADJUSTL( MomUnits ) ), TRIM( ParamStr(ParTab) ) &
                                  , TRIM(Num2LStr(TabAry(ITab))), UnitsStr(ParTab), TRIM( ParamStr(ParRow) ) &
                                  , TRIM( ParamStr(ParCol) ), UnitsStr(ParCol), UnitsStr(ParRow), ( ColAry(ICol), ICol=1,MaxCol )
         ELSE
            WRITE (UnOu,FmtHdSpc)  'Flap bending moment', TRIM( ADJUSTL( MomUnits ) ), TRIM( ParamStr(ParTab) ) &
                                  , TRIM(Num2LStr(TabAry(ITab))), UnitsStr(ParTab), TRIM( ParamStr(ParRow) ) &
                                  , TRIM( ParamStr(ParCol) ), UnitsStr(ParCol), UnitsStr(ParRow), ( ColAry(ICol), ICol=1,MaxCol )
         ENDIF

         DO IRow=1,MaxRow

            IF ( TabDel )  THEN
               WRITE (UnOu,FmtDaTab)   RowAry(IRow), ( ConvTrq*FlpAry(IRow,ICol,ITab), ICol=1,MaxCol )
            ELSE
               WRITE (UnOu,FmtDaSpc)   RowAry(IRow), ( ConvTrq*FlpAry(IRow,ICol,ITab), ICol=1,MaxCol )
            ENDIF

         ENDDO ! IRow

         WRITE (UnOu,'(A)')  ' '

      ENDIF


         ! Output thrust?

      IF ( OutThr )  THEN

         IF ( TabDel )  THEN
            WRITE (UnOu,FmtHdTab)  'Thrust', TRIM( ADJUSTL( FrcUnits ) ), TRIM(ADJUSTL(ParamStr(ParTab))) &
                                  , TRIM(Num2LStr(TabAry(ITab))), UnitsStr(ParTab), TRIM(ADJUSTL(ParamStr(ParRow))) &
                                  , TRIM(ADJUSTL(ParamStr(ParCol))), UnitsStr(ParCol), UnitsStr(ParRow) &
                                  , (ColAry(ICol), ICol=1,MaxCol)
        ELSE
            WRITE (UnOu,FmtHdSpc)  'Thrust', TRIM( ADJUSTL( FrcUnits ) ), TRIM( ParamStr(ParTab) ), TRIM(Num2LStr(TabAry(ITab))) &
                                  , UnitsStr(ParTab), TRIM( ParamStr(ParRow) ), TRIM( ParamStr(ParCol) ), UnitsStr(ParCol) &
                                  , UnitsStr(ParRow), ( ColAry(ICol), ICol=1,MaxCol )
         ENDIF

         DO IRow=1,MaxRow

            IF ( TabDel )  THEN
               WRITE (UnOu,FmtDaTab)   RowAry(IRow), ( ConvFrc*ThrAry(IRow,ICol,ITab), ICol=1,MaxCol )
            ELSE
               WRITE (UnOu,FmtDaSpc)   RowAry(IRow), ( ConvFrc*ThrAry(IRow,ICol,ITab), ICol=1,MaxCol )
            ENDIF

         ENDDO ! IRow

         WRITE (UnOu,'(A)')  ' '

      ENDIF

      IF ( ITab .NE. MaxTab )  WRITE (UnOu,FmtDbLin)

   ENDDO ! ITab


   RETURN
   END SUBROUTINE ParmAnal
!=======================================================================
   FUNCTION Prandtl( R1, R2, SinAFA )


      ! Prandtl tip loss model.  The formulation of the algorithm was
      ! changed by M. Buhl to make it slightly more efficient.


   USE                             WTP_Data
   USE                             Parameters

   IMPLICIT                        NONE


      ! Function declaration.

   REAL(ReKi)                   :: Prandtl


      ! Argument declarations.

   REAL(ReKi), INTENT(IN)       :: R1                                           ! 1.0 (TL) or non-dimensional local radius (HL).
   REAL(ReKi), INTENT(IN)       :: R2                                           ! Non-dimensional local radius (TL) or Non-dimensional hub radius (HL).
   REAL(ReKi), INTENT(IN)       :: SinAFA                                       ! Sine of the airflow angle.


      ! Local declarations.

   REAL(ReKi)                   :: Expon                                        ! Exponent (f) in the calculation.
   REAL(ReKi)                   :: F                                            ! e^(-f).



   Expon = ABS( 0.5*NumBlade*( R1 - R2 )/( R2*SinAFA ) )

   IF ( Expon .LT. 7.0 )  THEN
      F       = EXP( -Expon )
      Prandtl = TwoByPi*ATAN( SQRT( 1.0 - F*F )/F )                             ! ACOS(F)=ATAN(SQRT((1-F^2)/F))
   ELSE
      Prandtl = 1.0
   ENDIF


   RETURN
   END FUNCTION Prandtl ! ( R1, R2, SinAFA )
!=======================================================================
   SUBROUTINE RotAnal(CaseConv)


      ! This routine performs the rotor analysis.


   USE                             Parameters
   USE                             ProgGen
   USE                             WTP_Data

   IMPLICIT                        NONE

      ! Variables for Convergence
   REAL(ReKi)                   :: AxIndPrevSeg                                    ! Value of AxInd from previous converged segment, if not converged, uses these default values.
   REAL(ReKi)                   :: TanIndPrevSeg                                   ! Value of TanInd from previous converged segment, if not converged, uses these default values.


      ! Local decarations.

   REAL(ReKi)                   :: AreaAnn                                         ! The (parital) annulus area of the current local segment and section.
   REAL(ReKi)                   :: AreaLoc                                         ! The blade area of the current local segment.
   REAL(ReKi)                   :: AvgInfl                                         ! The average induced velocity deficit across the rotor.
   REAL(ReKi)                   :: Azim                                            ! The azimuth of the current section in degrees.
   REAL(ReKi)                   :: AzimR                                           ! The azimuth of the current section in radians.
   REAL(ReKi)                   :: CircLcND                                        ! Nondimensional circumference of the rotor cone at the middle of current segment.
   REAL(ReKi)                   :: CosFSkew                                        ! The cosine of the free-flow skew angle.
   REAL(ReKi)                   :: FlpLoc                                          ! Flap bending moment produced by the current local segment.
   REAL(ReKi)                   :: HtLocND                                         ! The local nondimensional height of the current analysis point from hub.
   REAL(ReKi)                   :: NB_QA                                           ! Number of blades divided by the dynamic pressure times the swept area.
   REAL(ReKi)                   :: PressAbs                                        ! Absolute Pressure, used in Cavitation Check
   REAL(ReKi)                   :: PwrCLoc                                         ! Power coefficient of the current local segment.
   REAL(ReKi)                   :: PwrLoc                                          ! Power produced by the current local segment.
   REAL(ReKi)                   :: Q_HH                                            ! Dynamic pressure at hub height.
   REAL(ReKi)                   :: QA                                              ! HH dymanic pressure times swept area.
   REAL(ReKi)                   :: QACC_NS                                         ! Temporary variable (QLoc*AreaLoc*CosCone/NumSect).
   REAL(ReKi)                   :: QLoc                                            ! The local dynamic pressure.
   REAL(ReKi)                   :: Re                                              ! The local Reynolds number.
   REAL(ReKi)                   :: ShearLoc                                        ! The local wind-shear effect on wind speed.
   REAL(ReKi)                   :: SumInfl                                         ! The sum of the induced velocity deficits times the ????.
   REAL(ReKi)                   :: Sigma                                           ! Sigma factor used in Cavitation Check
   REAL(ReKi)                   :: SinFSkew                                        ! The sine of the free-flow skew angle.
   REAL(ReKi)                   :: SinISkew                                        ! The sine of the induced skew angle.
   REAL(ReKi)                   :: SWconstO                                        ! The old value of SWconst.
   REAL(ReKi)                   :: ThrCLoc                                         ! Thrust coefficient of the current local segment.
   REAL(ReKi)                   :: ThrLoc                                          ! Thrust produced by the current local segment.
   REAL(ReKi)                   :: ThrLocLn                                        ! Thrust produced by the current local segment divided by the segment length.
   REAL(ReKi)                   :: TrqCLoc                                         ! Torque coefficient of the current local segment.
   REAL(ReKi)                   :: TrqLoc                                          ! Torque produced by the current local segment.
   REAL(ReKi)                   :: TrqLocLn                                        ! Torque produced by the current local segment divided by the segment length.
   REAL(ReKi)                   :: VInPlan2                                        ! Square of the in-plane component of wind speed in the rotor system.
   REAL(ReKi)                   :: VInPlane                                        ! In-plane component of wind speed in the rotor system.
   REAL(ReKi)                   :: VNyaw                                           ! Freestream wind speed reduced by the yaw angle.
   REAL(ReKi)                   :: VRotorX                                         ! X component of wind speed in the rotor system.
   REAL(ReKi)                   :: VRotorY                                         ! Y component of wind speed in the rotor system.
   REAL(ReKi)                   :: VRotorZ                                         ! Z component of wind speed in the rotor system.
   REAL(ReKi)                   :: VTot                                            ! Total, induced, relative wind speed for a local element.
   REAL(ReKi)                   :: VTot2                                           ! Square of the total, induced, relative wind speed for a local element.

   INTEGER                      :: ISect                                           ! Index for rotor sector.
   INTEGER                      :: ISeg                                            ! Index for blade segment.

   LOGICAL                      :: CaseConv                                        ! Flag that says if we converged all the induction loops for a case.
   LOGICAL                      :: CavElement  = .FALSE.                           ! Flag is set to TRUE if Cavitation occurs for the blade element being analyzed
   LOGICAL                      :: FoundSol                                        ! Flag that says if we found a solution for all the induction loops for a case.
   LOGICAL                      :: FullConv                                        ! Flag that says if we fully converged all the induction loops for a case.

   CHARACTER( 68), PARAMETER    :: FmtBEDs  = "(I5,F8.3,F10.2,F7.1,F8.2,4F9.3,2F9.2,4F9.3,F11.3,L5,3F9.3,3F12.3,L7)"

   CHARACTER(137), PARAMETER    :: FmtBEDt  = "(I4,'"//Tab//"',F9.3,'"//Tab//"',F8.2,'"//Tab//"',F9.1,'"//Tab//"',F8.2,'" &
                                              //Tab//"',4(F9.3,'"//Tab//"'),2(F8.2,'"//Tab//"'),4(F9.3,'"//Tab//"'),F11.3,'" &
                                              //Tab//"',L4,'"//Tab//"',3(F9.3,'"//Tab//"'),2(F12.3,'"//Tab//"'),F12.3,'"&
                                              //Tab//"',L4)"
   CHARACTER(450), PARAMETER    :: FmtBEHs  = "(/,' Elem    RElm  IncidAng   Azim  LocVel       Re     Loss    AxInd   TanInd" &
                                              //"  AFAngle    Alpha       Cl       Cd       Cm    Cpmin     CavNum  Cav    ThrCo" &
                                              //"    TrqCo    PwrCo     Thr/Len     Trq/Len       Power  Converge" &
                                              //"',/,'  (-)    (',A,')" &
                                              //"     (deg)  (deg)  (',A,')   (mill)      (-)      (-)      (-)    (deg)    (deg)" &
                                              //"      (-)      (-)      (-)      (-)        (-)  (-)      (-)      (-)      (-)" &
                                              //"    (',A,')       (',A,')        (kW)     (-)' )"
   CHARACTER(323), PARAMETER    :: FmtBEHt  = "(/,'Element"//Tab//"RElm"//Tab//"IncidAng"//Tab//"Azimuth"//Tab//"Loc Vel" &
                                              //Tab//"Re"//Tab//"Loss"//Tab//"Axial Ind."//Tab//"Tang. Ind." &
                                              //Tab//"Airflow Angle"//Tab//"AlfaD"//Tab//"Cl"//Tab//"Cd"//Tab//"Cm"//Tab//"Cpmin" &
                                              //Tab//"CavNum"//Tab//"Cav"//Tab//"Thrust Coef"//Tab//"Torque Coef" &
                                              //Tab//"Power Coef"//Tab//"Thrust/Len"//Tab//"Torque/Len"//Tab//"Power" &
                                              //Tab//"Converge',/,'(-)" &
                                              //Tab//"(',A,')"//Tab//"(deg)"//Tab//"(deg)"//Tab//"(',A,')"//Tab//"(millions)" &
                                              //Tab//"(-)"//Tab//"(-)"//Tab//"(-)"//Tab//"(deg)"//Tab//"(deg)"//Tab//"(-)" &
                                              //Tab//"(-)"//Tab//"(-)"//Tab//"(-)"//Tab//"(-)"//Tab//"(-)"//Tab//"(-)"//Tab//"(-)" &
                                              //Tab//"(-)"//Tab//"(',A,')"//Tab//"(',A,')"//Tab//"(kW)"//Tab//"(-)')"

   CHARACTER( 92)    :: FmtRPTs   = "(/'Blade-element data for Rotation Rate = ',A,' rpm, Blade Pitch = ',A,' deg, TSR = ',A,'.')"
   CHARACTER( 99)    :: FmtRPTt   = "(/'Blade-element data for:'" &
                                  //",/,A,'"//Tab//"rpm Rotation Rate'" &
                                  //",/,A,'"//Tab//"deg Blade Pitch'" &
                                  //",/,A,'"//Tab//"Tip-Speed Ratio')"
   CHARACTER(105)    :: FmtRPWs   = "(/'Blade-element data for Rotation Rate = ',A,' rpm, Blade Pitch = ',A,' deg, Wind Speed = '" &
                                  //",A,' ',A,'.')"
   CHARACTER(100)    :: FmtRPWt   = "(/'Blade-element data for:'" &
                                  //",/,A,'"//Tab//"rpm Rotation Rate'" &
                                  //",/,A,'"//Tab//"deg Blade Pitch'" &
                                  //",/,A,'"//Tab//"',A,' Wind Speed')"


      ! Initialize the accumulators.

   TrqC    = 0.0
   PwrC    = 0.0
   Thrust  = 0.0
   FlapMom = 0.0
   Torque  = 0.0
   Power   = 0.0


      ! Increment the number of cases being run.

   NCases = NCases + 1


      ! Hub-height dynamic pressure and related constants.

   Q_HH  = HalfRho*VelHH*VelHH
   QA    = Q_HH*SwptArea
   NB_QA = NumBlade/QA


      ! Write out header for the blade element file if requested.

   IF ( WriteBED )  THEN

      IF ( TabDel )  THEN

         IF ( InputTSR )  THEN
            IF ( WriteBED )  WRITE (UnBE,FmtRPTt)  TRIM( Num2LStr( OmgRPM ) ), TRIM( Num2LStr( PitDeg ) ), TRIM( Num2LStr( Spd ) )
         ELSE
            IF ( WriteBED )  WRITE (UnBE,FmtRPWt)  TRIM( Num2LStr( OmgRPM ) ), TRIM( Num2LStr( PitDeg ) ), TRIM( Num2LStr( Spd ) ) &
                             , SpdUnits
         ENDIF
         WRITE (UnBE,FmtBEHt)  TRIM( ADJUSTL( LenUnits ) ), TRIM( ADJUSTL( SpdUnits ) ), TRIM( ADJUSTL( FpLUnits ) ) &
                              , TRIM( ADJUSTL( MpLUnits ) )
      ELSE

         IF ( InputTSR )  THEN
            IF ( WriteBED )  WRITE (UnBE,FmtRPTs)  TRIM( Num2LStr( OmgRPM ) ), TRIM( Num2LStr( PitDeg ) ), TRIM( Num2LStr( Spd ) )
         ELSE
            IF ( WriteBED )  WRITE (UnBE,FmtRPWs)  TRIM( Num2LStr( OmgRPM ) ), TRIM( Num2LStr( PitDeg ) ), TRIM( Num2LStr( Spd ) ) &
                             , SpdUnits
         ENDIF
         WRITE (UnBE,FmtBEHs)  LenUnits, SpdUnits, FpLUnits, MpLUnits

      ENDIF

   ENDIF


      ! Initialize the case-convergence and full-convergenge flag.  They will be set to false if any induction loop fails.

   CaseConv = .TRUE.
   FoundSol = .TRUE.
   FullConv = .TRUE.


      ! Initialize AeroDyn's skewed-wake correction.  If we are not doing skewed wake, set the skewed-wake
      ! convergence flag to true so we output the element data, if requested.

   IF ( SkewWake )  THEN

      SumInfl  = 0.0
      VNyaw    = VelHH*CosYaw
      VRotorX  = VNyaw*CosTilt
      VRotorY  = VelHH*SinYaw
      VRotorZ  = -VNyaw*SinTilt
      VInPlan2 = VRotorY**2 + VRotorZ**2
      VInPlane = SQRT( VInPlan2 )

      IF ( VInPlane > 0.001 )  THEN
         SinFSkew =  VRotorY/VInPlane
         CosFSkew = -VRotorZ/VInPlane
         SinISkew = ABS( VRotorX )/VelHH
         SWconst  = ( 15*Pi/64 )*SQRT( ( 1.0 - SinISkew )/( 1.0 + SinISkew ) )
         SWconv   = .FALSE.
         DoSkew   = .TRUE.
      ELSE
         SWconst  = 0.0
         SWconv   = .TRUE.
         DoSkew   = .FALSE.
      ENDIF

   ENDIF


      ! Loop indefinitely until we converge the skewed-wake algorithm.

   SkewedWakeLoop: DO


         ! Start of Segment Loop.  Work our way out the blade.

      SegmentLoop: DO ISeg=1,NumSeg

         IF ( WriteBED .AND. SWconv .AND. PrntElem(ISeg) .AND. ( NumSect .GT. 1 ) )  WRITE(UnBE,'()')


         AreaLoc  = DelRLoc(ISeg)*Chord(ISeg)*RotorRad                      ! Number of blades accounted for at the end.
         AreaAnn  = 2*Pi*RLoc(ISeg)*CosCone*DelRLoc(ISeg)/NumSect           ! Area of annulus in local sector over which forces are averaged
         CircLcND = 2.0*Pi*RLocND(ISeg)*CosCone
         Solidity = NumBlade*Chord(ISeg)/CircLcND


            ! Calculate the local tangential velocity (body frame).

         VBodTang = TipSpeed*RLocND(ISeg)


            ! Calculate the incidence angle between the chord line and the
            ! cone of rotation.

         IncidAng = Twist(ISeg) + Pitch


            ! Initialize the inductions.

         AxInd  = 0.0
         TanInd = 0.0


            !  ------------------  Beginning of section loop.  -----------------------


            ! Work our way around the cone of rotation.

         SectionLoop: DO ISect=1,NumSect


               ! Calculate the blade azimuth and related constants.
               ! The first azimuth angle starts at 0 degrees.  This allows for a check of cavitation at the "12-o-clock" position, and also this should be more accurate for sheared inflow.
            Azim     = 360*(ISect - 1) / NumSect
            AzimR   = Azim*D2R
            CosAzim = COS( AzimR )
            SinAzim = SIN( AzimR )


               ! Calculate the local shear effect and the local wind speed.
            HtLocND  = RLocND(ISeg) * (CosAzim*CosCone*CosTilt - SinTilt*SinCone)

            ShearLoc = ( 1.0 + (HtLocND/HubHtND) )**ShearExp
            VWndGnd  = VelHH*ShearLoc*CavBeta*CavLambda ! Add DAWT corrections here  ! DAWT = Diffuser Augmented Wind (or Water) Turbine


               ! Get the undisturbed normal and tangential total wind speeds.

            CALL GetVel ( VTotNorm )


               ! Calculate the local speed ratio.

            SpdRatio = VBodTang/VTotNorm


               ! Calculate the skewed-wake correction for axial induction.

            IF ( DoSkew )  THEN
               SWcorr = 1.0 - 2.0*RLocND(ISeg)*SWconst*( SinFSkew*SinAzim + CosFSkew*CosAzim )  ! WT_Perf uses different definition of Azim
            ELSE
               SWcorr = 1.0
            ENDIF


               ! Calculate the induction factors.  The Prop version is like the old
               ! PROP-PC and WT_Perf.  The PropX version is like PROPX and AeroDyn.

            SELECT CASE ( IndType )

               CASE ( .False. )


                     ! No induction model.

                  AxInd  = 0.0
                  TanInd = 0.0

                  CALL GetAero ( ISeg, AxInd, TanInd )

                  Solution = .TRUE.
                  Converge = .TRUE.

               CASE ( .True. )

                     ! Use BEM induction model.

                  CALL InductBEM  ( ISeg, ISect, Solution, Converge, AxIndPrevSeg, TanIndPrevSeg )

            END SELECT

            IF ( .NOT. Solution )  FoundSol = .FALSE.
            IF ( .NOT. Converge )  FullConv = .FALSE.

            IF ( ( .NOT. Solution ) .OR. ( .NOT. Converge ) ) THEN
                  ! We have not found a solution or reached a required convergence.
               CaseConv = .FALSE.
            ENDIF


               ! Calculate results only after we've converged the skewed-wake correction.

            IF ( SWconv )  THEN


                  ! Update the velocities to use the last values of the inductions.

               VIndTang = VTotTang*( 1.0 + TanInd )
               VIndNorm = VTotNorm*( 1.0 -  AxInd )
               VIndNorm = VTotNorm*( 1.0 - AxInd*SWcorr )


                  ! Local dynamic pressure, section area.

               VTot2   = VIndTang*VIndTang + VIndNorm*VIndNorm
               QLoc    = HalfRho*VTot2
               QACC_NS = QLoc*AreaLoc*CosCone/NumSect


                     ! Local blade element data.

               ThrLoc = QACC_NS*( ClLoc*CosAF + CdLoc*SinAF )
               TrqLoc = QACC_NS*( ClLoc*SinAF - CdLoc*CosAF )*RLoc(ISeg)
               PwrLoc = TrqLoc*Omega
               FlpLoc = ThrLoc*( RLoc(ISeg) - HubRad )


                  ! Increment rotor dimensional data for single blade.

               Thrust  = Thrust  + ThrLoc
               Torque  = Torque  + TrqLoc
               Power   = Power   + PwrLoc
               FlapMom = FlapMom + FlpLoc

                  !!!!! Cavitation Check   !!!!!
         !    CavElement is a flag for cavitation at the current blade element being analyzed.
         !    For Parametric Analysis (ParmAnal), CavForAnyCase is a flag that gets set to TRUE
         !      if cavitation occurs at any time during the analysis (all posible cases being run),
         !      and once CavForAnyCase is set to TRUE it cannot get set back to FALSE.
         !    For Combined Case Analysis (CombAnal), CavForAnyCase gets reset to FALSE at the
         !      beginning of each case analysis, so we can distinguish which cases cavitation occured on.
         !    The formula for Sigma is such that CavSF is multiplied to the vapor pressure.
         !    The cavitation formula works for both sets of units metric/english

               IF (Cavitation) THEN
                  PressAbs = PressAtm + AirDens*Gravity*(WatDepth - HubHt - HtLocND*RotorRad)
                  Sigma = 2*(PressAbs - PressVaporCavSF)/(AirDens*VTot2) ! the classical definition, with a safety factor applied

                  IF ( ( Sigma + CpminLoc ) < 0 ) THEN
                     CavElement      = .TRUE.
                     CavForAnyCase   = .TRUE.
                  ELSE
                     CavElement      = .FALSE.
                  ENDIF

               ELSE
                  Sigma = 0  !placeholder value
               ENDIF

         !    Previously, if cavitation was detected we would output dummy values (Sevens) in the output file s.
         !    Now the originally calculated values are output, and we will output a special flag that says if
         !      cavitation occured or not.

               ! Output blade element data if requested.

               IF ( WriteBED .AND. PrntElem(ISeg) )  THEN


               ! Convert local thrust and torque to per unit length.

                  ThrLocLn = ThrLoc/DelRLoc(ISeg)
                  TrqLocLn = TrqLoc/DelRLoc(ISeg)


               ! Local blade element coefficients.

                  ThrCLoc = ThrLoc*NumBlade/(Q_HH*AreaAnn)
                  TrqCLoc = TrqLoc*NumBlade/(Q_HH*AreaAnn*RLoc(ISeg)*CosCone)
                  PwrCLoc = PwrLoc*NumBlade/(Q_HH*VelHH*AreaAnn)             ! Ploc/Pwind


               ! Calculate the Reynolds number in millions.

                  VTot = SQRT( VTot2 )
                  Re   = 1.0e-6*VTot*Chord(ISeg)*RotorRad/KinVisc


                  If ( ( ConvFlag == 1 ) .AND. ( ( .NOT. Solution ) .OR. ( .NOT. Converge ) ) ) THEN

                        ! Since we did not converge, we output nines to the bed file. Similarly, in the CombCase and ParmAnal routines we output nines.

                     IF (WriteDebug) THEN
                        write (*,'(A,7F13.6,I6,I6)') "Bad TSR, OmgRPM, PitDeg, AxInd, TanInd, AlfaD, ClLoc, iseg, ISect:", &
                                                       TSR, OmgRPM, PitDeg, AxInd, TanInd, AlfaD, ClLoc, iseg, ISect
                        write (UnDB,'(1X,7F16.9,I6,I6)') TSR,OmgRPM,PitDeg,AxInd,TanInd,AlfaD,ClLoc,iseg, ISect
                     ENDIF

                        ! Output dummy blade element data if requested.

                     IF ( TabDel )  THEN
                        WRITE (UnBE,FmtBEDt) ISeg, RLoc(ISeg), IncidAng*R2D, Azim, 999.99, 999.999, 999.999, 999.999, 999.999, &
                                                                 99999.99, 99999.99, 999.999, 999.999, 999.999, 999.999, 9999.999, &
                                                                 CavElement, &
                                                                 999.999, 999.999, 999.999, 9999.999, 9999.999, 9999.999, Converge
                     ELSE
                        WRITE (UnBE,FmtBEDs) ISeg, RLoc(ISeg), IncidAng*R2D, Azim, 999.99, 999.999, 999.999, 999.999, 999.999, &
                                                                 99999.99, 99999.99, 999.999, 999.999, 999.999, 999.999, 9999.999, &
                                                                 CavElement, &
                                                                 999.999, 999.999, 999.999, 9999.999, 9999.999, 9999.999, Converge
                     ENDIF

                  ELSEIF ( ( ConvFlag == 2 ) .AND. ( ( .NOT. Solution ) .OR. ( .NOT. Converge ) ) ) THEN

                     IF (WriteDebug) THEN
                        write (*,'(A,7F13.6,I6,I6)') "Bad TSR, OmgRPM, PitDeg, AxInd, TanInd, AlfaD, ClLoc, iseg, ISect:", &
                                                       TSR, OmgRPM, PitDeg, AxInd, TanInd, AlfaD, ClLoc, iseg, ISect
                        write (UnDB,'(1X,7F16.9,I6,I6)') TSR,OmgRPM,PitDeg,AxInd,TanInd,AlfaD,ClLoc,iseg, ISect
                     ENDIF

                        ! Output dummy blade element data if requested.

                     IF ( TabDel )  THEN
                        WRITE (UnBE,FmtBEDt) ISeg, RLoc(ISeg), IncidAng*R2D, Azim,  NaN, NaN, NaN, NaN, NaN, NaN, &
                                                                 NaN, NaN, NaN, NaN, NaN, NaN, CavElement,&
                                                                 NaN, NaN, NaN, NaN, NaN, NaN, Converge
                     ELSE
                        WRITE (UnBE,FmtBEDs) ISeg, RLoc(ISeg), IncidAng*R2D, Azim,  NaN, NaN, NaN, NaN, NaN, NaN, &
                                                                 NaN, NaN, NaN, NaN, NaN, NaN, CavElement,&
                                                                 NaN, NaN, NaN, NaN, NaN, NaN, Converge
                     ENDIF

                  ELSE ! ( ConvFlag )

                     IF ( TabDel )  THEN
                        WRITE (UnBE,FmtBEDt) ISeg, RLoc(ISeg), IncidAng*R2D, Azim, VTot, Re, Loss, AxInd, TanInd, AFangD, AlfaD, &
                                             ClLoc, CdLoc, CmLoc, CpminLoc, Sigma, CavElement, ThrCLoc, TrqCLoc,  PwrCLoc, &
                                             ThrLocLn, TrqLocLn, NumBlade*PwrLoc*ConvPwr, Converge

                     ELSE
                        WRITE (UnBE,FmtBEDs) ISeg, RLoc(ISeg), IncidAng*R2D, Azim, VTot, Re, Loss, AxInd, TanInd, AFangD, AlfaD, &
                                             ClLoc, CdLoc, CmLoc, CpminLoc, Sigma, CavElement, ThrCLoc, TrqCLoc,  PwrCLoc, &
                                             ThrLocLn, TrqLocLn, NumBlade*PwrLoc*ConvPwr, Converge

                     ENDIF

                  ENDIF ! ( ConvFlag)

               ENDIF ! ( WriteBED .AND. PrntElem(ISeg) )

            ELSEIF ( DoSkew )  THEN

               ! Increment the sum of the area-weighted inflow values for AeroDyn's skewed-wake correction.

               SumInfl = SumInfl + VTotNorm*AxInd*RLoc(ISeg)*DelRLoc(ISeg)

            ENDIF ! SWconv

         ENDDO SectionLoop ! ISect

      ENDDO SegmentLoop ! ISeg


         ! Exit skewed-wake loop if we converged the last pass.

      IF ( SWconv )  EXIT SkewedWakeLoop


         ! Update skewed-wake parameters.

      IF ( DoSkew )  THEN

         AvgInfl  = 2.0*SumInfl/( NumSect*RotorRad**2 )
         SumInfl  = 0.0
         SinISkew = ABS( VRotorX  - AvgInfl )/SQRT( VInPlan2 + ( VRotorX  - AvgInfl )**2 )
         SWconstO = SWconst
         SWconst  = ( 15*Pi/64 )*SQRT( ( 1.0 - SinISkew )/( 1.0 + SinISkew ) )

         IF ( ABS( SWconst - SWconstO ) > SWTol )  THEN
            SWconv = .FALSE.
         ELSE
            SWconv = .TRUE.
         ENDIF

      ENDIF

   ENDDO SkewedWakeLoop

   IF ( .NOT. FoundSol )  NmCaseFail = NmCaseFail + 1
   IF ( .NOT. FullConv )  NmCaseNC   = NmCaseNC   + 1


      ! Calculate rotor nondimensional data.

   TrqC = Torque*NB_QA*SwpRadIn
   PwrC = TrqC*TSR


      ! Calculate rotor dimensional data for all blades.

   Thrust = Thrust*NumBlade
   Torque = Torque*NumBlade
   Power  = Power *NumBlade



   RETURN
   END SUBROUTINE RotAnal ! ( )
!=======================================================================
   SUBROUTINE SetConv


      ! This routine sets up conversion factors.


   USE                             Parameters
   USE                             ProgGen
   USE                             WTP_Data

   IMPLICIT                        NONE


      ! Local decarations.
   CHARACTER(3)                 :: SpdUns                                       ! Temporary variable to hold the speed units in uppercase.


   IF ( InputTSR )  THEN

      ConvFact = 1.0

   ELSE
      ! SpdUns was getting truncated by the assignment: SpdUns = SpdUnits, not sure if this actually mattered, but the GNU compiler was complaining
      SpdUns = SpdUnits(1:3)
      CALL Conv2UC ( SpdUns )

      SELECT CASE ( SpdUns )

         CASE ( 'FPS' )            ! Using speed in ft/s.

            IF ( Metric )  THEN
               ConvFact    = 1.0/M2Ft
            ELSE
               ConvFact    = 1.0
            ENDIF

            UnitsStr(3) = 'fps'

         CASE ( 'MPS' )            ! Using speed in m/s.

            IF ( Metric )  THEN
               ConvFact    = 1.0
            ELSE
               ConvFact    = M2Ft
            ENDIF

            UnitsStr(3) = 'mps'

         CASE ( 'MPH' )            ! Using speed in mph.

            ConvFact    = 22.0/15.0
            IF ( Metric )  THEN
               ConvFact    = 22.0/( 15.0*M2Ft )
            ELSE
               ConvFact    = 22.0/15.0
            ENDIF

            UnitsStr(3) = 'mph'

         CASE DEFAULT

            CALL ProgAbort ( ' Your speed units must be either "mps", "fps", or "mph".' )

      END SELECT

   ENDIF

       ! convert gravitational acceleration if needed
   IF ( Metric ) THEN
      Gravity = 9.80665  !m/s^2
   ELSE
      Gravity = 32.17404 !ft/s^2
   ENDIF

      ! Set up conversion factors and SpdUnits strings.

   IF ( KFact )  THEN
      IF ( Metric )  THEN
         ConvFrc  = 0.001
         ConvPwr  = 0.001
         ConvTrq  = 0.001
         FrcUnits = '  kN'
         FpLUnits = ' N/m'
         LenUnits = 'm'
         MomUnits = '   kN-m'
         MpLUnits = 'N'
         PwrUnits = 'kW'
         SpdUnits = ' m/s'
      ELSE
         ConvFrc  = 0.001
         ConvPwr  = 0.001*FP2Nm
         ConvTrq  = 0.001
         FrcUnits = 'klbf'
         FpLUnits = 'lbf/ft'
         LenUnits = 'ft'
         MomUnits = 'kft-lbf'
         MpLUnits = 'lbf'
         PwrUnits = 'kW'
         SpdUnits = 'ft/s'
      ENDIF
   ELSE ! ( not KFact )
      IF ( Metric )  THEN
         ConvFrc  = 1.0
         ConvPwr  = 1.0
         ConvTrq  = 1.0
         FrcUnits = '   N'
         FpLUnits = ' N/m'
         LenUnits = 'm'
         MomUnits = '    N-m'
         MpLUnits = 'N'
         PwrUnits = ' W'
         SpdUnits = ' m/s'
      ELSE
         ConvFrc  = 1.0
         ConvPwr  = FP2Nm
         ConvTrq  = 1.0
         FrcUnits = ' lbf'
         FpLUnits = 'lbf/ft'
         LenUnits = 'ft'
         MomUnits = ' ft-lbf'
         MpLUnits = 'lbf'
         PwrUnits = ' W'
         SpdUnits = 'ft/s'
      ENDIF
   ENDIF


   RETURN
   END SUBROUTINE SetConv
!=======================================================================

END MODULE WTP_Subs
