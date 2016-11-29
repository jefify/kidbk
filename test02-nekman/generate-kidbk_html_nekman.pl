#!/usr/bin/perl

use strict;
use warnings;
use JSON qw( decode_json );
use Encode;
use Data::Dumper;

my $chrome_bookmark_file = "/home/alik/.config/google-chrome/Default/Bookmarks";
my $kidbk_template_file = "./generate-kidbk_html_nekman-template.txt";
my $kidbk_template_marker = '<!-- #####INSERIR-AQUI##### -->';
my $kidbk_output_file = "./kidbk.html";
my $n_columns = 4;
my $tab = "  ";

## MAIN

my $bmbar = JSON->new->utf8(0)->decode(decode_utf8((&readfile($chrome_bookmark_file))))->{'roots'}->{'bookmark_bar'}->{'children'};
# print Dumper($bmbar);

# aquivo de aida
# aqui pode comer batante memoria, mas como agora nao eh grande, vou deixar a manipulacao do arquivo de saida na memoria.
my $content_output_file = &readfile($kidbk_template_file);
my $str_to_insert = &generateHtmlStrBkDir($bmbar);

$content_output_file =~ s/$kidbk_template_marker/$str_to_insert/;
open( my $fh, ">" . $kidbk_output_file ) or die "Can't open output file $kidbk_output_file.\n";
print $fh $content_output_file;
#print $content_output_file;
print "Bookmark gerado no arquivo $kidbk_output_file.\n";
close ($fh);


## FUNCTIONS

sub readfile {
    open(my $fh, 'sudo -u alik cat ' . $_[0] . " |") or die "Can't open file $_[0]: $!";
    local $/;
    <$fh>;
}


sub generateHtmlStrBkDir {
    my $r = "";
    my $items = shift;
    my $prefix = shift;
    $prefix = "" unless defined($prefix);
    my $j = 0;
    foreach my $item(@$items){
        next if (defined($item->{'url'}) && $item->{'url'} =~ /^javascript:/);
        my $str = encode('utf-8', $item->{'name'});
        if($item->{'type'} eq "url"){
             # fullscreen youtube
             if ($item->{'url'} =~ /^(.*\.youtube\..*\/)watch\?(.*\&)?v=(\w+)(\&.+)?$/) {
                 $item->{'url'} = "$1";
                 $item->{'url'} .= "embed/$3?";
                 $item->{'url'} .= "$2" if $2;
                 $item->{'url'} .= "&$4" if $4;
                 $item->{'url'} .= "&rel=1&autoplay=1";
 		$item->{'url'} =~ s/\?&/?/g;
 		$item->{'url'} =~ s/&&/&/g;
             }
            if ($j == 0) {
                $r .= $tab . "<tr>\n";
            }
            $r .= $tab x 2 . '<td width="' . (100/$n_columns) . '%"><a href="'. $item->{'url'} .'"><div style="height:100%;width:100%">' . $str . '</div></a></td>' . "\n";
            $j++;
            if ($j == $n_columns) {
                $r .= $tab . "</tr>\n";
                $j = 0;
            }
        } elsif ($item->{'type'} eq "folder"){
            # completar celulas
            if ($j > 0) {
                for (; $j < $n_columns; $j++) {
                    $r .= $tab x 2 . '<td>&nbsp;</td>' . "\n";
                }
                $r .= $tab . "</tr>\n";
                $j = 0;
            }
            $r .= $tab . "<tr>\n";
            $r .= $tab x2 . '<th colspan=' . $n_columns . '>' . $prefix . $str . "</th>\n";
            $r .= $tab . "</tr>\n";
            $r .= &generateHtmlStrBkDir($item->{'children'}, $prefix . $str . " > ");
        }
    }
    # completar celulas
    if ($j > 0) {
        for (; $j < $n_columns; $j++) {
            $r .= $tab x 2 . '<td>&nbsp;</td>' . "\n";
        }
        $r .= $tab . "</tr>\n";
        $j = 0;
    }
    return $r;
}


