/*
    ASInetUsageController.m
    InternetUsage
    
    Copyright (c) 2009, Shane Ambler
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without 
    modification, are permitted provided that the following conditions are met:

        *   Redistributions of source code must retain the above copyright
            notice, this list of conditions and the following disclaimer.
        *   Redistributions in binary form must reproduce the above copyright 
            notice, this list of conditions and the following disclaimer in the
            documentation and/or other materials provided with the distribution.
            
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
    OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
    PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
    NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
******************************************************************************
    Change History :-
    29/10/2009 - Created by Shane Ambler
    
*/

#import "ASInetUsageController.h"
#import "ASHistoryDay.h"

@implementation ASInetUsageController


-(void)awakeFromNib
{
    [oShowVersion setStringValue:VERS];
    [oTabView selectFirstTabViewItem:nil];
    // IB doesn't allow us to disable mouse clicks in the nib
    // we disable this so the user doesn't move the level unwittingly
    // we are using an adjustable control for display only purposes
    [oUsageRemainingLevel setEnabled:false];
    [oDaysRemainingLevel setEnabled:false];
    [oDifferenceLevel setEnabled:false];
    [oAllowancePerDayLevel setEnabled:false];
    [oCurrentAverageLevel setEnabled:false];
    [oAverageRemainingLevel setEnabled:false];
    [oTodaysUsageLevel setEnabled:false];
}

- (IBAction)changeHistory:(id)sender
{
}

- (IBAction)changeStartup:(id)sender
{
}

- (IBAction)changeUpdate:(id)sender
{
}

- (IBAction)ruleAdd:(id)sender
{
}

- (IBAction)ruleRemove:(id)sender
{
}

- (IBAction)changeSave:(id)sender
{
}

- (IBAction)update:(id)sender
{
    [oShowStatus setStringValue:@"Updating"];
    
    //======== testing only
    mAccSpeed = [NSString stringWithFormat:@"24 Mbits/sec"];
    mAccISO = [NSString stringWithFormat:@"10098.845488 40000 20091126 0.00"]; // live sample - ttlDown quota rollover ???
    mPeriodStartDate = [NSCalendarDate dateWithString:[[mAccISO componentsSeparatedByString:@" "]objectAtIndex:2] calendarFormat:@"%Y%m%d"];
    
    [self readInData];
    
    //======== end testing
    [self refreshWindow];
    if( [oTabView indexOfTabViewItem:[oTabView selectedTabViewItem]] > 0 )
	[oTabView selectFirstTabViewItem:nil];
	
    [oTabView selectNextTabViewItem:nil];
}

-(void)refreshWindow
{
    [oExcessBilledAt setStringValue:@"$0.00 per MB (not implemented)"];  //Do we need this??? - Business acc maybe
    [oDownloadSpeed setStringValue:mAccSpeed];
    [oPeriodStartDate setStringValue:[mPeriodStartDate descriptionWithCalendarFormat:@"%d/%m/%Y"]];
    
    
    [oPrepaidMB setStringValue:[self downloadQuota]];
    [oAmountUsed setStringValue:[self quotaUsed]];
    [oUsageRemaining setStringValue:[self quotaRemaining]];
    [oUsageRemainingPC setStringValue:[self quotaRemainingPC]];
    [oUsageRemainingLevel setFloatValue:[[self quotaRemainingPC]floatValue]];
    [oDaysRemaining setStringValue:[self daysRemaining]];
    [oDaysRemainingPC setStringValue:[self daysRemainingPC]];
    [oDaysRemainingLevel setFloatValue:[[self daysRemainingPC]floatValue]];
//    oDifference;//Do we need these?? -- how do we calc the diff?
//    oDifferencePC;
//    oDifferenceLevel;
//    oAllowancePerDay;
//    oAllowancePerDayLevel;
//    oCurrentAverage;
//    oCurrentAverageLevel;
//    oAverageRemaining;
//    oAverageRemainingLevel;
//    oTodaysUsage;
//    oTodaysUsageLevel;
//    oShowScale;
//    oAverageForPeriod;
//    oTotalForPeriod;
//    oTopScale;
//    oFirstDate;
//    oLastDate;
//    oCurrentDate;
//    oPeriodSelection; //Do we need to talk to this???
//    oAddRule;
//    oRemoveRule;
//    oRulesList;
//    oUpdateOption;
//    oShowMeter;
//    oAboutIcon;
        [oShowStatus setStringValue:@"Idle"];
	[oLastUpdate setStringValue:[NSString stringWithFormat:@"Last update %@",[[NSCalendarDate calendarDate]description]]];
}

-(void)readInData
{
    NSBundle *myBundle;
    NSString *historydata;
    NSStringEncoding tmpenc;
    NSError *tmperror = [[NSError alloc]init];
    NSString *histPath;
    
    mHistory = [[ASHistory alloc]init];
    
    // for testing only
    myBundle = [NSBundle mainBundle];
    histPath = [myBundle pathForResource:@"padsl-usage" ofType:@"txt"];
    historydata = [NSString stringWithContentsOfFile:histPath usedEncoding:&tmpenc error:&tmperror];
    
    [mHistory addHistory:historydata];
    //[myBundle release];
    //[historydata release];
    [tmperror release];
    
}

-(NSString*)downloadQuota
{
    NSString *tmpStr;
    NSArray *tmpArray;
    
    tmpArray = [mAccISO componentsSeparatedByString:@" "];
    tmpStr = [tmpArray objectAtIndex:1];
    
    if( [tmpStr intValue] > MB_GB_Conversion )
	tmpStr = [NSString stringWithFormat:@"%.2f GB",(float)[tmpStr floatValue]/MB_GB_Conversion];
    else
	tmpStr = [NSString stringWithFormat:@"%@ MB",tmpStr];
    
    return tmpStr;
}

-(NSString*)quotaUsed
{
    NSString *tmpStr;
    NSArray *tmpArray;
    
    tmpArray = [mAccISO componentsSeparatedByString:@" "];
    tmpStr = [tmpArray objectAtIndex:0];
    
    if( [tmpStr intValue] > MB_GB_Conversion )
	tmpStr = [NSString stringWithFormat:@"%.2f GB",[tmpStr floatValue]/MB_GB_Conversion];
    else
	tmpStr = [NSString stringWithFormat:@"%@ MB",tmpStr];
    
    return tmpStr;
}

-(NSString*)quotaRemaining
{
    NSString *tmpStr;
    NSArray *tmpArray;
    float qRemaining;
    
    tmpArray = [mAccISO componentsSeparatedByString:@" "];
    qRemaining = [[tmpArray objectAtIndex:1]floatValue] - [[tmpArray objectAtIndex:0]floatValue];
    
    if( qRemaining > MB_GB_Conversion )
	tmpStr = [NSString stringWithFormat:@"%.2f GB",qRemaining/MB_GB_Conversion];
    else
	tmpStr = [NSString stringWithFormat:@"%f MB",qRemaining];
    
    return tmpStr;
}

-(NSString*)quotaRemainingPC
{
    NSArray *tmpArray;
    float qUsed,quota;
    
    tmpArray = [mAccISO componentsSeparatedByString:@" "];
    qUsed = [[tmpArray objectAtIndex:0]floatValue];
    quota = [[tmpArray objectAtIndex:1]floatValue];
    
    return [NSString stringWithFormat:@"%.0f %%",(1-(qUsed/quota))*100];
}

-(NSString*)daysRemaining
{
    int daysLeft, hoursLeft;
    
    [mPeriodStartDate years:NULL months:NULL days:&daysLeft hours:&hoursLeft minutes:NULL seconds:NULL sinceDate:[NSCalendarDate calendarDate]];
    
    return [NSString stringWithFormat:@"%.2f Days",daysLeft+(hoursLeft/(float)24)];
}

-(NSString*)daysRemainingPC
{
    int daysLeft, hoursLeft, daysInPeriod;
    NSCalendarDate *startDate;
    
    [mPeriodStartDate years:NULL months:NULL days:&daysLeft hours:&hoursLeft minutes:NULL seconds:NULL sinceDate:[NSCalendarDate calendarDate]];
    
    startDate = [mPeriodStartDate dateByAddingYears:0 months:-1 days:0 hours:0 minutes:0 seconds:0];
    
    [mPeriodStartDate years:NULL months:NULL days:&daysInPeriod hours:NULL minutes:NULL seconds:NULL sinceDate:startDate];
    
    return [NSString stringWithFormat:@"%.0f %%",((daysLeft+(hoursLeft/(float)24))/daysInPeriod)*100];
}



@end
