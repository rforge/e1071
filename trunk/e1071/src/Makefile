LIBNAME=e1071
LD=ld

OBJS=pnm.o 

$(LIBNAME).so:  $(OBJS)
	$(LD) $(SHLIBLDFLAGS) -o $@ $(OBJS) -lnetpbm

clean:
	@rm -f *.o *.so

realclean: clean
