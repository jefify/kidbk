#!/usr/bin/perl
 
# http://blog.csdn.net/guo40/article/details/4037052 / http://carlislebear.blogspot.com.br/2013/05/perl.html

sub strip_non_utf8_characters {
    my $text=shift;
    my $utf8_rgx='\A(
     [\x09\x0A\x0D\x20-\x7E]            # ASCII
   | [\xC2-\xDF][\x80-\xBF]             # non-overlong 2-byte
   |  \xE0[\xA0-\xBF][\x80-\xBF]        # excluding overlongs
   | [\xE1-\xEC\xEE\xEF][\x80-\xBF]{2}  # straight 3-byte
   |  \xED[\x80-\x9F][\x80-\xBF]        # excluding surrogates
   |  \xF0[\x90-\xBF][\x80-\xBF]{2}     # planes 1-3
   | [\xF1-\xF3][\x80-\xBF]{3}          # planes 4-15
   |  \xF4[\x80-\x8F][\x80-\xBF]{2}     # plane 16
  )*\z';
  my $tlen=length($text);
  print "\n length:" . $tlen . "\t";
  for(my $i=0;$i<$tlen;$i++){
    $text=substr($text,0,$tlen-$i);
    return $text if( $text=~ m/$utf8_rgx/x );
  }
  return '';
}
 
sub t{
  my $text=shift;
  for(my $i=0;$i< length($text) ;$i+=2){
    printf( "split length=%d response:%s\n",
      $i,
      &strip_non_utf8_characters(substr($text,0,$i))
    );
  }
}
$string = "歡迎來到全世界最大的網站";
&t($string);
print "\n",substr($string,0,10),"\n";
print length $string;
print "\n",&strip_non_utf8_characters(substr($string,0,999)); #結果
 
