!s> Calculates the Smagorinsky eddy viscosity and diffusivity at l_w-points
module smagorinsky_mod
  use datadefn_mod, only : DEFAULT_PRECISION
  use monc_component_mod, only : component_descriptor_type, &
       component_field_value_type, component_field_information_type, &
       COMPONENT_ARRAY_FIELD_TYPE, COMPONENT_DOUBLE_DATA_TYPE
  use state_mod, only : FORWARD_STEPPING, model_state_type
  use grids_mod, only : vertical_grid_configuration_type, X_INDEX, Y_INDEX, Z_INDEX
  use optionsdatabase_mod, only : options_get_real, options_get_real, options_get_integer, options_get_logical
  use prognostics_mod, only : prognostic_field_type
  use science_constants_mod, only : von_karman_constant, z0, smallp, rlvap_over_cp, ratio_mol_wts, G, cp
  use communication_types_mod, only : halo_communication_type, neighbour_description_type, field_data_wrapper_type
  use halo_communication_mod, only : copy_field_to_buffer, init_halo_communication, finalise_halo_communication, &
       initiate_nonblocking_halo_swap, get_single_field_per_halo_cell, copy_corner_to_buffer
  use registry_mod, only : is_component_enabled
  use logging_mod, only : LOG_DEBUG, LOG_ERROR, LOG_INFO, log_master_log
  use q_indices_mod, only: get_q_index, standard_q_names
  use saturation_mod, only: qsaturation, dqwsatdt
  implicit none

#ifndef TEST_MODE
  private
#endif

  logical :: circle_a_enabled
  integer, parameter :: RICHARDSON_NUMBER_CALCULATION=2
  real(kind=DEFAULT_PRECISION) :: eps, repsh, thcona, thconb, thconap1, suba, subb, subc, subg, subh, subr, pr_n, ric, ricinv
  real(kind=DEFAULT_PRECISION) :: diff_mult
  ! Alanna parametrization
  real(kind=DEFAULT_PRECISION) :: Cs_ML, Cs_NC, C_AC, Cs_IC, gamma_f_s, alpha_f_s, gamma_g_s, alpha_g_s, ri_ct
  real(kind=DEFAULT_PRECISION) :: Cth_ML, Cth_NC, Cth_L_IC, gamma_f_th, alpha_f_th, gamma_g_th, alpha_g_th

  real(kind=DEFAULT_PRECISION), dimension(:,:), allocatable :: z_ml_height_diag, z_ct_height_diag
  integer, dimension(:,:), allocatable :: z_ml_index_diag, z_ct_index_diag
  real(kind=DEFAULT_PRECISION), dimension(:,:,:), allocatable :: mom_env_ml_diag, mom_ic_ml_diag, scalar_env_ml_diag, scalar_ic_ml_diag
  real(kind=DEFAULT_PRECISION), dimension(:,:,:), allocatable :: mom_ml_diag, scalar_ml_diag
  real(kind=DEFAULT_PRECISION), dimension(:,:,:), allocatable :: ssq_diag, ri_diag, fm_diag, fh_diag
  real(kind=DEFAULT_PRECISION) :: zztop, dxx, dyy
  real(kind=DEFAULT_PRECISION) :: delta_sq
  real(kind=DEFAULT_PRECISION), parameter :: cloud_thresh=1.0E-6

  ! Alanna parametrization end ----------------------------

  
  public smagorinsky_get_descriptor, calculate_half_squared_strain_rate,    &
         calculate_richardson_number, calculate_thermal_dissipation_rate,   &
         copy_diff_to_halo_buffer, copy_vis_to_halo_buffer,                 &
         copy_vis_corners_to_halo_buffer, copy_diff_corners_to_halo_buffer, &
         update_viscous_number, setfri, set_vis_and_diff,                   &
         mixing_length_param, set_vis_and_diff_param, delta_sq

  integer :: iqv, iql ! index for water vapour and liquid
  integer :: mixing_length_param_level

contains

  !> Provides the descriptor back to the caller and is used in component registration
  !! @returns The termination check component descriptor
  type(component_descriptor_type) function smagorinsky_get_descriptor()
    smagorinsky_get_descriptor%name="smagorinsky"
    smagorinsky_get_descriptor%version=0.1
    smagorinsky_get_descriptor%initialisation=>initialisation_callback
    smagorinsky_get_descriptor%timestep=>timestep_callback
    smagorinsky_get_descriptor%finalisation=>finalisation_callback
    
    smagorinsky_get_descriptor%field_value_retrieval=>field_value_retrieval_callback
    smagorinsky_get_descriptor%field_information_retrieval=>field_information_retrieval_callback
    allocate(smagorinsky_get_descriptor%published_fields(14))

    ! Alanna parametrization
    smagorinsky_get_descriptor%published_fields(1)="z_ml_index"
    smagorinsky_get_descriptor%published_fields(2)="z_ml_height"
	  smagorinsky_get_descriptor%published_fields(3)="z_ct_index"
    smagorinsky_get_descriptor%published_fields(4)="z_ct_height"
    smagorinsky_get_descriptor%published_fields(5)="mom_env_ml"
    smagorinsky_get_descriptor%published_fields(6)="mom_ic_ml"
	  smagorinsky_get_descriptor%published_fields(7)="scalar_env_ml"
    smagorinsky_get_descriptor%published_fields(8)="scalar_ic_ml"
    ! Alanna parametrization end ----------------------------
    smagorinsky_get_descriptor%published_fields(9) ="ssq"
    smagorinsky_get_descriptor%published_fields(10)="Ri"
    smagorinsky_get_descriptor%published_fields(11)="fm"
    smagorinsky_get_descriptor%published_fields(12)="fh"
    smagorinsky_get_descriptor%published_fields(13)="mom_ml"
    smagorinsky_get_descriptor%published_fields(14)="scalar_ml"

  end function smagorinsky_get_descriptor

  !> Field information retrieval callback, this returns information for a specific components published field
  !! @param current_state Current model state
  !! @param name The name of the field to retrieve information for
  !! @param field_information Populated with information about the field
  subroutine field_information_retrieval_callback(current_state, name, field_information)
    type(model_state_type), target, intent(inout) :: current_state
    character(len=*), intent(in) :: name
    type(component_field_information_type), intent(out) :: field_information
    
    if (     name .eq. "z_ml_index"  &
        .or. name .eq. "z_ml_height" &
        .or. name .eq. "z_ct_index"  &
        .or. name .eq. "z_ct_height" &
       ) then

      field_information%field_type=COMPONENT_ARRAY_FIELD_TYPE
      field_information%number_dimensions=2
      field_information%dimension_sizes(1)=current_state%local_grid%size(Y_INDEX)
      field_information%dimension_sizes(2)=current_state%local_grid%size(X_INDEX)
      field_information%data_type=COMPONENT_DOUBLE_DATA_TYPE

    elseif (      name .eq. "mom_env_ml"      &
             .or. name .eq. "mom_ic_ml"       &
             .or. name .eq. "scalar_env_ml"   &
             .or. name .eq. "scalar_ic_ml"    &
             .or. name .eq. "ssq"    &
             .or. name .eq. "Ri"    &
             .or. name .eq. "fm"    &
             .or. name .eq. "fh"    &
             .or. name .eq. "mom_ml"    &
             .or. name .eq. "scalar_ml"    &
            ) then
            
      field_information%field_type=COMPONENT_ARRAY_FIELD_TYPE
      field_information%number_dimensions=3
      field_information%dimension_sizes(1)=current_state%local_grid%size(Z_INDEX)
      field_information%dimension_sizes(2)=current_state%local_grid%size(Y_INDEX)
      field_information%dimension_sizes(3)=current_state%local_grid%size(X_INDEX)
      field_information%data_type=COMPONENT_DOUBLE_DATA_TYPE

    endif    

    field_information%enabled=current_state%mixing_length_param

  end subroutine field_information_retrieval_callback
  
  !> Field value retrieval callback, this returns the value of a specific published field
  !! @param current_state Current model state
  !! @param name The name of the field to retrieve the value for
  !! @param field_value Populated with the value of the field
  subroutine field_value_retrieval_callback(current_state, name, field_value)
    type(model_state_type), target, intent(inout) :: current_state
    character(len=*), intent(in) :: name
    type(component_field_value_type), intent(out) :: field_value
    
    integer :: k

    if (name .eq. "z_ml_index" .and. allocated(z_ml_index_diag)) then
       allocate(field_value%real_2d_array(current_state%local_grid%size(Y_INDEX),     &
            current_state%local_grid%size(X_INDEX)))
       field_value%real_2d_array(:,:) = z_ml_index_diag(:,:)
    elseif (name .eq. "z_ml_height" .and. allocated(z_ml_height_diag)) then
       allocate(field_value%real_2d_array(current_state%local_grid%size(Y_INDEX),     &
            current_state%local_grid%size(X_INDEX)))
       field_value%real_2d_array(:,:) = z_ml_height_diag(:,:)
    elseif (name .eq. "z_ct_index" .and. allocated(z_ct_index_diag)) then
       allocate(field_value%real_2d_array(current_state%local_grid%size(Y_INDEX),     &
            current_state%local_grid%size(X_INDEX)))
       field_value%real_2d_array(:,:) = z_ct_index_diag(:,:)
    elseif (name .eq. "z_ct_height" .and. allocated(z_ct_height_diag)) then
       allocate(field_value%real_2d_array(current_state%local_grid%size(Y_INDEX),     &
            current_state%local_grid%size(X_INDEX)))
       field_value%real_2d_array(:,:) = z_ct_height_diag(:,:)       
    elseif (name .eq. "mom_env_ml" .and. allocated(mom_env_ml_diag)) then
       allocate(field_value%real_3d_array(current_state%local_grid%size(Z_INDEX), &
                                          current_state%local_grid%size(Y_INDEX), &
                                          current_state%local_grid%size(X_INDEX)))
       field_value%real_3d_array(:,:,:) = mom_env_ml_diag(:,:,:)
    elseif (name .eq. "mom_ic_ml" .and. allocated(mom_ic_ml_diag)) then
       allocate(field_value%real_3d_array(current_state%local_grid%size(Z_INDEX), &
                                          current_state%local_grid%size(Y_INDEX), &
                                          current_state%local_grid%size(X_INDEX)))
       field_value%real_3d_array(:,:,:) = mom_ic_ml_diag(:,:,:)
    elseif (name .eq. "scalar_env_ml" .and. allocated(scalar_env_ml_diag)) then
       allocate(field_value%real_3d_array(current_state%local_grid%size(Z_INDEX), &
                                          current_state%local_grid%size(Y_INDEX), &
                                          current_state%local_grid%size(X_INDEX)))
       field_value%real_3d_array(:,:,:) = scalar_env_ml_diag(:,:,:)
    elseif (name .eq. "scalar_ic_ml" .and. allocated(scalar_ic_ml_diag)) then
       allocate(field_value%real_3d_array(current_state%local_grid%size(Z_INDEX), &
                                          current_state%local_grid%size(Y_INDEX), &
                                          current_state%local_grid%size(X_INDEX)))
       field_value%real_3d_array(:,:,:) = scalar_ic_ml_diag(:,:,:)
    elseif (name .eq. "ssq" .and. allocated(ssq_diag)) then
       allocate(field_value%real_3d_array(current_state%local_grid%size(Z_INDEX), &
                                          current_state%local_grid%size(Y_INDEX), &
                                          current_state%local_grid%size(X_INDEX)))
       field_value%real_3d_array(:,:,:) = ssq_diag(:,:,:)
    elseif (name .eq. "Ri" .and. allocated(ri_diag)) then
       allocate(field_value%real_3d_array(current_state%local_grid%size(Z_INDEX), &
                                          current_state%local_grid%size(Y_INDEX), &
                                          current_state%local_grid%size(X_INDEX)))
       field_value%real_3d_array(:,:,:) = ri_diag(:,:,:)
    elseif (name .eq. "fm" .and. allocated(fm_diag)) then
       allocate(field_value%real_3d_array(current_state%local_grid%size(Z_INDEX), &
                                          current_state%local_grid%size(Y_INDEX), &
                                          current_state%local_grid%size(X_INDEX)))
       field_value%real_3d_array(:,:,:) = fm_diag(:,:,:)
    elseif (name .eq. "fh" .and. allocated(fh_diag)) then
       allocate(field_value%real_3d_array(current_state%local_grid%size(Z_INDEX), &
                                          current_state%local_grid%size(Y_INDEX), &
                                          current_state%local_grid%size(X_INDEX)))
       field_value%real_3d_array(:,:,:) = fh_diag(:,:,:)
    elseif (name .eq. "mom_ml" .and. allocated(mom_ml_diag)) then
       allocate(field_value%real_3d_array(current_state%local_grid%size(Z_INDEX), &
                                          current_state%local_grid%size(Y_INDEX), &
                                          current_state%local_grid%size(X_INDEX)))
       field_value%real_3d_array(:,:,:) = mom_ml_diag(:,:,:)
    elseif (name .eq. "scalar_ml" .and. allocated(scalar_ml_diag)) then
       allocate(field_value%real_3d_array(current_state%local_grid%size(Z_INDEX), &
                                          current_state%local_grid%size(Y_INDEX), &
                                          current_state%local_grid%size(X_INDEX)))
       field_value%real_3d_array(:,:,:) = scalar_ml_diag(:,:,:)
    end if
    
  end subroutine field_value_retrieval_callback


  !> Initialisation call back which will read in the coriolis configuration and set up the geostrophic winds
  !! @param current_state The current model state
  subroutine initialisation_callback(current_state)
    ! Options:
    ! current_state%mixing_length_param = use_mixing_length_param = .true. to use Alanna's parametrization
    ! current_state%mixing_length_param_level = 1 (4D), 2 (8D) or 3 (16D)
    ! 
    type(model_state_type), target, intent(inout) :: current_state

    ! Alanna parametrization 
    character(len=100) :: output_str
    integer :: z_size_local, y_size_local, x_size_local
    ! Alanna parametrization end ----------------------------

    if (.not. is_component_enabled(current_state%options_database, "diffusion")) then
      call log_master_log(LOG_ERROR, "Smagorinsky requires the diffusion component to be enabled")
    end if    
    
    if (.not. is_component_enabled(current_state%options_database, "viscosity")) then
      call log_master_log(LOG_ERROR, "Smagorinsky requires the viscosity component to be enabled")
    end if
    
    if (.not. current_state%use_viscosity_and_diffusion) then 
       call log_master_log(LOG_ERROR, "Smagorinsky requires use_viscosity_and_diffusion=.true. or monc will fail")
    endif

    if (.not. is_component_enabled(current_state%options_database, "lower_bc")) then
       call log_master_log(LOG_INFO, "LOWERBC is disabled, zero diff and vis_coeff on level 1")
       current_state%vis_coefficient%data(1,:,:)=0.0_DEFAULT_PRECISION
       current_state%diff_coefficient%data(1,:,:)=0.0_DEFAULT_PRECISION
    endif
    
    circle_a_enabled=options_get_logical(current_state%options_database, "circle_a_enabled")
    
    dxx=options_get_real(current_state%options_database, "dxx")
    dyy=options_get_real(current_state%options_database, "dyy")
    zztop=options_get_real(current_state%options_database, "zztop")
    
    delta_sq = (max(dxx, dyy))**2

    eps=0.01_DEFAULT_PRECISION
    repsh=0.5_DEFAULT_PRECISION/eps
    thcona=ratio_mol_wts*current_state%thref0
    thconb=thcona-current_state%thref0
    thconap1=thcona

    subb=options_get_real(current_state%options_database, "smag-subb")
    subc=options_get_real(current_state%options_database, "smag-subc")

    subg=1.2_DEFAULT_PRECISION
    subh=0.0_DEFAULT_PRECISION
    subr=4.0_DEFAULT_PRECISION
    pr_n=0.7_DEFAULT_PRECISION
    ric=0.25_DEFAULT_PRECISION
    ricinv=1.0_DEFAULT_PRECISION/ric
       
    ! Alanna parametrization
    if (current_state%mixing_length_param) then
        
      mixing_length_param_level = options_get_integer(current_state%options_database, "mixing_length_param_level") 
      write(output_str,'(A, I1)') "Mixing length parametrization enabled with level=", mixing_length_param_level
      call log_master_log(LOG_INFO, adjustl(trim(output_str)))

      pr_n=1.0_DEFAULT_PRECISION
	    C_AC = 0.0_DEFAULT_PRECISION
	
	    alpha_f_s = 1.4_DEFAULT_PRECISION
	    gamma_f_s = 16.0_DEFAULT_PRECISION
	    alpha_g_s = 1.2_DEFAULT_PRECISION
	    gamma_g_s = 16.0_DEFAULT_PRECISION
	    ri_ct = 0.5_DEFAULT_PRECISION

	    alpha_f_th = 1.6_DEFAULT_PRECISION
	    gamma_f_th = 3.0_DEFAULT_PRECISION
	    alpha_g_th = 1.45_DEFAULT_PRECISION
	    gamma_g_th = 4.0_DEFAULT_PRECISION
	    
	    if (mixing_length_param_level == 1) then ! 4D
	      Cs_ML = 0.137_DEFAULT_PRECISION
	      Cs_NC = 0.095_DEFAULT_PRECISION
	      Cs_IC = 0.15_DEFAULT_PRECISION	
	      Cth_ML = 0.175_DEFAULT_PRECISION
	      Cth_NC = 0.09_DEFAULT_PRECISION
	      Cth_L_IC = 0.2_DEFAULT_PRECISION
	    else if (mixing_length_param_level == 2) then ! 8D
	      Cs_ML = 0.11_DEFAULT_PRECISION
	      Cs_NC = 0.05_DEFAULT_PRECISION
	      Cs_IC = 0.12_DEFAULT_PRECISION	
	      Cth_ML = 0.13_DEFAULT_PRECISION
	      Cth_NC = 0.05_DEFAULT_PRECISION
	      Cth_L_IC = 0.17_DEFAULT_PRECISION
	    else if (mixing_length_param_level == 3) then ! 16D
	      Cs_ML = 0.075_DEFAULT_PRECISION
	      Cs_NC = 0.015_DEFAULT_PRECISION
	      Cs_IC = 0.09_DEFAULT_PRECISION
	      Cth_ML = 0.08_DEFAULT_PRECISION
	      Cth_NC = 0.015_DEFAULT_PRECISION
	      Cth_L_IC = 0.13_DEFAULT_PRECISION
	    else
        call log_master_log(LOG_ERROR, "Illegal mixing_length_param_level")
	    end if
	  end if
    ! Alanna parametrization end ----------------------------

    suba=1.0_DEFAULT_PRECISION/pr_n

    
    z_size_local = current_state%local_grid%size(Z_INDEX)
    y_size_local = current_state%local_grid%size(Y_INDEX)
    x_size_local = current_state%local_grid%size(X_INDEX)

    if ((.not. circle_a_enabled) .and. current_state%use_viscosity_and_diffusion) then
      call log_master_log(LOG_DEBUG, "Smagorinsky initialise halo communication.")
      call init_halo_communication(current_state, get_single_field_per_halo_cell, &
           current_state%viscosity_halo_swap_state, 2, .true.)
      call init_halo_communication(current_state, get_single_field_per_halo_cell, &
           current_state%diffusion_halo_swap_state, 2, .true.)
           
    end if    

    if (.not. current_state%passive_q) then 
       iqv = get_q_index(standard_q_names%VAPOUR, 'smagorinsky')
       current_state%water_vapour_mixing_ratio_index=iqv
       
       iql = get_q_index(standard_q_names%CLOUD_LIQUID_MASS, 'smagorinsky')
       current_state%liquid_water_mixing_ratio_index=iql
    endif

    if (current_state%mixing_length_param) then
      call ml_param_alloc_diag(current_state)
    end if
    
    if (.not. circle_a_enabled) then
      allocate(ssq_diag(z_size_local, y_size_local, x_size_local))
      ssq_diag(:,:,:) = 0.0
      allocate(ri_diag(z_size_local, y_size_local, x_size_local))
      ri_diag(:,:,:) = 0.0
      allocate(fm_diag(z_size_local, y_size_local, x_size_local))
      fm_diag(:,:,:) = 0.0
      allocate(fh_diag(z_size_local, y_size_local, x_size_local))
      fh_diag(:,:,:) = 0.0
      allocate(mom_ml_diag(z_size_local, y_size_local, x_size_local))
      mom_ml_diag(:,:,:) = 0.0
      allocate(scalar_ml_diag(z_size_local, y_size_local, x_size_local))
      scalar_ml_diag(:,:,:) = 0.0
    end if
       
  end subroutine initialisation_callback
  
  !> For each none halo cell this will calculate the subgrid terms for viscosity and diffusion
  !! @param current_state The current model state
  subroutine timestep_callback(current_state)
    type(model_state_type), target, intent(inout) :: current_state

    real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)) :: richardson_number, ssq, fm, fh
  	real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)) :: Cs_env, r_Cs_env_ml, r_Cs_IC_ml
  	real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)) :: Cth_env, r_Cth_env_ml, r_Cth_IC_ml
    integer :: icol, jcol ! Shorthand column indices
    integer :: target_x_index, target_y_index
    integer :: k

    if (circle_a_enabled) return

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
        if (current_state%field_stepping == FORWARD_STEPPING) then
          ssq=calculate_half_squared_strain_rate(current_state, current_state%u, current_state%v, current_state%w)
          richardson_number=calculate_richardson_number(current_state, ssq, current_state%th, current_state%q)
        else
          ssq=calculate_half_squared_strain_rate(current_state, current_state%zu, current_state%zv, current_state%zw)
          richardson_number=calculate_richardson_number(current_state, ssq, current_state%zth, current_state%zq)
        end if
        
        call setfri(current_state, richardson_number, fm, fh)
        
        if (current_state%mixing_length_param) then
        
          ! Alanna parametrization
          
          call mixing_length_param(current_state, richardson_number, Cs_env, r_Cs_env_ml, r_Cs_IC_ml, Cth_env, r_Cth_env_ml, r_Cth_IC_ml)
          
          call set_vis_and_diff_param(current_state, ssq, fm, fh, r_Cs_env_ml, r_Cs_IC_ml, r_Cth_env_ml, r_Cth_IC_ml)
          
        else
        
          call set_vis_and_diff(current_state, ssq, fm, fh)
          
        end if 
        
        if (is_component_enabled(current_state%options_database, "cfltest")) then
           call update_viscous_number(current_state)
        endif
        
        if (allocated(ssq_diag)) ssq_diag(:, target_y_index, target_x_index) = ssq(:)
        if (allocated(ri_diag)) ri_diag(:, target_y_index, target_x_index) = richardson_number(:)    

      end if
    end if
    
    if (current_state%last_timestep_column) then
      call log_master_log(LOG_DEBUG, "Smagorinsky halo swap.")

      ! need to ensure not already in progress
      call initiate_nonblocking_halo_swap(current_state, current_state%diffusion_halo_swap_state, &
           copy_diff_to_halo_buffer, copy_diff_corners_to_halo_buffer)
      call initiate_nonblocking_halo_swap(current_state, current_state%viscosity_halo_swap_state, &
           copy_vis_to_halo_buffer, copy_vis_corners_to_halo_buffer)
    end if
    
  end subroutine timestep_callback

  !> Called when the model is finishing up, will finalise the halo communications represented by the state
  !! @param current_state The current model state
  subroutine finalisation_callback(current_state)
    type(model_state_type), target, intent(inout) :: current_state
    
    ! if (circle_a_enabled) return
    
    ! Alanna parametrization
    !deallocate(current_state%global_grid%configuration%vertical%r_Cs_env_ml, current_state%global_grid%configuration%vertical%r_Cs_env_ml_sq)
    !deallocate(current_state%global_grid%configuration%vertical%r_Cs_IC_ml, current_state%global_grid%configuration%vertical%r_Cs_IC_ml_sq)
    ! Alanna parametrization end ----------------------------

    if (.not. circle_a_enabled) then
      call log_master_log(LOG_DEBUG, "Smagorinsky finalise halo communication.")
      call finalise_halo_communication(current_state%viscosity_halo_swap_state)
      call finalise_halo_communication(current_state%diffusion_halo_swap_state)      
    end if

    if (current_state%mixing_length_param) then
      call ml_param_dealloc_diag()
    end if

    
    if (allocated(ssq_diag))        deallocate(ssq_diag)
    if (allocated(ri_diag))         deallocate(ri_diag)
    if (allocated(fm_diag))         deallocate(fm_diag)
    if (allocated(fh_diag))         deallocate(fh_diag)
    if (allocated(mom_ml_diag))     deallocate(mom_ml_diag)
    if (allocated(scalar_ml_diag))  deallocate(scalar_ml_diag)
    

  end subroutine finalisation_callback  
  
  subroutine ml_param_alloc_diag(current_state)
    type(model_state_type), target, intent(inout) :: current_state
    integer :: z_size_local, y_size_local, x_size_local
    ! Alanna parametrization
    z_size_local = current_state%local_grid%size(Z_INDEX)
    y_size_local = current_state%local_grid%size(Y_INDEX)
    x_size_local = current_state%local_grid%size(X_INDEX)
    
    ! allocate the ML capping inversion index as a 2-D field that is then
    ! published to the ioserver
    allocate(z_ml_index_diag(y_size_local, x_size_local))
    z_ml_index_diag(:,:) = 0
    allocate(z_ct_index_diag(y_size_local, x_size_local))
    z_ct_index_diag(:,:) = 0

    allocate(z_ml_height_diag(y_size_local, x_size_local))
    z_ml_height_diag(:,:) = 1.0
    allocate(z_ct_height_diag(y_size_local, x_size_local))
    z_ct_height_diag(:,:) = 1.0
    
    allocate(mom_env_ml_diag(z_size_local, y_size_local, x_size_local))
    mom_env_ml_diag(:,:,:) = 0.0
    allocate(mom_ic_ml_diag(z_size_local, y_size_local, x_size_local))
    mom_ic_ml_diag(:,:,:) = 0.0
    allocate(scalar_env_ml_diag(z_size_local, y_size_local, x_size_local))
    scalar_env_ml_diag(:,:,:) = 0.0
    allocate(scalar_ic_ml_diag(z_size_local, y_size_local, x_size_local))
    scalar_ic_ml_diag(:,:,:) = 0.0

  end subroutine ml_param_alloc_diag
    
  subroutine ml_param_dealloc_diag()
    ! Alanna parametrization
    if (allocated(z_ct_height_diag)) deallocate(z_ct_height_diag)
    if (allocated(z_ml_height_diag)) deallocate(z_ml_height_diag)
    if (allocated(z_ct_index_diag))  deallocate(z_ct_index_diag)
    if (allocated(z_ml_index_diag))  deallocate(z_ml_index_diag)
    
    if (allocated(mom_env_ml_diag))    deallocate(mom_env_ml_diag)
    if (allocated(mom_ic_ml_diag))     deallocate(mom_ic_ml_diag)
    if (allocated(scalar_env_ml_diag)) deallocate(scalar_env_ml_diag)
    if (allocated(scalar_ic_ml_diag))  deallocate(scalar_ic_ml_diag)
    ! Alanna parametrization end ----------------------------
  
  end subroutine ml_param_dealloc_diag

  !Alanna parametrization
  !> Subroutine to implement Alanna's mixing length parametrization
  subroutine mixing_length_param(current_state, richardson_number, Cs_env, r_Cs_env_ml, r_Cs_IC_ml, Cth_env, r_Cth_env_ml, r_Cth_IC_ml)
    type(model_state_type), target, intent(inout) :: current_state
    real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)), intent(in) :: richardson_number
  	real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)), intent(out) :: Cs_env, r_Cs_env_ml, r_Cs_IC_ml
  	real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)), intent(out) :: Cth_env, r_Cth_env_ml, r_Cth_IC_ml
	  real(kind=DEFAULT_PRECISION) :: z_ml_height, z_ct_height

    integer :: z_ml_index, z_ct_index  	
    integer :: icol, jcol ! Shorthand column indices
    integer :: target_x_index, target_y_index
    
    icol=current_state%column_local_x
    jcol=current_state%column_local_y

    target_x_index=icol-current_state%local_grid%halo_size(X_INDEX)
    target_y_index=jcol-current_state%local_grid%halo_size(Y_INDEX)
    
    call ml_height(current_state, richardson_number, z_ml_height, z_ml_index)

    call ct_height(current_state, richardson_number, z_ct_height, z_ct_index, z_ml_index)

    call C_prof_non_cloud_env(current_state, Cs_ML, Cs_NC, C_AC, z_ml_height, z_ct_height, gamma_f_s, alpha_f_s, gamma_g_s, alpha_g_s, Cs_env)
    
    call calculate_mixing_length_with_C_env(current_state, current_state%global_grid%configuration%vertical, Cs_env, Cs_IC, r_Cs_env_ml, r_Cs_IC_ml)

    call C_prof_non_cloud_env(current_state, Cth_ML, Cth_NC, C_AC, z_ml_height, z_ct_height, gamma_f_th, alpha_f_th, gamma_g_th, alpha_g_th, Cth_env)
    
    call calculate_mixing_length_with_C_env(current_state, current_state%global_grid%configuration%vertical, Cth_env, Cth_L_IC, r_Cth_env_ml, r_Cth_IC_ml)
        
        ! Copy diagnostics
    if (allocated(z_ml_index_diag))  z_ml_index_diag(target_y_index, target_x_index) = z_ml_index
    if (allocated(z_ml_height_diag)) z_ml_height_diag(target_y_index, target_x_index) = z_ml_height

    if (allocated(z_ct_index_diag))  z_ct_index_diag(target_y_index, target_x_index) = z_ct_index
    if (allocated(z_ct_height_diag)) z_ct_height_diag(target_y_index, target_x_index) = z_ct_height
    
    if (allocated(mom_env_ml_diag))    mom_env_ml_diag(:, target_y_index, target_x_index) = r_Cs_env_ml(:)
    if (allocated(mom_ic_ml_diag))     mom_ic_ml_diag(:, target_y_index, target_x_index) = r_Cs_IC_ml(:)
    if (allocated(scalar_env_ml_diag)) scalar_env_ml_diag(:, target_y_index, target_x_index) = r_Cth_env_ml(:)
    if (allocated(scalar_ic_ml_diag))  scalar_ic_ml_diag(:, target_y_index, target_x_index) = r_Cth_IC_ml(:)
  
  end subroutine mixing_length_param

  !Alanna parametrization
  !> Subroutine to calculate the mixed layer height for the Smagorinsky parameter profiles function
  subroutine ml_height(current_state, richardson_number, z_ml_height, z_ml_index)
    type(model_state_type), target, intent(inout) :: current_state
    real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)), intent(in) :: richardson_number
    real(kind=DEFAULT_PRECISION), intent(out) :: z_ml_height
    integer, intent(out) :: z_ml_index
    integer :: icol, jcol ! Shorthand column indices
    integer :: k, kk
    integer, parameter :: n_ml = 3
    logical :: ml_found

    icol=current_state%column_local_x
    jcol=current_state%column_local_y

    z_ml_index = 1
    z_ml_height = 1.0

    do k = 1, size(richardson_number)-n_ml
      ml_found = .true.
      do kk = k, k+n_ml 
        ml_found = ml_found .and.                        &
                          ((richardson_number(kk) > ric) &
                      .or. (current_state%q(iql)%data(kk, jcol, icol) > cloud_thresh))
 
      end do ! kk   
      if (ml_found) then  !making sure not a once off Ri > crit value
        z_ml_index = k
        z_ml_height = current_state%global_grid%configuration%vertical%zn(k)
        exit ! End subroutine once condition is met
      end if
    end do ! k
    
    return
 
  end subroutine ml_height

  !> Subroutine to calculate the average cloud top height for the Smagorinsky parameter profiles function.
  !! a top down method is used, with a Richardson number of less than 0.5 (critical value was found by analysing ARM data)

  subroutine ct_height(current_state, richardson_number, z_ct_height, z_ct_index, z_ml_index)
    type(model_state_type), target, intent(inout) :: current_state
    real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)), intent(in) :: richardson_number
    integer, intent(in) :: z_ml_index
    real(kind=DEFAULT_PRECISION), intent(out) :: z_ct_height
    integer, intent(out) :: z_ct_index
    integer :: k, kk
    integer, parameter :: n_ct = 3 
    logical :: ct_found

    z_ct_index = 1
    z_ct_height = 1.0
    do k = size(richardson_number), n_ct + 1, -1     
      ct_found = .true.
      do kk = k, k-n_ct 
        ct_found = ct_found .and. (richardson_number(kk) <= ri_ct)  
      end do ! kk   
      if (ct_found) then
        z_ct_index = k
        z_ct_height = current_state%global_grid%configuration%vertical%zn(z_ct_index)
        exit ! End subroutine once condition is met
      end if
    end do
    if (z_ct_index == 1 .or. z_ct_index < z_ml_index) then
      z_ct_index = z_ml_index+1
      z_ct_height = current_state%global_grid%configuration%vertical%zn(z_ml_index+1)
    end if
    
    return
 
  end subroutine ct_height

  !> Subroutine to set the Smagorinsky paraemerter to a certain value based on the points vertical position 
  !! in the column, based on the stability.
  !! The profile for the Smagorinsky parameter is dependent on the mixed layer capping inversion height
  !! and the cloud layer depth (the CL depth dependency is yet to be added). 
  subroutine C_prof_non_cloud_env(current_state, C_ML, C_NC, C_AC_in, z_i_metre, z_ct_metre, gamma_f_in, alpha_f_in, gamma_g_in, alpha_g_in, C_env)
    type(model_state_type), target, intent(inout) :: current_state
    real(kind=DEFAULT_PRECISION), intent(in) :: C_ML, C_NC, C_AC_in, z_i_metre, z_ct_metre, gamma_f_in, alpha_f_in, gamma_g_in, alpha_g_in
    real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)) :: f, g, w, z_m
    real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)), intent(out) :: C_env

    z_m = current_state%global_grid%configuration%vertical%z
    f = ( (z_m/(alpha_f_in*z_i_metre) )**gamma_f_in ) / (1.0 - (z_m/(alpha_f_in*z_i_metre)) )**2
    g = ( (z_m/(alpha_g_in*z_ct_metre) )**gamma_g_in ) / (1.0 - (z_m/(alpha_g_in*z_ct_metre)) )**2

    C_env = (C_ML - C_NC - C_AC_in)*(1.0/(1.0+f)) + (C_NC - C_AC_in)*(1.0/(1.0+g)) + C_AC_in
 
  end subroutine C_prof_non_cloud_env

  !> Calculates the mixing length for the neutral case with the Cs_env profile included (stability dependence)
  !! @param current_state The current model state_mod
  !! @param vertical_grid The vertical grid that we are working on
  !! @param kkp Number of grid points in a vertical column
!  subroutine calculate_mixing_length_with_C_env_grid_mngr(current_state, vertical_grid, Cs_env)
!    type(model_state_type), intent(inout) :: current_state
!    type(vertical_grid_configuration_type), intent(inout) :: vertical_grid
!	real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)), intent(in) :: Cs_env
!    integer :: k
!
!    dxx=options_get_real(current_state%options_database, "dxx")
!    dyy=options_get_real(current_state%options_database, "dyy")
!    zztop=options_get_real(current_state%options_database, "zztop")
!
!    do k=2, current_state%global_grid%size(Z_INDEX)-1
!
!	  vertical_grid%r_Cs_env_ml(k)=sqrt(1.0_DEFAULT_PRECISION/(1.0_DEFAULT_PRECISION/(von_karman_constant*&
!           (vertical_grid%z(k)+z0))**2+1.0_DEFAULT_PRECISION/( Cs_env(k) * max(dxx, dyy) )**2) )
 !     vertical_grid%prr_Cs_env_ml_sq(k)=vertical_grid%r_Cs_env_ml(k)*vertical_grid%r_Cs_env_ml(k)
!
!	  vertical_grid%r_Cs_IC_ml(k)=sqrt(1.0_DEFAULT_PRECISION/(1.0_DEFAULT_PRECISION/(von_karman_constant*&
!           (vertical_grid%z(k)+z0))**2+1.0_DEFAULT_PRECISION/( Cs_IC * max(dxx, dyy) )**2) )
!	  vertical_grid%r_Cs_IC_ml_sq(k)=vertical_grid%r_Cs_IC_ml(k)*vertical_grid%r_Cs_IC_ml(k)
!
!    end do    
!  end subroutine calculate_mixing_length_with_C_env_grid_mngr

  !> Calculates the mixing length for the neutral case with the Cs_env profile included (stability dependence)
  !! @param current_state The current model state_mod
  !! @param vertical_grid The vertical grid that we are working on
  !! @param kkp Number of grid points in a vertical column
  subroutine calculate_mixing_length_with_C_env(current_state, vertical_grid, C_env, C_IC, r_C_env_ml, r_C_IC_ml)
    type(model_state_type), intent(inout) :: current_state
    type(vertical_grid_configuration_type), intent(in) :: vertical_grid
    real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)), intent(in) :: C_env
    real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)), intent(out) :: r_C_env_ml, r_C_IC_ml
    real(kind=DEFAULT_PRECISION), intent(in) :: C_IC
    
    integer :: k

    do k=2, current_state%global_grid%size(Z_INDEX)-1

      r_C_env_ml(k)=sqrt(1.0_DEFAULT_PRECISION/(1.0_DEFAULT_PRECISION/(von_karman_constant*&
          (vertical_grid%z(k)+z0))**2+1.0_DEFAULT_PRECISION/( C_env(k)**2 * delta_sq) ) )

      r_C_IC_ml(k)=sqrt(1.0_DEFAULT_PRECISION/(1.0_DEFAULT_PRECISION/(von_karman_constant*&
          (vertical_grid%z(k)+z0))**2+1.0_DEFAULT_PRECISION/( C_IC**2 * delta_sq) ) )

    end do    
    
  end subroutine calculate_mixing_length_with_C_env
  ! Alanna parametrization end ----------------------------

  !> Update viscous number based upon the viscosity and diffusivity coefficients
  !! @param current_state The current model state
  subroutine update_viscous_number(current_state, diff_mult)
    type(model_state_type), target, intent(inout) :: current_state
    real(kind=DEFAULT_PRECISION), intent(in), optional :: diff_mult    

    integer :: k
    integer :: compare_timestep  ! timestep adusted in the case of reconfiguration to keep same cfl interval
    real(kind=DEFAULT_PRECISION) :: dmult 
    character(len=100) :: output_str

    compare_timestep = current_state%timestep + current_state%reconfig_timestep_offset

    if ((mod(compare_timestep, current_state%cfl_frequency) == 1 &
        .or. compare_timestep - current_state%start_timestep .le. current_state%cfl_frequency) &
        .or. compare_timestep .ge. (current_state%last_cfl_timestep + current_state%cfl_frequency)) then

      if(current_state%immersed%ib_enabled)then
        do k=2, current_state%local_grid%size(Z_INDEX)-1
          if(current_state%immersed%indic_w(k,current_state%column_local_y, current_state%column_local_x).eq.0)then
            current_state%cvis=max(current_state%cvis, max(current_state%vis_coefficient%data(k, current_state%column_local_y, &
               current_state%column_local_x),current_state%diff_coefficient%data(k, current_state%column_local_y, &
               current_state%column_local_x))*(current_state%global_grid%configuration%vertical%rdzn(k+1)**2+&
               current_state%global_grid%configuration%horizontal%cx2+current_state%global_grid%configuration%horizontal%cy2))
           end if
        end do
      else
      end if
        
      if (present(diff_mult)) then
        dmult = diff_mult
!        write(output_str, *) dmult
!        call log_master_log(LOG_INFO, "update_viscous_number with dmult="//adjustl(trim(output_str)))
      else
        dmult = 1.0_DEFAULT_PRECISION
      end if

      do k=2, current_state%local_grid%size(Z_INDEX)-1
        current_state%cvis=max(current_state%cvis, max(&
                               current_state%vis_coefficient%data(k, current_state%column_local_y, current_state%column_local_x), &
                               dmult &
                             * current_state%diff_coefficient%data(k, current_state%column_local_y, current_state%column_local_x)) &
                             * (current_state%global_grid%configuration%vertical%rdzn(k+1)**2 &
                              + current_state%global_grid%configuration%horizontal%cx2 &
                              + current_state%global_grid%configuration%horizontal%cy2))
      end do
    end if
  end subroutine update_viscous_number  

  !> Calculates the stability functions depending on the Richardson Number (RI)
  !! @param current_state The current model state
  !! @param richardson_number Richardson number
  subroutine setfri(current_state, richardson_number, fm, fh)
    type(model_state_type), target, intent(inout) :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:), intent(in) :: richardson_number
    real(kind=DEFAULT_PRECISION), dimension(:), intent(out) :: fm, fh

    real(kind=DEFAULT_PRECISION) :: rifac
    integer :: icol, jcol ! Shorthand column indices
    integer :: target_x_index, target_y_index
    integer :: k

    icol=current_state%column_local_x
    jcol=current_state%column_local_y

    target_x_index=icol-current_state%local_grid%halo_size(X_INDEX)
    target_y_index=jcol-current_state%local_grid%halo_size(Y_INDEX)

    do k=2,current_state%local_grid%size(Z_INDEX)-1
      if (richardson_number(k) .le. 0.0_DEFAULT_PRECISION) then
        fm(k) = sqrt(1.0_DEFAULT_PRECISION-subc*richardson_number(k))
        
        fh(k) = suba*sqrt(1.-subb*richardson_number(k)) 
               
      else if ((richardson_number(k) .gt. 0.0_DEFAULT_PRECISION) .and. (richardson_number(k) .lt. ric)) then
        rifac=(1.-richardson_number(k)*ricinv)**4
        
        fm(k) = rifac*(1.-subh*richardson_number(k))
        
        fh(k) = rifac*suba*(1.-subg*richardson_number(k))
                    
      else
        fm(k) = 0.0_DEFAULT_PRECISION
        fh(k) = 0.0_DEFAULT_PRECISION
      end if
            
    end do

    if (allocated(fm_diag)) fm_diag(:, target_y_index, target_x_index) = fm(:)
    if (allocated(fh_diag)) fh_diag(:, target_y_index, target_x_index) = fh(:)

         
  end subroutine setfri

  !> Calculates the eddy viscosity (VIS) and diffusivity (DIFF) depending on the Richardson Number (RI) and half
  !! squared strain rate
  !! @param current_state The current model state
  !! @param ssq The half squared strain rate
  subroutine set_vis_and_diff(current_state, ssq, fm, fh)
    type(model_state_type), target, intent(inout) :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:), intent(inout) :: ssq, fm, fh

    integer :: icol, jcol ! Shorthand column indices
    integer :: target_x_index, target_y_index
    integer :: k
    real(kind=DEFAULT_PRECISION) :: sctmp
    logical :: calcvis

    icol=current_state%column_local_x
    jcol=current_state%column_local_y

    target_x_index=icol-current_state%local_grid%halo_size(X_INDEX)
    target_y_index=jcol-current_state%local_grid%halo_size(Y_INDEX)

    if (current_state%immersed%ib_enabled) then
      
      do k=2, current_state%local_grid%size(Z_INDEX)-1
        ! solid, non ghost point
        if ((current_state%immersed%indic_w(k,current_state%column_local_y, current_state%column_local_x) .eq. 1) .and. &
            (.not. (current_state%immersed%ghost_w(k,current_state%column_local_y, current_state%column_local_x) .gt. 0 ))) then 
          current_state%vis_coefficient%data&
            (k, current_state%column_local_y, current_state%column_local_x)= 0.0_DEFAULT_PRECISION
          current_state%diff_coefficient%data&
            (k, current_state%column_local_y, current_state%column_local_x)= 0.0_DEFAULT_PRECISION
        end if
        calcvis=.false.
        if(current_state%immersed%indic_w(k,current_state%column_local_y, current_state%column_local_x) .eq. 0)then
          calcvis=.true.
        end if
        if((current_state%immersed%ib_type==1).and.&
           (current_state%immersed%ghost_w(k,current_state%column_local_y, current_state%column_local_x) .gt. 0 ))then
          calcvis=.false.
        end if
        if(calcvis)then
          ! fluid point  
          sctmp=current_state%global_grid%configuration%vertical%rneutml_sq(k)*sqrt(ssq(k))
          current_state%vis_coefficient%data(k, current_state%column_local_y, current_state%column_local_x)  = fm(k) * sctmp
          current_state%diff_coefficient%data(k, current_state%column_local_y, current_state%column_local_x) = fh(k) * sctmp     
        end if
      end do
  
    else
    
      do k=2,current_state%local_grid%size(Z_INDEX)-1
    
        sctmp=current_state%global_grid%configuration%vertical%rneutml_sq(k)*sqrt(ssq(k))
        current_state%vis_coefficient%data(k, current_state%column_local_y, current_state%column_local_x)  = fm(k) * sctmp
        current_state%diff_coefficient%data(k, current_state%column_local_y, current_state%column_local_x) = fh(k) * sctmp     
      
      end do
      
    end if ! not IB
    
    current_state%vis_coefficient%data(current_state%local_grid%size(Z_INDEX), &
           current_state%column_local_y, current_state%column_local_x)= 0.0_DEFAULT_PRECISION
    current_state%diff_coefficient%data(current_state%local_grid%size(Z_INDEX), &
           current_state%column_local_y, current_state%column_local_x)= 0.0_DEFAULT_PRECISION

    if (allocated(mom_ml_diag)) mom_ml_diag(:, target_y_index, target_x_index) = &
      current_state%global_grid%configuration%vertical%rneutml_sq(:)
    if (allocated(scalar_ml_diag)) scalar_ml_diag(:, target_y_index, target_x_index) = &
      current_state%global_grid%configuration%vertical%rneutml_sq(:)

  end subroutine set_vis_and_diff
   
  ! Alanna parametrization
  !> Updated calculation of the eddy viscosity (VIS) and diffusivity (DIFF) including the new parametrization of the 
  !! Smagorinsky parameter with height depending on the Richardson Number (RI) and half
  !! squared strain rate
  !! @param current_state The current model state
  !! @param ssq The half squared strain rate
  subroutine set_vis_and_diff_param(current_state, ssq, fm, fh, r_Cs_env_ml, r_Cs_IC_ml, r_Cth_env_ml, r_Cth_IC_ml)
    type(model_state_type), target, intent(inout) :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:), intent(in) :: ssq, fm, fh
    real(kind=DEFAULT_PRECISION), dimension(:), intent(in) :: r_Cs_env_ml, r_Cs_IC_ml, r_Cth_env_ml, r_Cth_IC_ml

    real(kind=DEFAULT_PRECISION) :: ml_sq, ml_sq_th, mod_s
    integer :: icol, jcol ! Shorthand column indices
    integer :: target_x_index, target_y_index
    integer :: k

    icol=current_state%column_local_x
    jcol=current_state%column_local_y

    target_x_index=icol-current_state%local_grid%halo_size(X_INDEX)
    target_y_index=jcol-current_state%local_grid%halo_size(Y_INDEX)

    do k=2,current_state%local_grid%size(Z_INDEX)-1

!      if (richardson_number(k) .le. 0.0_DEFAULT_PRECISION) then
!        current_state%vis_coefficient%data(k, current_state%column_local_y, current_state%column_local_x)=&
!             sqrt(1.0_DEFAULT_PRECISION-subc*richardson_number(k))
!        current_state%diff_coefficient%data(k, current_state%column_local_y, current_state%column_local_x)=&
!             suba*sqrt(1.-subb*richardson_number(k))        
!      else if ((richardson_number(k) .gt. 0.0_DEFAULT_PRECISION) .and. (richardson_number(k) .lt. ric)) then
!        rifac=(1.-richardson_number(k)*ricinv)**4
!        current_state%vis_coefficient%data(k, current_state%column_local_y, current_state%column_local_x)=&
!             rifac*(1.-subh*richardson_number(k))
!        current_state%diff_coefficient%data(k, current_state%column_local_y, current_state%column_local_x)=&
!             rifac*suba*(1.-subg*richardson_number(k))       
!      else
!        current_state%vis_coefficient%data(k, current_state%column_local_y, current_state%column_local_x)=0.0_DEFAULT_PRECISION
!        current_state%diff_coefficient%data(k, current_state%column_local_y, current_state%column_local_x)=0.0_DEFAULT_PRECISION
!      end if

      ml_sq =r_Cs_env_ml(k) * r_Cs_env_ml(k)
      ml_sq_th =r_Cth_env_ml(k) * r_Cth_env_ml(k)
      
      mod_s = sqrt(ssq(k))
      
      if (.not. current_state%passive_q .and. current_state%number_q_fields .gt. 0) then
        if (current_state%q(iql)%data(k, jcol, icol) .gt. cloud_thresh) then
		      ml_sq = r_Cs_IC_ml(k) * r_Cs_IC_ml(k)
		      ml_sq_th = r_Cth_IC_ml(k) * r_Cth_IC_ml(k)
		    end if
	    end if
	    
      current_state%vis_coefficient%data(k, jcol, icol) = fm(k) * ml_sq * mod_s
      current_state%diff_coefficient%data(k, jcol, icol)= fh(k) * ml_sq_th * mod_s    
      
      if (allocated(mom_ml_diag)) mom_ml_diag(k, target_y_index, target_x_index) = ml_sq
      if (allocated(scalar_ml_diag)) scalar_ml_diag(k, target_y_index, target_x_index) = ml_sq_th

    end do

    current_state%vis_coefficient%data(current_state%local_grid%size(Z_INDEX),  jcol, icol)= 0.0_DEFAULT_PRECISION
    current_state%diff_coefficient%data(current_state%local_grid%size(Z_INDEX), jcol, icol)= 0.0_DEFAULT_PRECISION

  end subroutine set_vis_and_diff_param
  ! Alanna parametrization end ----------------------------

  !> Calculates the richardson number depending upon the setup of the model and the method selected
  !! @param current_state The current model state
  !! @param ssq The half squared strain rate
  !! @returns The Richardson number for a specific column
  function calculate_richardson_number(current_state, ssq, th, q)
    type(model_state_type), target, intent(inout) :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:), intent(in) :: ssq
    type(prognostic_field_type), intent(inout) :: th
    type(prognostic_field_type), dimension(:), intent(inout) :: q
    real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)) :: calculate_richardson_number
    
    integer :: k

    if (.not. current_state%passive_th) then
      if (.not. current_state%passive_q) then
        if (RICHARDSON_NUMBER_CALCULATION .eq. 2) then
          calculate_richardson_number=moist_ri_2(current_state, ssq, th, q)
        else
          calculate_richardson_number=moist_ri_1(current_state, ssq, th, q)
        end if
      else
        do k=2, current_state%local_grid%size(Z_INDEX)-1
          calculate_richardson_number(k) = (current_state%global_grid%configuration%vertical%dthref(k) + &
               current_state%th%data(k+1, current_state%column_local_y, current_state%column_local_x) -&
               current_state%th%data(k, current_state%column_local_y, current_state%column_local_x))* &
               current_state%global_grid%configuration%vertical%rdzn(k+1)*&
               current_state%global_grid%configuration%vertical%buoy_co(k) / ssq(k) 
        end do
      end if
    else
      calculate_richardson_number=0.0_DEFAULT_PRECISION        
    end if
    
  end function calculate_richardson_number

  !> Calculates another "moist version" of the Richardson number based on "change in subgrid buoyancy flux 
  !! when a fraction EPS is exchanged"
  !! @param current_state The current model state
  !! @param ssq The half squared strain rate
  !! @returns The Richardson number calculated here for a specific column
  function moist_ri_2(current_state, ssq, th, q)
    type(model_state_type), target, intent(inout) :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:), intent(in) :: ssq
    type(prognostic_field_type), intent(inout) :: th
    type(prognostic_field_type), dimension(:), intent(inout) :: q
    real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)) :: moist_ri_2

    integer :: k
    real(kind=DEFAULT_PRECISION) :: tmpinv, scltmp, qt_k, qt_kp1, thlpr_k, thlpr_kp1, qlli, qlui, &
         thvli, thvui, thlpr_un, thlpr_ln, qtun, qtln, thvln, thvun, qlln, qlun

    do K=2,current_state%local_grid%size(Z_INDEX)-1
      tmpinv = 1.0_DEFAULT_PRECISION/ssq(k)
      scltmp=current_state%global_grid%configuration%vertical%rdzn(k+1)*&
           current_state%global_grid%configuration%vertical%buoy_co(k)
      if (current_state%use_anelastic_equations) then
        thcona=ratio_mol_wts*current_state%global_grid%configuration%vertical%thref(k)
        thconb=0.5_DEFAULT_PRECISION*(ratio_mol_wts-1.0_DEFAULT_PRECISION)*&
             (current_state%global_grid%configuration%vertical%thref(k)+&
             current_state%global_grid%configuration%vertical%thref(k+1))
        thconap1=ratio_mol_wts*current_state%global_grid%configuration%vertical%thref(k+1)
      end if    
      
      qt_k = q(current_state%water_vapour_mixing_ratio_index)%data(&
           k, current_state%column_local_y, current_state%column_local_x)+&
           q(current_state%liquid_water_mixing_ratio_index)%data(k, current_state%column_local_y, current_state%column_local_x)
      qt_kp1 = q(current_state%water_vapour_mixing_ratio_index)%data(&
           k+1, current_state%column_local_y, current_state%column_local_x)+&
           q(current_state%liquid_water_mixing_ratio_index)%data(k+1, current_state%column_local_y, current_state%column_local_x)
      thlpr_k = th%data(k, current_state%column_local_y, current_state%column_local_x) -&
           rlvap_over_cp*q(current_state%liquid_water_mixing_ratio_index)%data(&
           k, current_state%column_local_y, current_state%column_local_x)*&
           current_state%global_grid%configuration%vertical%prefrcp(k)
      ! calculate theta_l at constant (level K) pressure
      thlpr_kp1 = th%data(k+1, current_state%column_local_y, current_state%column_local_x) - &
           rlvap_over_cp*q(current_state%liquid_water_mixing_ratio_index)%data(&
           k+1, current_state%column_local_y, current_state%column_local_x)*&
           current_state%global_grid%configuration%vertical%prefrcp(k+1)

      !.......CALCULATE QL AND BUOYANCY OF LEVELS K AND K+1 (LOWER AND UPPER)
      !.......QL CALC AT CONSTANT PRESSURE
      qlli = max(0.0_DEFAULT_PRECISION, (qt_k-(current_state%global_grid%configuration%vertical%qsat(k) +&
           current_state%global_grid%configuration%vertical%dqsatdt(k)*&
           (current_state%global_grid%configuration%vertical%rprefrcp(k)*thlpr_k-&
           current_state%global_grid%configuration%vertical%tstarpr(k))))*&
           current_state%global_grid%configuration%vertical%qsatfac(k))
      qlui = max(0.0_DEFAULT_PRECISION, (qt_kp1-(current_state%global_grid%configuration%vertical%qsat(k+1) +&
           current_state%global_grid%configuration%vertical%dqsatdt(k+1)*&
           (current_state%global_grid%configuration%vertical%rprefrcp(k+1)*(thlpr_kp1+&
           current_state%global_grid%configuration%vertical%thref(k+1))-&
           current_state%global_grid%configuration%vertical%tstarpr(k+1)-&
           current_state%global_grid%configuration%vertical%tref(k+1))))*&
           current_state%global_grid%configuration%vertical%qsatfac(k+1))
      thvli = thlpr_k+current_state%global_grid%configuration%vertical%thref(k) +&
           ( rlvap_over_cp*current_state%global_grid%configuration%vertical%prefrcp(k)-thcona ) * qlli                         
      thvui = thlpr_kp1+current_state%global_grid%configuration%vertical%thref(k+1) +&
           ( rlvap_over_cp*current_state%global_grid%configuration%vertical%prefrcp(k+1)-thconap1 ) * qlui                       

      !.......MIX CONSERVATIVE QUANTITIES AT CONSTANT PRESSURE
      !.......NOTE THAT FOR COMPUTATIONAL CONVENIENCE THE RELEVANT LEVEL'S
      !.......THREF HAS BEEN OMITTED FROM ALL THV'S, THLPR_LN AND THLPR_UN AS
      !.......ONLY THE DIFFERENCE BETWEEN THV'S AT THE SAME LEVEL IS REQUIRED.
      thlpr_un = thlpr_kp1 - eps*(thlpr_kp1 - thlpr_k + current_state%global_grid%configuration%vertical%dthref(k))
      thlpr_ln = thlpr_k   + eps*(thlpr_kp1 - thlpr_k + current_state%global_grid%configuration%vertical%dthref(k))
      qtun     = qt_kp1    - eps*(qt_kp1 - qt_k) 
      qtln     = qt_k      + eps*(qt_kp1 - qt_k)
      !.......CALCULATE LIQUID WATER AND BUOYANCY OF MIXED AIR
      qlln = max(0.0_DEFAULT_PRECISION,( qtln - ( current_state%global_grid%configuration%vertical%qsat(k) +&
           current_state%global_grid%configuration%vertical%dqsatdt(k)*&
           (current_state%global_grid%configuration%vertical%rprefrcp(k)*&
           thlpr_ln-current_state%global_grid%configuration%vertical%tstarpr(k)))&
           )*current_state%global_grid%configuration%vertical%qsatfac(k))
      qlun = max(0.0_DEFAULT_PRECISION,( qtun - ( current_state%global_grid%configuration%vertical%qsat(k+1) + &
           current_state%global_grid%configuration%vertical%dqsatdt(k+1)*&
           (current_state%global_grid%configuration%vertical%rprefrcp(k+1)*&
           (thlpr_un+current_state%global_grid%configuration%vertical%thref(k+1))-&
           current_state%global_grid%configuration%vertical%tstarpr(k+1)-current_state%global_grid%configuration%vertical%tref(k+1)))&
           )*current_state%global_grid%configuration%vertical%qsatfac(k+1))
      thvln = thlpr_ln+current_state%global_grid%configuration%vertical%thref(k) +&
           ( rlvap_over_cp*current_state%global_grid%configuration%vertical%prefrcp(k)-thcona) * qlln
      thvun = thlpr_un+current_state%global_grid%configuration%vertical%thref(k+1) +&
           ( rlvap_over_cp*current_state%global_grid%configuration%vertical%prefrcp(k+1)-thconap1) * qlun

      !.....CHANGE IN BUOYANCY DUE TO FRAC MIXING IS USED TO DETERMINE l_ri
      moist_ri_2(k) = scltmp*tmpinv*(thconb*(qt_kp1-qt_k) +((thvln-thvli)-(thvun-thvui))*repsh)
    end do
  end function moist_ri_2

  !> Calculates numerator of Richarson number as the difference in buoyancy between a parcel at K+1 and a parcel lifted from
  !! K to K+1. Condensation is calculated by assuming that TL=T-(Lv/CP)*QL+gz/CP and QT = QV+QL are conserved on lifting.
  !! Microphysics conversions are assumed to happen slowly compared to turbulent processes so are, therefore, neglected
  !! in the calculation.
  !! @param current_state The current model state
  !! @param ssq The half squared strain rate
  !! @returns The Richardson number calculated here for a specific column
  function moist_ri_1(current_state, ssq, th, q)
    type(model_state_type), target, intent(inout) :: current_state
    real(kind=DEFAULT_PRECISION), dimension(:), intent(in) :: ssq
    type(prognostic_field_type), intent(inout) :: th
    type(prognostic_field_type), dimension(:), intent(inout) :: q
    real(kind=DEFAULT_PRECISION), dimension(current_state%local_grid%size(Z_INDEX)) :: moist_ri_1

    integer :: k
    real(kind=DEFAULT_PRECISION) :: liquid_water_at_kp1, temperature_at_kp1, dtlref, tmpinv, &
         liquid_water_static_energy_temperature, total_water_substance, total_water_substance_p1, scltmp, qloading

    ! Set up the liquid water static energy & total water
    do k=2, current_state%local_grid%size(Z_INDEX)
      liquid_water_static_energy_temperature = &
           th%data(k, current_state%column_local_y, current_state%column_local_x)*&
           current_state%global_grid%configuration%vertical%rprefrcp(k) - rlvap_over_cp*&
           q(current_state%liquid_water_mixing_ratio_index)%data(k, current_state%column_local_y, current_state%column_local_x)
      if (k==2) then
        total_water_substance = q(current_state%water_vapour_mixing_ratio_index)%data(&
             k, current_state%column_local_y, current_state%column_local_x) + &
             q(current_state%liquid_water_mixing_ratio_index)%data(k, current_state%column_local_y, current_state%column_local_x)
      else
        total_water_substance=total_water_substance_p1
      end if
      total_water_substance_p1 = q(current_state%water_vapour_mixing_ratio_index)%data(&
           k+1, current_state%column_local_y, current_state%column_local_x) + &
           q(current_state%liquid_water_mixing_ratio_index)%data(k+1, current_state%column_local_y, current_state%column_local_x)
      if (k .le. current_state%local_grid%size(Z_INDEX)-1) then
        tmpinv = 1.0_DEFAULT_PRECISION/ssq(k)
        dtlref = current_state%global_grid%configuration%vertical%tref(k+1)-&
             current_state%global_grid%configuration%vertical%tref(k)+(G/cp)*&
             current_state%global_grid%configuration%vertical%dzn(k+1)
        temperature_at_kp1=current_state%global_grid%configuration%vertical%tstarpr(k+1)+&
             current_state%global_grid%configuration%vertical%tref(k+1)+&
             (liquid_water_static_energy_temperature+rlvap_over_cp*(total_water_substance-&
             current_state%global_grid%configuration%vertical%qsat(k+1)) - &
             dtlref - current_state%global_grid%configuration%vertical%tstarpr(k+1) )*&
             current_state%global_grid%configuration%vertical%qsatfac(k+1)
        liquid_water_at_kp1=total_water_substance -( current_state%global_grid%configuration%vertical%qsat(k+1)+&
             current_state%global_grid%configuration%vertical%dqsatdt(k+1)*(temperature_at_kp1- &
             current_state%global_grid%configuration%vertical%tstarpr(k+1)-&
             current_state%global_grid%configuration%vertical%tref(k+1)) )
        if (liquid_water_at_kp1 .le. 0.0_DEFAULT_PRECISION) then
          liquid_water_at_kp1=0.0_DEFAULT_PRECISION
          temperature_at_kp1=current_state%global_grid%configuration%vertical%tref(k+1)+&
               (liquid_water_static_energy_temperature-dtlref)
        end if
        scltmp=current_state%global_grid%configuration%vertical%rdzn(k+1)*&
             current_state%global_grid%configuration%vertical%buoy_co(k)
        ! Calculate the Richardson number taking into account the water
        ! loading terms from the other hydrometeors in the buoyancy
        ! calculation
        qloading = current_state%cq(current_state%water_vapour_mixing_ratio_index)*&
             (total_water_substance_p1-total_water_substance)-ratio_mol_wts*&
             (q(current_state%liquid_water_mixing_ratio_index)%data(&
             k+1, current_state%column_local_y, current_state%column_local_x)-liquid_water_at_kp1)
        !if(IRAINP.gt.0) qloading = qloading + current_state%cq(IQR)*(l_q(J,K+1,IQR)-l_q(J,K,IQR))
        !if(ISNOWP.gt.0) qloading = qloading + current_state%cq(IQS)*(l_q(J,K+1,IQS)-l_q(J,K,IQS))
        !if(ICECLP.gt.0) qloading = qloading + current_state%cq(IQI)*(l_q(J,K+1,IQI)-l_q(J,K,IQI))
        !if(IGRAUP.gt.0) qloading = qloading + currnet_state%cq(IQG)*(l_q(J,K+1,IQG)-l_q(J,K,IQG))

        moist_ri_1(k) = ((th%data(k+1, current_state%column_local_y, current_state%column_local_x)+&
             current_state%global_grid%configuration%vertical%thref(k+1) - temperature_at_kp1*&
             current_state%global_grid%configuration%vertical%prefrcp(k+1))&
             +current_state%global_grid%configuration%vertical%thref(k+1)*qloading)*scltmp*tmpinv
      end if
    end do
  end function moist_ri_1  
  
  !> Calculates the half squared strain rate on l_w-points which is used in determining the Richardson number. 
  !! CX=1./DX, CY=1./DY, RDZ(K)=1./DZ(K), RDZN(K) =1./DZN(K)
  !! SSQ= 0.5*(DU_I/DX_J+DU_J/DX_I)**2
  !! SSQIJ= (DU_I/DX_J+DU_J/DX_I)**2
  !! Hence SSQ= SUM(I,J) {0.5*(SSQIJ)}
  !! @param current_state The current model state
  !! @returns The hard squared strain rate for a specific column
  function calculate_half_squared_strain_rate(current_state, u, v, w)
    type(model_state_type), target, intent(inout) :: current_state
    type(prognostic_field_type), intent(inout) :: u, v, w
    real(kind=DEFAULT_PRECISION) :: calculate_half_squared_strain_rate(current_state%local_grid%size(Z_INDEX))

    real(kind=DEFAULT_PRECISION) :: ssq11, ssq22, ssq33, ssq13, ssq23, ssq12

    integer :: k

    do k=2,current_state%local_grid%size(Z_INDEX)-1   
#ifdef U_ACTIVE    
      ssq11=current_state%global_grid%configuration%horizontal%cx2*(&
           (u%data(k+1, current_state%column_local_y, current_state%column_local_x)-&
            u%data(k+1, current_state%column_local_y, current_state%column_local_x-1))**2+&
           (u%data(k, current_state%column_local_y, current_state%column_local_x)-&
            u%data(k, current_state%column_local_y, current_state%column_local_x-1))**2)
#else
      ssq11=0.0_DEFAULT_PRECISION
#endif
#ifdef V_ACTIVE
      ssq22=current_state%global_grid%configuration%horizontal%cy2*(&
           (v%data(k+1, current_state%column_local_y, current_state%column_local_x)-&
            v%data(k+1, current_state%column_local_y-1, current_state%column_local_x))**2+&
           (v%data(k, current_state%column_local_y, current_state%column_local_x)-&
            v%data(k, current_state%column_local_y-1, current_state%column_local_x))**2)
#else
      ssq22=0.0_DEFAULT_PRECISION
#endif
#ifdef W_ACTIVE
      ssq33=((w%data(k, current_state%column_local_y, current_state%column_local_x)-&
              w%data(k-1, current_state%column_local_y, current_state%column_local_x))*&
             current_state%global_grid%configuration%vertical%rdz(k))**2 +&
            ((w%data(k+1, current_state%column_local_y, current_state%column_local_x)-&
              w%data(k, current_state%column_local_y, current_state%column_local_x))*&
             current_state%global_grid%configuration%vertical%rdz(k+1))**2
#else
      ssq33=0.0_DEFAULT_PRECISION
#endif
#if defined(U_ACTIVE) && defined(W_ACTIVE)
      ! Average over 2 points U and W
      ssq13=(((u%data(k+1, current_state%column_local_y, current_state%column_local_x)-&
               u%data(k, current_state%column_local_y, current_state%column_local_x))*&
              current_state%global_grid%configuration%vertical%rdzn(k+1)+&
              (w%data(k, current_state%column_local_y, current_state%column_local_x+1)-&
               w%data(k, current_state%column_local_y, current_state%column_local_x))*&
              current_state%global_grid%configuration%horizontal%cx)**2+&
             ((u%data(k+1, current_state%column_local_y, current_state%column_local_x-1)-&
               u%data(k, current_state%column_local_y, current_state%column_local_x-1))*&
              current_state%global_grid%configuration%vertical%rdzn(k+1)+&
              (w%data(k, current_state%column_local_y, current_state%column_local_x)-&
               w%data(k, current_state%column_local_y, current_state%column_local_x-1))*&
              current_state%global_grid%configuration%horizontal%cx)**2)*0.5_DEFAULT_PRECISION
#elif defined(U_ACTIVE) && !defined(W_ACTIVE)
      ssq13=(((u%data(k+1, current_state%column_local_y, current_state%column_local_x)-&
               u%data(k, current_state%column_local_y, current_state%column_local_x))*&
              current_state%global_grid%configuration%vertical%rdzn(k+1))**2+&
             ((u%data(k+1, current_state%column_local_y, current_state%column_local_x-1)-&
               u%data(k, current_state%column_local_y, current_state%column_local_x-1))*&
              current_state%global_grid%configuration%vertical%rdzn(k+1))**2)*0.5_DEFAULT_PRECISION
#elif !defined(U_ACTIVE) && defined(W_ACTIVE)
      ssq13=(((w%data(k, current_state%column_local_y, current_state%column_local_x+1)-&
               w%data(k, current_state%column_local_y, current_state%column_local_x))*&
              current_state%global_grid%configuration%horizontal%cx)**2+&
             ((w%data(k, current_state%column_local_y, current_state%column_local_x)-&
               w%data(k, current_state%column_local_y, current_state%column_local_x-1))*&
              current_state%global_grid%configuration%horizontal%cx)**2)*0.5_DEFAULT_PRECISION
#else
      ssq13=0.0_DEFAULT_PRECISION
#endif
#if defined(W_ACTIVE) && defined(V_ACTIVE)
      ! Average over 2 points W and V
      ssq23=(((w%data(k, current_state%column_local_y, current_state%column_local_x)-&
               w%data(k, current_state%column_local_y-1, current_state%column_local_x))*&
              current_state%global_grid%configuration%horizontal%cy+&
              (v%data(k+1, current_state%column_local_y-1, current_state%column_local_x)-&
               v%data(k, current_state%column_local_y-1, current_state%column_local_x))*&
              current_state%global_grid%configuration%vertical%rdzn(k+1))**2+&
             ((w%data(k, current_state%column_local_y+1, current_state%column_local_x)-&
               w%data(k, current_state%column_local_y, current_state%column_local_x))*&
              current_state%global_grid%configuration%horizontal%cy+&
              (v%data(k+1, current_state%column_local_y, current_state%column_local_x)-&
               v%data(k, current_state%column_local_y, current_state%column_local_x))*&
              current_state%global_grid%configuration%vertical%rdzn(k+1))**2)*0.5_DEFAULT_PRECISION
#elif defined(W_ACTIVE) && !defined(V_ACTIVE)
      ssq23=(((w%data(k, current_state%column_local_y, current_state%column_local_x)-&
               w%data(k, current_state%column_local_y-1, current_state%column_local_x))*&
              current_state%global_grid%configuration%horizontal%cy)**2+&
             ((w%data(k, current_state%column_local_y+1, current_state%column_local_x)-&
               w%data(k, current_state%column_local_y, current_state%column_local_x))*&
              current_state%global_grid%configuration%horizontal%cy)**2)*0.5_DEFAULT_PRECISION
#elif !defined(W_ACTIVE) && defined(V_ACTIVE)
      ssq23=(((v%data(k+1, current_state%column_local_y-1, current_state%column_local_x)-&
               v%data(k, current_state%column_local_y-1, current_state%column_local_x))*&
              current_state%global_grid%configuration%vertical%rdzn(k+1))**2+&
             ((v%data(k+1, current_state%column_local_y, current_state%column_local_x)-&
               v%data(k, current_state%column_local_y, current_state%column_local_x))*&
              current_state%global_grid%configuration%vertical%rdzn(k+1))**2)*0.5_DEFAULT_PRECISION
#else
      ssq23=0.0_DEFAULT_PRECISION
#endif

#if defined(U_ACTIVE) && defined(V_ACTIVE)
      ! Average over 8 points from U and V
      ssq12=(((((u%data(k, current_state%column_local_y, current_state%column_local_x-1)-&
                 u%data(k, current_state%column_local_y-1, current_state%column_local_x-1))*&
                current_state%global_grid%configuration%horizontal%cy+&
                (v%data(k, current_state%column_local_y-1, current_state%column_local_x)-&
                 v%data(k, current_state%column_local_y-1, current_state%column_local_x-1))*&
                current_state%global_grid%configuration%horizontal%cx)**2 +&
               ((u%data(k, current_state%column_local_y+1, current_state%column_local_x-1)-&
                 u%data(k, current_state%column_local_y, current_state%column_local_x-1))*&
                current_state%global_grid%configuration%horizontal%cy+&
                (v%data(k, current_state%column_local_y, current_state%column_local_x)-&
                 v%data(k, current_state%column_local_y, current_state%column_local_x-1))*&
                current_state%global_grid%configuration%horizontal%cx)**2) +(&
               ((u%data(k, current_state%column_local_y, current_state%column_local_x)-&
                 u%data(k, current_state%column_local_y-1, current_state%column_local_x))*&
                current_state%global_grid%configuration%horizontal%cy+&
                (v%data(k, current_state%column_local_y-1, current_state%column_local_x+1)-&
                 v%data(k, current_state%column_local_y-1, current_state%column_local_x))*&
                current_state%global_grid%configuration%horizontal%cx)**2 +&
               ((u%data(k, current_state%column_local_y+1, current_state%column_local_x)-&
                 u%data(k, current_state%column_local_y, current_state%column_local_x))*&
                current_state%global_grid%configuration%horizontal%cy+&
                (v%data(k, current_state%column_local_y, current_state%column_local_x+1)-&
                 v%data(k, current_state%column_local_y, current_state%column_local_x))*&
                current_state%global_grid%configuration%horizontal%cx)**2))+((&
               ((u%data(k+1, current_state%column_local_y, current_state%column_local_x-1)-&
                 u%data(k+1, current_state%column_local_y-1, current_state%column_local_x-1))*&
                current_state%global_grid%configuration%horizontal%cy+&
                (v%data(k+1, current_state%column_local_y-1, current_state%column_local_x)-&
                 v%data(k+1, current_state%column_local_y-1, current_state%column_local_x-1))*&
                current_state%global_grid%configuration%horizontal%cx)**2+&
               ((u%data(k+1, current_state%column_local_y+1, current_state%column_local_x-1)-&
                 u%data(k+1, current_state%column_local_y, current_state%column_local_x-1))*&
                current_state%global_grid%configuration%horizontal%cy+&
                (v%data(k+1, current_state%column_local_y, current_state%column_local_x)-&
                 v%data(k+1, current_state%column_local_y, current_state%column_local_x-1))*&
                current_state%global_grid%configuration%horizontal%cx)**2)+(&
               ((u%data(k+1, current_state%column_local_y, current_state%column_local_x)-&
                 u%data(k+1, current_state%column_local_y-1, current_state%column_local_x))*&
                current_state%global_grid%configuration%horizontal%cy+&
                (v%data(k+1, current_state%column_local_y-1, current_state%column_local_x+1)-&
                 v%data(k+1, current_state%column_local_y-1, current_state%column_local_x))*&
                current_state%global_grid%configuration%horizontal%cx)**2+&
               ((u%data(k+1, current_state%column_local_y+1, current_state%column_local_x)-&
                 u%data(k+1, current_state%column_local_y, current_state%column_local_x))*&
                current_state%global_grid%configuration%horizontal%cy+&
                (v%data(k+1, current_state%column_local_y, current_state%column_local_x+1)-&
                 v%data(k+1, current_state%column_local_y, current_state%column_local_x))*&
                current_state%global_grid%configuration%horizontal%cx)**2)))*0.125_DEFAULT_PRECISION

#elif defined(U_ACTIVE) && !defined(V_ACTIVE)

      ssq12=(((((u%data(k, current_state%column_local_y, current_state%column_local_x-current_state%local_grid%size(Z_INDEX)1)-&
                 u%data(k, current_state%column_local_y-1, current_state%column_local_x-1))*&
                current_state%global_grid%configuration%horizontal%cy)**2 +&
               ((u%data(k, current_state%column_local_y+1, current_state%column_local_x-1)-&
                 u%data(k, current_state%column_local_y, current_state%column_local_x-1))*&
                current_state%global_grid%configuration%horizontal%cy)**2) +(&
               ((u%data(k, current_state%column_local_y, current_state%column_local_x)-&
                 u%data(k, current_state%column_local_y-1, current_state%column_local_x))*&
                current_state%global_grid%configuration%horizontal%cy)**2 +&
               ((u%data(k, current_state%column_local_y+1, current_state%column_local_x)-&
                 u%data(k, current_state%column_local_y, current_state%column_local_x))*&
                current_state%global_grid%configuration%horizontal%cy)**2))+((&
               ((u%data(k+1, current_state%column_local_y, current_state%column_local_x-1)-&
                 u%data(k+1, current_state%column_local_y-1, current_state%column_local_x-1))*&
                current_state%global_grid%configuration%horizontal%cy)**2+&
               ((u%data(k+1, current_state%column_local_y+1, current_state%column_local_x-1)-&
                 u%data(k+1, current_state%column_local_y, current_state%column_local_x-1))*&
                current_state%global_grid%configuration%horizontal%cy)**2)+(&
               ((u%data(k+1, current_state%column_local_y, current_state%column_local_x)-&
                 u%data(k+1, current_state%column_local_y-1, current_state%column_local_x))*&
                current_state%global_grid%configuration%horizontal%cy)**2+&
               ((u%data(k+1, current_state%column_local_y+1, current_state%column_local_x)-&
                 u%data(k+1, current_state%column_local_y, current_state%column_local_x))*&
                current_state%global_grid%configuration%horizontal%cy)**2)))*0.125_DEFAULT_PRECISION

#elif !defined(U_ACTIVE) && defined(V_ACTIVE)

      ssq12=(((((v%data(k, current_state%column_local_y-1, current_state%column_local_x)-&
                 v%data(k, current_state%column_local_y-1, current_state%column_local_x-1))*&
                current_state%global_grid%configuration%horizontal%cx)**2 +&
               ((v%data(k, current_state%column_local_y, current_state%column_local_x)-&current_state%local_grid%size(Z_INDEX)
                 v%data(k, current_state%column_local_y, current_state%column_local_x-1))*&
                current_state%global_grid%configuration%horizontal%cx)**2) +&
              (((v%data(k, current_state%column_local_y-1, current_state%column_local_x+1)-&
                 v%data(k, current_state%column_local_y-1, current_state%column_local_x))*&
                current_state%global_grid%configuration%horizontal%cx)**2 +&
               ((v%data(k, current_state%column_local_y, current_state%column_local_x+1)-&
                 v%data(k, current_state%column_local_y, current_state%column_local_x))*&
                current_state%global_grid%configuration%horizontal%cx)**2))+((&
               ((v%data(k+1, current_state%column_local_y-1, current_state%column_local_x)-&
                 v%data(k+1, current_state%column_local_y-1, current_state%column_local_x-1))*&
                current_state%global_grid%configuration%horizontal%cx)**2+&
               ((v%data(k+1, current_state%column_local_y, current_state%column_local_x)-&
                 v%data(k+1, current_state%column_local_y, current_state%column_local_x-1))*&
                current_state%global_grid%configuration%horizontal%cx)**2)+(&
               ((v%data(k+1, current_state%column_local_y-1, current_state%column_local_x+1)-&
                 v%data(k+1, current_state%column_local_y-1, current_state%column_local_x))*&
                current_state%global_grid%configuration%horizontal%cx)**2+&
               ((v%data(k+1, current_state%column_local_y, current_state%column_local_x+1)-&
                 v%data(k+1, current_state%column_local_y, current_state%column_local_x))*&
                current_state%global_grid%configuration%horizontal%cx)**2)))*0.125_DEFAULT_PRECISION
#else
      ssq12=0.0_DEFAULT_PRECISION
#endif
      calculate_half_squared_strain_rate(k)=ssq11+ssq22+ssq33+ssq13+ssq23+ssq12+smallp
    end do
    
    calculate_half_squared_strain_rate(1) = calculate_half_squared_strain_rate(2)
    calculate_half_squared_strain_rate(current_state%local_grid%size(Z_INDEX)) = 0.0_DEFAULT_PRECISION
    
  end function calculate_half_squared_strain_rate

!===========================================
  !! @param current_state The current model state
  !! @returns The thermal dissiptation rate for a specific column: backscatter is NOT included -- exercise for partners
  function calculate_thermal_dissipation_rate(current_state, th)
    type(model_state_type), target, intent(inout) :: current_state
    type(prognostic_field_type), intent(inout) :: th
    real(kind=DEFAULT_PRECISION) :: calculate_thermal_dissipation_rate(current_state%local_grid%size(Z_INDEX))

    integer :: k

    do k=2,current_state%local_grid%size(Z_INDEX)-1
      calculate_thermal_dissipation_rate(k) = &
        current_state%diff_coefficient%data(k, current_state%column_local_y, current_state%column_local_x) * ( &
          (current_state%global_grid%configuration%vertical%rdzn(k+1) * &
            (current_state%th%data(k+1, current_state%column_local_y, current_state%column_local_x) - &
             current_state%th%data(k, current_state%column_local_y, current_state%column_local_x) - &
             current_state%global_grid%configuration%vertical%dthref(k) ) ) ** 2 + &
          0.25 * current_state%global_grid%configuration%horizontal%cx2 * &
            ( (current_state%th%data(k, current_state%column_local_y, current_state%column_local_x+1) - &
               current_state%th%data(k, current_state%column_local_y, current_state%column_local_x) ) ** 2 + &
              (current_state%th%data(k, current_state%column_local_y, current_state%column_local_x) - &
               current_state%th%data(k, current_state%column_local_y, current_state%column_local_x-1) ) ** 2 + &
              (current_state%th%data(k+1, current_state%column_local_y, current_state%column_local_x+1) - &
               current_state%th%data(k+1, current_state%column_local_y, current_state%column_local_x) ) **2 + &
              (current_state%th%data(k+1, current_state%column_local_y, current_state%column_local_x) - &
               current_state%th%data(k+1, current_state%column_local_y, current_state%column_local_x-1) ) ** 2 ) + &
          0.25 * current_state%global_grid%configuration%horizontal%cy2 * &
            ( (current_state%th%data(k, current_state%column_local_y+1, current_state%column_local_x) - &
               current_state%th%data(k, current_state%column_local_y, current_state%column_local_x) ) ** 2 + &
              (current_state%th%data(k, current_state%column_local_y, current_state%column_local_x) - &
               current_state%th%data(k, current_state%column_local_y-1, current_state%column_local_x) ) ** 2 + &
              (current_state%th%data(k+1, current_state%column_local_y+1, current_state%column_local_x) - &
               current_state%th%data(k+1, current_state%column_local_y, current_state%column_local_x) ) **2 + &
              (current_state%th%data(k+1, current_state%column_local_y, current_state%column_local_x) - &
               current_state%th%data(k+1, current_state%column_local_y-1, current_state%column_local_x) ) ** 2 ) )
    end do

  end function calculate_thermal_dissipation_rate

!===========================================

  !> Copies the viscosity field data to halo buffers for a specific process in a dimension and halo cell
  !! @param current_state The current model state
  !! @param neighbour_descriptions Description of the neighbour halo swapping status
  !! @param dim Dimension to copy from
  !! @param source_index The source index of the dimension we are reading from in the prognostic field
  !! @param pid_location Location of the neighbouring process in the local stored data structures
  !! @param current_page The current (next) buffer page to copy into
  !! @param source_data Optional source data which is read from
  subroutine copy_vis_to_halo_buffer(current_state, neighbour_description, dim, source_index, &
       pid_location, current_page, source_data)
    type(model_state_type), intent(inout) :: current_state
    integer, intent(in) :: dim, pid_location, source_index
    integer, intent(inout) :: current_page(:)
    type(neighbour_description_type), intent(inout) :: neighbour_description
    type(field_data_wrapper_type), dimension(:), intent(in), optional :: source_data

    call copy_field_to_buffer(current_state%local_grid, neighbour_description%send_halo_buffer, &
         current_state%vis_coefficient%data, dim, source_index, current_page(pid_location))

    current_page(pid_location)=current_page(pid_location)+1
  end subroutine copy_vis_to_halo_buffer

  !> Copies the viscosity field corner data to halo buffers for a specific process
  !! @param current_state The current model state
  !! @param neighbour_descriptions Description of the neighbour halo swapping status
  !! @param corner_loc The corner location
  !! @param x_source_index The X source index of the dimension we are reading from in the prognostic field
  !! @param y_source_index The Y source index of the dimension we are reading from in the prognostic field
  !! @param pid_location Location of the neighbouring process in the local stored data structures
  !! @param current_page The current (next) buffer page to copy into
  !! @param source_data Optional source data which is read from
  subroutine copy_vis_corners_to_halo_buffer(current_state, neighbour_description, corner_loc, x_source_index, y_source_index, &
       pid_location, current_page, source_data)
    type(model_state_type), intent(inout) :: current_state
    integer, intent(in) :: corner_loc, pid_location, x_source_index, y_source_index
    integer, intent(inout) :: current_page(:)
    type(neighbour_description_type), intent(inout) :: neighbour_description
    type(field_data_wrapper_type), dimension(:), intent(in), optional :: source_data

    call copy_corner_to_buffer(current_state%local_grid, neighbour_description%send_corner_buffer, &
         current_state%vis_coefficient%data, corner_loc, x_source_index, y_source_index, current_page(pid_location))

    current_page(pid_location)=current_page(pid_location)+1
  end subroutine copy_vis_corners_to_halo_buffer 

  !> Copies the diffusion field data to halo buffers for a specific process in a dimension and halo cell
  !! @param current_state The current model state
  !! @param neighbour_descriptions Description of the neighbour halo swapping status
  !! @param dim Dimension to copy from
  !! @param source_index The source index of the dimension we are reading from in the prognostic field
  !! @param pid_location Location of the neighbouring process in the local stored data structures
  !! @param current_page The current (next) buffer page to copy into
  !! @param source_data Optional source data which is read from
  subroutine copy_diff_to_halo_buffer(current_state, neighbour_description, dim, source_index, &
       pid_location, current_page, source_data)
    type(model_state_type), intent(inout) :: current_state
    integer, intent(in) :: dim, pid_location, source_index
    integer, intent(inout) :: current_page(:)
    type(neighbour_description_type), intent(inout) :: neighbour_description
    type(field_data_wrapper_type), dimension(:), intent(in), optional :: source_data

    call copy_field_to_buffer(current_state%local_grid, neighbour_description%send_halo_buffer, &
         current_state%diff_coefficient%data, dim, source_index, current_page(pid_location))

    current_page(pid_location)=current_page(pid_location)+1
  end subroutine copy_diff_to_halo_buffer

  !> Copies the diffusion field corner data to halo buffers for a specific process
  !! @param current_state The current model state
  !! @param neighbour_descriptions Description of the neighbour halo swapping status
  !! @param corner_loc The corner location
  !! @param x_source_index The X source index of the dimension we are reading from in the prognostic field
  !! @param y_source_index The Y source index of the dimension we are reading from in the prognostic field
  !! @param pid_location Location of the neighbouring process in the local stored data structures
  !! @param current_page The current (next) buffer page to copy into
  !! @param source_data Optional source data which is read from
  subroutine copy_diff_corners_to_halo_buffer(current_state, neighbour_description, corner_loc, x_source_index, y_source_index, &
       pid_location, current_page, source_data)
    type(model_state_type), intent(inout) :: current_state
    integer, intent(in) :: corner_loc, pid_location, x_source_index, y_source_index
    integer, intent(inout) :: current_page(:)
    type(neighbour_description_type), intent(inout) :: neighbour_description
    type(field_data_wrapper_type), dimension(:), intent(in), optional :: source_data

    call copy_corner_to_buffer(current_state%local_grid, neighbour_description%send_corner_buffer, &
         current_state%diff_coefficient%data, corner_loc, x_source_index, y_source_index, current_page(pid_location))

    current_page(pid_location)=current_page(pid_location)+1
  end subroutine copy_diff_corners_to_halo_buffer

end module smagorinsky_mod
