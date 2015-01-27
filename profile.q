/ simple profiler for functions
/ does not support projection
/ does not really work if functions defined using \d
/ does not work for f . a, use f a for monadic or f[a;a0] etc
/ in .p namespace for ease of use
/ any issues let me know
/ example
/ q)f
/ {[x;y]
/   x+y;
/   {x;y;z}[5+33;x;];
/   :x+y;
/  }
/ q)p)f[1;2]
/ fn                      time         pct
/ ----------------------------------------
/ "{[x;y]\n  x+y;"        00:00:00.000 50
/ "\n  {x;y;z}[5+33;x;];" 00:00:00.000 25
/ "\n  :x+y;"             00:00:00.000 25
/ "\n }"                  00:00:00.000 0
/ q)p){1+2;til 100;til 2000}`
/ fn         time         pct
/ --------------------------------
/ "{1+2;"    00:00:00.000 11.11111
/ "til 100;" 00:00:00.000 16.66667
/ "til 2000" 00:00:00.000 72.22222
/ ,"}"       00:00:00.000 0
/ q)p){system"sleep 1";x+'til 1000;x+y+123}[1;2]
/ fn                    time         pct
/ -----------------------------------------------
/ "{system\"sleep 1\";" 00:00:01.002 99.99132
/ "x+'til 1000;"        00:00:00.000 0.008581704
/ "x+y+123"             00:00:00.000 9.978725e-05
/ ,"}"                  00:00:00.000 0
\d .p
e:{profile[first x;eval each 1_x:parse x]}

profile:{[f;a]
  f:$[-11h=type f;get f;f];
  if[100h<>type f;'"profiler nyi"];
  f:@[tag;f;{'"profiler failed to tag:",x}];
  t:run[f;a];
  :disp[f;t];
 };

stub:";.p.time,:.z.p;"; / append this for timing

tag:{[f]
  f:-4!string f;
  i:min 2 1 1>f{sums(-). x~\:/:1#'y}/:("{}";"[]";"()"); / indices to ignore brackets
  f:raze f@[;;,;stub]/where i&f~\:1#";";                / append timing stub
  if[$[null i:last count[stub]+f ss stub;1;not all(-1_i _f)in" \t\n"];
    f:(-1_f),stub,"}"];                                / handle ...} without ;
  :get f;
 };

run:{[f;a]
  .p.time:1#.z.p;
  f . a;
  :.p.time,.z.p;
 };

disp:{[f;t]
  r:update time:1_deltas t til 1+count fn from([]fn:stub vs string f);
  r:update time:0D from r where all each fn in\:"\t\n }";      / handle "empty" lines
  :update trim fn,`time$0^time,pct:0^100*time%sum time from r; / time easier to read?
 };
\d .
