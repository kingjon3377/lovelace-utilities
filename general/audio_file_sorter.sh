#!/bin/sh
# Test the format of a file; if it's a MP3, FLAC, MP4 or Ogg Vorbis audio file
# (per the "file" command), silently succeed, but otherwise report what kind of
# file it is. This was created to help in putting music from my collection on a
# portable music player that supports "OGG" but not the Opus codec and not some
# Vorbis-encoded Ogg files.
format="$(file -F @ -N "${1}" | sed -e 's#^.*@ \(.*\)$#\1#')"
case "${format}" in
"Audio file with ID3 version "[0-9].[0-9].[0-9]", contains:MPEG ADTS, layer III, v"[0-9]", "*" kbps, "*" kHz, JntStereo") : ;;
"Audio file with ID3 version "[0-9].[0-9].[0-9]", contains:MPEG ADTS, layer III, v"[0-9]", "*" kbps, "*" kHz, Stereo") : ;;
"Audio file with ID3 version "[0-9].[0-9].[0-9]", contains:MPEG ADTS, layer III, v"[0-9]", "*" kbps, "*" kHz, Monaural") : ;;
"Audio file with ID3 version "[0-9].[0-9].[0-9]) echo "${1} has ID3 tag but isn't MP3" ;;
data) echo "${1} isn't recogized as any file format known to libmagic" ;;
"FLAC audio bitstream data, "*" bit, stereo, "*" kHz, "*" samples") : ;;
"ISO Media, Apple iTunes ALAC/AAC-LC (.M4A) Audio") : ;;
"ISO Media, MP4 Base Media v"[0-9]" [IS0 14496-12:2003]") : ;;
"ISO Media, MP4 v"[0-9]" [ISO 14496-14]") : ;;
"ISO Media, MPEG v4 system, Dynamic Adaptive Streaming over HTTP") : ;;
"Microsoft ASF") echo "${1} is ASF" ;;
"MPEG ADTS, layer III, v"[0-9]", "*" kbps, "*" kHz, JntStereo") : ;;
"MPEG ADTS, layer III, v"[0-9]", "*" kbps, "*" kHz, Stereo") : ;;
"MPEG ADTS, layer III, v"[0-9]", "*" kbps, "*" kHz, Monaural") : ;;
"Ogg data, Opus audio,") echo "${1} uses Opus audio codec, which may not be supported" ;;
"Ogg data, Skeleton v"[0-9].[0-9]) echo "${1} is \"Ogg Skeleton\", which may not be supported" ;;
"Ogg data, Vorbis audio, mono, "*" Hz, "*" bps, created by: "*) : ;;
"Ogg data, Vorbis audio, mono, "*" Hz, "*" bps") : ;;
"Ogg data, Vorbis audio, stereo, "*" Hz, "*" bps, created by: "*) : ;;
"Ogg data, Vorbis audio, stereo, "*" Hz, "*" bps") : ;;
"RIFF (little-endian) data, WAVE audio, Microsoft PCM, "*" bit, mono "*" Hz") echo "${1} is a WAV" ;;
*) echo "${1} is an unanticipated format, to wit \"${format}\"" ;;
esac
