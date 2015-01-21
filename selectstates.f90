subroutine selectstates(valuework,dim1,valueindex,singularvalue,&
		subspacenum,syssite,szzero,pair1)
	USE mpi
	USe variables
	
	implicit none
	integer :: dim1
	integer,optional :: szzero,pair1
	real(kind=8) :: valuework(dim1),singularvalue(subM)
	integer :: valueindex(subM)
	real(kind=8) :: percent
	integer :: i,j,m
	integer :: directly,syssite
! directly is the num of states we have selected
	integer :: subspacenum(((syssite+1)*2+1)**2+1)
	logical :: noequal,done

	write(*,*) "enter in selectstates subroutine!"
	singularvalue=0.0D0
	valueindex=0
	write(*,*) "dim1=",dim1
!	write(*,*) valuework
	if(logic_spinreversal==0) then
		do i=1,dim1,1
			do j=1,subM,1
				if(valuework(i)>singularvalue(j)) then
					valueindex(j+1:subM)=valueindex(j:subM-1)
					singularvalue(j+1:subM)=singularvalue(j:subM-1)
					valueindex(j)=i
					singularvalue(j)=valuework(i)
					exit
				end if
			end do
		end do
!	write(*,*) valueindex
		percent=2.0+DBLE(isweep)*0.1
	!	write(*,*) subspacenum
		if(percent<1.0D0) then
			directly=INT(DBLE(dim1)*percent)
			do while(directly<subM)
			do i=1,subspacenum(1),1
				do j=sum(subspacenum(1:i+1)),sum(subspacenum(1:i))+1,-1
					do m=1,directly,1
						noequal=.true.
						if(j==valueindex(m)) then
							noequal=.false.
							exit
						end if
					end do
					if(noequal==.true.) then
						valueindex(directly+1)=j
						singularvalue(directly+1)=valuework(j)
						directly=directly+1
						exit
					end if
				end do
				if(directly==subM) then
					exit
				end if
			end do
			end do
		end if
!		write(*,*) "valueindex",valueindex
!	else
!		do i=1,szzero+pair1,1
!			do j=1,subM,1
!				if(valuework(i)>singularvalue(j)) then
!					if(i<=pair1) then
!						valueindex(j+2:subM)=valueindex(j:subM-2)
!						valueindex(j)=i
!						valueindex(j+1)=pair1+szzero+i
!						singularvalue(j+2:subM)=singularvalue(j:subM-2)
!						singularvalue(j)=valuework(i)
!						singularvalue(j+1)=valuework(i)
!						exit
!					else
!						valueindex(j+1:subM)=valueindex(j:subM-1)
!						singularvalue(j+1:subM)=singularvalue(j:subM-1)
!						valueindex(j)=i
!						singularvalue(j)=valuework(i)
!						exit
!					end if
!				end if
!			end do
!		end do
!		if(valueindex(subM)<=pair1) then
!			do i=pair1+szzero,pair1+1,-1
!			
!			do j=1,subM,1
!				if(valueindex(j)==i) then
!					done=.false.
!					exit
!				else
!					done=.true.
!				end if
!			end do
!				if(done==.true.) then
!				valueindex(subM)=i
!				singularvalue(subM)=valuework(i)
!				exit
!				end if
!			end do
!		end if
	end if

return
end subroutine selectstates