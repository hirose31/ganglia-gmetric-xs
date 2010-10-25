use inc::Module::Install;
use Getopt::Long;

name        'Ganglia-Gmetric-XS';
all_from    'lib/Ganglia/Gmetric/XS.pm';

build_requires 'Test::More'      => 0;

GetOptions(
    "ganglia-dir=s"      => \my $ganglia_dir,
    "diag"               => \my $diagnostic,
    "debug"              => \my $debug,
   );
$ganglia_dir ||= $ENV{GANGLIA_DIR} if $ENV{GANGLIA_DIR};

die "missing option: --ganglia-dir=/path/to/ganglia-3.0.x" unless $ganglia_dir;
my @static_libs = qw(
                        lib/.libs/libganglia.a
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
cc_inc_paths "$ganglia_dir/include", "$ganglia_dir/lib";
#cc_lib_paths "";
libs "-lrt -lconfuse -lapr-1";
my @defines;
makemaker_args "MYEXTLIB" => join(" ", @myextlibs);
if ($diagnostic) {
    cc_optimize_flags "-g";
    push @defines, "-DDIAG";
}
if ($debug) {
    cc_optimize_flags "-g";
}
makemaker_args "DEFINE" => join(" ", @defines);

use_test_base;
auto_install;
WriteAll;
