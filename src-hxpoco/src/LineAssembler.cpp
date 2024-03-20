#include "Lightstreamer/HxPoco/LineAssembler.h"

namespace {

using Lightstreamer::HxPoco::LineAssembler;

constexpr char LF = '\n';
constexpr char CR = '\r';

int indexOf(const LineAssembler::ByteBuf& buf, int startIndex, int endIndex, char c) {
  auto itBegin = buf.begin() + startIndex;
  auto itEnd = buf.begin() + endIndex;
  auto it = std::find(itBegin, itEnd, c);
  return it == itEnd ? -1 : it - itBegin;
}

/**
 * Finds the index of a CR LF sequence (EOL). The index points to LF.
 * Returns -1 if there is no EOL.
 * @param startIndex starting index (inclusive)
 * @param endIndex ending index (exclusive)
 */
int findEol(const LineAssembler::ByteBuf& buf, int startIndex, int endIndex)
{
  int eolIndex = -1;
  if (startIndex >= endIndex)
  {
    return eolIndex;
  }
  int crIndex = indexOf(buf, startIndex, endIndex, CR);
  if (crIndex != -1 && crIndex != endIndex - 1 // CR it is not the last byte
      && buf[crIndex + 1] == LF)
  {
    eolIndex = crIndex + 1;
  }
  return eolIndex;
}

/**
 * Copies a slice of a frame representing a part of a bigger string in a temporary buffer to be reassembled.
 * @param startIndex starting index (inclusive)
 * @param endIndex ending index (exclusive)
 */
void copyLinePart(const LineAssembler::ByteBuf& buf, std::string& linePart, int startIndex, int endIndex)
{
  auto itBegin = buf.begin();
  linePart.append(itBegin + startIndex, itBegin + endIndex);
}

/**
 * Converts a line to a UTF-8 string.
 * @param startIndex starting index (inclusive)
 * @param endIndex ending index (exclusive)
 */
std::string_view byteBufToString(const LineAssembler::ByteBuf& buf, int startIndex, int endIndex)
{
  return std::string_view(buf.begin() + startIndex, endIndex - startIndex);
}

/**
 * Returns the last byte written.
 */
inline char peekAtLastByte(const std::string& s) {
  return s.back();
}

/**
 * Converts the bytes in a UTF-8 string. The last two bytes (which are always '\r' '\n') are excluded.
 */
inline std::string_view toLine(std::string_view s) {
  auto sz = s.size();
  poco_assert_dbg(sz >= 2);
  poco_assert_dbg(s[sz - 2] == CR);
  poco_assert_dbg(s[sz - 1] == LF);
  return s.substr(0, sz - 2);
}

inline void reset(std::string& s) {
  s.resize(0);
}

} // END unnamed namespace

/**
 * Reads the available bytes and extracts the contained lines. 
 * For each line found the given callback is notified.
 */
void LineAssembler::readBytes(const ByteBuf& buf, std::function<void(std::string_view)> callback) {
  /*
   * A frame has the following structure:
   * <frame> ::= <head><body><tail>
   *
   * The head of a frame (if present) is the rest of a line started in a previous frame.
   * <head> ::= <rest-previous-line>?
   * <rest-previous-line> ::= <line-part><LF>
   * NB line-part can be empty. In that case the char CR is in the previous frame.
   *
   * The body consists of a sequence of whole lines.
   * <body> ::= <line>*
   * <line> ::= <line-body><EOL>
   *
   * The tail of a frame (if present) is a line lacking the EOL terminator (NB it can span more than one frame).
   * <tail> ::= <line-part>?
   *
   * EOL is the sequence \r\n.
   * <EOL> ::= <CR><LF>
   *
   */
  /*
   * NB
   * startIndex and eolIndex are the most important variables
   * and they must be updated together since they represents the next part of frame to elaborate.
   */
  const int endIndex = buf.size(); // ending index of the byte buffer (exclusive)
  int startIndex = 0; // starting index of the current line/part of line (inclusive)
  int eolIndex; // ending index of the current line/part of line (inclusive) (it points to EOL)
  if (startIndex >= endIndex)
  {
    return; // byte buffer is empty: nothing to do
  }
  /* head */
  bool hasHead;
  const bool prevLineIsIncomplete = linePart.size() != 0;
  if (prevLineIsIncomplete)
  {
    /*
     * Since the previous line is incomplete (it lacks the line terminator),
     * is the rest of the line in this frame?
     * We have three cases:
     * A) the char CR is in the previous frame and the char LF is in this one;
     * B) the chars CR and LF are in this frame;
     * C) the sequence CR LF is not in this frame (maybe there is CR but not LF).
     *
     * If case A) or B) holds, the next part to compute is <head> (see grammar above).
     * In case C) we must compute <tail>.
     */
    if (peekAtLastByte(linePart) == CR && buf[startIndex] == LF)
    {
      // case A) EOL is across the previous and the current frame
      hasHead = true;
      eolIndex = startIndex;
    }
    else
    {
      eolIndex = findEol(buf, startIndex, endIndex);
      if (eolIndex != -1)
      {
        // case B)
        hasHead = true;
      }
      else
      {
        // case C)
        hasHead = false;
      }
    }
  }
  else
  {
    /*
     * The previous line is complete.
     * We must consider two cases:
     * D) the sequence CR LF is in this frame;
     * E) the sequence CR LF is not in this frame (maybe there is CR but not LF).
     *
     * If case D) holds, the next part to compute is <body>.
     * If case E) holds, the next part is <tail>.
     */
    hasHead = false;
    eolIndex = findEol(buf, startIndex, endIndex);
  }
  if (hasHead)
  {
    copyLinePart(buf, linePart, startIndex, eolIndex + 1);
    const auto line = toLine(linePart);
    callback(line);

    startIndex = eolIndex + 1;
    eolIndex = findEol(buf, startIndex, endIndex);
    reset(linePart);
  }
  /* body */
  while (eolIndex != -1)
  {
    const auto line = byteBufToString(buf, startIndex, eolIndex - 1); // exclude CR LF chars
    callback(line);

    startIndex = eolIndex + 1;
    eolIndex = findEol(buf, startIndex, endIndex);
  }
  /* tail */
  const bool hasTail = startIndex != endIndex;
  if (hasTail)
  {
    copyLinePart(buf, linePart, startIndex, endIndex);
  }
}