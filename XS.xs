#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "ganglia.h"

#define XS_STATE(type, x) \
  INT2PTR(type, SvROK(x) ? SvIV(SvRV(x)) : SvIV(x))

typedef struct ganglia_t {
  Ganglia_pool              context;
  Ganglia_gmetric           gmetric;
  Ganglia_udp_send_channels channel;
  Ganglia_gmond_config      gconfig;
} ganglia;

MODULE = Ganglia::Gmetric::XS    PACKAGE = Ganglia::Gmetric::XS

SV *
new(class, ...)
    SV *class;
  PREINIT:
    ganglia *gang;
    SV *sv;
    char *config = "/etc/gmond.conf";
  CODE:
    if (SvROK(class))
      croak("Cannot call new() on a reference");
    Newxz(gang, 1, ganglia);

    if (items > 1) {
      HV   *hv;
      HE   *he;
      SV   *key;
      if (!SvROK(ST(1)))
        croak("ref(hashref) expected");
      hv = (HV*)SvRV(ST(1));
      if (SvTYPE(hv) != SVt_PVHV)
        croak("hashref expected");

      key = newSVpv("config",0);
      he  = hv_fetch_ent(hv, key, 0, 0);
      if (he)
        config = SvPV_nolen(HeVAL(he));
    }
#ifdef DIAG
    PerlIO_printf(PerlIO_stderr(), "config:%s\n", config);
#endif

    gang->context = Ganglia_pool_create(NULL);
    if (! gang->context)
      croak("failed to Ganglia_pool_create");

    gang->gconfig = Ganglia_gmond_config_create(config, 0);
    if (! gang->gconfig)
      croak("failed to Ganglia_gmond_config_create");

    gang->channel = Ganglia_udp_send_channels_create(gang->context, gang->gconfig);
    if (! gang->channel)
      croak("failed to Ganglia_udp_send_channels_create");

    gang->gmetric = Ganglia_gmetric_create(gang->context);
    if (! gang->gmetric)
      croak("failed to Ganglia_gmetric_create");

    sv = newSViv(PTR2IV(gang));
    sv = newRV_noinc(sv);
    sv_bless(sv, gv_stashpv(SvPV_nolen(class), 1));
    SvREADONLY_on(sv);
    RETVAL = sv;
  OUTPUT:
    RETVAL

int
send(self, SV *args)
    SV *self;
  PREINIT:
    ganglia *gang;
    char *name  = "";
    char *value = "";
    char *type  = "";
    char *units = "";
  CODE:
    HV   *hv;
    HE   *he;
    SV   *tmp;
    char *key;
    I32   keylen = 0;
    int   r;
    gang = XS_STATE(ganglia *, self);

    if (!SvROK(args))
      croak("ref(hashref) expected");
    hv = (HV*)SvRV(args);
    if (SvTYPE(hv) != SVt_PVHV)
      croak("hashref expected");

    hv_iterinit(hv);
    while ( (tmp = hv_iternextsv(hv, &key, &keylen)) != NULL ) {
      if (strEQ(key, "name")) {
        name  = SvPV_nolen(tmp);
      } else if (strEQ(key, "value")) {
        value = SvPV_nolen(tmp);
      } else if (strEQ(key, "type")) {
        type  = SvPV_nolen(tmp);
      } else if (strEQ(key, "units")) {
        units = SvPV_nolen(tmp);
      }
    }

    r = Ganglia_gmetric_set(gang->gmetric, name, value, type, units, 3, 60, 0);
    switch(r) {
    case 1:
      croak("gmetric parameters invalid. exiting.\n");
    case 2:
      croak("one of your parameters has an invalid character '\"'. exiting.\n");
    case 3:
      croak("the type parameter \"%s\" is not a valid type. exiting.\n", type);
    case 4:
      croak("the value parameter \"%s\" does not represent a number. exiting.\n", value);
    }

    RETVAL = ! Ganglia_gmetric_send(gang->gmetric, gang->channel);
  OUTPUT:
    RETVAL

void
DESTROY(self)
    SV *self;
  PREINIT:
    ganglia *gang;
  CODE:
#ifdef DIAG
    PerlIO_printf(PerlIO_stderr(), "DESTROY: called\n" );
#endif
    gang = XS_STATE(ganglia *, self);
    if (gang == NULL) {
#ifdef DIAG
      PerlIO_printf(PerlIO_stderr(), "DESTROY: gang is null\n" );
#endif
      return;
    }

    if (gang->gmetric != NULL)
      Ganglia_gmetric_destroy(gang->gmetric);
    if (gang->context != NULL)
      Ganglia_pool_destroy(gang->context);
#ifdef DIAG
    PerlIO_printf(PerlIO_stderr(), "DESTROY: done\n" );
#endif
