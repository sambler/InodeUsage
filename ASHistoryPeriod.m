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

-(ASHistoryPeriod*)initFor:(NSString*)period starting:(NSCalendarDate*)startDay
{
    if( (self = [super init]) )
    {
	mPeriodKey = [period retain];
	mPeriodHistory = [[NSMutableArray alloc]init];
	mStartDay = [[NSCalendarDate dateWithString:[NSString stringWithFormat:@"%@%@",period,[startDay descriptionWithCalendarFormat:@"%d"]] calendarFormat:@"%Y%m%d"]retain];
	mPeriodTotalUsage = 0.0;
	mPeriodAverageUsage = 0.0;
	mHighestDailyUsage = 0.0;
    }
    return self;
}

-(void)add:(ASHistoryDay*)day
{
    [mPeriodHistory addObject:day];
    mPeriodTotalUsage += [day usage];
    mPeriodAverageUsage = mPeriodTotalUsage/[mPeriodHistory count];
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
    int periodTerm;
    
    [[mStartDay dateByAddingYears:0 months:1 days:0 hours:0 minutes:0 seconds:0]years:nil months:nil days:&periodTerm hours:nil minutes:nil seconds:nil sinceDate:mStartDay];
    
    return periodTerm;
}

-(int)entriesCount
{
    return [mPeriodHistory count];
}

-(NSCalendarDate*)startDate
{
    return mStartDay;
}

-(void)setEndDate:(NSCalendarDate*)ending
{
    mEndDay = [ending retain];
}

-(NSCalendarDate*)endDate
{
    if(mEndDay == nil)
	return [mStartDay dateByAddingYears:0 months:1 days:-1 hours:0 minutes:0 seconds:0];
    
    return mEndDay;
}

-(NSMutableArray*)data
{
    return mPeriodHistory;
}

-(NSArray*)periodDataSorted
{
    return [mPeriodHistory sortedArrayUsingFunction:historyDateSorting context:nil];
}

-(ASHistoryPeriod*)copyAsFullPeriod
{
    //for the history graph we need a full listing - add zero usage for any missing days
    ASHistoryPeriod *tmpPeriod = [[[ASHistoryPeriod alloc]init]autorelease];
    NSCalendarDate *tmpDate;
    ASHistoryDay *newDay;
    unsigned int x, daysToLoop = [self daysInPeriod];
    int daysDiff;
    
    //so we start with a sorted array and the copy the other data
    tmpPeriod->mPeriodHistory = [[NSMutableArray arrayWithArray:[self periodDataSorted]]retain];
    tmpPeriod->mPeriodKey = [[mPeriodKey copy]retain];
    tmpPeriod->mStartDay = [[mStartDay copy]retain];
    tmpPeriod->mPeriodTotalUsage = mPeriodTotalUsage;
    tmpPeriod->mPeriodAverageUsage = mPeriodAverageUsage;
    tmpPeriod->mHighestDailyUsage = mHighestDailyUsage;
    
    for (x = 0; x < daysToLoop; x++)
    {
	tmpDate = [mStartDay dateByAddingYears:0 months:0 days:x hours:0 minutes:0 seconds:0]; //the date we expect at this array index
	if( x < [tmpPeriod->mPeriodHistory count] )
	    [[[tmpPeriod->mPeriodHistory objectAtIndex:x]storedDay] years:nil months:nil days:&daysDiff hours:nil minutes:nil seconds:nil sinceDate:tmpDate];
	else
	    daysDiff = 1;//make the following add a day
	
	if(daysDiff != 0)
	{
	    newDay = [ASHistoryDay historyWith:tmpDate :0.0];
	    [tmpPeriod->mPeriodHistory insertObject:newDay atIndex:x];
	}
    }
    
    return tmpPeriod;
}

-(ASHistoryDay*)historyForDay:(NSCalendarDate*)day
{
    ASHistoryDay *theDayData;
    int daysDifference;
    unsigned int x;
    
    for (x = 0; x < [mPeriodHistory count]; x++)
    {
	theDayData = [mPeriodHistory objectAtIndex:x];
	[[theDayData storedDay] years:nil months:nil days:&daysDifference hours:nil minutes:nil seconds:nil sinceDate:day];
	if( daysDifference == 0 )
	    return theDayData;
    }
    
    return nil;
}





@end


int historyPeriodValueSorting(ASHistoryPeriod* first, ASHistoryPeriod* second, void *context)
{
    return [[first key]caseInsensitiveCompare:[second key]];
}


