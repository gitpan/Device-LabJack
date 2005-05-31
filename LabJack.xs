#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "ljackuw.h"

MODULE = Device::LabJack		PACKAGE = Device::LabJack		

##############################################################################################	

=head1 NAME

Device::LabJack - a perl interface to the LabJack U12 (USB measurement/automation device - A/D, D/A converter and digital I/O)

=head1 DESCRIPTION

You can read and write digital and analog data to and from your LabJack U12 device with this module.

=head2 What is a LabJack?

LabJacks are USB/Ethernet based measurement and automation devices which provide analog inputs/outputs, digital inputs/outputs, and more. They serve as an inexpensive and easy to use interface between computers and the physical world.


=cut


##############################################################################################	



=head AISample

################################################################################

SYNOPSIS


# Example perl program which calls this module:-

use Device::LabJack;

$idnum=-1;
$demo=0;
$stateIO=0;
$updateIO=0;
$ledOn=1;
@channels=(0,1,2,3);
@gains=(0,0,0,0);
$disableCal=0;

my(@results)=Device::LabJack::AISample($idnum,$demo,$stateIO,$updateIO,$ledOn,\@channels,\@gains,$disableCal);
print join("\n",@results);

INFO

Reads the voltages from 1,2, or 4 analog inputs.  Also
controls/reads the 4 IO ports.  Execution time for this
function is 20 milliseconds or less.

Declaration:
long __cdecl AISample ( long *idnum,
                long demo,
                long *stateIO,
                long updateIO,
                long ledOn,
                long numChannels,
                long *channels,
                long *gains,
                long disableCal,
                long *overVoltage,
                float *voltages )

Parameter Description:
Returns:    LabJack errorcodes or 0 for no error.
Inputs:
·   *idnum - Local ID, serial number, or -1 for first found.
·   demo - Send 0 for normal operation, >0 for demo mode.  Demo mode allows this function to be called without a LabJack.
·   *stateIO - Output states for IO0-IO3.
·   updateIO - If >0, state values will be written.  Otherwise, just a read is performed.
·   ledOn - If >0, the LabJack LED is turned on.
·   numChannels - Number of analog input channels to read (1,2, or 4).
·   *channels - Pointer to an array of channel commands with at least numChannels elements.  Each channel command is 0-7 for single-ended, or 8-11 for differential.
·   *gains - Pointer to an array of gain commands with at least numChannels elements.  Gain commands are 0=1, 1=2, ..., 7=20.  This amplification is only available for differential channels.
·   disableCal - If >0, voltages returned will be raw readings that are not corrected using calibration constants.
·   *voltages - Pointer to an array where voltage readings are returned.  Send a 4-element array of zeros.
Outputs:
·   *idnum - Returns the local ID or -1 if no LabJack is found.
·   *overVoltage - If >0, an overvoltage has been detected on one of the selected analog inputs.

=cut

void
AISample(idnum,demo,stateIO,updateIO,ledOn,channels,gains,disableCal)
        int idnum
        int demo
        int stateIO
        int updateIO
        int ledOn
//        int numCh
        SV * channels
        SV * gains
        int disableCal
    INIT:
        int i,n,numchannels,numgains,numCh;
        long errorcode;
        long lchannels[14]; // ={0,1,2,3};
        long lgains[14];     // ={0,0,0,0};
        long ov;
        float voltages[4]={0,0,0,0};

        // Check that they passed an array of channels, and count the elements
        if ((!SvROK(channels))
            || (SvTYPE(SvRV(channels)) != SVt_PVAV)
            || ((numchannels = av_len((AV *)SvRV(channels))) < 0))
        {
            XSRETURN_UNDEF;
        }

        // Check that they passed an array of gains, and count the elements
        if ((!SvROK(gains))
            || (SvTYPE(SvRV(gains)) != SVt_PVAV)
            || ((numgains = av_len((AV *)SvRV(gains))) < 0))
        {
            XSRETURN_UNDEF;
        }

        // Make sure there's a gain for every channel
        if(numgains<numchannels) {
            XSRETURN_UNDEF;
        }

    PPCODE:

        // Extract the channels we got from perl...
        for (n = 0; n <= numchannels; n++) {
                lchannels[n]= SvNV(*av_fetch((AV *)SvRV(channels), n, 0));
        }
        // Extract the gains we got from perl...
        for (n = 0; n <= numgains; n++) {
                lgains[n]= SvNV(*av_fetch((AV *)SvRV(gains), n, 0));
        }
        numCh=numchannels+1;

        // Run the command
        errorcode = AISample (&idnum,demo,&stateIO,updateIO,ledOn,numCh,lchannels,lgains,disableCal,&ov,voltages);

        // Return the results to perl in a big array
        if(errorcode) {
          char errorString[51];
          GetErrorString ( errorcode, errorString );
          XPUSHs(sv_2mortal(newSVpv(errorString,0)));
        } else {
          XPUSHs(sv_2mortal(newSVnv(errorcode)));
        }

        XPUSHs(sv_2mortal(newSVnv(idnum)));
        XPUSHs(sv_2mortal(newSVnv(ov)));
        XPUSHs(sv_2mortal(newSVnv(stateIO)));
        for(i=0;i<numCh;i++)XPUSHs(sv_2mortal(newSVnv(voltages[i])));
        












=head AOUpdate

################################################################################


INFO

Sets the voltages of the analog outputs. Also controls/reads all 20 digital 
I/O and the counter. Execution time for this function is 20 milliseconds or 
less. 

Declaration:
long AOUpdate ( long *idnum,
                long demo,
                long trisD,
                long trisIO,
                long *stateD,
                long *stateIO,
                long updateDigital,
                long resetCounter,
                unsigned long *count,
                float analogOut0,
                float analogOut1)


Parameter Description:
Returns: LabJack errorcodes or 0 for no error.
Inputs:
  - *idnum - Local ID, serial number, or -1 for first found.
  - demo - Send 0 for normal operation, >0 for demo mode. Demo mode allows this function to be called without a LabJack.
  - trisD - Directions for D0-D15. 0=Input, 1=Output.
  - trisIO - Directions for IO0-IO3. 0=Input, 1=Output.
  - *stateD - Output states for D0-D15.
  - *stateIO - Output states for IO0-IO3.
  - updateDigital - If >0, tris and state values will be written. Otherwise, just a read is performed.
  - resetCounter - If >0, the counter is reset to zero after being read.
  - analogOut0 - Voltage from 0.0 to 5.0 for AO0.
  - analogOut1 - Voltage from 0.0 to 5.0 for AO1.
Outputs:
  - *idnum - Returns the local ID or -1 if no LabJack is found.
  - *stateD - States of D0-D15.
  - *stateIO - States of IO0-IO3.
  - *count - Current value of the 32-bit counter (CNT). This value is read before the counter is reset.

=cut

void
AOUpdate (idnum,demo,trisD,trisIO,stateD,stateIO,updateDigital,resetCounter,analogOut0,analogOut1)
        int idnum
        int demo
        int trisD
        int trisIO
        int stateD
        int stateIO
        int updateDigital
        int resetCounter
        float analogOut0
        float analogOut1

    INIT:
        unsigned count=0;
        long errorcode=0;
//        int lstateD=0;
//        int lstateIO=0;


    PPCODE:

        // Run the command
        // errorcode = AISample (&idnum,demo,&stateIO,updateIO,ledOn,numCh,lchannels,lgains,disableCal,&ov,voltages);

        errorcode = AOUpdate (&idnum,demo,trisD,trisIO,&stateD,&stateIO,updateDigital,resetCounter,&count,analogOut0,analogOut1);

        // Return the results to perl in a big array
        if(errorcode) {
          char errorString[51];
          GetErrorString ( errorcode, errorString );
          XPUSHs(sv_2mortal(newSVpv(errorString,0)));
        } else {
          XPUSHs(sv_2mortal(newSVnv(errorcode)));
        }

        XPUSHs(sv_2mortal(newSVnv(idnum)));
        XPUSHs(sv_2mortal(newSVnv(stateD)));
        XPUSHs(sv_2mortal(newSVnv(stateIO)));
        XPUSHs(sv_2mortal(newSVnv(count)));
        









=head AIBurst

################################################################################


INFO

Reads a specified number of scans (up to 4096) at a specified scan rate (up to 8192 Hz) from
1,2, or 4 analog inputs. First, data is acquired and stored in the LabJack's 4096 sample RAM
buffer. Then, the data is transferred to the PC.

Declaration:
long AIBurst ( long *idnum,
               long demo,
               long stateIOin,
               long updateIO,
               long ledOn,
               long numChannels,
               long *channels,
               long *gains,
               float *scanRate,
               long disableCal,
               long triggerIO,
               long triggerState,
               long numScans,
               long timeout,
               float (*voltages)[4],
               long *stateIOout,
               long *overVoltage,
               long transferMode )


Parameter Description:
Returns: LabJack errorcodes or 0 for no error.
Inputs:
  - *idnum   -   Local ID, serial number, or -1 for first found.
  - demo   -   Send 0 for normal operation, >0 for demo mode. Demo mode allows this function to be called without a LabJack.
  - *stateIOin   -   Output states for IO0-IO3.
  - updateIO   -   If >0, state values will be written. Otherwise, just a read is performed.
  - ledOn   -   If >0, the LabJack LED is turned on.
  - numChannels   -   Number of analog input channels to read (1,2, or 4).
  - *channels   -   Pointer to an array of channel commands with at least numChannels elements. Each channel command is 0-7 for single-ended, or 8-11 for differential.
  - *gains   -   Pointer to an array of gain commands with at least numChannels elements. Gain commands are 0=1, 1=2, ..., 7=20. This amplification is only available for differential channels.
  - *scanRate   -   Scans acquired per second. A scan is a reading from every channel (1,2, or 4). The sample rate (scanRate * numChannels) must be between 400 and 8192.
  - disableCal   -   If >0, voltages returned will be raw readings that are not corrected using calibration constants.
  - triggerIO   -   The IO port to trigger on (0=none, 1=IO0, ...,4=IO3).
  - triggerState   -   If >0, the acquisition will be triggered when the selected IO port reads high.
  - numScans   -   Number of scans which will be returned. Minimum is 1. Maximum numSamples is 4096, where numSamples is numScans * numChannels.
  - timeout   -   This function will return immediately with a timeout error if it does not receive a scan within this number of seconds.
  - *voltages   -   Pointer to a 4096 by 4 array where voltage readings are returned. Send filled with zeros.
  - *stateIOout   -   Pointer to a 4096 element array where IO states are returned. Send filled with zeros.
  - transferMode   -  Always send 0.

Outputs:
  - *idnum   -   Returns the local ID or -1 if no LabJack is found.
  - *scanRate   -   Returns the actual scan rate, which due to clock resolution is not always exactly the same as the desired scan rate.
  - *voltages   -   Pointer to a 4096 by 4 array where voltage readings are returned. Unused locations are filled with 9999.0.
  - *stateIOout   -   Pointer to a 4096 element array where IO states are returned. Unused locations are filled with 9999.0.
  - *overVoltage   -   If >0, an overvoltage has been detected on at least one sample of one of the selected analog inputs.

=cut



void 
AIBurst(idnum,demo,stateIOin,updateIO,ledOn,channels,gains,scanRate,disableCal,triggerIO,triggerState,numScans,timeout,transferMode)
        long idnum
        long demo
        long stateIOin
        long updateIO
        long ledOn
//        int numCh             we can work this out from the size of the perl array
        SV * channels
        SV * gains
        float scanRate
        long disableCal
        long triggerIO
        long triggerState
        long numScans
        long timeout
//        SV * voltages         These are output vectors
//        SV * stateIOout
        long transferMode
    INIT:
        int i,n,j,numchannels,numgains,numCh; // ,numvoltages,numstateIOout
        long errorcode;
        long lchannels[14]; // ={0,1,2,3};
        long lgains[14];     // ={0,0,0,0};
        long ov;
        // float voltages[4]={0,0,0,0};
        float voltages[4096][4];
        long stateIOout[4096];

        // Check that they passed an array of channels, and count the elements
        if ((!SvROK(channels))
            || (SvTYPE(SvRV(channels)) != SVt_PVAV)
            || ((numchannels = av_len((AV *)SvRV(channels))) < 0))
        {
            XSRETURN_UNDEF;
        }

        // Check that they passed an array of gains, and count the elements
        if ((!SvROK(gains))
            || (SvTYPE(SvRV(gains)) != SVt_PVAV)
            || ((numgains = av_len((AV *)SvRV(gains))) < 0))
        {
            XSRETURN_UNDEF;
        }

        // Make sure there's a gain for every channel
        if(numgains<numchannels) {
            XSRETURN_UNDEF;
        }


    PPCODE:

        // Extract the channels we got from perl...
        for (n = 0; n <= numchannels; n++) {
                lchannels[n]= SvNV(*av_fetch((AV *)SvRV(channels), n, 0));
        }
        // Extract the gains we got from perl...
        for (n = 0; n <= numgains; n++) {
                lgains[n]= SvNV(*av_fetch((AV *)SvRV(gains), n, 0));
        }
        numCh=numchannels+1;

        // clear the output area
        memset(stateIOout,0,4096*sizeof(long));
        memset(voltages,0,4*4096*sizeof(float));

        // Run the command
        errorcode = AIBurst (&idnum,
                             demo,
                             stateIOin,
                             updateIO,
                             ledOn,
                             numCh,
                             lchannels,
                             lgains,
                             &scanRate,
                             disableCal,
                             triggerIO,
                             triggerState,
                             numScans,
                             timeout,
                             voltages,
                             stateIOout,
                             &ov,
                             transferMode);

        // Return the results to perl in a big array
        if(errorcode) {
          char errorString[51];
          GetErrorString ( errorcode, errorString );
          XPUSHs(sv_2mortal(newSVpv(errorString,0)));
        } else {
          XPUSHs(sv_2mortal(newSVnv(errorcode)));
        }

        XPUSHs(sv_2mortal(newSVnv(idnum)));
        XPUSHs(sv_2mortal(newSVnv(scanRate)));
        XPUSHs(sv_2mortal(newSVnv(ov)));
        for(i=0;i<numScans;i++)
          for(j=0;j<numCh;j++)
            XPUSHs(sv_2mortal(newSVnv(voltages[i][j])));
        for(i=0;i<numScans;i++)
          XPUSHs(sv_2mortal(newSVnv(stateIOout[i])));
        



