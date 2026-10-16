# NIVO Feeder (nivoplacer)

A feeder implementation for NIVO auto tape feeders on a QR-addressed feeder bus.
Functionally identical to the original RapidFeeder implementation, with a
configuration wizard that adds QR code scanning for automatic feeder discovery.

## Requirements

- An actuator named exactly `nivo` must exist on the machine. The feeder sends
  `actuate(String)` commands to this actuator to perform bus actions.
- A sub-driver under GcodeDriver for the NIVO feeder system. Under
  ACTUATE_STRING_COMMAND add `M603 {StringValue}` and hit apply.
  M603 is to advance the tape forward and M602 is reverse. Adjust the G-code
  to match your controller.

## Setup and Scanning

Create a new NIVO feeder from the Feeders tab (the New Feeder chooser only
offers NIVO in this build). Name it something that describes the bank of
feeders it will scan for, such as NIVO-West.

In the settings for the feeder, locate the "NIVO Feeder Scanning" section and
define the Scan Start, Scan End and Scan Increment values:

- Scan Start: camera position over the first possible QR code.
- Scan End: camera position over the last possible QR code.
- Scan Increment: about half the size of the camera image frame, so the scan
  never advances past a QR code and misses it.

Press Scan. The camera moves along the line formed by the start and end
points, captures frames and decodes QR codes. It then creates or updates a
NIVO feeder for each QR code found: name = address = QR text, pick location =
QR code center.

## Usage

Pressing Feed on a NIVO feeder sends `{address} {pitch}` to the `nivo`
actuator, which the GcodeDriver substitutes into the ACTUATE_STRING_COMMAND,
e.g. `M603 <address> <pitch>`.

Note: most other feeder implementations are hidden from the New Feeder chooser.
The chooser offers NIVO plus ReferenceAutoFeeder, ReferenceSlotAutoFeeder,
ReferencePushPullFeeder and ReferenceStripFeeder (sprocket-hole vision strip
feeder from upstream OpenPnP). Feeders of other classes already saved in
machine.xml still load and work.
