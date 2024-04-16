program fortranTest
    implicit none !important
    !comments

    integer, parameter :: ikind=selected_real_kind(p=15) !to have 15 floating point precision

    character :: name*10 ! *n to declare the length of the string
    integer :: i
    real(kind=ikind) :: x, y, z !real (//float in C) with the setprecision we want with ikind
    double precision :: a !it's a double // in C

    real, dimension(3) :: list !dimension 3 list

    real, allocatable, dimension(:) :: array
    integer :: elements

    real, dimension(3:3) :: matrix ! banger

    if ( 1 == 2 ) z = 10.0_ikind / 3.0_ikind ! .0_ikind to have the precision we want...

    if ( 1 == 2 ) then !then // with { in C
        print *, "haha c koi ton non"
        read *, name
        print *, "moi c ", name
    end if

    if ( 1 == 2 ) print *, "oui" !no need for then if in one line

    if ( 1 == 2 ) then
        do i = 20,10,-2 !start,end,step
            print *, i
        end do
    end if 

    if ( 1 == 2 ) then
        open(12, file="mydata.txt") !le 12 c'est au pif
        write(12,*) 1.0
        write(12,*) 2.0
        write(12,*) 3.0
        close(12)

        open(10, file="mydata.txt")
        read(10,*) x, y, z
        close(10)

        print *, x, y, z
    end if

    if ( 1 == 2) then
        open(13, file="mytable.txt")
        print *,"           x           y           z"
        write(13,*) "           x           y           z"

        do x=1,5
            do y=1,3,0.5
                z = x*y
                print *, x, y, z
                write(13,*) x, y, z
            end do
        end do
        close(13)
    end if

    list(1) = 1.0
    list(2) = 2.0
    list(3) = 3.0
    print *,list

    elements = 3
    allocate(array(elements))
    array(1) = 4.0
    array(2) = 5.0
    array(3) = 6.0
    print *,array
    deallocate(array)



end program fortranTest


