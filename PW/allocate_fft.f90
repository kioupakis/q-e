!
! Copyright (C) 2001-2010 Quantum ESPRESSO group
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
!
!-----------------------------------------------------------------------
SUBROUTINE allocate_fft
  !-----------------------------------------------------------------------
  !     This routine computes the data structure associated to the FFT
  !     grid and allocate memory for all the arrays which depend upon
  !     these dimensions
  !
  USE io_global, ONLY : stdout
  USE gvect,     ONLY : ngm, g, gg, nl, nlm, mill, igtongl
  USE gvecs,   ONLY : ngms, nls, nlsm
  USE grid_dimensions,        ONLY : dense
  USE smooth_grid_dimensions, ONLY : smooth
! DCC
!  USE gcoarse,   ONLY : nr1c,nr2c,nr3c,nrxxc,ngmc, nlc, nlcm
!  USE ee_mod,    ONLY : do_coarse
  USE ions_base, ONLY : nat
  USE lsda_mod,  ONLY : nspin
  USE spin_orb,  ONLY : domag
  USE scf,       ONLY : rho, v, vnew, vltot, vrs, rho_core, rhog_core, &
                        kedtau, create_scf_type
  USE control_flags, ONLY : gamma_only
  USE noncollin_module, ONLY : pointlist, factlist, r_loc, &
      report, i_cons, noncolin, npol
  USE wavefunctions_module, ONLY : psic, psic_nc
  USE funct,     ONLY: dft_is_meta
  IMPLICIT NONE
  !
  !     determines the data structure for fft arrays
  !
  CALL data_structure( gamma_only )
  !
! DCC
!  IF( do_coarse ) CALL data_structure_coarse( gamma_only, nr1,nr2,nr3, ecutwfc )
  !

  IF (dense%nrxx.lt.ngm) THEN
     WRITE( stdout, '(/,4x," nr1=",i4," nr2= ", i4, " nr3=",i4, &
          &" nrxx = ",i8," ngm=",i8)') dense%nr1, dense%nr2, dense%nr3, dense%nrxx, ngm
     CALL errore ('allocate_fft', 'the nr"s are too small!', 1)

  ENDIF
  IF (smooth%nrxx.lt.ngms) THEN
     WRITE( stdout, '(/,4x," nr1s=",i4," nr2s= ", i4, " nr3s=",i4, &
          &" nrxxs = ",i8," ngms=",i8)') smooth%nr1, smooth%nr2, smooth%nr3, smooth%nrxx, ngms
     CALL errore ('allocate_fft', 'the nrs"s are too small!', 1)

  ENDIF
  IF (ngm  <= 0) CALL errore ('allocate_fft', 'wrong ngm', 1)
  IF (ngms <= 0) CALL errore ('allocate_fft', 'wrong ngms', 1)
  IF (dense%nrxx <= 0) CALL errore ('allocate_fft', 'wrong nrxx', 1)
  IF (smooth%nrxx<= 0) CALL errore ('allocate_fft', 'wrong nrxxs', 1)
  IF (nspin<= 0) CALL errore ('allocate_fft', 'wrong nspin', 1)
  !
  !     Allocate memory for all kind of stuff.
  !
  CALL create_scf_type(rho)
  CALL create_scf_type(v,    do_not_allocate_becsum = .true.)
  CALL create_scf_type(vnew, do_not_allocate_becsum = .true.)
  ALLOCATE (vltot( dense%nrxx))
  ALLOCATE (rho_core( dense%nrxx))
  IF (dft_is_meta() ) THEN
     ALLOCATE ( kedtau(smooth%nrxx,nspin) )
  ELSE
     ALLOCATE ( kedtau(1,nspin) )
  ENDIF
  ALLOCATE( rhog_core( ngm ) )
  ALLOCATE (psic( dense%nrxx))
  ALLOCATE (vrs( dense%nrxx, nspin))

! DCC
!  IF( do_coarse ) THEN
!     ALLOCATE (nlc( ngmc))
!     IF (gamma_only) ALLOCATE (nlcm(ngmc))
!  ENDIF

  IF (noncolin) ALLOCATE (psic_nc( dense%nrxx, npol))

  IF ( ((report.ne.0).or.(i_cons.ne.0)) .and. (noncolin.and.domag) .or. (i_cons.eq.1) ) THEN
!
! In order to print out local quantities, integrated around the atoms,
! we need the following variables
!
     ALLOCATE(pointlist(dense%nrxx))
     ALLOCATE(factlist(dense%nrxx))
     ALLOCATE(r_loc(nat))
     CALL make_pointlists
  ENDIF

  RETURN
END SUBROUTINE allocate_fft
