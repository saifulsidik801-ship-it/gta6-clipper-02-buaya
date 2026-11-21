#!/bin/bash
# Render the 2nd GTA 6 clipper entry: Windah vs the crocodile ("misteri buaya").
# Single moment, not a compilation (top-10 study: 9 of the top 10 are one moment).
# Source: Windah Basudara, GTA VI GAMEPLAY #4 (03qhcshfeMY), "misteri buaya" arc.
# File source.mp4 starts at stream 16:00, so file time = stream time - 16:00.
#
# Beats (file time, each keeps its own stream audio — honest cuts):
#  b1 HOOK    175-180  (stream 18:55-19:00) Jason down in the reeds beside the
#                      giant gator, Windah wide-eyed. Caption: HAMPIR DIMAKAN / BUAYA
#  b2 APPROACH 164-170 (stream 18:44-18:50) boat in the reeds, gators in the water,
#                      "Ada buaya dong. Banyak banget." Caption: ADA BUAYA... / BANYAK BANGET
#  b3 CLIMAX  190-197  (stream 19:08-19:16) Jason aiming his pistol at the gator at
#                      golden sunset, muzzle flash. "Sorry ya gua tembak ya."
#                      Caption: SORRY YA... / GUA TEMBAK YA
#  b4 PAYOFF  229-235  (stream 19:49-19:55) Jason walks off with the package (+$400),
#                      "Misteri buaya gua pecahkan... Mirip gua emang mirip gua
#                      buayanya... Gak gua kill." Caption: BUAYANYA MIRIP GUA / GAK GUA KILL
#  pitch 24-29 (5 s black card, same wording as the v3 entry, per RULES.txt)
# Timeline: b1 0-5 | b2 5-11 | b3 11-18 | b4 18-24 | pitch 24-29 (29 s total)
# Layout: 16:9 source centred in 1080x1920 over a blurred dark backdrop
# (same as the v3 entry), big Noto Sans Bold captions in the top band.
# No intro card: the top-10 clips open on the action, so the gator shot IS the hook.
#
# AUDIO: source.mp4's own audio track is BROKEN (yt-dlp's mp4 section mux wrote
# only 13.5 s of Opus audio for a 285 s video, and that fragment is a different
# track — it has silences where the subtitles show continuous speech). The real
# audio is g4_croc_audio.webm (audio-only download of the same section, 295 s).
# Alignment verified: the webm's gunshot bump sits at file 193.4 (muzzle flash at
# file 193) and its near-silence at 195.4-196.6 falls in the no-dialogue window
# after the "Sorry ya" line (subs: line ends 19:14, next line 19:26) — so the
# webm audio is aligned with the video at offset 0. Video comes from input 0,
# audio from input 1.
set -euo pipefail
cd ~/workspace/makefun/gta6-clipper-02-buaya

FONT=/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf
OUT=windah-gta6-buaya.mp4

# beat: $1=start $2=end $3=line1 $4=line2 $5=tag $6=line1 colour $7=line2 colour
beat() {
  local s="$1" e="$2" l1="$3" l2="$4" t="$5" c1="${6:-white}" c2="${7:-white}"
  printf '[0:v]trim=start=%s:end=%s,setpts=PTS-STARTPTS,fps=30,split=2[%sbg][%sfg];' "$s" "$e" "$t" "$t"
  printf '[%sbg]scale=270:480,gblur=sigma=20,scale=1080:1920,eq=brightness=-0.3[%sbgb];' "$t" "$t"
  printf '[%sfg]scale=1080:608[%sfgs];' "$t" "$t"
  printf '[%sbgb][%sfgs]overlay=(W-w)/2:(H-h)/2,setsar=1,' "$t" "$t"
  printf "drawtext=fontfile=%s:text='%s':fontsize=96:fontcolor=%s:borderw=4:bordercolor=black:box=1:boxcolor=black@0.45:boxborderw=28:x=(w-text_w)/2:y=180," "$FONT" "$l1" "$c1"
  if [ -n "$l2" ]; then
    printf "drawtext=fontfile=%s:text='%s':fontsize=96:fontcolor=%s:borderw=4:bordercolor=black:box=1:boxcolor=black@0.45:boxborderw=28:x=(w-text_w)/2:y=300," "$FONT" "$l2" "$c2"
  fi
  printf 'format=yuv420p[%sv];' "$t"
  printf '[1:a]atrim=start=%s:end=%s,asetpts=PTS-STARTPTS,aresample=48000[%sa];' "$s" "$e" "$t"
}

FC=""
FC+=$(beat 175 180 'HAMPIR DIMAKAN' 'BUAYA' b1 yellow yellow)
FC+=$(beat 164 170 'ADA BUAYA...' 'BANYAK BANGET' b2)
FC+=$(beat 190 197 'SORRY YA...' 'GUA TEMBAK YA' b3)
FC+=$(beat 229 235 'BUAYANYA MIRIP GUA' 'GAK GUA KILL' b4 white yellow)
# pitch card: 5 s black, 3 lines (RULES.txt: the clip itself must carry make.fun's pitch)
FC+="color=c=black:s=1080x1920:d=5:r=30,setsar=1,format=yuv420p,"
FC+="drawtext=fontfile=$FONT:text='Bikin klip kayak gini pake AI':fontsize=62:fontcolor=white:borderw=3:bordercolor=black:x=(w-text_w)/2:y=780,"
FC+="drawtext=fontfile=$FONT:text='dan dapet duit di make.fun':fontsize=62:fontcolor=white:borderw=3:bordercolor=black:x=(w-text_w)/2:y=870,"
FC+="drawtext=fontfile=$FONT:text='make.fun/bounty/gta6-clipper-01':fontsize=48:fontcolor=yellow:borderw=3:bordercolor=black:x=(w-text_w)/2:y=1000[pv];"
FC+="anullsrc=channel_layout=stereo:sample_rate=48000,atrim=0:5,asetpts=PTS-STARTPTS[pa];"
FC+="[b1v][b1a][b2v][b2a][b3v][b3a][b4v][b4a][pv][pa]concat=n=5:v=1:a=1[v][a]"

ffmpeg -y -v error -stats \
  -i source.mp4 -i g4_croc_audio.webm \
  -filter_complex "$FC" \
  -map "[v]" -map "[a]" \
  -c:v libx264 -crf 20 -preset veryfast -r 30 \
  -c:a aac -b:a 128k -movflags +faststart \
  "$OUT"
echo "== done =="
ffprobe -v error -show_entries format=duration,size -show_entries stream=codec_name,width,height,r_frame_rate -of default=noprint_wrappers=1 "$OUT"
