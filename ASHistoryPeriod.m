/*
    ASHistoryPeriod.m
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

#import "ASHistoryPeriod.h"


@implementation ASHistoryPeriod

-(ASHistoryPeriod*)initFor:(NSString*)period
{
    if( (self = [super init]) )
    {
	mPeriodKey = [period retain];
	mDaysInPeriod = [[NSMutableArray alloc]init];
	mPeriodTotalUsage = 0.0;
	mPeriodAverageUsage = 0.0;
	mHighestDailyUsage = 0.0;
    }
    return self;
}

-(void)add:(ASHistoryDay*)day
{
    [mDaysInPeriod addObject:day];
    mPeriodTotalUsage += [day usage];
    mPeriodAverageUsage = mPeriodTotalUsage/[mDaysInPeriod count];
    if([day usage]>mHighestDailyUsage)
	mHighestDailyUsage = [day usage];
}

-(NSString*)key
{
    return mPeriodKey;
}

-(float)totalUsage
{
    return mPeriodTotalUsage;
}

-(float)highestDailyUsage
{
    return mHighestDailyUsage;
}

-(float)averageUsage
{
    return mPeriodAverageUsage;
}

-(int)daysInPeriod
{
    // should we calc this from start date or just rely on history entries??
    return [mDaysInPeriod count];
}

-(ASHistoryDay*)historyForDay:(NSCalendarDate*)day
{
    ASHistoryDay *theDayData;
    int daysDifference;
    unsigned int x;
    
    for (x=0; x<[mDaysInPeriod count]; x++)
    {
	theDayData = [mDaysInPeriod objectAtIndex:x];
	[[theDayData day] years:nil months:nil days:&daysDifference hours:nil minutes:nil seconds:nil sinceDate:day];
	if( daysDifference == 0 )
	    return theDayData;
    }
    
    return nil;
}



@end
