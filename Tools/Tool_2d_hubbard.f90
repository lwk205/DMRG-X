module var
    implicit none
    integer :: nsitex,nsitey
    integer,allocatable :: indexxy(:,:),bondlink(:,:,:,:)
    real(kind=8) :: bondlength,nuclE
    real(kind=8),parameter :: hopt=-1.0D0,hubbardU=4.0D0
    logical :: IfPPP
    real(kind=8),allocatable :: siteenergy(:,:)

end module var

program Tool_2d_hubbard
! this program prepare the 2d_hubbard integral for DMRG-X
    use var
    implicit none

    write(*,*) "input nsitex,nsitey:"
    read(*,*) nsitex,nsitey
    write(*,*) "bond length:"
    read(*,*) bondlength
    write(*,*) "IfPPP:"
    read(*,*) IfPPP

    allocate(indexxy(nsitex,nsitey))
    allocate(bondlink(nsitex,nsitey,nsitex,nsitey))
    allocate(siteenergy(nsitex,nsitey))
    siteenergy=0.0D0
    nuclE=0.0D0

    call bondnet
    call multichain
    call output
    
    deallocate(indexxy)
    deallocate(bondlink)
    deallocate(siteenergy)
end program Tool_2d_hubbard

subroutine FCIDUMP
    use var
    implicit none

end subroutine FCIDUMP

subroutine output
    use var
    implicit none
    integer :: icol,irow,jcol,jrow,i
    logical :: iffind
    real(kind=8) :: pppV,distance2

    open(unit=10,file="coord.xyz",status="replace")
    write(10,*) nsitex*nsitey
    write(10,*) 
    do i=1,nsitex*nsitey,1
        iffind=.false.
        do icol=1,nsitey,1
        do irow=1,nsitex,1
            if(indexxy(irow,icol)==i) then
                write(10,'(1A,4F8.5)') 'C',DBLE(irow-1)*bondlength,DBLE(icol-1)*bondlength,0.0D0,1.0D0
                iffind=.true.
                exit
            end if
            if(iffind==.true.) exit
        end do
        end do
    end do
    close(10)
    
    open(unit=11,file="integral.inp",status="replace")
    open(unit=13,file="FCIDUMP",status="replace")
    do icol=1,nsitey,1
    do irow=1,nsitex,1
    do jcol=1,nsitey,1
    do jrow=1,nsitex,1
        if(bondlink(jrow,jcol,irow,icol)==1) then
            write(11,*) indexxy(irow,icol),indexxy(jrow,jcol),hopt
            write(13,*) hopt,indexxy(irow,icol),indexxy(jrow,jcol),0,0
        end if
        if(IfPPP==.true.) then
            if(jrow+(jcol-1)*nsitex>irow+(icol-1)*nsitex) then
                distance2=((jrow-irow)*bondlength)**2+((jcol-icol)*bondlength)**2
                pppV=hubbardU/sqrt(1+hubbardU*hubbardU*distance2/14.397D0/14.397D0)
                write(13,*) pppV,indexxy(jrow,jcol),indexxy(jrow,jcol),indexxy(irow,icol),indexxy(irow,icol)
                siteenergy(irow,icol)=siteenergy(irow,icol)-pppV
                siteenergy(jrow,jcol)=siteenergy(jrow,jcol)-pppV
                nuclE=nuclE+pppV
            end if
        end if
    end do
    end do
    end do
    end do
    do i=1,nsitex*nsitey,1
        write(11,*) 0.0D0
    end do
    do i=1,nsitex*nsitey,1
        write(11,*) hubbardU
        write(13,*) hubbardU,i,i,i,i
    end do

    do icol=1,nsitey,1
    do irow=1,nsitex,1
        write(13,*) siteenergy(irow,icol),indexxy(irow,icol),indexxy(irow,icol),0,0
    end do
    end do
    write(13,*) nuclE,0,0,0,0
        

    close(11)
    close(13)

    return

return
end subroutine output

subroutine multichain
    use var
    implicit none
    integer :: i,j

    do j=1,nsitey,1
    do i=1,nsitex,1
        if(mod(j,2)==1) then
            indexxy(i,j)=i+(j-1)*nsitex
        else
            indexxy(i,j)=(nsitex-i)+1+(j-1)*nsitex
        end if
    end do
    end do
    return
end subroutine multichain

subroutine bondnet
    use var
    implicit none
    integer :: icol,irow,jcol,jrow
    
    bondlink=0
    do icol=1,nsitey,1
    do irow=1,nsitex,1
    do jcol=1,nsitey,1
    do jrow=1,nsitex,1
        if(jrow+jcol*nsitex>irow+icol*nsitex) then
            if ((icol-jcol)**2+(irow-jrow)**2==1) then
                bondlink(jrow,jcol,irow,icol)=1
            end if
        end if
    end do
    end do
    end do
    end do
    return
end subroutine bondnet




















