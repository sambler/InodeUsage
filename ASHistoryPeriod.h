/*
    ASHistoryPeriod.h
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
    30/10/2009 - Created by Shane Ambler
    
*/

#import "ASHistoryDay.h"

@interface ASHistoryPeriod : NSObject {
    NSString *mPeriodKey;
    NSMutableArray *mPeriodHistory;
    NSCalendarDate *mStartDay;
    NSCalendarDate *mEndDay;
    float mPeriodTotalUsage;
    float mPeriodAverageUsage;
    float mHighestDailyUsage;
    
}

-(ASHistoryPeriod*)initFor:(NSString*)period starting:(NSCalendarDate*)startDay;

-(void)add:(ASHistoryDay*)day;

-(NSString*)key;
-(float)totalUsage;
-(float)highestDailyUsage;
-(float)averageUsage;
-(int)daysInPeriod;
-(int)entriesCount;
-(NSCalendarDate*)startDate;
-(NSCalendarDate*)endDate;
-(void)setEndDate:(NSCalendarDate*)ending;
-(NSMutableArray*)data;
-(NSArray*)periodDataSorted;
-(ASHistoryPeriod*)copyAsFullPeriod;

-(ASHistoryDay*)historyForDay:(NSCalendarDate*)day;



@end

int historyPeriodValueSorting(ASHistoryPeriod* first, ASHistoryPeriod* second, void *context);

