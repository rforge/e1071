LIBNAME=e1071
LD=ld

OBJS=pnm.o 

$(LIBNAME).so:  $(OBJS)
	$(LD) $(SHLIBLDFLAGS) -o $@ $(OBJS) -lpnm -lppm -lpgm -lpbm

clean:
	@rm -f *.o *.so

realclean: clean
