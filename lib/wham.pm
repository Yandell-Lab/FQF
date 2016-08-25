package wham;
use Moo::Role;

##-----------------------------------------------------------
##---------------------- ATTRIBUTES -------------------------
##-----------------------------------------------------------

has seqid_skip => (
    is      => 'rw',
    builder => 1,
);

##-----------------------------------------------------------
##------------------------ METHODS --------------------------
##-----------------------------------------------------------

sub _build_seqid_skip {
    my $self = shift;

    my @record;
    while ( my $data = <DATA> ) {
        chomp $data;
        push @record, $data;
    }
    my $ids = join( ",", @record );
    $self->seqid_skip($ids);
}

##-----------------------------------------------------------

sub whamg_svtper {
    my $self = shift;
    $self->pull;

    my $config = $self->class_config;
    my $opts   = $self->tool_options('whamg');
    my $files  = $self->file_retrieve('fastq2bam');

    my $skip_ids = $self->seqid_skip;

    my @cmds;
    foreach my $bam ( @{$files} ) {
        chomp $bam;

        next unless ( $bam =~ /bam$/ );

        my $file = $self->file_frags($bam);
        my $output =
            $config->{output}
          . $file->{parts}[0]
          . "_unfiltered.genotype.wham.vcf";
        $self->file_store($output);

        my $threads;
        ( $opts->{x} ) ? ( $threads = $opts->{x} ) : ( $threads = 1 );

        ## create temp.
        my $temp_bam = $config->{output} . $file->{parts}[0] . "_temp.vcf";
        my $temp_log = $config->{output} . $file->{parts}[0] . ".log";

        my $cmd = sprintf(
            "whamg -a %s -x %s -f %s -e %s > %s 2> %s && svtyper -B %s -i %s -o %s && rm %s",
            $config->{fasta}, $threads,  $bam, $skip_ids,
            $temp_bam,        $temp_log, $bam, $temp_bam,
            $output,          $temp_bam
        );
        push @cmds, $cmd;
    }
    $self->bundle( \@cmds );
}

##-----------------------------------------------------------

sub wham_bgzip {
    my $self = shift;
    $self->pull;

    my $config     = $self->class_config;
    my $opts       = $self->tool_options('wham_bgzip');
    my $typer_file = $self->file_retrieve('whamg_svtyper');

    my $output_file = "$typer_file->[0]" . '.gz';

    $self->file_store($output_file);

    ## dup step need different path to software.
    my $cmd = sprintf( "bgzip -c %s > %s", $typer_file->[0], $output_file );
    $self->bundle( \$cmd );
}

##-----------------------------------------------------------

sub wham_tabix {
    my $self = shift;
    $self->pull;

    my $config       = $self->class_config;
    my $opts         = $self->tool_options('tabix');
    my $bgziped_file = $self->file_retrieve('wham_bgzip');

    ## dup step need different path to software.
    my $cmd = sprintf( "tabix -p vcf %s", $bgziped_file->[0] );
    $self->bundle( \$cmd );
}

##-----------------------------------------------------------

1;

__DATA__
GL000207.1
GL000226.1
GL000229.1
GL000231.1
GL000210.1
GL000239.1
GL000235.1
GL000201.1
GL000247.1
GL000245.1
GL000197.1
GL000203.1
GL000246.1
GL000249.1
GL000196.1
GL000248.1
GL000244.1
GL000238.1
GL000202.1
GL000234.1
GL000232.1
GL000206.1
GL000240.1
GL000236.1
GL000241.1
GL000243.1
GL000242.1
GL000230.1
GL000237.1
GL000233.1
GL000204.1
GL000198.1
GL000208.1
GL000191.1
GL000227.1
GL000228.1
GL000214.1
GL000221.1
GL000209.1
GL000218.1
GL000220.1
GL000213.1
GL000211.1
GL000199.1
GL000217.1
GL000216.1
GL000215.1
GL000205.1
GL000219.1
GL000224.1
GL000223.1
GL000195.1
GL000212.1
GL000222.1
GL000200.1
GL000193.1
GL000194.1
GL000225.1
GL000192.1
NC_007605
hs37d5
phix
