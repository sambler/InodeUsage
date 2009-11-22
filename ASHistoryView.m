/*
    ASHistoryView.m
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
    03/11/2009 - Created by Shane Ambler
    22/11/2009 - added cour drawing to the history graph by Shane Ambler
    
*/

#import "ASHistoryView.h"
#import "ASInternetUsageUserDefaults.h"


@implementation ASHistoryView

- (id)initWithFrame:(NSRect)frame
{
    if ( (self = [super initWithFrame:frame]) ) {
        mCurrentPeriod = nil;
	mDaysInPeriod = 0;
	mDaysToShow = 0;
	mSpacePerDay = 0;
	mFillColour = nil;
	mBorderColour = nil;
	
    }
    return self;
}

-(void)setPeriodData:(ASHistoryPeriod*)periodData
{
    mCurrentPeriod = [periodData retain];
    
    mDaysToShow = [[NSUserDefaults standardUserDefaults]integerForKey:ASIUHistoryShowLimit];
    
    if ( mDaysToShow > [mCurrentPeriod entriesCount] )
	mDaysToShow = [mCurrentPeriod entriesCount];
    
    mSpacePerDay = [self frame].size.width/mDaysToShow;
    
    [self setNeedsDisplay:true];
}

-(void)updateColours
{
    [mBorderColour release];
    mBorderColour = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults]objectForKey:ASIUHistoryBorderColour]];
    [mBorderColour retain];
    [mFillColour release];
    mFillColour = [NSUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults]objectForKey:ASIUHistoryFillColour]];
    [mFillColour retain];
}

- (void)drawRect:(NSRect)rect
{
    NSRect usageRect;
    int x, idxStart, idxEnd;
    
    [[NSColor whiteColor]set];
    [NSBezierPath fillRect:rect];
    
    if( mCurrentPeriod == nil ) return;
    
    [NSBezierPath setDefaultLineWidth:2.0];
    [mFillColour setFill];
    [mBorderColour setStroke];
    
    idxEnd = [mCurrentPeriod entriesCount];
    idxStart = idxEnd - mDaysToShow;
    
    for(x=idxStart;x<idxEnd;x++)
    {
	usageRect.origin.x = (mSpacePerDay * (x-idxStart))+1;
	usageRect.origin.y = -2.0;
	usageRect.size.width = mSpacePerDay * 0.8; //leave a little gap between
	usageRect.size.height = ([[[mCurrentPeriod data] objectAtIndex:x]usage]/[mCurrentPeriod highestDailyUsage])*rect.size.height;
	
	[NSBezierPath fillRect:usageRect];
	[NSBezierPath strokeRect:usageRect];
    }
    
}






@end
