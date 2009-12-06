/*
    ASInetUsageController.m
    InodeUsage
    
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
    22/11/2009 - added colour defaults for history graph by Shane Ambler
    
*/

#import <Security/Security.h>
#import "ASInetUsageController.h"
#import "ASHistoryDay.h"
#import "ASIUUtilities.h"


// setting this to true causes the history to be generated instead of from the internode server
#define DEBUG_GENERATED_HISTORY true

// userdefaults string definitions

NSString *ASIUSaveLoginDetails = @"Save Login Details";
NSString *ASIUAutoUpdate = @"Auto Update Frequency";
NSString *ASIUAutoShowUsageMeter = @"Show Usage Meter At Startup";
NSString *ASIUDefaultLoginID = @"Default LoginID";
NSString *ASIUHistoryBorderColour = @"History Border Colour";
NSString *ASIUHistoryFillColour = @"History Filll Colour";
NSString *ASIUHistoryShowLimit = @"History Show Limit";

// keychain service name - only used here
const NSString *ASIUServiceName = @"InodeUsage";

// Internodes url to retrieve the data
const NSString *ASIUPostingURL = @"https://customer-webtools-api.internode.on.net/cgi-bin/padsl-usage";


@implementation ASInetUsageController

+(void)initialize
{
    NSMutableDictionary *factorySettings = [NSMutableDictionary dictionary];
    NSData *tmpData;
    
    [factorySettings setObject:[NSNumber numberWithBool:true] forKey:ASIUSaveLoginDetails];
    //save frequency of update in hours - 0 = no auto update
    [factorySettings setObject:[NSNumber numberWithInt:0] forKey:ASIUAutoUpdate];
    [factorySettings setObject:[NSNumber numberWithBool:false] forKey:ASIUAutoShowUsageMeter];
    
    tmpData = [NSArchiver archivedDataWithRootObject:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:1.0]];
    [factorySettings setObject:tmpData forKey:ASIUHistoryBorderColour];
    
    tmpData = [NSArchiver archivedDataWithRootObject:[NSColor colorWithDeviceRed:0.4 green:0.4 blue:1.0 alpha:1.0]];
    [factorySettings setObject:tmpData forKey:ASIUHistoryFillColour];
    
    // 48 = max of 4 years history to display - only affects all periods history display
    [factorySettings setObject:[NSNumber numberWithInt:48] forKey:ASIUHistoryShowLimit];
    
    [[NSUserDefaults standardUserDefaults]registerDefaults:factorySettings];
}

- (void) dealloc
{
    [mAccSpeed release];
    [mAccISO release];
    [mPeriodStartDate release];
    [mHistory release];
    
    [super dealloc];
}

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
    
    [oSaveLogin setState:[[NSUserDefaults standardUserDefaults]boolForKey:ASIUSaveLoginDetails]];
    if( [oSaveLogin state] && ([[[NSUserDefaults standardUserDefaults]stringForKey:ASIUDefaultLoginID]length] > 0) )
    {
	[oLoginID setStringValue:[[NSUserDefaults standardUserDefaults]stringForKey:ASIUDefaultLoginID]];
	[self fillLoginDetails];
    } 
    [oShowMeter setState:[[NSUserDefaults standardUserDefaults]boolForKey:ASIUAutoShowUsageMeter]];
    [oUpdateOption selectItemWithTag:[[NSUserDefaults standardUserDefaults]integerForKey:ASIUAutoUpdate]];
    if( [oUpdateOption selectedTag] >0 )
    {
        [self setupTimer:false];
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:false];
        // we queue up the timer then add a single shot timer to update after the window is shown
    }
    
    [oBorderColour setColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults]objectForKey:ASIUHistoryBorderColour]]];
    [oFillColour setColor:[NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults]objectForKey:ASIUHistoryFillColour]]];
    [oHistoryGraph updateColours];
    [oHistoryGraph setInfoField:oCurrentDate];
    // IB doesn't allow us to set show in background for utility windows
    [oMeterWindow setHidesOnDeactivate:false];
    
}

-(void)setupTimer:(bool)inUpdateNow
{
    if( [oUpdateOption selectedTag] == 0 )
        return;
    
    if( mUpdateTimer )
        [mUpdateTimer invalidate];
    
    mUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:(60*60*[oUpdateOption selectedTag]) target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:true];
    
    if( inUpdateNow )
        [self update:nil];
}

-(void)timerFireMethod:(NSTimer*)inTimer
{
    [self update:nil];
}

- (IBAction)changeHistory:(id)sender
{
    ASHistoryPeriod* theData;
    
    if ([sender tag] == 10) //current period
    {
	theData = [[mHistory historyForPeriod:[mPeriodStartDate descriptionWithCalendarFormat:@"%Y%m"]]copyAsFullPeriod];
    }
    else if ([sender tag] == 20)//period totals
    {
	theData = [self buildFullHistoryArray];
    }
    else // sender tag determines the period
    {
	theData = [[mHistory historyForPeriod:[NSString stringWithFormat:@"%i",[sender tag]]]copyAsFullPeriod];
    }
    
    [oAverageForPeriod setStringValue:formatAsGB([theData averageUsage])];
    [oTotalForPeriod setStringValue:formatAsGB([theData totalUsage])];
    [oTopScale setStringValue:formatAsGB([theData highestDailyUsage])];
    [oFirstDate setStringValue:[[theData startDate]descriptionWithCalendarFormat:@"%d/%m/%Y"]];
    [oLastDate setStringValue:[[theData endDate]descriptionWithCalendarFormat:@"%d/%m/%Y"]];
    [oCurrentDate setStringValue:@""];
    
    [oHistoryGraph setPeriodData:theData];
    [oHistoryGraph setNeedsDisplay:true];
}

- (IBAction)viewList:(id)sender
{    
}

- (IBAction)changeStartup:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setBool:[sender state] forKey:ASIUAutoShowUsageMeter];
}

- (IBAction)changeUpdate:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setInteger:[sender selectedTag] forKey:ASIUAutoUpdate];
    
    if( [sender selectedTag] == 0 )
    {
        [mUpdateTimer invalidate];
        mUpdateTimer = nil;
    }
    else
        [self setupTimer:true];
}

- (IBAction)ruleAdd:(id)sender
{
}

- (IBAction)ruleRemove:(id)sender
{
}

- (IBAction)changeLogin:(id)sender
{
    [self saveLoginDetails];
}

- (IBAction)changeSave:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setBool:[sender state] forKey:ASIUSaveLoginDetails];
    if ([sender state]) [self changeLogin:nil];
}

- (IBAction)changeBorderColour:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setObject:[NSArchiver archivedDataWithRootObject:[sender color]] forKey:ASIUHistoryBorderColour];
    [oHistoryGraph updateColours];
}

- (IBAction)changeFillColour:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setObject:[NSArchiver archivedDataWithRootObject:[sender color]] forKey:ASIUHistoryFillColour];
    [oHistoryGraph updateColours];
}

- (IBAction)showMain:(id)sender
{
    [oMainWindow setIsVisible:true];
}

- (IBAction)showMeter:(id)sender
{
    [oMeterWindow setIsVisible:true];
    [self refreshWindow];
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
    
    if( (sender != oUpdateButton) && [oShowMeter state] )
    {
	// if the meter window is show on start then once updated show the meter and hide the main
	[self showMeter:nil];
	[oMainWindow setIsVisible:false];
    }
}

-(void)refreshWindow
{
    // account tab
    [oExcessBilledAt setStringValue:@"$0.00 per MB (not implemented)"];  //Do we need this??? - Business acc maybe
    [oDownloadSpeed setStringValue:mAccSpeed];
    [oPeriodStartDate setStringValue:[[mPeriodStartDate dateByAddingYears:0 months:1 days:0 hours:0 minutes:0 seconds:0] descriptionWithCalendarFormat:@"%d/%m/%Y"]];
    
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
    
    // usage meter window
    [oMeterUsageRemainingLevel setFloatValue:[self quotaRemainingPC]];
    [oMeterUsageRemainingText setStringValue:[self quotaRemaining]];
    [oMeterDaysRemainingLevel setFloatValue:[self daysRemainingPC]];
    [oMeterDaysRemainingText setStringValue:[self daysRemaining]];
    
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
    avgRemain = avgRemain>90 ? 99 : avgRemain+10;
    [oTodaysUsageLevel setWarningValue:avgRemain];
    [oTodaysUsageLevel setCriticalValue:avgRemain+((100-avgRemain)/2)]; //half way between warn and the max???
    //---
    [oShowScale setStringValue:[self scaleForLevels]];
    
    //history tab
    // no need to update here - changing the history menu triggers an update
//    oAverageForPeriod;
//    oTotalForPeriod;
//    oTopScale;
//    oFirstDate;
//    oLastDate;
//    oCurrentDate;
//    oHistoryMenu;
//    oViewAsTable;
    [oHistoryGraph setNeedsDisplay:true];
    
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
    NSString *historydata;
    
#if DEBUG_GENERATED_HISTORY
    
    // for testing without bothering internodes server every time through
    // we can generate the history data and some pre-defined info to go with it
    NSCalendarDate *tmpDate;
    int x;
    float tmpUsage;
    
    mAccSpeed = [NSString stringWithFormat:@"24 Mbits/sec"];
    
    // the 'ISO' info - ttlDown quota rollover ???(excess cost maybe)
    // the download used (first figure) can throw out the average use when at the beginning of a period
    // adjust this rollover date for testing
    mAccISO = [NSString stringWithFormat:@"25000 80000 %@ 0.00",[[[NSCalendarDate calendarDate]dateByAddingYears:0 months:1 days:0 hours:0 minutes:0 seconds:0] descriptionWithCalendarFormat:@"%Y%m%d"]];
    
    // generate 825 days of history
    // days usage is 100MB * dayofmonth
    // months usage totals are as follows -
    // 28 day month - 40.6 GB
    // 29 day month - 43.5 GB
    // 30 day month - 46.5 GB
    // 31 day month - 49.6 GB
    
    historydata = [NSString stringWithFormat:@""]; // start with an empty string to prevent the {null} entry at the start
    for(x=0;x<825;x++)
    {
	tmpDate = [NSCalendarDate calendarDate];
	tmpDate = [tmpDate dateByAddingYears:0 months:0 days:x-824 hours:0 minutes:0 seconds:0];
	tmpUsage = 100.0*[tmpDate dayOfMonth];
	historydata = [NSString stringWithFormat:@"%@%@ %f\n",historydata,[tmpDate descriptionWithCalendarFormat:@"%y%m%d"],tmpUsage];
    }
#else
    // the real history retrieval code -----
    NSPipe *fromPipe;
    NSFileHandle *fromHandle;
    NSTask *curlTask;
    NSString *postFormData;
    
    // get speed
    curlTask = [[[NSTask alloc]init]autorelease];
    fromPipe = [NSPipe pipe];
    fromHandle = [fromPipe fileHandleForReading];
    [curlTask setLaunchPath:@"/usr/bin/curl"];
    postFormData = [NSString stringWithFormat:@"username=%@&password=%@&speed=1",[oLoginID stringValue],[oLoginPasswd stringValue]];
    [curlTask setArguments:[NSArray arrayWithObjects:@"--silent",@"-d",postFormData,ASIUPostingURL,nil]];
    [curlTask setStandardOutput:fromPipe];
    [curlTask launch];
    mAccSpeed = [[NSString alloc]initWithData:[fromHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    
    // get the 'ISO' info - ttlDown quota rollover ???(excess cost maybe)
    curlTask = [[[NSTask alloc]init]autorelease];
    fromPipe = [NSPipe pipe];
    fromHandle = [fromPipe fileHandleForReading];
    [curlTask setLaunchPath:@"/usr/bin/curl"];
    postFormData = [NSString stringWithFormat:@"username=%@&password=%@&iso=1",[oLoginID stringValue],[oLoginPasswd stringValue]];
    [curlTask setArguments:[NSArray arrayWithObjects:@"--silent",@"-d",postFormData,ASIUPostingURL,nil]];
    [curlTask setStandardOutput:fromPipe];
    [curlTask launch];
    mAccISO = [[NSString alloc]initWithData:[fromHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    
    // get history
    curlTask = [[[NSTask alloc]init]autorelease];
    fromPipe = [NSPipe pipe];
    fromHandle = [fromPipe fileHandleForReading];
    [curlTask setLaunchPath:@"/usr/bin/curl"];
    postFormData = [NSString stringWithFormat:@"username=%@&password=%@&history=1",[oLoginID stringValue],[oLoginPasswd stringValue]];
    [curlTask setArguments:[NSArray arrayWithObjects:@"--silent",@"-d",postFormData,ASIUPostingURL,nil]];
    [curlTask setStandardOutput:fromPipe];
    [curlTask launch];
    historydata = [[[NSString alloc]initWithData:[fromHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding]autorelease];
#endif
    
    mPeriodStartDate = [[[NSCalendarDate dateWithString:[NSString stringWithFormat:@"%@ 00:00:00",[[mAccISO componentsSeparatedByString:@" "]objectAtIndex:2]] calendarFormat:@"%Y%m%d %H:%M:%S"] dateByAddingYears:0 months:-1 days:0 hours:0 minutes:0 seconds:0]retain]; //we get the end date so convert to start
    
    if( mHistory != nil ) [mHistory release];
    mHistory = [[ASHistory alloc]init];
    [mHistory addHistory:historydata periodStartDay:mPeriodStartDate];
    [self buildHistoryMenu];
    [oHistoryMenu selectItemAtIndex:0];
    [self changeHistory:[oHistoryMenu itemAtIndex:0]];
}

// delegate to enable mouse moved event in history graph
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if ( [tabView indexOfTabViewItem:tabViewItem] == 3 )
    {
	[oMainWindow setAcceptsMouseMovedEvents:true];
	[oMainWindow makeFirstResponder:oHistoryGraph];
    }else
    {
	[oMainWindow setAcceptsMouseMovedEvents:false];
	[oMainWindow setAcceptsMouseMovedEvents:false];
    }

}

-(NSString*)downloadQuota
{
    return formatAsGB([self currentQuota]);
}

-(NSString*)quotaUsed
{
    return formatAsGB([self currentQuotaUsed]);
}

-(NSString*)quotaRemaining
{
    return formatAsGB([self currentQuota] - [self currentQuotaUsed]);
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
    return formatAsGB([self currentQuota]/[self currentPeriodDays]);
}

-(NSString*)currentAverage
{
    return formatAsGB([self currentQuotaUsed]/([self currentPeriodDays]-[self currentPeriodDaysLeft]));
}

-(float)currentAveragePC
{
    return (([self currentQuotaUsed]/([self currentPeriodDays]-[self currentPeriodDaysLeft]))/[self statsMaxScale])*100;
}

-(NSString*)averageRemaining
{
    return formatAsGB(([self currentQuota]-[self currentQuotaUsed])/[self currentPeriodDaysLeft]);
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
    
    return formatAsGB([usageData usage]);
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
    return formatAsGB([self statsMaxScale]);
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
    
    [[mPeriodStartDate dateByAddingYears:0 months:1 days:0 hours:0 minutes:0 seconds:0]years:NULL months:NULL days:&daysLeft hours:&hoursLeft minutes:NULL seconds:NULL sinceDate:[NSCalendarDate calendarDate]];
    
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

//build history menu
-(void)buildHistoryMenu
{
    NSString *itemOne = @"Current Period...";
    NSString *itemTwo = @"Period Totals";
    
    NSMenu *theMenu = [oHistoryMenu menu];
    NSMenuItem *theItem;
    
    NSArray *periodList;
    NSEnumerator *listEnumerator;
    NSString *curKey;
    
    //we could be re-updating - start from scratch
    [oHistoryMenu removeAllItems];
    
    [theMenu setAutoenablesItems:false];
    
    theItem = [[NSMenuItem alloc]initWithTitle:itemOne action:@selector(changeHistory:) keyEquivalent:@""];
    [theItem setTag:10];
    [theItem setEnabled:true];
    [theItem setTarget:self];
    [theMenu addItem:theItem];
    [theItem release];
    
    theItem = [[NSMenuItem alloc]initWithTitle:itemTwo action:@selector(changeHistory:) keyEquivalent:@""];
    [theItem setTag:20];
    [theItem setEnabled:true];
    [theItem setTarget:self];
    [theMenu addItem:theItem];
    [theItem release];
    
    theItem = [NSMenuItem separatorItem];
    [theMenu addItem:theItem];
    
    periodList = [mHistory periodKeyArray];
    listEnumerator = [periodList reverseObjectEnumerator];
    while( (curKey = [listEnumerator nextObject]) )
    {
	NSString *curTitle;
	NSCalendarDate *curDate;
	
	curDate = [NSCalendarDate dateWithString:[NSString stringWithFormat:@"%@%i",curKey,[mPeriodStartDate dayOfMonth]] calendarFormat:@"%Y%m%d"];
	
	curTitle = [NSString stringWithFormat:@"%@...%@",[curDate descriptionWithCalendarFormat:@"%d/%m/%y"],[[curDate dateByAddingYears:0 months:1 days:-1 hours:0 minutes:0 seconds:0]descriptionWithCalendarFormat:@"%d/%m/%y"]];
	
	theItem = [[NSMenuItem alloc]initWithTitle:curTitle action:@selector(changeHistory:) keyEquivalent:@""];
	[theItem setTag:[curKey intValue]];
	[theItem setEnabled:true];
	[theItem setTarget:self];
	[theMenu addItem:theItem];
	[theItem release];
    }
}

-(ASHistoryPeriod*)buildFullHistoryArray
{
    //we are building an array of history days
    //we want to imitate a normal period history but have total period traffic for each entry
    //instead of day traffic. The date used will be the first day of the period being recorded.
    
    NSArray *periodList;
    NSEnumerator *listEnumerator;
    ASHistoryPeriod *curItem;
    NSCalendarDate *startDate;
    ASHistoryPeriod *tmpHistory;
    ASHistoryDay *tmpDay;
    NSCalendarDate *tmpEndDate;
    
    periodList = [mHistory periodDataArray];
    
    if( [[NSUserDefaults standardUserDefaults]integerForKey:ASIUHistoryShowLimit] > [periodList count] )
    {
	startDate = [mPeriodStartDate dateByAddingYears:0 months:-([periodList count]-1) days:0 hours:0 minutes:0 seconds:0];
    }else {
	startDate = [mPeriodStartDate dateByAddingYears:0 months:-([[NSUserDefaults standardUserDefaults]integerForKey:ASIUHistoryShowLimit]-1) days:0 hours:0 minutes:0 seconds:0];
    }
    tmpHistory = [[[ASHistoryPeriod alloc]initFor:[startDate descriptionWithCalendarFormat:@"%Y%m"] starting:startDate]autorelease];
    
    listEnumerator = [periodList objectEnumerator];
    while( (curItem = [listEnumerator nextObject]) )
    {
	tmpDay = [ASHistoryDay historyWith:[curItem startDate] :[curItem totalUsage]];
	[tmpHistory add:tmpDay];
	tmpEndDate = [curItem startDate];
    }
    [tmpHistory setEndDate:tmpEndDate];
    return tmpHistory;
}

//saving login details
-(void)fillLoginDetails
{
    //UInt32 usernameLength;
    //char *username;
    UInt32 passwdLength;
    void *passwd;
    
    if ( [[oLoginID stringValue]length] == 0 ) return; // no username = don't search
    
    // we don't seem to have a way to retrieve the username and password from the keychain ???
    // get/store the username from userdefaults - password from keychain
    
    SecKeychainFindGenericPassword(NULL,[ASIUServiceName length],[ASIUServiceName cString],[[oLoginID stringValue] length],[[oLoginID stringValue] cString],&passwdLength,&passwd,NULL);
    
    [oLoginPasswd setStringValue:[NSString stringWithCString:passwd length:passwdLength]];
    
    SecKeychainItemFreeContent(NULL,passwd);
}

-(void)saveLoginDetails
{
    OSStatus status;
    
    // is there anything to save??
    if( [[oLoginID stringValue]length] == 0 ) return;
    if( [[oLoginID stringValue]caseInsensitiveCompare:@"username"] == NSOrderedSame ) return; // default content - treat as empty
    if( [[oLoginPasswd stringValue]length] == 0 ) return;
    
    [[NSUserDefaults standardUserDefaults]setObject:[oLoginID stringValue] forKey:ASIUDefaultLoginID];
    
    status = SecKeychainAddGenericPassword(NULL,[ASIUServiceName length],[ASIUServiceName cString],[[oLoginID stringValue]length],[[oLoginID stringValue]cString],[[oLoginPasswd stringValue]length],[[oLoginPasswd stringValue]cString],NULL);
    
    if(status == errSecDuplicateItem)
    {
	UInt32 passwdLength;
	void *passwd;
	SecKeychainItemRef itemRef = nil;
	
	SecKeychainFindGenericPassword(NULL,[ASIUServiceName length],[ASIUServiceName cString],[[oLoginID stringValue] length],[[oLoginID stringValue] cString],&passwdLength,&passwd,&itemRef);
	
	SecKeychainItemFreeContent(NULL,passwd);
	
	SecKeychainItemModifyAttributesAndData(itemRef,NULL,[[oLoginPasswd stringValue]length],[[oLoginPasswd stringValue]cString]);
    }
}



@end


