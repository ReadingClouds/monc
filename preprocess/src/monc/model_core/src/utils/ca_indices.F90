










!> This manages the circle_a variables and specifically the mapping between names and the index that they are stored at
module ca_indices_mod
  use conversions_mod, only : conv_to_string
  use logging_mod, only : LOG_INFO, LOG_ERROR, log_master_log
  implicit none

  private

  integer, parameter :: n_maxcas=100 !< Maximum number of ca variables to manage
  integer, parameter :: n_maxcaname=100 !< Length to allocate for a ca variable name

  !< Internal storage type for tracking the ca variable states
  type :: ca_metadata_type
     character(n_maxcaname) :: name
     logical :: l_used=.false.
  end type ca_metadata_type
  
  !< Register of the ca variables
  type(ca_metadata_type) :: ca_register(n_maxcas)

  ! standard names
  type :: standard_ca_names_type
     character(LEN=3 ) :: TKE                    = 'tke' 
     character(LEN=7 ) :: THL_THL                = 'thl_thl' 
     character(LEN=5 ) :: QT_QT                  = 'qt_qt' 
     character(LEN=6 ) :: THL_QT                 = 'thl_qt' 
     character(LEN=3 ) :: U_U                    = 'u_u' 
     character(LEN=3 ) :: U_V                    = 'u_v' 
     character(LEN=3 ) :: U_W                    = 'u_w' 
     character(LEN=3 ) :: V_V                    = 'v_v' 
     character(LEN=3 ) :: V_W                    = 'v_w' 
     character(LEN=3 ) :: W_W                    = 'w_w' 
     character(LEN=5 ) :: U_THL                  = 'u_thl' 
     character(LEN=5 ) :: V_THL                  = 'v_thl' 
     character(LEN=5 ) :: W_THL                  = 'w_thl' 
     character(LEN=4 ) :: U_QT                   = 'u_qt' 
     character(LEN=4 ) :: V_QT                   = 'v_qt' 
     character(LEN=4 ) :: W_QT                   = 'w_qt' 
  end type standard_ca_names_type

  type(standard_ca_names_type) :: standard_ca_names

  public ca_metadata_type, get_ca_index, get_ca_indices_descriptor, get_max_number_ca_indices, &
       get_number_active_ca_indices, set_ca_index, standard_ca_names

contains

  !> Sets a ca index to be active at a specific index and sets the name
  !! @param index The index to set the ca index at
  !! @param name The name to set as the ca index name
  subroutine set_ca_index(index, name)
    integer, intent(in) :: index
    character(len=*), intent(in) :: name

    ca_register(index)%name=adjustr(trim(name))
    ca_register(index)%l_used=.true.
  end subroutine set_ca_index  

  !> Gets the maximum number of ca indicies
  !! @returns The maximum number of ca indicies
  integer function get_max_number_ca_indices()
    get_max_number_ca_indices=n_maxcas
  end function get_max_number_ca_indices

  !> Gets the number of active ca indicies (i.e. those allocated to specific uses)
  !! @returns The number of active ca indicies
  integer function get_number_active_ca_indices()

    integer :: i

    get_number_active_ca_indices=0
    do i=1, n_maxcas
      if (ca_register(i)%l_used) get_number_active_ca_indices=get_number_active_ca_indices+1
    end do    
  end function get_number_active_ca_indices  

  !> Retrieves the indicies descriptor at a specific location
  !! @param i The index to retrieve the descriptor at
  !! @returns The corresponding descriptor
  function get_ca_indices_descriptor(i)
    integer :: i
    type(ca_metadata_type) :: get_ca_indices_descriptor
    
    get_ca_indices_descriptor=ca_register(i)
  end function get_ca_indices_descriptor  

  !> Add in a new entry into the register if the name does
  !! not already exist or return the index of the pre-existing variable.
  !! @param name variable name
  !! @param assigning_component name of component which is assigning this variable
  !! @returns The variable index
  integer function get_ca_index(name, assigning_component)
    character(*), intent(in) :: name
    character(*), optional :: assigning_component

    integer :: iname, i_unused

    i_unused=0
    
    do iname=n_maxcas, 1, -1
      if (trim(name) == trim(ca_register(iname)%name)) then
        ! Here we find the variable has already been added
        get_ca_index=iname
        return
      end if
      ! Counting backwards we will eventually find the first open slot
      if (.not. ca_register(iname)%l_used) then
        i_unused=iname
      end if
    end do

    if (i_unused == 0) then
      call log_master_log(LOG_ERROR, 'Somehow we need to extend ca_register')
    end if

    ! Not already defined, so populate the empty slot
    get_ca_index=i_unused
    ca_register(get_ca_index)%name = adjustr(trim(name))
    ca_register(get_ca_index)%l_used = .true.

    if (present(assigning_component)) then
      call log_master_log(LOG_INFO, 'ca variable #'//trim(conv_to_string(get_ca_index))//' is assigned to '//trim(name)//&
           '. Assigned from component: '//trim(assigning_component))
    else
      call log_master_log(LOG_INFO, 'ca variable #'//trim(conv_to_string(get_ca_index))//' is assigned to '//trim(name))
    end if

  end function get_ca_index
end module ca_indices_mod
