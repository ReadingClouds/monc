!> Circle-A flexible First and Second order closure turbulence scheme.
module circle_a_mod

  use datadefn_mod, only : DEFAULT_PRECISION, STRING_LENGTH     
  use state_mod, only : FORWARD_STEPPING, CENTRED_STEPPING, model_state_type
  use monc_component_mod, only : COMPONENT_ARRAY_FIELD_TYPE, &
      COMPONENT_DOUBLE_DATA_TYPE, component_descriptor_type, &
      component_field_value_type, component_field_information_type
  use optionsdatabase_mod, only :  options_get_real_array, options_get_real, &
     options_get_logical, options_get_array_size, options_get_string
  use prognostics_mod, only : prognostic_field_type
  use halo_communication_mod, only : copy_field_to_buffer, init_halo_communication, finalise_halo_communication, &
       initiate_nonblocking_halo_swap, get_single_field_per_halo_cell, copy_corner_to_buffer
 
  use grids_mod, only : local_grid_type, X_INDEX, Y_INDEX, Z_INDEX
  use science_constants_mod, only : smallp, pi, r_over_cp, rlvap_over_cp, von_karman_constant, z0, G, ratio_mol_wts
  use saturation_mod, only: qsaturation, dqwsatdt

  use registry_mod, only : is_component_enabled
  use logging_mod, only : LOG_DEBUG, LOG_ERROR, LOG_INFO, log_master_log
  use smagorinsky_mod, only: calculate_half_squared_strain_rate, &
                             calculate_richardson_number, copy_diff_to_halo_buffer, &
                             copy_vis_to_halo_buffer, copy_vis_corners_to_halo_buffer, &
                             copy_diff_corners_to_halo_buffer, update_viscous_number, setfri, set_vis_and_diff, &
                             mixing_length_param, set_vis_and_diff_param
  use q_indices_mod, only: get_q_index, standard_q_names
  implicit none

#ifndef TEST_MODE
  private
#endif

  logical, public :: circle_a_enabled
!  logical, public :: diffuse_ca_progs
  logical :: diffuse_ca_progs
  logical :: use_total_fluxes

            
  real(kind=DEFAULT_PRECISION), public :: tke_diff_mult
    
  real(kind=DEFAULT_PRECISION), parameter :: mintke = 0.0000005, min_thl_thl = 0.0000005, min_qt_qt = 5.0E-12
  real(kind=DEFAULT_PRECISION), parameter :: b1=24.0, b2=15.0, a1=1.18, a2=0.665, c1=0.137, c2=0.7, c3=0.323, c4=0.0, c5=0.2
  real(kind=DEFAULT_PRECISION) :: c_virtual
  real(kind=DEFAULT_PRECISION) :: one_third, two_thirds
  real(kind=DEFAULT_PRECISION) :: visc_const, ca_var_const, tke_coeff, pr_n, suba, smag_d, b1_over_b2  
  
  integer :: iqv, iql
  
  !Indices for variances and covariance
  integer :: i_thl_thl, i_qt_qt, i_thl_qt, i_tke,  &
             i_uu, i_uv, i_uw, i_vv, i_vw, i_ww, &
             i_u_thl, i_v_thl, i_w_thl, &
             i_u_qt, i_v_qt, i_w_qt

  character(len=1000) :: output_str

  real(kind=DEFAULT_PRECISION), dimension(:,:,:), allocatable :: smag_tke_diag, tke_shear_prod_diag, tke_buoyant_prod_diag, &
                                                                 tke_total_prod_diag, tke_dissipation_diag, &
                                                                 tke_decay_rate_diag, &
                                                                 richardson_number_diag, ssq_diag, fm_ca_diag, fh_ca_diag, &
                                                                 smag_viscosity_diag, smag_diffusivity_diag, &                           
                                                                 tke_viscosity_diag, tke_diffusivity_diag, &
                                                                 thl2_prod_diag, qt2_prod_diag, thlqt_prod_diag

                                                                                        

  
  !config option
  character(len=STRING_LENGTH) :: ca_level
  !config option
  character(len=STRING_LENGTH) :: gtype 
  logical :: Smagorinsky_equiv

  public circle_a_get_descriptor
  
contains

  !> Provides a description of this component for the core to register
  !! @returns The descriptor containing registration information for this component
  type(component_descriptor_type) function circle_a_get_descriptor()
    circle_a_get_descriptor%name="circle_a"
    circle_a_get_descriptor%version=0.1
    circle_a_get_descriptor%initialisation=>initialisation_callback
    circle_a_get_descriptor%timestep=>timestep_callback
    circle_a_get_descriptor%finalisation=>finalisation_callback

    circle_a_get_descriptor%field_value_retrieval=>field_value_retrieval_callback
    circle_a_get_descriptor%field_information_retrieval=>field_information_retrieval_callback
    allocate(circle_a_get_descriptor%published_fields(17))

    circle_a_get_descriptor%published_fields(1)="smag_tke"
    circle_a_get_descriptor%published_fields(2)="tke_shear_prod"
    circle_a_get_descriptor%published_fields(3)="tke_buoyant_prod"
    circle_a_get_descriptor%published_fields(4)="tke_total_prod"
    circle_a_get_descriptor%published_fields(5)="tke_dissipation"
    circle_a_get_descriptor%published_fields(6)="tke_decay_rate"
    circle_a_get_descriptor%published_fields(7)="richardson_number"
    circle_a_get_descriptor%published_fields(8)="modssq"
    circle_a_get_descriptor%published_fields(9)="fm_ca"
    circle_a_get_descriptor%published_fields(10)="fh_ca"
    circle_a_get_descriptor%published_fields(11)="smag_viscosity"
    circle_a_get_descriptor%published_fields(12)="smag_diffusivity"
    circle_a_get_descriptor%published_fields(13)="tke_viscosity"
    circle_a_get_descriptor%published_fields(14)="tke_diffusivity"
    circle_a_get_descriptor%published_fields(15)="thl2_prod"
    circle_a_get_descriptor%published_fields(16)="qt2_prod"
    circle_a_get_descriptor%published_fields(17)="thlqt_prod"
     
  end function circle_a_get_descriptor

  !> Field information retrieval callback, this returns information for a specific components published field
  !! @param current_state Current model state
  !! @param name The name of the field to retrieve information for
  !! @param field_information Populated with information about the field
  subroutine field_information_retrieval_callback(current_state, name, field_information)
    type(model_state_type), target, intent(inout) :: current_state
    character(len=*), intent(in) :: name
    type(component_field_information_type), intent(out) :: field_information
!    integer :: strcomp
    
    logical :: comp_enabled, available

!    write(output_str, *)"field_information_retrieval_callback = ",name
!    call log_master_log(LOG_INFO, adjustl(trim(output_str)))

    comp_enabled = is_component_enabled(current_state%options_database, "circle_a") 
    
    available = comp_enabled 
                    
    if (     name .eq. "smag_tke" &
        .or. name .eq. "tke_shear_prod" &
        .or. name .eq. "tke_buoyant_prod" &
        .or. name .eq. "tke_total_prod" &
        .or. name .eq. "tke_dissipation" &
        .or. name .eq. "tke_decay_rate" &
        .or. name .eq. "richardson_number" &
        .or. name .eq. "modssq" &
        .or. name .eq. "fm_ca" &
        .or. name .eq. "fh_ca" &
        .or. name .eq. "smag_viscosity" &
        .or. name .eq. "smag_diffusivity" &
      ) then    
      field_information%field_type=COMPONENT_ARRAY_FIELD_TYPE
      field_information%number_dimensions=3
      field_information%dimension_sizes(1)=current_state%local_grid%size(Z_INDEX)
      field_information%dimension_sizes(2)=current_state%local_grid%size(Y_INDEX)
      field_information%dimension_sizes(3)=current_state%local_grid%size(X_INDEX)
      field_information%data_type=COMPONENT_DOUBLE_DATA_TYPE
      field_information%enabled = available
    end if

    available = (comp_enabled .and. (ca_level .eq. "L2.5_Smag" .or. ca_level .eq. "L3.0_Smag"))
    if    (name .eq. "tke_viscosity" &
      .or. name .eq. "tke_diffusivity" &
      ) then    
      field_information%field_type=COMPONENT_ARRAY_FIELD_TYPE
      field_information%number_dimensions=3
      field_information%dimension_sizes(1)=current_state%local_grid%size(Z_INDEX)
      field_information%dimension_sizes(2)=current_state%local_grid%size(Y_INDEX)
      field_information%dimension_sizes(3)=current_state%local_grid%size(X_INDEX)
      field_information%data_type=COMPONENT_DOUBLE_DATA_TYPE
      field_information%enabled = available
    end if
    
    available = (comp_enabled .and. ca_level .eq. "L3.0_Smag")
    if    (name .eq. "thl2_prod" &
      .or. name .eq. "qt2_prod" &      
      .or. name .eq. "thlqt_prod" &
      ) then    
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
    
    if (name .eq. "smag_tke" .and. allocated(smag_tke_diag)) then
      call set_published_field_value(field_value, real_3d_field=smag_tke_diag)
    end if
    if (name .eq. "tke_shear_prod" .and. allocated(tke_shear_prod_diag)) then
      call set_published_field_value(field_value, real_3d_field=tke_shear_prod_diag)
    end if
    if (name .eq. "tke_buoyant_prod" .and. allocated(tke_buoyant_prod_diag)) then
      call set_published_field_value(field_value, real_3d_field=tke_buoyant_prod_diag)
    end if
    if (name .eq. "tke_total_prod" .and. allocated(tke_total_prod_diag)) then
      call set_published_field_value(field_value, real_3d_field=tke_total_prod_diag)
    end if
    if (name .eq. "tke_dissipation" .and. allocated(tke_dissipation_diag)) then
      call set_published_field_value(field_value, real_3d_field=tke_dissipation_diag)
    end if
    if (name .eq. "tke_decay_rate" .and. allocated(tke_decay_rate_diag)) then
      call set_published_field_value(field_value, real_3d_field=tke_decay_rate_diag)
    end if
    if (name .eq. "richardson_number" .and. allocated(richardson_number_diag)) then
      call set_published_field_value(field_value, real_3d_field=richardson_number_diag)
    end if
    if (name .eq. "modssq" .and. allocated(ssq_diag)) then
      call set_published_field_value(field_value, real_3d_field=ssq_diag)
    end if
    if (name .eq. "fm_ca" .and. allocated(fm_ca_diag)) then
      call set_published_field_value(field_value, real_3d_field=fm_ca_diag)
    end if
    if (name .eq. "fh_ca" .and. allocated(fh_ca_diag)) then
      call set_published_field_value(field_value, real_3d_field=fh_ca_diag)
    end if
    if (name .eq. "smag_viscosity" .and. allocated(smag_viscosity_diag)) then
      call set_published_field_value(field_value, real_3d_field=smag_viscosity_diag)
    end if
    if (name .eq. "smag_diffusivity" .and. allocated(smag_diffusivity_diag)) then
      call set_published_field_value(field_value, real_3d_field=smag_diffusivity_diag)
    end if
    if (name .eq. "tke_viscosity" .and. allocated(tke_viscosity_diag)) then
      call set_published_field_value(field_value, real_3d_field=tke_viscosity_diag)
    end if
    if (name .eq. "tke_diffusivity" .and. allocated(tke_diffusivity_diag)) then
      call set_published_field_value(field_value, real_3d_field=tke_diffusivity_diag)
    end if
    if (name .eq. "thl2_prod" .and. allocated(thl2_prod_diag)) then
      call set_published_field_value(field_value, real_3d_field=thl2_prod_diag)
    end if
    if (name .eq. "qt2_prod" .and. allocated(qt2_prod_diag)) then
      call set_published_field_value(field_value, real_3d_field=qt2_prod_diag)
    end if
    if (name .eq. "thlqt_prod" .and. allocated(thlqt_prod_diag)) then
      call set_published_field_value(field_value, real_3d_field=thlqt_prod_diag)
    end if

  end subroutine field_value_retrieval_callback

  !> Initialisation callback hook which will <DO WHAT?>
  !! @param current_state The current model state
  subroutine initialisation_callback(current_state)
  
    ! Current supported levels (set by ca_level in options_database):
    ! 
    ! L1.0_Smag
    ! L2.0_Smag
    ! L2.5_Smag
    ! L3.0_Smag
    !
    ! The "Lx.x_Smag" means use a closure consistent with the standard Smagorinsky stability fiunctions.
    ! Once this is working I intend to implement the 3DTE closures as well.
    !
    ! All second-order variables are stored in the model state whether diagnostic or prognostic.
    ! number_ca_fields is independent of level; it is there for future expansion but should 
    ! be left at 16 at present.
    !
    ! current_state%ca_advect() is an array of logicals that controls whether a field is advected.
    !
    ! All current_state%ca_advect() are .false. except:
    ! 
    ! current_state%ca_advect(i_tke) 
    ! L1.0_Smag: .false.
    ! L2.0_Smag: .true. but only used diagnostically
    ! L2.5_Smag: .true.
    ! L3.0_Smag: .true.
    !
    ! current_state%ca_advect(i_thl_thl), current_state%ca_advect(i_qt_qt), current_state%ca_advect(i_thl_qt)  
    ! L1.0_Smag: .false.
    ! L2.0_Smag: .false.
    ! L2.5_Smag: .false.
    ! L3.0_Smag: .true.
    !
    ! Options:
    ! diffuse_ca_progs 
    ! use_total_fluxes
    ! gtype: set by gaussian in options_database
    
    type(model_state_type), intent(inout), target :: current_state
    
    integer :: i,j
   
    logical :: available

    circle_a_enabled=options_get_logical(current_state%options_database, "circle_a_enabled")

    if (circle_a_enabled) then
      call log_master_log(LOG_INFO, "Circle_A is enabled.")      
    else
      call log_master_log(LOG_INFO, "Circle_A is not enabled.")
      return
    end if
   
    if (.not. is_component_enabled(current_state%options_database, "smagorinsky")) then
      call log_master_log(LOG_ERROR, "Circle_A requires the smagorinsky component to be enabled")
    end if    
    
    if (.not. is_component_enabled(current_state%options_database, "diffusion")) then
      call log_master_log(LOG_ERROR, "Circle_A requires the diffusion component to be enabled")
    end if    

    if (.not. is_component_enabled(current_state%options_database, "viscosity")) then
      call log_master_log(LOG_ERROR, "Circle_A requires the viscosity component to be enabled")
    end if

    if (.not. current_state%use_viscosity_and_diffusion) then 
       call log_master_log(LOG_ERROR, "Circle_A requires use_viscosity_and_diffusion=.true. or monc will fail")
    endif

    if (.not. is_component_enabled(current_state%options_database, "lower_bc")) then
       call log_master_log(LOG_INFO, "LOWERBC is disabled, zero diff and vis_coeff on level 1")
       current_state%vis_coefficient%data(1,:,:)=0.0_DEFAULT_PRECISION
       current_state%diff_coefficient%data(1,:,:)=0.0_DEFAULT_PRECISION
    endif
    
    ca_level = options_get_string(current_state%options_database, "circle_a_level")
    
    Smagorinsky_equiv = (ca_level(6:9) .eq. "Smag")
    if (Smagorinsky_equiv) then
      call log_master_log(LOG_INFO, "Circle_A is using Smagorinsky-based source terms.")
    end if
    
    if (ca_level .ne. "L1.0_Smag" .and.                                                  &
        ca_level .ne. "L2.0_Smag" .and.                                                  &
        ca_level .ne. "L2.5_Smag" .and.                                                  & 
        ca_level .ne. "L3.0_Smag") then    
      call log_master_log(LOG_ERROR, trim("Config option not available: "//ca_level))
    else
      write(output_str, *)"Circle-A Level: ", ca_level
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))
    end if
     
    diffuse_ca_progs=options_get_logical(current_state%options_database, "diffuse_ca_progs")
    if (diffuse_ca_progs) then
      call log_master_log(LOG_INFO, "Circle_A diffusion of prognostics is enabled.")
    else
      call log_master_log(LOG_INFO, "Circle_A diffusion of prognostics is disabled.")
    end if
    
    use_total_fluxes=options_get_logical(current_state%options_database, "use_total_fluxes")
    if (use_total_fluxes) then
      call log_master_log(LOG_INFO, "Circle_A using total fluxes in source terms.")
    else
      call log_master_log(LOG_INFO, "Circle_A using down-gradient fluxes in source terms.")
    end if
    
    gtype = options_get_string(current_state%options_database, "gaussian")

    if (current_state%number_ca_fields > 0) then
    
      i_tke     = current_state%tke_index
      i_thl_thl = current_state%thl_thl_index
      i_qt_qt   = current_state%qt_qt_index
      i_thl_qt  = current_state%thl_qt_index
      i_uu      = current_state%u_u_index
      i_uv      = current_state%u_v_index
      i_uw      = current_state%u_w_index
      i_vv      = current_state%v_v_index
      i_vw      = current_state%v_w_index
      i_ww      = current_state%w_w_index
      i_u_thl   = current_state%u_thl_index
      i_v_thl   = current_state%v_thl_index
      i_w_thl   = current_state%w_thl_index
      i_u_qt    = current_state%u_qt_index
      i_v_qt    = current_state%v_qt_index
      i_w_qt    = current_state%w_qt_index
      
      write(output_str, *)"tke_index = ",i_tke
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      write(output_str, *)"thl_thl_index = ",i_thl_thl
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      write(output_str, *)"qt_qt_index = ",  i_qt_qt
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      write(output_str, *)"thl_qt_index = ", i_thl_qt
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      write(output_str, *)"uu_index = ",i_uu
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      write(output_str, *)"uv_index = ",i_uv
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      write(output_str, *)"uw_index = ",i_uw
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      write(output_str, *)"vv_index = ",i_vv
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      write(output_str, *)"vw_index = ",i_vw
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      write(output_str, *)"ww_index = ",i_ww
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      write(output_str, *)"u_thl_index = ",i_u_thl
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      write(output_str, *)"v_thl_index = ",i_v_thl
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))      
      write(output_str, *)"w_thl_index = ",i_w_thl
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      write(output_str, *)"u_qt_index = ",i_u_qt
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      write(output_str, *)"v_qt_index = ",i_v_qt
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      write(output_str, *)"w_qt_index = ",i_w_qt
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      
      allocate(current_state%ca_advect( current_state%number_ca_fields ) )
      do i=1, current_state%number_ca_fields
        current_state%ca_advect(i) = .false.
      end do
      
      if (ca_level .ne. "L1.0_Smag") then 
        ! Advect TKE; 
        ! However, for L2.0 amd L2.0_Smag do not use this; it is passive for diagnostic interest.
        current_state%ca_advect(i_tke) = .true. 
        write(output_str, *)"Advecting TKE, index ",i_tke
        call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      endif

      if (ca_level .eq. "L3.0_Smag") then 
        current_state%ca_advect(i_thl_thl) = .true. 
        write(output_str, *)"Advecting thl_thl, index ",i_thl_thl
        call log_master_log(LOG_INFO, adjustl(trim(output_str)))
        current_state%ca_advect(i_qt_qt) = .true. 
        write(output_str, *)"Advecting qt_qt, index ",i_qt_qt
        call log_master_log(LOG_INFO, adjustl(trim(output_str)))
        current_state%ca_advect(i_thl_qt) = .true. 
        write(output_str, *)"Advecting thl_qt, index ",i_thl_qt
        call log_master_log(LOG_INFO, adjustl(trim(output_str)))
      endif
      
    end if   

    if (.not. current_state%passive_q) then 
       iqv = get_q_index(standard_q_names%VAPOUR, 'circle_a')
       current_state%water_vapour_mixing_ratio_index=iqv
       
       iql = get_q_index(standard_q_names%CLOUD_LIQUID_MASS, 'circle_a')
       current_state%liquid_water_mixing_ratio_index=iql
    endif

!    tke_diff_mult = options_get_real(current_state%options_database, "tke_diff_mult")
    if ((.not. diffuse_ca_progs) .or. ca_level .eq. "L1.0_Smag" .or. ca_level .eq. "L2.0_Smag" ) then
      tke_diff_mult = 1.0_DEFAULT_PRECISION
    else
      tke_diff_mult = 5.0_DEFAULT_PRECISION / 3.0_DEFAULT_PRECISION
    end if
    
    ! various constants it is useful to pre-calculate.
    
    c_virtual = (ratio_mol_wts-1.0_DEFAULT_PRECISION)
   
    one_third  = (1.0_DEFAULT_PRECISION/3.0_DEFAULT_PRECISION)
    two_thirds = (2.0_DEFAULT_PRECISION/3.0_DEFAULT_PRECISION)

    visc_const = sqrt(2.0_DEFAULT_PRECISION) / b1**one_third
    ca_var_const = b2 / b1**one_third
    
    tke_coeff = (b1**two_thirds) * 0.5_DEFAULT_PRECISION
    smag_d = tke_coeff !b1 / 2.0_DEFAULT_PRECISION / sqrt(2.0_DEFAULT_PRECISION)
    
    pr_n=0.7_DEFAULT_PRECISION
    suba=1.0_DEFAULT_PRECISION/pr_n
    
    b1_over_b2 = b1 / b2
    
! We might need this here if we move all of smagorinsky functionality to here.

    if (current_state%use_viscosity_and_diffusion) then
      call log_master_log(LOG_DEBUG, "Circle_A initialise halo communication.")
      call init_halo_communication(current_state, get_single_field_per_halo_cell, &
           current_state%viscosity_halo_swap_state, 2, .true.)
      call init_halo_communication(current_state, get_single_field_per_halo_cell, &
           current_state%diffusion_halo_swap_state, 2, .true.)
    end if    
    
!    available = is_component_enabled(current_state%options_database, "circle_a") 

    available = circle_a_enabled

    if (available) then  
      allocate( smag_tke_diag(current_state%local_grid%size(Z_INDEX),          &
                             current_state%local_grid%size(Y_INDEX),           &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( tke_shear_prod_diag(current_state%local_grid%size(Z_INDEX),    &
                             current_state%local_grid%size(Y_INDEX),           &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( tke_buoyant_prod_diag(current_state%local_grid%size(Z_INDEX),  &
                             current_state%local_grid%size(Y_INDEX),           &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( tke_total_prod_diag(current_state%local_grid%size(Z_INDEX),    &
                             current_state%local_grid%size(Y_INDEX),           &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( tke_dissipation_diag(current_state%local_grid%size(Z_INDEX),   &
                             current_state%local_grid%size(Y_INDEX),           &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( tke_decay_rate_diag(current_state%local_grid%size(Z_INDEX),    &
                             current_state%local_grid%size(Y_INDEX),           &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( richardson_number_diag(current_state%local_grid%size(Z_INDEX), &
                             current_state%local_grid%size(Y_INDEX),           &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( ssq_diag(current_state%local_grid%size(Z_INDEX),               &
                             current_state%local_grid%size(Y_INDEX),           &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( fm_ca_diag(current_state%local_grid%size(Z_INDEX),                &
                             current_state%local_grid%size(Y_INDEX),           &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( fh_ca_diag(current_state%local_grid%size(Z_INDEX),                &
                             current_state%local_grid%size(Y_INDEX),           &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( smag_viscosity_diag(current_state%local_grid%size(Z_INDEX),    &
                             current_state%local_grid%size(Y_INDEX),           &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( smag_diffusivity_diag(current_state%local_grid%size(Z_INDEX),  &
                             current_state%local_grid%size(Y_INDEX),           &
                             current_state%local_grid%size(X_INDEX)   )    )
    end if

    available = (circle_a_enabled .and.                                        &
                 (ca_level .eq. "L2.5_Smag" .or. ca_level .eq. "L3.0_Smag"))
    if (available) then  
      allocate( tke_viscosity_diag(current_state%local_grid%size(Z_INDEX),     &
                             current_state%local_grid%size(Y_INDEX),           &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( tke_diffusivity_diag(current_state%local_grid%size(Z_INDEX),   &
                             current_state%local_grid%size(Y_INDEX),           &
                             current_state%local_grid%size(X_INDEX)   )    )
    end if

    available = (circle_a_enabled .and. ca_level .eq. "L3.0_Smag")
    if (available) then  
      allocate( thl2_prod_diag(current_state%local_grid%size(Z_INDEX),  &
                             current_state%local_grid%size(Y_INDEX),  &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( qt2_prod_diag(current_state%local_grid%size(Z_INDEX),  &
                             current_state%local_grid%size(Y_INDEX),  &
                             current_state%local_grid%size(X_INDEX)   )    )
      allocate( thlqt_prod_diag(current_state%local_grid%size(Z_INDEX),  &
                             current_state%local_grid%size(Y_INDEX),  &
                             current_state%local_grid%size(X_INDEX)   )    )
    end if

  end subroutine initialisation_callback

  !> Finalisation callback hook which will <DO WHAT?>
  !! @param current_state The current model state
  subroutine finalisation_callback(current_state)
    type(model_state_type), intent(inout), target :: current_state
    if (circle_a_enabled) then
      call log_master_log(LOG_DEBUG, "Circle_A finalise halo communication.")

      call finalise_halo_communication(current_state%viscosity_halo_swap_state)
      call finalise_halo_communication(current_state%diffusion_halo_swap_state)
    end if
    call log_master_log(LOG_INFO, "Circle_a finalisation called.")

    if (allocated(smag_tke_diag)) deallocate(smag_tke_diag)
    if (allocated(tke_shear_prod_diag)) deallocate(tke_shear_prod_diag)
    if (allocated(tke_buoyant_prod_diag)) deallocate(tke_buoyant_prod_diag)
    if (allocated(tke_total_prod_diag)) deallocate(tke_total_prod_diag)
    if (allocated(tke_dissipation_diag)) deallocate(tke_dissipation_diag)
    if (allocated(tke_decay_rate_diag)) deallocate(tke_decay_rate_diag)
    if (allocated(richardson_number_diag)) deallocate(richardson_number_diag)
    if (allocated(ssq_diag)) deallocate(ssq_diag)
    if (allocated(fm_ca_diag)) deallocate(fm_ca_diag)
    if (allocated(fh_ca_diag)) deallocate(fh_ca_diag)
    if (allocated(smag_viscosity_diag)) deallocate(smag_viscosity_diag)
    if (allocated(smag_diffusivity_diag)) deallocate(smag_diffusivity_diag)
    if (allocated(tke_viscosity_diag)) deallocate(tke_viscosity_diag)
    if (allocated(tke_diffusivity_diag)) deallocate(tke_diffusivity_diag)
    if (allocated(thl2_prod_diag)) deallocate(thl2_prod_diag)
    if (allocated(qt2_prod_diag)) deallocate(qt2_prod_diag)
    if (allocated(thlqt_prod_diag)) deallocate(thlqt_prod_diag)
    
  end subroutine finalisation_callback

  !> Timestep callback hook which will <DO WHAT?>
  !! @param current_state The current model state
  subroutine timestep_callback(current_state)
    type(model_state_type), intent(inout), target :: current_state

    real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)) :: &
                                  beta_t, beta_q                           
    real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)) :: &
                                  richardson_number, ssq, fm, fh, smag_tke, &
                                  shear_prod, buoyant_prod, tke_source, tke_decay_rate, &
                                  thl_thl_source, qt_qt_source, thl_qt_source, var_decay_rate
    real(kind=DEFAULT_PRECISION), dimension(3, current_state%local_grid%size(Z_INDEX)) :: grad_thl, grad_qt
    real(kind=DEFAULT_PRECISION), dimension(3, 3, current_state%local_grid%size(Z_INDEX)) :: dui_by_dxj
    real(kind=DEFAULT_PRECISION), dimension(6, current_state%local_grid%size(Z_INDEX)) :: strain_rate
    ! Alanna parametrization
  	real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)) :: Cs_env, r_Cs_env_ml, r_Cs_IC_ml
  	real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)) :: Cth_env, r_Cth_env_ml, r_Cth_IC_ml
  	
    integer :: k          ! Loop counter
    integer :: icol, jcol ! Shorthand column indices
    
    real(kind=DEFAULT_PRECISION) :: tke_surf!, thl2_pr_surf, qt2_pr_surf, qtthl_pr_surf
    real(kind=DEFAULT_PRECISION) :: dtm  ! Local timestep variable
    integer :: target_x_index, target_y_index
    logical, parameter :: override_ssq=.true.
!    logical, parameter :: override_ssq=.false.
    logical, parameter :: use_smag_Ri=.false.
    logical :: calculate_diagnostics

    ! currently Circle-A is in subgrid group, implemented after smag
    ! but before advection in initialisation and finalisation stages
                        
    if (.not. circle_a_enabled) then
      call log_master_log(LOG_INFO, "Circle_A is not enabled.")
      return
    end if

    icol=current_state%column_local_x
    jcol=current_state%column_local_y

    target_x_index=icol-current_state%local_grid%halo_size(X_INDEX)
    target_y_index=jcol-current_state%local_grid%halo_size(Y_INDEX)
    
    if (.not. current_state%halo_column) then
    
      if (.not. current_state%use_viscosity_and_diffusion) then
      
        current_state%vis_coefficient%data(2:,:,:)=0.0_DEFAULT_PRECISION
        current_state%diff_coefficient%data(2:,:,:)=0.0_DEFAULT_PRECISION
        current_state%cvis=0.0_DEFAULT_PRECISION
        
      else
      
        ! ================ Variables derived from current state ================    
        ! Gradient of theta_l and qt on w-points.
        ! dui_by_dxj on w-points.
        ! Note - this appears to be backwards, as LEAPFROG is using previous timestep variables.
        ! This is how Smagorinsky is written and is done to improve stability.

        if (current_state%field_stepping == FORWARD_STEPPING) then
        
          call get_grad_thl_qt(current_state, current_state%th, current_state%q, grad_thl, grad_qt) 
          call get_dui_by_dxj(current_state, current_state%u, current_state%v, current_state%w, dui_by_dxj)
          call get_strain_rate_from_dui_by_dxj(current_state, dui_by_dxj, strain_rate) 
           
        else !leapfrog
        
          call get_grad_thl_qt(current_state, current_state%zth, current_state%zq, grad_thl, grad_qt) 
          call get_dui_by_dxj(current_state, current_state%zu, current_state%zv, current_state%zw, dui_by_dxj)
          call get_strain_rate_from_dui_by_dxj(current_state, dui_by_dxj, strain_rate)  
          
        end if

        ! ========================= Smagorinsky Section =======================    
        ! This is essentially Smagorinsky code.
        ! Note - this appears to be backwards, as LEAPFROG is using previous timestep variables.
        ! This is how Smagorinsky is written and is done to improve stability.
        
        if (current_state%field_stepping == FORWARD_STEPPING) then
        
          if (override_ssq) then
            ssq=get_ssq(current_state, strain_rate)
          else
            ssq=calculate_half_squared_strain_rate(current_state, current_state%u, current_state%v, current_state%w)        
          end if
          richardson_number=calculate_richardson_number(current_state, ssq, current_state%th, current_state%q) 
          
        else !leapfrog
        
          if (override_ssq) then
            ssq=get_ssq(current_state, strain_rate)
          else
            ssq=calculate_half_squared_strain_rate(current_state, current_state%zu, current_state%zv, current_state%zw)
          end if
          richardson_number=calculate_richardson_number(current_state, ssq, current_state%zth, current_state%zq)  
            
        end if       
        
        ! Calculate stability functions and thence set diffusivity and viscosity in current_state.
        call setfri(current_state, richardson_number, fm, fh)
        
        if (current_state%mixing_length_param) then
        
          ! Alanna parametrization
          
          call mixing_length_param(current_state, richardson_number, Cs_env, r_Cs_env_ml, r_Cs_IC_ml, Cth_env, r_Cth_env_ml, r_Cth_IC_ml)
          
          call set_vis_and_diff_param(current_state, ssq, fm, fh, r_Cs_env_ml, r_Cs_IC_ml, r_Cth_env_ml, r_Cth_IC_ml)
          
        else
        
          call set_vis_and_diff(current_state, ssq, fm, fh)
          
        end if 
        
        call set_smag_tke(current_state, ssq, richardson_number, fm, fh, smag_tke)
                    
        ! =============== Diagnostic Scalar Variances Section ==================           
        ! Now deal with scalar variances needed for cloud scheme.                                              
        if (ca_level .eq. "L1.0_Smag" .or. ca_level .eq. "L2.0_Smag" .or. ca_level .eq. "L2.5_Smag") then
        
          ! Diagnostic variances on p grid.
        
          call get_cloud_variances(current_state, richardson_number, fm, fh, grad_thl, grad_qt, &
                                   current_state%mixing_length_param, r_Cth_env_ml, r_Cth_IC_ml, &
                                   current_state%ca(i_thl_thl), current_state%ca(i_qt_qt), current_state%ca(i_thl_qt))
                                   
        end if
        
        ! Apply minimum scalar variances and consistent covariance.
        do k=1,current_state%local_grid%size(Z_INDEX)
           current_state%ca(i_thl_thl)%data(k,jcol, icol) = &
              MAX(current_state%ca(i_thl_thl)%data(k,jcol, icol), min_thl_thl)           
           current_state%ca(i_qt_qt)%data(k,jcol, icol) = &
              MAX(current_state%ca(i_qt_qt)%data(k,jcol, icol), min_qt_qt)   
           current_state%ca(i_thl_qt)%data(k,jcol, icol) = &
              sign(MIN(ABS(current_state%ca(i_thl_qt)%data(k,jcol, icol)), &
                       sqrt(current_state%ca(i_qt_qt)%data(k,jcol, icol))  &
                     * sqrt(current_state%ca(i_qt_qt)%data(k,jcol, icol))), &
                   current_state%ca(i_thl_qt)%data(k,jcol, icol))                     
        end do        
      
        ! ========================= TKE update and diffusivity Section =======================    
        
        ! Buoyancy coefficients are on theta, zn, levels.
        call buoyancy_ceoff(current_state,                                     &
                            current_state%ca(i_thl_thl)%data(:,jcol, icol),    &
                            current_state%ca(i_qt_qt)%data(:,jcol, icol),      &
                            current_state%ca(i_thl_qt)%data(:,jcol, icol),     &
                            current_state%th%data(:,jcol, icol),               &
                            current_state%q(iqv)%data(:,jcol, icol),           &
                            current_state%q(iql)%data(:,jcol, icol),           &
                            beta_t, beta_q)

        ! ======================= Copy diagnostics to arrays ====================   
         
        if (allocated(richardson_number_diag)) richardson_number_diag(:, target_y_index, target_x_index) = richardson_number(:)                              
        if (allocated(ssq_diag)) ssq_diag(:, target_y_index, target_x_index) = ssq(:)                              
        if (allocated(fm_ca_diag)) fm_ca_diag(:, target_y_index, target_x_index) = fm(:)                              
        if (allocated(fh_ca_diag)) fh_ca_diag(:, target_y_index, target_x_index) = fh(:)                              
        if (allocated(smag_viscosity_diag)) smag_viscosity_diag(:, target_y_index, target_x_index) = &
          current_state%vis_coefficient%data(:,jcol, icol)                             
        if (allocated(smag_diffusivity_diag)) smag_diffusivity_diag(:, target_y_index, target_x_index) = &
          current_state%diff_coefficient%data(:,jcol, icol)                             

        if (allocated(smag_tke_diag)) then
          call array_on_z_to_zn(current_state%local_grid%size(Z_INDEX), smag_tke, &
                                smag_tke_diag(:, target_y_index, target_x_index) )
        end if
                               
        ! Use equilibrium at surface to set sub-surface tke
        ! Need to use right time level data at surface
        if (current_state%field_stepping == FORWARD_STEPPING) then

          tke_surf = tke_coeff * &
            current_state%vis_coefficient%data(1,jcol, icol) * &
            (sqrt((current_state%zu%data(2, jcol, icol) * &
                   current_state%zu%data(2, jcol, icol) ) + &
                  (current_state%zv%data(2, jcol, icol) * &
                   current_state%zv%data(2, jcol, icol) ) )  / &
             current_state%global_grid%configuration%vertical%zn(2) )

        else
    
          tke_surf = tke_coeff *&
            current_state%vis_coefficient%data(1,jcol, icol) * &
            (sqrt((current_state%u%data(2, jcol, icol) * &
                   current_state%u%data(2, jcol, icol) ) + &
                  (current_state%v%data(2, jcol, icol) * &
                   current_state%v%data(2, jcol, icol) ) )  / &
             current_state%global_grid%configuration%vertical%zn(2) )
         
        end if   
        
        current_state%ca(i_tke)%data(1, jcol, icol) = 2.0_DEFAULT_PRECISION * tke_surf &
          - current_state%ca(i_tke)%data(2, jcol, icol)

        ! Since viscosity uses TKE, best to set lower limit first so have moved the following
        ! Apply minimum TKE
        do k=1,current_state%local_grid%size(Z_INDEX)
          current_state%ca(i_tke)%data(k,jcol, icol) = &
              MAX(current_state%ca(i_tke)%data(k,jcol, icol), mintke)           
        end do
        
        ! Now we overwrite viscosity and diffusivity for prognostic TKE.
        if (ca_level .eq. "L2.5_Smag" .or. ca_level .eq. "L3.0_Smag") then
        
          call set_visc_diff_from_tke(current_state, richardson_number, fm, fh) 
          
          ! ===================== Copy diagnostics to arrays ====================   
          if (allocated(tke_viscosity_diag)) tke_viscosity_diag(:, target_y_index, target_x_index) = current_state%vis_coefficient%data(:,jcol, icol)                             
          if (allocated(tke_diffusivity_diag)) tke_diffusivity_diag(:, target_y_index, target_x_index) = current_state%diff_coefficient%data(:,jcol, icol)                             

        endif
             
        if (is_component_enabled(current_state%options_database, "cfltest")) then
          call update_viscous_number(current_state, tke_diff_mult)
        endif
        
        ! ========================= Diagnostic FLuxes Section =======================    
                    
        ! Scalar fluxes on w points
        call get_scalar_fluxes(current_state, grad_thl, grad_qt, &
                               current_state%ca(i_u_thl), current_state%ca(i_v_thl), current_state%ca(i_w_thl), &
                               current_state%ca(i_u_qt),  current_state%ca(i_v_qt),  current_state%ca(i_w_qt))
                               
        ! Momentum fluxes on w points
        call get_momentum_fluxes(current_state, strain_rate, &
                                 current_state%ca(i_uv), current_state%ca(i_uw), current_state%ca(i_vw))   
                                 
        ! Contributions to TKE on w points
        if (Smagorinsky_equiv) then
          if (ca_level .eq. "L2.0_Smag") then
            call get_viscous_tke_components(current_state, smag_tke, strain_rate, &                                 
                                            current_state%ca(i_uu), current_state%ca(i_vv), current_state%ca(i_ww)) 
          else
            call get_viscous_tke_components(current_state, current_state%ca(i_tke)%data(:, jcol, icol), strain_rate, &                                 
                                            current_state%ca(i_uu), current_state%ca(i_vv), current_state%ca(i_ww))              
          end if
        else
          call get_tke_components(current_state, ssq, richardson_number, dui_by_dxj, strain_rate, &
                                  current_state%ca(i_tke)%data(:, jcol, icol), &
                                  current_state%ca(i_uu), current_state%ca(i_vv), current_state%ca(i_ww))   
        end if
        
        ! ========================= TKE Source Section =======================    
        ! Calculate TKE source strength and decay rate
        ! Strictly, only needed for L_2.5 and above but we are implementing a passive prognostic tke at L_2.0
        ! Currently uses ssq and Ri; could implement using the diagnosed stress and buoyancy flux directly.
        call set_tke_source(current_state, ssq, grad_thl, grad_qt,              &
                            strain_rate, beta_t, beta_q,                        &
                            shear_prod, buoyant_prod, tke_source)

        call set_tke_decay_rate(current_state, tke_decay_rate)
        
        if (current_state%field_stepping == FORWARD_STEPPING) then
          dtm = current_state%dtm
          call implicit_leapfrog_source(current_state, tke_source, current_state%ca(i_tke)%data(:,jcol, icol), &
            tke_decay_rate, dtm, 2, current_state%local_grid%size(Z_INDEX),                       &
            current_state%sca(i_tke)%data(:,jcol, icol))
        else !leapfrog
          dtm = 2.0_DEFAULT_PRECISION * current_state%dtm
          call implicit_leapfrog_source(current_state, tke_source, current_state%zca(i_tke)%data(:,jcol, icol), &
            tke_decay_rate, dtm, 2, current_state%local_grid%size(Z_INDEX),                       &
            current_state%sca(i_tke)%data(:,jcol, icol))
        end if        
                                
        ! ======================= Copy diagnostics to arrays ====================   
        if (allocated(tke_shear_prod_diag)) tke_shear_prod_diag(:, target_y_index, target_x_index) = shear_prod(:)                              
        if (allocated(tke_buoyant_prod_diag)) tke_buoyant_prod_diag(:, target_y_index, target_x_index) = buoyant_prod(:)                              
        if (allocated(tke_total_prod_diag)) tke_total_prod_diag(:, target_y_index, target_x_index) = tke_source(:) 

        if (allocated(tke_dissipation_diag)) then
          do k=1,current_state%local_grid%size(Z_INDEX)
            tke_dissipation_diag(k, target_y_index, target_x_index) = current_state%ca(i_tke)%data(k,jcol, icol) &
                                                                      * tke_decay_rate(k)
          end do
        end if                            

        if (allocated(tke_decay_rate_diag)) tke_decay_rate_diag(:, target_y_index, target_x_index) = tke_decay_rate(:) 

        ! ============= Prognostic Scalar Variances Section ====================  
          
        ! Now deal with scalar variances needed for cloud scheme.                                      
        if (ca_level .eq. "L3.0_Smag") then
                                   
          call get_variance_source(current_state, i_u_thl, i_u_thl, grad_thl, grad_thl, thl_thl_source)
          call get_variance_source(current_state, i_u_qt,  i_u_qt,  grad_qt,  grad_qt,  qt_qt_source)
          call get_variance_source(current_state, i_u_thl, i_u_qt,  grad_thl, grad_qt,  thl_qt_source)
          
          ! Scalar variance decay rate is 2 u_t / (B2 lambda)
          do k=1,current_state%local_grid%size(Z_INDEX)
            var_decay_rate(k) = b1_over_b2 * tke_decay_rate(k)
          end do
          
          if (current_state%field_stepping == FORWARD_STEPPING) then
          
            dtm = current_state%dtm
            
            call implicit_leapfrog_source(current_state, thl_thl_source, current_state%ca(i_thl_thl)%data(:,jcol, icol), &
              var_decay_rate, dtm, 2, current_state%local_grid%size(Z_INDEX),                       &
              current_state%sca(i_thl_thl)%data(:,jcol, icol))
              
            call implicit_leapfrog_source(current_state, qt_qt_source, current_state%ca(i_qt_qt)%data(:,jcol, icol), &
              var_decay_rate, dtm, 2, current_state%local_grid%size(Z_INDEX),                       &
              current_state%sca(i_qt_qt)%data(:,jcol, icol))
              
            call implicit_leapfrog_source(current_state, thl_qt_source, current_state%ca(i_thl_qt)%data(:,jcol, icol), &
              var_decay_rate, dtm, 2, current_state%local_grid%size(Z_INDEX),                       &
              current_state%sca(i_thl_qt)%data(:,jcol, icol))
              
          else !leapfrog
          
            dtm = 2.0_DEFAULT_PRECISION * current_state%dtm
            
            call implicit_leapfrog_source(current_state, thl_thl_source, current_state%zca(i_thl_thl)%data(:,jcol, icol), &
              var_decay_rate, dtm, 2, current_state%local_grid%size(Z_INDEX),                       &
              current_state%sca(i_thl_thl)%data(:,jcol, icol))
              
            call implicit_leapfrog_source(current_state, qt_qt_source, current_state%zca(i_qt_qt)%data(:,jcol, icol), &
              var_decay_rate, dtm, 2, current_state%local_grid%size(Z_INDEX),                       &
              current_state%sca(i_qt_qt)%data(:,jcol, icol))
              
            call implicit_leapfrog_source(current_state, thl_qt_source, current_state%zca(i_thl_qt)%data(:,jcol, icol), &
              var_decay_rate, dtm, 2, current_state%local_grid%size(Z_INDEX),                       &
              current_state%sca(i_thl_qt)%data(:,jcol, icol))
              
          end if  

          if (allocated(thl2_prod_diag)) thl2_prod_diag(:, target_y_index, target_x_index) = thl_thl_source(:)                              
          if (allocated(qt2_prod_diag)) qt2_prod_diag(:, target_y_index, target_x_index) = qt_qt_source(:)                              
          if (allocated(thlqt_prod_diag)) thlqt_prod_diag(:, target_y_index, target_x_index) = thl_qt_source(:)                              
          
!        else
              
!          call log_master_log(LOG_ERROR, "Circle_A cloud variances needs option.")
          
        end if
                                             
      end if ! .not. current_state%use_viscosity_and_diffusion
    end if ! .not. current_state%halo_column

    ! ========================= End of timestepping section =======================  
            
    !   Swap here as no longer swapping in smagorinsky.
    if (current_state%last_timestep_column) then
      call log_master_log(LOG_DEBUG, "Circle-A halo swap.")

      ! need to ensure not already in progress
      call initiate_nonblocking_halo_swap(current_state, current_state%diffusion_halo_swap_state, &
           copy_diff_to_halo_buffer, copy_diff_corners_to_halo_buffer)
      call initiate_nonblocking_halo_swap(current_state, current_state%viscosity_halo_swap_state, &
           copy_vis_to_halo_buffer, copy_vis_corners_to_halo_buffer)
    end if
 
  end subroutine timestep_callback
  
  !> Timestep callback hook which will calculate the buyancy coefficients
  !> on theta (zn) levels.
  !! @param current_state The current model state
  subroutine buoyancy_ceoff(current_state,                                     & 
                            sThl_Thl, sqt_qt, sThl_qt, th, qv, qc,             & 
                            beta_t, beta_q)
                            
    type(model_state_type), target, intent(inout) :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:), intent(inout) :: sThl_Thl,     &
                        sqt_qt, sThl_qt, th, qv, qc   
    real(kind=DEFAULT_PRECISION), dimension(:), intent(out) :: beta_t, beta_q
   
    real(DEFAULT_PRECISION), parameter :: min_sigma_s=1e-7

    real(DEFAULT_PRECISION) :: TdegK   ! Temperature in Kelvin
    real(DEFAULT_PRECISION) :: Pmb     ! Pressure in mb
    real(DEFAULT_PRECISION) :: exner   ! Exner pressure
    real(DEFAULT_PRECISION) :: one_over_exner ! Reciprocal of Exner pressure
    real(DEFAULT_PRECISION) :: qt      ! qv+qc
    real(DEFAULT_PRECISION) :: Qcr ! resolved cloud mass mixing ratio based on super saturation
    real(DEFAULT_PRECISION) :: qs      ! Saturation mixing ratio
    real(DEFAULT_PRECISION) :: dqsdT   ! Rate of change of qs with temperature
    real(DEFAULT_PRECISION) :: pref
    real(DEFAULT_PRECISION) :: Thref
    real(DEFAULT_PRECISION) :: Tref
    real(DEFAULT_PRECISION) :: Thl
    real(DEFAULT_PRECISION) :: sigma_s !Standard deviation of s (subgrid liquid water content)
    real(DEFAULT_PRECISION) :: clfr    !Cloud fraction
    real(DEFAULT_PRECISION) :: qcl     !Cloud liquid water based on Gaussian scheme 
    real(DEFAULT_PRECISION) :: beta_c, alpha_L,a_L,delta_q,ap,sigma_sq,qn,qfact
    real(DEFAULT_PRECISION) :: eps
    
    integer :: k

    eps = 1.0/ratio_mol_wts
    
    do k=2, current_state%local_grid%size(Z_INDEX) 

      pref = current_state%global_grid%configuration%vertical%prefn(k)
      Thref = current_state%global_grid%configuration%vertical%thref(k)
      Tref = current_state%global_grid%configuration%vertical%tref(k)

      exner = current_state%global_grid%configuration%vertical%rprefrcp(k)
      one_over_exner = current_state%global_grid%configuration%vertical%prefrcp(k)
      
      Pmb   = pref/100. 
      
      !Calculation of liquid water temperature, taken from smagorinsky.F90
      Thl = th(k) + Thref - rlvap_over_cp * qc(k) * one_over_exner

      qt = qv(k) + qc(k)
      
      TdegK = Thl * exner  
       
      qs = qsaturation(TdegK, Pmb)

      alpha_L = dqwsatdt(qs, Tref) 

      a_L = 1.0/(1.0 + rlvap_over_cp * alpha_L)

      delta_q = qt - qs

      Qcr = delta_q * a_L

      ap = alpha_L * exner
      
      sigma_sq = sqt_qt(k)-2.0*sThl_qt(k)*ap+sThl_Thl(k)*ap*ap
      sigma_s = sqrt(sigma_sq) * a_L
             
      if (gtype .eq. "simple" .or. sigma_s .lt. min_sigma_s) then
        
        if (delta_q > 0.0) then   
          clfr = 1.0
          beta_c = a_L * ( rlvap_over_cp / Tref - 1.0 / eps)
          beta_t(k) = G * (1.0 / Thref - ap * beta_c)
          beta_q(k) = G * (c_virtual + beta_c)
        else
          clfr = 0.0
          beta_c = 0.0
          beta_t(k) = G / Thref
          beta_q(k) = G * c_virtual      
        endif  
            
      else

        qn = Qcr/sigma_s
      
        qfact = exp(-qn*qn/2.0) / sqrt(2.0*pi)
      
        clfr = MAX (0., 0.5 * (1.0 - erf(-qn/sqrt(2.0))) )
        
        qcl = MAX (0., (clfr * qn + qfact) )
        
        clfr = MAX (0., clfr - qcl * qfact)

        beta_c = clfr * a_L * ( rlvap_over_cp / Tref - 1 / eps)
        beta_t(k) = G * (1.0 / Thref - ap * beta_c)
        beta_q(k) = G * (c_virtual + beta_c)
        
      endif
      
    end do
    
    beta_t(1) = beta_t(2)
    beta_q(1) = beta_q(2)
    
    return
  end subroutine buoyancy_ceoff  

  
  !> set prognostic tke source strength
  subroutine set_tke_source(current_state,                                     & 
                           ssq, grad_thl, grad_qt, strain_rate,                &
                           beta_t, beta_q,                                     &
                           shear_prod, buoyant_prod, tke_source)
    type(model_state_type), target, intent(inout) :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:), intent(inout) :: ssq
    real(kind=DEFAULT_PRECISION), dimension(:, :), intent(inout):: grad_thl, grad_qt
    real(kind=DEFAULT_PRECISION), dimension(6, current_state%local_grid%size(Z_INDEX)), intent(inout) :: strain_rate
    real(kind=DEFAULT_PRECISION), dimension(:), intent(inout) :: beta_t, beta_q
    real(kind=DEFAULT_PRECISION), dimension(:), intent(out) :: shear_prod, buoyant_prod, tke_source

    ! Local Variables
    integer :: icol, jcol ! Shorthand column indices
    integer :: k
    real(kind=DEFAULT_PRECISION) :: buoy_cofS1, buoy_cofS2, tke
    
    buoy_cofS1 = G/current_state%global_grid%configuration%vertical%thref(1)
    buoy_cofS2 = G/current_state%global_grid%configuration%vertical%thref(2)

    icol=current_state%column_local_x
    jcol=current_state%column_local_y

    k = current_state%local_grid%size(Z_INDEX)
    shear_prod(k) = 0.0_DEFAULT_PRECISION
    buoyant_prod(k) = 0.0_DEFAULT_PRECISION
    
!      s(1, k) = 2.0_DEFAULT_PRECISION * dui_by_dxj(1, 1, k)   
!      s(2, k) = dui_by_dxj(1, 2, k) + dui_by_dxj(2, 1, k)   
!      s(3, k) = dui_by_dxj(1, 3, k) + dui_by_dxj(3, 1, k)   
!      s(4, k) = 2.0_DEFAULT_PRECISION * dui_by_dxj(2, 2, k)   
!      s(5, k) = dui_by_dxj(2, 3, k) + dui_by_dxj(3, 2, k)   
!      s(6, k) = 2.0_DEFAULT_PRECISION * dui_by_dxj(3, 3, k)   

    if (use_total_fluxes) then

      do k=2, current_state%local_grid%size(Z_INDEX)-1 
      
         tke = 0.5 * ( current_state%ca(i_tke)%data(k, jcol, icol) &
                     + current_state%ca(i_tke)%data(k+1, jcol, icol) )
                     
         ! Shear production is 0.5 tau^d_ij S_ij but off-diagonal terms are 
         ! symmetric so tau^d_ij S_ij = tau^d_ji S_ji. Thus, we just calculate 
         ! upper (or lower) triangle and the factor of 2 cancels.             
      
         shear_prod(k) =  -1.0 * (                                             &
                   0.5 * (current_state%ca(i_uu)%data(k, jcol, icol)           &
                                 - two_thirds * tke)                           &
                              * strain_rate(1, k)                              &
                        + current_state%ca(i_uv)%data(k, jcol, icol)           &
                              * strain_rate(2, k)                              &
                        + current_state%ca(i_uw)%data(k, jcol, icol)           &
                              * strain_rate(3, k)                              &
                 + 0.5 * (current_state%ca(i_vv)%data(k, jcol, icol)           &
                                 - two_thirds * tke)                           &
                              * strain_rate(4, k)                              &
                        + current_state%ca(i_vw)%data(k, jcol, icol)           & 
                              * strain_rate(5, k)                              &                           
                 + 0.5 * (current_state%ca(i_ww)%data(k, jcol, icol)           &
                                 - two_thirds * tke)                           &
                              * strain_rate(6, k) )
         
!         buoyant_prod(k) = -current_state%diff_coefficient%data(k,jcol, icol)  &
!                           * ssq(k) * richardson_number(k)
         ! On w-grid                  
         buoyant_prod(k) = 0.5 * (beta_t(k) + beta_t(k+1))                     &
                         * current_state%ca(i_w_thl)%data(k, jcol, icol)       &
                         + 0.5 * (beta_q(k) + beta_q(k+1))                     &
                         * current_state%ca(i_w_qt)%data(k, jcol, icol)
                                
      end do

    
    else
    
      do k=2, current_state%local_grid%size(Z_INDEX)-1 
      
         shear_prod(k) = (current_state%vis_coefficient%data(k,jcol, icol) * ssq(k)) 
         
         buoyant_prod(k) = -current_state%diff_coefficient%data(k,jcol, icol)  &
                          * (0.5 * (beta_t(k) + beta_t(k+1)) * grad_thl(3,k)   &
                           + 0.5 * (beta_q(k) + beta_q(k+1)) * grad_qt(3,k))     
         
!         buoyant_prod(k) = -current_state%diff_coefficient%data(k,jcol, icol) &
!                           * ssq(k) * richardson_number(k)
                                
      end do
    
    end if
    
! Need to use right time level data at surface
    if (current_state%field_stepping == FORWARD_STEPPING) then
    
! u*
      shear_prod(1) = sqrt(current_state%vis_coefficient%data(1,jcol, icol)     &
                       * sqrt((current_state%zu%data(2, jcol, icol) * current_state%zu%data(2, jcol, icol) )   &
                            + (current_state%zv%data(2, jcol, icol) * current_state%zv%data(2, jcol, icol) ) ) &
                       / current_state%global_grid%configuration%vertical%zn(2) )
         
      shear_prod(1) = shear_prod(1)**3 / (von_karman_constant * current_state%global_grid%configuration%vertical%zn(2))
         
      buoyant_prod(1) = -1.0_DEFAULT_PRECISION * current_state%diff_coefficient%data(1,jcol,icol)   &
                     * current_state%global_grid%configuration%vertical%rdzn(2)                     &
                     *( buoy_cofS2 * (current_state%zth%data(2,jcol,icol)                           & 
                                    + current_state%global_grid%configuration%vertical%thref(2)     & 
                                    + current_state%global_grid%configuration%vertical%thref(2)     & 
                                    * (c_virtual * current_state%zq(1)%data(2,jcol,icol)            & 
                                       - current_state%zq(2)%data(2,jcol,icol) ) )                  &
                      - buoy_cofS1 * (current_state%zth%data(1,jcol,icol)                           & 
                                    + current_state%global_grid%configuration%vertical%thref(1)     & 
                                    + current_state%global_grid%configuration%vertical%thref(1)     & 
                                    * (c_virtual * current_state%zq(1)%data(1,jcol,icol)            & 
                                       - current_state%zq(2)%data(1,jcol,icol) ) ) )
      
    else 

! u*
      shear_prod(1) = sqrt(current_state%vis_coefficient%data(1,jcol, icol)     &
                       * sqrt((current_state%u%data(2, jcol, icol) * current_state%u%data(2, jcol, icol) )   &
                            + (current_state%v%data(2, jcol, icol) * current_state%v%data(2, jcol, icol) ) ) &
                       / current_state%global_grid%configuration%vertical%zn(2) )
         
      shear_prod(1) = shear_prod(1)**3 / (von_karman_constant * current_state%global_grid%configuration%vertical%zn(2))

      buoyant_prod(1) = -1.0_DEFAULT_PRECISION * current_state%diff_coefficient%data(1,jcol,icol)   &
                     * current_state%global_grid%configuration%vertical%rdzn(2)                     &
                     *( buoy_cofS2 * (current_state%th%data(2,jcol,icol)                            & 
                                    + current_state%global_grid%configuration%vertical%thref(2)     & 
                                    + current_state%global_grid%configuration%vertical%thref(2)     & 
                                    * (c_virtual * current_state%q(1)%data(2,jcol,icol)             & 
                                       - current_state%q(2)%data(2,jcol,icol) ) )                   &
                      - buoy_cofS1 * (current_state%zth%data(1,jcol,icol)                           & 
                                    + current_state%global_grid%configuration%vertical%thref(1)     & 
                                    + current_state%global_grid%configuration%vertical%thref(1)     & 
                                    * (c_virtual * current_state%q(1)%data(1,jcol,icol)             & 
                                       - current_state%q(2)%data(1,jcol,icol) ) ) )

    
    end if

    ! Calculations were on w grid - now average to p grid.
    do k=current_state%local_grid%size(Z_INDEX),2,-1 
      shear_prod(k) = 0.5_DEFAULT_PRECISION * (shear_prod(k) + shear_prod(k-1))
      buoyant_prod(k) = 0.5_DEFAULT_PRECISION * (buoyant_prod(k) + buoyant_prod(k-1))
      tke_source(k) = shear_prod(k) + buoyant_prod(k) 
    end do

    shear_prod(1) = shear_prod(2)
    buoyant_prod(1) = buoyant_prod(2)  
    tke_source(1) = shear_prod(1) + buoyant_prod(1)
    
    return
    
  end subroutine set_tke_source 
  
  !> set prognostic tke decay rate
  subroutine set_tke_decay_rate(current_state, tke_decay_rate)
    type(model_state_type), intent(inout), target :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:), intent(out) :: tke_decay_rate
    ! Local Variables
    real(kind=DEFAULT_PRECISION) :: mixing_length
    integer :: icol, jcol ! Shorthand column indices
    integer :: k

    icol=current_state%column_local_x
    jcol=current_state%column_local_y
    
    do k = 2, current_state%local_grid%size(Z_INDEX) - 1
    
      mixing_length = sqrt( 1.0_DEFAULT_PRECISION                                              &
                         / (1.0_DEFAULT_PRECISION / (von_karman_constant                       &
                            * (current_state%global_grid%configuration%vertical%zn(k)+z0))**2  &
                          + 1.0_DEFAULT_PRECISION / current_state%rmlmax**2) )

      tke_decay_rate(k) = 2.0_DEFAULT_PRECISION * sqrt(2.0_DEFAULT_PRECISION * current_state%ca(i_tke)%data(k,jcol, icol)) &
                          / (b1 * mixing_length)
    
    end do
  
    return
    
  end subroutine set_tke_decay_rate

  !> set diagnostic tke 
  subroutine set_smag_tke(current_state, ssq, richardson_number, fm, fh, smag_tke)
    type(model_state_type), intent(inout), target :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:), intent(inout) :: ssq, richardson_number, fm, fh
    real(kind=DEFAULT_PRECISION), dimension(:), intent(out) :: smag_tke

    ! Local Variables
    real(kind=DEFAULT_PRECISION) :: Pr, one_minus_rbypr
    integer :: icol, jcol ! Shorthand column indices
    integer :: k

    icol=current_state%column_local_x
    jcol=current_state%column_local_y
    
    do k = 2, current_state%local_grid%size(Z_INDEX) - 1

      smag_tke(k) = mintke
    
      if (fh(k) > smallp) then
    
        Pr = fm(k) / fh(k) 
        one_minus_rbypr = (1.0_DEFAULT_PRECISION - richardson_number(k) / Pr)
        if (one_minus_rbypr > 0.0_DEFAULT_PRECISION) then 
     
          smag_tke(k) = max( mintke, current_state%global_grid%configuration%vertical%rneutml_sq(k) * ssq(k)  &
                                     * (smag_d * fm(k) * one_minus_rbypr)**two_thirds)
                         
        end if
        
      end if
    
    end do
    
    smag_tke(1) = smag_tke(2)
    smag_tke(current_state%local_grid%size(Z_INDEX)) = 0.0_DEFAULT_PRECISION
  
    return
    
  end subroutine set_smag_tke

  subroutine set_visc_diff_from_tke(current_state, richardson_number, fm, fh)  
    type(model_state_type), intent(inout), target :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:), intent(in)  :: richardson_number, fm, fh
    integer :: icol, jcol ! Shorthand column indices
    integer :: k
    real(kind=DEFAULT_PRECISION) :: Pr, tke, one_minus_rbypr

    icol=current_state%column_local_x
    jcol=current_state%column_local_y
  
    do k=2, current_state%local_grid%size(Z_INDEX)-1 
    
      if (fh(k) > smallp) then
    
        Pr = fm(k) / fh(k)
        one_minus_rbypr = (1.0_DEFAULT_PRECISION - richardson_number(k) / Pr)
        
        if (one_minus_rbypr > smallp) then 
          ! viscosity and diffusivity on w levels, tke on theta.
          tke = 0.5_DEFAULT_PRECISION * (current_state%ca(i_tke)%data(k,jcol, icol) + current_state%ca(i_tke)%data(k+1,jcol, icol))
       
          current_state%vis_coefficient%data(k,jcol, icol)  = visc_const * fm(k)**two_thirds / one_minus_rbypr**one_third &
                                       * sqrt(current_state%global_grid%configuration%vertical%rneutml_sq(k) * tke)
       
          current_state%diff_coefficient%data(k,jcol, icol) = current_state%vis_coefficient%data(k,jcol, icol) / Pr
                        
        end if
        
      else
      
        current_state%vis_coefficient%data(k,jcol, icol)  = smallp
        current_state%diff_coefficient%data(k,jcol, icol)  = smallp
        
      end if
                              
    end do
 
  end subroutine set_visc_diff_from_tke
  
  !> Calculates dui_by_dxj on w-points. 
  !! CX=1./DX, CY=1./DY, RDZ(K)=1./DZ(K), RDZN(K) =1./DZN(K)
  !! @param current_state The current model state
  !! @returns The hard squared strain rate for a specific column
  subroutine get_dui_by_dxj(current_state, u, v, w, dui_by_dxj)
    type(model_state_type), target, intent(inout) :: current_state
    type(prognostic_field_type), intent(inout) :: u, v, w
    real(kind=DEFAULT_PRECISION), intent(out) :: dui_by_dxj(:, :, :)

    integer :: icol, jcol ! Shorthand column indices
    integer :: k, nz
    real(kind=DEFAULT_PRECISION) :: rdx, rdy
        
    icol=current_state%column_local_x
    jcol=current_state%column_local_y
    
    nz = current_state%local_grid%size(Z_INDEX)
    
    rdx = current_state%global_grid%configuration%horizontal%cx
    rdy = current_state%global_grid%configuration%horizontal%cy

    do k=2,nz-1   
#ifdef U_ACTIVE    
      dui_by_dxj(1, 1, k) = 0.5_DEFAULT_PRECISION * rdx &
           * ( (u%data(k+1, jcol, icol) &
              - u%data(k+1, jcol, icol-1))&
             + (u%data(k, jcol, icol)&
              - u%data(k, jcol, icol-1)) )
          
      dui_by_dxj(1, 2, k) = 0.125_DEFAULT_PRECISION * rdy &
            * ( (u%data(k, jcol, icol-1) &
               - u%data(k, jcol-1, icol-1)) &
              + (u%data(k, jcol+1, icol-1) &
               - u%data(k, jcol, icol-1)) &
              + (u%data(k, jcol, icol) &
               - u%data(k, jcol-1, icol)) &
              + (u%data(k, jcol+1, icol) &
               - u%data(k, jcol, icol)) &
              + (u%data(k+1, jcol, icol-1) &
               - u%data(k+1, jcol-1, icol-1)) &
              + (u%data(k+1, jcol+1, icol-1) &
               - u%data(k+1, jcol, icol-1)) &
              + (u%data(k+1, jcol, icol) &
               - u%data(k+1, jcol-1, icol)) &
              + (u%data(k+1, jcol+1, icol) &
               - u%data(k+1, jcol, icol)) ) 
                 
      dui_by_dxj(1, 3, k) = 0.5_DEFAULT_PRECISION &
            * ( (u%data(k+1, jcol, icol) &
               - u%data(k, jcol, icol)) &
                 * current_state%global_grid%configuration%vertical%rdzn(k+1) &
              + (u%data(k+1, jcol, icol-1) &
               - u%data(k, jcol, icol-1))&
               * current_state%global_grid%configuration%vertical%rdzn(k+1) )
#else
      dui_by_dxj(1, 1, k) ==0.0_DEFAULT_PRECISION
      dui_by_dxj(1, 2, k) ==0.0_DEFAULT_PRECISION
      dui_by_dxj(1, 3, k) ==0.0_DEFAULT_PRECISION
#endif
#ifdef V_ACTIVE
      dui_by_dxj(2, 1, k) = 0.125_DEFAULT_PRECISION * rdx &
            * ( (v%data(k, jcol-1, icol) &
               - v%data(k, jcol-1, icol-1)) &
              + (v%data(k, jcol, icol) &
               - v%data(k, jcol, icol-1)) &
              + (v%data(k, jcol-1, icol+1) &
               - v%data(k, jcol-1, icol)) &
              + (v%data(k, jcol, icol+1) &
               - v%data(k, jcol, icol)) &
              + (v%data(k+1, jcol-1, icol) &
               - v%data(k+1, jcol-1, icol-1)) &
              + (v%data(k+1, jcol, icol) &
               - v%data(k+1, jcol, icol-1)) &
              + (v%data(k+1, jcol-1, icol+1) &
               - v%data(k+1, jcol-1, icol)) &
              + (v%data(k+1, jcol, icol+1) &
               - v%data(k+1, jcol, icol)) ) 
                
      dui_by_dxj(2, 2, k) = 0.5_DEFAULT_PRECISION * rdy &
            * ( (v%data(k+1, jcol, icol) &
                -v%data(k+1, jcol-1, icol)) &
              + (v%data(k, jcol, icol) &
                -v%data(k, jcol-1, icol)) )
           
      dui_by_dxj(2, 3, k) = 0.5_DEFAULT_PRECISION &
            * ( (v%data(k+1, jcol-1, icol) &
               - v%data(k, jcol-1, icol)) &
                 * current_state%global_grid%configuration%vertical%rdzn(k+1) &
              + (v%data(k+1, jcol, icol) &
               - v%data(k, jcol, icol)) &
                 * current_state%global_grid%configuration%vertical%rdzn(k+1) )
#else
      dui_by_dxj(2, 1, k) = 0.0_DEFAULT_PRECISION
      dui_by_dxj(2, 2, k) = 0.0_DEFAULT_PRECISION
      dui_by_dxj(2, 3, k) = 0.0_DEFAULT_PRECISION
#endif
#ifdef W_ACTIVE
      dui_by_dxj(3, 1, k) = 0.5_DEFAULT_PRECISION * rdx &
            * ( (w%data(k, jcol, icol+1) &
               - w%data(k, jcol, icol)) &
              + (w%data(k, jcol, icol) &
               - w%data(k, jcol, icol-1)) )
               
      dui_by_dxj(3, 2, k) = 0.5_DEFAULT_PRECISION  * rdy &
            * ( (w%data(k, jcol, icol) &
               - w%data(k, jcol-1, icol)) &
              + (w%data(k, jcol+1, icol) &
               - w%data(k, jcol, icol)) )
                              
      dui_by_dxj(3, 3, k) = 0.5_DEFAULT_PRECISION &
            * ( (w%data(k, jcol, icol) &
               - w%data(k-1, jcol, icol)) &
                 * current_state%global_grid%configuration%vertical%rdz(k) &
              + (w%data(k+1, jcol, icol) &
               - w%data(k, jcol, icol)) &
                 * current_state%global_grid%configuration%vertical%rdz(k+1) )
#else
      dui_by_dxj(3, 1, k) = 0.0_DEFAULT_PRECISION
      dui_by_dxj(3, 2, k) = 0.0_DEFAULT_PRECISION
      dui_by_dxj(3, 3, k) = 0.0_DEFAULT_PRECISION
#endif

    end do

    dui_by_dxj(:, :, 1) = 0.0_DEFAULT_PRECISION   
#if defined(U_ACTIVE)
    dui_by_dxj(1, 3, 1) = (current_state%u%data(2, jcol, icol)    &
                         + current_state%u%data(2, jcol, icol-1)) &
                         * 0.5_DEFAULT_PRECISION                  &
                        / current_state%global_grid%configuration%vertical%zn(2)
#endif
#if defined(V_ACTIVE)
    dui_by_dxj(2, 3, 1) = (current_state%v%data(2, jcol, icol)    &
                         + current_state%v%data(2, jcol-1, icol)) &
                         * 0.5_DEFAULT_PRECISION                  &
                        / current_state%global_grid%configuration%vertical%zn(2)  
#endif

    return
    
  end subroutine get_dui_by_dxj
  
  !> Calculates strain rate on l_w-points. 
  !! CX=1./DX, CY=1./DY, RDZ(K)=1./DZ(K), RDZN(K) =1./DZN(K)
  !! _SIJ= (DU_I/DX_J+DU_J/DX_I)
  !! @param current_state The current model state
  !! @returns The hard squared strain rate for a specific column
  subroutine get_strain_rate_from_dui_by_dxj(current_state, dui_by_dxj, s)
    type(model_state_type), target, intent(inout) :: current_state
    real(kind=DEFAULT_PRECISION), intent(inout) :: dui_by_dxj(:, :, :)
    real(kind=DEFAULT_PRECISION), intent(out) :: s(:, :)

    integer :: k, nz
            
    nz = current_state%local_grid%size(Z_INDEX)

    do k=2,nz-1
      s(1, k) = 2.0_DEFAULT_PRECISION * dui_by_dxj(1, 1, k)   
      s(2, k) = dui_by_dxj(1, 2, k) + dui_by_dxj(2, 1, k)   
      s(3, k) = dui_by_dxj(1, 3, k) + dui_by_dxj(3, 1, k)   
      s(4, k) = 2.0_DEFAULT_PRECISION * dui_by_dxj(2, 2, k)   
      s(5, k) = dui_by_dxj(2, 3, k) + dui_by_dxj(3, 2, k)   
      s(6, k) = 2.0_DEFAULT_PRECISION * dui_by_dxj(3, 3, k)   
    end do
    
    return
    
  end subroutine get_strain_rate_from_dui_by_dxj
  
  function get_ssq(current_state, strain_rate)
    type(model_state_type), target, intent(inout) :: current_state
    real(kind=DEFAULT_PRECISION), intent(inout) :: strain_rate(:, :)

    real(kind=DEFAULT_PRECISION) :: get_ssq(current_state%local_grid%size(Z_INDEX))
    real(kind=DEFAULT_PRECISION) :: ssq11, ssq22, ssq33, ssq13, ssq23, ssq12

    integer :: k
    do k=2,current_state%local_grid%size(Z_INDEX)-1 
      ssq11 = 0.5_DEFAULT_PRECISION * strain_rate(1, k) * strain_rate(1, k)
      ssq12 = strain_rate(2, k) * strain_rate(2, k)
      ssq13 = strain_rate(3, k) * strain_rate(3, k)
      ssq22 = 0.5_DEFAULT_PRECISION * strain_rate(4, k) * strain_rate(4, k)
      ssq23 = strain_rate(5, k) * strain_rate(5, k)
      ssq33 = 0.5_DEFAULT_PRECISION * strain_rate(6, k) * strain_rate(6, k)
      get_ssq(k)=ssq11+ssq22+ssq33+ssq13+ssq23+ssq12+smallp
    end do
    
    get_ssq(1) = get_ssq(2)
    get_ssq(current_state%local_grid%size(Z_INDEX)) = 0.0_DEFAULT_PRECISION
    
  end function get_ssq

      
  subroutine scalar_grad_on_w(current_state, field, grad_field)
    type(model_state_type), intent(inout), target :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:, :, :), intent(inout)  :: field
    real(kind=DEFAULT_PRECISION), dimension(:, :), intent(out)  :: grad_field
    
    real(kind=DEFAULT_PRECISION) :: dfdz, dfdx_k, dfdx_kp1,  dfdy_k, dfdy_kp1, dfdx, dfdy
    integer :: icol, jcol ! Shorthand column indices
    integer :: k, nz
        
    icol=current_state%column_local_x
    jcol=current_state%column_local_y
    
    nz = current_state%local_grid%size(Z_INDEX)
    
    do k=2,nz-1
                  
      dfdz     = ( field(k+1, jcol, icol)  - field(k, jcol, icol) ) &
                 * current_state%global_grid%configuration%vertical%rdzn(k+1)
      
      dfdx_k   = ( field(k, jcol, icol+1) - field(k, jcol, icol-1) ) &
                 * current_state%global_grid%configuration%horizontal%cx * 0.5_DEFAULT_PRECISION

      dfdx_kp1 = ( field(k+1, jcol, icol+1) - field(k+1, jcol, icol-1) ) &
                 * current_state%global_grid%configuration%horizontal%cx * 0.5_DEFAULT_PRECISION

      dfdy_k   = ( field(k, jcol+1, icol) - field(k, jcol-1, icol) ) &
                 * current_state%global_grid%configuration%horizontal%cy * 0.5_DEFAULT_PRECISION

      dfdy_kp1 = ( field(k+1, jcol+1, icol) - field(k+1, jcol-1, icol) ) &
                 * current_state%global_grid%configuration%horizontal%cy * 0.5_DEFAULT_PRECISION
                  
      dfdx     = ( dfdx_k + dfdx_kp1 ) * 0.5_DEFAULT_PRECISION

      dfdy     = ( dfdy_k + dfdy_kp1 ) * 0.5_DEFAULT_PRECISION
      
      grad_field(1, k) = dfdx
      grad_field(2, k) = dfdy
      grad_field(3, k) = dfdz
      
    end do 
     
  end subroutine scalar_grad_on_w
  
  !> Calculates gradient of theta_l and qt on w-points. 
  !! @param current_state The current model state
  !! @returns the gradient of theta_l and qt on w-points for a specific column
  subroutine get_grad_thl_qt(current_state, th, q, grad_thl, grad_qt)
    type(model_state_type), intent(inout), target :: current_state
    type(prognostic_field_type), intent(inout) :: th
    type(prognostic_field_type), dimension(:), intent(inout) :: q
    real(kind=DEFAULT_PRECISION), dimension(:, :), intent(inout):: grad_thl, grad_qt

    real(kind=DEFAULT_PRECISION) :: qt_k, qt_kp1, thl_k, thl_kp1
    real(kind=DEFAULT_PRECISION) :: dthldx, dqtdx, dthldy, dqtdy, dthldz, dqtdz    
    real(kind=DEFAULT_PRECISION) :: dqtdx_k, dqtdx_kp1, dqtdy_k, dqtdy_kp1
    real(kind=DEFAULT_PRECISION) :: dthdx_k, dthdx_kp1, dthdy_k, dthdy_kp1

    integer :: icol, jcol ! Shorthand column indices
    integer :: k, nz
        
    icol=current_state%column_local_x
    jcol=current_state%column_local_y
    
    nz = current_state%local_grid%size(Z_INDEX)
    
    do k=1,nz-1
                  
      qt_k =   q(iqv)%data(k, jcol, icol)   + q(iql)%data(k, jcol, icol)
      qt_kp1 = q(iqv)%data(k+1, jcol, icol) + q(iql)%data(k+1, jcol, icol)
      
      ! Note: prefrcp = (surface_reference_pressure/prefn(k))**r_over_cp = 1/Pi
      ! and rprefrcp = 1/prefrcp.
      ! This is confusing, as prefrcp is actually proportional to 1/ pref**r_over_cp and rprefrcp to pref**r_over_cp
      ! The following is thus th_l = th + thref - (L/cp) q_cl / Pi
             
      thl_k =   th%data(k, jcol, icol) + current_state%global_grid%configuration%vertical%thref(k) &
              - rlvap_over_cp*q(iql)%data(k, jcol, icol) &
                * current_state%global_grid%configuration%vertical%prefrcp(k)
      thl_kp1 = th%data(k+1, jcol, icol) + current_state%global_grid%configuration%vertical%thref(k+1) &
              - rlvap_over_cp*q(iql)%data(k+1, jcol, icol) &
                * current_state%global_grid%configuration%vertical%prefrcp(k+1)
                
      dthldz = (thl_kp1 - thl_k) * current_state%global_grid%configuration%vertical%rdzn(k+1)
      
      dqtdz =  (qt_kp1  - qt_k)  * current_state%global_grid%configuration%vertical%rdzn(k+1)

      dqtdx_k   = ( ( q(iqv)%data(k, jcol, icol+1) + q(iql)%data(k, jcol, icol+1) ) &
                  - ( q(iqv)%data(k, jcol, icol-1) + q(iql)%data(k, jcol, icol-1) ) &
                  ) * current_state%global_grid%configuration%horizontal%cx * 0.5_DEFAULT_PRECISION

      dqtdx_kp1 = ( ( q(iqv)%data(k+1, jcol, icol+1) + q(iql)%data(k+1, jcol, icol+1) ) &
                  - ( q(iqv)%data(k+1, jcol, icol-1) + q(iql)%data(k+1, jcol, icol-1) ) &
                  ) * current_state%global_grid%configuration%horizontal%cx * 0.5_DEFAULT_PRECISION

      dqtdy_k   = ( ( q(iqv)%data(k, jcol+1, icol) + q(iql)%data(k, jcol+1, icol) ) &
                  - ( q(iqv)%data(k, jcol-1, icol) + q(iql)%data(k, jcol-1, icol) ) &
                  ) * current_state%global_grid%configuration%horizontal%cy * 0.5_DEFAULT_PRECISION

      dqtdy_kp1 = ( ( q(iqv)%data(k+1, jcol+1, icol) + q(iql)%data(k+1, jcol+1, icol) ) &
                  - ( q(iqv)%data(k+1, jcol-1, icol) + q(iql)%data(k+1, jcol-1, icol) ) &
                  ) * current_state%global_grid%configuration%horizontal%cy * 0.5_DEFAULT_PRECISION
                  
      dqtdx     = ( dqtdx_k + dqtdx_kp1 ) * 0.5_DEFAULT_PRECISION

      dqtdy     = ( dqtdy_k + dqtdy_kp1 ) * 0.5_DEFAULT_PRECISION


      dthdx_k   = ( th%data(k, jcol, icol+1)   &
                  - th%data(k, jcol, icol-1)   &
                  ) * current_state%global_grid%configuration%horizontal%cx * 0.5_DEFAULT_PRECISION

      dthdx_kp1 = ( th%data(k+1, jcol, icol+1)   &
                  - th%data(k+1, jcol, icol-1)   &
                  ) * current_state%global_grid%configuration%horizontal%cx * 0.5_DEFAULT_PRECISION

      dthdy_k   = ( th%data(k, jcol+1, icol)   &
                  - th%data(k, jcol-1, icol)   &
                  ) * current_state%global_grid%configuration%horizontal%cy * 0.5_DEFAULT_PRECISION
      
      dthdy_kp1 = ( th%data(k+1, jcol+1, icol)   &
                  - th%data(k+1, jcol-1, icol)   &
                  ) * current_state%global_grid%configuration%horizontal%cy * 0.5_DEFAULT_PRECISION
                  
      dthldx = ( ( dthdx_k   - rlvap_over_cp * dqtdx_k   * current_state%global_grid%configuration%vertical%prefrcp(k) ) &
               + ( dthdx_kp1 - rlvap_over_cp * dqtdx_kp1 * current_state%global_grid%configuration%vertical%prefrcp(k+1) ) &
               ) * 0.5_DEFAULT_PRECISION

      dthldy = ( ( dthdy_k   - rlvap_over_cp * dqtdy_k   * current_state%global_grid%configuration%vertical%prefrcp(k) ) &
               + ( dthdy_kp1 - rlvap_over_cp * dqtdy_kp1 * current_state%global_grid%configuration%vertical%prefrcp(k+1) ) &
               ) * 0.5_DEFAULT_PRECISION
      
      grad_thl(1, k) = dthldx  
      grad_thl(2, k) = dthldy  
      grad_thl(3, k) = dthldz  
      grad_qt(1, k) = dqtdx      
      grad_qt(2, k) = dqtdy      
      grad_qt(3, k) = dqtdz
            
    end do

!    grad_thl(1, 1) = grad_thl(1, 2)  
!    grad_thl(2, 1) = grad_thl(2, 2)  
!    grad_thl(3, 1) = grad_thl(3, 2)  
!    grad_qt(1, 1) = grad_qt(1, 2)      
!    grad_qt(2, 1) = grad_qt(2, 2)      
!    grad_qt(3, 1) = grad_qt(3, 2)
    
  end subroutine get_grad_thl_qt
  
  !> Calculates scalar fluxes. 
  !! @param current_state The current model state
  !! @param grad_thl gradient of theta_l on w points
  !! @param grad_qt gradient of qt on w points
  !! @returns (u,v,w)_thl, (u,v,w)_qt on w-points
  subroutine get_scalar_fluxes(current_state, grad_thl, grad_qt, u_thl, v_thl, w_thl, u_qt, v_qt, w_qt)
    type(model_state_type), intent(inout), target :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:, :), intent(inout):: grad_thl, grad_qt
    type(prognostic_field_type), intent(inout) :: u_thl
    type(prognostic_field_type), intent(inout) :: v_thl
    type(prognostic_field_type), intent(inout) :: w_thl
    type(prognostic_field_type), intent(inout) :: u_qt
    type(prognostic_field_type), intent(inout) :: v_qt
    type(prognostic_field_type), intent(inout) :: w_qt
    
    real(kind=DEFAULT_PRECISION) :: dthldx, dqtdx, dthldy, dqtdy, dthldz, dqtdz    
    integer :: icol, jcol ! Shorthand column indices
    integer :: k, nz
        
    icol=current_state%column_local_x
    jcol=current_state%column_local_y
    
    nz = current_state%local_grid%size(Z_INDEX)
  
    do k=1,nz-1
      u_thl%data(k, jcol, icol) = -current_state%diff_coefficient%data(k,jcol, icol) * grad_thl(1, k)
      v_thl%data(k, jcol, icol) = -current_state%diff_coefficient%data(k,jcol, icol) * grad_thl(2, k)
      w_thl%data(k, jcol, icol) = -current_state%diff_coefficient%data(k,jcol, icol) * grad_thl(3, k)
      u_qt%data(k, jcol, icol)  = -current_state%diff_coefficient%data(k,jcol, icol) * grad_qt(1, k)
      v_qt%data(k, jcol, icol)  = -current_state%diff_coefficient%data(k,jcol, icol) * grad_qt(2, k)
      w_qt%data(k, jcol, icol)  = -current_state%diff_coefficient%data(k,jcol, icol) * grad_qt(3, k)
    end do
    
!    u_thl%data(1, jcol, icol) = u_thl%data(2, jcol, icol)
!    v_thl%data(1, jcol, icol) = v_thl%data(2, jcol, icol)
!    w_thl%data(1, jcol, icol) = w_thl%data(2, jcol, icol)
!    u_qt%data(1, jcol, icol)  = u_qt%data(2, jcol, icol)
!    v_qt%data(1, jcol, icol)  = v_qt%data(2, jcol, icol)
!    w_qt%data(1, jcol, icol)  = w_qt%data(2, jcol, icol)

    u_thl%data(nz, jcol, icol) = 0_DEFAULT_PRECISION
    v_thl%data(nz, jcol, icol) = 0_DEFAULT_PRECISION
    w_thl%data(nz, jcol, icol) = 0_DEFAULT_PRECISION
    u_qt%data(nz, jcol, icol)  = 0_DEFAULT_PRECISION
    v_qt%data(nz, jcol, icol)  = 0_DEFAULT_PRECISION
    w_qt%data(nz, jcol, icol)  = 0_DEFAULT_PRECISION

! Calculations were on w grid - now average to p grid.
    
!    do k=nz,2,-1 
!      u_thl%data(k, jcol, icol) = 0.5_DEFAULT_PRECISION * (u_thl%data(k, jcol, icol) + u_thl%data(k-1, jcol, icol))
!      v_thl%data(k, jcol, icol) = 0.5_DEFAULT_PRECISION * (v_thl%data(k, jcol, icol) + v_thl%data(k-1, jcol, icol))
!      w_thl%data(k, jcol, icol) = 0.5_DEFAULT_PRECISION * (w_thl%data(k, jcol, icol) + w_thl%data(k-1, jcol, icol))
!      u_qt%data(k, jcol, icol)   = 0.5_DEFAULT_PRECISION * (u_qt%data(k, jcol, icol) + u_qt%data(k-1, jcol, icol))
!      v_qt%data(k, jcol, icol)   = 0.5_DEFAULT_PRECISION * (v_qt%data(k, jcol, icol) + v_qt%data(k-1, jcol, icol))
!      w_qt%data(k, jcol, icol)   = 0.5_DEFAULT_PRECISION * (w_qt%data(k, jcol, icol) + w_qt%data(k-1, jcol, icol))
!    end do
    
  end subroutine get_scalar_fluxes

  !> Calculates momentum fluxes. 
  !! @param current_state The current model state
  !! @param strain_rate Shear on w points
  !! @returns uv, uw, vw on w-points
  subroutine get_momentum_fluxes(current_state, strain_rate, uv, uw, vw)
    type(model_state_type), intent(inout), target :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:, :), intent(inout) :: strain_rate
    type(prognostic_field_type), intent(inout) :: uv
    type(prognostic_field_type), intent(inout) :: uw
    type(prognostic_field_type), intent(inout) :: vw   
    
    integer :: icol, jcol ! Shorthand column indices
    integer :: k, nz
        
    icol=current_state%column_local_x
    jcol=current_state%column_local_y
    
    nz = current_state%local_grid%size(Z_INDEX)
      
    do k=2,nz-1
      
      uv%data(k, jcol, icol) = -current_state%vis_coefficient%data(k,jcol, icol) * strain_rate(2, k)
      uw%data(k, jcol, icol) = -current_state%vis_coefficient%data(k,jcol, icol) * strain_rate(3, k)
      vw%data(k, jcol, icol) = -current_state%vis_coefficient%data(k,jcol, icol) * strain_rate(5, k)
      
    end do
    
    uv%data(1, jcol, icol) = 0
    uw%data(1, jcol, icol) = - current_state%vis_coefficient%data(1,jcol, icol) &
                             * current_state%u%data(2, jcol, icol) &
                             / current_state%global_grid%configuration%vertical%zn(2)
    vw%data(1, jcol, icol) = - current_state%vis_coefficient%data(1,jcol, icol) &
                             * current_state%v%data(2, jcol, icol) &
                             / current_state%global_grid%configuration%vertical%zn(2)
    
    k = nz
    uv%data(k, jcol, icol) = -current_state%vis_coefficient%data(k,jcol, icol) * strain_rate(2, k)
    uw%data(k, jcol, icol) = -current_state%vis_coefficient%data(k,jcol, icol) * strain_rate(3, k)
    vw%data(k, jcol, icol) = -current_state%vis_coefficient%data(k,jcol, icol) * strain_rate(5, k)
    
! Calculations were on w grid - now average to p grid.
    
!    do k=nz,2,-1 
!      uv%data(k, jcol, icol) = 0.5_DEFAULT_PRECISION * (uv%data(k, jcol, icol) + uv%data(k-1, jcol, icol))
!      uw%data(k, jcol, icol) = 0.5_DEFAULT_PRECISION * (uw%data(k, jcol, icol) + uw%data(k-1, jcol, icol))
!      vw%data(k, jcol, icol) = 0.5_DEFAULT_PRECISION * (vw%data(k, jcol, icol) + vw%data(k-1, jcol, icol))
!    end do
    
    return
    
  end subroutine get_momentum_fluxes

  !> Calculates diagonal terms of stress tensor. 
  !! @param current_state The current model state
  !! @param s Shear on w points
  !! @param tke Prognostic o diagnostic TKE on p points
  !! @returns uu, vv, ww on w-points
  subroutine get_viscous_tke_components(current_state, tke, strain_rate, uu, vv, ww)
    type(model_state_type), intent(inout), target :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:), intent(inout) :: tke    
    real(kind=DEFAULT_PRECISION), dimension(:, :), intent(inout) :: strain_rate
    type(prognostic_field_type), intent(inout) :: uu
    type(prognostic_field_type), intent(inout) :: vv
    type(prognostic_field_type), intent(inout) :: ww   
    
    real(kind=DEFAULT_PRECISION) :: ut2, tke_surf
    
    integer :: icol, jcol ! Shorthand column indices
    integer :: k, nz
        
    icol=current_state%column_local_x
    jcol=current_state%column_local_y
    
    nz = current_state%local_grid%size(Z_INDEX)
      
    do k=2,nz-1
    
      ut2 = tke(k) + tke(k+1)
      
      uu%data(k, jcol, icol) = ut2 / 3.0 - current_state%vis_coefficient%data(k,jcol, icol) * strain_rate(1, k)
      vv%data(k, jcol, icol) = ut2 / 3.0 - current_state%vis_coefficient%data(k,jcol, icol) * strain_rate(4, k)
      ww%data(k, jcol, icol) = ut2 / 3.0 - current_state%vis_coefficient%data(k,jcol, icol) * strain_rate(6, k)
      
    end do
    
    ! Use equilibrium at surface to set sub-surface tke
    ! Need to use right time level data at surface
    if (current_state%field_stepping == FORWARD_STEPPING) then

      tke_surf = tke_coeff * &
        current_state%vis_coefficient%data(1,jcol, icol) * &
        (sqrt((current_state%zu%data(2, jcol, icol) * &
               current_state%zu%data(2, jcol, icol) ) + &
              (current_state%zv%data(2, jcol, icol) * &
               current_state%zv%data(2, jcol, icol) ) )  / &
         current_state%global_grid%configuration%vertical%zn(2) )

    else

      tke_surf = tke_coeff *&
        current_state%vis_coefficient%data(1,jcol, icol) * &
        (sqrt((current_state%u%data(2, jcol, icol) * &
               current_state%u%data(2, jcol, icol) ) + &
              (current_state%v%data(2, jcol, icol) * &
               current_state%v%data(2, jcol, icol) ) )  / &
         current_state%global_grid%configuration%vertical%zn(2) )
     
    end if   

    uu%data(1, jcol, icol) = 2.0 * tke_surf
    vv%data(1, jcol, icol) = 2.0 * tke_surf
    ww%data(1, jcol, icol) = 2.0 * tke_surf
    
    k = nz
    uu%data(k, jcol, icol) = 0.0
    vv%data(k, jcol, icol) = 0.0
    ww%data(k, jcol, icol) = 0.0
    
! Calculations were on w grid - now average to p grid.
    
!    do k=nz,2,-1 
!      uv%data(k, jcol, icol) = 0.5_DEFAULT_PRECISION * (uv%data(k, jcol, icol) + uv%data(k-1, jcol, icol))
!      uw%data(k, jcol, icol) = 0.5_DEFAULT_PRECISION * (uw%data(k, jcol, icol) + uw%data(k-1, jcol, icol))
!      vw%data(k, jcol, icol) = 0.5_DEFAULT_PRECISION * (vw%data(k, jcol, icol) + vw%data(k-1, jcol, icol))
!    end do
    
    return
    
  end subroutine get_viscous_tke_components

  !> Calculates diagonal terms of stress tensor. 
  !! @param current_state The current model state
  !! @param ssq Shear squared on w points
  !! @param richardson_number Richardson number on w points
  !! @param dui_by_dxj deformatin tensor
  !! @param s Shear on w points
  !! @param tke Prognostic o diagnostic TKE on p points
  !! @returns uv, uw, vw on w-points
  subroutine get_tke_components(current_state, ssq, richardson_number, dui_by_dxj, s, tke, uu, vv, ww)
    type(model_state_type), intent(inout), target :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:), intent(inout)  :: ssq, richardson_number
    real(kind=DEFAULT_PRECISION), dimension(:, :, :), intent(inout) :: dui_by_dxj
    real(kind=DEFAULT_PRECISION), dimension(:, :), intent(inout) :: s
    real(kind=DEFAULT_PRECISION), dimension(:), intent(inout) :: tke
    type(prognostic_field_type), intent(inout) :: uu
    type(prognostic_field_type), intent(inout) :: vv
    type(prognostic_field_type), intent(inout) :: ww
    
    
    real(kind=DEFAULT_PRECISION) :: const_1, const_2, const_3, const_4, coeff, ut2_tot
    real(kind=DEFAULT_PRECISION) :: mod_s_i, dbdz, mixing_length, ut, ut2
    real(kind=DEFAULT_PRECISION) :: reduction_factor, buoyancy_factor, correction_factor
    real(kind=DEFAULT_PRECISION), dimension(3) :: ut2_comp
    real(kind=DEFAULT_PRECISION), dimension(3,3) :: sexp
    integer :: icol, jcol ! Shorthand column indices
    integer :: kk, k, nz
        
    icol=current_state%column_local_x
    jcol=current_state%column_local_y
    
    nz = current_state%local_grid%size(Z_INDEX)
    
    const_1 = (1.0_DEFAULT_PRECISION - c4)
    const_2 = one_third * const_2 - c1 
    const_3 = (1.0_DEFAULT_PRECISION - c2)
    const_4 = 6.0_DEFAULT_PRECISION * a1
  
    do k=2,nz-1
    
      dbdz = richardson_number(k) * ssq(k)
      
      mixing_length = sqrt(current_state%global_grid%configuration%vertical%rneutml_sq(k))
      
      ut2 = tke(k) + tke(k+1)
      ut = sqrt(ut2)
      
      sexp(1,1) = s(1, k)
      sexp(1,2) = s(2, k)
      sexp(2,1) = s(2, k)
      sexp(1,3) = s(3, k)
      sexp(3,1) = s(3, k)
      sexp(2,2) = s(4, k)
      sexp(2,3) = s(5, k)
      sexp(3,2) = s(5, k)
      sexp(3,3) = s(6, k)
      
!      reduction_factor = min(1.0_DEFAULT_PRECISION, (tke(k) / smag_tke(k)) )
      reduction_factor = 1.0_DEFAULT_PRECISION
      
      coeff = const_4 * mixing_length / ut ! * reduction_factor
      
      buoyancy_factor = const_3 * current_state%vis_coefficient%data(k,jcol, icol) * dbdz
      
      mod_s_i = 0.0_DEFAULT_PRECISION
      do kk=1,3
        mod_s_i = mod_s_i + sexp(1, kk) * dui_by_dxj(1, kk, k)
      end do
      mod_s_i = const_1 * current_state%vis_coefficient%data(k,jcol, icol) * (mod_s_i - ssq(k) * one_third)
    
      ut2_comp(1) = min(ut2, max(0.0_DEFAULT_PRECISION, one_third * ut2 - coeff & 
                    * ( c1 * ut2 * dui_by_dxj(1, 1, k) - mod_s_i - buoyancy_factor * one_third ) ) )

      mod_s_i = 0.0_DEFAULT_PRECISION
      do kk=1,3
        mod_s_i = mod_s_i + sexp(2, kk) * dui_by_dxj(2, kk, k)
      end do
      mod_s_i = const_1 * current_state%vis_coefficient%data(k,jcol, icol) * (mod_s_i - ssq(k) * one_third)
      
      ut2_comp(2) = min(ut2, max(0.0_DEFAULT_PRECISION, one_third * ut2 - coeff & 
                    * ( c1 * ut2 * dui_by_dxj(2, 2, k) - mod_s_i - buoyancy_factor * one_third ) ) )

      mod_s_i = 0.0_DEFAULT_PRECISION
      do kk=1,3
        mod_s_i = mod_s_i + sexp(3, kk) * dui_by_dxj(3, kk, k)
      end do
      mod_s_i = const_1 * current_state%vis_coefficient%data(k,jcol, icol) * (mod_s_i - ssq(k) * one_third)
           
      ut2_comp(3) = min(ut2, max(0.0_DEFAULT_PRECISION, one_third * ut2 - coeff & 
                    * ( c1 * ut2 * dui_by_dxj(3, 3, k) - mod_s_i + buoyancy_factor * two_thirds ) ) )
                    
      ut2_tot = 0.0_DEFAULT_PRECISION      
      do kk=1,3
        ut2_tot = ut2_tot + ut2_comp(kk)
      end do
      
      if (ut2_tot > 0.0_DEFAULT_PRECISION) then
        correction_factor = ut2 / ut2_tot
        do kk=1,3
          ut2_comp(kk) = ut2_comp(kk) * correction_factor
        end do
      end if
                  
      uu%data(k, jcol, icol) = ut2_comp(1)
      vv%data(k, jcol, icol) = ut2_comp(2)
      ww%data(k, jcol, icol) = ut2_comp(3)
      
    end do
    
! Calculations were on w grid - now average to p grid.
    
!    do k=nz,2,-1 
!      uu%data(k, jcol, icol) = 0.5_DEFAULT_PRECISION * (uu%data(k, jcol, icol) + uu%data(k-1, jcol, icol))
!      vv%data(k, jcol, icol) = 0.5_DEFAULT_PRECISION * (vv%data(k, jcol, icol) + vv%data(k-1, jcol, icol))
!      ww%data(k, jcol, icol) = 0.5_DEFAULT_PRECISION * (ww%data(k, jcol, icol) + ww%data(k-1, jcol, icol))
!    end do
    
    return
    
  end subroutine get_tke_components

        
  subroutine get_cloud_variances(current_state, richardson_number, fm, fh, grad_thl, grad_qt, &
                                 mixing_length_param, r_Cth_env_ml, r_Cth_IC_ml, &
                                 thl_thl, qt_qt, thl_qt)
    type(model_state_type), intent(inout), target :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:), intent(inout)  :: richardson_number, fm, fh
    real(kind=DEFAULT_PRECISION), dimension(:, :), intent(inout):: grad_thl, grad_qt
    logical, intent(in) :: mixing_length_param
    real(kind=DEFAULT_PRECISION), dimension(:), intent(in) :: r_Cth_env_ml, r_Cth_IC_ml

    type(prognostic_field_type), intent(inout) :: thl_thl
    type(prognostic_field_type), intent(inout) :: qt_qt
    type(prognostic_field_type), intent(inout) :: thl_qt
    
    real(kind=DEFAULT_PRECISION) :: ml_sq_th
    real(kind=DEFAULT_PRECISION) :: denom,  coeff   
    real(kind=DEFAULT_PRECISION) :: dthldx, dqtdx, dthldy, dqtdy, dthldz, dqtdz    
    
!    real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX), &
!                                            current_state%local_grid%size(Y_INDEX), &
!                                            current_state%local_grid%size(Z_INDEX)) :: thl, qt
    integer :: icol, jcol ! Shorthand column indices
    integer :: k, nz
        
    icol=current_state%column_local_x
    jcol=current_state%column_local_y
    
    nz = current_state%local_grid%size(Z_INDEX)
              
!    do k=1,nz
!      thl(k) = th%data(k, jcol, icol) + current_state%global_grid%configuration%vertical%thref(k) &
!              - rlvap_over_cp*q(iql)%data(k, jcol, icol) &
!              * current_state%global_grid%configuration%vertical%prefrcp(k)
!      qt(k) = q(iqv)%data(k, jcol, icol)   + q(iql)%data(k, jcol, icol)
!    end do

!    call scalar_grad_on_w(current_state, th%data, grad_th)
!    call scalar_grad_on_w(current_state, q(iqv)%data, grad_qv)
!    call scalar_grad_on_w(current_state, q(iql)%data, grad_ql)

    
    do k=1,nz

      denom = fm(k) * (1.-suba * richardson_number(k))
        
      if (denom .gt. smallp) then 
      
        if (mixing_length_param) then
        
          ml_sq_th =r_Cth_env_ml(k) * r_Cth_env_ml(k)
      
          if (.not. current_state%passive_q .and. current_state%number_q_fields .gt. 0) then          
            if (current_state%q(iql)%data(k, jcol, icol) .gt. 1.0E-6) then
		          ml_sq_th = r_Cth_IC_ml(k) * r_Cth_IC_ml(k)
  		      end if  		    
	        end if

          coeff = ca_var_const * fh(k) * ml_sq_th / denom**(1.0/3.0)
        
        else
                
          coeff = ca_var_const * fh(k) * current_state%global_grid%configuration%vertical%rneutml_sq(k) / denom**(1.0/3.0)
          
        end if
             
        dthldx = grad_thl(1, k)
        dthldy = grad_thl(2, k)
        dthldz = grad_thl(3, k)
        
        dqtdx = grad_qt(1, k)
        dqtdy = grad_qt(2, k)
        dqtdz = grad_qt(3, k)
              
        thl_thl%data(k, jcol, icol) = coeff * (dthldx * dthldx + dthldy * dthldy + dthldz * dthldz)
        qt_qt%data(k, jcol, icol)   = coeff * (dqtdx * dqtdx + dqtdy * dqtdy + dqtdz * dqtdz)
        thl_qt%data(k, jcol, icol)  = coeff * (dthldx * dqtdx +  dthldy * dqtdy + dthldz * dqtdz)

      else

        thl_thl%data(k, jcol, icol) = 0.0_DEFAULT_PRECISION
        qt_qt%data(k, jcol, icol)   = 0.0_DEFAULT_PRECISION
        thl_qt%data(k, jcol, icol)  = 0.0_DEFAULT_PRECISION

      endif
            
    end do
    
!    thl_thl%data(1, jcol, icol) = thl_thl%data(2, jcol, icol)
!    qt_qt%data(1, jcol, icol) =   qt_qt%data(2, jcol, icol)
!    thl_qt%data(1, jcol, icol) =  thl_qt%data(2, jcol, icol)

!    thl_thl%data(nz, jcol, icol) = thl_thl%data(nz-1, jcol, icol)
!    qt_qt%data(nz, jcol, icol) =   qt_qt%data(nz-1, jcol, icol)
!    thl_qt%data(nz, jcol, icol) =  thl_qt%data(nz-1, jcol, icol)
    
! Calculations were on w grid - now average to p grid.
    
    do k=nz,2,-1 
      thl_thl%data(k, jcol, icol) = 0.5_DEFAULT_PRECISION * (thl_thl%data(k, jcol, icol) + thl_thl%data(k-1, jcol, icol))
      qt_qt%data(k, jcol, icol)   = 0.5_DEFAULT_PRECISION * (qt_qt%data(k, jcol, icol)   + qt_qt%data(k-1, jcol, icol))
      thl_qt%data(k, jcol, icol)  = 0.5_DEFAULT_PRECISION * (thl_qt%data(k, jcol, icol)  + thl_qt%data(k-1, jcol, icol))
    end do
            
  end subroutine get_cloud_variances
  
  subroutine get_variance_source(current_state, ica_1, ica_2,  grad_v1, grad_v2, v1v2_source)
    type(model_state_type), intent(inout), target :: current_state
    integer, intent(inout):: ica_1, ica_2
    real(kind=DEFAULT_PRECISION), dimension(:, :), intent(inout):: grad_v1, grad_v2
    real(kind=DEFAULT_PRECISION), dimension(:), intent(out):: v1v2_source

    integer :: icol, jcol ! Shorthand column indices
    integer :: ii, k, nz
        
    icol=current_state%column_local_x
    jcol=current_state%column_local_y
    
    nz = current_state%local_grid%size(Z_INDEX)
    
    if (use_total_fluxes) then

      do k=1,nz
      
        v1v2_source(k) = 0.0_DEFAULT_PRECISION
        do ii = 1,3
          v1v2_source(k) = v1v2_source(k) &
                 - current_state%ca(ica_1 + ii - 1)%data(k, jcol, icol) * grad_v2(ii, k) &
                 - current_state%ca(ica_2 + ii - 1)%data(k, jcol, icol) * grad_v1(ii, k)
        end do
               
      end do

    else  
        
      do k=1,nz
      
        v1v2_source(k) = 0.0_DEFAULT_PRECISION
        do ii = 1,3
          v1v2_source(k) = v1v2_source(k) + grad_v1(ii, k) * grad_v2(ii, k) 
        end do

        v1v2_source(k) = v1v2_source(k) * 2.0_DEFAULT_PRECISION &
                       * current_state%diff_coefficient%data(k,jcol, icol)
        
      end do
      
    end if
    
    call array_on_z_to_zn(nz, v1v2_source, v1v2_source) 
 
  end subroutine get_variance_source
  
  !> Calculates an equivalent leapfrog source term for a given forcing and decay rate.
  !! @param 
  !! @param 
  !! @param 
  subroutine implicit_leapfrog_source(current_state, local_source, prev_value, decay_rate, dtm, k_start, k_end, leapfrog_source)
    type(model_state_type), intent(inout), target :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:), intent(in) :: local_source, decay_rate
    real(kind=DEFAULT_PRECISION), intent(in) :: dtm
    integer, intent(in) :: k_start, k_end
    real(kind=DEFAULT_PRECISION), dimension(:), intent(inout) :: prev_value, leapfrog_source
        
    integer :: k
    
    do k = k_start, k_end
      leapfrog_source(k) = leapfrog_source(k) + (local_source(k) - prev_value(k) * decay_rate(k)) &
                                                 / (1.0_DEFAULT_PRECISION + decay_rate(k) * dtm)
    end do
  end subroutine implicit_leapfrog_source
  
  subroutine array_on_z_to_zn(nz, array_in, array_out)
    integer, intent(in) :: nz
    real(kind=DEFAULT_PRECISION), dimension(:), intent(inout) :: array_in
    real(kind=DEFAULT_PRECISION), dimension(:), intent(out) :: array_out
    integer :: k
    do k=nz,2,-1 
      array_out(k) = 0.5_DEFAULT_PRECISION * (array_in(k) + array_in(k-1))
    end do
    
  end subroutine array_on_z_to_zn  

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
end module circle_a_mod
