/*_________________________________________________________________________________________________
|/                                                     .__                                         \
/                           ______  _________.__. ____ |  |__   ____                               |
|                           \____ \/  ___<   |  |/ ___\|  |  \ /  _ \                              |
|                           |  |_> >___ \ \___  \  \___|   Y  (  <_> )                             |
|                           |   __/____  >/ ____|\___  >___|  /\____/                              |
\                           |__|       \/ \/         \/     \/                                     |
 \__________________ if $reality > $fiction { /kill %sanity | echo -a *voices* } __________________/
//================================================================================================\\
||                                      INFOCHAN script v1.4                                      ||
||                        Multi Network Support + Channel mode +c detector                        ||
||================================================================================================||
||            Key features:                                                                       ||
||           • Information shown: [Name: Value(%percentage)]                                      ||
||             → [Total, Authed, Away, Here, Prefixed, ~|&|@|%|+|r, IRCop(s), Bot(s), Clone(s)]   ||
||           • The built in control code block detector (+c) works wonders a, as it sends         ||
||              a message to the channel first informing them that the out is being stripped      ||
||              and if that's not enough, it has a flood protection system to block further spam  ||
||           • 5 Customizable colors: [Text, Value, Percentage, Wrappers & Arrows]                ||
||           • Custom channel menu with 5 different output options;                               ||
||             → (Echo, Active Channel, Op Notice, Custom Nick (input box), Specify Custom        ||
||           • Supports Networks with WHOX at the moment (Tested on [ircu], [UnrealIRCD])         ||
||           • Works with mIRC v7.6+ & AdiIRC v3.8+                                               ||
||     *NEW* • Added dialog option                                                                ||
||                                                                                                ||
||  Example with mode +c                                                                          ||
||  --------------------                                                                          ||
|| * foo sets mode: +c                                                                            ||
|| <@foo> [Detected mode +c - Stripping message...]                                               ||
|| <@foo> ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡ #foo info start ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡                                   ||
|| <@foo> ••• [Total User(s): 41] → [Authed: 33(%80)] → [Away: 10(%24)] → [Here: 31(%75)]         ||
|| <@foo> ••• [Prefixed: 32(%78)] → [@: 31(%75)] → [+: 1(%2)] → [noob(s): 9(%21)]                 ||
|| <@foo> ••• [IRCops(s): 4(%9)] → [oper1, oper2, oper3]                                          ||
|| <@foo> ••• [Clones(s): none]                                                                   ||
|| <@foo> ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡ #foo info end ≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡≡                                     ||
||================================================================================================||
||   Changelog:                                                                                   ||
||   ----------                                                                                   ||
||     v1.4 (25/02/2021)                                                                          ||
||     → Added spam protection against multiple clicks                                            ||
||     v1.3 (24/02/2021)                                                                          ||
||     → Added Dialog option and improved some code                                               ||
||     v1.2 (12/02/2021)                                                                          ||
||     → Added $unsafe to output                                                                  ||
\\================================================================================================//
╔══════════════════════════════════════════════════════════════════════════════════════════════════╗
║                                          Author: psycho                                          ║
║              Network: Undernet | irc.undernet.org  | Channel: #psycho, #mIRCscripting            ║
║              Network: ChatHub  | irc.chathub.org   | Channel: #mSL                               ║
║              Network: SwiftIRC | irc.swiftirc.net  | Channel: #mIRCscripting, #mSL               ║
╠══════════════════════════════════════════════════════════════════════════════════════════════════╣
║                                       Credits/Contributions                                      ║
║                    Major contribution by: westor ~No sleep for the wicked~                       ║
║                               Notable contributions: Ouims, maroon                               ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════╝
*/


/*
┌──────────┐
│ Settings │
└──────────┘
*/
;Colors
alias -l text_color { return 02 }
alias -l value_color { return 04 }
alias -l percent_color { return 06 }
alias -l wrapper_color { return 10 }
alias -l arrow_color { return 14 }

/*
╔═══════════════════════════════════════════════════════════════════════════════════════════╗
║ You Don't need to touch anything beyond this point, but if you insist, you know the drill ║
╚═══════════════════════════════════════════════════════════════════════════════════════════╝
*/
on *:LOAD:{
  echo -at $pre_a You just loaded /infochan $infochan_ver Multi-Network script
  echo -at $pre_a You can access the commands by right clicking the channel window.
}

on *:UNLOAD:{
  echo -at What the hell??
  echo -at Alrighty then!
}

/*
┌─────────┐
│ ALIASES │
└─────────┘
*/

;--- Globals ---

alias -l infochan_ver { return v1.4 }

alias sw { 
  ;syn: $sw([-coenq],target,message) | /sw [-coenq] target message
  ;[-coenq] c/chan o/onotice e/echo n/notice q/query
  if (!$regex(swtch,$1,/^\-([coenq])$/)) || (!$2) { $iif($nick,notice $nick,msg $target) Syntax: $!sw([-conq],[target],message) | return }
  if ($regml(swtch,1) == e) { echo -tuag $2- } 
  elseif ($isid) { sw.do $replacex($regml(swtch,1),c,msg $2,o,.onotice $2,n,.notice $2,q,msg $2) $3- }
  else { sw.do $replacex($regml(swtch,1),c,msg $2,o,.onotice $2,n,.notice $2,q,msg $2) $3- }
}

alias -l sw.do { 
  ;syn: processes the output received from sw
  if ($istok(msg notice,$1,32)) && ($2 ischan) && (c isincs $gettok($chan($2).mode,1,32)) {
    if (!$hget($2,_sw_strip)) { hinc -mu10 $2 _sw_strip 1 | $1 $2 [Detected mode +c - Stripping message...]  }
    .timer 1 1 $1 $2 $unsafe($strip($3-))
  }
  else .timer 1 1 $unsafe($1-)
}

alias sw.chk { if ($regex(sw.check,$1,/^\-([coenq])$/)) { return $true } } 

alias pre_a { return $+($chr(3),14,$chr(8592),$chr(3),12,$chr(8597),$chr(3),02,$chr(8594),$chr(15)) }
alias col {
  ; $col(N,TEXT)
  if ($1 == $null) { var %c = $base(02,10,10,2) }
  elseif ($1 == r) { var %c = $base($r(1,15),10,10,2) }
  else { var %c = $base($1,10,10,2) }
  return $+($chr(3),%c,$2-,$chr(15))
}
alias per {
  ;syn: $per(value1,value2)
  ;properties .n = $per($chan,[qaohvr]) / .c = $per($chan,value)
  if ($prop == n) { return $+($chr(40),%,$int($calc($nick($1,0,$2) * 100 / $nick($1,0))),$chr(41)) }
  if ($prop == c) { return $+($chr(40),%,$int($calc($2 * 100 / $nick($1,0))),$chr(41)) }
  else { return $+($chr(40),%,$int($calc($1 * 100 / $2)),$chr(41)) }
}

alias infochan {
  ;syn: infochan [-coenq] <chan> <target>
  if (!$sw.chk($1)) || (!$2) { return }
  elseif ($2 ischan) { 
    if ($hget($2,_delay)) { $hget($+(stats_,$2),_c_out) $2 is in cooldown mode. You can request again in $duration($hget($2,_delay).unset) | return }
    hadd -m $+(stats_,$2) _c_out $1 $iif($3,$3,$2) | hinc -mu10 $2 _delay 1 | .enable #chan_info | .who $2 $+(%,cfhinrtua,$chr(44),555)
  }
}
alias infochand { dialog $iif($dialog(infochan),-v,-mv) infochan infochan }
alias getcnlist { 
  if (!$1) { return error: $!getcnlist([#channel|chans]) }
  var %a = $iif($1 ischan && $me ison $1,$nick($1,0),$chan(0))
  while (%a) {
    var %o = $addtok(%o,$iif($1 ischan,$nick($1,%a),$chan(%a)),44)
    dec %a
  }
  return %o
}

alias getcnlists {
  if ($me ison $1 && $1 ischan) || ($1 == chans) { 
    var %a = $v1, %b = $iif(%a ischan,$nick($1,0),$chan(0)), %o 
    while (%b) {
      var %o = $addtok(%o,$iif(%a ischan,$nick(%a,%b),$chan(%b)),44)
      dec %b
    }
    return %o
  }
  else return error: $!getcnlist([#channel|chans])
}

;--- Locals ---


alias -l c_info_get { 
  ;syn: $c_info_get(chan) [for table name]
  ;syn: $c_info_get(chan,item) [for item data]
  return $iif($2,$hget($+(stats_,$1),$2),$hget($+(stats_,$1)))
}
alias -l c_info_hidden { return 255.255.255.255 127.0.0.1 }

alias -l c_ivp { 
  var %c_i = $c_info_get($1,$2) 
  if (%c_i) { return $psy($+($col($text_color,$iif($3 > 1 && $right($3,1) == s,$+($3,(s)),$3)),$chr(58),$chr(32),$col($value_color,%c_i),$col($percent_color,$per($1,%c_i).c))).sc10 }
  elseif (!$4) { return $psy($+($col($text_color,$iif($3 > 1 && $right($3,1) == s,$+($3,(s)),$3)),$chr(58),$chr(32),$col($value_color,none))).sc10 }
}

alias -l c_info { 
  ;syn: $c_info(chan,item,name)
  ;ie; $c_info(#test,_auth,Authed)
  if ($c_info_get($1)) {
    if ($istok(_auth _away _here _bot _ircop _clone _prefixes _prefixes_~ _prefixes_& _prefixes_@ _prefixes_% _prefixes_+ _prefixes_r,$2,32)) { return $c_ivp($1,$2,$3,$prop) }
    elseif ($c_info_get($1,$2)) {
      if ($2 == _bot_nick) { return $c_ivp($1,_bot,Bots) $col($arrow_color,→) $psy($regsubex($c_info_get($1,_bot_nick),/( $+ $chr(44) $+ )/g,$+(\1,$chr(32)))).sc10 }
      if ($2 == _ircop_nick) { return $c_ivp($1,_irc_op,IRCops) $col($arrow_color,→) $psy($regsubex($c_info_get($1,_ircop_nick),/( $+ $chr(44) $+ )/g,$+(\1,$chr(32)))).sc10 }
    }
  }
}

alias -l chans { scon $netid($1) return $!regsubex($str(.,$chan(0)),/./g,$+($chan(\n),$chr(32))) }
alias -l netid { var %x = $scon(0) | while (%x) { if ($scon(%x).network == $1) { return %x } | dec %x } }

/* 
┌───────────┐
│ RAW EVENT │
└───────────┘
*/

#chan_info off

raw *:*: {
  haltdef | tokenize 32 $rawmsg 
  ;echo -a $_text($1-)
  if ($2 = 354) && ($4 == 555) {
    hinc -m $+(stats_,$5) _all_user 1 | hadd -m $+(stats_,$5) $iif($matchtok($c_info_hidden,$7,1,32),$8,$7) $addtok($hget($+(stats_,$5),$iif($matchtok($c_info_hidden,$7,1,32),$8,$7)),$9,63)
    if ($regex($10,\*)) { hinc -m $+(stats_,$5) _irc_op 1 | hadd -m $+(stats_,$5) _ircop_nick $addtok($hget($+(stats_,$5),_ircop_nick),$9,44) }
    if ($regex($10,G)) { hinc -m $+(stats_,$5) _away 1 | hadd -m $+(stats_,$5) _away_nick $addtok($hget($+(stats_,$5),_away_nick),$9,44) }
    if ($regex(prefix,$10,(@|&|%|\+|~))) { hinc -m $+(stats_,$5) _prefixes 1 | hinc -m $+(stats_,$5) $+(_prefixes_,$regml(prefix,1)) 1 }
    if ($regex($10,B)) { hinc -m $+(stats_,$5) _bot 1 | hadd -m $+(stats_,$5) _bot_nick $addtok($hget($+(stats_,$5),_bot_nick),$9,44) }
    if ($regex($10,H)) { hinc -m $+(stats_,$5) _here 1 }
    if ($regex($11,\D)) { hinc -m $+(stats_,$5) _auth 1 }
  }
  if ($2 = 315) && ($hget($+(stats_,$4))) {
    hadd -m $+(stats_,$4) _prefixes_r $nick($4,0,r)
    if ($hfind($+(stats_,$4),\?,0,r).data) { hadd -m $+(stats_,$4) _clone $v1 }
    var %_c_out = sw $hget($+(stats_,$4),_c_out), 
    %_c_out $str($pre_a,6) $4 info start $str($pre_a,6)
    %_c_out $pre_a $psy($+($col($text_color,Total User(s):),$chr(32),$col(4,$nick($4,0)))).sc10 $col($arrow_color,→) $c_info($4,_auth,Authed) $col($arrow_color,→) $c_info($4,_away,Away) $col($arrow_color,→) $c_info($4,_here,Here)
    %_c_out $pre_a $c_info($4,_prefixes,Prefixed) $col($arrow_color,→) $iif(~ isin $prefix,$c_info($4,_prefixes_~,~) $col($arrow_color,→)) $iif(& isin $prefix,$c_info($4,_prefixes_&,&) $col($arrow_color,→)) $c_info($4,_prefixes_@,@) $col($arrow_color,→) $iif(% isin $prefix,$c_info($4,_prefixes_%,%) $col($arrow_color,→)) $c_info($4,_prefixes_+,+) $col($arrow_color,→) $c_info($4,_prefixes_r,noob(s))
    %_c_out $pre_a $c_info($4,_ircop_nick,IRCops) $iif($c_info_get($4,_bot),$+($col($arrow_color,↕),$chr(32),$c_info($4,_bot_nick,Bots))) 
    %_c_out $pre_a $c_info($4,_clone,Clones)
    var %1 = 1,%_clonenick, %_addr
    while ($hfind($+(stats_,$4),\?,%1,r).data) {
      var %_addr = $v1, %_clonenick = $regsubex($hget($+(stats_,$4),%_addr),/(\?)/g,$chr(44) $chr(32))
      %_c_out $pre_a $psy($col($text_color,Address:) $col($value_color,%_addr)).sc10 $col($arrow_color,→) $psy($+(Nicks,$+($col($arrow_color,$chr(40)),$col($percent_color,$numtok(%_clonenick,44)),$col($arrow_color,$chr(41))),$chr(58),$chr(32),%_clonenick)).sc10
      inc %1
    }
    %_c_out $str($pre_a,6) $4 info end $str($pre_a,6)
    hfree $+(stats_,$4) | .timer 1 2 .disable #chan_info
  }
}

#chan_info end

/*
┌──────────────┐
│ Dialog  Menu │
└──────────────┘
*/

dialog infochan {
  title "/infochan custom report"
  size -1 -1 138 120
  option dbu
  icon $qt($scriptdir $+ infochan.ico), 0
  combo 1, 51 8 80 11, drop
  combo 2, 51 30 80 11, edit drop
  combo 3, 51 43 80 11, edit drop
  edit "", 4, 51 65 80 11
  edit "", 5, 2 84 132 13, read multi autovs center
  text "Output Method:", 6, 4 9 39 8, right
  text "Network:", 7, 4 31 45 8, right
  text "Channel:", 8, 4 44 45 8, right
  text "Nick / Channel:", 9, 2 67 45 8, right
  box "Select the output method", 10, 2 1 132 20
  box "Select the source channel", 11, 2 23 132 33
  box "Enter destination nick or channel", 12, 2 58 132 22
  button "Cancel", 13, 83 98 51 12, flat cancel
  button "Send Report", 14, 2 98 80 12, default flat
  text "part of ‹•p•S•y•›", 15, 87 111 44 8, right
  text "/infochan", 16, 2 111 25 8
}

on *:dialog:infochan:edit:*: {
  if ($did == 4) { 
    if ($istok(Notice Query,$did(1),32)) { 
      if (!$did(4)) || ($did(4) isnum)  || ($len($did(4)) < 2) { did -b $dname 14 | did -ra $dname 5 Please select a destination | set %info.error Please select a destination }
      elseif (!$did(14).enabled) { did -e $dname 14 | unset %info.error } 
    }
    elseif ($istok(Channel Onotice,$did(1),32)) && ($did(4)) && (!$istok($asc($did(4)),35,32)) { did -b $dname 14 | set %info.error select a channel in destination }
  }
}
ON *:DIALOG:infochan:mouse:*: {
  if ($did == 1) { did -ra $dname 5 Select the output method }
  if ($did == 2) { did -ra $dname 5 Select the source network }
  if ($did == 3) { did -ra $dname 5 Select the source channel }
  if ($did == 4) { did -ra $dname 5 Enter the destination target }
  if ($did == 14) { 
    if (!$did(14).enabled) { did -ra $dname 5 error: You must %info.error }
    if ($did(14).enabled) { did -ra $dname 5 Click this button to send the report }
  }
  if ($did == 13) { did -ra $dname 5 Click this to close the window }
}


ON *:DIALOG:infochan:init:*: { 
  didtok $dname 1 44 Channel,Onotice,Notice,Query
  did -c $dname 1 1
  var %nets $scon(0)
  while (%nets) { scon %nets did -a $dname 2 $!network | dec %nets }
  did -c $dname 2 $didwm($dname,2,$network)
  didtok $dname 3 32 $chans($network)
  did -c $dname 3 $didwm($dname,3,$active)
}

on *:DIALOG:infochan:sclick:*: { 
  if ($istok(Notice Query,$did(1),32)) && (!$did(4)) { did -b $dname 14 | did -ra $dname 5 Please select a destination | set %info.error select a Destination }
  if ($istok(Channel Onotice,$did(1),32)) {
    if (!$did(14).enabled) { did -e $dname 14 | unset %info.error }
    elseif ($did(4)) && (!$istok($asc($did(4)),35,32)) { did -b $dname 14 | set %info.error select a channel in destination }
  }
  if ($did == 2) {
    did -r $dname 3
    didtok $dname 3 32 $chans($did($dname,2).seltext)
    did -fc $dname 3 1
  }
  if ($did = 14) {
    if (!%infochan.spam) { 
      tokenize 32 $replace($did(1),Channel,-c,Onotice,-o,Notice,-n,Query,-q) $did(3) $did(4)
      scon $netid($did(2)) | infochan $1- | set -z %infochan.spam 10 | noop $input(Report sent!,o,Success!)
    }
    else { 
      noop $input(Don't spam that button! $crlf Wait $duration(%infochan.spam),o,Spam!) | return
    }
  }
}

/* 
┌──────────────┐
│ Channel Menu │
└──────────────┘
*/

menu channel {
  p&Sy
  .infochan
  ..Output → Echo:infochan -e $chan
  ..Output → Custom:infochand
}

;End of code