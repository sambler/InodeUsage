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
    // it looks better/different from a progress bar and gives us the markers
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
    
    [self readInData];
    
    [self refreshWindow];
    if( [oTabView indexOfTabViewItem:[oTabView selectedTabViewItem]] > 0 )
	[oTabView selectFirstTabViewItem:nil];
	
    [oTabView selectNextTabViewItem:nil];
    [oLastUpdate setStringValue:[NSString stringWithFormat:@"Last update %@",[[NSCalendarDate calendarDate]description]]];
    [oShowStatus setStringValue:@"Idle"];
}

-(void)refreshWindow
{
    // account tab
    [oExcessBilledAt setStringValue:@"$0.00 per MB (not implemented)"];  //Do we need this??? - Business acc maybe
    [oDownloadSpeed setStringValue:mAccSpeed];
    [oPeriodStartDate setStringValue:[mPeriodStartDate descriptionWithCalendarFormat:@"%d/%m/%Y"]];
    
    //usage tab
    [oPrepaidMB setStringValue:[self downloadQuota]];
    [oAmountUsed setStringValue:[self quotaUsed]];
    [oUsageRemaining setStringValue:[self quotaRemaining]];
    [oUsageRemainingPC setStringValue:[NSString stringWithFormat:@"%.0f %%",[self quotaRemainingPC]]];
    [oUsageRemainingLevel setFloatValue:[self quotaRemainingPC]];
    [oDaysRemaining setStringValue:[self daysRemaining]];
    [oDaysRemainingPC setStringValue:[NSString stringWithFormat:@"%.0f %%",[self daysRemainingPC]]];
    [oDaysRemainingLevel setFloatValue:[self daysRemainingPC]];
//    oDifference;//Do we need these?? -- how do we calc the diff?
//    oDifferencePC;
//    oDifferenceLevel;
    
    //stats tab
    [oAllowancePerDay setStringValue:[self allowancePerDay]];
    [oAllowancePerDayLevel setFloatValue:50.0];//the allowance level sits in the middle
    [oCurrentAverage setStringValue:[self currentAverage]];
    [oCurrentAverageLevel setFloatValue:[self currentAveragePC]];
    [oAverageRemaining setStringValue:[self averageRemaining]];
    [oAverageRemainingLevel setFloatValue:[self averageRemainingPC]];
    [oTodaysUsage setStringValue:[self todaysUsage]];
    [oTodaysUsageLevel setFloatValue:[self todaysUsagePC]];
    // we adjust todays warning levels to fit with usage remaining
    float avgRemain = [self averageRemainingPC];
    [oTodaysUsageLevel setWarningValue:avgRemain+10];
    [oTodaysUsageLevel setCriticalValue:avgRemain+((100-avgRemain)/2)]; //half way between here and the max scale???
    //---
    [oShowScale setStringValue:[self scaleForLevels]];
    
    //history tab
//    oAverageForPeriod;
//    oTotalForPeriod;
//    oTopScale;
//    oFirstDate;
//    oLastDate;
//    oCurrentDate;
//    oPeriodSelection; //Do we need to talk to this???
    
    //rules tab
//    oAddRule;
//    oRemoveRule;
//    oRulesList;
    
    //prefs tab
//    oUpdateOption;
//    oShowMeter;
    
    //about tab
//    oAboutIcon;
}

-(void)readInData
{
    NSBundle *myBundle;
    NSString *historydata;
    NSStringEncoding tmpenc;
    NSError *tmperror;
    NSString *histPath;
    
    mHistory = [[ASHistory alloc]init];
    
    //======== start testing only
    mAccSpeed = [NSString stringWithFormat:@"24 Mbits/sec"];
    mAccISO = [NSString stringWithFormat:@"10098.845488 40000 20091126 0.00"]; // live sample - ttlDown quota rollover ???(excess cost maybe)
    mPeriodStartDate = [NSCalendarDate dateWithString:[[mAccISO componentsSeparatedByString:@" "]objectAtIndex:2] calendarFormat:@"%Y%m%d"];
    
    myBundle = [NSBundle mainBundle];
    histPath = [myBundle pathForResource:@"padsl-usage" ofType:@"txt"];
    tmperror = [[NSError alloc]init];
    historydata = [NSString stringWithContentsOfFile:histPath usedEncoding:&tmpenc error:&tmperror];
    
    
    [tmperror release];
    //======== end testing
    
    [mHistory addHistory:historydata];
    
}

-(NSString*)downloadQuota
{
    return [self formatAsGB:[self currentQuota]];
}

-(NSString*)quotaUsed
{
    return [self formatAsGB:[self currentQuotaUsed]];
}

-(NSString*)quotaRemaining
{
    return [self formatAsGB:[self currentQuota] - [self currentQuotaUsed]];
}

-(float)quotaRemainingPC
{
    return (1-([self currentQuotaUsed]/[self currentQuota]))*100;
}

-(NSString*)daysRemaining
{
    return [NSString stringWithFormat:@"%.2f Days",[self currentPeriodDaysLeft]];
}

-(float)daysRemainingPC
{
    return ([self currentPeriodDaysLeft]/[self currentPeriodDays])*100;
}

-(NSString*)allowancePerDay
{
    return [self formatAsGB:[self currentQuota]/[self currentPeriodDays]];
}

-(NSString*)currentAverage
{
    return [self formatAsGB:[self currentQuotaUsed]/([self currentPeriodDays]-[self currentPeriodDaysLeft])];
}

-(float)currentAveragePC
{
    return (([self currentQuotaUsed]/([self currentPeriodDays]-[self currentPeriodDaysLeft]))/[self statsMaxScale])*100;
}

-(NSString*)averageRemaining
{
    return [self formatAsGB:([self currentQuota]-[self currentQuotaUsed])/[self currentPeriodDaysLeft]];
}

-(float)averageRemainingPC
{
    return ((([self currentQuota]-[self currentQuotaUsed])/[self currentPeriodDaysLeft])/[self statsMaxScale])*100;
}
-(NSString*)todaysUsage
{
    ASHistoryDay *usageData = [mHistory historyForDay:[NSCalendarDate calendarDate]];
    
    if(usageData == nil)
	return @"?? MB";
    
    return [self formatAsGB:[usageData usage]];
}

-(float)todaysUsagePC
{
    ASHistoryDay *usageData = [mHistory historyForDay:[NSCalendarDate calendarDate]];
    
    if(usageData == nil)
	return 0.0;
    
    return ([usageData usage]/[self statsMaxScale])*100;
}

-(NSString*)scaleForLevels
{
    return [self formatAsGB:[self statsMaxScale]];
}

// common use functions

-(int)currentPeriodDays
{
    int daysInPeriod;
    
    [mPeriodStartDate years:NULL months:NULL days:&daysInPeriod hours:NULL minutes:NULL seconds:NULL sinceDate:[mPeriodStartDate dateByAddingYears:0 months:-1 days:0 hours:0 minutes:0 seconds:0]];
    
    return daysInPeriod;
}

-(float)currentPeriodDaysLeft
{
    int daysLeft, hoursLeft;
    
    [mPeriodStartDate years:NULL months:NULL days:&daysLeft hours:&hoursLeft minutes:NULL seconds:NULL sinceDate:[NSCalendarDate calendarDate]];
    
    return daysLeft+(hoursLeft/(float)24);
}

-(float)currentQuota
{
    return [[[mAccISO componentsSeparatedByString:@" "] objectAtIndex:1]floatValue];
}

-(float)currentQuotaUsed
{
    return [[[mAccISO componentsSeparatedByString:@" "] objectAtIndex:0]floatValue];
}

-(float)statsMaxScale
{
    // the daily allowance level sits in the middle so max scale is (daily allowance * 2)
    return [self currentQuota]/[self currentPeriodDays] * 2;
}

-(NSString*)formatAsGB:(float)inputMB
{
    if( inputMB > MB_GB_Conversion )
	return [NSString stringWithFormat:@"%.2f GB",inputMB/MB_GB_Conversion];
    else
	return [NSString stringWithFormat:@"%.1f MB",inputMB];
}



@end
