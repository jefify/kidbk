#!/usr/bin/perl

use strict;
use warnings;
use JSON qw( decode_json );
use Encode;
use Data::Dumper;

my $chrome_bookmark_file = "/home/alik/.config/google-chrome/Default/Bookmarks";
my $kidbk_template_file = "./generate-kidbk_html-template.txt";
my $kidbk_template_marker = '#####INSERIR-AQUI#####';
my $kidbk_output_file = "./kidbk.html";

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
    foreach my $item(@$items){
        if($item->{'type'} eq "url"){
            #print '<a href="'. $item->{'url'} .'">' . $prefix . encode('utf-8', $item->{'name'}) . "</a><br>\n";
            # http://blog.csdn.net/guo40/article/details/4037052 / http://carlislebear.blogspot.com.br/2013/05/perl.html
            #my $str = substr(encode('utf-8', $item->{'name'}), 0, 12);
            #Encode::from_to($str,'UTF-8','unicode');
            #$str =~ s/\x{fffd}//g;
            #Encode::from_to($str,'unicode','UTF-8');
            my $str = encode('utf-8', $item->{'name'});
            $r .= " " x 12 . '<div class="grid-item dpad-focusable" tabindex="0">' . "\n";
            $r .= " " x 16 . '<a href="'. $item->{'url'} .'">' . '<img class="thumb" src="./images/thumbs/thumb01.jpg" title="' . $prefix . ($prefix eq ""?"":'&#13;') . encode('utf-8', $item->{'name'}) . '" /></a>' . "\n";
            $r .= " " x 16 . '<div class="title">' . $str . "</div><br>\n";
            $r .= " " x 12 . '</div>' . "\n";
        } elsif ($item->{'type'} eq "folder"){
            $r .= &generateHtmlStrBkDir($item->{'children'}, $prefix . encode('utf-8', $item->{'name'}) . " > ");
        }
    }
    return $r;
}


