!=======================================================================
MODULE ProgGen


USE                             NWTC_Library

IMPLICIT                        NONE

REAL(ReKi)                   :: ATol                                            ! Error tolerance for induction iteration.
REAL(ReKi)                   :: ATol2                                           ! The squared error tolerance for induction iteration.
!! Moved from NWTC Library
REAL(ReKi)                   :: AirDens                                         ! The air density at hub height.
REAL(ReKi)                   :: KinVisc                                         ! The kinematic viscosity at hub height.
REAL(ReKi)                   :: SWTol                                           ! Error tolerance for skewed-wake iteration.

! -----  Cavitation Model  -------------------------------------------------------
REAL(ReKi)                   :: CavBeta                                         ! Beta term in diffuser augmentation correction.
REAL(ReKi)                   :: CavLambda                                       ! Lambda term in diffuser augmentation correction.
REAL(ReKi)                   :: PressAtm                                        ! Atmospheric Pressure, Pa units
REAL(ReKi)                   :: PressVapor                                      ! Vapor Pressure of Water
REAL(ReKi)                   :: PressVaporCavSF                                 ! Vapor Pressure of Water, multiplied by the cavitation safety factor
REAL(ReKi)                   :: CavSF                                           ! Cavitation Safety Factor
REAL(ReKi)                   :: WatDepth                                        ! Depth from water free surface to mudline (tower base)
REAL(ReKi)                   :: WatDepthND                                      ! Non-dimensional version of WatDepth.

INTEGER                      :: ConvFlag                                        ! For non-converging cases, 0 to output the result, 1 to output nines, 2 to output NaN.

LOGICAL                      :: AIDrag                                          ! Flag that tells if to inclde the drag term in the axial-induction calculation.
LOGICAL                      :: Cavitation                                      ! Run cavitation check? if cavitation, output sevens, check 12o'clock azimuth
LOGICAL                      :: Converge                                        ! Flag that says if we converged the induction loop enough to satisfy the convergence criterion.
LOGICAL                      :: DAWT                                            ! Run Diffuser Augmented Water Turbine Analysis? Marshall will hunt you down and kill you if use this for a wind turbine.
LOGICAL                      :: DimenInp                                        ! Flag that tells if input is dimensional or not.
LOGICAL                      :: DoSkew                                          ! Flag that says if we should calculate skewed-wake corrections for this case.
LOGICAL                      :: HubLoss                                         ! Flag that tells if to calculate the hub-loss correction factor.
LOGICAL                      :: IndType                                         ! Switch that tells which, if any, induction method is to be used.

LOGICAL                      :: InputTSR                                        ! Flag that tells if wind parameters are for TSR or wind speed.
LOGICAL                      :: KFact                                           ! Flag that tells if input is in K (e.g., kN instead of N).
LOGICAL                      :: Metric                                          ! Flag that tells if input is in metric units.
LOGICAL                      :: OutCp                                           ! Flag that tells if to output the Cp.
LOGICAL                      :: OutFlp                                          ! Flag that tells if to output the flap bending moment.
LOGICAL                      :: OutMaxCp                                        ! Flag that tells if to output the conditions leading to the maximum Cp.
LOGICAL                      :: OutPwr                                          ! Flag that tells if to output the power.
LOGICAL                      :: OutThr                                          ! Flag that tells if to output the thrust.
LOGICAL                      :: OutTrq                                          ! Flag that tells if to output the torque.
LOGICAL, ALLOCATABLE         :: PrntElem (:)                                    ! Array of flags to indicate which elements are to be printed to the blade-element file.
LOGICAL                      :: SkewWake                                        ! Flag that tells if to correct for skewed wakes.
LOGICAL                      :: Solution                                        ! Flag that says if we found a solution.
LOGICAL                      :: SWconv                                          ! Flag that says if we converged the skewed-wake loop.
LOGICAL                      :: Swirl                                           ! Flag that tells if to calculate the tangential induction factor.
LOGICAL                      :: TabDel                                          ! Flag that tells if to delimit data using tabs.
LOGICAL                      :: TIDrag                                          ! Flag that tells if to inclde the drag term in the tangential-induction calculation.
LOGICAL                      :: TipLoss                                         ! Flag that tells if to calculate the tip-loss correction factor.
LOGICAL                      :: TISingularity                                   ! Use the singularity avoidance method in the tangential-induction calculation?
LOGICAL                      :: UnfPower                                        ! Flag that says if we should output power to an unformatted file for use with HARP_Opt.
LOGICAL                      :: WriteBED                                        ! Flag that tells if to output blade-element data.

CHARACTER( 11)               :: DateNow                                         ! Date shortly after the start of execution.
CHARACTER(  6)               :: FpLUnits                                        ! The string containing the units of force per unit length.
CHARACTER(  4)               :: FrcUnits                                        ! The string containing the units of force.
CHARACTER(200)               :: InpFile
CHARACTER(  2)               :: LenUnits                                        ! The string containing the units of length.
CHARACTER(  7)               :: MomUnits                                        ! The string containing the units of moment.
CHARACTER(  3)               :: MpLUnits                                        ! The string containing the units of moment per unit length.
CHARACTER(  1)               :: NullChar = CHAR( 0 )
CHARACTER(  5)               :: ParamStr (3) = (/'Omega' ,'Pitch' ,'TSR  '/)    ! The strings for the variable-parameter names.
CHARACTER(  2)               :: PwrUnits                                        ! The string containing the units of power.
CHARACTER( 13)               :: RealFmt
CHARACTER(200)               :: RootName                                        ! Root name of the input file.
CHARACTER(200)               :: RunTitle                                        ! The title of the run from the input file.
CHARACTER(  4)               :: SpdUnits                                        ! The string containing the units of speed.
CHARACTER(  9)               :: TextFmt  = '(  X,A10)'
CHARACTER(  9)               :: TextFmtI = '(  X,A12)'
CHARACTER(  8)               :: TimeNow                                         ! Time of day shortly after the start of execution.
CHARACTER(3)                 :: UnitsStr  (3) = (/ 'rpm', 'deg', '   ' /)       ! The strings for the variable-parameter units.


END MODULE ProgGen
!=======================================================================
MODULE Parameters


   ! This module stores constants.

USE                                NWTC_Library

IMPLICIT                           NONE

REAL(ReKi), PARAMETER           :: BadCp        =   -9.999999                     ! Value to display for Cp when induction iteration fails.
REAL(ReKi), PARAMETER           :: BadPwr       = -999.999                      ! Value to display for power when induction iteration fails.
REAL(ReKi), PARAMETER           :: CavCp        =   -7.777777                     ! Value to display for Cp when Cavitation.
REAL(ReKi), PARAMETER           :: CavPwr       = -777.777                      ! Value to display for power when Cavitation.
REAL(ReKi), PARAMETER           :: FP2Nm        =    1.35582                    ! Convertion from foot-pounds to N-m.
REAL(ReKi), PARAMETER           :: M2Ft         =    3.280840                   ! Convertion from meters to feet.

INTEGER, PARAMETER              :: ParStLen (3) = (/ 5, 5, 3 /)                 ! Length of the strings containing the parameter names (ParamStr).
INTEGER, PARAMETER              :: UnAF         = 3                             ! Unit for airfoil-data input files.
INTEGER, PARAMETER              :: UnBE         = 4                             ! Unit for blade-element output file.
INTEGER, PARAMETER              :: UnDA         = 9                             ! Unit for diffuser augmented turbine analysis input p[arameters.
INTEGER, PARAMETER              :: UnDB         = 11                            ! Unit for Debug Output File
INTEGER, PARAMETER              :: UnIn         = 1                             ! Unit for input file.
INTEGER, PARAMETER              :: UnOu         = 2                             ! Unit for main output file.
INTEGER, PARAMETER              :: UnSc         = 6                             ! Unit for the screen.
INTEGER, PARAMETER              :: UnUn         = 8                             ! Unit for unformatted output file.

LOGICAL                         :: WriteDebug   = .FALSE.                       ! Logical for Debug Output File


END MODULE Parameters
!=======================================================================
MODULE WTP_Data


   ! This module stores constants to specify the KIND of variables.


USE                                NWTC_Library

IMPLICIT                           NONE

TYPE                            :: Case                                         ! Declare new type that is an allocatable table of combined cases.
   REAL(ReKi)                   :: Cp                                           ! The output power coefficient for a given case.
   REAL(ReKi)                   :: FlapMom                                      ! The output flap moment speed for a given case.
   REAL(ReKi)                   :: Pitch                                        ! The input pitch for a given case.
   REAL(ReKi)                   :: Power                                        ! The output power for a given case.
   REAL(ReKi)                   :: RotSpeed                                     ! The input rotor speed for a given case.
   REAL(ReKi)                   :: Thrust                                       ! The output thrust speed for a given case.
   REAL(ReKi)                   :: Torque                                       ! The output torque for a given case.
   REAL(ReKi)                   :: TSR                                          ! The input tip-speed ratio for a given case.
   REAL(ReKi)                   :: WndSpeed                                     ! The input wind speed for a given case.
ENDTYPE Case

TYPE(Case), ALLOCATABLE         :: Cases    (:)                                 ! The table of combined cases.

TYPE(ElmTable), ALLOCATABLE     :: AF_Table (:)                                 ! The super-supertable of element supertables of tables with airfoil data.

REAL(ReKi)                      :: AFangD                                       ! The angle between the wind vector and the cone of rotation in degrees.
REAL(ReKi)                      :: AIDragM                                      ! Multiplier for Drag term in AI calculation.
REAL(ReKi)                      :: AlfaD                                        ! The angle of attack in degrees.
REAL(ReKi), ALLOCATABLE         :: AlfaStal (:)                                 ! The array describing the stall angle of attack for each segment.
REAL(ReKi), ALLOCATABLE         :: AlfShift (:)                                 ! The angle we should shift the potential Cl curve to make it tangent to the input Cl curve.
REAL(ReKi)                      :: AxInd                                        ! The axial induction factor.
LOGICAL                         :: CavForAnyCase = .FALSE.                      ! Flag gets set to TRUE if Cavitation occurs during ANY case for Parametric analysis, and for the Combined Case analysis it is set to TRUE only for the cases which cavitate
REAL(ReKi)                      :: CdLoc                                        ! The coefficient of drag at the current analysis point.
REAL(ReKi), ALLOCATABLE         :: CdMin    (:)                                 ! The minimum Cd value in each Cd table.
REAL(ReKi), ALLOCATABLE         :: Chord    (:)                                 ! The array describing the chord distribution.
REAL(ReKi)                      :: ClLoc                                        ! The coefficient of lift at the current analysis point.
REAL(ReKi), POINTER             :: ColAry   (:)                                 ! The array holding all the column-parameter values.
REAL(ReKi)                      :: ConvFact                                     ! The wind-speed units conversion factor.
REAL(ReKi)                      :: ConvFrc                                      ! The conversion factor for force.
REAL(ReKi)                      :: ConvPwr                                      ! The conversion factor for power.
REAL(ReKi)                      :: ConvTrq                                      ! The conversion factor for torque.
REAL(ReKi)                      :: CosAF                                        ! The cosine of the airflow angle.
REAL(ReKi)                      :: CosAzim                                      ! The cosine of the current section.
REAL(ReKi)                      :: CosCone                                      ! The cosine of the precone angle.
REAL(ReKi)                      :: CosTilt                                      ! The cosine of the tilt angle.
REAL(ReKi)                      :: CosYaw                                       ! The cosine of the yaw error.
REAL(ReKi), ALLOCATABLE         :: CpAry    (:,:,:)                             ! The array to hold power coefficient for all parametric cases.
REAL(ReKi)                      :: CpminLoc                                     ! The coefficient of minimum pressure at the current analysis point.
REAL(ReKi)                      :: CmLoc                                        ! The coefficient of pitching moment at the current analysis point.
REAL(ReKi), ALLOCATABLE         :: DClShift (:)                                 ! The amount the Cl curve shifts upward when making it tangent to the input Cl curve.
REAL(ReKi), ALLOCATABLE         :: DelRLoc  (:)                                 ! The array of segment lengths.
REAL(ReKi)                      :: FlapMom                                      ! Flap bending moment.
REAL(ReKi), ALLOCATABLE         :: FlpAry   (:,:,:)                             ! The array to hold flap bending moment for all parametric cases.
REAL(ReKi)                      :: Gravity                                      ! Acceleration due to gravity
REAL(ReKi)                      :: HalfRho                                      ! Half of the air density.
REAL(ReKi)                      :: HubHt                                        ! The height of the hub above ground level.
REAL(ReKi)                      :: HubHtND                                      ! The non-dimensional height of the hub above ground level.
REAL(ReKi)                      :: HubRad                                       ! The hub radius.
REAL(ReKi)                      :: HubRadND                                     ! The non-dimensional hub radius.
REAL(ReKi)                      :: IncidAng                                     ! The incidence angle between the chord line and the cone of rotation
REAL(ReKi)                      :: Loss                                         ! The product of the tip- and hub-loss correction factor (total loss).
REAL(ReKi)                      :: Omega                                        ! Rotor speed in radians per second.
REAL(ReKi), ALLOCATABLE, TARGET :: OmgAry   (:)                                 ! The array of rotor-speed settings.
REAL(ReKi)                      :: OmgDel                                       ! The difference in rotor-speed settings.
REAL(ReKi)                      :: OmgEnd                                       ! The final rotor-speed setting.
REAL(ReKi)                      :: OmgRPM                                          ! Rotor speed in rpm.
REAL(ReKi)                      :: OmgSt                                        ! The initial rotor-speed setting.
REAL(ReKi), ALLOCATABLE, TARGET :: PitAry   (:)                                 ! The array of pitch settings.
REAL(ReKi)                      :: Pitch                                        ! The pitch angle in radians.
REAL(ReKi)                      :: PitDeg                                          ! The pitch angle in degrees.
REAL(ReKi)                      :: PitDel                                       ! The difference in pitch settings.
REAL(ReKi)                      :: PitEnd                                       ! The final pitch setting.
REAL(ReKi)                      :: PitSt                                        ! The initial pitch setting.
REAL(ReKi)                      :: Power                                        ! Rotor power.
REAL(ReKi)                      :: PreCone                                      ! The precone half angle.
REAL(ReKi), ALLOCATABLE         :: PwrAry   (:,:,:)                             ! The array to hold power for all parametric cases.
REAL(ReKi)                      :: PwrC                                         ! Power coefficient.
REAL(ReKi)                      :: PwrConv                                      ! The conversion factor for power.
REAL(ReKi), ALLOCATABLE         :: RLoc     (:)                                 ! The array of segment centers (distance from hub).
REAL(ReKi), ALLOCATABLE         :: RLocND   (:)                                 ! The non-dimensional array of segment centers.
REAL(ReKi)                      :: RotorRad                                     ! The rotor radius.
REAL(ReKi), POINTER             :: RowAry   (:)                                 ! The array holding all the row-parameter values.
REAL(ReKi)                      :: Segs                                         ! NumSeg converted to REAL.
REAL(ReKi)                      :: ShearExp                                     ! The exponent of the wind shear.
REAL(ReKi)                      :: SinAF                                        ! The sine of the airflow angle.
REAL(ReKi)                      :: SinAzim                                      ! The sine of the current section.
REAL(ReKi)                      :: SinCone                                      ! The sine of the precone angle.
REAL(ReKi)                      :: SinTilt                                      ! The sine of the tilt angle.
REAL(ReKi)                      :: SinYaw                                       ! The sine of the yaw error.
REAL(ReKi)                      :: Solidity                                     ! The solidity of the current segment.
REAL(ReKi)                      :: Spd                                          ! Current value of wind speed or TSR.
REAL(ReKi), ALLOCATABLE, TARGET :: SpdAry   (:)                                 ! The array of wind-speed/TSR settings.
REAL(ReKi)                      :: SpdDel                                       ! The difference in wind-speed/TSR settings.
REAL(ReKi)                      :: SpdEnd                                       ! The final wind-speed/TSR setting.
REAL(ReKi)                      :: SpdRatio                                     ! The local speed ratio (wind speed/rotational speed).
REAL(ReKi)                      :: SpdSt                                        ! The initial wind-speed/TSR setting.
REAL(ReKi)                      :: SWconst                                      ! A constant used in the skewed-wake correction.
REAL(ReKi)                      :: SWcorr                                       ! The correction to axial induction due to skewed wake.
REAL(ReKi)                      :: SweptRad                                     ! Swept radius.
REAL(ReKi)                      :: SwpRadIn                                     ! Inverse of the swept radius.
REAL(ReKi)                      :: SwptArea                                     ! Swept area
REAL(ReKi), POINTER             :: TabAry   (:)                                 ! The array holding all the table-parameter values.
REAL(ReKi)                      :: TanInd                                       ! The tangential induction factor (swirl).
REAL(ReKi), ALLOCATABLE         :: Thick    (:)                                 ! The array describing the thickness distribution.
REAL(ReKi), ALLOCATABLE         :: ThrAry   (:,:,:)                             ! The array to hold thrust for all parametric cases.
REAL(ReKi)                      :: Thrust                                       ! Rotor thrust.
REAL(ReKi)                      :: TIDragM                                      ! Multiplier for Drag term in TI calculation.
REAL(ReKi)                      :: TipSpeed                                     ! Tip speed: rotor speed times swept rotor radius.
REAL(ReKi)                      :: Tilt                                         ! The tilt of the shaft with respect to horizontal.
REAL(ReKi)                      :: Torque                                       ! Rotor torque
REAL(ReKi), ALLOCATABLE         :: TrqAry   (:,:,:)                             ! The array to hold torque for all parametric cases.
REAL(ReKi)                      :: TrqC                                         ! Torque coefficient.
REAL(ReKi)                      :: TSR                                          ! Tip-speed ratio
REAL(ReKi), ALLOCATABLE         :: Twist    (:)                                 ! The array describing the twist distribution.
REAL(ReKi)                      :: VBodTang                                     ! The local tangential velocity in the body frame.
REAL(ReKi)                      :: VelHH                                        ! Hub-height wind speed.
REAL(ReKi)                      :: VInd2                                        ! The square of the total relative, induced (local) velocity.
REAL(ReKi)                      :: VIndNorm                                     ! Induced normal wind speed.
REAL(ReKi)                      :: VIndNrm2                                     ! Induced normal wind speed squared.
REAL(ReKi)                      :: VIndTang                                     ! Induced tangential wind speed.
REAL(ReKi)                      :: VTotNorm                                     ! The total relative wind speed normal the the chordline.
REAL(ReKi)                      :: VTotTang                                     ! The total relative wind speed parallel the the chordline.
REAL(ReKi)                      :: VWndGnd                                      ! The local wind speed in the ground reference system.
REAL(ReKi)                      :: Yaw                                          ! The rotor yaw error.

INTEGER, ALLOCATABLE            :: AFfile    (:)                                ! List of unique airfoil files.
INTEGER, SAVE                   :: NCases     = 0                               ! Number of cases analyzed.
INTEGER                         :: DataSize (3)                                 ! Number of rows, columns, and grids of standard data output.
INTEGER, ALLOCATABLE            :: IndClBrk (:)                                 ! The index pointing to the break in the Cl curve for each aerodynamic table.
INTEGER                         :: MaxCol                                       ! Maximum number of columns in the output matrix.
INTEGER                         :: MaxIter                                      ! Maximum number of iterations for Newt Raphson induction factor.
INTEGER                         :: NSplit                                       ! Maximum number of iterations for the binary search method algorithm to converge on the induction factor.
INTEGER                         :: MaxRow                                       ! Maximum number of rows in the output matrix.
INTEGER                         :: MaxTab                                       ! Maximum number of tables in the output matrix.
INTEGER                         :: NumBlade                                     ! Number of blades.
INTEGER                         :: NumCases                                     ! Number of combined-analysis cases.
INTEGER, ALLOCATABLE            :: NumCd    (:)                                 ! Number of points in each Cd table.
INTEGER, ALLOCATABLE            :: NumCl    (:)                                 ! Number of points in each Cl table.
INTEGER                         :: NumElmPr                                     ! Number of elements that will be printed to the blade-element file.
INTEGER                         :: NmCaseFail = 0                               ! The number of cases in which no solution was found.
INTEGER                         :: NmCaseNC   = 0                               ! The number of cases in which the iteration did not fully converge on the exact solution.
INTEGER                         :: NumOmg                                       ! Number of rotor speeds.
INTEGER                         :: NumPit                                       ! Number of Pitch settings.
INTEGER                         :: NumSect                                      ! Number of swept-area sectors.
INTEGER                         :: NumSeg                                       ! Number of blade segments.
INTEGER                         :: NumSpd                                       ! Number of wind speeds or TSRs.
INTEGER                         :: ParCol                                       ! The parameter to vary by columns.
INTEGER                         :: ParRow                                       ! The parameter to vary by rows.
INTEGER                         :: ParTab                                       ! The parameter to vary by tables.


END MODULE WTP_Data
!=======================================================================
