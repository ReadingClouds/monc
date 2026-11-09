!> Single and double Gaussian cloud scheme
module gaussiancloud_mod
  use datadefn_mod, only : DEFAULT_PRECISION, STRING_LENGTH
  use monc_component_mod, only : COMPONENT_ARRAY_FIELD_TYPE, &
      COMPONENT_DOUBLE_DATA_TYPE, component_descriptor_type, &
      component_field_value_type, component_field_information_type
  use optionsdatabase_mod, only : options_get_real,options_get_integer,options_get_string
  use state_mod, only : FORWARD_STEPPING, model_state_type
  use grids_mod, only : Z_INDEX, X_INDEX, Y_INDEX
  use science_constants_mod, only : r_over_cp, rlvap_over_cp, pi, r, rlvap, ratio_mol_wts
  use saturation_mod, only: qsaturation, dqwsatdt
  use q_indices_mod, only: get_q_index, standard_q_names
  use registry_mod, only : is_component_enabled
  use logging_mod, only : LOG_ERROR, log_master_log, LOG_INFO
  use circle_a_mod, only: circle_a_enabled

implicit none

#ifndef TEST_MODE
  private
#endif
    
  ! Indices for vapour and cloud
  integer :: iqv, iql

  !Indices for variances and covariance
  integer :: i_thl_thl, i_qt_qt, i_thl_qt

  integer :: k_cloudmax ! max k index for height
  real(kind=DEFAULT_PRECISION) :: max_height_cloud

  ! Local tendency diagnostic variables for this component
  ! 3D tendency fields and logicals for their use
  real(kind=DEFAULT_PRECISION), dimension(:,:,:), allocatable ::                    &
                   tend_3d_th,      tend_3d_qv,      tend_3d_ql,      tend_3d_tabs
  logical ::     l_tend_3d_th,    l_tend_3d_qv,    l_tend_3d_ql,    l_tend_3d_tabs
  ! Local mean tendency profile fields and logicals for their use
  real(kind=DEFAULT_PRECISION), dimension(:), allocatable ::                        &
               tend_pr_tot_th,  tend_pr_tot_qv,  tend_pr_tot_ql,  tend_pr_tot_tabs
  logical :: l_tend_pr_tot_th,l_tend_pr_tot_qv,l_tend_pr_tot_ql,l_tend_pr_tot_tabs

  real(kind=DEFAULT_PRECISION), dimension(:,:,:), allocatable ::                    &
      delta_q_diag, sigma_s_diag, delta_qcl_diag, qcl_diag, cf_diag
  
  !config option
  character(len=STRING_LENGTH) :: gtype 

  public gaussiancloud_get_descriptor

contains

  !> Provides the descriptor back to the caller and is used in component registration
  !! @returns The termination check component descriptor
  type(component_descriptor_type) function gaussiancloud_get_descriptor()
    gaussiancloud_get_descriptor%name="gaussiancloud"
    gaussiancloud_get_descriptor%version=0.1
    gaussiancloud_get_descriptor%initialisation=>initialisation_callback
    gaussiancloud_get_descriptor%timestep=>timestep_callback
    gaussiancloud_get_descriptor%finalisation=>finalisation_callback

    gaussiancloud_get_descriptor%field_value_retrieval=>field_value_retrieval_callback
    gaussiancloud_get_descriptor%field_information_retrieval=>field_information_retrieval_callback
    allocate(gaussiancloud_get_descriptor%published_fields(4+4+5))

    gaussiancloud_get_descriptor%published_fields(1)="tend_th_gaussiancloud_3d_local"
    gaussiancloud_get_descriptor%published_fields(2)="tend_qv_gaussiancloud_3d_local"
    gaussiancloud_get_descriptor%published_fields(3)="tend_ql_gaussiancloud_3d_local"
    gaussiancloud_get_descriptor%published_fields(4)="tend_tabs_gaussiancloud_3d_local"

    gaussiancloud_get_descriptor%published_fields(4+1)="tend_th_gaussiancloud_profile_total_local"
    gaussiancloud_get_descriptor%published_fields(4+2)="tend_qv_gaussiancloud_profile_total_local"
    gaussiancloud_get_descriptor%published_fields(4+3)="tend_ql_gaussiancloud_profile_total_local"
    gaussiancloud_get_descriptor%published_fields(4+4)="tend_tabs_gaussiancloud_profile_total_local"

    gaussiancloud_get_descriptor%published_fields(8+1)="delta_q"
    gaussiancloud_get_descriptor%published_fields(8+2)="sigma_s"
    gaussiancloud_get_descriptor%published_fields(8+3)="delta_qcl"
    gaussiancloud_get_descriptor%published_fields(8+4)="qcl"
    gaussiancloud_get_descriptor%published_fields(8+5)="cloud_fraction"
  end function gaussiancloud_get_descriptor


 !> Field information retrieval callback, this returns information for a specific components published field
  !! @param current_state Current model state
  !! @param name The name of the field to retrieve information for
  !! @param field_information Populated with information about the field
  subroutine field_information_retrieval_callback(current_state, name, field_information)
    type(model_state_type), target, intent(inout) :: current_state
    character(len=*), intent(in) :: name
    type(component_field_information_type), intent(out) :: field_information
    integer :: strcomp
    
    logical :: available

    ! Field information for 3d
    strcomp=INDEX(name, "gaussiancloud_3d_local")
    if (strcomp .ne. 0) then
      field_information%field_type=COMPONENT_ARRAY_FIELD_TYPE
      field_information%number_dimensions=3
      field_information%dimension_sizes(1)=current_state%local_grid%size(Z_INDEX)
      field_information%dimension_sizes(2)=current_state%local_grid%size(Y_INDEX)
      field_information%dimension_sizes(3)=current_state%local_grid%size(X_INDEX)
      field_information%data_type=COMPONENT_DOUBLE_DATA_TYPE

      if      (name .eq. "tend_th_gaussiancloud_3d_local") then
        field_information%enabled=l_tend_3d_th
      else if (name .eq. "tend_qv_gaussiancloud_3d_local") then
        field_information%enabled=l_tend_3d_qv
      else if (name .eq. "tend_ql_gaussiancloud_3d_local") then
        field_information%enabled=l_tend_3d_ql
      else if (name .eq. "tend_tabs_gaussiancloud_3d_local") then
        field_information%enabled=l_tend_3d_tabs
      else
        field_information%enabled=.true.
      end if

    end if !end 3d check

    ! Field information for profiles
    strcomp=INDEX(name, "gaussiancloud_profile_total_local")
    if (strcomp .ne. 0) then
      field_information%field_type=COMPONENT_ARRAY_FIELD_TYPE
      field_information%number_dimensions=1
      field_information%dimension_sizes(1)=current_state%local_grid%size(Z_INDEX)
      field_information%data_type=COMPONENT_DOUBLE_DATA_TYPE

      if      (name .eq. "tend_th_gaussiancloud_profile_total_local") then
        field_information%enabled=l_tend_pr_tot_th
      else if (name .eq. "tend_qv_gaussiancloud_profile_total_local") then
        field_information%enabled=l_tend_pr_tot_qv
      else if (name .eq. "tend_ql_gaussiancloud_profile_total_local") then
        field_information%enabled=l_tend_pr_tot_ql
      else if (name .eq. "tend_tabs_gaussiancloud_profile_total_local") then
        field_information%enabled=l_tend_pr_tot_tabs
      else
        field_information%enabled=.true.
      end if

    end if !end profile check
    
    available = is_component_enabled(current_state%options_database, "gaussiancloud") &
                .and. current_state%th%active                                         &
                .and. .not. current_state%passive_q                                   &
                .and. current_state%number_q_fields .gt. 0
                    
    if (name .eq. "delta_q" .or. name .eq. "sigma_s"                      &
        .or. name .eq. "delta_qcl" .or. name .eq. "qcl"       &
        .or. name .eq. "cloud_fraction") then    
      field_information%field_type=COMPONENT_ARRAY_FIELD_TYPE
      field_information%number_dimensions=3
      field_information%dimension_sizes(1)=current_state%local_grid%size(Z_INDEX)
      field_information%dimension_sizes(2)=current_state%local_grid%size(Y_INDEX)
      field_information%dimension_sizes(3)=current_state%local_grid%size(X_INDEX)
      field_information%data_type=COMPONENT_DOUBLE_DATA_TYPE
      field_information%enabled = available
    end if

  end subroutine field_information_retrieval_callback


  !> Field value retrieval callback, this returns the value of a specific published field
  !! @param current_state Current model state
  !! @param name The name of the field to retrieve the value for
  !! @param field_value Populated with the value of the field
  subroutine field_value_retrieval_callback(current_state, name, field_value)
    type(model_state_type), target, intent(inout) :: current_state
    character(len=*), intent(in) :: name
    type(component_field_value_type), intent(out) :: field_value

    ! 3d Tendency Fields
    if      (name .eq. "tend_th_gaussiancloud_3d_local" .and. allocated(tend_3d_th)) then
      call set_published_field_value(field_value, real_3d_field=tend_3d_th)
    else if (name .eq. "tend_qv_gaussiancloud_3d_local" .and. allocated(tend_3d_qv)) then
      call set_published_field_value(field_value, real_3d_field=tend_3d_qv)
    else if (name .eq. "tend_ql_gaussiancloud_3d_local" .and. allocated(tend_3d_ql)) then
      call set_published_field_value(field_value, real_3d_field=tend_3d_ql)
    else if (name .eq. "tend_tabs_gaussiancloud_3d_local" .and. allocated(tend_3d_tabs)) then
      call set_published_field_value(field_value, real_3d_field=tend_3d_tabs)

    ! Profile Tendency Fields
    else if (name .eq. "tend_th_gaussiancloud_profile_total_local" .and. allocated(tend_pr_tot_th)) then
      call set_published_field_value(field_value, real_1d_field=tend_pr_tot_th)
    else if (name .eq. "tend_qv_gaussiancloud_profile_total_local" .and. allocated(tend_pr_tot_qv)) then
      call set_published_field_value(field_value, real_1d_field=tend_pr_tot_qv)
    else if (name .eq. "tend_ql_gaussiancloud_profile_total_local" .and. allocated(tend_pr_tot_ql)) then
      call set_published_field_value(field_value, real_1d_field=tend_pr_tot_ql)
    else if (name .eq. "tend_tabs_gaussiancloud_profile_total_local" .and. allocated(tend_pr_tot_tabs)) then
      call set_published_field_value(field_value, real_1d_field=tend_pr_tot_tabs)
    
    ! Other diags
    else if (name .eq. "delta_q" .and. allocated(delta_q_diag)) then
      call set_published_field_value(field_value, real_3d_field=delta_q_diag)
    else if (name .eq. "sigma_s" .and. allocated(sigma_s_diag)) then 
      call set_published_field_value(field_value, real_3d_field=sigma_s_diag)
    else if (name .eq. "delta_qcl" .and. allocated(delta_qcl_diag)) then 
      call set_published_field_value(field_value, real_3d_field=delta_qcl_diag)
    else if (name .eq. "qcl" .and. allocated(qcl_diag)) then 
      call set_published_field_value(field_value, real_3d_field=qcl_diag)
    else if (name .eq. "cloud_fraction" .and. allocated(cf_diag)) then    
      call set_published_field_value(field_value, real_3d_field=cf_diag)

    end if

  end subroutine field_value_retrieval_callback


  !> The initialisation callback sets up the moisture fields
  !! @param current_state The current model state
  subroutine initialisation_callback(current_state)
    type(model_state_type), target, intent(inout) :: current_state

    integer :: k ! look counter
    logical :: l_qdiag
    
    logical :: available
    
    
    if (is_component_enabled(current_state%options_database, "simplecloud")) then
      call log_master_log(LOG_ERROR, "Gaussiancloud and Simplecloud are enabled, this does not work yet. Please disable one")
    end if 
    !get config option, single gaussian or double gaussian
    
    gtype = options_get_string(current_state%options_database, "gaussian")
    if (gtype .ne. "simple" .and. gtype .ne. "single" .and. gtype .ne. "double") then    
      call log_master_log(LOG_ERROR, "Config option not available: "//gtype)
    endif

    if (is_component_enabled(current_state%options_database, "casim")) then
      call log_master_log(LOG_ERROR, "Casim and Gaussiancloud are enabled, this does not work yet. Please disable one")
    end if 

    if (.not.(circle_a_enabled)) then
      call log_master_log(LOG_ERROR, "Circle_a needs to be enabled for gaussiancloud to work.")
    end if 

    call log_master_log(LOG_INFO, "Gaussian cloud scheme enabled: "//gtype)

    iqv=get_q_index(standard_q_names%VAPOUR, 'gaussiancloud')
    iql=get_q_index(standard_q_names%CLOUD_LIQUID_MASS, 'gaussiancloud')

    i_thl_thl=current_state%thl_thl_index
    i_qt_qt  =current_state%qt_qt_index
    i_thl_qt =current_state%thl_qt_index

    !! set buoyancy coefficient (value for vapour should be set
    !! elsewhere for a moist model
    !if (.not. allocated(current_state%cq))then
    !  allocate(current_state%cq(current_state%number_q_fields))
    !  current_state%cq=0.0_DEFAULT_PRECISION
    !end if
    !current_state%cq(iql) = -1.0 

    max_height_cloud=options_get_real(current_state%options_database, "max_height_cloud")
    do k=2, current_state%local_grid%size(Z_INDEX)-1 ! PAC Revisit. Should this be without -1?
      if (current_state%global_grid%configuration%vertical%zn(k) > max_height_cloud) exit
    end do
    k_cloudmax=k-1

    ! Set tendency diagnostic logicals based on availability
    ! Need to use 3d tendencies to compute the profiles, so they will be allocated
    !      in the case where profiles are available
    l_qdiag =  (.not. current_state%passive_q .and. current_state%number_q_fields .gt. 0)

    l_tend_pr_tot_th  = current_state%th%active
    l_tend_pr_tot_qv  = l_qdiag .and. current_state%water_vapour_mixing_ratio_index > 0
    l_tend_pr_tot_ql  = l_qdiag .and. current_state%liquid_water_mixing_ratio_index > 0
    l_tend_pr_tot_tabs  = l_tend_pr_tot_th

    l_tend_3d_th  = current_state%th%active .or. l_tend_pr_tot_th
    l_tend_3d_qv  = (l_qdiag .and. current_state%water_vapour_mixing_ratio_index > 0) .or. l_tend_pr_tot_qv
    l_tend_3d_ql  = (l_qdiag .and. current_state%liquid_water_mixing_ratio_index > 0) .or. l_tend_pr_tot_ql
    l_tend_3d_tabs = l_tend_3d_th

    ! Allocate 3d tendency fields upon availability
    if (l_tend_3d_th) then
      allocate( tend_3d_th(current_state%local_grid%size(Z_INDEX),  &
                           current_state%local_grid%size(Y_INDEX),  &
                           current_state%local_grid%size(X_INDEX)   )    )
    endif
    if (l_tend_3d_qv) then
      allocate( tend_3d_qv(current_state%local_grid%size(Z_INDEX),  &
                           current_state%local_grid%size(Y_INDEX),  &
                           current_state%local_grid%size(X_INDEX)   )    )
    endif
    if (l_tend_3d_ql) then
      allocate( tend_3d_ql(current_state%local_grid%size(Z_INDEX),  &
                           current_state%local_grid%size(Y_INDEX),  &
                           current_state%local_grid%size(X_INDEX)   )    )
    endif
    if (l_tend_3d_tabs) then
      allocate( tend_3d_tabs(current_state%local_grid%size(Z_INDEX),  &
                             current_state%local_grid%size(Y_INDEX),  &
                             current_state%local_grid%size(X_INDEX)   )    )
    endif

    ! Allocate profile tendency fields upon availability
    if (l_tend_pr_tot_th) then
      allocate( tend_pr_tot_th(current_state%local_grid%size(Z_INDEX)) )
    endif
    if (l_tend_pr_tot_qv) then
      allocate( tend_pr_tot_qv(current_state%local_grid%size(Z_INDEX)) )
    endif
    if (l_tend_pr_tot_ql) then
      allocate( tend_pr_tot_ql(current_state%local_grid%size(Z_INDEX)) )
    endif
    if (l_tend_pr_tot_tabs) then
      allocate( tend_pr_tot_tabs(current_state%local_grid%size(Z_INDEX)) )
    endif
    
    available = is_component_enabled(current_state%options_database, "gaussiancloud") &
                .and. current_state%th%active                                         &
                .and. .not. current_state%passive_q                                   &
                .and. current_state%number_q_fields .gt. 0
                    
    if (available) then  
      allocate( delta_q_diag(current_state%local_grid%size(Z_INDEX),  &
                             current_state%local_grid%size(Y_INDEX),  &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( sigma_s_diag(current_state%local_grid%size(Z_INDEX),  &
                             current_state%local_grid%size(Y_INDEX),  &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( delta_qcl_diag(current_state%local_grid%size(Z_INDEX),  &
                             current_state%local_grid%size(Y_INDEX),  &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( qcl_diag(current_state%local_grid%size(Z_INDEX),      &
                             current_state%local_grid%size(Y_INDEX),  &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( cf_diag(current_state%local_grid%size(Z_INDEX),       &
                             current_state%local_grid%size(Y_INDEX),  &
                             current_state%local_grid%size(X_INDEX)   )    )
    end if

  end subroutine initialisation_callback  


  subroutine finalisation_callback(current_state)
    type(model_state_type), target, intent(inout) :: current_state

    if (allocated(tend_3d_th)) deallocate(tend_3d_th)
    if (allocated(tend_3d_qv)) deallocate(tend_3d_qv)
    if (allocated(tend_3d_ql)) deallocate(tend_3d_ql)
    if (allocated(tend_3d_tabs)) deallocate(tend_3d_tabs)

    if (allocated(tend_pr_tot_th)) deallocate(tend_pr_tot_th)
    if (allocated(tend_pr_tot_qv)) deallocate(tend_pr_tot_qv)
    if (allocated(tend_pr_tot_ql)) deallocate(tend_pr_tot_ql)
    if (allocated(tend_pr_tot_tabs)) deallocate(tend_pr_tot_tabs)

    if (allocated(delta_q_diag)) deallocate(delta_q_diag)
    if (allocated(sigma_s_diag)) deallocate(sigma_s_diag)
    if (allocated(delta_qcl_diag)) deallocate(delta_qcl_diag)
    if (allocated(qcl_diag)) deallocate(qcl_diag)
    if (allocated(cf_diag)) deallocate(cf_diag)

  end subroutine finalisation_callback


  !> Called for each column per timestep  
  ! This will modify the liquid water content based on a Gaussian model for the
  ! subgrid liquid water content
  !! @param current_state The current model state
  subroutine timestep_callback(current_state)
    type(model_state_type), target, intent(inout) :: current_state
    
    real(DEFAULT_PRECISION), parameter :: min_sigma_s=1e-7

    real(DEFAULT_PRECISION) :: TdegK   ! Temperature in Kelvin
    real(DEFAULT_PRECISION) :: Pmb     ! Pressure in mb
    real(DEFAULT_PRECISION) :: exner   ! Exner pressure
    real(DEFAULT_PRECISION) :: one_over_exner ! Reciprocal of Exner pressure
    real(DEFAULT_PRECISION) :: qv,qc   ! Shorthand for vapour and cloud mass mixing ratio
    real(DEFAULT_PRECISION) :: qt      ! qv+qc
    real(DEFAULT_PRECISION) :: sh_qv,sh_qc
    real(DEFAULT_PRECISION) :: sh_qt,sh_qs 
    real(DEFAULT_PRECISION) :: Qcr ! resolved cloud mass mixing ratio based on super saturation
    real(DEFAULT_PRECISION) :: qs      ! Saturation mixing ratio
    real(DEFAULT_PRECISION) :: dqsdT   ! Rate of change of qs with temperature
    real(DEFAULT_PRECISION) :: dmass   ! Mass transfer mixing ratio
    real(DEFAULT_PRECISION) :: pref
    real(DEFAULT_PRECISION) :: Thref
    real(DEFAULT_PRECISION) :: Tref
    real(DEFAULT_PRECISION) :: Thlpr_k
    real(DEFAULT_PRECISION) :: sqt_qt,sThl_qt,sThl_Thl !Variances and Covariances of qt and Thl
    real(DEFAULT_PRECISION) :: Sks, Skw !Skewness of s and w
    real(DEFAULT_PRECISION) :: rsw      !correlation of s and w
    real(DEFAULT_PRECISION) :: sigma_s !Standard deviation of s (subgrid liquid water content)
    real(DEFAULT_PRECISION) :: x,xabs,p,t,a1,a2,a3,a4,a5,erf !Variables and parameters for calculation of error function erf
    real(DEFAULT_PRECISION) :: clfr    !Cloud fraction
    real(DEFAULT_PRECISION) :: qcl     !Cloud liquid water based on Gaussian scheme 
!    real(DEFAULT_PRECISION) :: qcl_gauss, qcl_simple
    real(DEFAULT_PRECISION) :: alpha_L,a_L,delta_q,ap,sigma_sq,qn,qsatfac,delta_q_p
    real(DEFAULT_PRECISION) :: eps
    
    integer :: k          ! Loop counter
    integer :: icol, jcol ! Shorthand column indices

    real(DEFAULT_PRECISION) :: dtm  ! Local timestep variable
    integer :: target_x_index, target_y_index
    logical :: calculate_diagnostics

    calculate_diagnostics = current_state%diagnostic_sample_timestep

    ! Zero profile tendency totals on first instance in the sum
    if (current_state%first_timestep_column) then
      if (l_tend_pr_tot_th) then
        tend_pr_tot_th(:)=0.0_DEFAULT_PRECISION
      endif
      if (l_tend_pr_tot_qv) then
        tend_pr_tot_qv(:)=0.0_DEFAULT_PRECISION
      endif
      if (l_tend_pr_tot_ql) then
        tend_pr_tot_ql(:)=0.0_DEFAULT_PRECISION
      endif
      if (l_tend_pr_tot_tabs) then
        tend_pr_tot_tabs(:)=0.0_DEFAULT_PRECISION
      endif
    endif  ! zero totals

    if (current_state%halo_column) return

    if (current_state%field_stepping == FORWARD_STEPPING) then 
      dtm = current_state%dtm
    else
      dtm = current_state%dtm*2.0
    endif

    icol=current_state%column_local_x
    jcol=current_state%column_local_y

    target_y_index=jcol-current_state%local_grid%halo_size(Y_INDEX)
    target_x_index=icol-current_state%local_grid%halo_size(X_INDEX)

    if (calculate_diagnostics) call save_precomponent_tendencies( &
            current_state, icol, jcol, target_x_index, target_y_index)

    eps = 1.0/ratio_mol_wts

    do k=2,k_cloudmax


      sThl_Thl = current_state%ca(i_thl_thl)%data(k, jcol, icol)
      sqt_qt = current_state%ca(i_qt_qt)%data(k, jcol, icol)
      sThl_qt = current_state%ca(i_thl_qt)%data(k, jcol, icol)

      pref = current_state%global_grid%configuration%vertical%prefn(k)
      Thref = current_state%global_grid%configuration%vertical%thref(k)
      Tref = current_state%global_grid%configuration%vertical%tref(k)

      exner = current_state%global_grid%configuration%vertical%rprefrcp(k)
      one_over_exner = current_state%global_grid%configuration%vertical%prefrcp(k)
      Pmb   = pref/100. 

      if (current_state%field_stepping == FORWARD_STEPPING) then
        qv    = current_state%q(iqv)%data(k, jcol, icol) + current_state%sq(iqv)%data(k, jcol, icol)*dtm
        qc    = current_state%q(iql)%data(k, jcol, icol) + current_state%sq(iql)%data(k, jcol, icol)*dtm
        TdegK = (current_state%th%data(k, jcol, icol) + current_state%sth%data(k, jcol, icol)*dtm &
           + current_state%global_grid%configuration%vertical%thref(k))*exner
      else
        qv    = current_state%zq(iqv)%data(k, jcol, icol) + current_state%sq(iqv)%data(k, jcol, icol)*dtm
        qc    = current_state%zq(iql)%data(k, jcol, icol) + current_state%sq(iql)%data(k, jcol, icol)*dtm
        TdegK = (current_state%zth%data(k, jcol, icol) + current_state%sth%data(k, jcol, icol)*dtm &
           + current_state%global_grid%configuration%vertical%thref(k))*exner
      end if
      ! Calculate the cloud/vapour increments

      qt = qv + qc
      qs = qsaturation(TdegK, Pmb)

      alpha_L = dqwsatdt(qs, Tref) 

      a_L = 1.0/(1.0 + rlvap_over_cp * alpha_L)

      !Calculation of liquid water temperature, taken from smagorinsky.F90
      Thlpr_k = current_state%th%data(k, jcol, icol)+Thref - rlvap_over_cp * qc * one_over_exner

      !delta_q_p = qt-qs-alpha_L*exner*(Thlpr_k-Thref)
      delta_q = qt - qs

!      dqsdT = dqwsatdt(qs, TdegK) equiv alpha_L
!      qsatfac = 1.0/(1.0 + rlvap_over_cp*dqsdT) equiv a_L

      delta_q_diag(k, target_y_index, target_x_index)=delta_q 

      Qcr = delta_q * a_L

      ap = alpha_L * exner
      sigma_sq = sqt_qt-2.0*sThl_qt*ap+sThl_Thl*ap*ap
      sigma_s = sqrt(sigma_sq) * a_L

      sigma_s_diag(k, target_y_index, target_x_index) = sigma_s 

      !ts=current_state%timestep
      !if(icol==10 .and. jcol==10) then
      !  print *, ts,k,"  Qcr: ", Qcr, "  qv:", qv,"  qs:",qs, "  qsatfac:",qsatfac, "  a_L: ",a_L, "  alpha_L: ",alpha_L, "  delta_q: ",delta_q
      !  print *, ts,k,"  delta_q_p: ",delta_q_p, "  qt: ",qt, "  qs: ", qs, "  Thlpr_k: ",Thlpr_k,"  Thref: ", Thref
      !endif

      clfr=0
      if (gtype .eq. "simple" .or. sigma_s .lt. min_sigma_s) then
        !if sigma_s is too small use simplecloud all or nothing scheme      
        !simplecloud
        if (qv > qs .or. qc >0.0)then      
          dmass = MAX (-qc,(qv-qs) * a_L) 
          if (dmass > -qc) clfr = 1.0
          dmass = dmass / dtm 
        else
          dmass=0
        endif

        qcl = qc + dmass*dtm
      
      else

        qn = Qcr/sigma_s

        if (gtype .eq. "single") then
        
          call single_gaussian(qn, sigma_s, Qcr, qcl, clfr)

        else 
        
          Sks=0
          Skw=0
          rsw=0
          call double_gaussian(qcl,Qcr,sigma_s,Sks,Skw,rsw)
          
        endif

        dmass = (qcl-qc)/dtm  
      
      endif

      delta_qcl_diag(k, target_y_index, target_x_index) = dmass * dtm
      qcl_diag(k, target_y_index, target_x_index) = qcl
      cf_diag(k, target_y_index, target_x_index)=clfr
      
      current_state%sq(iqv)%data(k, jcol, icol) = current_state%sq(iqv)%data(k, jcol, icol) - dmass
      current_state%sq(iql)%data(k, jcol, icol) = current_state%sq(iql)%data(k, jcol, icol) + dmass

      current_state%sth%data(k, jcol, icol) = current_state%sth%data(k, jcol, icol) &
         + rlvap_over_cp*dmass*one_over_exner

    end do

    ! If there's any cloud above then evaporate it
    do k=k_cloudmax+1, current_state%local_grid%size(Z_INDEX)
    
      if (current_state%scalar_stepping == FORWARD_STEPPING) then
        qv    = current_state%q(iqv)%data(k, jcol, icol) + current_state%sq(iqv)%data(k, jcol, icol)*dtm
        qc    = current_state%q(iql)%data(k, jcol, icol) + current_state%sq(iql)%data(k, jcol, icol)*dtm
        TdegK = (current_state%th%data(k, jcol, icol) + current_state%sth%data(k, jcol, icol)*dtm &
           + current_state%global_grid%configuration%vertical%thref(k))*exner
      else
        qv    = current_state%zq(iqv)%data(k, jcol, icol) + current_state%sq(iqv)%data(k, jcol, icol)*dtm
        qc    = current_state%zq(iql)%data(k, jcol, icol) + current_state%sq(iql)%data(k, jcol, icol)*dtm
        TdegK = (current_state%zth%data(k, jcol, icol) + current_state%sth%data(k, jcol, icol)*dtm &
           + current_state%global_grid%configuration%vertical%thref(k))*exner
      end if
      
      if (qc >0.0)then
        dmass = -qc/dtm
      
        current_state%sq(iqv)%data(k, jcol, icol) = current_state%sq(iqv)%data(k, jcol, icol) - dmass
        current_state%sq(iql)%data(k, jcol, icol) = current_state%sq(iql)%data(k, jcol, icol) + dmass

        current_state%sth%data(k, jcol, icol) = current_state%sth%data(k, jcol, icol) &
           + rlvap_over_cp*dmass*one_over_exner

      end if
      
    end do

    if (calculate_diagnostics) call compute_component_tendencies(current_state, icol, jcol, target_x_index, target_y_index)

  end subroutine timestep_callback

  !> Calculate liquid cloud water content using single Gaussian scheme (Mellor-Yamada).
  !! @param qcl - liquid water content
  !! @param qn - Qcr/sigma_s
  !! @param sigma_s - standard deviation of s
  subroutine single_gaussian(qn, sigma_s, Qcr, qcl, clfr)
    real(DEFAULT_PRECISION), intent(in) :: qn, sigma_s, Qcr
    real(DEFAULT_PRECISION), intent(out) :: qcl, clfr
    !real(DEFAULT_PRECISION) :: erf

    !erf=error_fct(-qn/sqrt(2.0)) !Cray compiler on Monsoon supports Fortran function 'erf'

    !clfr = 0.5*(1.0-erf)
    clfr = MAX (0., 0.5*(1.0-erf(-qn/sqrt(2.0))) )

    qcl = MAX (0., sigma_s*(clfr*qn+(1.0/sqrt(2.0*pi))*exp(-qn*qn/2.0)) )

  end subroutine single_gaussian

  !> Calculate liquid cloud water content using double Gaussian scheme (modified Lewellen & Yoh).
  !! @param qcl - liquid water content
  !! @param qc_gauss - resolved liquid water content based on supersaturation
  !! @param sigma_s - standard deviation of s
  !! @param Sks - Skewness of s
  !! @param Skw - Skewness of w
  !! @param rsw - correlation of s and w
  subroutine double_gaussian(qcl,Qcr,sigma_s,Sks,Skw,rsw)
    real(DEFAULT_PRECISION), intent(out) :: qcl
    real(DEFAULT_PRECISION), intent(in) :: Qcr,sigma_s,Sks,Skw,rsw
    real(DEFAULT_PRECISION) :: erf,clfr
    real(DEFAULT_PRECISION) :: fac
    real(DEFAULT_PRECISION) :: a  !weighing factor between the two Gaussians 
    real(DEFAULT_PRECISION) :: Bs
    real(DEFAULT_PRECISION) :: mu_s1, mu_s2,mu_s
    real(DEFAULT_PRECISION) :: sig_s1, sig_s2
    real(DEFAULT_PRECISION) :: qcl1, qcl2, N1, N2
    integer :: c, eps, epsnm1

    mu_s=0 ! resolved s is zero by definition

    !find a
    !solving using Newton method
    c=0    
    eps = 0
    epsnm1 = 0.1

    if (Sks*Skw==0 .OR. (1-6*epsnm1+9*epsnm1**2-4*epsnm1**3)==0) then
      eps=0.01                                                                                            
    else
      ! solve (1-eps)**3*eps=rsw**3/(Sks*Skw)
      fac = rsw**3/abs(Sks*Skw) 
      if (fac > 0 .AND. fac < 27./256.) then ! the allowed boundaries for eps between 0 and 1 
        do while (abs(epsnm1-eps)>0.001 .AND. c<=30) 
          epsnm1=eps
          eps=epsnm1-((1-epsnm1)**3*epsnm1-fac)/(1-6*epsnm1+9*epsnm1**2-3*epsnm1**3)
          c=c+1
          if (c>30) then
          !if no convergence use linearized solution
            eps=(1-sqrt(1-12.*fac))/6.
          endif
        end do

      else if (fac > 27./256.) then
      !if value larger than max((1-eps)**3*eps) in the interval 0<=eps<=1
        eps=0.25 !the location of the maximum value of (1-eps)**3*eps                                      
      else
        eps=0.01
      endif

    endif

    !restrict eps to interval (0.01,0.99) to avoid extreme values
    if (eps<0.01) then  
      eps=0.01
    else if (eps>0.99) then
      eps=0.99 !if a is too small it will not fullfil the critaria for a valid sigma_1 (3*sig_s[i,j,k]**2/Bs[i,j,k]**2<=(1-a**3)/a)
    endif

    a=1-eps

    Bs=mean_diff(Sks,a,sigma_s,mu_s)
    if (a>0 .AND. Bs .ne. 0) then
      do while (3*sigma_s**2/Bs**2<=(1-a**3)/a .AND. a<0.99) !3*sigma_s**2/Bs**2 > (1-a**3)/a required for sigma_s2**2 >= 0
      !Adjust a and B until requirement is fulfilled
        a=a+0.01
        Bs=mean_diff(Sks,a,sigma_s,mu_s)
      enddo
      if (a>=0.99 .AND. 3*sigma_s**2/Bs**2<=(1-a**3)/a) then !if requirement can't be fulfilled set B=0 and a=0.99
        a=0.99
        Bs=0
      endif
    endif

    !calculate moments, mu_s=0

    mu_s1=mu_s-(1-a)*Bs
    mu_s2=mu_s+a*Bs

    if (a==0) then      !only PDF2                                                                    
      sig_s1=0
    else                                                                                                   
      sig_s1=sqrt(sigma_s**2-(1-a)*(1+a+a**2)/(3*a)*Bs**2)
    endif 
                      
    sig_s2=sqrt(sigma_s**2+(1-a)**2/3*Bs**2)   

    if (a==0) then
      call qclcalc(qcl2,N2,sig_s2,mu_s2,Qcr)
      qcl1=0
    else if (a==1) then
      call qclcalc(qcl1,N1,sig_s1,mu_s1,Qcr)
      qcl2=0
    else
      call qclcalc(qcl1,N1,sig_s1,mu_s1,Qcr)
      call qclcalc(qcl2,N2,sig_s2,mu_s2,Qcr)
    endif

    !C=a*N1+(1-a)*N2                                                                              
    qcl=a*qcl1+(1-a)*qcl2     

  end subroutine double_gaussian

  subroutine qclcalc(qcl,C,sig,mu,Qcr)
    real(DEFAULT_PRECISION), intent(in) :: sig,mu,Qcr
    real(DEFAULT_PRECISION), intent(out) :: qcl,C

    !Cloud cover
    C=0.5*(1-error_fct(-(Qcr+mu)/(sig*sqrt(2.))))
    !liquid water content
    qcl=C*Qcr+sig/sqrt(2.*pi)*(exp(-0.5*((Qcr+mu)/sig)**2))+C*mu
  end subroutine

  !> Calculate difference in mean between the two Gaussians
  !! @param Sk - Skewness
  !! @param a -  weighing factor between the two Gaussians
  !! @param sig -  Standard deviation
  !! @param mu -  mean
  real(DEFAULT_PRECISION) function mean_diff(Sk,a,sig,mu)
    real(DEFAULT_PRECISION), intent(in) :: a,sig,mu
    real(DEFAULT_PRECISION), intent(in) :: Sk
    real(DEFAULT_PRECISION) :: B,Bn,Bnm1,Skabs
    integer :: c,si
    !find B
    c=0
    if (Sk<0) then 
      si=-1
    else
      si=1
    endif
    Skabs=abs(Sk) 

    if (a>0.99) then  !no cloud, only PDF1                                                                    
      Bn=0                                                                                                   
      B=0                                                                                                    
    else                                                                                                   
      !first guess                                                                                          
      B=sig*(Skabs/(1-a))**(1./3.)

      !Newton method
      Bnm1=B+0.1
      Bn=B
      do while (abs(Bn-Bnm1)>0.00001 .AND. c<20)
        Bnm1=Bn 
        Bn=Bnm1-(6*a*(1-a)*mu*Bnm1**2+Bnm1**3*(1-a)-Skabs*sig**3)/(12*a*(1-a)*mu*Bnm1+3*Bnm1**2*(1-a))

        c=c+1
      end do
    endif

    if (c>=20) then !if it didn't converge use original estimate
      Bn=B
    endif

    Bn=si*Bn

    mean_diff=Bn

  end function mean_diff

  !> Calculate error function for argument x 
  !! @param x parameter for error function
  real(DEFAULT_PRECISION) function error_fct(x)

    real(DEFAULT_PRECISION), intent(in) :: x
    real(DEFAULT_PRECISION), parameter :: a1 =  0.254829592
    real(DEFAULT_PRECISION), parameter :: a2 = -0.284496736
    real(DEFAULT_PRECISION), parameter :: a3 =  1.421413741
    real(DEFAULT_PRECISION), parameter :: a4 = -1.453152027
    real(DEFAULT_PRECISION), parameter :: a5 =  1.061405429
    real(DEFAULT_PRECISION), parameter :: p  =  0.3275911
    real(DEFAULT_PRECISION) :: xabs,t

    xabs = abs(x) !Approx. of error function only valid for x>=0
    
    t = 1.0 / (1.0 + p * xabs)


    !This approximation is only valid for x>=0
    error_fct=1.0-(a1*t+a2*t*t+a3*t**3+a4*t**4+a5**5)*exp(-xabs*xabs)
    !For negative x, make use of symmetry of error function: erf(x)=-erf(-x)
    if (x.lt.0) then
      error_fct=-error_fct
    endif

  end function error_fct
  
   !> Save the 3d tendencies coming into the component.
  !! @param current_state Current model state
  !! @param cxn The current slice, x, index
  !! @param cyn The current column, y, index.
  !! @param txn target_x_index
  !! @param tyn target_y_index
  subroutine save_precomponent_tendencies(current_state, cxn, cyn, txn, tyn)
    type(model_state_type), target, intent(in) :: current_state
    integer, intent(in) ::  cxn, cyn, txn, tyn

    ! Save 3d tendency fields upon request (of 3d or profiles) and availability
    if (l_tend_3d_th) then
      tend_3d_th(:,tyn,txn)=current_state%sth%data(:,cyn,cxn)
    endif
    if (l_tend_3d_qv) then
      tend_3d_qv(:,tyn,txn)=current_state%sq(iqv)%data(:,cyn,cxn)
    endif
    if (l_tend_3d_ql) then
      tend_3d_ql(:,tyn,txn)=current_state%sq(iql)%data(:,cyn,cxn)
    endif
    if (l_tend_3d_tabs) then
      tend_3d_tabs(:,tyn,txn)=current_state%sth%data(:,cyn,cxn) * current_state%global_grid%configuration%vertical%rprefrcp(:)
    endif

  end subroutine save_precomponent_tendencies


   !> Computation of component tendencies
  !! @param current_state Current model state
  !! @param cxn The current slice, x, index
  !! @param cyn The current column, y, index.
  !! @param txn target_x_index
  !! @param tyn target_y_index
  subroutine compute_component_tendencies(current_state, cxn, cyn, txn, tyn)
    type(model_state_type), target, intent(inout) :: current_state
    integer, intent(in) ::  cxn, cyn, txn, tyn

    ! Calculate change in tendency due to component
    if (l_tend_3d_th) then
      tend_3d_th(:,tyn,txn)=current_state%sth%data(:,cyn,cxn)     - tend_3d_th(:,tyn,txn)
    endif
    if (l_tend_3d_qv) then
      tend_3d_qv(:,tyn,txn)=current_state%sq(iqv)%data(:,cyn,cxn) - tend_3d_qv(:,tyn,txn)
    endif
    if (l_tend_3d_ql) then
      tend_3d_ql(:,tyn,txn)=current_state%sq(iql)%data(:,cyn,cxn) - tend_3d_ql(:,tyn,txn)
    endif
    if (l_tend_3d_tabs) then
      tend_3d_tabs(:,tyn,txn)=   &
       current_state%sth%data(:,cyn,cxn) * current_state%global_grid%configuration%vertical%rprefrcp(:)   &
        - tend_3d_tabs(:,tyn,txn)
    endif

   ! Add local tendency fields to the profile total
    if (l_tend_pr_tot_th) then
      tend_pr_tot_th(:)=tend_pr_tot_th(:) + tend_3d_th(:,tyn,txn)
    endif
    if (l_tend_pr_tot_qv) then
      tend_pr_tot_qv(:)=tend_pr_tot_qv(:) + tend_3d_qv(:,tyn,txn)
    endif
    if (l_tend_pr_tot_ql) then
      tend_pr_tot_ql(:)=tend_pr_tot_ql(:) + tend_3d_ql(:,tyn,txn)
    endif
    if (l_tend_pr_tot_tabs) then
      tend_pr_tot_tabs(:)=tend_pr_tot_tabs(:) + tend_3d_tabs(:,tyn,txn)
    endif

  end subroutine compute_component_tendencies


  !> Sets the published field value from the temporary diagnostic values held by this component.
  !! @param field_value Populated with the value of the field
  !! @param real_1d_field Optional one dimensional real of values to publish
  !! @param real_2d_field Optional two dimensional real of values to publish
  subroutine set_published_field_value(field_value, real_1d_field, real_2d_field, real_3d_field)
    type(component_field_value_type), intent(inout) :: field_value
    real(kind=DEFAULT_PRECISION), dimension(:), optional :: real_1d_field
    real(kind=DEFAULT_PRECISION), dimension(:,:), optional :: real_2d_field
    real(kind=DEFAULT_PRECISION), dimension(:,:,:), optional :: real_3d_field

    if (present(real_1d_field)) then
      allocate(field_value%real_1d_array(size(real_1d_field)), source=real_1d_field)
    else if (present(real_2d_field)) then
      allocate(field_value%real_2d_array(size(real_2d_field, 1), size(real_2d_field, 2)), source=real_2d_field)
    else if (present(real_3d_field)) then
      allocate(field_value%real_3d_array(size(real_3d_field, 1), size(real_3d_field, 2), size(real_3d_field, 3)), &
               source=real_3d_field)
    end if
  end subroutine set_published_field_value

end module gaussiancloud_mod
