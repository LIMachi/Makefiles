import argparse
import math
import sys
import shutil

def get_progress_bar(numchars, fraction=None, percent=None):
  if percent is not None:
    fraction = percent / 100.0
  if fraction >= 1.0:
    return "█" * numchars
  blocks = [" ", "▏", "▎", "▍", "▌", "▋", "▊", "▉", "█"]
  length_in_chars = fraction * numchars
  n_full = int(length_in_chars)
  i_partial = int(8 * (length_in_chars - n_full))
  n_empty = max(numchars - n_full - 1, 0)
  return ("█" * n_full) + blocks[i_partial] + (" " * n_empty)

def main():
  col = shutil.get_terminal_size((80,25)).columns - 40
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("--stepno", type=int, required=True)
  parser.add_argument("--nsteps", type=int, required=True)
  parser.add_argument("remainder", nargs=argparse.REMAINDER)
  args = parser.parse_args()
  if args.nsteps < 1:
    args.nsteps = 1
  nchars = int(math.log(args.nsteps, 10)) + 1
  if args.stepno != 1:
    sys.stdout.write("\x1b[1A\x1b[2K") #moves the cursor up 1 line, then clear the line
  fmt_str = "[{:Xd}/{:Xd}]({:6.2f}%) ".replace("X", str(nchars)) #numerical progress string
  progress = 100 * args.stepno / args.nsteps
  sys.stdout.write(fmt_str.format(args.stepno, args.nsteps, progress)) #write numerical progress
  sys.stdout.write(get_progress_bar(20, percent=progress)) #write visual progress bar
  remainder_str = " ".join(args.remainder)
  sys.stdout.write(" {:s}\n".format(remainder_str[:col])) #writes the rest of the echo call, truncated to the terminal width
  sys.stdout.flush()

if __name__ == "__main__":
  main()
