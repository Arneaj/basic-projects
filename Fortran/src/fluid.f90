program fluid
    implicit none

    integer :: nParticles 

    real :: dt

    real :: xMin, yMin, xMax, yMax

    real, allocatable, dimension(:,:) :: P
    real, allocatable, dimension(:,:) :: v
    real, allocatable, dimension(:,:) :: a

    nParticles = 10
    dt = 0.001
    xMin = 0
    yMin = 0
    xMax = 10
    yMax = 10

    allocate(P(nParticles,2))
    allocate(v(nParticles,2))
    allocate(a(nParticles,2))

    P = 0.0*P
    v = 0.0*v
    a = 0.0*a
    P = P + 5.0

    


end program fluid

subroutine bounce(x, y, dx, dy)
    implicit none

    real :: x, y, dx, dy

    real :: xMin, yMin, xMax, yMax
    xMin = 0
    yMin = 0
    xMax = 10
    yMax = 10

    if ( x < xMin .or. x > xMax ) dx = -dx
    if ( y < yMin .or. y > yMax ) dy = -dy

end subroutine bounce

subroutine gravity(ax, ay)
    implicit none

    real :: ax, ay
    ax = 0
    ay = -9.8

end subroutine gravity

subroutine repulsion()
end subroutine repulsion

subroutine friction()
end subroutine friction

