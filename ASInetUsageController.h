/*
    ASInetUsageController.h
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
    
*/

#import "ASHistory.h"
#import "ASHistoryView.h"

@interface ASInetUsageController : NSObject
{
    // always visible
    IBOutlet NSTextField *oLastUpdate;
    IBOutlet NSTextField *oShowStatus;
    IBOutlet NSTextField *oShowVersion;
    IBOutlet NSTabView *oTabView;
    
    //Account Panel
    IBOutlet NSTextField *oLoginID;
    IBOutlet NSTextField *oLoginPasswd;
    IBOutlet NSButton *oSaveLogin;
    IBOutlet NSButton *oUpdateButton;
    IBOutlet NSTextField *oExcessBilledAt; //Do we need this??? - Business acc maybe
    IBOutlet NSTextField *oDownloadSpeed;
    IBOutlet NSTextField *oPeriodStartDate;
    
    //Usage Panel
    IBOutlet NSTextField *oPrepaidMB;
    IBOutlet NSTextField *oAmountUsed;
    IBOutlet NSTextField *oUsageRemaining;
    IBOutlet NSTextField *oUsageRemainingPC;
    IBOutlet NSLevelIndicator *oUsageRemainingLevel;
    IBOutlet NSTextField *oDaysRemaining;
    IBOutlet NSTextField *oDaysRemainingPC;
    IBOutlet NSLevelIndicator *oDaysRemainingLevel;
    IBOutlet NSTextField *oDifference;//Do we need these?? -- how do we calc the diff?
    IBOutlet NSTextField *oDifferencePC;
    IBOutlet NSLevelIndicator *oDifferenceLevel;
    
    //Stats Panel
    IBOutlet NSTextField *oAllowancePerDay;
    IBOutlet NSLevelIndicator *oAllowancePerDayLevel;
    IBOutlet NSTextField *oCurrentAverage;
    IBOutlet NSLevelIndicator *oCurrentAverageLevel;
    IBOutlet NSTextField *oAverageRemaining;
    IBOutlet NSLevelIndicator *oAverageRemainingLevel;
    IBOutlet NSTextField *oTodaysUsage;
    IBOutlet NSLevelIndicator *oTodaysUsageLevel;
    IBOutlet NSTextField *oShowScale;
    
    //History Panel
    IBOutlet NSTextField *oAverageForPeriod;
    IBOutlet NSTextField *oTotalForPeriod;
    IBOutlet NSTextField *oTopScale;
    IBOutlet NSTextField *oFirstDate;
    IBOutlet NSTextField *oLastDate;
    IBOutlet NSTextField *oCurrentDate;
    IBOutlet NSPopUpButton *oHistoryMenu;
    IBOutlet NSButton *oViewAsTable;
    IBOutlet ASHistoryView *oHistoryGraph;
    
    //Rules Panel
    IBOutlet NSButton *oAddRule;
    IBOutlet NSButton *oRemoveRule;
    IBOutlet NSTableView *oRulesList;
    
    //Prefs Panel
    IBOutlet NSPopUpButton *oUpdateOption;
    IBOutlet NSButton *oShowMeter;
    IBOutlet NSColorWell *oBorderColour;
    IBOutlet NSColorWell *oFillColour;
    
    //About Panel
    IBOutlet NSImageView *oAboutIcon;
    
    
    NSString *mAccSpeed;
    NSString *mAccISO;
    NSCalendarDate *mPeriodStartDate;
    ASHistory *mHistory;
    
}
- (IBAction)changeHistory:(id)sender;
- (IBAction)viewList:(id)sender;
- (IBAction)changeStartup:(id)sender;
- (IBAction)changeUpdate:(id)sender;
- (IBAction)changeBorderColour:(id)sender;
- (IBAction)changeFillColour:(id)sender;
- (IBAction)ruleAdd:(id)sender;
- (IBAction)ruleRemove:(id)sender;
- (IBAction)changeLogin:(id)sender;
- (IBAction)changeSave:(id)sender;
- (IBAction)update:(id)sender;
- (IBAction)showMain:(id)sender;
- (IBAction)showMeter:(id)sender;

-(void)refreshWindow;
-(void)readInData;


//calculate figures for main window
-(NSString*)downloadQuota;
-(NSString*)quotaUsed;
-(NSString*)quotaRemaining;
-(float)quotaRemainingPC;
-(NSString*)daysRemaining;
-(float)daysRemainingPC;
-(NSString*)allowancePerDay;
-(NSString*)currentAverage;
-(float)currentAveragePC;
-(NSString*)averageRemaining;
-(float)averageRemainingPC;
-(NSString*)todaysUsage;
-(float)todaysUsagePC;
-(NSString*)scaleForLevels;

// common use functions
-(int)currentPeriodDays;
-(float)currentPeriodDaysLeft;
-(float)currentQuota;
-(float)currentQuotaUsed;
-(float)statsMaxScale;
-(NSString*)formatAsGB:(float)inputMB;

-(void)buildHistoryMenu;
-(ASHistoryPeriod*)buildFullHistoryArray;

-(void)fillLoginDetails;
-(void)saveLoginDetails;



@end
