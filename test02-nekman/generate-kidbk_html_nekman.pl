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
my $n_columns = 5;
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
    my $i = 0;
    foreach my $item(@$items){
        if($item->{'type'} eq "url"){
            next if ($item->{'url'} =~ /^javascript:/);
            if ($i == 0) {
                $r .= $tab . "<tr>\n";
            }
            $r .= $tab x 2 . '<td width="20%"><a href="'. $item->{'url'} .'">' . encode('utf-8', $item->{'name'}). '</a></td>' . "\n";
            $i++;
            if ($i == $n_columns) {
                $r .= $tab . "</tr>\n";
                $i = 0;
            }
        } elsif ($item->{'type'} eq "folder"){
            if ($i > 0) {
                $r .= $tab . "</tr>\n";
                $i = 0;
            }
            $r .= $tab . "<tr>\n";
            $r .= $tab x2 . '<th colspan=' . $n_columns . '>' . $prefix . encode('utf-8', $item->{'name'}) . "</th>\n";
            $r .= $tab . "</tr>\n";
            $r .= &generateHtmlStrBkDir($item->{'children'}, $prefix . encode('utf-8', $item->{'name'}) . " > ");
        }
    }
    return $r;
}


