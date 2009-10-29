/*
    ASHistoryDay.m
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


@implementation ASHistoryDay

+(ASHistoryDay*)historyWith:(NSDate*)day :(float)usage
{
    ASHistoryDay *newDay = [[self alloc] init];
    newDay->mDay = [day retain];
    newDay->mUsage = usage;
    return newDay;
}

+(ASHistoryDay*)historyFrom:(NSString*)dayStr :(NSString*)usageStr
{
    // dayStr is a six digit representation of the date (yymmdd)
    // break up each piece to get the values for the date -- yy<90 = 2000+
    
    return [ASHistoryDay historyWith:[NSDate initWithString:dayStr] :[usageStr floatValue]];
}

-(NSDate*)day
{
    return mDay;
}

-(float)usage
{
    return mUsage;
}

-(void) dealloc
{
    [mDay release];
    [super dealloc];
}

@end
