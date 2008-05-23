use inc::Module::Install;
use Getopt::Long;

name        'Ganglia-Gmetric-XS';
all_from    'lib/Ganglia/Gmetric/XS.pm';

requires 'UNIVERSAL::require'    => 0;

build_requires 'Test::More'      => 0;
build_requires 'Test::Base'      => 0;

GetOptions(
    "ganglia-dir=s"      => \my $ganglia_dir,
    "enable-clear-pool"  => \my $enable_clear_pool,
    "diag"               => \my $diagnostic,
    "debug"              => \my $debug,
   );
$ganglia_dir ||= $ENV{GANGLIA_DIR} if $ENV{GANGLIA_DIR};

die "missing option: --ganglia-dir=/path/to/ganglia-3.x.x" unless $ganglia_dir;
my @static_libs = qw(
                        lib/.libs/libganglia.a
                        srclib/apr/.libs/libapr-0.a
                        srclib/confuse/src/.libs/libconfuse.a
                   );
my @myextlibs;
for my $lib (@static_libs) {
    my $lib_path = "$ganglia_dir/$lib";
    if(not -r $lib_path) {
        die "$lib_path: cannot find";
    }
    push @myextlibs, $lib_path;
}

can_cc or die "This module requires a C compiler";
cc_optimize_flags "-O2";
cc_inc_paths "$ganglia_dir/lib", "$ganglia_dir/srclib/apr/include";
#cc_lib_paths "";
libs "-lrt";
my @defines;
makemaker_args "MYEXTLIB" => join(" ", @myextlibs);
if ($diagnostic) {
    cc_optimize_flags "-g";
    push @defines, "-DDIAG";
}
if ($debug) {
    cc_optimize_flags "-g";
}
if ($enable_clear_pool) {
    push @defines, "-DCLEAR_POOL";
}
makemaker_args "DEFINE" => join(" ", @defines);

use_test_base;
auto_install;
WriteAll;
