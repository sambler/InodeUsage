/*
    ASHistory.m
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

#import "ASHistory.h"
#import "ASHistoryPeriod.h"
#import "ASHistoryDay.h"

@implementation ASHistory

-(ASHistory*)init
{
    if ( (self = [super init]) )
    {
	mHistoryPeriods = [[NSMutableDictionary alloc]init];
	mKnownDaysCount = 0;
	mKnownPeriodsCount = 0;
    }
    return self;
}

-(int)knownPeriodsCount
{
    return mKnownPeriodsCount;
}

-(int)knownDaysCount
{
    return mKnownDaysCount;
}

-(void)addDay:(NSString*)day
{
    ASHistoryDay *dayHistory;
    ASHistoryPeriod *pHist;
    
    dayHistory = [ASHistoryDay historyFrom:[day substringWithRange:NSMakeRange(0,6)] :[day substringWithRange:NSMakeRange(7,[day length]-7)]];
    
    if( (pHist = [mHistoryPeriods objectForKey:[dayHistory periodKey:kPeriodStart]]) )
    {
	[pHist add:dayHistory];
    }else{
	pHist = [[ASHistoryPeriod alloc]initFor:[dayHistory periodKey:kPeriodStart]];
	[pHist add:dayHistory];
	[mHistoryPeriods setObject:pHist forKey:[pHist key]];
    }
    
    //[dayHistory release];
    //[pHist release];
}

-(void)addHistory:(NSString*)history
{
    unsigned int lineStart = 0;
    unsigned int lineEnd = 0;
    unsigned int contEnd = 0;
    int lineTarget = 0;
    NSString *theLine;
    
    lineTarget = [history length] - 5;
    
    while(lineTarget>1)
    {
	[history getLineStart:&lineStart end:&lineEnd contentsEnd:&contEnd forRange:NSMakeRange(lineTarget,2)];
	theLine = [history substringWithRange:NSMakeRange(lineStart,lineEnd-lineStart)];
	[self addDay:theLine];
	//[theLine release];
	lineTarget = lineStart - 5;
    }
}


@end
