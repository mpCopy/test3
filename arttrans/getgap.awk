
}#BEGIN

{
  if($1 == "GAP_file:") { print $2 > TMPFILE }
}

END { close(TMPFILE) }
